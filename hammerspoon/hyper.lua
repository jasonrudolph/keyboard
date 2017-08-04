local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')

if not status then
  hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
end

for i, mapping in ipairs(hyperModeAppMappings) do
  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end
