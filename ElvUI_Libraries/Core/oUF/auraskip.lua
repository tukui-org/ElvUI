local _, ns = ...
local oUF = ns.oUF

local next = next
local wipe = wipe
local select = select
local unpack = unpack

local SpellIsSelfBuff = SpellIsSelfBuff
local SpellIsPriorityAura = SpellIsPriorityAura
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = SpellGetVisibilityInfo

local GetAuraSlots = C_UnitAuras.GetAuraSlots
local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID

local hasValidPlayer = false
local cachedVisibility = {}
local cachedSelfBuffChecks = {}
local cachedPriority = SpellIsPriorityAura and {}
local auraInfo = {}

oUF.AuraInfo = auraInfo -- export it

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
		wipe(cachedSelfBuffChecks)

		if cachedPriority then
			wipe(cachedPriority)
		end
	end
end)

local function VisibilityInfo(spellId)
	return SpellGetVisibilityInfo(spellId, UnitAffectingCombat('player') and 'RAID_INCOMBAT' or 'RAID_OUTOFCOMBAT')
end

local function CachedVisibility(spellId)
	if cachedVisibility[spellId] == nil then
		if not hasValidPlayer then -- Don't cache the info if the player is not valid since we didn't get a valid result
			return VisibilityInfo(spellId)
		else
			cachedVisibility[spellId] = { VisibilityInfo(spellId) }
		end
	end

	return unpack(cachedVisibility[spellId])
end

local function CheckIsSelfBuff(spellId)
	if cachedSelfBuffChecks[spellId] == nil then
		cachedSelfBuffChecks[spellId] = SpellIsSelfBuff(spellId)
	end

	return cachedSelfBuffChecks[spellId]
end

local function CheckIsMine(sourceUnit)
	return sourceUnit == 'player' or sourceUnit == 'pet' or sourceUnit == 'vehicle'
end

local function AllowAura(spellId, sourceUnit, canApplyHelpful)
	local isMine = CheckIsMine(sourceUnit)
	local hasCustom, alwaysShowMine, showForMySpec = CachedVisibility(spellId)
	local isCustom = hasCustom and (showForMySpec or (alwaysShowMine and isMine))

	if canApplyHelpful then
		return isCustom or (isMine and not CheckIsSelfBuff(spellId))
	else
		return isCustom or true
	end
end

local function AuraIsPriority(spellId)
	if not spellId then
		return false
	end

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
		return AllowAura(aura.spellId, aura.sourceUnit, aura.isHelpful and aura.canApplyAura)
	end

	return false
end

local function TryAdded(frame, unit, aura)
	if not aura.auraInstanceID then return end

	local unitAura = auraInfo[unit]
	unitAura[aura.auraInstanceID] = aura
end

local empty = {} -- incase of failure
local function TryUpdated(frame, unit, auraInstanceID)
	local unitAura = auraInfo[unit]

	local aura = GetAuraDataByAuraInstanceID(unit, auraInstanceID) -- get new info
	unitAura[auraInstanceID] = aura  -- update the data

	return aura or empty
end

local function TryRemove(frame, unit, auraInstanceID)
	local unitAura = auraInfo[unit]
	local aura = unitAura[auraInstanceID]

	unitAura[auraInstanceID] = nil -- remove it

	return aura or true
end

local function TrySkipAura(frame, event, unit, shouldDisplay, tryFunc, auras)
	if not auras then
		return true
	end

	local skip = true
	for _, value in next, auras do
		local aura = tryFunc(frame, unit, value) -- collect the aura from updated or check if a preexisting was removed
		if aura == true then -- an aura that existed during load was removed
			skip = false -- this can also happen with nameplates that spawn in and an aura is removed
		elseif skip then -- check skip status
			skip = not shouldDisplay(frame, event, unit, aura or value)
		end
	end

	return skip
end

local function ProcessAura(frame, unit, token, ...)
	local numSlots = select('#', ...)
	for i = 1, numSlots do
		local slot = select(i, ...)
		local aura = GetAuraDataBySlot(unit, slot)
		if aura then
			TryAdded(frame, unit, aura)
		end
	end

	return token
end

local function ProcessTokens(frame, unit, token, ...)
	repeat token = ProcessAura(frame, unit, token, ...)
	until not token
end

local function ProcessExisting(frame, unit)
	ProcessTokens(frame, unit, GetAuraSlots(unit, 'HELPFUL'))
	ProcessTokens(frame, unit, GetAuraSlots(unit, 'HARMFUL'))
end

local function ShouldSkipAura(frame, event, unit, updateInfo, shouldDisplay)
	if not auraInfo[unit] then
		auraInfo[unit] = {}
	end

	if event ~= 'UNIT_AURA' or not updateInfo or updateInfo.isFullUpdate then
		wipe(auraInfo[unit]) -- clear this since we cant verify it

		ProcessExisting(frame, unit) -- we need to collect full data here

		return false -- this is from some other thing
	end

	local added = TrySkipAura(frame, event, unit, shouldDisplay, TryAdded, updateInfo.addedAuras)
	local updated = TrySkipAura(frame, event, unit, shouldDisplay, TryUpdated, updateInfo.updatedAuraInstanceIDs)
	local removed = TrySkipAura(frame, event, unit, shouldDisplay, TryRemove, updateInfo.removedAuraInstanceIDs)

	if not added then return false end -- a new aura has appeared
	if not updated then return false end -- an existing aura has been altered
	if not removed then return false end -- an aura has been yeeted into the abyss

	return true -- who are you
end

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
function oUF:ShouldSkipAuraUpdate(frame, event, unit, updateInfo, shouldDisplay)
	if not unit or (frame.unit and frame.unit ~= unit) then return true end

	return ShouldSkipAura(frame, event, unit, updateInfo, shouldDisplay or CouldDisplayAura)
end
