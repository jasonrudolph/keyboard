local log = hs.logger.new('delete-words.lua', 'debug')

isInTerminal = function()
  app = hs.application.frontmostApplication():name()
  return app == 'iTerm2' or app == 'Terminal'
end

-- Use option + h to delete previous word
hs.hotkey.bind({'alt'}, 'h', function()
  if isInTerminal() then
    keyUpDown({'ctrl'}, 'w')
  else
    keyUpDown({'alt'}, 'delete')
  end
end)

-- Use option + l to delete next word
hs.hotkey.bind({'alt'}, 'l', function()
  if isInTerminal() then
    keyUpDown({}, 'escape')
    keyUpDown({}, 'd')
  else
    keyUpDown({'alt'}, 'forwarddelete')
  end
end)

-- Use control + u to delete to beginning of line
--
-- In bash, control + u automatically deletes to the beginning of the line, so
-- we don't need (or want) this hotkey in the terminal. If this hotkey was
-- enabled in the terminal, it would break the standard control + u behavior.
-- Therefore, we only enable this hotkey for non-terminal apps.
local wf = hs.window.filter.new():setFilters({iTerm2 = false, Terminal = false})
enableHotkeyForWindowsMatchingFilter(wf, hs.hotkey.new({'ctrl'}, 'u', function()
  keyUpDown({'cmd', 'shift'}, 'left')
  keyUpDown({}, 'forwarddelete')
end))
