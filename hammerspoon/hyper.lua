local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types
local simultaneousKeypressModal = require('keyboard.simultaneous-keypress-modal')

-- Look for custom Hyper Mode app mappings. If there are none, then use the
-- default mappings.
local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')
if not status then
  hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
end

-- Create a hotkey that will enter Hyper Mode when 'k' and 'l' are pressed
-- simultaneously.
hyperMode = simultaneousKeypressModal.new('Hyper Mode', 'k', 'l')

--------------------------------------------------------------------------------
-- Watch for key-down events in Hyper Mode, and trigger app associated with the
-- given key.
--------------------------------------------------------------------------------
hyperModeKeyListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not hyperMode:isActive() then
    return false
  end

  local app = hyperModeAppMappings[event:getCharacters(true):lower()]

  if app then
    if (type(app) == 'string') then
      hs.application.open(app)
    elseif (type(app) == 'function') then
      app()
    else
      hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
    end
    return true
  end
end):start()

--- We're all set. Now we just enable Hyper Mode and get to work. 👔
hyperMode:enable()
