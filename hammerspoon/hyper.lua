-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({}, 'F18')

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
  hyperModeDeactivationListener:start()
end

-- Leave Hyper Mode when F17 (right option key) is released.
hyperModeDeactivationListener = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(event)
  if event:getKeyCode() == hs.keycodes.map['F17'] then
    hyperMode:exit()
    hyperModeDeactivationListener:stop()
  end
end)

-- Bind the Hyper key
f17 = hs.hotkey.bind({}, 'F17', pressedF17)
