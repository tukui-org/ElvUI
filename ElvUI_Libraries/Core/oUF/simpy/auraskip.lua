local _, ns = ...
local oUF = ns.oUF

-- ShouldSkipAuraUpdate by Blizzard (implemented and heavily modified by Simpy)

local wipe = wipe
local unpack = unpack
local ipairs = ipairs

local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local SpellIsPriorityAura = SpellIsPriorityAura
local UnitAffectingCombat = UnitAffectingCombat

local hasValidPlayer = false
local cachedVisibility = {}
local cachedPriority = {}

local AlwaysAllow = { -- spells could get stuck but it's very rare, this table is for that
	[335904] = true -- Doom Winds: Unable to gain effects of Doom Winds
}

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('PLAYER_LEAVING_WORLD')

if oUF.isRetail then
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
		wipe(cachedPriority)
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

local function AllowAura(spellId)
	local hasCustom, alwaysShowMine, showForMySpec = CachedVisibility(spellId)
	return (not hasCustom) or alwaysShowMine or showForMySpec
end

local function AuraIsPriority(spellId)
	if AlwaysAllow[spellId] then
		return true
	end

	if cachedPriority[spellId] == nil then
		cachedPriority[spellId] = SpellIsPriorityAura(spellId)
	end

	return cachedPriority[spellId]
end

local function CouldDisplayAura(frame, event, unit, auraInfo)
	if auraInfo.isNameplateOnly then
		return frame.isNamePlate
	elseif auraInfo.isBossAura or AuraIsPriority(auraInfo.spellId) then
		return true
	elseif auraInfo.isHarmful or auraInfo.isHelpful then
		return AllowAura(auraInfo.spellId)
	end

	return false
end

local function ShouldSkipAura(frame, event, unit, fullUpdate, updatedAuras, relevantFunc, ...)
	if fullUpdate or fullUpdate == nil then
		return false
	elseif updatedAuras and relevantFunc then
		for _, auraInfo in ipairs(updatedAuras) do
			if relevantFunc(frame, event, unit, auraInfo, ...) then
				return false
			end
		end

		return true
	end
end

function oUF:ShouldSkipAuraUpdate(frame, event, unit, fullUpdate, updatedAuras, relevantFunc)
	return (not unit or frame.unit ~= unit) or ShouldSkipAura(frame, event, unit, fullUpdate, updatedAuras, relevantFunc or CouldDisplayAura)
end
