local eventtap = require('hs.eventtap')
local events = eventtap.event.types

local modal={}

-- Return an object whose behavior is inspired by hs.hotkey.modal. In this case,
-- the modal state is entered when the specified modifier key is tapped (i.e.,
-- pressed and then released in quick succession).
modal.new = function(modifier)
  local instance = {
    modifier = modifier,

    lastFlagsSeen = {},

    tapTimeoutInSeconds = 0.5,

    modalStateTimeoutInSeconds = 1.0,

    modalKeybindings = {},

    inModalState = false,

    reset = function(self)
      self.tapStarted = false

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

      hs.timer.doAfter(self.modalStateTimeoutInSeconds,
        function() self:exit() end
      )
    end,

    -- Exit the modal state in which the modal's hotkey are active
    --
    -- Mimics hs.modal.modal:exit()
    exit = function(self)
      if not self.inModalState then return end

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
    local oldFlags = instance.lastFlagsSeen
    local newFlags = event:getFlags()

    instance.lastFlagsSeen = newFlags

    -- If we've transitioned from no modifiers to just the modifier that we care
    -- about, then this could be the start of a tap, so start watching for the
    -- modifier to be released.
    if isNoModifiers(oldFlags) and isOnlyModifier(newFlags) then
      instance.tapStarted = true

      -- If the modifier isn't released before the timeout, then it doesn't seem
      -- like the user is intending to *tap* the modifier key. So, start over.
      hs.timer.doAfter(instance.tapTimeoutInSeconds, function()
        if not instance.inModalState then instance:reset() end
      end)

      return
    end

    -- If we saw the modifier we care about get pressed, and now no modifiers
    -- are down, then this is the key-up event for the modifier we care about.
    -- So, enter the modal state.
    if instance.tapStarted and isNoModifiers(newFlags) then
      instance:enter()

      return
    end

    -- If we get here, then this isn't the sequence of events we were looking
    -- for, so start over.
    instance:reset()

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
