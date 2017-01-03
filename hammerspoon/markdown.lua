function wrapSelectedText(wrapCharacters)
  -- Preserve the current contents of the system clipboard
  local originalClipboardContents = hs.pasteboard.getContents()

  -- Copy the currently-selected text to the system clipboard
  keyUpDown('cmd', 'c')

  -- Allow some time for the command+c keystroke to fire asynchronously before
  -- we try to read from the clipboard
  hs.timer.doAfter(0.1, function()
    -- Construct the formatted output and paste it over top of the
    -- currently-selected text
    local selectedText = hs.pasteboard.getContents()
    local wrappedText = wrapCharacters .. selectedText .. wrapCharacters
    hs.pasteboard.setContents(wrappedText)
    keyUpDown('cmd', 'v')

    -- Allow some time for the command+v keystroke to fire asynchronously before
    -- we restore the original clipboard
    hs.timer.doAfter(0.1, function()
      hs.pasteboard.setContents(originalClipboardContents)
    end)
  end)
end

--------------------------------------------------------------------------------
-- Define Markdown Mode
--
-- Markdown Mode allows you to perform common Markdown-formatting tasks anywhere
-- that you're editing text. Use Control+m to turn on Markdown mode. Then, use
-- any shortcut below to perform a formatting action. For example, to wrap the
-- selected text in double asterisks, hit Control+m, and then b.
--
--   b => wrap the selected text in double asterisks ("b" for "bold")
--   i => wrap the selected text in single asterisks ("i" for "italic")
--   s => wrap the selected text in double tildes ("s" for "strikethrough")
--------------------------------------------------------------------------------

markdownMode = hs.hotkey.modal.new({}, 'F20')

-- Bind the given key to call the given function and exit Markdown mode
function markdownMode.bindWithAutomaticExit(mode, key, fn)
  mode:bind({}, key, function()
    mode:exit()
    fn()
  end)
end

markdownMode:bindWithAutomaticExit('b', function()
  wrapSelectedText('**')
end)

markdownMode:bindWithAutomaticExit('i', function()
  wrapSelectedText('*')
end)

markdownMode:bindWithAutomaticExit('s', function()
  wrapSelectedText('~~')
end)

-- Use Control+m to enter Markdown Mode
hs.hotkey.bind({'ctrl'}, 'm', function()
  markdownMode:enter()
end)
