local _, ns = ...
local oUF = ns.oUF

local next = next
local wipe = wipe
local select = select
local unpack = unpack

local SpellIsPriorityAura = SpellIsPriorityAura
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = SpellGetVisibilityInfo

local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

local hasValidPlayer = false
local cachedVisibility = {}
local cachedPriority = SpellIsPriorityAura and {}

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

local _, myclass = UnitClass('player')
local AlwaysAllow = { -- spells could get stuck but it's very rare, this table is for that
	[335904] = true, -- Doom Winds: Unable to gain effects of Doom Winds
	[25771] = myclass == 'PALADIN' -- Forbearance: Blizzard has it listed as a priority debuff
}

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('PLAYER_LEAVING_WORLD')

if oUF.isRetail or oUF.isMist then
	eventFrame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
end

eventFrame:SetScript('OnEvent', function(_, event)
	if event == 'PLAYER_ENTERING_WORLD' then
		hasValidPlayer = true
	elseif event == 'PLAYER_LEAVING_WORLD' then
		hasValidPlayer = false
	elseif event == 'PLAYER_SPECIALIZATION_CHANGED' then
		wipe(cachedVisibility)
	elseif event == 'PLAYER_REGEN_ENABLED' or event == 'PLAYER_REGEN_DISABLED' then
		wipe(cachedVisibility)

		if cachedPriority then
			wipe(cachedPriority)
		end
	end
end)

local function VisibilityInfo(spellId)
	return SpellGetVisibilityInfo(spellId, UnitAffectingCombat('player') and 'RAID_INCOMBAT' or 'RAID_OUTOFCOMBAT')
end

local function CachedVisibility(spellId)
	local cached = cachedVisibility[spellId]
	if cached then -- send the cache
		return unpack(cached)
	end

	local hasCustom, alwaysShowMine, showForMySpec = VisibilityInfo(spellId)
	if hasValidPlayer then -- only cache when the player is valid
		cachedVisibility[spellId] = { hasCustom, alwaysShowMine, showForMySpec }
	end

	return hasCustom, alwaysShowMine, showForMySpec
end

local function CheckIsMine(sourceUnit)
	return sourceUnit == 'player' or sourceUnit == 'pet' or sourceUnit == 'vehicle'
end

local function AllowAura(spellId, sourceUnit)
	local hasCustom, alwaysShowMine, showForMySpec = CachedVisibility(spellId)
	if hasCustom then -- whether the spell visibility should be customized
		return showForMySpec or (alwaysShowMine and CheckIsMine(sourceUnit))
	end

	return true -- if hasCustom is false, it means always display
end

local function AuraIsPriority(spellId)
	if AlwaysAllow[spellId] then
		return true
	end

	if cachedPriority then
		if cachedPriority[spellId] == nil then
			cachedPriority[spellId] = SpellIsPriorityAura(spellId)
		end

		return cachedPriority[spellId]
	end
end

local function CouldDisplayAura(frame, event, unit, aura)
	if aura.isNameplateOnly then
		return frame.isNamePlate
	elseif aura.isBossAura or AuraIsPriority(aura.spellId) then
		return true
	elseif aura.isHarmful or aura.isHelpful then
		return AllowAura(aura.spellId, aura.sourceUnit)
	end

	return false
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

	unitAuraInfo[auraInstanceID] = (which ~= 'remove' and aura) or nil

	local allow = (which == 'remove') or not aura or not showFunc or showFunc(frame, event, unit, aura)

	for filter, filtered in next, auraFiltered do
		UpdateFilter(which, filter, filtered, allow, unit, auraInstanceID, aura)
	end

	return allow
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

local function ProcessAura(frame, event, unit, showFunc, token, ...)
	local numSlots = select('#', ...)
	for i = 1, numSlots do
		local slot = select(i, ...)
		local aura = GetAuraDataBySlot(unit, slot)
		if aura then
			TryAdded('add', frame, event, unit, showFunc, aura)
		end
	end

	return token
end

local function ProcessTokens(frame, event, unit, showFunc, token, ...)
	repeat token = ProcessAura(frame, event, unit, showFunc, token, ...)
	until not token
end

local function ProcessExisting(frame, event, unit, showFunc)
	ProcessTokens(frame, event, unit, showFunc, GetAuraSlots(unit, 'HELPFUL'))
	ProcessTokens(frame, event, unit, showFunc, GetAuraSlots(unit, 'HARMFUL'))
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
	elseif hasValidPlayer and event ~= 'ElvUI_UpdateAllElements' then -- skip in this case
		oUF:ClearUnitAuraInfo(unit) -- clear these since we cant verify it

		ProcessExisting(frame, event, unit, showFunc) -- we need to collect full data here
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

	return ShouldSkipAura(frame, event, unit, updateInfo, showFunc or CouldDisplayAura)
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
