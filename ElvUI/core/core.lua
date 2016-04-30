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
local format, find, split, match, strrep, len, sub, gsub = string.format, string.find, string.split, string.match, strrep, string.len, string.sub, string.gsub
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVar, SetCVar, GetCVarBool = GetCVar, SetCVar, GetCVarBool
local IsAddOnLoaded = IsAddOnLoaded
local PlayMusic, StopMusic = PlayMusic, StopMusic
local GetSpellInfo = GetSpellInfo
local IsInInstance, IsInGroup, IsInRaid = IsInInstance, IsInGroup, IsInRaid
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local GetSpecialization, GetActiveSpecGroup = GetSpecialization, GetActiveSpecGroup
local GetCombatRatingBonus = GetCombatRatingBonus
local GetDodgeChance, GetParryChance = GetDodgeChance, GetParryChance
local UnitLevel, UnitStat, UnitAttackPower = UnitLevel, UnitStat, UnitAttackPower
local SendAddonMessage = SendAddonMessage
local InCombatLockdown = InCombatLockdown
local DoEmote = DoEmote
local SendChatMessage = SendChatMessage
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetMapNameByID = GetMapNameByID
local GetBonusBarOffset = GetBonusBarOffset
local UnitHasVehicleUI = UnitHasVehicleUI
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN = COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub, UIParent, MAX_PLAYER_LEVEL, ScriptErrorsFrame_OnError
-- GLOBALS: ElvUIPlayerBuffs, ElvUIPlayerDebuffs, LeftChatPanel, RightChatPanel
-- GLOBALS: ElvUI_StaticPopup1, ElvUI_StaticPopup1Button1, LeftChatToggleButton, RightChatToggleButton
-- GLOBALS: ElvUI_StanceBar, ObjectiveTrackerFrame, GameTooltip, Minimap


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
E.resolution = GetCVar("gxResolution")
E.screenheight = tonumber(match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(match(E.resolution, "(%d+)x+%d"))
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
	['MAGE'] = {
		['Curse'] = true
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
}

E.noop = function() end;

function E:Print(...)
	print(self["media"].hexvaluecolor..self.UIName..':|r', ...)
end

--Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99,
	colorStr = 'fcfcfc'
}

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

	if(self.global.tukuiMode) then
		border = {r=0.6, g = 0.6, b = 0.6}
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

	if(self.global.tukuiMode) then
		value = {r = 1, g = 1, b = 1}
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
	["Consolidated Buffs"] = {"auras", "consolidatedBuffs"},
}

local function MasqueCallback(Addon, Group, SkinID, Gloss, Backdrop, Colors, Disabled)
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

	if IsAddOnLoaded('TidyPlates') and E.private.nameplate.enable then
		E:IncompatibleAddOn('TidyPlates', 'NamePlate')
	end

	if IsAddOnLoaded('Aloft') and E.private.nameplate.enable then
		E:IncompatibleAddOn('Aloft', 'NamePlate')
	end

	if IsAddOnLoaded('Healers-Have-To-Die') and E.private.nameplate.enable then
		E:IncompatibleAddOn('Healers-Have-To-Die', 'NamePlate')
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
	local _, instanceType = IsInInstance()
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
local frames = {}

