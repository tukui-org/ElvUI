local _, ns = ...
local oUF = ns.oUF

local next = next
local wipe = wipe
local select = select

local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitClass = UnitClass

local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

local auraInfo = {}
local auraFiltered = {
	HELPFUL = {},
	HARMFUL = {},
	RAID = {},
	PLAYER = {},
	INCLUDE_NAME_PLATE_ONLY = {}
}

oUF.AuraInfo = auraInfo -- export it, not filtered
oUF.AuraFiltered = auraFiltered -- by filter

local hasValidPlayer
local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('PLAYER_LEAVING_WORLD')
eventFrame:SetScript('OnEvent', function(_, event)
	if event == 'PLAYER_ENTERING_WORLD' then
		hasValidPlayer = true
	elseif event == 'PLAYER_LEAVING_WORLD' then
		hasValidPlayer = false
	end
end)

local function CheckIsMine(sourceUnit)
	return sourceUnit == 'player' or sourceUnit == 'pet' or sourceUnit == 'vehicle'
end

local function AllowAura(frame, aura)
	if aura.isNameplateOnly then
		return frame.isNamePlate
	end

	return true
end

local function UpdateFilter(which, filter, filtered, allow, unit, auraInstanceID, aura)
	local unitAuraFiltered = filtered[unit]

	unitAuraFiltered[auraInstanceID] = not oUF:ShouldSkipAuraFilter(aura, filter) and (which ~= 'remove' and allow and aura) or nil
end

local function UpdateAuraFilters(which, frame, event, unit, showFunc, auraInstanceID, aura)
	local unitAuraInfo = auraInfo[unit]

	if which == 'update' then
		aura = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
	elseif which == 'remove' then
		aura = unitAuraInfo[auraInstanceID]
	end

	if aura and aura.sourceUnit then -- this is lame but useful
		aura.unitGUID = UnitGUID(aura.sourceUnit) -- fetch the new unit token with UnitTokenFromGUID
		aura.unitName, aura.unitRealm = UnitName(aura.sourceUnit)
		aura.unitClassName, aura.unitClassFilename, aura.unitClassID = UnitClass(aura.sourceUnit)
	end

	unitAuraInfo[auraInstanceID] = (which ~= 'remove' and aura) or nil

	local allow = (which == 'remove') or not aura or AllowAura(frame, aura)

	for filter, filtered in next, auraFiltered do
		UpdateFilter(which, filter, filtered, allow, unit, auraInstanceID, aura)
	end

	if showFunc then
		return showFunc(frame, event, unit, auraInstanceID, aura)
	else
		return allow
	end
end

local function TryAdded(which, frame, event, unit, showFunc, aura)
	return UpdateAuraFilters(which, frame, event, unit, showFunc, aura and aura.auraInstanceID, aura)
end

local function TryUpdated(which, frame, event, unit, showFunc, auraInstanceID)
	return UpdateAuraFilters(which, frame, event, unit, showFunc, auraInstanceID)
end

local function TryRemove(which, frame, event, unit, showFunc, auraInstanceID)
	return UpdateAuraFilters(which, frame, event, unit, showFunc, auraInstanceID)
end

local function TrySkipAura(which, frame, event, unit, showFunc, tryFunc, auras)
	if not auras then return end

	local show -- assume we skip it
	for _, value in next, auras do -- lets process them all
		if tryFunc(which, frame, event, unit, showFunc, value) then
			show = true -- something is shown
		end
	end

	return show
end

local function ProcessAura(frame, event, unit, token, ...)
	local numSlots = select('#', ...)
	for i = 1, numSlots do
		local slot = select(i, ...)
		local aura = GetAuraDataBySlot(unit, slot)
		if aura then
			TryAdded('add', frame, event, unit, nil, aura)
		end
	end

	return token
end

local function ProcessTokens(frame, event, unit, token, ...)
	repeat token = ProcessAura(frame, event, unit, token, ...)
	until not token
end

