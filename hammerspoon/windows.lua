hs.window.animationDuration = 0

-- +-----------------+
-- |        |        |
-- |  HERE  |        |
-- |        |        |
-- +-----------------+
function hs.window.left(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |        |        |
-- |        |  HERE  |
-- |        |        |
-- +-----------------+
function hs.window.right(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |      HERE       |
-- +-----------------+
-- |                 |
-- +-----------------+
function hs.window.up(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.w = max.w
  f.y = max.y
  f.h = max.h / 2
  win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +-----------------+
-- |      HERE       |
-- +-----------------+
function hs.window.down(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.w = max.w
  f.y = max.y + (max.h / 2)
  f.h = max.h / 2
  win:setFrame(f)
end

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'left', function()
  local win = hs.window.focusedWindow()
  win:left()
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'right', function()
  local win = hs.window.focusedWindow()
  win:right()
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'up', function()
  local win = hs.window.focusedWindow()
  win:up()
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'down', function()
  local win = hs.window.focusedWindow()
  win:down()
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'return', function()
  hs.window.focusedWindow():maximize()
end)
