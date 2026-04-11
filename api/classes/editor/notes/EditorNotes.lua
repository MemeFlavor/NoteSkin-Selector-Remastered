local F         = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'
local math      = require 'mods.NoteSkin Selector Remastered.api.libraries.standard.math'
local funkinlua = require 'mods.NoteSkin Selector Remastered.api.modules.funkinlua'

local json = require 'mods.NoteSkin Selector Remastered.api.libraries.json.main'

local kbCondJustPressed = funkinlua.kbCondJustPressed
local kbCondPressed     = funkinlua.kbCondPressed

---@enum BORDERS
local BORDERS = {
     LEFT  = 207,
     RIGHT = -545,
     UP    = 177,
     DOWN  = -440
}

---@enum OFFSETS
local OFFSETS = {
     X = 1,
     Y = 2
}

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_ANIMATIONS = {'pressed', 'confirm', 'colored', 'strums'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

---@class EditorNotes
local EditorNotes = {}

function EditorNotes:new(tag, sprite)
     local self = setmetatable({}, {__index = self})
     self.tag    = tag
     self.sprite = sprite

     self._dir  = 1
     self._dirX = 0
     self._dirY = 0
     self._dirA = 1 -- amplifier

     self._dir_offsets_data = {
          CONFIRM = {{0,0}, {0,0}, {0,0}, {0,0}},
          PRESSED = {{0,0}, {0,0}, {0,0}, {0,0}},
          COLORED = {{0,0}, {0,0}, {0,0}, {0,0}},
          STRUMS  = {{0,0}, {0,0}, {0,0}, {0,0}}
     }
     return self
end

function EditorNotes:create()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 600 + (130*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, self.sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)
          playAnim(editorTag, editorDirection)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)

          for skinAnimationIndex = 1, #SKIN_ANIMATIONS do
               local skinAnimations = SKIN_ANIMATIONS[skinAnimationIndex]:upper()
               self._offsets[skinAnimations][editorIndex][OFFSETS.X] = getProperty(F"${editorTag}.offset.x")
               self._offsets[skinAnimations][editorIndex][OFFSETS.Y] = getProperty(F"${editorTag}.offset.y")
          end
     end
end

function EditorNotes:update_movement()
     local dirTag    = self:_get_tag()
     local dirLength = math.sqrt(self._dirX^2 + self._dirY^2)

     if kbCondPressed('D', self:_get_focused()) or kbCondPressed('RIGHT', self:_get_focused()) then
          self._dirX = self._dirX + 1
     end
     if kbCondPressed('A', self:_get_focused()) or kbCondPressed('LEFT', self:_get_focused()) then
          self._dirX = self._dirX - 1
     end
     if kbCondPressed('S', self:_get_focused()) or kbCondPressed('DOWN', self:_get_focused()) then
          self._dirY = self._dirY + 1
     end
     if kbCondPressed('W', self:_get_focused()) or kbCondPressed('UP', self:_get_focused()) then
          self._dirY = self._dirY - 1
     end

     --[[ if getProperty(F"${dirTag}.offset.x") < BORDERS.RIGHT then
          self:_set_offset_data('X', BORDERS.RIGHT)
          setProperty(F"${dirTag}.offset.x", self:_get_offset_data('X'))
     end
     if getProperty(F"${dirTag}.offset.x") > BORDERS.LEFT  then
          self:_set_offset_data('X', BORDERS.LEFT)
          setProperty(F"${dirTag}.offset.x", self:_get_offset_data('X'))
     end
     if getProperty(F"${dirTag}.offset.y") < BORDERS.DOWN  then
          self:_set_offset_data('Y', BORDERS.DOWN)
          setProperty(F"${dirTag}.offset.y", self:_get_offset_data('Y'))
     end
     if getProperty(F"${dirTag}.offset.y") > BORDERS.UP    then
          self:_set_offset_data('Y', BORDERS.UP)
          setProperty(F"${dirTag}.offset.y", self:_get_offset_data('Y'))
     end ]]
     if dirLength > 0 then
          self._dirX, self._dirY = self._dirX / dirLength, self._dirY / dirLength

          local function directionMovement(mainKey, altKey)
               local mainKeyPressed = kbCondPressed(mainKey, self:_get_focused())
               local altkeyPressed  = kbCondPressed(altKey, self:_get_focused())
               return mainKeyPressed or altkeyPressed and not (mainKeyPressed and altkeyPressed)
          end

          if directionMovement('D', 'A') then
               self:_set_offset_data('X', math.round(getProperty(F"${dirTag}.offset.x") - self._dirX*self._dirA, 2))
          end
          if directionMovement('S', 'W') then
               self:_set_offset_data('Y', math.round(getProperty(F"${dirTag}.offset.y") - self._dirY*self._dirA, 2))
          end

          local stepSize = kbCondPressed('SHIFT', self:_get_focused()) == true and 1000 or 100
          if directionMovement('RIGHT', 'LEFT') then
               self:_set_offset_data('X', math.round(getProperty(F"${dirTag}.offset.x") - self._dirX*self._dirA/stepSize, 3))               setProperty(F"${dirTag}.offset.x", self:_get_offset_data('X'))
          end
          if directionMovement('DOWN', 'UP') then
               self:_set_offset_data('Y', math.round(getProperty(F"${dirTag}.offset.y") - self._dirY*self._dirA/stepSize, 3))
          end
     end

     if kbCondJustPressed('LBRACKET', self:_get_focused()) and self._dir > 1 then
          self._dir = self._dir - 1
     end
     if kbCondJustPressed('RBRACKET', self:_get_focused()) and self._dir < 4 then
          self._dir = self._dir + 1
     end
     if self:_get_focused() then
          setProperty(F"${dirTag}.offset.x", self:_get_offset_data('X'))
          setProperty(F"${dirTag}.offset.y", self:_get_offset_data('Y'))          
     end

     debugPrint(self:_get_offset_data('X'))
end

function EditorNotes:update_animations()
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)
          local editorX = 600 + (130*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]

          if keyboardJustPressed('U') then
               playAnim(editorTag, F"${editorDirection} pressed")
          end
          if keyboardJustPressed('I') then
               playAnim(editorTag, F"${editorDirection} confirm")
          end
          if keyboardJustPressed('O') then
               playAnim(editorTag, F"${editorDirection} colored")
          end
          if keyboardJustPressed('P') then
               playAnim(editorTag, editorDirection)
          end
     end
end

function EditorNotes:texture(sprite)
     for editorIndex = 1, 4 do
          local editorTag = self.tag..tostring(editorIndex)

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          loadFrames(editorTag, sprite)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, true)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, true)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, true)
          playAnim(editorTag, editorDirection)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)
     end
end

function EditorNotes:_get_tag()
     return F"${self.tag}${self._dir}"
end

function EditorNotes:_get_focused()
     return getPropertyFromClass('backend.ui.PsychUIInputText', 'focusOn') == nil
end

function EditorNotes:get_offset_x()
     return getProperty(F"${self:_get_tag()}.offset.x")
end

function EditorNotes:get_offset_y()
     return getProperty(F"${self:_get_tag()}.offset.y")
end

function EditorNotes:set_offset_x(value)
     setProperty(F"${self:_get_tag()}.offset.x", value)
end

function EditorNotes:set_offset_y(value)
     setProperty(F"${self:_get_tag()}.offset.y", value)
end

function EditorNotes:_get_offset_data(types)
     return self._offsets[self._offsets_name][self._dir][OFFSETS[types]]
end

function EditorNotes:_set_offset_data(types, value)
     self._offsets[self._offsets_name][self._dir][OFFSETS[types]] = value
end

return EditorNotes