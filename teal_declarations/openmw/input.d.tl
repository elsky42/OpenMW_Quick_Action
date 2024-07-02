--[[
  `openmw.input` can be used only in menu scripts and scripts attached to a player.
  local input = require('openmw.input')
]]

local openmw_async = require("openmw.async")
local openmw_util = require("openmw.util")
--[[
  (DEPRECATED, use actions with matching keys)
]]
global record ACTION
  Activate: number
  
  AlwaysRun: number
  
  AutoMove: number
  
  Console: number
  
  CycleSpellLeft: number
  
  CycleSpellRight: number
  
  CycleWeaponLeft: number
  
  CycleWeaponRight: number
  
  GameMenu: number
  
  Inventory: number
  
  Journal: number
  
  Jump: number
  
  MoveBackward: number
  
  MoveForward: number
  
  MoveLeft: number
  
  MoveRight: number
  
  QuickKey1: number
  
  QuickKey10: number
  
  QuickKey2: number
  
  QuickKey3: number
  
  QuickKey4: number
  
  QuickKey5: number
  
  QuickKey6: number
  
  QuickKey7: number
  
  QuickKey8: number
  
  QuickKey9: number
  
  QuickKeysMenu: number
  
  QuickLoad: number
  
  QuickMenu: number
  
  QuickSave: number
  
  Run: number
  
  Screenshot: number
  
  Sneak: number
  
  ToggleDebug: number
  
  ToggleHUD: number
  
  TogglePOV: number
  
  TogglePostProcessorHUD: number
  
  ToggleSpell: number
  
  ToggleWeapon: number
  
  Use: number
  
  ZoomIn: number
  
  ZoomOut: number
  
end
global record ACTION_TYPE
  --[[
    Input action with value of true or false
  ]]
  Boolean: input.ActionType
  
  --[[
    Input action with a numeric value
  ]]
  Number: input.ActionType
  
  --[[
    Input action with a numeric value between 0 and 1 (inclusive)
  ]]
  Range: input.ActionType
  
end
--[[
  Ids of game controller axises.
  Used as an argument in getAxisValue.
]]
global record CONTROLLER_AXIS
  --[[
    Left stick horizontal axis (from -1 to 1)
  ]]
  LeftX: number
  
  --[[
    Left stick vertical axis (from -1 to 1)
  ]]
  LeftY: number
  
  --[[
    (DEPRECATED, use the LookLeftRight action) View direction horizontal axis (RightX by default, can be mapped to another axis in Options/Controls menu)
  ]]
  LookLeftRight: number
  
  --[[
    (DEPRECATED, use the LookUpDown action) View direction vertical axis (RightY by default, can be mapped to another axis in Options/Controls menu)
  ]]
  LookUpDown: number
  
  --[[
    (DEPRECATED, use the MoveForwardBackward action) Movement forward/backward (LeftY by default, can be mapped to another axis in Options/Controls menu)
  ]]
  MoveForwardBackward: number
  
  --[[
    (DEPRECATED, use the MoveLeftRight action) Side movement (LeftX by default, can be mapped to another axis in Options/Controls menu)
  ]]
  MoveLeftRight: number
  
  --[[
    Right stick horizontal axis (from -1 to 1)
  ]]
  RightX: number
  
  --[[
    Right stick vertical axis (from -1 to 1)
  ]]
  RightY: number
  
  --[[
    Left trigger (from 0 to 1)
  ]]
  TriggerLeft: number
  
  --[[
    Right trigger (from 0 to 1)
  ]]
  TriggerRight: number
  
end
global record CONTROLLER_BUTTON
  A: number
  
  B: number
  
  Back: number
  
  DPadDown: number
  
  DPadLeft: number
  
  DPadRight: number
  
  DPadUp: number
  
  Guide: number
  
  LeftShoulder: number
  
  LeftStick: number
  
  RightShoulder: number
  
  RightStick: number
  
  Start: number
  
  X: number
  
  Y: number
  
