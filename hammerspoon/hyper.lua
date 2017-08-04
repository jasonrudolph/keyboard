local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')

if not status then
  hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
end

for i, mapping in ipairs(hyperModeAppMappings) do
  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, mapping[1], function()
    local appName = mapping[2]
    local app = hs.application.get(appName)
    if app then
      app:activate()
    else
      hs.application.launchOrFocus(appName)
    end
  end)
end
