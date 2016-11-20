-- A global variable for BetterCapsLock Mode
betterCapsLockMode = hs.hotkey.modal.new({}, 'F20')

--------------------------------------------------------------------------------
-- Define keybindings available within BetterCapsLock Mode
--------------------------------------------------------------------------------

-- When caps lock is pressed in combination with another normal key, translate
-- it to control plus that other normal key. For example, translate
-- "caps lock + e" to "control + e" to go to the end of the line.
for _, key in ipairs({ 'space', 'a', 'b', 'd', 'e', 'f', 'h', 'l', 'n', 'o', 'p', 't' }) do
  betterCapsLockMode:bind({}, key, nil, function()
    hs.eventtap.keyStroke({'⌃'}, key)
    betterCapsLockMode.triggered = true
  end)
end

-- Use BetterCapsLock+r to reload Hammerspoon config
betterCapsLockMode:bind({}, 'r', nil, function()
  hs.reload()
end)

--------------------------------------------------------------------------------
-- Define WindowLayout Mode
--
-- WindowLayout Mode allows you to manage window layout using keyboard shortcuts
-- that are on the home row, or very close to it. Use BetterCapsLock+w to turn
-- on WindowLayout mode. Then, use any shortcut below to perform a window layout
-- action. For example, to send the window left, hit BetterCapsLock+w, and then
-- h.
--
--   h => send window to the left half of the screen
--   j => send window to the bottom half of the screen
--   k => send window to the top half of the screen
--   l => send window to the right half of the screen
--   return => make window full screen
--------------------------------------------------------------------------------

require('windows')

windowLayoutMode = hs.hotkey.modal.new({}, 'F16')

-- Bind the given key to call the given function and exit WindowLayout mode
function windowLayoutMode.bindWithAutomaticExit(mode, key, fn)
  mode:bind({}, key, function()
    mode:exit()
    fn()
  end)
end

windowLayoutMode:bindWithAutomaticExit('return', function()
  hs.window.focusedWindow():maximize()
end)

windowLayoutMode:bindWithAutomaticExit('h', function()
  hs.window.focusedWindow():left()
end)

windowLayoutMode:bindWithAutomaticExit('j', function()
  hs.window.focusedWindow():down()
end)

windowLayoutMode:bindWithAutomaticExit('k', function()
  hs.window.focusedWindow():up()
end)

windowLayoutMode:bindWithAutomaticExit('l', function()
  hs.window.focusedWindow():right()
end)

pressedW = function()
  betterCapsLockMode.triggered = true
  windowLayoutMode:enter()
end

releasedW = function() end
betterCapsLockMode:bind({}, 'w', nil, pressedW, releasedW)

--------------------------------------------------------------------------------
-- Bind BetterCapsLock Mode to F19 (caps lock)
--------------------------------------------------------------------------------

-- Enter BetterCapsLock Mode when F19 (caps lock) is pressed.
pressedF19 = function()
  betterCapsLockMode.triggered = false
  betterCapsLockMode:enter()
end

-- Leave BetterCapsLock Mode when F19 (caps lock) is released.
--   Send ESCAPE if no other keys are pressed.
releasedF19 = function()
  betterCapsLockMode:exit()
  if not betterCapsLockMode.triggered then
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

-- Bind the BetterCapsLock key
f19 = hs.hotkey.bind({}, 'F19', pressedF19, releasedF19)
