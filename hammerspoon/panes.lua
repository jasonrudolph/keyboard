local wf = hs.window.filter

-- Use control + dash to split panes horizontally in iTerm2
local splitHorizontalHotkey = hs.hotkey.new({'ctrl'}, '-', function()
  keyUpDown({'cmd', 'shift'}, 'd')
end)

-- Use control + pipe to split panes vertically in iTerm2
local splitVerticalHotkey = hs.hotkey.new({'ctrl', 'shift'}, '\\', function()
  keyUpDown({'cmd'}, 'd')
end)

-- Use control + h/j/k/l to move left/down/up/right by one pane in iTerm2
local paneDownHotkey = hs.hotkey.new({'ctrl'}, 'j', function()
  keyUpDown({'cmd', 'alt'}, 'down')
end)
local paneUpHotkey = hs.hotkey.new({'ctrl'}, 'k', function()
  keyUpDown({'cmd', 'alt'}, 'up')
end)
local paneLeftHotkey = hs.hotkey.new({'ctrl'}, 'h', function()
  keyUpDown({'cmd', 'alt'}, 'left')
end)
local paneRightHotkey = hs.hotkey.new({'ctrl'}, 'l', function()
  keyUpDown({'cmd', 'alt'}, 'right')
end)

local terminalWindowFilter = wf.new('iTerm2')

terminalWindowFilter:subscribe(wf.windowFocused, function()
  splitHorizontalHotkey:enable()
  splitVerticalHotkey:enable()
  paneUpHotkey:enable()
  paneDownHotkey:enable()
  paneLeftHotkey:enable()
  paneRightHotkey:enable()
end)

terminalWindowFilter:subscribe(wf.windowUnfocused, function()
  splitHorizontalHotkey:disable()
  splitVerticalHotkey:disable()
  paneUpHotkey:disable()
  paneDownHotkey:disable()
  paneLeftHotkey:disable()
  paneRightHotkey:disable()
end)
