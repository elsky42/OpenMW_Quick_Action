--[[
  `openmw_aux.ui` defines utility functions for UI.
  Implementation can be found in `resources/vfs/openmw_aux/ui.lua`.
  local auxUi = require('openmw_aux.ui')
]]

local record ui
  --[[
    Recursively destroys all elements in the passed layout or element
  ]]
  deepDestroy: function(
    elementOrLayout: any
  )
  
  deepLayoutCopy: function(
    layout: table
  ): table
  
  --[[
    Recursively updates all elements in the passed layout or element
  ]]
  deepUpdate: function(
    elementOrLayout: any
  )
  
end
return ui