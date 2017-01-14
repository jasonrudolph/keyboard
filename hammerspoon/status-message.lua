local drawing = require 'hs.drawing'
local geometry = require 'hs.geometry'
local screen = require 'hs.screen'
local styledtext = require 'hs.styledtext'

local statusmessage = {}
statusmessage.new = function(messageText)
  local frame = screen.primaryScreen():frame()

  local styledTextAttributes = {
    font = { name = 'Monaco', size = 24 },
  }

  local styledText = styledtext.new('🔨 ' .. messageText, styledTextAttributes)

  local styledTextSize = drawing.getTextDrawingSize(styledText)
  local textRect = {
    x = frame.w - styledTextSize.w - 40,
    y = frame.h - styledTextSize.h,
    w = styledTextSize.w + 40,
    h = styledTextSize.h + 40,
  }
  local text = drawing.text(textRect, styledText):setAlpha(0.7)

  local background = drawing.rectangle(
    {
      x = frame.w - styledTextSize.w - 45,
      y = frame.h - styledTextSize.h - 3,
      w = styledTextSize.w + 15,
      h = styledTextSize.h + 6
    }
  )
  background:setRoundedRectRadii(10, 10)
  background:setFillColor({ red = 0, green = 0, blue = 0, alpha=0.6 })

  return {
    background = background,
    text = text,
    show = function(self)
      self.background:show()
      self.text:show()
    end,
    hide = function(self)
      self.background:hide()
      self.text:hide()
    end
  }
end

return statusmessage
