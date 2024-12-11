-- 2024-11-10 更新
-- 增加 how_only_first_in_preedit: true 控制是否仅显示首选词在编辑栏
-- 作者：王牌餅乾
-- https://github.com/lost-melody/
-- 转载请保留作者名
-- Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
---------------------------------------

-- 將要被返回的過濾器對象
local embeded_cands_filter = {}

--[[ 
# xxx.schema.yaml 
switches: 
  - name: embeded_cands 
    states: [ 普通, 嵌入 ] 
    reset: 1 
engine: 
  filters: 
    - lua_filter@*smyh.embeded_cands 
key_binder: 
  bindings: 
    - { when: always, accept: "Control+Shift+E", toggle: embeded_cands }
--]]

-- 候選序號標記
local index_indicators = {"¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰"}

-- 首選/非首選格式定義
local first_format = "${Stash}[${候選}${Seq}]${Code}${Comment}"
local next_format = "${Stash}${候選}${Seq}${Comment}"
local separator = " "

-- 讀取 schema.yaml 開關設置:
local option_name = "embeded_cands"
local only_first_option_name = "show_only_first_in_preedit"

-- 從方案配置中讀取字符串
local function parse_conf_str(env, path, default)
    local str = env.engine.schema.config:get_string(env.name_space.."/"..path)
    if not str and default and #default ~= 0 then
        str = default
    end
    return str
end

-- 從方案配置中讀取字符串列表
local function parse_conf_str_list(env, path, default)
    local list = {}
    local conf_list = env.engine.schema.config:get_list(env.name_space.."/"..path)
    if conf_list then
        for i = 0, conf_list.size-1 do
            table.insert(list, conf_list:get_value_at(i).value)
        end
    elseif default then
        list = default
    end
    return list
end

-- 構造開關變更回調函數
local function get_switch_handler(env, op_name)
    local option
    if not env.option then
        option = {}
        env.option = option
    else
        option = env.option
    end
    -- 返回通知回調, 當改變選項值時更新暫存的值
    return function(ctx, name)
        if name == op_name then
            option[name] = ctx:get_option(name)
            if option[name] == nil then
                -- 當選項不存在時默認爲啟用狀態
                option[name] = true
            end
        end
    end
end

local function compile_formatter(format)
    local pattern = "%$%{[^{}]+%}"
    local verbs = {}
    for s in string.gmatch(format, pattern) do
        table.insert(verbs, s)
    end

    local res = {
        format = string.gsub(format, pattern, "%%s"),
        verbs = verbs,
    }
    local meta = { __index = function() return "" end }

    function res:build(dict)
        setmetatable(dict, meta)
        local args = {}
        for _, pat in ipairs(self.verbs) do
            table.insert(args, dict[pat])
        end
        return string.format(self.format, table.unpack(args))
    end

    return res
end

local namespaces = {}
function namespaces:init(env)
    if not namespaces:config(env) then
        local config = {}
        config.index_indicators = parse_conf_str_list(env, "index_indicators", index_indicators)
        config.first_format = parse_conf_str(env, "first_format", first_format)
        config.next_format = parse_conf_str(env, "next_format", next_format)
        config.separator = parse_conf_str(env, "separator", separator)
        config.option_name = parse_conf_str(env, "option_name")

        config.formatter = {}
        config.formatter.first = compile_formatter(config.first_format)
        config.formatter.next = compile_formatter(config.next_format)
        namespaces:set_config(env, config)
    end
end
function namespaces:set_config(env, config)
    namespaces[env.name_space] = namespaces[env.name_space] or {}
    namespaces[env.name_space].config = config
end
function namespaces:config(env)
    return namespaces[env.name_space] and namespaces[env.name_space].config
end

function embeded_cands_filter.init(env)
    local ok = pcall(namespaces.init, namespaces, env)
    if not ok then
        local config = {}
        config.index_indicators = index_indicators
        config.first_format = first_format
        config.next_format = next_format
        config.separator = separator
        config.option_name = parse_conf_str(env, "option_name")

        config.formatter = {}
        config.formatter.first = compile_formatter(config.first_format)
        config.formatter.next = compile_formatter(config.next_format)
        namespaces:set_config(env, config)
    end

    local config = namespaces:config(env)
    if config.option_name and #config.option_name ~= 0 then
        local handler = get_switch_handler(env, config.option_name)
        handler(env.engine.context, config.option_name)
        env.engine.context.option_update_notifier:connect(handler)
    else
        config.option_name = option_name
        env.option = {}
        env.option[config.option_name] = true
    end

    env.show_only_first_in_preedit = env.engine.schema.config:get_bool(env.name_space .. "/" .. only_first_option_name) or false
end

local function render_comment(comment)
    if string.match(comment, "^[ ~]") then
        comment = ""
    elseif string.len(comment) ~= 0 then
        comment = "["..comment.."]"
    end
    return comment
end

local function render_cand(env, seq, code, text, comment)
    local formatter
    if seq == 1 then
        formatter = namespaces:config(env).formatter.first
    else
        formatter = namespaces:config(env).formatter.next
    end
    comment = render_comment(comment)
    if env.show_only_first_in_preedit and seq > 1 then
        return ""
    end
    local cand = formatter:build({
        ["${Seq}"] = namespaces:config(env).index_indicators[seq],
        ["${Code}"] = code,
        ["${候選}"] = text,
        ["${Comment}"] = comment,
    })
    return cand
end

function embeded_cands_filter.func(input, env)
    if not env.option[namespaces:config(env).option_name] then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local page_size = env.engine.schema.page_size
    local page_cands, page_rendered = {}, {}
    local index, first_cand, preedit = 0, nil, ""

    local function refresh_preedit()
        if first_cand then
            first_cand.preedit = table.concat(page_rendered, namespaces:config(env).separator)
            for _, c in ipairs(page_cands) do
                yield(c)
            end
        end
        first_cand, preedit = nil, ""
        page_cands, page_rendered = {}, {}
    end

    local hash = {}
    local rank = 0
    local iter, obj = input:iter()
    local next = iter(obj)
    while next do
        index = index + 1
        local cand = next

        if (not hash[cand.text]) then
            hash[cand.text] = true

            if not first_cand then
                first_cand = cand
            end

            rank = rank + 1
            preedit = render_cand(env, rank, first_cand.preedit, cand.text, cand.comment)

            table.insert(page_cands, cand)
            table.insert(page_rendered, preedit)
        end

        if index == page_size then
            refresh_preedit()
            rank = 0
        end

        next = iter(obj)
        if not next and index < page_size then
            refresh_preedit()
        end
        index = index % page_size
    end
end

function embeded_cands_filter.fini(env)
end

return embeded_cands_filter
