local Module = {}

function Module.init(env)
   env.enable_quick_code_hint = env.engine.schema.config:get_bool("moran/enable_quick_code_hint")
   if env.enable_quick_code_hint then
      -- The user might have changed it.
      local dict = env.engine.schema.config:get_string("fixed/dictionary")
      env.quick_code_hint_reverse = ReverseLookup(dict)
      env.quick_code_hint_skip_chars = env.engine.schema.config:get_bool("moran/quick_code_hint_skip_chars") or false
      
      -- 获取配置中允许的词长范围（默认为 2 和 3）
      env.quick_code_hint_min_len = env.engine.schema.config:get_int("moran/quick_code_hint_min_len") or 2
      env.quick_code_hint_max_len = env.engine.schema.config:get_int("moran/quick_code_hint_max_len") or 3
   else
      env.quick_code_hint_reverse = nil
   end
   env.quick_code_indicator = env.engine.schema.config:get_string("moran/quick_code_indicator") or "⚡"
end

function Module.fini(env)
   env.quick_code_hint_reverse = nil
   collectgarbage()
end

function Module.func(translation, env)
   if (not env.enable_quick_code_hint) or env.quick_code_hint_reverse == nil then
      for cand in translation:iter() do
         yield(cand)
      end
      return
   end

   -- Look up if the "genuine" candidate is already in the qc dict
   for cand in translation:iter() do
      if cand.type == "punct" then
         yield(cand)
         goto outer_continue
      end

      local gcand = cand:get_genuine()
      local word = gcand.text

      -- 获取当前词的长度
      local word_len = utf8.len(word)

      -- 只有当词的长度在配置的范围内时才进行快速代码提示
      if word_len < env.quick_code_hint_min_len or word_len > env.quick_code_hint_max_len then
         yield(cand)
         goto outer_continue
      end

      -- 词长符合条件，执行快速代码提示
      local all_codes = env.quick_code_hint_reverse:lookup(word)
      local in_use = false
      if all_codes then
         local codes = {}
         for code in all_codes:gmatch("%S+") do
            if #code < 4 then
               if code == cand.preedit then
                  in_use = true
               else
                  table.insert(codes, code)
               end
            end
         end
         if #codes == 0 and not in_use then
            goto inner_continue
         end
         local codes_hint = table.concat(codes, " ")
         local comment = ""
         if gcand.comment == env.quick_code_indicator then
            -- 避免重复的⚡符号
            comment = gcand.comment .. codes_hint
         else
            comment = gcand.comment .. env.quick_code_indicator .. codes_hint
         end
         gcand.comment = comment
      end
      ::inner_continue::
      yield(cand)

      ::outer_continue::
   end
end

return Module
