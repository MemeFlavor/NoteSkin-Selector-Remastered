luaDebugMode = true

local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local table     = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.table'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local hoverObject   = funkinlua.hoverObject
local clickObject   = funkinlua.clickObject
local pressedObject = funkinlua.pressedObject
local releaseObject = funkinlua.releasedObject

--- Main button component class for FlavorUI.
---@class FlavorUI_Button
local FlavorUI_Button = {}

---
---@param tag
---@param state
---@return FlavorUI_Button
function FlavorUI_Button:new(tag, state)
     local self = setmetatable({}, {__index = self})
     self.tag   = tag
     self.state = state or 'static'

     self.ddeedede = false
     return self
end

local a = true
local b = true

function FlavorUI_Button:update()
     local hoverMouse = hoverObject(self.tag, 'camHUD')
     local clickMouse = clickObject(self.tag, 'camHUD')
     local pressMouse = pressedObject(self.tag, 'camHUD')
     local releaseMouse = releaseObject(self.tag, 'camHUD')


     if self.state == 'disabled' then
          playAnim(self.tag, 'disabled')
          return
     end

     if hoverMouse and a == true then
          playAnim(self.tag, 'hovered')
          a = false
          return
     end
     if not hoverMouse and a == false then
          playAnim(self.tag, 'static')
          a = true
          return
     end
     if (clickMouse or pressMouse) and b == true then
          playAnim(self.tag, 'pressed')
          b = false
          return
     end
     if (releaseMouse) and b == false then
          playAnim(self.tag, 'hovered')
          b = true
          return
     end
end

function FlavorUI_Button:set_state(value)
     self.state = value
     self:update()

     a = not a
     b = true
     self:update()
end

function FlavorUI_Button:get_state()
end

return FlavorUI_Button