local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
end)

keyUpDown = function(modifiers, key)
  -- Un-comment & reload config to log each keystroke that we're triggering
  -- log.d('Sending keystroke:', hs.inspect(modifiers), key)

  hs.eventtap.keyStroke(modifiers, key, 0)
end

-- Subscribe to the necessary events on the given window filter such that the
-- given hotkey is enabled for windows that match the window filter and disabled
-- for windows that don't match the window filter.
--
-- windowFilter - An hs.window.filter object describing the windows for which
--                the hotkey should be enabled.
-- hotkey       - The hs.hotkey object to enable/disable.
--
-- Returns nothing.
-- Keep global references so Lua GC does not collect filtered hotkeys or watchers
_G._filteredHotkeys = {}

enableHotkeyForWindowsMatchingFilter = function(windowFilter, hotkey)
  table.insert(_G._filteredHotkeys, {filter = windowFilter, hotkey = hotkey})

  local fw = hs.window.focusedWindow()
  if fw and windowFilter:isWindowAllowed(fw) then
    hotkey:enable()
  else
    hotkey:disable()
  end
end

local updateFilteredHotkeys = function()
  local fw = hs.window.focusedWindow()
  for _, entry in ipairs(_G._filteredHotkeys) do
    if fw and entry.filter:isWindowAllowed(fw) then
      entry.hotkey:enable()
    else
      entry.hotkey:disable()
    end
  end
end

if _G._appWatcher then _G._appWatcher:stop() end
_G._appWatcher = hs.application.watcher.new(function(appName, eventType)
  if eventType == hs.application.watcher.activated or eventType == hs.application.watcher.deactivated then
    hs.timer.doAfter(0.05, updateFilteredHotkeys)
  end
end)
_G._appWatcher:start()

require('keyboard.control-escape')
require('keyboard.delete-words')
require('keyboard.hyper')
require('keyboard.markdown')
require('keyboard.panes')
require('keyboard.windows')

hs.notify.new({title='Hammerspoon', informativeText='Ready to rock 🤘'}):send()
