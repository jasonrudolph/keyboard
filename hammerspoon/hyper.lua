local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')

if not status then
  hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
end

local switchToApp = function (app)
  local frontmostApp = hs.application.frontmostApplication()
  local openApp = hs.application.get(app)
  if openApp and frontmostApp:name() == openApp:name() then
    hs.eventtap.keyStroke({'command'}, '`', 0)
  else
    hs.application.open(app)
  end
end

for i, mapping in ipairs(hyperModeAppMappings) do
  local key = mapping[1]
  local app = mapping[2]
  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, function()
    if (type(app) == 'string') then
      switchToApp(app)
    elseif (type(app) == 'function') then
      app()
    else
      hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
    end
  end)
end
