--[[
  `openmw.menu` can be used only in menu scripts.
  local menu = require('openmw.menu')
]]

global record STATE
  Ended: any
  
  NoGame: any
  
  Running: any
  
end
local record menu
  --[[
    All possible game states returned by @{#menu.getState}
  ]]
  STATE: STATE
  
  --[[
    Delete a saved game
  ]]
  deleteGame: function(
    directory: string, --[[name of the save directory (e. g. character)]]
    slotName: string
  )
  
  --[[
    List of all available saves, grouped by directory
  ]]
  getAllSaves: function(): { any: { menu.SaveInfo } }
  
  --[[
    Current save directory
  ]]
  getCurrentSaveDir: function(): string
  
  --[[
    List of all saves for the given directory
  ]]
  getSaves: function(
    directory: string
  ): { menu.SaveInfo }
  
  --[[
    Current game state
  ]]
  getState: function(): STATE
  
  --[[
    Load the game from a save slot
  ]]
  loadGame: function(
    directory: string, --[[name of the save directory (e. g. character)]]
    slotName: string
  )
  
  --[[
    Start a new game
  ]]
  newGame: function()
  
  --[[
    Exit the game
  ]]
  quit: function()
  
  --[[
    Save the game
  ]]
  saveGame: function(
    description: string, --[[human readable description of the save]]
    slotName: string
  )
  
  record SaveInfo
    contentFiles: { string }
    
    --[[
      Time at which the game was saved, as a timestamp in seconds. Can be passed as the second argument to `os.data`.
    ]]
    creationTime: number
    
    description: string
    
    playerLevel: string
    
    playerName: string
    
    --[[
      Gameplay time for this saved game. Note: available even with [time played](../modding/settings/saves.html#timeplayed) turned off
    ]]
    timePlayed: number
    
  end
end
return menu