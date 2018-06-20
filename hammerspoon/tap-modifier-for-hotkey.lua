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
      -- Keep track of the three most recent events.
      self.eventHistory = {
        -- Serialize the event and push it into the history
        push = function(self, event)
          self[3] = self[2]
          self[2] = self[1]
          self[1] = event:asData()
        end,

        -- Fetch the event (if any) at the given index
        fetch = function(self, index)
          if self[index] then
            return eventtap.event.newEventFromData(self[index])
          end
        end
      }

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

  isFlagsChangedEvent = function(event)
    return event and event:getType() == events.flagsChanged
  end

  isFlagsChangedEventWithNoModifiers = function(event)
    return isFlagsChangedEvent(event) and isNoModifiers(event:getFlags())
  end

  isFlagsChangedEventWithOnlyModifier = function(event)
    return isFlagsChangedEvent(event) and isOnlyModifier(event:getFlags())
  end

  instance.autoExitTimer = hs.timer.new(0, function() instance:exit() end)

  instance.watcher = eventtap.new({events.flagsChanged, events.keyDown},
    function(event)
      -- If we're in the modal state, and we got a keydown event, then trigger
      -- the function associated with the key.
      if (event:getType() == events.keyDown and instance.inModalState) then
        local fn = instance.modalKeybindings[event:getCharacters():lower()]

        -- Some actions may take a while to perform (e.g., opening Slack when
        -- it's not yet running). We don't want to keep the modal state active
        -- while we wait for a long-running action to complete. So, we schedule
        -- the action to run in the background so that we can exit the modal
        -- state and let the user go on about their business.
        local delayInSeconds = 0.001 -- 1 millisecond
        hs.timer.doAfter(delayInSeconds, function()
          if fn then fn() end
        end)

        instance:exit()

        -- Delete the event so that we're the sole consumer of it
        return true
      end

      -- Otherwise, determine if this event should cause us to enter the modal
      -- state.

      local currentEvent = event
      local lastEvent = instance.eventHistory:fetch(1)
      local secondToLastEvent = instance.eventHistory:fetch(2)

      instance.eventHistory:push(currentEvent)

      -- If we've observed the following sequence of events, then enter the
      -- modal state:
      --
      -- 1. No modifiers are down
      -- 2. Modifiers changed, and now only the primary modifier is down
      -- 3. Modifiers changed, and now no modifiers are down
      if (secondToLastEvent == nil or isNoModifiers(secondToLastEvent:getFlags())) and
        isFlagsChangedEventWithOnlyModifier(lastEvent) and
        isFlagsChangedEventWithNoModifiers(currentEvent) then

        instance:enter()
      end

      -- Let the event propagate
      return false
    end
  )

  return instance:reset()
end

return modal
