local wf = hs.window.filter

-- Use control + dash to split panes horizontally in iTerm2
local splitHorizontalHotkey = hs.hotkey.new({'ctrl'}, '-', function()
  keyUpDown({'cmd', 'shift'}, 'd')
end)

-- Use control + pipe to split panes vertically in the terminal
local splitVerticalHotkey = hs.hotkey.new({'ctrl', 'shift'}, '\\', function()
  keyUpDown({'cmd'}, 'd')
end)

local terminalWindowFilter = wf.new('iTerm2')

terminalWindowFilter:subscribe(wf.windowFocused, function()
  splitHorizontalHotkey:enable()
  splitVerticalHotkey:enable()
end)

terminalWindowFilter:subscribe(wf.windowUnfocused, function()
  splitHorizontalHotkey:disable()
  splitVerticalHotkey:disable()
end)
