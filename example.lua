do
    EngageArea = ZONE:New( "AE" )
    PatrolZone = ZONE:New( "Activate Engage" )
    
AICapZone = AI_CAP_ZONE:New( PatrolZone, 500, 7000, 200, 600 )
    AggressorsFlight = GROUP:FindAllByMatching( "AGRESSORBFM" )
    MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Manage Menus" )

    
    function SetAircraftForBFMWithGun(aircraftToSpawn)
      local aircraft=SPAWN:New(aircraftToSpawn):OnSpawnGroup(
        function (SpawnGroup)
            target_unit = UNIT:FindByName("Aerial-2")
            attack_task = SpawnGroup:TaskAttackUnit(target_unit)
            SpawnGroup:PushTask(attack_task)
        end
    )
      aircraft:SpawnInZone(EngageArea,true,6000,6100)
      --local CapPlane = GROUP:FindByName( aircraftToSpawn )


--AICapZone:SetControllable( CapPlane )

--AICapZone:__Start( 1 ) -- They should statup, and start patrolling in the PatrolZone.
    end
    
    for i,v in ipairs(AggressorsFlight) do
        -- pippo = v:GetName()
    lenght = string.len(v:GetName())
    name = string.sub(v:GetName(),12,lenght)
    --BASE:T("aggressor name " .. v.GetName())
    --BASE:T("aggressor name simplified " .. name)
      MENU_COALITION_COMMAND:New( coalition.side.BLUE, "BFM " .. name .. " With Gun", MenuCoalitionBlue, SetAircraftForBFMWithGun, v:GetName() )
    end
    
    
    end

