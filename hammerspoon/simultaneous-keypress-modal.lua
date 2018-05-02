local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types
local message = require('keyboard.status-message')

local modal={}

modal.new = function(name, key1, key2)
  local instance = {
    -- The two keys that must be pressed simultaneously to enter the modal state
    key1 = key1,
    key2 = key2,

    -- If key1 and key2 are *both* pressed within this time period, consider
    -- this to mean that they've been pressed simultaneously, and therefore we
    -- should enter the modal state.
    maxTimeBetweenSimultaneousKeypresses = 0.04, -- 40 milliseconds

    -- The status message to display when the modal state is active
    statusMessage = message.new(name),

    -- Resets object to initial state
    reset = function(self)
      self.active = false
      self.isKey1Down = false
      self.isKey2Down = false
      self.ignoreNextKey1 = false
      self.ignoreNextKey2 = false
      self.statusMessage:hide()

      return self
    end,

    -- Are we in the modal state?
    isActive = function(self)
      return self.active
    end,

    -- Enters the modal state
    --
    -- Mimics hs.hotkey.modal:enter()
    enter = function(self)
      if self.active then return end

      self.statusMessage:show()
      self.active = true
      self:entered()
    end,

    -- Exits the modal state
    --
    -- Mimics hs.hotkey.modal:exit()
    exit = function(self)
      if not self.active then return end

      self:reset()
      self:exited()
    end,

    -- Optional callback for when a modal state is entered
    --
    -- Mimics hs.hotkey.modal:entered()
    entered = function(self) end,

    -- Optional callback for when a modal state is exited
    --
    -- Mimics hs.hotkey.modal:exited()
    exited = function(self) end,

    -- Enable the simultaneous keypress hotkey
    --
    -- Mimics hs.hotkey:enable()
    enable = function(self)
      self.activationListener:start()
      self.deactivationListener:start()
    end,

    -- Diable the simultaneous keypress hotkey
    --
    -- Mimics hs.hotkey:disable()
    disable = function(self)
      self:exit()
      self.activationListener:stop()
      self.deactivationListener:stop()
    end,
  }

  instance.activationListener = eventtap.new({ eventTypes.keyDown }, function(event)
    -- If key1 or key2 is pressed in conjuction with any modifier keys
    -- (e.g., command + key1), then we're not activating the modal state.
    if not (next(event:getFlags()) == nil) then
      return false
    end

    local characters = event:getCharacters()

    if characters == instance.key1 then
      if instance.ignoreNextKey1 then
        instance.ignoreNextKey1 = false
        return false
      end
      -- Temporarily suppress this key1 keystroke. At this point, we're not sure
      -- if the user intends to type key1, or if the user is attempting to
      -- activate the modal state. If key2 is pressed by the time the following
      -- function executes, then activate the modal state. Otherwise, trigger an
      -- ordinary key1 keystroke.
      instance.isKey1Down = true
      hs.timer.doAfter(instance.maxTimeBetweenSimultaneousKeypresses, function()
        if instance.isKey2Down then
          instance:enter()
        else
          instance.ignoreNextKey1 = true
          keyUpDown({}, instance.key1)
          return false
        end
      end)
      return true
    elseif characters == instance.key2 then
      if instance.ignoreNextKey2 then
        instance.ignoreNextKey2 = false
        return false
      end
      -- Temporarily suppress this key2 keystroke. At this point, we're not sure
      -- if the user intends to type key2, or if the user is attempting to
      -- activate the modal state. If key1 is pressed by the time the following
      -- function executes, then activate the modal state. Otherwise, trigger an
      -- ordinary key2 keystroke.
      instance.isKey2Down = true
      hs.timer.doAfter(instance.maxTimeBetweenSimultaneousKeypresses, function()
        if instance.isKey1Down then
          instance:enter()
        else
          instance.ignoreNextKey2 = true
          keyUpDown({}, instance.key2)
          return false
        end
      end)
      return true
    end
  end)

  instance.deactivationListener = eventtap.new({ eventTypes.keyUp }, function(event)
    local characters = event:getCharacters()
    if characters == instance.key1 or characters == instance.key2 then
      instance:reset()
    end
  end)

  return instance:reset()
end

return modal
