-- block_words.lua
-- 屏蔽指定的字词列表，并通过开关控制是否启用

local blocked_words = {
    ["①"] = true,
    ["②"] = true,
--  ["不良词"] = true,
}

local function filter(input, env)
    local block_enabled = env.engine.context:get_option("block_words_enabled")
    local index = 0

    for cand in input:iter() do
        index = index + 1
        if not block_enabled then
            yield(cand)  -- 未开启屏蔽，直接显示
        else
            if index == 1 then
                -- 首选项，无论是否屏蔽，都显示
                yield(cand)
            elseif not blocked_words[cand.text] then
                -- 不是首选项，且不在屏蔽表中，显示
                yield(cand)
            end
            -- 如果是非首选且被屏蔽，就不 yield，自动过滤
        end
    end
end

return filter

