
PilotGroupName = "Uzi11"
HoldingPointZone = "Hold Point"
MenuMainItems = "Nellis AFB"
RadioPower = 120

Airborne = false

HoldingPointRunway = ZONE:FindByName(HoldingPointZone)

Airportport = AIRBASE:FindByName(AIRBASE.Nevada.Nellis_AFB)

-- Let's get a reference to the Command Center's RADIO
AirportportRadio = Airportport:GetRadio()  

MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, MenuMainItems )

function sendRadioMessage(file,frequency,message,group)
    -- Now, we'll set up the next transmission
    AirportportRadio:SetFileName(file)  -- We first need the file name of a sound,
    AirportportRadio:SetFrequency(frequency)         -- then a frequency in MHz,
    AirportportRadio:SetModulation(radio.modulation.AM) -- a modulation (we use DCS' enumartion, this way we don't have to type numbers)...
    AirportportRadio:SetPower(RadioPower)             -- and finally a power in Watts. A "normal" ground TACAN station has a power of 120W.
    AirportportRadio:Broadcast()
    sendMessageToGroup(message,group)
end

--- Return Group for specific pilot.
-- @return #GROUP
function GetPilotGroupObject()
    PilotGroupObject = GROUP:FindByName(PilotGroupName)
    return PilotGroupObject
end

function SendRadioStartup()
    sendRadioMessage("request startup.ogg",121.8,"Nellis Ground, Uzi1-1, from Ramp F112 request start-up.",GetPilotGroupObject())
    mytimer=TIMER:New(sendRadioMessage, "cleared for startup.ogg",121.8,"Uzi1-1, Nellis Ground, cleared for startup, Runway in use 03R. wind 30.5 knots, QNH 29.92, report when ready to taxi.", GetPilotGroupObject())
    mytimer:Start(10)
end

function SendRadioTaxi()
    PilotGroupObject = GROUP:FindByName(PilotGroupName)
    sendRadioMessage("request taxi.ogg",121.8,"Nellis Ground, Uzi1-1, ready for taxi",GetPilotGroupObject())
    mytimer=TIMER:New(sendRadioMessage, "cleared for taxi.ogg",121.8,"Uzi1-1, Nellis Ground, cleared for taxi holding point A RWY 03R via F A.", GetPilotGroupObject())
    mytimer:Start(10)
end

function SendRadioTakeoff()
    Uzi1 = GROUP:FindByName(PilotGroupName)
    sendRadioMessage("request takeoff.ogg",121.8,"Nellis Tower, Uzi1-1, holding point A, runway 03R, ready for departure.",GetPilotGroupObject())
    mytimer=TIMER:New(sendRadioMessage, "cleared for takeoff.ogg",121.8,"Uzi1-1, Nellis Tower, cleared for takeoff runway 03R, wind 030/5 knots, after departure climb 5000ft, QNH 29.92.", GetPilotGroupObject())
    mytimer:Start(10)
end


function sendMessageToGroup(message,group)
    MESSAGE:New( message,10 ):ToGroup(group)
end

MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request startup", MenuCoalitionBlue, SendRadioStartup )
MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request taxi", MenuCoalitionBlue, SendRadioTaxi )


Messager = SCHEDULER:New(nil,function()
    pilotGroup = GetPilotGroupObject()
    if(pilotGroup and pilotGroup:IsPartlyOrCompletelyInZone(HoldingPointRunway)) then
        MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request takeoff", MenuCoalitionBlue, SendRadioTakeoff ) 
    end
end,{},0,1
)

-- SCHEDULER:New(nil,function()
--     pilotGroup = GetPilotGroupObject()
--     if(pilotGroup and pilotGroup:IsPartlyOrCompletelyInZone(HoldingPointRunway)) then
--         MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request takeoff", MenuCoalitionBlue, SendRadioTakeoff ) 
--     end
-- end,{},0,1
-- )


--dofile(MOOSE_DYNAMIC_LOADER)
--dofile("C:/vscode sources/dcs/airport/procedures.lua")