-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({}, 'F18')

local message = require('keyboard.status-message')
statusMessage = message.new('Hyper Mode')

function hyperMode:entered()
  statusMessage:show()
end

function hyperMode:exited()
  statusMessage:hide()
end

-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = {
  { 'a', 'iTunes' },                -- "A" for "Apple Music"
  { 'b', 'Google Chrome' },         -- "B" for "Browser"
  { 'c', 'Hackable Slack Client' }, -- "C for "Chat"
  { 'd', 'Remember The Milk' },     -- "D" for "Do!" ... or "Done!"
  { 'e', 'Atom' },                  -- "E" for "Editor"
  { 'f', 'Finder' },                -- "F" for "Finder"
  { 'g', 'Mailplane 3' },           -- "G" for "Gmail"
  { 's', 'Slack' },                 -- "S" for "Slack"
  { 't', 'iTerm' },                 -- "T" for "Terminal"
}

for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind({}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end

-- Enter Hyper Mode when F17 (right option key) is pressed
pressedF17 = function()
  hyperMode:enter()

  -- The releasedF17 function *should* get called when the Hyper key is
  -- released, but for some reason it seems that Hammerspoon sometimes fails to
  -- invoke that function. If Hammerspoon fails to invoke the releasedF17
  -- function, we end up stuck in Hyper Mode until the user once again presses
  -- and releases the Hyper Key. 🙀
  --
  -- To reduce the likelihood of getting stuck in Hyper Mode, set a timer to
  -- automatically exit Hyper Mode after a short while.
  local TIMEOUT_IN_SECONDS = 5
  hs.timer.doAfter(TIMEOUT_IN_SECONDS, function()
    hyperMode:exit()
  end)
end

-- Leave Hyper Mode when F17 (right option key) is released.
releasedF17 = function()
  hyperMode:exit()
end

-- Bind the Hyper key
f17 = hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)
