-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = require('keyboard.hyper-apps')
for i, mapping in ipairs(hyperModeAppMappings) do
  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end
