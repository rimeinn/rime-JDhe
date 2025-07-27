local chinese_charset = {
    { first = 0x4E00, last = 0x9FFF },   -- 基本汉字+补充
    { first = 0x3400, last = 0x4DBF },   -- 扩A
    { first = 0x20000, last = 0x2A6DF }, -- 扩B
    { first = 0x2A700, last = 0x2B739 }, -- 扩C
    { first = 0x2B740, last = 0x2B81F }, -- 扩D
    { first = 0x2B820, last = 0x2CEAF }, -- 扩E
    { first = 0x2CEB0, last = 0x2EBEF }, -- 扩F
    { first = 0x30000, last = 0x3134A }, -- 扩G
    { first = 0x31350, last = 0x323AF }, -- 扩H
    { first = 0x2EBF0, last = 0x2EE4F }, -- 扩I
    { first = 0x2E80, last = 0x2EF3 },   -- 部首扩展
    { first = 0x2F00, last = 0x2FD5 },   -- 康熙部首
    { first = 0xF900, last = 0xFAFF },   -- 兼容汉字
    { first = 0x2F800, last = 0x2FA1D }, -- 兼容扩展
    { first = 0xE815, last = 0xE86F },   -- PUA(GBK)部件
    { first = 0xE400, last = 0xE5E8 },   -- 部件扩展
    { first = 0xE600, last = 0xE6CF },   -- PUA增补
    { first = 0x31C0, last = 0x31E3 },   -- 汉字笔画
    { first = 0x2FF0, last = 0x2FFB },   -- 汉字结构
    { first = 0x3105, last = 0x312F },   -- 汉语注音
    { first = 0x31A0, last = 0x31BA },   -- 注音扩展
    { first = 0x3007, last = 0x3007 }    -- 〇
}

local function is_chinese(code)
    for _, range in ipairs(chinese_charset) do
        if code >= range.first and code <= range.last then return true end
    end
    return false
end

local function get_charset_option(env)
    return env.engine.context:get_option('charset_filter')
end

local function get_chinese_only_option(env)
    return env.engine.context:get_option('chinese_only')
end

local function get_charset_mode(env)
    local config = env.engine.schema.config
    return config:get_string("charset") or "both"
end

local function should_include_char(tag, mode)
    if mode == "both" then return tag == 't' or tag == 'f' or tag == 'j' end
    if mode == "simp" then return tag == 'j' or tag == 't' end
    if mode == "trad" then return tag == 'f' or tag == 't' end
    return true
end

local function filter_charset(str, charsetdb, mode)
    if not charsetdb then return true end
    for _, code in utf8.codes(str) do
        local ch = utf8.char(code)
        local tag = charsetdb:lookup(ch)  -- 使用反查字典
        tag = tag:sub(1, 1)
        if tag == "" or not should_include_char(tag, mode) then
            return false
        end
    end
    return true
end

local function filter_chinese(str)
    for _, code in utf8.codes(str) do
        if not is_chinese(code) then return false end
    end
    return true
end

local function charset_filter(input, env)
    local charset_option = get_charset_option(env)
    local chinese_only_option = get_chinese_only_option(env)
    local charset_mode = get_charset_mode(env)
    local charsetdb = charset_option and env.charsetdb or nil

    for cand in input:iter() do
        local cand_gen = cand:get_genuine()
        if filter_chinese(cand_gen.text) then
            if filter_charset(cand_gen.text, charsetdb, charset_mode) then
                yield(cand)
            end
        else
            if not chinese_only_option then
                yield(cand)
            end
        end
    end
end

-- 初始化时加载反查字典文件
local function init(env)
    -- 使用 ReverseLookup 加载名为 "charset" 的字典
    env.charsetdb = ReverseLookup("charset")  -- 这里会自动加载名为 charset 的字典
end

return { init = init, func = charset_filter }
