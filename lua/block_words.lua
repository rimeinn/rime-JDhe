-- block_words.lua
-- 功能：
--   1) 可开关的屏蔽词过滤（首选始终保留）
--   2) 当且仅当【当前输入码长 == 4 且首选是单字】时，把 "①" 插到候选首位

local blocked_words = {
  ["①"] = true,
  ["②"] = true,
-- ["不良词"] = true,
}

local function filter(input, env)
  -- 将流式候选收集到数组，便于插入与重排
  local cands = {}
  for cand in input:iter() do
    table.insert(cands, cand)
  end
  if #cands == 0 then return end

  local ctx        = env.engine.context
  local block_on   = ctx:get_option("block_words_enabled")
  local composing  = ctx.input               -- 当前正在输入的编码
  local is_four_cs = composing and (#composing == 4)

  ------------------------------------------------------------------
  -- ★ 条件：四码输入且首选单字 ⇒ 插入 "①"
  ------------------------------------------------------------------
  if is_four_cs and utf8.len(cands[1].text) == 1 then
    local first = cands[1]
    local one   = Candidate("symbol", first.start, first._end, "①", "")
    -- 让 "①" 不受屏蔽表影响
    blocked_words["①"] = false
    table.insert(cands, 1, one)
  end

  ------------------------------------------------------------------
  -- 输出：遵循“首选必出 + 开关 + 屏蔽表”规则
  ------------------------------------------------------------------
  for idx, cand in ipairs(cands) do
    if not block_on then
      yield(cand)                      -- 屏蔽未启用，全部输出
    else
      if idx == 1 then
        yield(cand)                    -- 首选始终输出
      elseif not blocked_words[cand.text] then
        yield(cand)                    -- 其余若不在屏蔽表，输出
      end
    end
  end
end

return filter
