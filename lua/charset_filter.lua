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
    { first = 0x2EBF0, last = 0x2EE4F }, -- 擴I
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

local function read_charset() return require('charset') end

local function init(env) env.charsets = read_charset() end

local function get_charset_option(env)
    return env.engine.context:get_option('charset_filter')
end

local function get_charset(env, option)
    if option then return env.charsets end
    return nil
end

local function get_chinese_only_option(env)
    return env.engine.context:get_option('chinese_only')
end

local function is_chinese(code)
    for index, value in ipairs(chinese_charset) do
        if code >= value.first and code <= value.last then return true end
    end
    return false
end

local function is_in_charset(char, charset) return charset[char] end

-- 對於CJK之外的字符不做過濾，假定所有的字符在CJK區
local function filter_charset(string, charset)
    if not charset then return true end
    for index, code in utf8.codes(string) do
        if not is_in_charset(utf8.char(code), charset) then return false end
    end
    return true
end

local function filter_chinese(string)
    for index, code in utf8.codes(string) do
        if not is_chinese(code) then return false end
    end
    return true
end

local function charset_filter(input, env)
    local charset_option = get_charset_option(env)
    local chinese_only_option = get_chinese_only_option(env)
    local charset = get_charset(env, charset_option)
    for cand in input:iter() do
        local cand_gen = cand:get_genuine()
        if filter_chinese(cand_gen.text) then
            if filter_charset(cand_gen.text, charset) then
                yield(cand)
            end
        else
            if not chinese_only_option then yield(cand) end
        end
    end
end

return { init = init, func = charset_filter }
