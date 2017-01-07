local wf = hs.window.filter

local itermHotkeyMappings = {
  -- Use control + dash to split panes horizontally
  {
    from = {{'ctrl'}, '-'},
    to   = {{'cmd', 'shift'}, 'd'}
  },

  -- Use control + pipe to split panes vertically
  {
    from = {{'ctrl', 'shift'}, '\\'},
    to   = {{'cmd'}, 'd'}
  },

  -- Use control + h/j/k/l to move left/down/up/right by one pane in iTerm2
  {
    from = {{'ctrl'}, 'h'},
    to   = {{'cmd', 'alt'}, 'left'}
  },
  {
    from = {{'ctrl'}, 'j'},
    to   = {{'cmd', 'alt'}, 'down'}
  },
  {
    from = {{'ctrl'}, 'k'},
    to   = {{'cmd', 'alt'}, 'up'}
  },
  {
    from = {{'ctrl'}, 'l'},
    to   = {{'cmd', 'alt'}, 'right'}
  },
}

local itermHotkeys = hs.fnutils.imap(itermHotkeyMappings, function(mapping)
  local fromMods = mapping['from'][1]
  local fromKey = mapping['from'][2]
  local toMods = mapping['to'][1]
  local toKey = mapping['to'][2]
  return hs.hotkey.new(fromMods, fromKey, function()
    keyUpDown(toMods, toKey)
  end)
end)

local terminalWindowFilter = wf.new('iTerm2')

terminalWindowFilter:subscribe(wf.windowFocused, function()
  hs.fnutils.each(itermHotkeys, function(hotkey)
    hotkey:enable()
  end)
end)

terminalWindowFilter:subscribe(wf.windowUnfocused, function()
  hs.fnutils.each(itermHotkeys, function(hotkey)
    hotkey:disable()
  end)
end)
