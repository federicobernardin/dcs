-- This test mission demonstrates the RADIO class, particularily when the transmiter is anything but a UNIT or a GROUP (a STATIC in this case)
-- The Player is in a Su25T parked on Batumi, and a Russian command center named "Russian Command Center" is placed 12km east of Batumi.

-- Note that if you are not using an ASM aircraft (a clickable cockpit aircraft), then the frequency and the modulation is not important.
-- If you want to test the mission fully, replance the SU25T by an ASM aircraft you own and tune to the right frequency (108AM here)

CommandCenter = STATIC:FindByName("HQ")
Cowboy = GROUP:FindByName("Cowboy11")

-- Let's get a reference to the Command Center's RADIO
CommandCenterRadio = CommandCenter:GetRadio()  

MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Manage Menus" )

-- Now, we'll set up the next transmission
CommandCenterRadio:SetFileName("landing1.ogg")  -- We first need the file name of a sound,
CommandCenterRadio:SetFrequency(108)         -- then a frequency in MHz,
CommandCenterRadio:SetModulation(radio.modulation.AM) -- a modulation (we use DCS' enumartion, this way we don't have to type numbers)...
CommandCenterRadio:SetPower(200)             -- and finally a power in Watts. A "normal" ground TACAN station has a power of 120W.
function SendRadio()
    
-- We have finished tinkering with our transmission, now is the time to broadcast it !
CommandCenterRadio:Broadcast()
MESSAGE:New( "cowboy-1-1, welcome to nellis airforce base, contact tower to frequency 108.00 to landing", 35, "INFO" ):ToGroup(Cowboy)
end

MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Send command", MenuCoalitionBlue, SendRadio )