end
global record CONTROL_SWITCH
  --[[
    Ability to move
  ]]
  Controls: input.ControlSwitch
  
  --[[
    Ability to attack
  ]]
  Fighting: input.ControlSwitch
  
  --[[
    Ability to jump
  ]]
  Jumping: input.ControlSwitch
  
  --[[
    Ability to change view direction
  ]]
  Looking: input.ControlSwitch
  
  --[[
    Ability to use magic
  ]]
  Magic: input.ControlSwitch
  
  --[[
    Vanity view if player doesn't touch controls for a long time
  ]]
  VanityMode: input.ControlSwitch
  
  --[[
    Ability to toggle 1st/3rd person view
  ]]
  ViewMode: input.ControlSwitch
  
end
global record KEY
  A: input.KeyCode
  
  Apostrophe: input.KeyCode
  
  B: input.KeyCode
  
  BackSlash: input.KeyCode
  
  Backspace: input.KeyCode
  
  C: input.KeyCode
  
  CapsLock: input.KeyCode
  
  Comma: input.KeyCode
  
  D: input.KeyCode
  
  Delete: input.KeyCode
  
  DownArrow: input.KeyCode
  
  E: input.KeyCode
  
  End: input.KeyCode
  
  Enter: input.KeyCode
  
  Equals: input.KeyCode
  
  Escape: input.KeyCode
  
  F: input.KeyCode
  
  F1: input.KeyCode
  
  F10: input.KeyCode
  
  F11: input.KeyCode
  
  F12: input.KeyCode
  
  F2: input.KeyCode
  
  F3: input.KeyCode
  
  F4: input.KeyCode
  
  F5: input.KeyCode
  
  F6: input.KeyCode
  
  F7: input.KeyCode
  
  F8: input.KeyCode
  
  F9: input.KeyCode
  
  G: input.KeyCode
  
  H: input.KeyCode
  
  Home: input.KeyCode
  
  I: input.KeyCode
  
  Insert: input.KeyCode
  
  J: input.KeyCode
  
  K: input.KeyCode
  
  L: input.KeyCode
  
  LeftAlt: input.KeyCode
  
  LeftArrow: input.KeyCode
  
  LeftBracket: input.KeyCode
  
  LeftCtrl: input.KeyCode
  
  LeftShift: input.KeyCode
  
  LeftSuper: input.KeyCode
  
  M: input.KeyCode
  
  Minus: input.KeyCode
  
  N: input.KeyCode
  
  NP_0: input.KeyCode
  
  NP_1: input.KeyCode
  
  NP_2: input.KeyCode
  
  NP_3: input.KeyCode
  
  NP_4: input.KeyCode
  
  NP_5: input.KeyCode
  
  NP_6: input.KeyCode
  
  NP_7: input.KeyCode
  
  NP_8: input.KeyCode
  
  NP_9: input.KeyCode
  
  NP_Delete: input.KeyCode
  
  NP_Divide: input.KeyCode
  
  NP_Enter: input.KeyCode
  
  NP_Minus: input.KeyCode
  
  NP_Multiply: input.KeyCode
  
  NP_Plus: input.KeyCode
  
  NumLock: input.KeyCode
  
  O: input.KeyCode
  
  P: input.KeyCode
  
  PageDown: input.KeyCode
  
  PageUp: input.KeyCode
  
  Pause: input.KeyCode
  
  Period: input.KeyCode
  
  PrintScreen: input.KeyCode
  
  Q: input.KeyCode
  
  R: input.KeyCode
  
  RightAlt: input.KeyCode
  
  RightArrow: input.KeyCode
  
  RightBracket: input.KeyCode
  
  RightCtrl: input.KeyCode
  
  RightShift: input.KeyCode
  
  RightSuper: input.KeyCode
  
  S: input.KeyCode
  
  ScrollLock: input.KeyCode
  
  Semicolon: input.KeyCode
  
  Slash: input.KeyCode
  
  Space: input.KeyCode
  
  T: input.KeyCode
  
  Tab: input.KeyCode
  
  U: input.KeyCode
  
  UpArrow: input.KeyCode
  
  V: input.KeyCode
  
  W: input.KeyCode
  
  X: input.KeyCode
  
  Y: input.KeyCode
  
  Z: input.KeyCode
  
  _0: input.KeyCode
  
  _1: input.KeyCode
  
  _2: input.KeyCode
  
  _3: input.KeyCode
  
  _4: input.KeyCode
  
  _5: input.KeyCode
  
  _6: input.KeyCode
  
  _7: input.KeyCode
  
  _8: input.KeyCode
  
  _9: input.KeyCode
  
