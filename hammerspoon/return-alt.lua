local isReturnKeyDown = false

local longPressTimer = hs.timer.delayed.new(0.5, function() end)

local function addAltToKeyEvent(keyEvent)
  local flags = keyEvent:getFlags()
  flags["alt"] = true
  keyEvent:setFlags(flags)
  return keyEvent
end

local function modifyReturn(event)
  local keyCode = event:getKeyCode()

  if keyCode == hs.keycodes.map["return"] then

    if event:getType() == hs.eventtap.event.types.keyDown then
      if isReturnKeyDown == false then
       isReturnKeyDown = true
       longPressTimer:start()
      end

    else
      isReturnKeyDown = false
      if longPressTimer:running() then
        longPressTimer:stop()
        return true,
        {
          hs.eventtap.event.newKeyEvent({}, hs.keycodes.map["return"], true),             hs.eventtap.event.newKeyEvent({}, hs.keycodes.map["return"], false)  
        }
      end

    end

    return true
  else
    if isReturnKeyDown then
      longPressTimer:stop()
      addAltToKeyEvent(event)
    end

    return false
  end
end

local returnEvents = {
   hs.eventtap.event.types.keyDown,
   hs.eventtap.event.types.keyUp
}

return_tap = hs.eventtap.new(returnEvents, modifyReturn)
return_tap:start()
