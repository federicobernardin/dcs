-- This demo mission will play an external audio file.
-- This is a file which is not part of the .miz file.
-- Save the file Hello-world.ogg to your Missions folder,
-- e.g. C:\Users\<YourUserName>\Saved Games\DCS.openbeta\Missions
-- Enter the A-10CII and listen to the radio.
-- If you don't own A-10CII you have to change the mission to use another aircraft.

-- Check dcs.log if something is not working:
BASE:TraceClass("MSRS")
BASE:TraceLevel(3)
BASE:TraceOnOff( true )

-- Force to use SRSEXE and WINDOWS TTS, no matter what is defined in Moose_MSRS.lua
local msrs=MSRS:New()
msrs:SetBackendSRSEXE()
msrs:SetProvider(MSRS.Provider.WINDOWS)
msrs:SetFrequencies(251)

local fileName = "MSRS-003-PlayTextFile.txt"
local folderPath = lfs.writedir() .. 'Missions'
local delay = 5

-- Broadcast text after 5 seconds.
MESSAGE:New( "I try to play the external text file now!" ):ToAll():ToLog()
msrs:PlayTextFile(string.format("%s\\%s", folderPath, fileName), delay)
