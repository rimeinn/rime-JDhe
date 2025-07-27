-- 功能：根据候选类型添加标记（通过选项开关控制）
-- 开启时效果：
--   user_phrase   => ✩
--   user_table    => ❖
--   sentence      => ∞

local M = {}

function M.init(env)
    -- 不需要从 config 读取配置，使用 context:get_option 读取实时开关状态
end

function M.func(input, env)
    local ctx = env.engine.context
    local enabled = ctx:get_option("is_in_user_dict")  -- 读取开关选项

    for cand in input:iter() do
        if enabled then
          -- 用户词库，加上*号
            if cand.type == "user_phrase" then
                cand.comment = cand.comment .. "✩"
            end
          -- 用户短语词库
            if cand.type == "user_table" then
                cand.comment = cand.comment .. "❖"
            end
          -- 整句拼写，加上𑄗符号
            if cand.type == "sentence" then
                cand.comment = cand.comment .. "∞"
            end
            -- dict 字典
--            if cand.type == 'phrase' then
--                cand.comment = cand.comment .. '字典'
--            end  
        end
        yield(cand)
    end
end

return M
