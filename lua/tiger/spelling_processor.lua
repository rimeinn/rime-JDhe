local rime = require('tiger/lib')
-- options 要与方案保持一致
local options = { 'spelling.off', 'spelling.lv1', 'spelling.lv2', 'spelling.lv3' }
options.default = 1

local processor = rime.make_option_cycler(options,
    'spelling/lua/cycle_key',
    'spelling/lua/switch_key')



return processor
