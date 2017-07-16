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
  hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end
