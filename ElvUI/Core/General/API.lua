------------------------------------------------------------------------
-- Collection of functions that can be used in multiple places
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')
local LCS = E.Libs.LCS

local _G = _G
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack
local wipe, max, next, tinsert, date, time = wipe, max, next, tinsert, date, time
local strfind, strlen, tonumber, tostring = strfind, strlen, tonumber, tostring
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetBattlefieldArenaFaction = GetBattlefieldArenaFaction
local GetClassInfo = GetClassInfo
local GetGameTime = GetGameTime
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetServerTime = GetServerTime
local GetSpecializationInfoForSpecID = GetSpecializationInfoForSpecID
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
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
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsMercenary = UnitIsMercenary
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit

local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local UnpackAuraData = AuraUtil and AuraUtil.UnpackAuraData
local UnitAura = UnitAura

local GetSpecialization = (E.Classic or E.Wrath) and LCS.GetSpecialization or GetSpecialization
local GetSpecializationInfo = (E.Classic or E.Wrath) and LCS.GetSpecializationInfo or GetSpecializationInfo

local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded

local C_AddOns_GetAddOnEnableState = C_AddOns and C_AddOns.GetAddOnEnableState
local GetAddOnEnableState = GetAddOnEnableState -- eventually this will be on C_AddOns and args swap

local C_TooltipInfo_GetUnit = C_TooltipInfo and C_TooltipInfo.GetUnit
local C_TooltipInfo_GetHyperlink = C_TooltipInfo and C_TooltipInfo.GetHyperlink
local C_TooltipInfo_GetInventoryItem = C_TooltipInfo and C_TooltipInfo.GetInventoryItem
local C_MountJournal_GetMountIDs = C_MountJournal and C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = C_MountJournal and C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = C_MountJournal and C_MountJournal.GetMountInfoExtraByID
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local C_PvP_IsRatedBattleground = C_PvP and C_PvP.IsRatedBattleground

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local FACTION_ALLIANCE = FACTION_ALLIANCE
local FACTION_HORDE = FACTION_HORDE
local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP

local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
local UIErrorsFrame = UIErrorsFrame
-- GLOBALS: ElvDB, ElvUF

local DebuffColors = E.Libs.Dispel:GetDebuffTypeColor()

E.MountIDs = {}
E.MountText = {}
E.MountDragons = {}

E.SpecInfoBySpecClass = {} -- ['Protection Warrior'] = specInfo (table)
E.SpecInfoBySpecID = {} -- [250] = specInfo (table)

E.SpecByClass = {
	DEATHKNIGHT	= { 250, 251, 252 },
	DEMONHUNTER	= { 577, 581 },
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

E.ClassName = { -- english locale
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

E.SpecName = { -- english locale
	-- Death Knight
	[250]	= 'Blood',
	[251]	= 'Frost',
	[252]	= 'Unholy',
	-- Demon Hunter
	[577]	= 'Havoc',
	[581]	= 'Vengeance',
	-- Druids
	[102]	= 'Balance',
	[103]	= 'Feral',
	[104]	= 'Guardian',
	[105]	= 'Restoration',
	-- Evoker
	[1467]	= 'Devastation',
	[1468]	= 'Preservation',
	[1473]	= 'Augmentation',
	-- Hunter
	[253]	= 'Beast Mastery',
	[254]	= 'Marksmanship',
	[255]	= 'Survival',
	-- Mage
	[62]	= 'Arcane',
	[63]	= 'Fire',
	[64]	= 'Frost',
	-- Monk
	[268]	= 'Brewmaster',
	[270]	= 'Mistweaver',
	[269]	= 'Windwalker',
	-- Paladin
	[65]	= 'Holy',
	[66]	= 'Protection',
	[70]	= 'Retribution',
	-- Priest
	[256]	= 'Discipline',
	[257]	= 'Holy',
	[258]	= 'Shadow',
	-- Rogue
	[259]	= 'Assasination',
	[260]	= 'Combat',
	[261]	= 'Sublety',
	-- Shaman
	[262]	= 'Elemental',
	[263]	= 'Enhancement',
	[264]	= 'Restoration',
	-- Walock
	[265]	= 'Affliction',
	[266]	= 'Demonology',
	[267]	= 'Destruction',
	-- Warrior
	[71]	= 'Arms',
	[72]	= 'Fury',
	[73]	= 'Protection',
}

function E:GetDateTime(localTime, unix)
	if not localTime then -- try to properly handle realm time
		local dateTable = date('*t', GetServerTime())

		local hours, minutes = GetGameTime() -- realm time since it doesnt match ServerTimeLocal
		dateTable.hour = hours
		dateTable.min = minutes

		if unix then
			return time(dateTable)
		else
			return dateTable
		end
	elseif unix then
		return GetServerTime()
	else
		return date('*t', GetServerTime())
	end
end

function E:ClassColor(class, usePriestColor)
	if not class then return end

	local color = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class]) or _G.RAID_CLASS_COLORS[class]
	if type(color) ~= 'table' then return end

	if not color.colorStr then
		color.colorStr = E:RGBToHex(color.r, color.g, color.b, 'ff')
	elseif strlen(color.colorStr) == 6 then
		color.colorStr = 'ff'..color.colorStr
	end

	if usePriestColor and class == 'PRIEST' and tonumber(color.colorStr, 16) > tonumber(E.PriestColors.colorStr, 16) then
		return E.PriestColors
	else
		return color
	end
