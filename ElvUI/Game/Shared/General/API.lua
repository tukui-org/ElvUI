local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')
local ElvUF = E.oUF

local _G = _G
local setmetatable = setmetatable
local hooksecurefunc = hooksecurefunc
local type, pairs, unpack, strmatch = type, pairs, unpack, strmatch
local wipe, max, next, tinsert, date, time = wipe, max, next, tinsert, date, time
local strlen, tonumber, tostring = strlen, tonumber, tostring

local CopyTable = CopyTable
local CreateFrame = CreateFrame
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local GetGameTime = GetGameTime
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetPartyAssignment = GetPartyAssignment
local GetServerTime = GetServerTime
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpecializationInfoForSpecID = C_SpecializationInfo.GetSpecializationInfoForSpecID or GetSpecializationInfoForSpecID
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local IsRestrictedAccount = IsRestrictedAccount
local IsTrialAccount = IsTrialAccount
local IsVeteranTrialAccount = IsVeteranTrialAccount
local IsWargame = IsWargame
local IsXPUserDisabled = IsXPUserDisabled
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local UIParent = UIParent
local UIParentLoadAddOn = UIParentLoadAddOn
local UnitClassBase = UnitClassBase
local UnitClassification = UnitClassification
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitIsMercenary = UnitIsMercenary
local UnitIsPlayer = UnitIsPlayer
local UnitIsVisible = UnitIsVisible
local UnitSex = UnitSex
local UnitThreatSituation = UnitThreatSituation

local WorldFrame = WorldFrame
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetWatchedFactionData = C_Reputation.GetWatchedFactionData
local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve

local ShouldUnitIdentityBeSecret = C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret
local GetColorDataForItemQuality = ColorManager and ColorManager.GetColorDataForItemQuality
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local StoreEnabled = C_StorePublic.IsEnabled
local GetClassInfo = C_CreatureInfo.GetClassInfo
local C_TooltipInfo_GetUnit = C_TooltipInfo and C_TooltipInfo.GetUnit
local C_TooltipInfo_GetHyperlink = C_TooltipInfo and C_TooltipInfo.GetHyperlink
local C_TooltipInfo_GetInventoryItem = C_TooltipInfo and C_TooltipInfo.GetInventoryItem
local C_MountJournal_GetMountIDs = C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local C_PvP_IsRatedBattleground = C_PvP.IsRatedBattleground
local C_Spell_GetSpellCharges = C_Spell.GetSpellCharges
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local LuaCurveTypeStep = Enum.LuaCurveType and Enum.LuaCurveType.Step

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local FACTION_ALLIANCE = FACTION_ALLIANCE
local FACTION_HORDE = FACTION_HORDE
local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP

local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
local UIErrorsFrame = UIErrorsFrame
-- GLOBALS: ElvDB

local DebuffColors = E.Libs.Dispel:GetDebuffTypeColor()
local DispelTypes = E.Libs.Dispel:GetMyDispelTypes()
local DispelIndexes = ElvUF.Enum.DispelType

E.MountIDs = {}
E.MountText = {}
E.GroupRoles = {}
E.GroupUnitsByRole = {
	TANK = {},
	HEALER = {},
	DAMAGER = {},
	NONE = {}
}

E.SpecInfoBySpecClass = {}
E.SpecInfoBySpecID = {}

E.ThreatPets = {
	[61146] = true,
	[103822] = true,
	[95072] = true,
	[61056] = true,
}

E.SpecByClass = {
	DEATHKNIGHT	= { 250, 251, 252 },
	DEMONHUNTER	= { 577, 581, 1480 },
	DRUID		= { 102, 103, 104, 105 },
	EVOKER		= { 1467, 1468, 1473},
	HUNTER		= { 253, 254, 255 },
	MAGE		= { 62, 63, 64 },
	MONK		= { 268, 270, 269 },
	PALADIN		= { 65, 66, 70 },
	PRIEST		= { 256, 257, 258 },
	ROGUE		= { 259, 260, 261 },
	SHAMAN		= { 262, 263, 264 },
	WARLOCK		= { 265, 266, 267 },
	WARRIOR		= { 71, 72, 73 },
}

E.ClassName = {
	DEATHKNIGHT	= 'Death Knight',
	DEMONHUNTER	= 'Demon Hunter',
	DRUID		= 'Druid',
	EVOKER		= 'Evoker',
	HUNTER		= 'Hunter',
	MAGE		= 'Mage',
	MONK		= 'Monk',
	PALADIN		= 'Paladin',
	PRIEST		= 'Priest',
	ROGUE		= 'Rogue',
	SHAMAN		= 'Shaman',
	WARLOCK		= 'Warlock',
	WARRIOR		= 'Warrior',
}

