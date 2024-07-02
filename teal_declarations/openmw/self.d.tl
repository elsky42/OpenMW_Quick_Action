--[[
  `openmw.self` provides full access to the object the script is attached to.
  Can be used only from local scripts. All fields and function of `GameObject` are also available for `openmw.self`.
  local self = require('openmw.self')
  local types = require('openmw.types')
  if self.type == types.Player then  -- All fields and functions of `GameObject` are available.
      self:sendEvent("something", self.position)
  end
]]

local openmw_core = require("openmw.core")
--[[
  Allows to view and/or modify controls of an actor.
  All fields are mutable.
]]
global record ActorControls
  --[[
    If true - initiate a jump
  ]]
  jump: boolean
  
  --[[
    +1 - move forward, -1 - move backward
  ]]
  movement: number
  
  --[[
    Look down (radians); if negative - look up
  ]]
  pitchChange: number
  
  --[[
    true - run, false - walk
  ]]
  run: boolean
  
  --[[
    +1 - move right, -1 - move left
  ]]
  sideMovement: number
  
  --[[
    If true - sneak
  ]]
  sneak: boolean
  
  --[[
    if 1 - activates the readied weapon/spell. For weapons, keeping at 1 will charge the attack until set to 0.
  ]]
  use: number
  
  --[[
    Turn right (radians); if negative - turn left
  ]]
  yawChange: number
  
end
local record self
  --[[
    Movement controls (only for actors)
  ]]
  controls: ActorControls
  
  --[[
    Enables or disables standard AI (enabled by default).
  ]]
  enableAI: function(
    self: self,
    v: boolean
  )
  
  --[[
    Returns true if the script isActive (the object it is attached to is in an active cell).
    If it is not active, then `openmw.nearby` can not be used.
  ]]
  isActive: function(
    self: self
  ): boolean
  
  --[[
    The object the script is attached to (readonly)
  ]]
  object: openmw_core.GameObject
  
end
return self