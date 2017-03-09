local message = require('status-message')

local messageMuting = message.new('muted 🎤')
local messageHot = message.new('hot 🎤')
local lastMods = {}
local recentlyClicked = false
local secondClick = false

displayStatus = function()
  -- Check if the active mic is muted
  if hs.audiodevice.defaultInputDevice():muted() then
    messageMuting:notify()
  else
    messageHot:notify()
  end
end
displayStatus()

toggle = function (device)
  if device:muted() then
    device:setMuted(false)
  else
    device:setMuted(true)
  end
end

optionKeyHandler = function()
  recentlyClicked = false
end

controlKeyTimer = hs.timer.delayed.new(0.3, optionKeyHandler)

option_handler = function(event)
  local device = hs.audiodevice.defaultInputDevice()
  local newMods = event:getFlags()

  -- alt keyDown
  if newMods['alt'] == true then
    toggle(device)
    if recentlyClicked == true then
      displayStatus()
      secondClick = true
    end
    recentlyClicked = true
    controlKeyTimer:start()

  -- alt keyUp
  elseif lastMods['alt'] == true and newMods['alt'] == nil then
    if secondClick then
      secondClick = false
    else
      toggle(device)
    end
  end

  lastMods = newMods
end

option_key = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, option_handler)
option_key:start()