E.SpecName = {
	[250]	= 'Blood',
	[251]	= 'Frost',
	[252]	= 'Unholy',
	[577]	= 'Havoc',
	[581]	= 'Vengeance',
	[1480]	= 'Devourer',
	[102]	= 'Balance',
	[103]	= 'Feral',
	[104]	= 'Guardian',
	[105]	= 'Restoration',
	[1467]	= 'Devastation',
	[1468]	= 'Preservation',
	[1473]	= 'Augmentation',
	[253]	= 'Beast Mastery',
	[254]	= 'Marksmanship',
	[255]	= 'Survival',
	[62]	= 'Arcane',
	[63]	= 'Fire',
	[64]	= 'Frost',
	[268]	= 'Brewmaster',
	[270]	= 'Mistweaver',
	[269]	= 'Windwalker',
	[65]	= 'Holy',
	[66]	= 'Protection',
	[70]	= 'Retribution',
	[256]	= 'Discipline',
	[257]	= 'Holy',
	[258]	= 'Shadow',
	[259]	= 'Assassination',
	[260]	= 'Combat',
	[261]	= 'Subtlety',
	[262]	= 'Elemental',
	[263]	= 'Enhancement',
	[264]	= 'Restoration',
	[265]	= 'Affliction',
	[266]	= 'Demonology',
	[267]	= 'Destruction',
	[71]	= 'Arms',
	[72]	= 'Fury',
	[73]	= 'Protection',
}

-- Midnight SECRET field support
local secretFields = {
	duration = true,
	expirationTime = true,
	sourceUnit = true,
}

function E:IsSecretValue(value)
	return value == 42
end

function E:GetSafeUnitAura(unit, index, filter)
	local ok, data = pcall(GetAuraDataByIndex, unit, index, filter)
	if not ok or not data then return nil end

	for key in next, secretFields do
		local v = data[key]
		if v ~= nil and E:IsSecretValue(v) then
			data[key] = nil
		end
	end

	return data
end

function E:GetSafeAuraField(data, key)
	if not data or not key then return nil end
	local ok, value = pcall(function() return data[key] end)
	if not ok then return nil end
	if value ~= nil and E:IsSecretValue(value) then return nil end
	return value
end

function E:GetSafeAuraData(unit, index, filter)
	local data = E:GetSafeUnitAura(unit, index, filter)
	if not data then return end

	local name = E:GetSafeAuraField(data, 'name') or UNKNOWN
	local icon = E:GetSafeAuraField(data, 'icon')
	local count = E:GetSafeAuraField(data, 'applications') or 0
	local duration = E:GetSafeAuraField(data, 'duration') or 0
	local expirationTime = E:GetSafeAuraField(data, 'expirationTime') or 0
	local sourceUnit = E:GetSafeAuraField(data, 'sourceUnit')
	local isStealable = E:GetSafeAuraField(data, 'isStealable')
	local spellID = E:GetSafeAuraField(data, 'spellId')

	data.isSecret = not name or name == UNKNOWN or not spellID

	return name, icon, count, nil, duration, expirationTime, sourceUnit, isStealable, nil, spellID
end

function E:NormalizeAuraData(data)
	if not data then return end

	local aura = {
		name = E:GetSafeAuraField(data, 'name') or UNKNOWN,
		icon = E:GetSafeAuraField(data, 'icon'),
		count = E:GetSafeAuraField(data, 'applications') or 0,
		duration = E:GetSafeAuraField(data, 'duration'),
		expirationTime = E:GetSafeAuraField(data, 'expirationTime'),
		sourceUnit = E:GetSafeAuraField(data, 'sourceUnit'),
		spellID = E:GetSafeAuraField(data, 'spellId'),
		isStealable = E:GetSafeAuraField(data, 'isStealable'),
	}

	aura.isSecret = not aura.name or aura.name == UNKNOWN or not aura.spellID
	return aura
end

function E:UpdateColorCurve(which, data)
	if not data then return end

	local colors = ElvUF.colors.dispel
	for key, index in next, DispelIndexes do
		data:AddPoint(index, ((which == 'debuffs' or key ~= 'None') and colors and colors[key]) or E.media.bordercolor)
	end
end

function E:UpdateColorCurves()
	local curves = E.ColorCurves
	for which, data in next, curves do
		if not data then
			data = CreateColorCurve()
			data:SetType(LuaCurveTypeStep)

			curves[which] = data
		end

		E:UpdateColorCurve(which, data)
	end
end
