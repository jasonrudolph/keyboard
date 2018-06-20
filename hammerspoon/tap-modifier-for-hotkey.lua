local eventtap = require('hs.eventtap')
local events = eventtap.event.types

local modal={}

-- Return an object whose behavior is inspired by hs.hotkey.modal. In this case,
-- the modal state is entered when the specified modifier key is tapped (i.e.,
-- pressed and then released in quick succession).
modal.new = function(modifier)
  local instance = {
    modifier = modifier,

    modalStateTimeoutInSeconds = 1.0,

    modalKeybindings = {},

    inModalState = false,

    reset = function(self)
      -- Keep track of the last flags from the three most recent flagsChanged
      -- events.
      self.flagsHistory = { {}, {}, {} }
      self.flagsHistory.push = function(self, flags)
        self[1] = self[2]
        self[2] = self[3]
        self[3] = flags
      end

      return self
    end,

    -- Enable the modal
    --
    -- Mimics hs.modal:enable()
    enable = function(self)
      self.watcher:start()
    end,

    -- Disable the modal
    --
    -- Mimics hs.modal:disable()
    disable = function(self)
      self.watcher:stop()
      self.watcher:reset()
    end,

    -- Temporarily enter the modal state in which the modal's hotkeys are
    -- active. The modal state will terminate after `modalStateTimeoutInSeconds`
    -- or after the first keydown event, whichever comes first.
    --
    -- Mimics hs.modal.modal:enter()
    enter = function(self)
      self.inModalState = true
      self:entered()
      self.autoExitTimer:setNextTrigger(self.modalStateTimeoutInSeconds)
    end,

    -- Exit the modal state in which the modal's hotkey are active
    --
    -- Mimics hs.modal.modal:exit()
    exit = function(self)
      if not self.inModalState then return end

      self.autoExitTimer:stop()
      self.inModalState = false
      self:reset()
      self:exited()
    end,

    -- Optional callback for when modal state is entered
    --
    -- Mimics hs.modal.modal:entered()
    entered = function(self) end,

    -- Optional callback for when modal state is exited
    --
    -- Mimics hs.modal.modal:exited()
    exited = function(self) end,

    -- Bind hotkey that will be enabled/disabled as modal state is
    -- entered/exited
    bind = function(self, key, fn)
      self.modalKeybindings[key] = fn
    end,
  }

  isNoModifiers = function(flags)
    local isFalsey = function(value)
      return not value
    end

    return hs.fnutils.every(flags, isFalsey)
  end

  isOnlyModifier = function(flags)
    isPrimaryModiferDown = flags[modifier]
    areOtherModifiersDown = hs.fnutils.some(flags, function(isDown, modifierName)
      local isPrimaryModifier = modifierName == modifier
      return isDown and not isPrimaryModifier
    end)

    return isPrimaryModiferDown and not areOtherModifiersDown
  end

  onModifierChange = function(event)
    instance.flagsHistory:push(event:getFlags())

    local flags3 = instance.flagsHistory[3] -- the current flags
    local flags2 = instance.flagsHistory[2] -- the previous flags
    local flags1 = instance.flagsHistory[1] -- the flags before the previous flags

    -- If we've transitioned from 1) no modifiers being pressed to 2) just the
    -- modifier that we care about being pressed, to 3) no modifiers being
    -- pressed, then enter the modal state.
    if isNoModifiers(flags1) and isOnlyModifier(flags2) and isNoModifiers(flags3) then
      instance:enter()
    end

    -- Allow the event to propagate
    return false
  end

  onKeyDown = function(event)
    if instance.inModalState then
      local fn = instance.modalKeybindings[event:getCharacters():lower()]

      -- Some actions may take a while to perform (e.g., opening Slack when it's
      -- not yet running). We don't want to keep the modal state active while we
      -- wait for a long-running action to complete. So, we schedule the action
      -- to run in the background so that we can exit the modal state and let
      -- the user go on about their business.
      local delayInSeconds = 0.001 -- 1 millisecond
      hs.timer.doAfter(delayInSeconds, function()
        if fn then fn() end
      end)

      instance:exit()

      -- Delete the event so that we're the sole consumer of it
      return true
    else
      -- Since we're not in the modal state, this event isn't part of a sequence
      -- of events that represents the modifier being tapped, so start over.
      instance:reset()

      -- Allow the event to propagate
      return false
    end
  end

  instance.autoExitTimer = hs.timer.new(0, function() instance:exit() end)

  instance.watcher = eventtap.new({events.flagsChanged, events.keyDown},
    function(event)
      if event:getType() == events.flagsChanged then
        return onModifierChange(event)
      else
        return onKeyDown(event)
      end
    end
  )

  return instance:reset()
end

return modal
