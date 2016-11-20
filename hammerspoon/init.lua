--------------------------------------------------------------------------------
-- BetterCapsLock Mode
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- Hyper Mode
--------------------------------------------------------------------------------

-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({}, 'F18')

-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = {
  { 'a', 'iTunes' },            -- "A" for "Apple Music"
  { 'b', 'Google Chrome' },     -- "B" for "Browser"
  { 'c', 'Slack' },             -- "C for "Chat"
  { 'd', 'Remember The Milk' }, -- "D" for "Do!" ... or "Done!"
  { 'e', 'Atom Beta' },         -- "E" for "Editor"
  { 'f', 'Finder' },            -- "F" for "Finder"
  { 'g', 'Mailplane 3' },       -- "G" for "Gmail"
  { 't', 'iTerm' },             -- "T" for "Terminal"
}

for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind({}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end

-- Enter Hyper Mode when F17 (right option key) is pressed
pressedF17 = function()
  hyperMode:enter()
end

-- Leave Hyper Mode when F17 (right option key) is released.
releasedF17 = function()
  hyperMode:exit()
end

-- Bind the Hyper key
hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)
