-- 2024/11/09更新：利用 ChatGPT 增加 spelling.lv1.1 只显示编码 spelling.lv1.2 只显示拼音功能

-- huma_spelling.lua
--[[ 
单字的字根拆分三重注解直接利用 simplifier 通过预制的 OpenCC 词库查到。
问题：这个方法，词组只能显示每个单字的注解，需要进行简化合并处理，仅显示词组编码和对应字根。
计划：用 Lua 处理词组注解。
实现障碍：simplifier 返回的类型，无法修改其注释。
   https://github.com/hchunhui/librime-lua/issues/16
一个思路：show_in_commet: false
   然后读取 cand.text 修改后作为注释显示，问题是无法直接将 cand.text 改回。
   理论上只能用 Candidate() 生成简单类型候选。
现在的方案：完全弃用 simplifier + OpenCC，单字和词组都用 Lua 处理。
注解数据来源与 OpenCC 方法相同，编成伪方案的伪词典，通过写入主方案的
schema/dependencies 来让 rime 编译为反查库 *.reverse.bin，最后通过 Lua 的反查
函数查询。
Handle multibye string in Lua:
  https://stackoverflow.com/questions/9003747/splitting-a-multibyte-string-in-lua
lua_filter 如何判断 cand 是否来自反查或当前是否处于反查状态？
  https://github.com/hchunhui/librime-lua/issues/18
--]]
local rime = require('tiger/lib')
local config = {}
config.encode_rules = {
    { length_equal = 2,            formula = 'AaAbBaBb' },
    { length_equal = 3,            formula = 'AaBaCaCb' },
    { length_in_range = { 4, 10 }, formula = 'AaBaCaZa' }
}
-- 注意借用编码规则有局限性：取码索引不一定对应取根索引，尤其是从末尾倒数时。
local spelling_rules = rime.encoder.load_settings(config.encode_rules)

