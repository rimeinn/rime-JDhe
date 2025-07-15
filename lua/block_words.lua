-- block_words.lua
-- 1) 可开关屏蔽词过滤（首选始终保留）
-- 2) 4 码输入时的特殊处理：
--    a. 首选是单字 → 插入 "①" 到首位
--    b. 否则 → 完全屏蔽 "①"

local blocked_words = {
  ["①"] = true,
  ["②"] = true,
-- ["不良词"] = true,
}

local function filter(input, env)
  -- 收集候选
  local cands = {}
  for cand in input:iter() do
    table.insert(cands, cand)
  end
  if #cands == 0 then return end

  local ctx        = env.engine.context
  local block_on   = ctx:get_option("block_words_enabled")
  local composing  = ctx.input
  local is_four_cs = composing and (#composing == 4)

  -- ------------- 4 码处理 ----------------
  if is_four_cs then
    local first_is_single = utf8.len(cands[1].text) == 1

    if first_is_single then
      -- 插入 "①" 到首位，并确保它不被屏蔽
      local first = cands[1]
      local one   = Candidate("symbol", first.start, first._end, "①", "")
      blocked_words["①"] = false            -- 允许显示
      table.insert(cands, 1, one)
    else
      -- 首选不是单字 → 严格屏蔽 "①"
      blocked_words["①"] = true
    end
  end
  -- ---------------------------------------

  -- 输出阶段：首选必出 + 开关 + 屏蔽表
  for idx, cand in ipairs(cands) do
    if not block_on then
      yield(cand)
    else
      if idx == 1 then
        yield(cand)
      elseif not blocked_words[cand.text] then
        yield(cand)
      end
    end
  end
end

return filter
