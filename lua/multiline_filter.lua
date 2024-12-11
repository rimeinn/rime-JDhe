-- 在词典里面候选支持\r, \r\n, \n, <br>分割分行
-- &nbsp 表示空格
-- 方案patch中要添加以下两行
--  engine/filters/+:
--  - lua_filter@multiline_filter
local function multiline_filter(input)
	for cand in input:iter() do
		local nt = cand.text
		if nt:match("\\r\\n") or nt:match("\\r") or nt:match("\\n") or nt:match("<br>") or nt:match("&nbsp") then
			nt = nt:gsub("&nbsp", " ")
			nt = nt:gsub("\\r\\n", "\r")
			nt = nt:gsub("\\r", "\r")
			nt = nt:gsub("\\n", "\r")
			nt = nt:gsub("<br>", "\r")
			local cnd = Candidate("", cand.start, cand._end, nt, cand.comment)
			yield(cnd)
		else
			yield(cand)
		end
	end
end

return multiline_filter