end

function E:InverseClassColor(class, usePriestColor, forceCap)
	local color = E:CopyTable({}, E:ClassColor(class, usePriestColor))
	local capColor = class == 'PRIEST' or forceCap

	color.r = capColor and max(1-color.r,0.35) or (1-color.r)
	color.g = capColor and max(1-color.g,0.35) or (1-color.g)
	color.b = capColor and max(1-color.b,0.35) or (1-color.b)
	color.colorStr = E:RGBToHex(color.r, color.g, color.b, 'ff')

	return color
end

do -- other non-english locales require this
	E.UnlocalizedClasses = {}
	for k, v in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do E.UnlocalizedClasses[v] = k end
	for k, v in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do E.UnlocalizedClasses[v] = k end

	function E:UnlocalizedClassName(className)
		return E.UnlocalizedClasses[className]
	end
end

do
	local essenceTextureID = 2975691
	function E:ScanTooltipTextures()
		local tt = E.ScanTooltip

		if not tt.gems then
			tt.gems = {}
		else
			wipe(tt.gems)
		end

		if not tt.essences then
			tt.essences = {}
		else
			for _, essences in pairs(tt.essences) do
				wipe(essences)
			end
		end

		local step = 1
		for i = 1, 10 do
			local tex = _G['ElvUI_ScanTooltipTexture'..i]
			local texture = tex and tex:IsShown() and tex:GetTexture()
			if texture then
				if texture == essenceTextureID then
					local selected = (tt.gems[i-1] ~= essenceTextureID and tt.gems[i-1]) or nil
					if not tt.essences[step] then tt.essences[step] = {} end

					tt.essences[step][1] = selected			--essence texture if selected or nil
					tt.essences[step][2] = tex:GetAtlas()	--atlas place 'tooltip-heartofazerothessence-major' or 'tooltip-heartofazerothessence-minor'
					tt.essences[step][3] = texture			--border texture placed by the atlas
					--`CollectEssenceInfo` will add 4 (hex quality color) and 5 (essence name)

					step = step + 1

					if selected then
						tt.gems[i-1] = nil
					end
				else
					tt.gems[i] = texture
				end
			end
		end

		return tt.gems, tt.essences
	end
end

do
	function E:GetAuraData(unitToken, index, filter)
		if E.Retail then
			return UnpackAuraData(GetAuraDataByIndex(unitToken, index, filter))
		else
			return UnitAura(unitToken, index, filter)
		end
	end

	local function FindAura(key, value, unit, index, filter, ...)
		local name, _, _, _, _, _, _, _, _, spellID = ...

		if not name then
			return
		elseif key == 'name' and value == name then
			return ...
		elseif key == 'spellID' and value == spellID then
			return ...
		else
			index = index + 1
			return FindAura(key, value, unit, index, filter, E:GetAuraData(unit, index, filter))
		end
	end

	function E:GetAuraByID(unit, spellID, filter)
		return FindAura('spellID', spellID, unit, 1, filter, E:GetAuraData(unit, 1, filter))
	end

	function E:GetAuraByName(unit, name, filter)
		return FindAura('name', name, unit, 1, filter, E:GetAuraData(unit, 1, filter))
	end
end

