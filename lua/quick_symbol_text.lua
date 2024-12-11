-- 欢迎使用带声调的拼音词库
-- @amzxyz
-- https://github.com/amzxyz/rime_feisheng
-- https://github.com/amzxyz/rime_wanxiang_pinyin
-- 本lua通过定义一个不直接上屏的引导符号搭配26字母实现快速符号输入，并在双击''上屏上一次的符号，双击;;重复上屏上次的汉字和字母
-- 使用方式加入到函数 - lua_processor@*quick_symbol_text 下面
-- 方案文件配置,
-- recognizer/patterns/quick_symbol: "^'.*$"
-- recognizer/patterns/quick_text: "^;.*$"
-- 新 recognizer/patterns/quick_symbol: "^'[A-Za-z']*$"
-- 新 recognizer/patterns/quick_text: "^;[A-Za-z;]*$"
-- 定义符号映射表
-- 定义符号映射表 (原有符号映射表保持不变)
local mapping = {
    q = "🥺",
    w = "🙂",
    e = "😳",
    r = "🥱",
    t = "🤮",
    y = "😵",
    u = "🙏",
    i = "🤟",
    o = "👌",
    p = "😱",
    a = "😲",
    s = "😴",
    d = "😂",
    f = "😩",
    g = "🤐",
    h = "😅",
    j = "🤫",
    k = "😭",
    l = "🤙",
    z = "😨",
    x = "😄",
    c = "🤬",
    v = "✌️",
    b = "🙄",
    n = "👍",
    m = "🤝"
}

-- 新增的;映射表
local semicolon_mapping = {
    q = "：“",
    w = "？",
    e = "“",
    r = "”",
    t = "@",
    y = "・",
    u = "「",
    i = "」",
    o = "#",
    p = "~",
    a = "！",
    s = "……",
    d = "、",
--    f = "自定义文本4",
    g = "`",
    h = "'",
    j = "。",
    k = "【",
    l = "】",
    z = "（",
    x = "*",
    c = "）",
    v = "《",
    b = "》",
    n = "<",
    m = ">"
}

-- 记录上次上屏的内容
local last_commit_symbol = ""  -- 存储符号的上屏历史
local last_commit_text = ""    -- 存储文本（汉字/字母）的上屏历史

-- 判断字符是否为符号，包括半角和全角符号
local function is_symbol(char)
    -- 检测半角符号范围
    if string.match(char, "[!@#$%%%^&*()%-_=+%[%]{}\\|;:'\",.<>/?`~]") then
        return true
    end
    -- 检测全角符号范围
    if string.match(char, "[！＠＃＄％＾＆＊（）＿＋－＝［］｛｝；：‘’“”、，。／？｀～]") then
        return true
    end
    return false
end

-- 判断上屏内容是符号还是文本（汉字/字母）
local function classify_commit_text(commit_text)
    -- 如果上屏内容中全是符号，则认为是符号
    if commit_text and #commit_text > 0 then
        for i = 1, #commit_text do
            local char = string.sub(commit_text, i, i)
            if not is_symbol(char) then
                return "text"  -- 上屏内容包含非符号字符，认为是文本
            end
        end
        return "symbol"  -- 上屏内容全是符号
    end
    return "unknown"
end

-- 初始化符号输入的状态
local function init(env)
    -- 读取 RIME 配置文件中的引导符号模式
    local config = env.engine.schema.config

    -- 动态读取符号和文本重复的引导模式
    local quick_symbol_pattern = config:get_string("recognizer/patterns/quick_symbol") or "^'.*$"
    local quick_text_pattern = config:get_string("recognizer/patterns/quick_text") or "^;.*$"

    -- 提取配置值中的第二个字符作为引导符
    local quick_symbol = string.sub(quick_symbol_pattern, 2, 2) or "'"
    local quick_text = string.sub(quick_text_pattern, 2, 2) or ";"
    
    -- 生成单引导符和双引导符模式
    env.single_symbol_pattern = "^" .. quick_symbol .. "([a-zA-Z])$"
    env.double_symbol_pattern_symbol = "^" .. quick_symbol .. quick_symbol .. "$"
    env.double_symbol_pattern_text = "^" .. quick_text .. quick_text .. "$"
    env.single_semicolon_pattern = "^" .. quick_text .. "([a-zA-Z])$"

    -- 捕获上屏事件，分类存储符号和文本
    env.engine.context.commit_notifier:connect(function(ctx)
        local commit_text = ctx:get_commit_text()

        -- 通过分类判断是符号还是文本
        local classification = classify_commit_text(commit_text)
        if classification == "symbol" then
            last_commit_symbol = commit_text  -- 保存符号到 last_commit_symbol
        elseif classification == "text" then
            last_commit_text = commit_text  -- 保存文本到 last_commit_text
        end
    end)
end

-- 捕获符号键盘事件并记录符号
local function capture_symbol_key(key_event)
    -- 获取按键字符表示
    local keychar = key_event:repr()

    -- 判断该字符是否为符号（半角或全角）
    if is_symbol(keychar) then
        return keychar  -- 返回符号字符
    end

    return nil
end

-- 处理符号和文本的重复上屏逻辑
local function processor(key_event, env)
    local engine = env.engine
    local context = engine.context
    local input = context.input  -- 当前输入的字符串

    -- 1. 检查是否输入的编码为双引导符 ;;，用于汉字或字母重复上屏
    if string.match(input, env.double_symbol_pattern_text) then
        if last_commit_text ~= "" then
            engine:commit_text(last_commit_text)  -- 上屏上次的汉字或文本
            context:clear()  -- 清空输入
            return 1  -- 捕获事件，处理完成
        end
    end

    -- 2. 检查是否输入的编码为双引导符 ''，用于符号重复上屏
    if string.match(input, env.double_symbol_pattern_symbol) then
        if last_commit_symbol ~= "" then
            engine:commit_text(last_commit_symbol)  -- 上屏上次的符号
            context:clear()  -- 清空输入
            return 1  -- 捕获事件，处理完成
        end
    end

    -- 3. 检查是否输入的编码为;搭配字母
    local match = string.match(input, env.single_semicolon_pattern)
    if match then
        local semicolon_symbol = semicolon_mapping[match]  -- 获取匹配的符号或文本
        if semicolon_symbol then
            -- 将符号或文本直接上屏并保存到符号历史
            engine:commit_text(semicolon_symbol)
            last_commit_symbol = semicolon_symbol  -- 保存符号到 last_commit_symbol
            context:clear()  -- 清空输入
            return 1  -- 捕获事件，处理完成
        end
    end

    -- 4. 检查当前输入是否匹配单引导符符号模式 'q、'w 等
    match = string.match(input, env.single_symbol_pattern)
    if match then
        local symbol = mapping[match]  -- 获取匹配的符号
        if symbol then
            -- 将符号直接上屏并保存到符号历史
            engine:commit_text(symbol)
            last_commit_symbol = symbol  -- 保存符号到 last_commit_symbol
            context:clear()  -- 清空输入
            return 1  -- 捕获事件，处理完成
        end
    end

    return 2  -- 未处理事件，继续传播
end

-- 导出到 RIME
return { init = init, func = processor }
