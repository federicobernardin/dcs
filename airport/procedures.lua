
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
NellisMainMenu = "Nellis AFB"
GeneralMainMenu = "General"

RadioPower = 120
MenuTowerVisible = false
AWACSEnable = false
NellisApproch = false
Showtime = false
Direction = "ingress" -- "egress"

Messages = {}


--- Return Group for specific pilot.
-- @return #GROUP
function GetPilotGroupObject()
    PilotGroupObject = GROUP:FindByName(PilotGroupName)
    return PilotGroupObject
end


FLIGHT_CONTROL = {
    towerCompetenceZone = "Nellis Tower Zone",
    towerApprochZone = "Approch Tower change zone",
    AWACSApprochZone = "AWACS activation",
    AWACSShowtimeZone="Showtime activation",
    showtimeInformationZone = "Showtime information",
    pilotGroupObject = nil,
    direction = "next", 
    controllingShiftingZone = {},
    init = function(self)
        self.controllingShiftingZone[0] = {}
        self.controllingShiftingZone[0]["name"] = "Tower"
        self.controllingShiftingZone[0]["frequency"] = 327
        self.controllingShiftingZone[0]["ID"] = "Approch Tower change zone"
        self.controllingShiftingZone[0]["next"] = "Contact Nellis Approch"
        self.controllingShiftingZone[0]["message"] = "Contact Nellis Approch"
        self.controllingShiftingZone[0]["previous"] = "Contact Tower"
        self.controllingShiftingZone[1] = {}
        self.controllingShiftingZone[1]["name"] = "Nellis Approch"
        self.controllingShiftingZone[1]["frequency"] = 327
        self.controllingShiftingZone[1]["ID"] = "AWACS activation"
        self.controllingShiftingZone[1]["next"] = "Contact AWACS"
        self.controllingShiftingZone[1]["previous"] = "Contact Approch"
        self.controllingShiftingZone[1]["message"] = "Contact AWACS"
        self.controllingShiftingZone[2] = {}
        self.controllingShiftingZone[2]["name"] = "AWACS"
        self.controllingShiftingZone[2]["frequency"] = 305
        self.controllingShiftingZone[2]["ID"] = "Showtime activation"
        self.controllingShiftingZone[2]["next"] = "Contact Showtime"
        self.controllingShiftingZone[2]["previous"] = "Contact AWACS"
        self.controllingShiftingZone[2]["message"] = "Contact Showtime"
        self.controllingShiftingZone[3] = {}
        self.controllingShiftingZone[3]["name"] = "Showtime"
        self.controllingShiftingZone[3]["frequency"] = 315
        self.controllingShiftingZone[3]["ID"] = "Showtime information"
        self.controllingShiftingZone[3]["next"] = nil
        self.controllingShiftingZone[3]["previous"] = "Showtime information"
        self.controllingShiftingZone[3]["message"] = "Showtime information"
    end,
    zoneCounter = 0,          
    zoneCounterNext = 1,                                       

    checkStatus = function(self) 
        if(self.pilotGroupObject == nil) then
            self.pilotGroupObject= GetPilotGroupObject()
        end
        if(self.zoneCounterNext>-1 and self.controllingShiftingZone[self.zoneCounter]["ID"] and UnitInZone(self.controllingShiftingZone[self.zoneCounter]["ID"])) then
            if(self.controllingShiftingZone[self.zoneCounter]["function"]) then
                load(self.controllingShiftingZone[self.zoneCounter]["function"])
            end
            sendMessageToGroup(self.controllingShiftingZone[self.zoneCounter][self.direction],self.pilotGroupObject)
            
            if(self.direction == "next") then
                self.zoneCounterNext = self.zoneCounterNext + 1
                self.zoneCounter = self.zoneCounter + 1
            else
                self.zoneCounterNext = self.zoneCounterNext - 1
                self.zoneCounter = self.zoneCounter - 1
            end
        else
        end
    end,
    RtbHandler = function(self)
        if(self.counter == 4) then
            self.counter = 3
        end
        self.direction = "previous"
    end
}



-- funzione per inizializzare la missione
function Init()
    --BASE.TraceOnOff(true)
    FLIGHT_CONTROL:init()
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

NellisCoalitionMenu = MENU_COALITION:New( coalition.side.BLUE, NellisMainMenu )
GeneralCoalitionMenu = MENU_COALITION:New( coalition.side.BLUE, GeneralMainMenu )

function sendRadioMessage(file,frequency,message,group)
    -- Now, we'll set up the next transmission
    AirportportRadio:SetFileName(file)  -- We first need the file name of a sound,
    AirportportRadio:SetFrequency(frequency)         -- then a frequency in MHz,
    AirportportRadio:SetModulation(radio.modulation.AM) -- a modulation (we use DCS' enumartion, this way we don't have to type numbers)...
    AirportportRadio:SetPower(RadioPower)             -- and finally a power in Watts. A "normal" ground TACAN station has a power of 120W.
    AirportportRadio:Broadcast()
    sendMessageToGroup(message,group)
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
        LandingMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request landing", NellisCoalitionMenu, SendRadioLanding )
    else
        if(LandingMenu) then
            LandingMenu:Remove()
        end
    end
end

function RequestRTBMenuCheck(airborne)
    if(airborne and not RTBMenu) then
        RTBMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "RTB", GeneralCoalitionMenu, SendRadioLanding )
    else
        if(RTBMenu) then
            RTBMenu:Remove()
        end
    end
end

function AddStartMenu()
    StartupMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request startup", NellisCoalitionMenu, SendRadioStartup )
    TaxiMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request taxi", NellisCoalitionMenu, SendRadioTaxi )
end

function RemoveTowerMenu()
    if(StartupMenu) then
        StartupMenu:Remove()
        StartupMenu = nil
    end
    if(TaxiMenu) then
        TaxiMenu:Remove()
        TaxiMenu = nil
    end
    if(TakeoffMenu) then
        TakeoffMenu:Remove()
        TakeoffMenu = nil
    end
    MenuTowerVisible = false
end


--- Function to manage all scheduler
function ScheduleManager()
    IsAirborne()
    RequestRTBMenuCheck(Airborne)
    if(not Airborne) then
        CheckTowerMenu()
        ActivateTakeoffMenu()
    else
        RemoveTowerMenu()
        RequestLandingMenuCheck()
        FLIGHT_CONTROL:checkStatus()
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
        TakeoffMenu = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request takeoff", NellisCoalitionMenu, SendRadioTakeoff ) 
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

function MoveToApprochOrTower()
    if(UnitInZone(TowerApprochZone) and Direction == "ingress") then
        if(Direction == "ingress") then
            sendMessageToGroup("Passa ad approch",Uzi1)
        else
            sendMessageToGroup("passa a tower",Uzi1)
        end
    end
end

function MoveToAWACSOrApproch()
    if(UnitInZone("AWACSApprochZone") and Direction == "ingress") then
        if(Direction == "ingress") then
            sendMessageToGroup("Passa ad awacs",Uzi1)
        else
            sendMessageToGroup("passa a approch",Uzi1)
        end
    end
end

function MoveToAWACSOrApproch()
    if(UnitInZone("AWACSApprochZone") and Direction == "ingress") then
        if(Direction == "ingress") then
            sendMessageToGroup("Passa ad awacs",Uzi1)
        else
            sendMessageToGroup("passa a approch",Uzi1)
        end
    end
end


Messager = SCHEDULER:New(nil,ScheduleManager,{},0,10)
--dofile(MOOSE_DYNAMIC_LOADER)
--dofile("C:/vscode sources/dcs/airport/procedures.lua")