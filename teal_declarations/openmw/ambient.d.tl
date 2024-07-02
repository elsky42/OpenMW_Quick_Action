--[[
  `openmw.ambient` controls background sounds, specific to given player (2D-sounds).
  Can be used only by menu scripts and local scripts, that are attached to a player.
  local ambient = require('openmw.ambient')
]]

local record ambient
  --[[
    Check if music is playing
    local isPlaying = ambient.isMusicPlaying();
  ]]
  isMusicPlaying: function(): boolean
  
  --[[
    Check if sound file is playing
    local isPlaying = ambient.isSoundFilePlaying("Sound\\test.mp3");
  ]]
  isSoundFilePlaying: function(
    fileName: string
  ): boolean
  
  --[[
    Check if sound is playing
    local isPlaying = ambient.isSoundPlaying("shock bolt");
  ]]
  isSoundPlaying: function(
    soundId: string
  ): boolean
  
  --[[
    Play a 2D sound
    local params = {
       timeOffset=0.1
       volume=0.3,
       scale=false,
       pitch=1.0,
       loop=true
    };
    ambient.playSound("shock bolt", params)
  ]]
  playSound: function(
    soundId: string, --[[ID of Sound record to play]]
    options: table
  )
  
  --[[
    Play a 2D sound file
    local params = {
       timeOffset=0.1
       volume=0.3,
       scale=false,
       pitch=1.0,
       loop=true
    };
    ambient.playSoundFile("Sound\\test.mp3", params)
  ]]
  playSoundFile: function(
    fileName: string, --[[Path to sound file in VFS]]
    options: table
  )
  
  --[[
    Play an ambient voiceover.
    -- play voiceover and print messagebox
    ambient.say("Sound\\Vo\\Misc\\voice.mp3", "Subtitle text")
  ]]
  say: function(
    fileName: string, --[[Path to sound file in VFS]]
    text: string
  )
  
  --[[
    Stop to play current music
    ambient.stopMusic();
  ]]
  stopMusic: function()
  
  --[[
    Stop an ambient voiceover
    ambient.stopSay();
  ]]
  stopSay: function(
    fileName: string
  )
  
  --[[
    Stop a sound
    ambient.stopSound("shock bolt");
  ]]
  stopSound: function(
    soundId: string
  )
  
  --[[
    Stop a sound file
    ambient.stopSoundFile("Sound\\test.mp3");
  ]]
  stopSoundFile: function(
    fileName: string
  )
  
  --[[
    Play a sound file as a music track
    local params = {
       fadeOut=2.0
    };
    ambient.streamMusic("Music\\Test\\Test.mp3", params)
  ]]
  streamMusic: function(
    fileName: string, --[[Path to file in VFS]]
    options: table
  )
  
  record Sound
    --[[
      Check if an ambient voiceover is playing
      local isActive = isSayActive();
    ]]
    isSayActive: function(): boolean
    
  end
end
return ambient