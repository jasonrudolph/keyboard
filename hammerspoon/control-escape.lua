-- Credit for this implementation goes to @arbelt and @jasoncodes 🙇⚡️😻
--
--   https://gist.github.com/arbelt/b91e1f38a0880afb316dd5b5732759f1
--   https://github.com/jasoncodes/dotfiles/blob/ac9f3ac/hammerspoon/control_escape.lua

sendEscape = false
lastMods = {}

controlKeyHandler = function()
  sendEscape = false
end

controlKeyTimer = hs.timer.delayed.new(0.15, controlKeyHandler)

controlHandler = function(evt)
  local newMods = evt:getFlags()
  if lastMods["ctrl"] == newMods["ctrl"] then
    return false
  end
  if not lastMods["ctrl"] then
    lastMods = newMods
    sendEscape = true
    controlKeyTimer:start()
  else
    if sendEscape then
      keyUpDown({}, 'escape')
    end
    lastMods = newMods
    controlKeyTimer:stop()
  end
  return false
end

controlTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, controlHandler)
controlTap:start()

otherHandler = function(evt)
  sendEscape = false
  return false
end

otherTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, otherHandler)
otherTap:start()
