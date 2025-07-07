-- helper.lua
-- List features and usage of the schema.
local T = {}

function T.func(input, seg, env)
    local composition = env.engine.context.composition
    local segment = composition:back()
    if seg:has_tag("help_menu") or (input == "/oh") or (input == "oH") then
        local table = {
            { "帮助菜单", "→ /oh | obv" },
            { "方案选单", "→ Control+grave(`) | F4" },
            { "中英标点", "→ Ctrl+." },
            { "繁简切换", "→ Control+Shift+4" },
            { "全角半角", "→ Control+Shift+5" },
            { "emoji显隐", "→ Shift+space" },
            { "快捷指令", "→ /kj | okj" },
            { "应用闪切", "→ /jk | ojk" },
            { "二三候选", "→ ;'号键" },
            { "上下翻页", "→ -=号键 | Tab与Shift+Tab" },
            { "以词定字", "→ Shift+1或2" },
            { "组字反查", "→ oiz" },
            { "五笔画反查", "→ obh" },
            { "虎码反查", "→ ohm" },
            { "计算器", "→ /=  | cC" },
            { "中文数字", "→ /cn | ocn" },
            { "重复上屏", "→ ;d" },
            { "词条置顶", "→ Ctrl+t" },
            { "词条降频", "→ Ctrl+j" },
            { "词条隐藏", "→ Ctrl+x" },
            { "词条删除", "→ Ctrl+d" },
            { "删用户词", "→ Ctrl+k" },
            { "时间戳值", "→ " .. "timestamp | /uts" },
            { "日期时间", "→ " .. "date | time | /wd | /wt" },
            { "农历星期", "→ " .. "lunar | week | /nl | /wk" },
            { "最近几天", "→ " .. "/wqt | /wzt | /wmt | /wht" },
            { "最近几周", "→ " .. "/wuz | /wlk | /wxz | /wnk" },
            { "最近几月", "→ " .. "/wuy | /wlm | /wxy | /wnm" },
        }
        segment.prompt = "〔帮助菜单〕"
        for _, v in ipairs(table) do
            local cand = Candidate("help", seg.start, seg._end, v[1], " " .. v[2])
            cand.quality = 999
            yield(cand)
        end
    end
end

return T
