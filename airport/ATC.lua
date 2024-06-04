
ATC={
    groundFrequency = 0,
    towerFrequency = 0,
    accFrequency = 0,
    tower = nil,
    acc = nil,
    towerZoneRadius = 8046.72,
    accZone = 0,
    accIngressComunication = "Welcome Cowboy1-1, Approch Control, continue inbound",
    accGoodbyeMessage = "Cowboy1-1, Kobuleti Approch, switch to Kobuleti Tower on frequency %s. Good day",
    towerIngressMessage = "Welcome Cowboy1-1, Kobuleti Tower, you're cleared for landing, runway 31L, 080 Wind",
    towerGoodbyeMessage = "Cowboy1-1, Kobuleti Tower, switch to Kobuleti Approch on frequency %s. Good day"
    
}
ATC.__index = ATC

function ATC:scheduleManager()
    for key, value in pairs(self.Units) do
        if(value:IsInZone(self.tower)and value:IsInZone(self.acc)) then
            if(value.insideACC) then
                value.insideACC = false
                self.eventHandler:dispatchEvent("exitACCControl", {unit = value})
            end
            if(not value.insideATC) then
                self.eventHandler:dispatchEvent("enterTowerControl", {unit = value})
            end
            value.insideATC = true
            self.eventHandler:dispatchEvent("inTowerControl", {unit = value})
        else
            if(value:IsInZone(self.acc)) then
                if(value.insideATC) then
                    self.eventHandler:dispatchEvent("exitTowerControl", {unit = value})
                    value.insideATC = false
                end
                if(not value.insideACC) then
                    self.eventHandler:dispatchEvent("enterACCControl", {unit = value})
                end
                value.insideACC = true
                self.eventHandler:dispatchEvent("inACCControl", {unit = value})
            else
                if(value.insideACC) then
                    self.eventHandler:dispatchEvent("exitACCControl", {unit = value})
                    value.insideACC = false
                end
            end
        end
    end
end

function ATC:New(Airport,EventHandlerObject,GroundFrequency,TowerFrequency,ACCFrequency,ACCRadius,TowerRadius)
    local self = setmetatable({}, ATC)
    self.towerZoneRadius = TowerRadius or 8046.72
    self.ACCZoneRadius = ACCRadius
    self.groundFrequency = GroundFrequency
    self.towerFrequency  =TowerFrequency
    self.accFrequency = ACCFrequency
    self.Units = {}
    self.tower = ZONE_AIRBASE:New(Airport, self.towerZoneRadius)
    self.acc = ZONE_AIRBASE:New(Airport, self.ACCZoneRadius)
    self.eventHandler = EventHandlerObject
    Messenger = SCHEDULER:New(self,self.scheduleManager,{},0,2)
    pippo=tostring(self.ingressACCComunication)
    self.eventHandler:addEventListener("enterACCControl", {name=self.ingressACCComunication,object=self})
    self.eventHandler:addEventListener("exitACCControl", {name=self.goodbyeTowerComunication,object=self})
    self.eventHandler:addEventListener("enterTowerControl", {name=self.ingressTowerComunication,object=self})
    self.eventHandler:addEventListener("exitTowerControl", {name=self.goodbyeTowerComunication,object=self})
    return self
end

function ATC:AddUnit(UnitName)
    UnitObject = ATC_Unit:New(UnitName)
    if not UnitObject then
        env.error( "ERROR: Unit " .. UnitName .. " does not exist!" )
        return nil
    end
    --if not self.Units[UnitName] then
        self.Units[UnitName] =  UnitObject
    --end
end

function ATC:ingressACCComunication(event)
    self:sendMessage(event.data.unit,self.accIngressComunication)
end
function ATC:ingressTowerComunication(event)
    self:sendMessage(event.data.unit,self.towerIngressMessage)
end
function ATC:goodbyeACCComunication(event)
    self:sendMessage(event.data.unit,self.accGoodbyeMessage)
end
function ATC:goodbyeTowerComunication(event)
    self:sendMessage(event.data.unit,self.towerGoodbyeMessage)
end

function ATC:sendMessage(unit,message)
    MESSAGE:New( message,10 ):ToAll() --:ToUnit(unit)
end