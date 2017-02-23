local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")
local Masque = LibStub("Masque", true)

--Cache global variables
--Lua functions
local _G = _G
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring
local assert, print, type, collectgarbage, pcall, date = assert, print, type, collectgarbage, pcall, date
local twipe, tinsert, tremove = table.wipe, tinsert, tremove
local floor = floor
local format, find, strrep, len, sub = string.format, string.find, strrep, string.len, string.sub
--WoW API / Variables
local CreateFrame = CreateFrame
local C_Timer_After = C_Timer.After
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local GetBonusBarOffset = GetBonusBarOffset
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCVar, SetCVar, GetCVarBool = GetCVar, SetCVar, GetCVarBool
local GetDodgeChance, GetParryChance = GetDodgeChance, GetParryChance
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetMapNameByID = GetMapNameByID
local GetSpecialization, GetActiveSpecGroup = GetSpecialization, GetActiveSpecGroup
local GetSpecializationRole = GetSpecializationRole
local GetSpellInfo = GetSpellInfo
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsInInstance, IsInGroup, IsInRaid = IsInInstance, IsInGroup, IsInRaid
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local SendAddonMessage = SendAddonMessage
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitLevel, UnitStat, UnitAttackPower = UnitLevel, UnitStat, UnitAttackPower
local COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN = COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub, UIParent, MAX_PLAYER_LEVEL, ScriptErrorsFrame_OnError
-- GLOBALS: ElvUIPlayerBuffs, ElvUIPlayerDebuffs, LeftChatPanel, RightChatPanel
-- GLOBALS: ElvUI_StaticPopup1, ElvUI_StaticPopup1Button1, OrderHallCommandBar
-- GLOBALS: ElvUI_StanceBar, ObjectiveTrackerFrame, GameTooltip, Minimap
-- GLOBALS: ElvUIParent, ElvUI_TopPanel, hooksecurefunc, InterfaceOptionsCameraPanelMaxDistanceSlider


--Constants
E.myclass = select(2, UnitClass("player"));
E.myspec = GetSpecialization()
E.myrace = select(2, UnitRace("player"))
E.myfaction = select(2, UnitFactionGroup('player'))
E.myname = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version");
E.myrealm = GetRealmName();
E.wowbuild = select(2, GetBuildInfo()); E.wowbuild = tonumber(E.wowbuild);
--Currently in Legion logging in while in Windowed mode will cause the game to use "Custom" resolution and GetCurrentResolution() returns 0. We use GetCVar("gxWindowedResolution") as fail safe
E.resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
E.screenwidth, E.screenheight = DecodeResolution(E.resolution)
E.isMacClient = IsMacClient()
E.LSM = LSM

--Tables
E["media"] = {};
E["frames"] = {};
E["statusBars"] = {};
E["texts"] = {};
E['snapBars'] = {}
E["RegisteredModules"] = {}
E['RegisteredInitialModules'] = {}
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92}
E.FrameLocks = {}
E.VehicleLocks = {}
E.CreditsList = {};
E.PixelMode = false;

E.InversePoints = {
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT',
	CENTER = 'CENTER'
}

E.DispelClasses = {
	['PRIEST'] = {
		['Magic'] = true,
		['Disease'] = true
	},
	['SHAMAN'] = {
		['Magic'] = false,
		['Curse'] = true
	},
	['PALADIN'] = {
		['Poison'] = true,
		['Magic'] = false,
		['Disease'] = true
	},
	['DRUID'] = {
		['Magic'] = false,
		['Curse'] = true,
		['Poison'] = true,
		['Disease'] = false,
	},
	['MONK'] = {
		['Magic'] = false,
		['Disease'] = true,
		['Poison'] = true
	}
}

E.HealingClasses = {
	PALADIN = 1,
	SHAMAN = 3,
	DRUID = 4,
	MONK = 2,
	PRIEST = {1, 2}
}

E.ClassRole = {
	PALADIN = {
		[1] = "Caster",
		[2] = "Tank",
		[3] = "Melee",
	},
	PRIEST = "Caster",
	WARLOCK = "Caster",
	WARRIOR = {
		[1] = "Melee",
		[2] = "Melee",
		[3] = "Tank",
	},
	HUNTER = "Melee",
	SHAMAN = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster",
	},
	ROGUE = "Melee",
	MAGE = "Caster",
	DEATHKNIGHT = {
		[1] = "Tank",
		[2] = "Melee",
		[3] = "Melee",
	},
	DRUID = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Tank",
		[4] = "Caster"
	},
	MONK = {
		[1] = "Tank",
		[2] = "Caster",
		[3] = "Melee",
	},
	DEMONHUNTER = {
		[1] = "Melee",
		[2] = "Tank"	
	},
}

E.noop = function() end;

function E:Print(...)
	print(self["media"].hexvaluecolor..'ElvUI:|r', ...)