end
local record input
  --[[
    (DEPRECATED, use getBooleanActionValue) Values that can be used with isActionPressed.
  ]]
  ACTION: ACTION
  
  --[[
    Values that can be used in registerAction
  ]]
  ACTION_TYPE: ACTION_TYPE
  
  --[[
    Values that can be used with getAxisValue.
  ]]
  CONTROLLER_AXIS: CONTROLLER_AXIS
  
  --[[
    Values that can be passed to onControllerButtonPress/onControllerButtonRelease engine handlers.
  ]]
  CONTROLLER_BUTTON: CONTROLLER_BUTTON
  
  --[[
    [Deprecated, moved to types.Player] Values that can be used with getControlSwitch/setControlSwitch.
  ]]
  CONTROL_SWITCH: CONTROL_SWITCH
  
  --[[
    Key codes.
  ]]
  KEY: KEY
  
  --[[
    Map of all currently registered actions
  ]]
  actions: { any: input.ActionInfo }
  
  --[[
    Activates the trigger with the given key
  ]]
  activateTrigger: function(
    key: string
  )
  
  --[[
    Provides a function computing the value of given input action.
      The callback is called once a frame, after the values of dependency actions are resolved.
      Throws an error if a cyclic action dependency is detected.
      input.bindAction('Activate', async:callback(function(dt, use, sneak, run)
          -- while sneaking, only activate things while holding the run binding
          return use and (run or not sneak)
      end), { 'Sneak', 'Run' })
  ]]
  bindAction: function(
    key: string,
    callback: openmw_async.Callback, --[[returning the new value of the action, and taking as arguments:
      frame time in seconds,
      value of the function,
      value of the first dependency action,
      ...]]
    dependencies: { string }
  )
  
  --[[
    Get value of an axis of a game controller.
  ]]
  getAxisValue: function(
    axisId: number
  ): number
  
  --[[
    Returns the value of a Boolean action
  ]]
  getBooleanActionValue: function(
    key: string
  ): boolean
  
  --[[
    [Deprecated, moved to types.Player] Get state of a control switch.
    I.e. is player able to move/fight/jump/etc.
  ]]
  getControlSwitch: function(
    key: input.ControlSwitch
  ): boolean
  
  --[[
    Returns a human readable name for the given key code
  ]]
  getKeyName: function(
    code: input.KeyCode
  ): string
  
  --[[
    Horizontal mouse movement during the last frame.
  ]]
  getMouseMoveX: function(): number
  
  --[[
    Vertical mouse movement during the last frame.
  ]]
  getMouseMoveY: function(): number
  
  --[[
    Returns the value of a Number action
  ]]
  getNumberActionValue: function(
    key: string
  ): number
  
  --[[
    Returns the value of a Range action
  ]]
  getRangeActionValue: function(
    key: string
  ): number
  
  --[[
    (DEPRECATED, use getBooleanActionValue) Input bindings can be changed ingame using Options/Controls menu.
  ]]
  isActionPressed: function(
    actionId: number
  ): boolean
  
  --[[
    Is `Alt` key pressed.
  ]]
  isAltPressed: function(): boolean
  
  --[[
    Is a controller button currently pressed.
  ]]
  isControllerButtonPressed: function(
    buttonId: number
  ): boolean
  
  --[[
    Is `Ctrl` key pressed.
  ]]
  isCtrlPressed: function(): boolean
  
  --[[
    Is player idle.
  ]]
  isIdle: function(): boolean
  
  --[[
    Is a keyboard button currently pressed.
  ]]
  isKeyPressed: function(
    keyCode: input.KeyCode
  ): boolean
  
  --[[
    Is a mouse button currently pressed.
  ]]
  isMouseButtonPressed: function(
    buttonId: number
  ): boolean
  
  --[[
    Is `Shift` key pressed.
  ]]
  isShiftPressed: function(): boolean
  
  --[[
    Is `Super`/`Win` key pressed.
  ]]
  isSuperPressed: function(): boolean
  
  --[[
    Registers a new input action.
    The key must be unique
  ]]
  registerAction: function(
    info: input.ActionInfo
  )
  
  --[[
    Registers a function to be called whenever the action's value changes
  ]]
  registerActionHandler: function(
    key: string,
    callback: openmw_async.Callback
  )
  
  --[[
    Registers a new input trigger.
    The key must be unique
  ]]
  registerTrigger: function(
    info: input.TriggerInfo
  )
  
  --[[
    Registers a function to be called whenever the trigger activates
  ]]
  registerTriggerHandler: function(
    key: string,
    callback: openmw_async.Callback
  )
  
  --[[
    [Deprecated, moved to types.Player] Set state of a control switch.
    I.e. forbid or allow player to move/fight/jump/etc.
  ]]
  setControlSwitch: function(
    key: input.ControlSwitch, --[[Control type (see @{openmw.input#CONTROL_SWITCH})]]
    value: boolean
  )
  
  --[[
    Map of all currently registered triggers
  ]]
  triggers: { any: input.TriggerInfo }
  
  record ActionInfo
    --[[
      initial value of the action
    ]]
    defaultValue: any
    
    --[[
      Localization key of the action's description
    ]]
    description: string
    
    key: string
    
    --[[
      Localization context containing the name and description keys
    ]]
    l10n: string
    
    --[[
      Localization key of the action's name
    ]]
    name: string
    
    type: input.ActionType
    
  end
  record ActionType
  end
  --[[
    String id of a @{#CONTROL_SWITCH}
  ]]
  record ControlSwitch
  end
  --[[
    Numeric id of a @{#KEY}
  ]]
  record KeyCode
  end
  --[[
    The argument of `onKeyPress`/`onKeyRelease` engine handlers.
  ]]
  record KeyboardEvent
    --[[
      Key code.
    ]]
    code: input.KeyCode
    
    --[[
      The pressed symbol (1-symbol string if can be represented or an empty string otherwise).
    ]]
    symbol: string
    
    --[[
      Is `Alt` key pressed.
    ]]
    withAlt: boolean
    
    --[[
      Is `Control` key pressed.
    ]]
    withCtrl: boolean
    
    --[[
      Is `Shift` key pressed.
    ]]
    withShift: boolean
    
    --[[
      Is `Super`/`Win` key pressed.
    ]]
    withSuper: boolean
    
  end
  --[[
    The argument of onTouchPress/onTouchRelease/onTouchMove engine handlers.
  ]]
  record TouchEvent
    --[[
      Device id (there might be multiple touch devices connected). Note: the specific device ids are not guaranteed. Always use previous user input (onTouch... handlers) to get a valid device id (e. g. in your script's settings page).
    ]]
    device: number
    
    --[[
      Finger id (the device might support multitouch).
    ]]
    finger: number
    
    --[[
      Relative position on the touch device (0 to 1 from top left corner),
    ]]
    position: openmw_util.Vector2
    
    --[[
      Pressure of the finger.
    ]]
    pressure: number
    
  end
  record TriggerInfo
    --[[
      Localization key of the trigger's description
    ]]
    description: string
    
    key: string
    
    --[[
      Localization context containing the name and description keys
    ]]
    l10n: string
    
    --[[
      Localization key of the trigger's name
    ]]
    name: string
    
  end
end
return input