function E:GetThreatStatusColor(status, nothreat)
	local color = ElvUF.colors.threat[status]
	if color then
		return color.r, color.g, color.b, color.a or 1
	elseif nothreat then
		if status == -1 then -- how or why?
			return 1, 1, 1, 1
		else
			return .7, .7, .7, 1
		end
	end
end

function E:GetPlayerRole()
	local role = (E.Retail or E.Wrath) and UnitGroupRolesAssigned('player') or 'NONE'
	return (role ~= 'NONE' and role) or E.myspecRole or 'NONE'
end

function E:CheckRole()
	E.myspec = GetSpecialization()

	if E.myspec then
		if E.Retail then
			E.myspecID, E.myspecName, E.myspecDesc, E.myspecIcon, E.myspecRole = GetSpecializationInfo(E.myspec)
		else -- they add background
			E.myspecID, E.myspecName, E.myspecDesc, E.myspecIcon, E.myspecBackground, E.myspecRole = GetSpecializationInfo(E.myspec)
		end
	end

	E.myrole = E:GetPlayerRole()
end

function E:IsDispellableByMe(debuffType)
	return E.Libs.Dispel:IsDispellableByMe(debuffType)
end

function E:UpdateDispelColors()
	local colors = E.db.general.debuffColors
	for debuffType, db in next, colors do
		local color = DebuffColors[debuffType]
		if color then
			E:UpdateClassColor(db)
			color.r, color.g, color.b = db.r, db.g, db.b
		end
	end
end

function E:UpdateDispelColor(debuffType, r, g, b)
	local color = DebuffColors[debuffType]
	if color then
		color.r, color.g, color.b = r, g, b
	end

	local db = E.db.general.debuffColors[debuffType]
	if db then
		db.r, db.g, db.b = r, g, b
	end
end

do
	local function SetOriginalHeight(f)
		if InCombatLockdown() then
			E:RegisterEventForObject('PLAYER_REGEN_ENABLED', SetOriginalHeight, SetOriginalHeight)
			return
		end

		E.UIParent:SetHeight(E.UIParent.origHeight)

		if f == SetOriginalHeight then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', SetOriginalHeight, SetOriginalHeight)
		end
	end

	local function SetModifiedHeight(f)
		if InCombatLockdown() then
			E:RegisterEventForObject('PLAYER_REGEN_ENABLED', SetModifiedHeight, SetModifiedHeight)
			return
		end

		E.UIParent:SetHeight(E.UIParent.origHeight - (_G.OrderHallCommandBar:GetHeight() + E.Border))

		if f == SetModifiedHeight then
			E:UnregisterEventForObject('PLAYER_REGEN_ENABLED', SetModifiedHeight, SetModifiedHeight)
		end
	end

	--This function handles disabling of OrderHall Bar or resizing of ElvUIParent if needed
	function E:HandleCommandBar()
		if E.global.general.commandBarSetting == 'DISABLED' then
			_G.OrderHallCommandBar:UnregisterAllEvents()
			_G.OrderHallCommandBar:SetScript('OnShow', _G.OrderHallCommandBar.Hide)
			_G.OrderHallCommandBar:Hide()
			UIParent:UnregisterEvent('UNIT_AURA') --Only used for OrderHall Bar
		elseif E.global.general.commandBarSetting == 'ENABLED_RESIZEPARENT' then
			_G.OrderHallCommandBar:HookScript('OnShow', SetModifiedHeight)
			_G.OrderHallCommandBar:HookScript('OnHide', SetOriginalHeight)
		end
	end
end

do
	local Masque = E.Libs.Masque
	local MasqueGroupState = {}
	local MasqueGroupToTableElement = {
		['ActionBars'] = {'actionbar', 'actionbars'},
		['Pet Bar'] = {'actionbar', 'petBar'},
		['Stance Bar'] = {'actionbar', 'stanceBar'},
		['Buffs'] = {'auras', 'buffs'},
		['Debuffs'] = {'auras', 'debuffs'},
	}

	function E:MasqueCallback(Group, _, _, _, _, Disabled)
		if not E.private then return end
		local element = MasqueGroupToTableElement[Group]
		if element then
			if Disabled then
				if E.private[element[1]].masque[element[2]] and MasqueGroupState[Group] == 'enabled' then
					E.private[element[1]].masque[element[2]] = false
					E:StaticPopup_Show('CONFIG_RL')
				end
				MasqueGroupState[Group] = 'disabled'
			else
				MasqueGroupState[Group] = 'enabled'
			end
		end
	end

	if Masque then
		Masque:Register('ElvUI', E.MasqueCallback)
	end
