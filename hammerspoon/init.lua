local log = hs.logger.new('init.lua', 'debug')

keyUpDown = function(modifiers, key)
  log.d('Sending keystroke:', hs.inspect(modifiers), key)
  hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
  hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
end

require('control-escape')
require('delete-words')
require('hyper')
require('markdown')
require('panes')
require('super')
require('windows')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
end)

hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤘'}):send()
