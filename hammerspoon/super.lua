local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types

-- If 's' and 'd' are *both* pressed within this time period, consider this to
-- mean that they've been pressed simultaneously, and therefore we should enter
-- Super Duper Mode.
local MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES = 0.02 -- 20 milliseconds

local superDuperMode = {}
superDuperMode.active = false
superDuperMode.isSDown = false
superDuperMode.isDDown = false
superDuperMode.ignoreNextS = false
superDuperMode.ignoreNextD = false
superDuperMode.modifiers = {}

superDuperModeActivationListener = eventtap.new({ eventTypes.keyDown }, function(event)
  -- If 's' or 'd' is pressed in conjuction with any modifier keys
  -- (e.g., command+s), then we're not activating Super Duper Mode.
  if not (next(event:getFlags()) == nil) then
    return false
  end

  local characters = event:getCharacters()

  if characters == 's' then
    if superDuperMode.ignoreNextS then
      superDuperMode.ignoreNextS = false
      return false
    end
    -- Temporarily suppress this 's' keystroke. At this point, we're not sure if
    -- the user intends to type an 's', or if the user is attempting to activate
    -- Super Duper Mode. If 'd' is pressed by the time the following function
    -- executes, then activate Super Duper Mode. Otherwise, trigger an ordinary
    -- 's' keystroke.
    superDuperMode.isSDown = true
    hs.timer.doAfter(MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES, function()
      if superDuperMode.isDDown then
        superDuperMode.active = true
      else
        superDuperMode.ignoreNextS = true
        keyUpDown({}, 's')
        return false
      end
    end)
    return true
  elseif characters == 'd' then
    if superDuperMode.ignoreNextD then
      superDuperMode.ignoreNextD = false
      return false
    end
    -- Temporarily suppress this 'd' keystroke. At this point, we're not sure if
    -- the user intends to type a 'd', or if the user is attempting to activate
    -- Super Duper Mode. If 's' is pressed by the time the following function
    -- executes, then activate Super Duper Mode. Otherwise, trigger an ordinary
    -- 'd' keystroke.
    superDuperMode.isDDown = true
    hs.timer.doAfter(MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES, function()
      if superDuperMode.isSDown then
        superDuperMode.active = true
      else
        superDuperMode.ignoreNextD = true
        keyUpDown({}, 'd')
        return false
      end
    end)
    return true
  end
end):start()

superDuperModeDeactivationListener = eventtap.new({ eventTypes.keyUp }, function(event)
  local characters = event:getCharacters()
  if characters == 's' or characters == 'd' then
    -- TODO Refactor: Extract this into a 'reset' function (or similar)
    superDuperMode.active = false
    superDuperMode.isSDown = false
    superDuperMode.isDDown = false
    superDuperMode.ignoreNextS = false
    superDuperMode.ignoreNextD = false
  end
end):start()

--------------------------------------------------------------------------------
-- Watch for key down/up events that represent modifiers in Super Duper Mode
--------------------------------------------------------------------------------
superDuperModeModifierKeyListener = eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
  if not superDuperMode.active then
    return false
  end

  local charactersToModifers = {}
  charactersToModifers['a'] = 'alt'
  charactersToModifers['f'] = 'cmd'
  charactersToModifers[' '] = 'shift'

  local modifier = charactersToModifers[event:getCharacters()]
  if modifier then
    if (event:getType() == eventTypes.keyDown) then
      superDuperMode.modifiers[modifier] = true
    else
      superDuperMode.modifiers[modifier] = nil
    end
    return true
  end
end):start()

--------------------------------------------------------------------------------
-- Watch for h/j/k/l key down events in Super Duper Mode, and trigger the
-- corresponding arrow key events
--------------------------------------------------------------------------------
superDuperModeNavListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not superDuperMode.active then
    return false
  end

  local charactersToKeystrokes = {
    h = 'left',
    j = 'down',
    k = 'up',
    l = 'right',
  }

  local keystroke = charactersToKeystrokes[event:getCharacters()]
  if keystroke then
    local modifiers = {}
    n = 0
    for k, v in pairs(superDuperMode.modifiers) do
      n = n + 1
      modifiers[n] = k
    end

    keyUpDown(modifiers, keystroke)
    return true
  end
end):start()

--------------------------------------------------------------------------------
-- Watch for i/o key down events in Super Duper Mode, and trigger the
-- corresponding key events to navigate to the previous/next tab respectively
--------------------------------------------------------------------------------
superDuperModeTabNavKeyListener = eventtap.new({ eventTypes.keyDown }, function(event)
  if not superDuperMode.active then
    return false
  end

  local charactersToKeystrokes = {
    i = '[',
    o = ']',
  }
  local keystroke = charactersToKeystrokes[event:getCharacters()]

  if keystroke then
    keyUpDown({'cmd', 'shift'}, keystroke)
    superDuperMode.triggered = true
    return true
  end
end):start()
