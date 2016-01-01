local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")
local Masque = LibStub("Masque", true)

--Cache global variables
--Lua functions
local _G = _G
local tonumber, pairs, error, unpack, select = tonumber, pairs, error, unpack, select
local print, type, collectgarbage, pcall, date = print, type, collectgarbage, pcall, date
local twipe, tinsert= table.wipe, tinsert
local floor = floor
local format, find, split, match, gsub = string.format, string.find, string.split, string.match, string.gsub
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
E["texts"] = {};
E['snapBars'] = {}
E["RegisteredModules"] = {}
E['RegisteredInitialModules'] = {}
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92}
E.FrameLocks = {}
E.CreditsList = {};
E.Spacing = 1;
E.Border = 2;
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
	print(self["media"].hexvaluecolor..'ElvUI:|r', ...)
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

	if role == "Tank" and IsInPvPGear then
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
	--self:UpdateFrameTemplates()

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
		_G[object]:SetParent(E.HiddenFrame)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "AddNonPetBattleFrames")
end

function E:AddNonPetBattleFrames(event)
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		_G[object]:SetParent(UIParent)
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
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
	if(self.private.actionbar) then
		if(self.private.actionbar.enablecd ~= nil) then
			self.private.cooldown.enable = self.private.actionbar.enablecd
			self.private.actionbar.enablecd = nil
		end

		if(self.db.actionbar.treshold ~= nil) then
			self.db.cooldown.threshold = self.db.actionbar.treshold
			self.db.actionbar.treshold = nil
		end

		if(self.db.actionbar.expiringcolor ~= nil) then
			self.db.cooldown.expiringColor = self.db.actionbar.expiringcolor
			self.db.actionbar.expiringcolor = nil
		end

		if(self.db.actionbar.secondscolor ~= nil) then
			self.db.cooldown.secondsColor = self.db.actionbar.secondscolor
			self.db.actionbar.secondscolor = nil
		end

		if(self.db.actionbar.minutescolor ~= nil) then
			self.db.cooldown.minutesColor = self.db.actionbar.minutescolor
			self.db.actionbar.minutescolor = nil
		end

		if(self.db.actionbar.hourscolor ~= nil) then
			self.db.cooldown.hoursColor = self.db.actionbar.hourscolor
			self.db.actionbar.hourscolor = nil
		end

		if(self.db.actionbar.dayscolor ~= nil) then
			self.db.cooldown.daysColor = self.db.actionbar.dayscolor
			self.db.actionbar.dayscolor = nil
		end
	end
	
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

	self.db.unitframe.units.raid10 = nil
	self.db.unitframe.units.raid25 = nil

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
end