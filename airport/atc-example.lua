


-- local pippo= ZONE_AIRBASE:New("Kobuleti",8046.72)
-- local ATCZone = SET_ZONE:New():FilterPrefixes( "Deploy" ):FilterStart()

-- local airzone = pippo:GetAirbase().AirbaseName
local k=15
-- local sentry = GROUP:FindByName( "AWACS" )
-- function ScheduleManager()
--     if (sentry:IsCompletelyInZone(pippo)) then
--         MESSAGE:New( "Entrato",5 ):ToAll()
--     end
--     if (sentry:IsNotInZone(pippo)) then
--         MESSAGE:New( "Uscito",5 ):ToAll()
--     end
-- end


-- Messager = SCHEDULER:New(nil,ScheduleManager,{},0,10)
BASIC_ROOT = "C:/vscode sources/dcs/airport/"
__Moose.Include( BASIC_ROOT..'events/eventDispatcher.lua' )
__Moose.Include( BASIC_ROOT..'events/eventHandler.lua' )
__Moose.Include( BASIC_ROOT..'atcUnit.lua' )
__Moose.Include( BASIC_ROOT..'ATC.lua' )
EventHandlerManager = EventHandler:new()
local kobuleti = ATC:New("Kobuleti",EventHandlerManager,221,222,223,18500)
kobuleti:AddUnit("Sentry")
local function onEnterTowerControl(event)
    env.info("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            env.info(key .. ": " .. tostring(value.name))
        end
    end
end
local function onEnterACCControl(event)
    print("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            print(key .. ": " .. tostring(value))
        end
    end
end
local function onExitTowerControl(event)
    print("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            print(key .. ": " .. tostring(value))
        end
    end
end
local function onExitACCControl(event)
    print("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            print(key .. ": " .. tostring(value))
        end
    end
end
local function inTowerControl(event)
    print("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            print(key .. ": " .. tostring(value))
        end
    end
end

local function inACCControl(event)
    print("Evento ricevuto: " .. event.type)
    if event.data then
        for key, value in pairs(event.data) do
            print(key .. ": " .. tostring(value))
        end
    end
end

--EventHandlerManager:addEventListener("enterTowerControl", {name=onEnterTowerControl})
-- EventHandlerManager:addEventListener("exitTowerControl", onEnterTowerControl)
EventHandlerManager:addEventListener("enterACCControl", {name=onEnterTowerControl})
-- EventHandlerManager:addEventListener("exitACCControl", onEnterTowerControl)
--EventHandlerManager:addEventListener("inTowerControl", onEnterTowerControl)
--EventHandlerManager:addEventListener("inACCControl", onEnterTowerControl)