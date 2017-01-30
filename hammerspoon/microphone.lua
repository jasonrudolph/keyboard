local message = require('status-message')

local messageMuting = message.new('muted 🎤')
local messageHot = message.new('hot 🎤')
local last_mods = {}
local recently_clicked = false
local second_click = false

display_status = function ()
  -- Check if the active mic is muted
  if hs.audiodevice.current(true).device:muted() then
    messageMuting:notify()
  else
    messageHot:notify()
  end
end
display_status()

toggle = function (device)
  if device:muted() then
    device:setMuted(false)
  else
    device:setMuted(true)
  end
end

control_key_handler = function()
  recently_clicked = false
end

control_key_timer = hs.timer.delayed.new(0.3, control_key_handler)

option_handler = function(event)
  local device = hs.audiodevice.current(true).device
  local new_mods = event:getFlags()

  -- alt keyDown
  if new_mods['alt'] == true then
    toggle(device)
    if recently_clicked == true then
      display_status()
      second_click = true
    end
    recently_clicked = true
    control_key_timer:start()

  -- alt keyUp
  elseif last_mods['alt'] == true and new_mods['alt'] == nil then
    if second_click then
      second_click = false
    else
      toggle(device)
    end
  end

  last_mods = new_mods
end

option_key = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, option_handler)
option_key:start()
