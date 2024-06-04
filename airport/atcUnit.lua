ATC_Unit = {
    ClassName="ATC_Unit",
}

function ATC_Unit:New( UnitName )

    -- Inherit ZONE_BASE.
    local self = BASE:Inherit( self, UNIT:FindByName(UnitName) )
  
    self.isReadyToTaxi = false
    self.isReadyToTakeoff = false
    self.isReadyToStartup = false
    self.isAirborne = self:InAir()
    self.insideATC = false
    self.insideACC = false
    self.name = UnitName
  

  
    return self
  end