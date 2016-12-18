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
