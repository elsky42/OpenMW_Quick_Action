--[[
  Allows to extend or override built-in skill progression mechanics.
  local I = require('openmw.interfaces')
  
  -- Forbid increasing destruction skill past 50
  I.SkillProgression.addSkillLevelUpHandler(function(skillid, options) 
      if skillid == 'destruction' and types.NPC.stats.skills.destruction(self).base >= 50 then
          return false
      end
  end)
  
  -- Scale sneak skill progression based on active invisibility effects
  I.SkillProgression.addSkillUsedHandler(function(skillid, params)
      if skillid == 'sneak' and params.useType == I.SkillProgression.SKILL_USE_TYPES.Sneak_AvoidNotice then
          local activeEffects = Actor.activeEffects(self)
          local visibility = activeEffects:getEffect(core.magic.EFFECT_TYPE.Chameleon).magnitude / 100
          visibility = visibility + activeEffects:getEffect(core.magic.EFFECT_TYPE.Invisibility).magnitude
          visibility = 1 - math.min(1, math.max(0, visibility))
          local oldSkillGain = params.skillGain
          params.skillGain = oldSkillGain * visibility
      end
  end
  
]]

--[[
  Table of all existing sources for skill increases.
  Any sources not listed below will be treated as equal to Trainer.
]]
global record SkillLevelUpSource
  --[[
    book
  ]]
  Book: string
  
  --[[
    trainer
  ]]
  Trainer: string
  
  --[[
    usage
  ]]
  Usage: string
  
end
--[[
  Table of skill use types defined by morrowind.
  Each entry corresponds to an index into the available skill gain values
  of a @{openmw.core#SkillRecord}
]]
global record SkillUseType
  --[[
    1
  ]]
  Acrobatics_Fall: number
  
  --[[
    0
  ]]
  Acrobatics_Jump: number
  
  --[[
    0
  ]]
  Alchemy_CreatePotion: number
  
  --[[
    1
  ]]
  Alchemy_UseIngredient: number
  
  --[[
    0
  ]]
  Armor_HitByOpponent: number
  
  --[[
    0
  ]]
  Armorer_Repair: number
  
  --[[
    0
  ]]
  Athletics_RunOneSecond: number
  
  --[[
    1
  ]]
  Athletics_SwimOneSecond: number
  
  --[[
    0
  ]]
  Block_Success: number
  
  --[[
    3
  ]]
  Enchant_CastOnStrike: number
  
  --[[
    2
  ]]
  Enchant_CreateMagicItem: number
  
  --[[
    0
  ]]
  Enchant_Recharge: number
  
  --[[
    1
  ]]
  Enchant_UseMagicItem: number
  
  --[[
    1
  ]]
  Mercantile_Bribe: number
  
  --[[
    0
  ]]
  Mercantile_Success: number
  
  --[[
    0
  ]]
  Security_DisarmTrap: number
  
  --[[
    1
  ]]
  Security_PickLock: number
  
  --[[
    0
  ]]
  Sneak_AvoidNotice: number
  
  --[[
    1
  ]]
  Sneak_PickPocket: number
  
  --[[
    1
  ]]
  Speechcraft_Fail: number
  
  --[[
    0
  ]]
  Speechcraft_Success: number
  
  --[[
    0
  ]]
  Spellcast_Success: number
  
  --[[
    0
  ]]
  Weapon_SuccessfulHit: number
  
end
local record SkillProgression
  --[[
    @{#SkillLevelUpSource}
  ]]
  SKILL_INCREASE_SOURCES: SkillLevelUpSource
  
  --[[
    @{#SkillUseType}
  ]]
  SKILL_USE_TYPES: SkillUseType
  
  --[[
    Add new skill level up handler for this actor.
    For load order consistency, handlers should be added in the body if your script.
    If `handler(skillid, source, options)` returns false, other handlers (including the default skill level up handler) 
    will be skipped. Where skillid and source are the parameters passed to @{#SkillProgression.skillLevelUp}, and options is
    a modifiable table of skill level up values, and can be modified to change the behavior of later handlers. 
    These values are calculated based on vanilla mechanics. Setting any value to nil will cause that mechanic to be skipped. By default contains these values:
    
      * `skillIncreaseValue` - The numeric amount of skill levels gained.
      * `levelUpProgress` - The numeric amount of level up progress gained.
      * `levelUpAttribute` - The string identifying the attribute that should receive points from this skill level up.
      * `levelUpAttributeIncreaseValue` - The numeric amount of attribute increase points received. This contributes to the amount of each attribute the character receives during a vanilla level up.
      * `levelUpSpecialization` - The string identifying the specialization that should receive points from this skill level up.
      * `levelUpSpecializationIncreaseValue` - The numeric amount of specialization increase points received. This contributes to the icon displayed at the level up screen during a vanilla level up.
    
  ]]
  addSkillLevelUpHandler: function(
    handler: function
  )
  
  --[[
    Add new skillUsed handler for this actor.
    For load order consistency, handlers should be added in the body of your script.
    If `handler(skillid, options)` returns false, other handlers (including the default skill progress handler) 
    will be skipped. Where options is a modifiable table of skill progression values, and can be modified to change the behavior of later handlers. 
    Contains a `skillGain` value as well as a shallow copy of the options passed to @{#SkillProgression.skillUsed}.
  ]]
  addSkillUsedHandler: function(
    handler: function
  )
  
  --[[
    Compute the total skill gain required to level up a skill based on its current level, and other modifying factors such as major skills and specialization.
  ]]
  getSkillProgressRequirement: function(
    skillid: string
  )
  
  --[[
    Trigger a skill level up, activating relevant handlers
  ]]
  skillLevelUp: function(
    skillid: string, --[[The id of the skill to level up.]]
    source: SkillLevelUpSource
  )
  
  --[[
    Trigger a skill use, activating relevant handlers
  ]]
  skillUsed: function(
    skillid: string, --[[The if of the skill that was used]]
    options: any
  )
  
  --[[
    Interface version
  ]]
  version: number
  
end
return SkillProgression