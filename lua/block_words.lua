-- block_words.lua
-- 屏蔽指定的字词列表，并通过开关控制是否启用

local blocked_words = {
    ["①"] = true,
--    ["②"] = true,
--    ["不良词"] = true,  -- 在这里添加你想要屏蔽的字词
}

-- 默认的开关值为 false（不开启屏蔽）
local block_words_enabled = false

-- 过滤候选词
local function filter(input, env)
    -- 获取来自 schema 配置中的开关
    local switch = env.engine.context:get_option("block_words_enabled")
    
    -- 如果开关启用，则更新屏蔽状态
    if switch ~= nil then
        block_words_enabled = switch
    end

    -- 遍历候选词
    for cand in input:iter() do
        if block_words_enabled then
            -- 启用屏蔽功能，检查候选词是否在屏蔽字词表中
            if not blocked_words[cand.text] then
                yield(cand)  -- 如果不在屏蔽列表中，则显示该候选词
            end
        else
            -- 如果没有启用屏蔽，直接显示所有候选词
            yield(cand)
        end
    end
end

-- 返回过滤函数
return filter
