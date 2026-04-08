local F = require 'mods.NoteSkin Selector Remastered.api.libraries.f-strings.F'

local SKIN_DIRECTIONS = {'left', 'down', 'up', 'right'}
local SKIN_COLORS     = {'purple0', 'blue0', 'green0', 'red0'}

local EditorNotes = {}

function EditorNotes:new(sprite)
     local self = setmetatable({}, {__index = self})
     self.sprite = sprite

     return self
end

function EditorNotes:create()
     for editorIndex = 1, 4 do
          local editorTag = F"editorNotes${editorIndex}"
          local editorX = 600 + (130*(editorIndex-1))
          local editorY = 150

          local editorDirection = SKIN_DIRECTIONS[editorIndex]
          local editorColors    = SKIN_COLORS[editorIndex]
          makeAnimatedLuaSprite(editorTag, self.sprite, editorX, editorY)
          scaleObject(editorTag, 0.65, 0.65)
          addAnimationByPrefix(editorTag, F"${editorDirection} pressed", F"${editorDirection} pressed", 24, false)
          addAnimationByPrefix(editorTag, F"${editorDirection} confirm", F"${editorDirection} confirm", 24, false)
          addAnimationByPrefix(editorTag, F"${editorDirection} colored", editorColors, 24, false)
          addAnimationByPrefix(editorTag, editorDirection, F"arrow${editorDirection:upper()}", 24, false)
          playAnim(editorTag, editorDirection, false)
          setObjectCamera(editorTag, 'camHUD')
          addLuaSprite(editorTag)
     end
end

function EditorNotes:update()
end

return EditorNotes