end

--Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99,
	colorStr = 'fcfcfc'
}

function E:GetPlayerRole()
	local assignedRole = UnitGroupRolesAssigned("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return GetSpecializationRole(spec);
	end

	return assignedRole;
end

--Basically check if another class border is being used on a class that doesn't match. And then return true if a match is found.
function E:CheckClassColor(r, g, b)
	r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local matchFound = false;
	for class, _ in pairs(RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			local colorTable = class == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			if colorTable.r == r and colorTable.g == g and colorTable.b == b then
				matchFound = true;
			end
		end
	end

	return matchFound
end

function E:GetColorTable(data)	
	if not data.r or not data.g or not data.b then
		error("Could not unpack color values.")
	end

	if data.r > 1 or data.r < 0 then data.r = 1 end
	if data.g > 1 or data.g < 0 then data.g = 1 end
	if data.b > 1 or data.b < 0 then data.b = 1 end
	if data.a and (data.a > 1 or data.a < 0) then data.a = 1 end

	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()
	if not self.db['general'] or not self.private['general'] then return end --Prevent rare nil value errors

	--Fonts
	self["media"].normFont = LSM:Fetch("font", self.db['general'].font)
	self["media"].combatFont = LSM:Fetch("font", self.private['general'].dmgfont)

	--Textures
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank")
	self["media"].normTex = LSM:Fetch("statusbar", self.private['general'].normTex)
	self["media"].glossTex = LSM:Fetch("statusbar", self.private['general'].glossTex)

	--Border Color
	local border = E.db['general'].bordercolor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		E.db['general'].bordercolor.r = classColor.r
		E.db['general'].bordercolor.g = classColor.g
		E.db['general'].bordercolor.b = classColor.b
	elseif E.PixelMode then
		border = {r = 0, g = 0, b = 0}
	end

	self["media"].bordercolor = {border.r, border.g, border.b}

	--Backdrop Color
	self["media"].backdropcolor = E:GetColorTable(self.db['general'].backdropcolor)

	--Backdrop Fade Color
	self["media"].backdropfadecolor = E:GetColorTable(self.db['general'].backdropfadecolor)

	--Value Color
	local value = self.db['general'].valuecolor

	if self:CheckClassColor(value.r, value.g, value.b) then
		value = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
		self.db['general'].valuecolor.r = value.r
		self.db['general'].valuecolor.g = value.g
		self.db['general'].valuecolor.b = value.b
	end

	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}

	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		local a = E.db.general.backdropfadecolor.a or 0.5
		LeftChatPanel.tex:SetAlpha(a)

		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(a)
	end

	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

E.LockedCVars = {}
E.IgnoredCVars = {}

function E:PLAYER_REGEN_ENABLED(_)
	if(self.CVarUpdate) then
		for cvarName, value in pairs(self.LockedCVars) do
			if (not self.IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value)) then
				SetCVar(cvarName, value)
			end			
		end
		self.CVarUpdate = nil
	end
end

local function CVAR_UPDATE(cvarName, value)
	if(not E.IgnoredCVars[cvarName] and E.LockedCVars[cvarName] and E.LockedCVars[cvarName] ~= value) then
		if(InCombatLockdown()) then
			E.CVarUpdate = true
			return
		end
		
		SetCVar(cvarName, E.LockedCVars[cvarName])
	end
end

hooksecurefunc("SetCVar", CVAR_UPDATE)
function E:LockCVar(cvarName, value)
	if(GetCVar(cvarName) ~= value) then
		SetCVar(cvarName, value)
	end
	self.LockedCVars[cvarName] = value
end

function E:IgnoreCVar(cvarName, ignore)
	ignore = not not ignore --cast to bool, just in case
	self.IgnoredCVars[cvarName] = ignore
end

--Update font/texture paths when they are registered by the addon providing them
--This helps fix most of the issues with fonts or textures reverting to default because the addon providing them is loading after ElvUI.
--We use a wrapper to avoid errors in :UpdateMedia because "self" is passed to the function with a value other than ElvUI.
local function LSMCallback()
	E:UpdateMedia()
end
E.LSM.RegisterCallback(E, "LibSharedMedia_Registered", LSMCallback)

local MasqueGroupState = {}
local MasqueGroupToTableElement = {
	["ActionBars"] = {"actionbar", "actionbars"},
	["Pet Bar"] = {"actionbar", "petBar"},
	["Stance Bar"] = {"actionbar", "stanceBar"},
	["Buffs"] = {"auras", "buffs"},
	["Debuffs"] = {"auras", "debuffs"},
}