end

function E:Dump(object, inspect)
	if C_AddOns_GetAddOnEnableState then
		if C_AddOns_GetAddOnEnableState('Blizzard_DebugTools', E.myname) == 0 then
			E:Print('Blizzard_DebugTools is disabled.')
			return
		end
	elseif GetAddOnEnableState(E.myname, 'Blizzard_DebugTools') == 0 then
		E:Print('Blizzard_DebugTools is disabled.')
		return
	end

	local debugTools = IsAddOnLoaded('Blizzard_DebugTools')
	if not debugTools then UIParentLoadAddOn('Blizzard_DebugTools') end

	if inspect then
		local tableType = type(object)
		if tableType == 'table' then
			_G.DisplayTableInspectorWindow(object)
		else
			E:Print('Failed: ', tostring(object), ' is type: ', tableType,'. Requires table object.')
		end
	else
		_G.DevTools_Dump(object)
	end
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames, E.AddNonPetBattleFrames)
		return
	elseif E:IsEventRegisteredForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames) then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.AddNonPetBattleFrames, E.AddNonPetBattleFrames)
	end

	for object, data in pairs(E.FrameLocks) do
		local parent, strata
		if type(data) == 'table' then
			parent, strata = data.parent, data.strata
		elseif data == true then
			parent = UIParent
		end

		local obj = _G[object] or object
		obj:SetParent(parent)
		if strata then
			obj:SetFrameStrata(strata)
		end
	end
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then
		E:RegisterEventForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames, E.RemoveNonPetBattleFrames)
		return
	elseif E:IsEventRegisteredForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames) then
		E:UnregisterEventForObject('PLAYER_REGEN_DISABLED', E.RemoveNonPetBattleFrames, E.RemoveNonPetBattleFrames)
	end

	for object in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(E.HiddenFrame)
	end
end

function E:RegisterPetBattleHideFrames(object, originalParent, originalStrata)
	if not object or not originalParent then
		E:Print('Error. Usage: RegisterPetBattleHideFrames(object, originalParent, originalStrata)')
		return
	end

	object = _G[object] or object

	--If already doing pokemon
	if E.Retail and C_PetBattles_IsInBattle() then
		object:SetParent(E.HiddenFrame)
	end

	E.FrameLocks[object] = {
		parent = originalParent,
		strata = originalStrata or nil,
	}
end

function E:UnregisterPetBattleHideFrames(object)
	if not object then
		E:Print('Error. Usage: UnregisterPetBattleHideFrames(object)')
		return
	end

	object = _G[object] or object

	--Check if object was registered to begin with
	if not E.FrameLocks[object] then return end

	--Change parent of object back to original parent
	local originalParent = E.FrameLocks[object].parent
	if originalParent then
		object:SetParent(originalParent)
	end

	--Change strata of object back to original
	local originalStrata = E.FrameLocks[object].strata
	if originalStrata then
		object:SetFrameStrata(originalStrata)
	end

	--Remove object from table
	E.FrameLocks[object] = nil
end

function E:RegisterObjectForVehicleLock(object, originalParent)
	if not object or not originalParent then
		E:Print('Error. Usage: RegisterObjectForVehicleLock(object, originalParent)')
		return
	end

	object = _G[object] or object
	--Entering/Exiting vehicles will often happen in combat.
	--For this reason we cannot allow protected objects.
	if object.IsProtected and object:IsProtected() then
		E:Print('Error. Object is protected and cannot be changed in combat.')
		return
	end

	--Check if we are already in a vehicles
	if (E.Retail or E.Wrath) and UnitHasVehicleUI('player') then
		object:SetParent(E.HiddenFrame)
	end

	--Add object to table
	E.VehicleLocks[object] = originalParent
end

function E:UnregisterObjectForVehicleLock(object)
	if not object then
		E:Print('Error. Usage: UnregisterObjectForVehicleLock(object)')
		return
	end

	object = _G[object] or object
	--Check if object was registered to begin with
	if not E.VehicleLocks[object] then
		return
	end

	--Change parent of object back to original parent
	local originalParent = E.VehicleLocks[object]
	if originalParent then
		object:SetParent(originalParent)
	end

	--Remove object from table
	E.VehicleLocks[object] = nil
end