local function SendRecieve(self, event, prefix, message, channel, sender)

	if event == "CHAT_MSG_ADDON" then
		if(sender == myName) then return end

		if prefix == "ELVUI_VERSIONCHK" and not E.recievedOutOfDateMessage then
			if(tonumber(message) ~= nil and tonumber(message) > tonumber(E.version)) then
				E:Print(L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"]:gsub("ElvUI", E.UIName))

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
	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self.db.theme = nil;
	self.db.install_complete = nil;

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

	local AB = self:GetModule('ActionBars')
	AB.db = self.db.actionbar
	AB:UpdateButtonSettings()
	AB:UpdateMicroPositionDimensions()
	AB:Extra_SetAlpha()
	AB:Extra_SetScale()

	local bags = E:GetModule('Bags');
	bags.db = self.db.bags
	bags:Layout();
	bags:Layout(true);
	bags:PositionBagFrames()
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
	NP.db = self.db.nameplate
	NP:UpdateAllPlates()

	local M = self:GetModule("Misc")
	M:UpdateExpRepDimensions()
	M:EnableDisable_ExperienceBar()
	M:EnableDisable_ReputationBar()

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

	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	self:UpdateFrameTemplates()
	self:UpdateStatusBars()

	local LO = E:GetModule('Layout')
	LO:ToggleChatPanels()
	LO:BottomPanelVisibility()
	LO:TopPanelVisibility()
	LO:SetDataPanelStyle()

	self:GetModule('Blizzard'):ObjectiveFrameHeight()

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

function E:AddNonPetBattleFrames(event)
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(UIParent)
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function E:EnterVehicleHideFrames(event, unit)
	if unit ~= "player" then return; end
	
	for object in pairs(E.VehicleLocks) do
		object:SetParent(E.HiddenFrame)
	end
end

function E:ExitVehicleShowFrames(event, unit)
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
	--Add missing Stack Threshold
	if E.global.unitframe['aurafilters']['RaidDebuffs'].spells then
		local matchFound
		for k, v in pairs(E.global.unitframe['aurafilters']['RaidDebuffs'].spells) do
			if type(v) == 'table' then
				matchFound = false
				for k_,v_ in pairs(v) do
					if k_ == 'stackThreshold' then
						matchFound = true
					end
				end
			end

			if not matchFound then
				E.global.unitframe['aurafilters']['RaidDebuffs']['spells'][k].stackThreshold = 0
			end
		end
	end

	--Convert spellIDs saved as strings to numbers
	if E.global.unitframe['aurafilters']['Whitelist (Strict)'].spells then
		for k, v in pairs(E.global.unitframe['aurafilters']['Whitelist (Strict)'].spells) do
			if type(v) == 'table' then
				for k_,v_ in pairs(v) do
					if k_ == 'spellID' and type(v_) == "string" and tonumber(v_) then
						E.global.unitframe['aurafilters']['Whitelist (Strict)']['spells'][k].spellID = tonumber(v_)
					end
				end
			end
		end
	end

	if E.db.general.experience.width > 100 and E.db.general.experience.height > 100 then
		E.db.general.experience.width = P.general.experience.width
		E.db.general.experience.height = P.general.experience.height
		E:Print("Experience bar appears to be an odd shape. Resetting to default size.")
	end

	if E.db.general.reputation.width > 100 and E.db.general.reputation.height > 100 then
		E.db.general.reputation.width = P.general.reputation.width
		E.db.general.reputation.height = P.general.reputation.height
		E:Print("Reputation bar appears to be an odd shape. Resetting to default size.")
	end

	--Turns out that a chat height lower than 58 will cause the following error: Message: ..\FrameXML\FloatingChatFrame.lua line 1147: attempt to perform arithmetic on a nil value
	--This only happens if the datatext panel for the respective chat panel is enabled, leaving no room for the chat frame.
	--Minimum height has been increased to 60, convert any setting lower than this to the new minimum height.
	if E.db.chat.panelHeight < 60 then E.db.chat.panelHeight = 60 end
	if E.db.chat.panelHeightRight < 60 then E.db.chat.panelHeightRight = 60 end

	--Boss Frame auras have been changed to support friendly/enemy filters in case there is an encounter with a friendly boss
	--Try to convert any filter settings the user had to the new format
	if not E.db.bossAuraFiltersConverted then
		local tempBuffs = E.db.unitframe.units.boss.buffs
		local tempDebuffs = E.db.unitframe.units.boss.debuffs
		local filterSettings = {
			"playerOnly",
			"noConsolidated",
			"useBlacklist",
			"useWhitelist",
			"noDuration",
			"onlyDispellable",
			"bossAuras",
		}

		--Buffs
		for _, setting in pairs(filterSettings) do
			if type(E.db.unitframe.units.boss.buffs[setting]) == "boolean" then
				E.db.unitframe.units.boss.buffs[setting] = {friendly = tempBuffs[setting], enemy = tempBuffs[setting]}
			elseif type(E.db.unitframe.units.boss.buffs[setting]) ~= "table" or
			 (type(E.db.unitframe.units.boss.buffs[setting]) == "table" and (E.db.unitframe.units.boss.buffs[setting].friendly == nil or E.db.unitframe.units.boss.buffs[setting].enemy == nil)) then
				--Something went wrong here, reset filter setting to default
				E.db.unitframe.units.boss.buffs[setting] = nil
			end
		end

		--Debuffs
		for _, setting in pairs(filterSettings) do
			if not setting == "noConsolidated" then --There is no noConsolidated setting for Debuffs
				if type(E.db.unitframe.units.boss.debuffs[setting]) == "boolean" then
					E.db.unitframe.units.boss.debuffs[setting] = {friendly = tempDebuffs[setting], enemy = tempDebuffs[setting]}
				elseif type(E.db.unitframe.units.boss.debuffs[setting]) ~= "table" or
				 (type(E.db.unitframe.units.boss.debuffs[setting]) == "table" and (E.db.unitframe.units.boss.debuffs[setting].friendly == nil or E.db.unitframe.units.boss.debuffs[setting].enemy == nil)) then
					--Something went wrong here, reset filter setting to default
					E.db.unitframe.units.boss.debuffs[setting] = nil
				end
			end
		end

		E.db.bossAuraFiltersConverted = true
	end

	--Convert stored mover strings to use the new comma delimiter
	if E.db.movers then
		for mover, moverString in pairs(E.db.movers) do
		   if find(moverString, "\031") then --Old delimiter found
			  moverString = gsub(moverString, "\031", ",") --Replace with new delimiter
			  E.db.movers[mover] = moverString --Store updated mover string
		   end
		end
	end

	--Convert stored BuffIndicator key/value pairs to use spellID as key
	if not E.global.unitframe.buffwatchBackup then E.global.unitframe.buffwatchBackup = {} end
	local shouldRemove
	for class in pairs(E.global.unitframe.buffwatch) do
		if not E.global.unitframe.buffwatchBackup[class] then E.global.unitframe.buffwatchBackup[class] = {} end
		shouldRemove = {}
		for i, values in pairs(E.global.unitframe.buffwatch[class]) do
			if values.id then --Added by user, all info stored in SavedVariables
				if i ~= values.id then
					--Mark entry for removal
					shouldRemove[i] = true
				end
				E.global.unitframe.buffwatch[class][values.id] = values
				if not E.global.unitframe.buffwatchBackup[class][values.id] then E.global.unitframe.buffwatchBackup[class][values.id] = values end --Store a copy in case something goes wrong

			elseif G.oldBuffWatch[class] and G.oldBuffWatch[class][i] then
				--Default BuffIndicator, grab info from legacy table
				local spellID = G.oldBuffWatch[class][i].id
				if spellID then
					--Store a copy in case something goes wrong
					if not E.global.unitframe.buffwatchBackup[class][spellID] then
						E.global.unitframe.buffwatchBackup[class][spellID] = G.oldBuffWatch[class][i]
						E:CopyTable(E.global.unitframe.buffwatchBackup[class][spellID], values)
					end
					E.global.unitframe.buffwatch[class][spellID] = G.oldBuffWatch[class][i] --Store default info under new spellID key
					E:CopyTable(E.global.unitframe.buffwatch[class][spellID], values) --Transfer user-changed settings to new table
					E.global.unitframe.buffwatch[class][i] = nil --Remove old entry
				end
			end
		end
		--Remove old entries of user-added BuffIndicators
		for id in pairs(shouldRemove) do
			E.global.unitframe.buffwatch[class][id] = nil
		end
	end

	--Add missing .point, .xOffset and .yOffset values to Buff Indicators that are missing them for whatever reason
	for class in pairs(E.global.unitframe.buffwatch) do
		for _, values in pairs(E.global.unitframe.buffwatch[class]) do
			if not values.point then values.point = "TOPLEFT" end
			if not values.xOffset then values.xOffset = 0 end
			if not values.yOffset then values.yOffset = 0 end
		end
	end
	
	--Font Conversions
	local fonts = {
		["ElvUI Alt-Font"] = "Continuum Medium",
		["ElvUI Alt-Combat"] = "Die Die Die!",
		["ElvUI Combat"] = "Action Man",
		["ElvUI Font"] = "PT Sans Narrow",
		["ElvUI Pixel"] = "Homespun"
	}
	if fonts[E.db.general.font] then E.db.general.font = fonts[E.db.general.font] end
	if fonts[E.db.nameplate.font] then E.db.nameplate.font = fonts[E.db.nameplate.font] end
	if fonts[E.db.nameplate.buffs.font] then E.db.nameplate.buffs.font = fonts[E.db.nameplate.buffs.font] end
	if fonts[E.db.nameplate.debuffs.font] then E.db.nameplate.debuffs.font = fonts[E.db.nameplate.debuffs.font] end
	if fonts[E.db.bags.itemLevelFont] then E.db.bags.itemLevelFont = fonts[E.db.bags.itemLevelFont] end
	if fonts[E.db.bags.countFont] then E.db.bags.countFont = fonts[E.db.bags.countFont] end
	if fonts[E.db.auras.font] then E.db.auras.font = fonts[E.db.auras.font] end
	if fonts[E.db.auras.consolidatedBuffs.font] then E.db.auras.consolidatedBuffs.font = fonts[E.db.auras.consolidatedBuffs.font] end
	if fonts[E.db.chat.font] then E.db.chat.font = fonts[E.db.chat.font] end
	if fonts[E.db.chat.tabFont] then E.db.chat.tabFont = fonts[E.db.chat.tabFont] end
	if fonts[E.db.datatexts.font] then E.db.datatexts.font = fonts[E.db.datatexts.font] end
	if fonts[E.db.tooltip.font] then E.db.tooltip.font = fonts[E.db.tooltip.font] end
	if fonts[E.db.tooltip.healthBar.font] then E.db.tooltip.healthBar.font = fonts[E.db.tooltip.healthBar.font] end
	if fonts[E.db.unitframe.font] then E.db.unitframe.font = fonts[E.db.unitframe.font] end
	if fonts[E.db.unitframe.units.party.rdebuffs.font] then E.db.unitframe.units.party.rdebuffs.font = fonts[E.db.unitframe.units.party.rdebuffs.font] end
	if fonts[E.db.unitframe.units.raid.rdebuffs.font] then E.db.unitframe.units.raid.rdebuffs.font = fonts[E.db.unitframe.units.raid.rdebuffs.font] end
	if fonts[E.db.unitframe.units.raid40.rdebuffs.font] then E.db.unitframe.units.raid40.rdebuffs.font = fonts[E.db.unitframe.units.raid40.rdebuffs.font] end
	if fonts[E.db.unitframe.units.raidpet.rdebuffs.font] then E.db.unitframe.units.raidpet.rdebuffs.font = fonts[E.db.unitframe.units.raidpet.rdebuffs.font] end
	if fonts[E.db.unitframe.units.tank.rdebuffs.font] then E.db.unitframe.units.tank.rdebuffs.font = fonts[E.db.unitframe.units.tank.rdebuffs.font] end
	if fonts[E.db.unitframe.units.assist.rdebuffs.font] then E.db.unitframe.units.assist.rdebuffs.font = fonts[E.db.unitframe.units.assist.rdebuffs.font] end
	if fonts[E.db.actionbar.font] then E.db.actionbar.font = fonts[E.db.actionbar.font] end
	if fonts[E.private.dmgfont] then E.private.dmgfont = fonts[E.private.dmgfont] end
	if fonts[E.private.namefont] then E.private.namefont = fonts[E.private.namefont] end
	if fonts[E.private.chatBubbleFont] then E.private.chatBubbleFont = fonts[E.private.chatBubbleFont] end
	
	--Convert fonts for custom texts too
	local function ConvertCustomTextFont(unit)
		local db = E.db.unitframe.units[unit]
		
		if db and db.customTexts then
			for objectName in pairs(db.customTexts) do
				local objectDB = db.customTexts[objectName]
				if objectDB.font and fonts[objectDB.font] then
					objectDB.font = fonts[objectDB.font]
				end
			end
		end
	end
	local units = {
		"player", "target", "targettarget", "targettargettarget", "focus", "focustarget",
		"pet", "pettarget", "boss", "arena", "party", "raid", "raid40", "raidpet",
	}
	for _, unit in pairs(units) do
		ConvertCustomTextFont(unit)
	end

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
end

local CPU_USAGE = {}
local function CompareCPUDiff(module, minCalls)
	local greatestUsage, greatestCalls, greatestName
	local greatestDiff = 0;
	local mod = E:GetModule(module, true) or E

	for name, oldUsage in pairs(CPU_USAGE) do
		local newUsage, calls = GetFunctionCPUUsage(mod[name], true)
		local differance = newUsage - oldUsage

		if differance > greatestDiff and calls > (minCalls or 15) then
			greatestName = name
			greatestUsage = newUsage
			greatestCalls = calls
			greatestDiff = differance
		end
	end

	if(greatestName) then
		E:Print(greatestName.. " had the CPU usage of: "..greatestUsage.."ms. And has been called ".. greatestCalls.." times.")
	end
end

function E:GetTopCPUFunc(msg)
	local module, delay, minCalls = msg:match("^([^%s]+)%s+(.*)$")

	module = module == "nil" and nil or module
	delay = delay == "nil" and nil or tonumber(delay)
	minCalls = minCalls == "nil" and nil or tonumber(minCalls)

	twipe(CPU_USAGE)
	local mod = self:GetModule(module, true) or self
	for name, func in pairs(mod) do
		if type(mod[name]) == "function" and name ~= "GetModule" then
			CPU_USAGE[name] = GetFunctionCPUUsage(mod[name], true)
		end
	end

	self:Delay(delay or 5, CompareCPUDiff, module, minCalls)
	self:Print("Calculating CPU Usage..")
end

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)

	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.data, "ElvUI")
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateDB", self.privateVars);
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

	if(self.global.tukuiMode) then
		self.UIName = "Tukui"
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

	if self:IsFoolsDay() and not E.global.aprilFools and not self.global.tukuiMode then
		self:StaticPopup_Show("TUKUI_MODE")
	end


	if self.db.general.loginmessage then
		print(select(2, E:GetModule('Chat'):FindURL("CHAT_MSG_DUMMY", format(L["LOGIN_MSG"]:gsub("ElvUI", E.UIName), self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version)))..'.')
	end

	if self.global.tukuiMode then
		if(self:IsFoolsDay()) then
			self:ShowTukuiFrame()
		end
		self:Print("Thank you for being a good sport, type /aprilfools to revert the changes.")
	end
end