local function utf8chars(str)
    local chars = {}
    for pos, code in utf8.codes(str) do chars[#chars + 1] = utf8.char(code) end
    return chars
end

local function xform(s)
    -- input format: "[spelling,code_code...,pinyin_pinyin...]"
    -- output format: "〔 spelling · code code ... · pinyin pinyin ... 〕"
    return s == '' and s or
        s:gsub('%[', '〔 '):gsub('%]', ' 〕'):gsub('{', '<')
        :gsub('}', '>'):gsub('_', ' '):gsub(',', ' · ')
end

local function parse_spll(str)
    -- Handle spellings like "{于下}{四点}丶"(for 求) where some radicals are
    -- represented by characters in braces.
    local radicals = {}
    for seg in str:gsub('%b{}', ' %0 '):gmatch('%S+') do
        if seg:find('^{.+}$') then
            table.insert(radicals, seg)
        else
            for pos, code in utf8.codes(seg) do
                table.insert(radicals, utf8.char(code))
            end
        end
    end
    return radicals
end

local function parse_raw_tricomment(str)
    return str:gsub(',.*', ''):gsub('^%[', '')
end

local function spell_phrase(s, spll_rvdb)
    local chars = utf8chars(s)
    local rule = spelling_rules[#chars]
    if not rule then return end
    local radicals = {}
    for i, coord in ipairs(rule) do
        local char_idx = coord[1] > 0 and coord[1] or #chars + 1 + coord[1]
        local raw = spll_rvdb:lookup(chars[char_idx])
        -- 若任一取码单字没有注解数据，则不对词组作注。
        if raw == '' then return end
        local char_radicals = parse_spll(parse_raw_tricomment(raw))
        local code_idx = coord[2] > 0 and coord[2] or #char_radicals + 1 +
            coord[2]
        radicals[i] = char_radicals[code_idx] or '◇'
    end
    return table.concat(radicals)
end

local function get_tricomment(cand, env)
    local text = cand.text
    if utf8.len(text) == 1 then
        local raw_spelling = env.spll_rvdb:lookup(text)
        if raw_spelling == '' then return end

        -- spelling.lv1.1 显示编码（如：〔 XDk 〕）
        if env.engine.context:get_option('spelling.lv1.1') then
            local code = env.code_rvdb:lookup(text)
            if code ~= '' then
                return ('〔 %s 〕'):format(code)
            end
        -- spelling.lv1.2 显示拼音（如：〔 hé hè hú huó huò huo 〕）
        elseif env.engine.context:get_option('spelling.lv1.2') then
            return xform(raw_spelling:gsub('%[.*,(.-)%]', '[%1]'))
        -- 默认拼音显示规则
        elseif env.engine.context:get_option('spelling.lv1') then
            return env.engine.context:get_option('spelling.lv1') and
                xform(raw_spelling:gsub('%[(.-),.*%]', '[%1]')) or
                xform(raw_spelling)
        -- spelling.lv2 显示字根和编码（如：〔 禾口 · XDk 〕）
        elseif env.engine.context:get_option('spelling.lv2') then
            return xform(raw_spelling:gsub('%[(.-,.-),.*%]', '[%1]'))
        -- spelling.lv3 显示字根、编码和拼音（如：〔 禾口 · XDk · hé hè hú huó huò huo 〕）
        elseif env.engine.context:get_option('spelling.lv3') then
            return xform(raw_spelling)
        end
    elseif utf8.len(text) > 1 then
        local spelling = spell_phrase(text, env.spll_rvdb)
        if not spelling then return end
        spelling = spelling:gsub('{(.-)}', '<%1>')

        -- spelling.lv1.1 显示编码（如：〔 XDk 〕）
        if env.engine.context:get_option('spelling.lv1.1') then
            local code = env.code_rvdb:lookup(text)
            if code ~= '' then
                return ('〔 %s 〕'):format(code)
            end
        -- spelling.lv1.2 显示拼音（如：〔 hé hè hú huó huò huo 〕）
        elseif env.engine.context:get_option('spelling.lv1.2') then
            local pinyin = env.spll_rvdb:lookup(text)
            if pinyin ~= '' then
                return ('〔 %s 〕'):format(pinyin)
            end
        -- 默认显示字根和编码（如：〔 禾口 · XDk 〕）
        elseif env.engine.context:get_option('spelling.lv2') then
            local code = env.code_rvdb:lookup(text)
            if code ~= '' then
                return ('〔 %s · %s 〕'):format(spelling, code)
            end
        -- spelling.lv3 显示字根、编码和拼音（如：〔 禾口 · XDk · hé hè hú huó huò huo 〕）
        elseif env.engine.context:get_option('spelling.lv3') then
            local code = env.code_rvdb:lookup(text)
            local pinyin = env.spll_rvdb:lookup(text)
            if code ~= '' then
                return ('〔 %s · %s · %s 〕'):format(spelling, code, pinyin)
            end
        end
    end
end

local function generate_candidate(cand, comment)
    local type = cand:get_dynamic_type()

    if type == 'Shadow' then
        if ShadowCandidate then
            cand = cand:to_shadow_candidate(cand.type, cand.text, comment, true)
        else
            cand = Candidate(cand.type, cand.text, comment)
        end
    elseif type == 'Uniquified' then
        if UniquifiedCandidate then
            cand = cand:to_uniquified_candidate(cand.type, cand.text, comment, true)
        else
            cand = Candidate(cand.type, cand.text, comment)
        end
    else
        cand.comment = comment
    end
    return cand
end

local function filter(input, env)
    if env.engine.context:get_option('spelling.off') then
        for cand in input:iter() do yield(cand) end
        return
    end
    for cand in input:iter() do
        --[[ 用户有时需要通过拼音反查简化字并显示三重注解，但 luna_pinyin 的简化字排序不
        合理且靠后。用户可开启 simplification 来解决，但是 simplifier 会强制覆盖注
        释，为了避免三重注解被覆盖，只能生成一个简单类型候选来代替原候选。 --]]
        if cand.type == 'simplified' and env.name_space == 'spelling_reverse' then
            local comment = (get_tricomment(cand, env) or '') .. cand.comment
            cand = generate_candidate(cand, comment)
        else
            local add_comment = cand.type == 'punct' and
                env.code_rvdb:lookup(cand.text) or cand.type ~=
                'sentence' and get_tricomment(cand, env)
            if add_comment and add_comment ~= '' then
                cand.comment = cand.type ~= 'completion' and
                    ((env.name_space == 'hmsp' and
                            env.is_mixtyping) or
                        (env.name_space == 'hmsp_for_rvlk')) and
                    add_comment or add_comment .. cand.comment
            end
        end
        yield(cand)
    end
end

local function init(env)
    local config = env.engine.schema.config
    local spll_rvdb = config:get_string('lua_reverse_db/spelling')
    local code_rvdb = config:get_string('lua_reverse_db/code')
    local abc_extags_size = config:get_list_size('abc_segmentor/extra_tags')
    env.spll_rvdb = ReverseDb('build/' .. spll_rvdb .. '.reverse.bin')
    env.code_rvdb = ReverseDb('build/' .. code_rvdb .. '.reverse.bin')
    env.is_mixtyping = abc_extags_size > 0
end

return {  init = init, func = filter }
