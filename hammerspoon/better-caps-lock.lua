local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types

local log = hs.logger.new('betterCapsLockMode', 'debug')

-- TODO Can I get rid of this modal stuff altogether?

-- A global variable for BetterCapsLock Mode
betterCapsLockMode = hs.hotkey.modal.new({}, 'f20')

--------------------------------------------------------------------------------
-- Bind BetterCapsLock Mode to F19 (caps lock)
--
-- Note: Via Karabiner-Elements, we change the caps lock key to be the F19 key.
--------------------------------------------------------------------------------

-- Enter BetterCapsLock Mode when F19 (caps lock) is pressed.
pressedF19 = function()
  betterCapsLockMode.triggered = false
  betterCapsLockMode:enter()
end

-- Leave BetterCapsLock Mode when F19 (caps lock) is released.
--   Send ESCAPE if no other keys are pressed.
releasedF19 = function()
  betterCapsLockMode:exit()
  if not betterCapsLockMode.triggered then
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

-- Bind the BetterCapsLock key
f19 = hs.hotkey.bind({}, 'f19', pressedF19, releasedF19)

--------------------------------------------------------------------------------
-- Watch for F19 key down/up events to track whether we're in BetterCapsLock
-- Mode
--------------------------------------------------------------------------------
betterCapsLockMode.active = false
f19Listener = eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
  local keyCode = event:getKeyCode()

  if keyCode == hs.keycodes.map['f19'] then
    betterCapsLockMode.active = (event:getType() == eventTypes.keyDown)
  end
end):start()

--------------------------------------------------------------------------------
-- Watch for caps lock used in combination with another "normal" key, and
-- translate it to control plus that other normal key. For example, translate
-- "caps lock + e" to "control + e" to go to the end of the line.
--------------------------------------------------------------------------------
betterCapsLockModeFIXMEKeyListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not betterCapsLockMode.active then
    return false
  end

  -- TODO We probably need to do this for *every* key that isn't explicitly used
  -- for another purpose in BetterCapsLock Mode. For example, we don't want to
  -- do this for 'w', because we use 'w' to enter WindowLayout Mode. However,
  -- for any key that isn't used for another purpose in BetterCapsLock Mode,
  -- that key ought to "Just Work" as if the user had pressed control plus that
  -- other key.
  local charactersToKeystrokes = {
    a = 'a',
    c = 'c',
    d = 'd',
    e = 'e',
    f = 'f',
    g = 'g',
    h = 'h',
    j = 'j',
    k = 'k',
    l = 'l',
    r = 'r',
    u = 'u',
  }
  charactersToKeystrokes[' '] = 'space'

  local keystroke = charactersToKeystrokes[event:getCharacters()]
  if keystroke then
    log.d('Sending keystroke: {ctrl}', keystroke)
    eventtap.event.newKeyEvent({'ctrl'}, keystroke, true):post()
    eventtap.event.newKeyEvent({'ctrl'}, keystroke, false):post()
    betterCapsLockMode.triggered = true
    return true
  end
end):start()

-- Use BetterCapsLock+` to reload Hammerspoon config
betterCapsLockMode:bind({}, '`', nil, function()
  hs.reload()
end)

--------------------------------------------------------------------------------
-- Define WindowLayout Mode
--
-- WindowLayout Mode allows you to manage window layout using keyboard shortcuts
-- that are on the home row, or very close to it. Use BetterCapsLock+w to turn
-- on WindowLayout mode. Then, use any shortcut below to perform a window layout
-- action. For example, to send the window left, press and release
-- BetterCapsLock+w, and then press h.
--
--   h => send window to the left half of the screen
--   j => send window to the bottom half of the screen
--   k => send window to the top half of the screen
--   l => send window to the right half of the screen
--   return => make window full screen
--------------------------------------------------------------------------------

require('windows')

windowLayoutMode = hs.hotkey.modal.new({}, 'F16')

-- Bind the given key to call the given function and exit WindowLayout mode
function windowLayoutMode.bindWithAutomaticExit(mode, key, fn)
  mode:bind({}, key, function()
    mode:exit()
    fn()
  end)
end

windowLayoutMode:bindWithAutomaticExit('return', function()
  hs.window.focusedWindow():maximize()
end)

windowLayoutMode:bindWithAutomaticExit('h', function()
  hs.window.focusedWindow():left()
end)

windowLayoutMode:bindWithAutomaticExit('j', function()
  hs.window.focusedWindow():down()
end)

windowLayoutMode:bindWithAutomaticExit('k', function()
  hs.window.focusedWindow():up()
end)

windowLayoutMode:bindWithAutomaticExit('l', function()
  hs.window.focusedWindow():right()
end)

pressedW = function()
  betterCapsLockMode.triggered = true
  windowLayoutMode:enter()
end

releasedW = function() end
betterCapsLockMode:bind({}, 'w', nil, pressedW, releasedW)
