
PilotGroupName = "Uzi11"
HoldingPointZone = "Hold Point"
MenuMainItems = "Nellis AFB"
RadioPower = 120
MenuTowerVisible = false

Messages = {}




function Init()
    Messages["startup-request"] = {}
    Messages["startup-request"][0] = "request startup.ogg"
    Messages["startup-request"][1] = 121.8
    Messages["startup-request"][2] = "Nellis Ground, Uzi1-1, from Ramp F112 request start-up."
    Messages["startup-response"] = {}
    Messages["startup-response"][0] = "cleared for startup.ogg"
    Messages["startup-response"][1] = 121.8
    Messages["startup-response"][2] = "Uzi1-1, Nellis Ground, cleared for startup, RWY 03R. wind 030/5, QNH 29.92, report when ready to taxi."
    Messages["startup-response"][3] = 10
    Messages["taxi-request"] = {}
    Messages["taxi-request"][0] = "request taxi.ogg"
    Messages["taxi-request"][1] = 121.8
    Messages["taxi-request"][2] = "Nellis Ground, Uzi1-1, ready for taxi"
    Messages["taxi-response"] = {}
    Messages["taxi-response"][0] = "cleared for taxi.ogg"
    Messages["taxi-response"][1] = 121.8
    Messages["taxi-response"][2] = "Uzi1-1, Nellis Ground, cleared for taxi holding point A RWY 03R via F A."
    Messages["taxi-response"][3] = 10
    Messages["takeoff-request"] = {}
    Messages["takeoff-request"][0] = "request takeoff.ogg"
    Messages["takeoff-request"][1] = 327
    Messages["takeoff-request"][2] = "Nellis Tower, Uzi1-1, holding point A, runway 03R, ready for departure."
    Messages["takeoff-response"] = {}
    Messages["takeoff-response"][0] = "cleared for takeoff.ogg"
    Messages["takeoff-response"][1] = 327
    Messages["takeoff-response"][2] = "Uzi1-1, Nellis Tower, cleared for takeoff runway 03R, wind 030/5 knots, after departure climb 5000ft, QNH 29.92."
    Messages["takeoff-response"][3] = 10
end

Airborne = false
Init()
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


function SendRadioMessageFromTable(index,answered,group)
    if(answered) then
        key = index .. "-request"
        sendRadioMessage(Messages[key][0],Messages[key][1],Messages[key][2],group)
        key = index .. "-response"
        mytimer=TIMER:New(sendRadioMessage, Messages[key][0],Messages[key][1],Messages[key][2], group)
        mytimer:Start(Messages[key][3])
    else
        sendRadioMessage(Messages[index][0],Messages[index][1],Messages[index][2],group)
    end
    
end

function SendRadioStartup()
    PilotGroupObject = GROUP:FindByName(PilotGroupName)
    SendRadioMessageFromTable("startup",true,PilotGroupObject)
end

function SendRadioTaxi()
    PilotGroupObject = GROUP:FindByName(PilotGroupName)
    SendRadioMessageFromTable("taxi",true,PilotGroupObject)
end

function SendRadioTakeoff()
    Uzi1 = GROUP:FindByName(PilotGroupName)
    SendRadioMessageFromTable("takeoff",true,PilotGroupObject)
end


function sendMessageToGroup(message,group)
    MESSAGE:New( message,10 ):ToGroup(group)
end




function AddStartMenu()
    StartupMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request startup", MenuCoalitionBlue, SendRadioStartup )
    TaxiMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request taxi", MenuCoalitionBlue, SendRadioTaxi )
end

function RemoveTowerMenu()
    if(StartupMenu) then
        StartupMenu:Remove()
    end
    if(TaxiMenu) then
        TaxiMenu:Remove()
    end
    if(TakeoffMenu) then
        TakeoffMenu:Remove()
    end
    MenuTowerVisible = false
end


--- Function to manage all scheduler
function ScheduleManager()
    IsAirborne()
    if(not Airborne) then
        CheckTowerMenu()
        ActivateTakeoffMenu()
    else
        RemoveTowerMenu()
    end
end

function CheckTowerMenu()
    if(not MenuTowerVisible) then
        AddStartMenu()
        MenuTowerVisible = true
    end
end

---SCHEDULE Functions
function ActivateTakeoffMenu()
    local pilotGroup = GetPilotGroupObject()
    if(pilotGroup and pilotGroup:IsPartlyOrCompletelyInZone(HoldingPointRunway)) then
        TakeoffMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request takeoff", MenuCoalitionBlue, SendRadioTakeoff ) 
    end
end

function IsAirborne()
    local clientGroup = CLIENT:FindByName(PilotGroupName)
    if(clientGroup and clientGroup:IsAlive() and clientGroup:InAir(true)) then
        Airborne = true
    else
        Airborne = false
    end

end

Messager = SCHEDULER:New(nil,ScheduleManager,{},0,1)
--dofile(MOOSE_DYNAMIC_LOADER)
--dofile("C:/vscode sources/dcs/airport/procedures.lua")