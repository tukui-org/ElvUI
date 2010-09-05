----------------------------------------------------------------------------------------
-- Script to fix wintergrasp mount, /cast [flyable] Flying Mount Name; Ground Mount Name
-- is not working when wintergrasp is in progress, it return nothing. :(
-- Also can exit vehicule if you are on a friend mechano, mammooth, etc
-- example of use : /mounter Amani War Bear, Relentless Gladiator's Frost Wyrm
----------------------------------------------------------------------------------------

local WINTERGRASP
WINTERGRASP = tukuilocal.mount_wintergrasp

local inFlyableWintergrasp = function()
	return GetZoneText() == WINTERGRASP and not GetWintergraspWaitTime()
end

local creatureCache, creatureId, creatureName
local mountCreatureName = function(name)
	local companionCount = GetNumCompanions("MOUNT")
	
	if not creatureCache or companionCount ~= #creatureCache then
		creatureCache = {}

		for i = 1, companionCount do
			creatureId, creatureName = GetCompanionInfo("MOUNT", i)
			creatureCache[creatureName] = i
		end
	end
	
	local creatureId = creatureCache[name]
	
	if creatureId then
		CallCompanion("MOUNT", creatureId)
		return true
	end
end

local argumentsPattern = "([^,]+),%s*(.+)"

SlashCmdList['MOUNTER'] = function(text, editBox)
	if CanExitVehicle() then
		VehicleExit()
	elseif not IsMounted() and not InCombatLockdown() then
		local groundMount, flyingMount = string.match(text, argumentsPattern)
		
		if not groundMount then
			groundMount = #text > 0 and text or nil
		end
		
		if groundMount then
			local mount = (flyingMount and IsFlyableArea() and not inFlyableWintergrasp()) and flyingMount or groundMount
			local success = mountCreatureName(mount)
		end
	else
		Dismount()
	end
end

SLASH_MOUNTER1 = "/mounter"
