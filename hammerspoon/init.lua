-- A global variable for BetterCapsLock Mode
betterCapsLockMode = hs.hotkey.modal.new({}, 'F20')

-- When caps lock is pressed in combination with another key, translate it to
-- control plus that other key. For example, translate "caps lock + e" to
-- "control + e" to go to the end of the line.
for _, key in ipairs({ 'space', 'a', 'b', 'd', 'e', 'f', 'h', 'l', 'n', 'o', 'p', 't' }) do
  betterCapsLockMode:bind({}, key, nil, function()
    hs.eventtap.keyStroke({'⌃'}, key)
    betterCapsLockMode.triggered = true
  end)
end

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
hs.hotkey.bind({}, 'F19', pressedF19, releasedF19)
