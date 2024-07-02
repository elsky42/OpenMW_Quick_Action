--[[
  Animation controller interface
  local anim = require('openmw.animation')
  local I = require('openmw.interfaces')
  
  -- play spellcast animation 
  I.AnimationController.playBlendedAnimation('spellcast', { startkey = 'self start', stopkey = 'self stop', priority = {
       [anim.BONE_GROUP.RightArm] = anim.PRIORITY.Weapon,
       [anim.BONE_GROUP.LeftArm] = anim.PRIORITY.Weapon,
       [anim.BONE_GROUP.Torso] = anim.PRIORITY.Weapon,
       [anim.BONE_GROUP.LowerBody] = anim.PRIORITY.WeaponLowerBody
       } })
  
]]

local record AnimationController
  --[[
    Add new playBlendedAnimation handler for this actor
    If `handler(groupname, options)` returns false, other handlers for
    the call will be skipped.
  ]]
  addPlayBlendedAnimationHandler: function(
    handler: function
  )
  
  --[[
    Add new text key handler for this actor
    While playing, some animations emit text key events.
    Register a handle to listen for all
    text key events associated with this actor's animations.
    If `handler(groupname, key)` returns false, other handlers for
    the call will be skipped.
  ]]
  addTextKeyHandler: function(
    groupname: string, --[[Name of the animation group to listen to keys for. If the empty string or nil, all keys will be received]]
    handler: function
  )
  
  --[[
    Make this actor play an animation.
    Makes a call to @{openmw.animation#playBlended}, after invoking handlers added through addPlayBlendedAnimationHandler
  ]]
  playBlendedAnimation: function(
    groupname: string, --[[The animation group to be played]]
    options: table
  )
  
  --[[
    Interface version
  ]]
  version: number
  
  --[[
    AnimationController Package
  ]]
  record Package
  end
end
return AnimationController