function E:EnterVehicleHideFrames(_, unit)
	if unit ~= 'player' then return end
	for object in pairs(E.VehicleLocks) do
		object:SetParent(E.HiddenFrame)
	end
end

function E:ExitVehicleShowFrames(_, unit)
	if unit ~= 'player' then return end
	for object, originalParent in pairs(E.VehicleLocks) do
		object:SetParent(originalParent)
	end
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	E:CheckRole()

	if initLogin or not ElvDB.DisabledAddOns then
		ElvDB.DisabledAddOns = {}
	end

	if initLogin or isReload then
		E:CheckIncompatible()
	end

	if not E.MediaUpdated then
		E:UpdateMedia()
		E.MediaUpdated = true
	end

	-- Blizzard will set this value to int(60/CVar cameraDistanceMax)+1 at logout if it is manually set higher than that
	if not E.Retail and E.db.general.lockCameraDistanceMax then
		E:SetCVar('cameraDistanceMaxZoomFactor', E.db.general.cameraDistanceMax)
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'pvp' then
		E.BGTimer = E:ScheduleRepeatingTimer('RequestBGInfo', 5)
		E:RequestBGInfo()
	elseif E.BGTimer then
		E:CancelTimer(E.BGTimer)
		E.BGTimer = nil
	end
end

function E:PLAYER_REGEN_ENABLED()
	if E.ShowOptions then
		E:ToggleOptions()

		E.ShowOptions = nil
	end
end

do
	local function NoCombat()
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1.0, 0.2, 0.2, 1.0)
	end

	function E:PLAYER_REGEN_DISABLED()
		local wasShown

		if IsAddOnLoaded('ElvUI_Options') then
			local ACD = E.Libs.AceConfigDialog
			if ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI then
				ACD:Close('ElvUI')
				wasShown = true
			end
		end

		if E.CreatedMovers then
			for name in pairs(E.CreatedMovers) do
				local mover = _G[name]
				if mover and mover:IsShown() then
					mover:Hide()
					wasShown = true
				end
			end
		end

		if wasShown then
			NoCombat()
		end
	end

	function E:AlertCombat()
		local combat = InCombatLockdown()
		if combat then NoCombat() end
		return combat
	end
end

function E:XPIsUserDisabled()
	return E.Retail and IsXPUserDisabled()
end

function E:XPIsTrialMax()
	return E.Retail and (IsRestrictedAccount() or IsTrialAccount() or IsVeteranTrialAccount()) and (E.myLevel == 20)
end

function E:XPIsLevelMax()
	return IsLevelAtEffectiveMaxLevel(E.mylevel) or E:XPIsUserDisabled() or E:XPIsTrialMax()
end

function E:GetGroupUnit(unit)
	if UnitIsUnit(unit, 'player') then return end
	if strfind(unit, 'party') or strfind(unit, 'raid') then
		return unit
	end

	-- returns the unit as raid# or party# when grouped
	if UnitInParty(unit) or UnitInRaid(unit) then
		local isInRaid = IsInRaid()
		for i = 1, GetNumGroupMembers() do
			local groupUnit = (isInRaid and 'raid' or 'party')..i
			if UnitIsUnit(unit, groupUnit) then
				return groupUnit
			end
		end
	end
end

function E:GetUnitBattlefieldFaction(unit)
	local englishFaction, localizedFaction = UnitFactionGroup(unit)

	-- this might be a rated BG or wargame and if so the player's faction might be altered
	-- should also apply if `player` is a mercenary.
	if unit == 'player' and E.Retail then
		if C_PvP_IsRatedBattleground() or IsWargame() then
			englishFaction = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
			localizedFaction = (englishFaction == 'Alliance' and FACTION_ALLIANCE) or FACTION_HORDE
		elseif UnitIsMercenary(unit) then
			if englishFaction == 'Alliance' then
				englishFaction, localizedFaction = 'Horde', FACTION_HORDE
			else
				englishFaction, localizedFaction = 'Alliance', FACTION_ALLIANCE
			end
		end
	end

	return englishFaction, localizedFaction
end

