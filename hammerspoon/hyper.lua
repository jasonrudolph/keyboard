-- Look for custom Hyper Mode app mappings. If there are none, then use the
-- default mappings.
local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')
if not status then
  hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
end

-- Create a hotkey that will enter Hyper Mode when 'alt' is tapped (i.e.,
-- when 'alt' is pressed and then released in quick succession).
local hotkey = require('keyboard.tap-modifier-for-hotkey')
hyperMode = hotkey.new('alt')

-- Bind the hotkeys that will be active when we're in Hyper Mode
for i, mapping in ipairs(hyperModeAppMappings) do
  local key = mapping[1]
  local app = mapping[2]
  hyperMode:bind(key, function()
    if (type(app) == 'string') then
      hs.application.open(app)
    elseif (type(app) == 'function') then
      app()
    else
      hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
    end
  end)
end

-- Show a status message when we're in Hyper Mode
local message = require('keyboard.status-message')
hyperMode.statusMessage = message.new('Hyper Mode')
hyperMode.entered = function()
  hyperMode.statusMessage:show()
end
hyperMode.exited = function()
  hyperMode.statusMessage:hide()
end

-- We're all set. Now we just enable Hyper Mode and get to work. 👔
hyperMode:enable()