local function ProcessExisting(frame, event, unit)
	ProcessTokens(frame, event, unit, GetAuraSlots(unit, 'HELPFUL'))
	ProcessTokens(frame, event, unit, GetAuraSlots(unit, 'HARMFUL'))
end

local function ShouldSkipAura(frame, event, unit, updateInfo, showFunc)
	if not auraInfo[unit] then
		oUF:CreateUnitAuraInfo(unit)
	end

	if event == 'UNIT_AURA' and updateInfo and not updateInfo.isFullUpdate then
		-- these try functions will update the aura info table, so let them process before returning
		local added = TrySkipAura('add', frame, event, unit, showFunc, TryAdded, updateInfo.addedAuras)
		local updated = TrySkipAura('update', frame, event, unit, showFunc, TryUpdated, updateInfo.updatedAuraInstanceIDs)
		local removed = TrySkipAura('remove', frame, event, unit, showFunc, TryRemove, updateInfo.removedAuraInstanceIDs)

		if added then return false end -- a new aura has appeared
		if updated then return false end -- an existing aura has been altered
		if removed then return false end -- an aura has been yeeted into the abyss

		return true -- who are you
	elseif hasValidPlayer ~= false and event ~= 'ElvUI_UpdateAllElements' then -- skip in this case
		oUF:ClearUnitAuraInfo(unit) -- clear these since we cant verify it

		ProcessExisting(frame, event, unit) -- we need to collect full data here
	end

	return false -- this is from something
end

function oUF:ClearUnitAuraInfo(unit)
	wipe(auraInfo[unit])

	for _, data in next, auraFiltered do
		wipe(data[unit])
	end
end

function oUF:CreateUnitAuraInfo(unit)
	if not auraInfo[unit] then
		auraInfo[unit] = {}
	end

	for _, data in next, auraFiltered do
		if not data[unit] then
			data[unit] = {}
		end
	end
end

-- now you can just use AuraFiltered
function oUF:ShouldSkipAuraFilter(aura, filter)
	if not aura then
		return true
	end

	if filter == 'HELPFUL' then
		return not aura.isHelpful
	elseif filter == 'HARMFUL' then
		return not aura.isHarmful
	elseif filter == 'RAID' then
		return not aura.isRaid
	elseif filter == 'INCLUDE_NAME_PLATE_ONLY' then
		return not aura.isNameplateOnly
	elseif filter == 'PLAYER' then
		return not CheckIsMine(aura.sourceUnit)
	end
end

-- ShouldSkipAuraUpdate by Blizzard (implemented and heavily modified by Simpy)
function oUF:ShouldSkipAuraUpdate(frame, event, unit, updateInfo, showFunc)
	if not unit or (frame.unit and frame.unit ~= unit) then
		return true
	end

	return ShouldSkipAura(frame, event, unit, updateInfo, showFunc)
end

-- Blizzard didnt implement the tooltip functions on Era or Mists
function oUF:GetAuraIndexByInstanceID(unit, auraInstanceID, filter)
	local index = 1
	local aura = GetAuraDataByIndex(unit, index, filter)
	while aura do
		if aura.auraInstanceID == auraInstanceID then
			return index
		end

		index = index + 1
		aura = GetAuraDataByIndex(unit, index, filter)
	end
end

function oUF:SetTooltipByAuraInstanceID(tt, unit, auraInstanceID, filter)
	if not auraInstanceID then
		return
	end

	if filter == 'HELPFUL' then
		if tt.SetUnitBuffByAuraInstanceID then
			tt:SetUnitBuffByAuraInstanceID(unit, auraInstanceID)
		else
			local index = oUF:GetAuraIndexByInstanceID(unit, auraInstanceID, filter)
			if index then
				tt:SetUnitBuff(unit, index, filter)
			end
		end
	elseif tt.SetUnitDebuffByAuraInstanceID then
		tt:SetUnitDebuffByAuraInstanceID(unit, auraInstanceID)
	else
		local index = oUF:GetAuraIndexByInstanceID(unit, auraInstanceID, filter)
		if index then
			tt:SetUnitDebuff(unit, index, filter)
		end
	end
end