function E:PositionGameMenuButton()
	if E.Retail then
		GameMenuFrame.Header.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
	end
	GameMenuFrame:Height(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)

	local button = GameMenuFrame.ElvUI
	button:SetFormattedText('%sElvUI|r', E.media.hexvaluecolor)

	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= button then
		button:ClearAllPoints()
		button:Point('TOPLEFT', relTo, 'BOTTOMLEFT', 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point('TOPLEFT', button, 'BOTTOMLEFT', 0, offY)
	end
end

function E:NEUTRAL_FACTION_SELECT_RESULT()
	E.myfaction, E.myLocalizedFaction = UnitFactionGroup('player')
end

function E:PLAYER_LEVEL_UP(_, level)
	E.mylevel = level
end

function E:ClickGameMenu()
	E:ToggleOptions() -- we already prevent it from opening in combat

	if not InCombatLockdown() then
		HideUIPanel(GameMenuFrame)
	end
end

function E:SetupGameMenu()
	local button = CreateFrame('Button', nil, GameMenuFrame, 'GameMenuButtonTemplate')
	button:SetScript('OnClick', E.ClickGameMenu)
	GameMenuFrame.ElvUI = button

	if not E:IsAddOnEnabled('ConsolePortUI_Menu') then
		button:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		button:Point('TOPLEFT', GameMenuButtonAddons, 'BOTTOMLEFT', 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', E.PositionGameMenuButton)
	end
end

function E:IsDragonRiding() -- currently unused, was used to help actionbars fade
	for spellID in next, E.MountDragons do
		if E:GetAuraByID('player', spellID, 'HELPFUL') then
			return true
		end
	end
end

function E:CompatibleTooltip(tt) -- knock off compatibility
	if tt.GetTooltipData then return end -- real support exists

	local info = { name = tt:GetName(), lines = {} }
	info.leftTextName = info.name .. 'TextLeft'
	info.rightTextName = info.name .. 'TextRight'

	tt.GetTooltipData = function()
		wipe(info.lines)

		for i = 1, tt:NumLines() do
			local left = _G[info.leftTextName..i]
			local leftText = left and left:GetText() or nil

			local right = _G[info.rightTextName..i]
			local rightText = right and right:GetText() or nil

			tinsert(info.lines, i, { lineIndex = i, leftText = leftText, rightText = rightText })
		end

		return info
	end
end

function E:GetUnitSpecInfo(unit)
	if not UnitIsPlayer(unit) then return end

	E.ScanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local _, specLine = TT:GetLevelLine(E.ScanTooltip, 1, true)
	local specText = specLine and specLine.leftText
	if specText then
		return E.SpecInfoBySpecClass[specText]
	end
end

function E:GetClassCoords(classFile, crop, get)
	local t = _G.CLASS_ICON_TCOORDS[classFile]
	if not t then return 0, 1, 0, 1 end

	if get then
		return t
	elseif type(crop) == 'number' then
		return t[1] + crop, t[2] - crop, t[3] + crop, t[4] - crop
	elseif crop then
		return t[1] + 0.022, t[2] - 0.025, t[3] + 0.022, t[4] - 0.025
	else
		return t[1], t[2], t[3], t[4]
	end
end

function E:CropRatio(frame, coords, mult)
	local left, right, top, bottom = unpack(coords or E.TexCoords)
	if not mult then mult = 0.5 end

	local width, height = frame:GetSize()
	local ratio = width / height
	if ratio > 1 then
		local trimAmount = (1 - (1 / ratio)) * mult
		top = top + trimAmount
		bottom = bottom - trimAmount
	else
		local trimAmount = (1 - ratio) * mult
		left = left + trimAmount
		right = right - trimAmount
	end

	return left, right, top, bottom
end

function E:ScanTooltip_UnitInfo(unit)
	if C_TooltipInfo_GetUnit then
		return C_TooltipInfo_GetUnit(unit)
	else
		E.ScanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetUnit(unit)
		E.ScanTooltip:Show()

		return E.ScanTooltip:GetTooltipData()
	end
end

function E:ScanTooltip_InventoryInfo(unit, slot)
	if C_TooltipInfo_GetInventoryItem then
		return C_TooltipInfo_GetInventoryItem(unit, slot)
	else
		E.ScanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetInventoryItem(unit, slot)
		E.ScanTooltip:Show()

		return E.ScanTooltip:GetTooltipData()
	end
end

function E:ScanTooltip_HyperlinkInfo(link)
	if C_TooltipInfo_GetHyperlink then
		return C_TooltipInfo_GetHyperlink(link)
	else
		E.ScanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetHyperlink(link)
		E.ScanTooltip:Show()

		return E.ScanTooltip:GetTooltipData()
	end
end

function E:LoadAPI()
	E:RegisterEvent('PLAYER_LEVEL_UP')
	E:RegisterEvent('PLAYER_ENTERING_WORLD')
	E:RegisterEvent('PLAYER_REGEN_ENABLED')
	E:RegisterEvent('PLAYER_REGEN_DISABLED')
	E:RegisterEvent('UI_SCALE_CHANGED', 'PixelScaleChanged')

	E:SetupGameMenu()

	if E.Retail then
		for _, mountID in next, C_MountJournal_GetMountIDs() do
			local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(mountID)
			local _, spellID, _, _, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal_GetMountInfoByID(mountID)
			E.MountIDs[spellID] = mountID
			E.MountText[mountID] = sourceText

			if isForDragonriding then
				E.MountDragons[spellID] = mountID
			end
		end

		do -- fill the spec info tables
			local MALE = _G.LOCALIZED_CLASS_NAMES_MALE
			local FEMALE = _G.LOCALIZED_CLASS_NAMES_FEMALE

			local i = 1
			local className, classFile, classID = GetClassInfo(i)
			local male, female = MALE[classFile], FEMALE[classFile]
			while classID do
				for index, id in next, E.SpecByClass[classFile] do
					local info = {
						id = id,
						index = index,
						classFile = classFile,
						className = className,
						englishName = E.SpecName[id]
					}

					E.SpecInfoBySpecID[id] = info

					for x = 3, 1, -1 do
						local _, name, desc, icon, role = GetSpecializationInfoForSpecID(id, x)

						if x == 1 then -- SpecInfoBySpecID
							info.name = name
							info.desc = desc
							info.icon = icon
							info.role = role

							E.SpecInfoBySpecClass[name..' '..className] = info
						else
							local copy = E:CopyTable({}, info)
							copy.name = name
							copy.desc = desc
							copy.icon = icon
							copy.role = role

							local localized = (x == 3 and female) or male
							copy.className = localized

							E.SpecInfoBySpecClass[name..' '..localized] = copy
						end
					end
				end

				i = i + 1
				className, classFile, classID = GetClassInfo(i)
				male, female = MALE[classFile], FEMALE[classFile]
			end
		end

		E:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')
		E:RegisterEvent('PET_BATTLE_CLOSE', 'AddNonPetBattleFrames')
		E:RegisterEvent('PET_BATTLE_OPENING_START', 'RemoveNonPetBattleFrames')
		E:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'CheckRole')
	else
		E:CompatibleTooltip(E.ScanTooltip)
		E:CompatibleTooltip(E.ConfigTooltip)
		E:CompatibleTooltip(E.SpellBookTooltip)
		E:CompatibleTooltip(_G.GameTooltip)
	end

	E.ScanTooltip.GetUnitInfo = E.ScanTooltip_UnitInfo
	E.ScanTooltip.GetHyperlinkInfo = E.ScanTooltip_HyperlinkInfo
	E.ScanTooltip.GetInventoryInfo = E.ScanTooltip_InventoryInfo

	if E.Retail or E.Wrath then
		E:RegisterEvent('UNIT_ENTERED_VEHICLE', 'EnterVehicleHideFrames')
		E:RegisterEvent('UNIT_EXITED_VEHICLE', 'ExitVehicleShowFrames')
	else
		E:RegisterEvent('CHARACTER_POINTS_CHANGED', 'CheckRole')
	end

	do -- setup cropIcon texCoords
		local opt = E.db.general.cropIcon
		local modifier = 0.04 * opt
		for i, v in ipairs(E.TexCoords) do
			if i % 2 == 0 then
				E.TexCoords[i] = v - modifier
			else
				E.TexCoords[i] = v + modifier
			end
		end
	end

	if _G.OrderHallCommandBar then
		E:HandleCommandBar()
	elseif E.Retail then
		local frame = CreateFrame('Frame')
		frame:RegisterEvent('ADDON_LOADED')
		frame:SetScript('OnEvent', function(Frame, event, addon)
			if event == 'ADDON_LOADED' and addon == 'Blizzard_OrderHallUI' then
				if InCombatLockdown() then
					Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
				else
					E:HandleCommandBar()
				end
				Frame:UnregisterEvent(event)
			elseif event == 'PLAYER_REGEN_ENABLED' then
				E:HandleCommandBar()
				Frame:UnregisterEvent(event)
			end
		end)
	end
end
