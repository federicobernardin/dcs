
--COSE DA SISTEMARE
-- 1) Avvisare di cambiare freq prima della richiesta takeoff
-- 2) sistemare audio startup, rumeore di fondo e testo
-- 3) Aggiungere avviso di cambio freq per APPROC
-- 4) via così

PilotGroupName = "Uzi11"
HoldingPointZone = "Hold Point"
TowerCompetenceZone = "Nellis Tower Zone"
TowerApprochZone = "Approch Tower change zone"
AWACSApprochZone = "AWACS activation"
AWACSShowtimeZone="Showtime activation"
ShowtimeInformationZone = "Showtime information"
MenuMainItems = "Nellis AFB"
RadioPower = 120
MenuTowerVisible = false
AWACSEnable = false
NellisApproch = false
Showtime = false
Direction = "ingress" -- "egress"

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
    Messages["landing-request"] = {}
    Messages["landing-request"][0] = "request landing.ogg"
    Messages["landing-request"][1] = 327
    Messages["landing-request"][2] = "Nellis Tower, Uzi1-1, request landing."
    Messages["landing-response"] = {}
    Messages["landing-response"][0] = "cleared for landing.ogg"
    Messages["landing-response"][1] = 327
    Messages["landing-response"][2] = "Uzi1-1, Nellis Tower, you are cleared for landing in traffic pattern, report final approch, RNWY 21L, Wind 030/5, QNH 29.92."
    Messages["landing-response"][3] = 10
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

function SendRadioLanding()
    Uzi1 = GROUP:FindByName(PilotGroupName)
    SendRadioMessageFromTable("landing",true,PilotGroupObject)
end


function sendMessageToGroup(message,group)
    MESSAGE:New( message,10 ):ToGroup(group)
end

function RequestLandingMenuCheck()
    if(UnitInZone(TowerCompetenceZone) or UnitInZone(TowerApprochZone)) then
        LandingMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request landing", MenuCoalitionBlue, SendRadioLanding )
    else
        if(LandingMenu) then
            LandingMenu:Remove()
        end
    end
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
        RequestLandingMenuCheck()
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

function UnitInZone(ZoneName)
    local pilotGroup = GetPilotGroupObject()
    local zoneObject = ZONE:FindByName(ZoneName)
    if(pilotGroup and pilotGroup:IsPartlyOrCompletelyInZone(zoneObject)) then
        return true
    else
        return false
    end
end

Messager = SCHEDULER:New(nil,ScheduleManager,{},0,1)
--dofile(MOOSE_DYNAMIC_LOADER)
--dofile("C:/vscode sources/dcs/airport/procedures.lua")