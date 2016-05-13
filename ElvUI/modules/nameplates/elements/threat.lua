local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Get Data For All Group Members Threat on Each Nameplate
function mod:Update_ThreatList(frame)
	if frame.IsPlayer or frame.IsFriendly then return end

	local unit = frame.unit
	local isTanking, status, percent = UnitDetailedThreatSituation('player', unit)
	local isInGroup, isInRaid = IsInGroup(), IsInRaid()
	frame.ThreatData = {}
	frame.ThreatData.player = {isTanking, status, percent}
	frame.isBeingTanked = false
	if(isTanking and E:GetPlayerRole() == "TANK") then
		frame.isBeingTanked = true
	end
	
	if(status and (isInRaid or isInGroup)) then --We don't care about units we have no threat on at all
		if isInRaid then
			for i=1, 40 do
				if UnitExists('raid'..i) and not UnitIsUnit('raid'..i, 'player') then
					frame.ThreatData['raid'..i] = frame.ThreatData['raid'..i] or {}
					isTanking, status, percent = UnitDetailedThreatSituation('raid'..i, unit)
					frame.ThreatData['raid'..i] = {isTanking, status, percent}
					
					if(frame.isBeingTanked ~= true and isTanking and UnitGroupRolesAssigned('raid'..i) == "TANK") then
						frame.isBeingTanked = true
					end
				end
			end
		else
			frame.ThreatData = {}
			frame.ThreatData.player = {UnitDetailedThreatSituation('player', unit)}
			for i=1, 4 do
				if UnitExists('party'..i) --[[and not UnitIsUnit('party'..i, 'player')]] then
					frame.ThreatData['party'..i] = frame.ThreatData['party'..i] or {}
					isTanking, status, percent = UnitDetailedThreatSituation('party'..i, unit)
					frame.ThreatData['party'..i] = {isTanking, status, percent}
					
					if(frame.isBeingTanked ~= true and isTanking and UnitGroupRolesAssigned('party'..i) == "TANK") then
						frame.isBeingTanked = true
					end					
				end
			end
		end	
	end
end