local function MasqueCallback(_, Group, _, _, _, _, Disabled)
	if not E.private then return; end
	local element = MasqueGroupToTableElement[Group]

	if element then
		if Disabled then
			if E.private[element[1]].masque[element[2]] and MasqueGroupState[Group] == "enabled" then
				E.private[element[1]].masque[element[2]] = false
				E:StaticPopup_Show("CONFIG_RL")
			end
			MasqueGroupState[Group] = "disabled"
		else
			MasqueGroupState[Group] = "enabled"
		end
	end
end

if Masque then
	Masque:Register("ElvUI", MasqueCallback)
end

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[473] = "Outland",
	[477] = "Outland",
}
local MapIdLookupTable = {
	[466] = "Outland",
	[473] = "Shadowmoon Valley",
	[477] = "Nagrand",
}

local function LocalizeZoneNames()
	local localizedZoneName

	for mapID, englishName in pairs(MapIdLookupTable) do
		localizedZoneName = GetMapNameByID(mapID)
		if localizedZoneName then
			-- Add combination of English and localized name to lookup table
			if not localizedMapNames[englishName] then
				localizedMapNames[englishName] = localizedZoneName
			end
		end
	end
end
LocalizeZoneNames()

--Add " (Outland)" to the end of zone name for Nagrand and Shadowmoon Valley, if mapID matches Outland continent.
--We can then use this function when we need to compare the players own zone against return values from stuff like GetFriendInfo and GetGuildRosterInfo,
--which adds the " (Outland)" part unlike the GetRealZoneText() API.
function E:GetZoneText(zoneAreaID)
	local zoneName = GetMapNameByID(zoneAreaID)
	local continent = ZoneIDToContinentName[zoneAreaID]

	if continent and continent == "Outland" then
		if zoneName == localizedMapNames["Nagrand"] or zoneName == "Nagrand"  then
			zoneName = localizedMapNames["Nagrand"].." ("..localizedMapNames["Outland"]..")"
		elseif zoneName == localizedMapNames["Shadowmoon Valley"] or zoneName == "Shadowmoon Valley"  then
			zoneName = localizedMapNames["Shadowmoon Valley"].." ("..localizedMapNames["Outland"]..")"
		end
	end

	return zoneName
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD()
	self:CheckRole()
	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true;
	end

	local _, instanceType = IsInInstance();
	if instanceType == "pvp" then
		self.BGTimer = self:ScheduleRepeatingTimer("RequestBGInfo", 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil;
	end
end

function E:ValueFuncCall()
	for func, _ in pairs(self['valueColorUpdateFuncs']) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if frame and frame.template and not frame.ignoreUpdates then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if frame and not frame.ignoreUpdates then
			if frame.template == 'Default' or frame.template == 'Transparent' or frame.template == nil then
				frame:SetBackdropBorderColor(unpack(self['media'].bordercolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == nil then
				if frame.backdropTexture then
					frame.backdropTexture:SetVertexColor(unpack(self['media'].backdropcolor))
				else
					frame:SetBackdropColor(unpack(self['media'].backdropcolor))
				end
			elseif frame.template == 'Transparent' then
				frame:SetBackdropColor(unpack(self['media'].backdropfadecolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

function E:RegisterStatusBar(statusBar)
	tinsert(self.statusBars, statusBar)
end

function E:UpdateStatusBars()
	for _, statusBar in pairs(self.statusBars) do
		if statusBar and statusBar:GetObjectType() == "StatusBar" then
			statusBar:SetStatusBarTexture(self.media.normTex)
		elseif statusBar and statusBar:GetObjectType() == "Texture" then
			statusBar:SetTexture(self.media.normTex)
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER');
E.UIParent:SetSize(UIParent:GetSize());
E.UIParent.origHeight = E.UIParent:GetHeight()
E['snapBars'][#E['snapBars'] + 1] = E.UIParent

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()


function E:CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if type(tree) == 'number' then
		if activeGroup and GetSpecialization(false, false, activeGroup) then
			return tree == GetSpecialization(false, false, activeGroup)
		end
	elseif type(tree) == 'table' then
		local activeGroup = GetActiveSpecGroup()
		for _, index in pairs(tree) do
			if activeGroup and GetSpecialization(false, false, activeGroup) then
				return index == GetSpecialization(false, false, activeGroup)
			end
		end
	end
end

function E:IsDispellableByMe(debuffType)
	if not self.DispelClasses[self.myclass] then return; end

	if self.DispelClasses[self.myclass][debuffType] then
		return true;
	end
end

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)
function E:SPELLS_CHANGED()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		self.DispelClasses["DRUID"].Disease = true
	else
		self.DispelClasses["DRUID"].Disease = false
	end
end

function E:CheckRole()
	local talentTree = GetSpecialization()
	local IsInPvPGear = false;
	local role
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() and UnitLevel('player') == MAX_PLAYER_LEVEL then
		IsInPvPGear = true;
	end

	self.myspec = talentTree

	if type(self.ClassRole[self.myclass]) == "string" then
		role = self.ClassRole[self.myclass]
	elseif talentTree then
		role = self.ClassRole[self.myclass][talentTree]
	end

	--Check for PvP gear or gladiator stance
	if role == "Tank" and (IsInPvPGear or (E.myclass == "WARRIOR" and GetBonusBarOffset() == 3)) then
		role = "Melee"
	end

	if not role then
		local playerint = select(2, UnitStat("player", 4));
		local playeragi	= select(2, UnitStat("player", 2));
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (playerap > playerint) or (playeragi > playerint) then
			role = "Melee";
		else
			role = "Caster";
		end
	end

	if(self.role ~= role) then
		self.role = role
		self.callbacks:Fire("RoleChanged")
	end

	if self.HealingClasses[self.myclass] ~= nil and self.myclass ~= 'PRIEST' then
		if self:CheckTalentTree(self.HealingClasses[self.myclass]) then
			self.DispelClasses[self.myclass].Magic = true;
		else
			self.DispelClasses[self.myclass].Magic = false;
		end
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button1 = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button2 = 'ElvUI '..module
	E.PopupDialogs['INCOMPATIBLE_ADDON'].addon = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].module = module
	E:StaticPopup_Show('INCOMPATIBLE_ADDON', addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return; end
	if IsAddOnLoaded('Prat-3.0') and E.private.chat.enable then
		E:IncompatibleAddOn('Prat-3.0', 'Chat')
	end

	if IsAddOnLoaded('Chatter') and E.private.chat.enable then
		E:IncompatibleAddOn('Chatter', 'Chat')
	end

	if IsAddOnLoaded('TidyPlates') and E.private.nameplates.enable then
		E:IncompatibleAddOn('TidyPlates', 'NamePlates')
	end

	if IsAddOnLoaded('Aloft') and E.private.nameplates.enable then
		E:IncompatibleAddOn('Aloft', 'NamePlates')
	end

	if IsAddOnLoaded('Healers-Have-To-Die') and E.private.nameplates.enable then
		E:IncompatibleAddOn('Healers-Have-To-Die', 'NamePlates')
	end
end

function E:IsFoolsDay()
	if find(date(), '04/01/') and not E.global.aprilFools then
		return true;
	else
		return false;
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end

	if type(defaultTable) == 'table' then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end

			currentTable[option] = value
		end
	end

	return currentTable
end

local function IsTableEmpty(tbl)
	for _, _ in pairs(tbl) do
		return false
	end
	return true
end

function E:RemoveEmptySubTables(tbl)
	if type(tbl) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveEmptySubTables' (table expected)")
		return
	end

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			if IsTableEmpty(v) then
				tbl[k] = nil
			else
				self:RemoveEmptySubTables(v)
			end
		end
	end
end

--Compare 2 tables and remove duplicate key/value pairs
--param cleanTable : table you want cleaned
--param checkTable : table you want to check against.
--return : a copy of cleanTable with duplicate key/value pairs removed
function E:RemoveTableDuplicates(cleanTable, checkTable)
	if type(cleanTable) ~= "table" then
		E:Print("Bad argument #1 to 'RemoveTableDuplicates' (table expected)")
		return
	end
	if type(checkTable) ~=  "table" then
		E:Print("Bad argument #2 to 'RemoveTableDuplicates' (table expected)")
		return
	end

	local cleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == "table" and checkTable[option] and type(checkTable[option]) == "table" then
			cleaned[option] = self:RemoveTableDuplicates(value, checkTable[option])
		else
			-- Add unique data to our clean table
			if (cleanTable[option] ~= checkTable[option]) then
				cleaned[option] = value
			end
		end
	end

	--Clean out empty sub-tables
	self:RemoveEmptySubTables(cleaned)

	return cleaned
end

--The code in this function is from WeakAuras, credit goes to Mirrored and the WeakAuras Team
function E:TableToLuaString(inTable)
	if type(inTable) ~= "table" then
		E:Print("Invalid argument #1 to E:TableToLuaString (table expected)")
		return
	end

	local ret = "{\n";
	local function recurse(table, level)
		for i,v in pairs(table) do
			ret = ret..strrep("    ", level).."[";
			if(type(i) == "string") then
				ret = ret.."\""..i.."\"";
			else
				ret = ret..i;
			end
			ret = ret.."] = ";

			if(type(v) == "number") then
				ret = ret..v..",\n"
			elseif(type(v) == "string") then
				ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"").."\",\n"
			elseif(type(v) == "boolean") then
				if(v) then
					ret = ret.."true,\n"
				else
					ret = ret.."false,\n"
				end
			elseif(type(v) == "table") then
				ret = ret.."{\n"
				recurse(v, level + 1);
				ret = ret..strrep("    ", level).."},\n"
			else
				ret = ret.."\""..tostring(v).."\",\n"
			end
		end
	end

	if(inTable) then
		recurse(inTable, 1);
	end
	ret = ret.."}";

	return ret;
end

local profileFormat = {
	["profile"] = "E.db",
	["private"] = "E.private",
	["global"] = "E.global",
	["filtersNP"] = "E.global",
	["filtersUF"] = "E.global",
	["filtersAll"] = "E.global",
}

local lineStructureTable = {}

function E:ProfileTableToPluginFormat(inTable, profileType)
	local profileText = profileFormat[profileType]
	if not profileText then
		return
	end

	twipe(lineStructureTable)
	local returnString = ""
	local lineStructure = ""
	local sameLine = false

	local function buildLineStructure()
		local str = profileText
		for _, v in ipairs(lineStructureTable) do
			if type(v) == "string" then
				str = str.."[\""..v.."\"]"
			else
				str = str.."["..v.."]"
			end
		end

		return str
	end

	local function recurse(tbl)
		lineStructure = buildLineStructure()
		for k, v in pairs(tbl) do
			if not sameLine then
				returnString = returnString..lineStructure
			end

			returnString = returnString.."[";

			if(type(k) == "string") then
				returnString = returnString.."\""..k.."\"";
			else
				returnString = returnString..k;
			end

			if type(v) == "table" then
				tinsert(lineStructureTable, k)
				sameLine = true
				returnString = returnString.."]"
				recurse(v)
			else
				sameLine = false
				returnString = returnString.."] = ";

				if type(v) == "number" then
					returnString = returnString..v.."\n"
				elseif type(v) == "string" then
					returnString = returnString.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"").."\"\n"
				elseif type(v) == "boolean" then
					if v then
						returnString = returnString.."true\n"
					else
						returnString = returnString.."false\n"
					end
				else
					returnString = returnString.."\""..tostring(v).."\"\n"
				end
			end
		end

		tremove(lineStructureTable)
		lineStructure = buildLineStructure()
	end

	if inTable and profileType then
		recurse(inTable);
	end

	return returnString;
end

--Split string by multi-character delimiter (the strsplit / string.split function provided by WoW doesn't allow multi-character delimiter)
function E:SplitString(s, delim)
	assert(type (delim) == "string" and len(delim) > 0, "bad delimiter")

	local start = 1
	local t = {}  -- results table

	-- find each instance of a string followed by the delimiter
	while true do
		local pos = find(s, delim, start, true) -- plain find

		if not pos then
			break
		end

		tinsert(t, sub(s, start, pos - 1))
		start = pos + len(delim)
	end -- while

	-- insert final one (after last delimiter)
	tinsert(t, sub(s, start))

	return unpack(t)
end

function E:SendMessage()
	if IsInRaid() then
		SendAddonMessage("ELVUI_VERSIONCHK", E.version, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
	elseif IsInGroup() then
		SendAddonMessage("ELVUI_VERSIONCHK", E.version, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
	end

	if E.SendMSGTimer then
		self:CancelTimer(E.SendMSGTimer)
		E.SendMSGTimer = nil
	end
end

local myName = E.myname.."-"..E.myrealm;
myName = myName:gsub("%s+", "")

local function SendRecieve(_, event, prefix, message, _, sender)

	if event == "CHAT_MSG_ADDON" then
		if(sender == myName) then return end

		if prefix == "ELVUI_VERSIONCHK" and not E.recievedOutOfDateMessage then
			if(tonumber(message) ~= nil and tonumber(message) > tonumber(E.version)) then
				E:Print(L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"])

				if((tonumber(message) - tonumber(E.version)) >= 0.05) then
					E:StaticPopup_Show("ELVUI_UPDATE_AVAILABLE")
				end

				E.recievedOutOfDateMessage = true
			end
		end
	else
		E.SendMSGTimer = E:ScheduleTimer('SendMessage', 12)
	end
end

RegisterAddonMessagePrefix('ELVUI_VERSIONCHK')

local f = CreateFrame('Frame')
f:RegisterEvent("GROUP_ROSTER_UPDATE")
--f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript('OnEvent', SendRecieve)

function E:UpdateAll(ignoreInstall)
	if not self.initialized then
		C_Timer_After(1, function() E:UpdateAll(ignoreInstall) end)
		return
	end

	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self.db.theme = nil;
	self.db.install_complete = nil;

	--The mover is positioned before it is resized, which causes issues for unitframes
	--Allow movers to be "pushed" outside the screen, when they are resized they should be back in the screen area.
	--We set movers to be clamped again at the bottom of this function.
	self:SetMoversClampedToScreen(false)

	self:SetMoversPositions()

	self:UpdateMedia()
	self:UpdateCooldownSettings()
	if self.RefreshGUI then self:RefreshGUI() end --Refresh Config

	local UF = self:GetModule('UnitFrames')
	UF.db = self.db.unitframe
	UF:Update_AllFrames()

	local CH = self:GetModule('Chat')
	CH.db = self.db.chat
	CH:PositionChat(true);
	CH:SetupChat()
	CH:UpdateAnchors()

	local AB = self:GetModule('ActionBars')
	AB.db = self.db.actionbar
	AB:UpdateButtonSettings()
	AB:UpdatePetCooldownSettings()
	AB:UpdateMicroPositionDimensions()
	AB:Extra_SetAlpha()
	AB:Extra_SetScale()

	local bags = E:GetModule('Bags');
	bags.db = self.db.bags
	bags:Layout();
	bags:Layout(true);
	bags:SizeAndPositionBagBar()
	bags:UpdateItemLevelDisplay()
	bags:UpdateCountDisplay()

	local totems = E:GetModule('Totems');
	totems.db = self.db.general.totems
	totems:PositionAndSize()
	totems:ToggleEnable()

	self:GetModule('Layout'):ToggleChatPanels()

	local DT = self:GetModule('DataTexts')
	DT.db = self.db.datatexts
	DT:LoadDataTexts()

	local NP = self:GetModule('NamePlates')
	NP.db = self.db.nameplates
	NP:ConfigureAll()

	local DataBars = self:GetModule("DataBars")
	DataBars.db = E.db.databars
	DataBars:UpdateDataBarDimensions()
	DataBars:EnableDisable_ExperienceBar()
	DataBars:EnableDisable_ReputationBar()
	DataBars:EnableDisable_ArtifactBar()
	DataBars:EnableDisable_HonorBar()
	
	local T = self:GetModule('Threat')
	T.db = self.db.general.threat
	T:UpdatePosition()
	T:ToggleEnable()

	self:GetModule('Auras').db = self.db.auras
	self:GetModule('Tooltip').db = self.db.tooltip

	if(ElvUIPlayerBuffs) then
		E:GetModule('Auras'):UpdateHeader(ElvUIPlayerBuffs)
	end

	if(ElvUIPlayerDebuffs) then
		E:GetModule('Auras'):UpdateHeader(ElvUIPlayerDebuffs)
	end

	if self.private.install_complete == nil or (self.private.install_complete and type(self.private.install_complete) == 'boolean') or (self.private.install_complete and type(tonumber(self.private.install_complete)) == 'number' and tonumber(self.private.install_complete) <= 3.83) then
		if not ignoreInstall then
			self:Install()
		end
	end

	self:GetModule('Minimap'):UpdateSettings()
	self:GetModule("AFK"):Toggle()

	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	self:UpdateFrameTemplates()
	self:UpdateStatusBars()

	local LO = E:GetModule('Layout')
	LO:ToggleChatPanels()
	LO:BottomPanelVisibility()
	LO:TopPanelVisibility()
	LO:SetDataPanelStyle()

	self:GetModule('Blizzard'):SetObjectiveFrameHeight()
	
	self:SetMoversClampedToScreen(true) --Go back to using clamp after resizing has taken place.

	collectgarbage('collect');
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(E.HiddenFrame)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "AddNonPetBattleFrames")
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, data in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		local parent, strata
		if type(data) == "table" then
			parent, strata = data.parent, data.strata
		elseif data == true then
			parent = UIParent
		end
		obj:SetParent(parent)
		if strata then
			obj:SetFrameStrata(strata)
		end
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function E:RegisterPetBattleHideFrames(object, originalParent, originalStrata)
	if not object or not originalParent then
		E:Print("Error. Usage: RegisterPetBattleHideFrames(object, originalParent, originalStrata)")
		return
	end

	local object = _G[object] or object
	--If already doing pokemon
	if C_PetBattles_IsInBattle() then
		object:SetParent(E.HiddenFrame)
	end
	E.FrameLocks[object] = {
		["parent"] = originalParent,
		["strata"] = originalStrata or nil,
	}
end

function E:UnregisterPetBattleHideFrames(object)
	if not object then
		E:Print("Error. Usage: UnregisterPetBattleHideFrames(object)")
		return
	end

	local object = _G[object] or object
	--Check if object was registered to begin with
	if not E.FrameLocks[object] then
		return
	end

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

function E:EnterVehicleHideFrames(_, unit)
	if unit ~= "player" then return; end
	
	for object in pairs(E.VehicleLocks) do
		object:SetParent(E.HiddenFrame)
	end
end

function E:ExitVehicleShowFrames(_, unit)
	if unit ~= "player" then return; end
	
	for object, originalParent in pairs(E.VehicleLocks) do
		object:SetParent(originalParent)
	end
end

function E:RegisterObjectForVehicleLock(object, originalParent)
	if not object or not originalParent then
		E:Print("Error. Usage: RegisterObjectForVehicleLock(object, originalParent)")
		return
	end

	local object = _G[object] or object
	--Entering/Exiting vehicles will often happen in combat.
	--For this reason we cannot allow protected objects.
	if object.IsProtected and object:IsProtected() then
		E:Print("Error. Object is protected and cannot be changed in combat.")
		return
	end

	--Check if we are already in a vehicles
	if UnitHasVehicleUI("player") then
		object:SetParent(E.HiddenFrame)
	end

	--Add object to table
	E.VehicleLocks[object] = originalParent
end

function E:UnregisterObjectForVehicleLock(object)
	if not object then
		E:Print("Error. Usage: UnregisterObjectForVehicleLock(object)")
		return
	end

	local object = _G[object] or object
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

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	if ... == '' or ... == ' ' or ... == nil then
		E:StaticPopup_Show('RESETUI_CHECK')
		return
	end

	self:ResetMovers(...)
end

function E:RegisterModule(name)
	if self.initialized then
		self:GetModule(name):Initialize()
	else
		self['RegisteredModules'][#self['RegisteredModules'] + 1] = name
	end
end

function E:RegisterInitialModule(name)
	self['RegisteredInitialModules'][#self['RegisteredInitialModules'] + 1] = name
end

function E:InitializeInitialModules()
	for _, module in pairs(E['RegisteredInitialModules']) do
		local module = self:GetModule(module, true)
		if module and module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool('scriptErrors') == true then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

function E:RefreshModulesDB()
	local UF = self:GetModule('UnitFrames')
	twipe(UF.db)
	UF.db = self.db.unitframe
end

function E:InitializeModules()
	for _, module in pairs(E['RegisteredModules']) do
		local module = self:GetModule(module)
		if module.Initialize then
			local _, catch = pcall(module.Initialize, module)

			if catch and GetCVarBool('scriptErrors') == true then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

--DATABASE CONVERSIONS
function E:DBConversions()	
	--Convert actionbar button spacing to backdrop spacing, so users don't get any unwanted changes
	if not E.db.actionbar.backdropSpacingConverted then
		for i = 1, 10 do
			if E.db.actionbar["bar"..i] then
				E.db.actionbar["bar"..i].backdropSpacing = E.db.actionbar["bar"..i].buttonspacing
			end
		end
		E.db.actionbar.barPet.backdropSpacing = E.db.actionbar.barPet.buttonspacing
		E.db.actionbar.stanceBar.backdropSpacing = E.db.actionbar.stanceBar.buttonspacing
		
		E.db.actionbar.backdropSpacingConverted = true
	end
	
	--Convert E.db.actionbar.showGrid to E.db.actionbar["barX"].showGrid
	if E.db.actionbar.showGrid ~= nil then
		local gridEnabled = E.db.actionbar.showGrid
		for i = 1, 10 do
			if E.db.actionbar["bar"..i] then
				E.db.actionbar["bar"..i].showGrid = gridEnabled
			end
		end
		E.db.actionbar.showGrid = nil
	end
	
	--Convert old WorldMapCoordinates from boolean to new table format
	if type(E.global.general.WorldMapCoordinates) == "boolean" then
		local enabledState = E.global.general.WorldMapCoordinates
		
		--Remove boolean value
		E.global.general.WorldMapCoordinates = nil
		
		--Add old enabled state
		E.global.general.WorldMapCoordinates.enable = enabledState
	end
	
	--Remove old nameplate settings, no need for them to take up space
	if E.db.nameplate then
		E.db.nameplate = nil
	end
end

local CPU_USAGE = {}
local function CompareCPUDiff(showall, minCalls)
	local greatestUsage, greatestCalls, greatestName, newName, newFunc
	local greatestDiff, lastModule, mod, newUsage, calls, differance = 0;

	for name, oldUsage in pairs(CPU_USAGE) do
		newName, newFunc = name:match("^([^:]+):(.+)$")
		if not newFunc then
			E:Print('CPU_USAGE:', name, newFunc)
		else
			if newName ~= lastModule then
				mod = E:GetModule(newName, true) or E
				lastModule = newName
			end
			newUsage, calls = GetFunctionCPUUsage(mod[newFunc], true)
			differance = newUsage - oldUsage
			if showall and calls > minCalls then
				E:Print(calls, name, differance)
			end
			if (differance > greatestDiff) and calls > minCalls then
				greatestName, greatestUsage, greatestCalls, greatestDiff = name, newUsage, calls, differance
			end
		end
	end

	if greatestName then
		E:Print(greatestName.. " had the CPU usage difference of: "..greatestUsage.."ms. And has been called ".. greatestCalls.." times.")
	else
		E:Print('CPU Usage: No CPU Usage differences found.')
	end
end

function E:GetTopCPUFunc(msg)
	local module, showall, delay, minCalls = msg:match("^([^%s]+)%s*([^%s]*)%s*([^%s]*)%s*(.*)$")
	local mod

	module = (module == "nil" and nil) or module
	if not module then
		E:Print('cpuusage: module (arg1) is required! This can be set as "all" too.')
		return
	end
	showall = (showall == "true" and true) or false
	delay = (delay == "nil" and nil) or tonumber(delay) or 5
	minCalls = (minCalls == "nil" and nil) or tonumber(minCalls) or 15

	twipe(CPU_USAGE)
	if module == "all" then
		for _, registeredModule in pairs(self['RegisteredModules']) do
			mod = self:GetModule(registeredModule, true) or self
			for name, func in pairs(mod) do
				if type(mod[name]) == "function" and name ~= "GetModule" then
					CPU_USAGE[registeredModule..":"..name] = GetFunctionCPUUsage(mod[name], true)
				end
			end
		end
	else
		mod = self:GetModule(module, true) or self
		for name, func in pairs(mod) do
			if type(mod[name]) == "function" and name ~= "GetModule" then
				CPU_USAGE[module..":"..name] = GetFunctionCPUUsage(mod[name], true)
			end
		end
	end

	self:Delay(delay, CompareCPUDiff, showall, minCalls)
	self:Print("Calculating CPU Usage differences (module: "..(module or "?")..", showall: "..tostring(showall)..", minCalls: "..tostring(minCalls)..", delay: "..tostring(delay)..")")
end

local function SetOriginalHeight()
	if InCombatLockdown() then
		E:RegisterEvent("PLAYER_REGEN_ENABLED", SetOriginalHeight)
		return
	end
	E:UnregisterEvent("PLAYER_REGEN_ENABLED")
	E.UIParent:SetHeight(E.UIParent.origHeight)
end

local function SetModifiedHeight()
	if InCombatLockdown() then
		E:RegisterEvent("PLAYER_REGEN_ENABLED", SetModifiedHeight)
		return
	end
	E:UnregisterEvent("PLAYER_REGEN_ENABLED")
	local height = E.UIParent.origHeight - OrderHallCommandBar:GetHeight()
	E.UIParent:SetHeight(height)
end

--This function handles disabling of OrderHall Bar or resizing of ElvUIParent if needed
local function HandleCommandBar()
	if E.global.general.commandBarSetting == "DISABLED" then
		local bar = OrderHallCommandBar
		bar:UnregisterAllEvents()
		bar:SetScript("OnShow", bar.Hide)
		bar:Hide()
		UIParent:UnregisterEvent("UNIT_AURA")--Only used for OrderHall Bar
	elseif E.global.general.commandBarSetting == "ENABLED_RESIZEPARENT" then
		E.UIParent:SetPoint("BOTTOM", UIParent, "BOTTOM");
		OrderHallCommandBar:HookScript("OnShow", SetModifiedHeight)
		OrderHallCommandBar:HookScript("OnHide", SetOriginalHeight)
	end
end

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)

	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateDB", self.privateVars);
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.data, "ElvUI")
	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self:CheckIncompatible()
	self:DBConversions()

	self:CheckRole()
	self:UIScale('PLAYER_LOGIN');

	self:LoadCommands(); --Load Commands
	self:InitializeModules(); --Load Modules
	self:LoadMovers(); --Load Movers
	self:UpdateCooldownSettings()
	self.initialized = true

	if self.private.install_complete == nil then
		self:Install()
	end

	if not find(date(), '04/01/') then
		E.global.aprilFools = nil;
	end

	if(self:HelloKittyFixCheck()) then
		self:HelloKittyFix()
	end

	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");
	self:RegisterEvent('UI_SCALE_CHANGED', 'UIScale')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent("PET_BATTLE_CLOSE", 'AddNonPetBattleFrames')
	self:RegisterEvent('PET_BATTLE_OPENING_START', "RemoveNonPetBattleFrames")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "EnterVehicleHideFrames")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "ExitVehicleShowFrames")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if self.myclass == "DRUID" then
		self:RegisterEvent("SPELLS_CHANGED")
	end

	if self.db.general.kittys then
		self:CreateKittys()
		self:Delay(5, self.Print, self, L["Type /hellokitty to revert to old settings."])
	end

	self:Tutorials()
	self:GetModule('Minimap'):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect");

	if self.db.general.loginmessage then
		print(select(2, E:GetModule('Chat'):FindURL("CHAT_MSG_DUMMY", format(L["LOGIN_MSG"], self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version)))..'.')
	end

	if OrderHallCommandBar then
		HandleCommandBar()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("ADDON_LOADED")
		f:SetScript("OnEvent", function(self, event, addon)
			if event == "ADDON_LOADED" and addon == "Blizzard_OrderHallUI" then
				if InCombatLockdown() then
					self:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					HandleCommandBar()
				end
				self:UnregisterEvent(event)
			elseif event == "PLAYER_REGEN_ENABLED" then
				HandleCommandBar()
				self:UnregisterEvent(event)
			end
		end)
	end
end