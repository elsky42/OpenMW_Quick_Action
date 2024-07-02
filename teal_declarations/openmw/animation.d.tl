--[[
  `openmw.animation` defines functions that allow control of character animations
  Note that for some methods, such as @{openmw.animation#playBlended} you should use the associated methods on the 
  [AnimationController](interface_animation.html) interface rather than invoking this API directly.
  local anim = require('openmw.animation')
]]

local openmw_core = require("openmw.core")
--[[
  `animation.BLEND_MASK`
]]
global record BlendMask
  --[[
    "15" All bones
  ]]
  All: number
  
  --[[
    "4" All bones from 'Bip01 L Clavicle' and out
  ]]
  LeftArm: number
  
  --[[
    "1" All bones from 'Bip01 pelvis' and below
  ]]
  LowerBody: number
  
  --[[
    "8" All bones from 'Bip01 R Clavicle' and out
  ]]
  RightArm: number
  
  --[[
    "2" All bones from 'Bip01 Spine1' and up, excluding arms
  ]]
  Torso: number
  
  --[[
    "14" All bones from 'Bip01 Spine1' and up, including arms
  ]]
  UpperBody: number
  
end
--[[
  `animation.BONE_GROUP`
]]
global record BoneGroup
  --[[
    "3" All bones from 'Bip01 L Clavicle' and out
  ]]
  LeftArm: number
  
  --[[
    "1" All bones from 'Bip01 pelvis' and below
  ]]
  LowerBody: number
  
  --[[
    "4" All bones from 'Bip01 R Clavicle' and out
  ]]
  RightArm: number
  
  --[[
    "2" All bones from 'Bip01 Spine1' and up, excluding arms
  ]]
  Torso: number
  
end
--[[
  `animation.PRIORITY`
]]
global record Priority
  --[[
    "8"
  ]]
  Block: number
  
  --[[
    "12" 
  ]]
  Death: number
  
  --[[
    "0"
  ]]
  Default: number
  
  --[[
    "6"
  ]]
  Hit: number
  
  --[[
    "4"
  ]]
  Jump: number
  
  --[[
    "9"
  ]]
  Knockdown: number
  
  --[[
    "5"
  ]]
  Movement: number
  
  --[[
    "13" Special priority used by scripted animations. When any animation with this priority is present, all animations without this priority are paused.
  ]]
  Scripted: number
  
  --[[
    "2"
  ]]
  SneakIdleLowerBody: number
  
  --[[
    "11"
  ]]
  Storm: number
  
  --[[
    "3"
  ]]
  SwimIdle: number
  
  --[[
    "10"
  ]]
  Torch: number
  
  --[[
    "7"
  ]]
  Weapon: number
  
  --[[
    "1"
  ]]
  WeaponLowerBody: number
  
end
local record animation
  --[[
    Possible @{#BlendMask} values
  ]]
  BLEND_MASK: BlendMask
  
  --[[
    Possible @{#BoneGroup} values
  ]]
  BONE_GROUP: BoneGroup
  
  --[[
    Possible @{#Priority} values
  ]]
  PRIORITY: Priority
  
  --[[
    Plays a VFX on the actor.
    Can be used only in local scripts on self.
    local mgef = core.magic.effects.records[myEffectName]
    anim.addVfx(self, 'VFX_Hands', {bonename = 'Bip01 L Hand', particle = mgef.particle, loop = mgef.continuousVfx, vfxId = mgef.id..'_myuniquenamehere'})
    -- later:
    anim.removeVfx(self, mgef.id..'_myuniquenamehere')
    
  ]]
  addVfx: function(
    actor: openmw_core.GameObject,
    static: any, --[[@{openmw.core#StaticRecord} or #string ID]]
    options: table
  )
  
  --[[
    Cancels and removes the animation group from the list of active animations
    Can be used only in local scripts on self.
  ]]
  cancel: function(
    actor: openmw_core.GameObject,
    groupname: string
  )
  
  --[[
    Clears all animations currently in the animation queue.
    This affects animations played by mwscript, @{openmw.animation#playQueued}, and ai packages, but does not affect animations played using @{openmw.animation#playBlended}.
    Can be used only in local scripts on self.
  ]]
  clearAnimationQueue: function(
    actor: openmw_core.GameObject,
    clearScripted: boolean
  )
  
  --[[
    Get the current active animation for a bone group
  ]]
  getActiveGroup: function(
    actor: openmw_core.GameObject,
    bonegroup: number
  ): string
  
  --[[
    Returns the completion of the animation, or nil if the animation group is not active.
  ]]
  getCompletion: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): number | nil
  
  --[[
    Get the current absolute time of the given animation group if it is playing, or -1 if it is not playing.
  ]]
  getCurrentTime: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): number
  
  --[[
    Returns the remaining number of loops, not counting the current loop, or nil if the animation group is not active.
  ]]
  getLoopCount: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): number | nil
  
  --[[
    Get the current playback speed of an animation group, or nil if the animation group is not active.
  ]]
  getSpeed: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): number | nil
  
  --[[
    Get the absolute position within the animation track of the given text key
  ]]
  getTextKeyTime: function(
    actor: openmw_core.GameObject,
    text: string
  ): number
  
  --[[
    Check if the object has an animation object or not
  ]]
  hasAnimation: function(
    actor: openmw_core.GameObject
  ): boolean
  
  --[[
    Check if the actor's skeleton has the given bone or not
  ]]
  hasBone: function(
    actor: openmw_core.GameObject,
    bonename: string
  ): boolean
  
  --[[
    Check if the actor's animation has the given animation group or not.
  ]]
  hasGroup: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): boolean
  
  --[[
    Check whether the animation is a looping animation or not.
    This is determined by a combination 
    of groupname, some of which are hardcoded to be looping, and the presence of loop start/stop keys.
    The groupnames that are hardcoded as looping are the following, as well as per-weapon-type suffixed variants of each.
    "walkforward", "walkback", "walkleft", "walkright", "swimwalkforward", "swimwalkback", "swimwalkleft", "swimwalkright", 
    "runforward", "runback", "runleft", "runright", "swimrunforward", "swimrunback", "swimrunleft", "swimrunright", 
    "sneakforward", "sneakback", "sneakleft", "sneakright", "turnleft", "turnright", "swimturnleft", "swimturnright",
    "spellturnleft", "spellturnright", "torch", "idle", "idle2", "idle3", "idle4", "idle5", "idle6", "idle7", "idle8", 
    "idle9", "idlesneak", "idlestorm", "idleswim", "jump", "inventoryhandtohand", "inventoryweapononehand", 
    "inventoryweapontwohand", "inventoryweapontwowide"
  ]]
  isLoopingAnimation: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): boolean
  
  --[[
    Check if the given animation group is currently playing
  ]]
  isPlaying: function(
    actor: openmw_core.GameObject,
    groupname: string
  ): boolean
  
  --[[
    Play an animation directly.
    You probably want to use the [AnimationController](interface_animation.html) interface, which will trigger relevant handlers, 
    instead of calling this directly. Note that the still hardcoded character controller may at any time and for any reason alter
    or cancel currently playing animations, so making your own calls to this function either directly or through the [AnimationController](interface_animation.html)
    interface may be of limited utility. For now, use openmw.animation#playQueued to script your own animations.
    Can be used only in local scripts on self.
  ]]
  playBlended: function(
    actor: openmw_core.GameObject,
    groupname: string,
    options: table
  )
  
  --[[
    Acts as a slightly extended version of MWScript's LoopGroup.
    Plays this animation exclusively
    until it ends, or the queue is cleared using #clearAnimationQueue. Use #clearAnimationQueue and the `startkey` option
    to imitate the behavior of LoopGroup's play modes.
    Can be used only in local scripts on self.
    -- Play death1 without waiting. Equivalent to playgroup, death1, 1
    anim.clearAnimationQueue(self, false)
    anim.playQueued(self, 'death1')
    
  ]]
  playQueued: function(
    actor: openmw_core.GameObject,
    groupname: string,
    options: table
  )
  
  --[[
    Removes all vfx from the actor
    Can be used only in local scripts on self.
  ]]
  removeAllVfx: function(
    actor: openmw_core.GameObject
  )
  
  --[[
    Removes a specific VFX
    Can be used only in local scripts on self.
  ]]
  removeVfx: function(
    actor: openmw_core.GameObject,
    vfxId: number
  )
  
  --[[
    Enables or disables looping for the given animation group.
    Looping is enabled by default.
    Can be used only in local scripts on self.
  ]]
  setLoopingEnabled: function(
    actor: openmw_core.GameObject,
    groupname: string,
    enabled: boolean
  )
  
  --[[
    Modifies the playback speed of an animation group.
    Note that this is not sticky and only affects the speed until the currently playing sequence ends.
    Can be used only in local scripts on self.
  ]]
  setSpeed: function(
    actor: openmw_core.GameObject,
    groupname: string,
    speed: number
  )
  
  --[[
    Skips animations for one frame, equivalent to mwscript's SkipAnim
    Can be used only in local scripts on self.
  ]]
  skipAnimationThisFrame: function(
    actor: openmw_core.GameObject
  )
  
end
return animation