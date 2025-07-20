-- block_words.lua
-- 功能：
--   1) 可开关屏蔽词过滤（首选始终保留）
--   2) 若输入长度为 4 且首选为「单个中文汉字」→ 插入 "①" 到首位
--   3) 否则 → 完全屏蔽 "①"

local blocked_words = {
  ["①"] = true,
  ["②"] = true,
-- ["不良词"] = true,
}

-- 判断是否是 CJK 汉字（统一表意文字）
local function is_cjk_hanzi(char)
  if not char or utf8.len(char) ~= 1 then return false end
  local code = utf8.codepoint(char)
  return (code >= 0x4E00 and code <= 0x9FFF)
end

local function filter(input, env)
  -- 收集所有候选
  local cands = {}
  for cand in input:iter() do
    table.insert(cands, cand)
  end
  if #cands == 0 then return end

  local ctx        = env.engine.context
  local block_on   = ctx:get_option("block_words_enabled")
  local composing  = ctx.input
  local is_four_cs = composing and (#composing == 4)

  -- ---------------- 四码逻辑 -------------------
  if is_four_cs then
    local first_text = cands[1].text
    if is_cjk_hanzi(first_text) then
      -- 插入 "①"，并允许显示
      local first = cands[1]
      local one = Candidate("symbol", first.start, first._end, "①", "")
      blocked_words["①"] = false
      table.insert(cands, 1, one)
    else
      -- 首选不是汉字 ⇒ 屏蔽 "①"
      blocked_words["①"] = true
    end
  end
  -- ---------------------------------------------

  -- 输出候选，遵循：首选必出 + 屏蔽表 + 开关控制
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
