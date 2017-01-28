local log = hs.logger.new('delete-words.lua', 'debug')

local isInTerminal = function()
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
  keyUpDown({'cmd'}, 'delete')
end))

-- Use control + ; to delete to end of line
--
-- I prefer to use control+h/j/k/l to move left/down/up/right by one pane in all
-- multi-pane apps (e.g., iTerm, various editors). That's convenient and
-- consistent, but it conflicts with the default macOS binding for deleting to
-- the end of the line (i.e., control+k). To maintain that very useful
-- functionality, and to keep it on the home row, this hotkey binds control+; to
-- delete to the end of the line.
hs.hotkey.bind({'ctrl'}, ';', function()
  -- If we're in the terminal, then temporarily disable our custom control+k
  -- hotkey used for pane navigation, then fire control+k to delete to the end
  -- of the line, and then renable the control+k hotkey.
  --
  -- If we're not in the terminal, then just select to the end of the line and
  -- then delete the selected text.
  if isInTerminal() then
    hotkeyForControlK = hs.fnutils.find(hs.hotkey.getHotkeys(), function(hotkey)
      return hotkey.idx == '⌃K'
    end)
    if hotkeyForControlK then hotkeyForControlK:disable() end

    keyUpDown({'ctrl'}, 'k')

    -- Allow some time for the control+k keystroke to fire asynchronously before
    -- we re-enable our custom control+k hotkey.
    hs.timer.doAfter(0.2, function()
      if hotkeyForControlK then hotkeyForControlK:enable() end
    end)
  else
    keyUpDown({'cmd', 'shift'}, 'right')
    keyUpDown({}, 'forwarddelete')
  end
end)
