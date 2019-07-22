local ElvUI = select(2, ...)

local gameLocale
do -- Locale doesn't exist yet, make it exist.
	local convert = {['enGB'] = 'enUS', ['esES'] = 'esMX', ['itIT'] = 'enUS'}
	local lang = GetLocale()

	gameLocale = convert[lang] or lang or 'enUS'
	ElvUI[2] = ElvUI[1].Libs.ACL:GetLocale('ElvUI', gameLocale)
end

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local ActionBars = E:GetModule('ActionBars')
local AFK = E:GetModule('AFK')
local Auras = E:GetModule('Auras')
local Bags = E:GetModule('Bags')
local Blizzard = E:GetModule('Blizzard')
local Chat = E:GetModule('Chat')
local DataBars = E:GetModule('DataBars')
local DataTexts = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Minimap = E:GetModule('Minimap')
local NamePlates = E:GetModule('NamePlates')
local Threat = E:GetModule('Threat')
local Tooltip = E:GetModule('Tooltip')
local Totems = E:GetModule('Totems')
local UnitFrames = E:GetModule('UnitFrames')

local LSM = E.Libs.LSM
local Masque = E.Libs.Masque

--Lua functions
local _G = _G
local tonumber, pairs, ipairs, error, unpack, select, tostring = tonumber, pairs, ipairs, error, unpack, select, tostring
local assert, type, xpcall, date, print = assert, type, xpcall, date, print
local twipe, tinsert, tremove, next = wipe, tinsert, tremove, next
local gsub, strmatch, strjoin = gsub, strmatch, strjoin
local format, find, strrep, len, sub = format, strfind, strrep, strlen, strsub
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVar, SetCVar, GetCVarBool = GetCVar, SetCVar, GetCVarBool
local GetFunctionCPUUsage = GetFunctionCPUUsage
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsInInstance, IsInGuild = IsInInstance, IsInGuild
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local GetAddOnEnableState = GetAddOnEnableState
local UIParentLoadAddOn = UIParentLoadAddOn
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitStat, UnitAttackPower = UnitStat, UnitAttackPower
local hooksecurefunc = hooksecurefunc
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_Timer_After = C_Timer.After
-- GLOBALS: ElvUIPlayerBuffs, ElvUIPlayerDebuffs

--Constants
E.noop = function() end
E.title = format('|cfffe7b2c%s |r', 'ElvUI')
E.myfaction, E.myLocalizedFaction = UnitFactionGroup('player')
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass('player')
E.myLocalizedRace, E.myrace = UnitRace('player')
E.myname = UnitName('player')
E.myrealm = GetRealmName()
E.myspec = GetSpecialization()
E.version = GetAddOnMetadata('ElvUI', 'Version')
E.wowpatch, E.wowbuild = GetBuildInfo()
E.wowbuild = tonumber(E.wowbuild)
E.resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar('gxWindowedResolution') --only used for now in our install.lua line 779
E.screenwidth, E.screenheight = GetPhysicalScreenSize()
E.isMacClient = IsMacClient()
E.NewSign = '|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:14:14|t' -- not used by ElvUI yet, but plugins like BenikUI and MerathilisUI use it.
E.InfoColor = '|cfffe7b2c'

--Tables
E.media = {}
E.frames = {}
E.unitFrameElements = {}
E.statusBars = {}
E.texts = {}
E.snapBars = {}
E.RegisteredModules = {}
E.RegisteredInitialModules = {}
E.valueColorUpdateFuncs = {}
E.TexCoords = {.08, .92, .08, .92}
E.FrameLocks = {}
E.VehicleLocks = {}
E.CreditsList = {}

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
	},
	['MAGE'] = {
		['Curse'] = true
	}
}

E.ClassRole = {
	PALADIN = {
		[1] = 'Caster',
		[2] = 'Tank',
		[3] = 'Melee',
	},
	PRIEST = 'Caster',
	WARLOCK = 'Caster',
	WARRIOR = {
		[1] = 'Melee',
		[2] = 'Melee',
		[3] = 'Tank',
	},
	HUNTER = 'Melee',
	SHAMAN = {
		[1] = 'Caster',
		[2] = 'Melee',
		[3] = 'Caster',
	},
	ROGUE = 'Melee',
	MAGE = 'Caster',
	DEATHKNIGHT = {
		[1] = 'Tank',
		[2] = 'Melee',
		[3] = 'Melee',
	},
	DRUID = {
		[1] = 'Caster',
		[2] = 'Melee',
		[3] = 'Tank',
		[4] = 'Caster'
	},
	MONK = {
		[1] = 'Tank',
		[2] = 'Caster',
		[3] = 'Melee',
	},
	DEMONHUNTER = {
		[1] = 'Melee',
		[2] = 'Tank'
	},
}

E.DEFAULT_FILTER = {}
for filter, tbl in pairs(G.unitframe.aurafilters) do
	E.DEFAULT_FILTER[filter] = tbl.type
end

local hexvaluecolor
function E:Print(...)
	hexvaluecolor = self.media.hexvaluecolor or '|cff00b3ff'
	(_G[self.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', hexvaluecolor, 'ElvUI:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

--Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99,
	colorStr = 'fcfcfc'
}

-- Socket Type info from 8.2
E.GemTypeInfo = {
	Yellow = {r = 0.97, g = 0.82, b = 0.29},
	Red = {r = 1, g = 0.47, b = 0.47},
	Blue = {r = 0.47, g = 0.67, b = 1},
	Hydraulic = {r = 1, g = 1, b = 1},
	Cogwheel = {r = 1, g = 1, b = 1},
	Meta = {r = 1, g = 1, b = 1},
	Prismatic = {r = 1, g = 1, b = 1},
	PunchcardRed = {r = 1, g = 0.47, b = 0.47},
	PunchcardYellow = {r = 0.97, g = 0.82, b = 0.29},
	PunchcardBlue = {r = 0.47, g = 0.67, b = 1},
}

function E:GetPlayerRole()
	local assignedRole = UnitGroupRolesAssigned('player')
	if assignedRole == 'NONE' then
		return E.myspec and GetSpecializationRole(E.myspec)
	end

	return assignedRole
end

function E:GrabColorPickerValues(r, g, b)
	-- we must block the execution path to `ColorCallback` in `AceGUIWidget-ColorPicker-ElvUI`
	-- in order to prevent an infinite loop from `OnValueChanged` when passing into `E.UpdateMedia` which eventually leads here again.
	_G.ColorPickerFrame.noColorCallback = true

	-- grab old values
	local oldR, oldG, oldB = _G.ColorPickerFrame:GetColorRGB()

	-- set and define the new values
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
	r, g, b = _G.ColorPickerFrame:GetColorRGB()

	-- swap back to the old values
	if oldR then _G.ColorPickerFrame:SetColorRGB(oldR, oldG, oldB) end

	-- free it up..
	_G.ColorPickerFrame.noColorCallback = nil

	return r, g, b
end

--Basically check if another class border is being used on a class that doesn't match. And then return true if a match is found.
function E:CheckClassColor(r, g, b)
	r, g, b = E:GrabColorPickerValues(r, g, b)
	local matchFound = false
	for class in pairs(_G.RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			local colorTable = class == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class])
			local red, green, blue = E:GrabColorPickerValues(colorTable.r, colorTable.g, colorTable.b)
			if red == r and green == g and blue == b then
				matchFound = true
			end
		end
	end

	return matchFound
end

function E:SetColorTable(t, data)
	if not data.r or not data.g or not data.b then
		error('SetColorTable: Could not unpack color values.')
	end

	if t and (type(t) == 'table') then
		t[1], t[2], t[3], t[4] = E:UpdateColorTable(data)
	else
		t = E:GetColorTable(data)
	end

	return t
end

function E:UpdateColorTable(data)
	if not data.r or not data.g or not data.b then
		error('UpdateColorTable: Could not unpack color values.')
	end

	if (data.r > 1 or data.r < 0) then data.r = 1 end
	if (data.g > 1 or data.g < 0) then data.g = 1 end
	if (data.b > 1 or data.b < 0) then data.b = 1 end
	if data.a and (data.a > 1 or data.a < 0) then data.a = 1 end

	if data.a then
		return data.r, data.g, data.b, data.a
	else
		return data.r, data.g, data.b
	end
end

function E:GetColorTable(data)
	if not data.r or not data.g or not data.b then
		error('GetColorTable: Could not unpack color values.')
	end

	if (data.r > 1 or data.r < 0) then data.r = 1 end
	if (data.g > 1 or data.g < 0) then data.g = 1 end
	if (data.b > 1 or data.b < 0) then data.b = 1 end
	if data.a and (data.a > 1 or data.a < 0) then data.a = 1 end

	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()
	if not self.db.general or not self.private.general then return end --Prevent rare nil value errors

	--Fonts
	self.media.normFont = LSM:Fetch('font', self.db.general.font)
	self.media.combatFont = LSM:Fetch('font', self.private.general.dmgfont)

	--Textures
	self.media.blankTex = LSM:Fetch('background', 'ElvUI Blank')
	self.media.normTex = LSM:Fetch('statusbar', self.private.general.normTex)
	self.media.glossTex = LSM:Fetch('statusbar', self.private.general.glossTex)

	--Border Color
	local border = E.db.general.bordercolor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
		E.db.general.bordercolor.r = classColor.r
		E.db.general.bordercolor.g = classColor.g
		E.db.general.bordercolor.b = classColor.b
	end

	self.media.bordercolor = {border.r, border.g, border.b}

	--UnitFrame Border Color
	border = E.db.unitframe.colors.borderColor
	if self:CheckClassColor(border.r, border.g, border.b) then
		local classColor = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
		E.db.unitframe.colors.borderColor.r = classColor.r
		E.db.unitframe.colors.borderColor.g = classColor.g
		E.db.unitframe.colors.borderColor.b = classColor.b
	end
	self.media.unitframeBorderColor = {border.r, border.g, border.b}

	--Backdrop Color
	self.media.backdropcolor = E:SetColorTable(self.media.backdropcolor, self.db.general.backdropcolor)

	--Backdrop Fade Color
	self.media.backdropfadecolor = E:SetColorTable(self.media.backdropfadecolor, self.db.general.backdropfadecolor)

	--Value Color
	local value = self.db.general.valuecolor

	if self:CheckClassColor(value.r, value.g, value.b) then
		value = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
		self.db.general.valuecolor.r = value.r
		self.db.general.valuecolor.g = value.g
		self.db.general.valuecolor.b = value.b
	end

	self.media.hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self.media.rgbvaluecolor = {value.r, value.g, value.b}

	local LeftChatPanel, RightChatPanel = _G.LeftChatPanel, _G.RightChatPanel
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)

		local a = E.db.general.backdropfadecolor.a or 0.5
		LeftChatPanel.tex:SetAlpha(a)
		RightChatPanel.tex:SetAlpha(a)
	end

	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

E.LockedCVars = {}
E.IgnoredCVars = {}

function E:PLAYER_REGEN_ENABLED(_)
	if self.CVarUpdate then
		for cvarName, value in pairs(self.LockedCVars) do
			if (not self.IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value)) then
				SetCVar(cvarName, value)
			end
		end
		self.CVarUpdate = nil
	end
end

local function CVAR_UPDATE(cvarName, value)
	if not E.IgnoredCVars[cvarName] and E.LockedCVars[cvarName] and E.LockedCVars[cvarName] ~= value then
		if InCombatLockdown() then
			E.CVarUpdate = true
			return
		end

		SetCVar(cvarName, E.LockedCVars[cvarName])
	end
end

hooksecurefunc('SetCVar', CVAR_UPDATE)
function E:LockCVar(cvarName, value)
	if GetCVar(cvarName) ~= value then
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
local function LSMCallback() E:UpdateMedia() end
LSM.RegisterCallback(E, 'LibSharedMedia_Registered', LSMCallback)

local MasqueGroupState = {}
local MasqueGroupToTableElement = {
	['ActionBars'] = {'actionbar', 'actionbars'},
	['Pet Bar'] = {'actionbar', 'petBar'},
	['Stance Bar'] = {'actionbar', 'stanceBar'},
	['Buffs'] = {'auras', 'buffs'},
	['Debuffs'] = {'auras', 'debuffs'},
}

local function MasqueCallback(_, Group, _, _, _, _, Disabled)
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
	Masque:Register('ElvUI', MasqueCallback)
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:NEUTRAL_FACTION_SELECT_RESULT()
	local newFaction, newLocalizedFaction = UnitFactionGroup('player')
	if E.myfaction ~= newFaction then
		E.myfaction, E.myLocalizedFaction = newFaction, newLocalizedFaction
	end
end

function E:PLAYER_ENTERING_WORLD()
	self:MapInfo_Update()
	self:CheckRole()

	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true
	end

	local _, instanceType = IsInInstance()
	if instanceType == 'pvp' then
		self.BGTimer = self:ScheduleRepeatingTimer('RequestBGInfo', 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil
	end
end

function E:ValueFuncCall()
	for func in pairs(self.valueColorUpdateFuncs) do
		func(self.media.hexvaluecolor, unpack(self.media.rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame in pairs(self.frames) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex, nil, frame.forcePixelMode)
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreFrameTemplates then
				frame:SetTemplate(frame.template, frame.glossTex, nil, frame.forcePixelMode, frame.isUnitFrameElement)
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBorderColors()
	for frame in pairs(self.frames) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == 'Default' or frame.template == 'Transparent' then
					frame:SetBackdropBorderColor(unpack(self.media.bordercolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreBorderColors then
				if frame.template == 'Default' or frame.template == 'Transparent' then
					frame:SetBackdropBorderColor(unpack(self.media.unitframeBorderColor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateBackdropColors()
	for frame in pairs(self.frames) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreBackdropColors then
				if frame.template == 'Default' then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == 'Transparent' then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.frames[frame] = nil
		end
	end

	for frame in pairs(self.unitFrameElements) do
		if frame and frame.template and not frame.ignoreUpdates then
			if not frame.ignoreBackdropColors then
				if frame.template == 'Default' then
					frame:SetBackdropColor(unpack(self.media.backdropcolor))
				elseif frame.template == 'Transparent' then
					frame:SetBackdropColor(unpack(self.media.backdropfadecolor))
				end
			end
		else
			self.unitFrameElements[frame] = nil
		end
	end
end

function E:UpdateFontTemplates()
	for text in pairs(self.texts) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle)
		else
			self.texts[text] = nil
		end
	end
end

function E:RegisterStatusBar(statusBar)
	tinsert(self.statusBars, statusBar)
end

function E:UpdateStatusBars()
	for _, statusBar in pairs(self.statusBars) do
		if statusBar and statusBar:IsObjectType('StatusBar') then
			statusBar:SetStatusBarTexture(self.media.normTex)
		elseif statusBar and statusBar:IsObjectType('Texture') then
			statusBar:SetTexture(self.media.normTex)
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', _G.UIParent)
E.UIParent:SetFrameLevel(_G.UIParent:GetFrameLevel())
E.UIParent:SetSize(_G.UIParent:GetSize())
E.UIParent:SetPoint('BOTTOM')
E.UIParent.origHeight = E.UIParent:GetHeight()
E.snapBars[#E.snapBars + 1] = E.UIParent

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()

function E:IsDispellableByMe(debuffType)
	if not self.DispelClasses[self.myclass] then return end

	if self.DispelClasses[self.myclass][debuffType] then
		return true
	end
end

function E:CheckRole()
	self.myspec = GetSpecialization()
	self.myrole = E:GetPlayerRole()

	-- myrole = group role; TANK, HEALER, DAMAGER
	-- role   = class role; Tank, Melee, Caster

	local role
	if type(self.ClassRole[self.myclass]) == 'string' then
		role = self.ClassRole[self.myclass]
	elseif self.myspec then
		role = self.ClassRole[self.myclass][self.myspec]
	end

	if not role then
		local playerint = select(2, UnitStat('player', 4))
		local playeragi	= select(2, UnitStat('player', 2))
		local base, posBuff, negBuff = UnitAttackPower('player')
		local playerap = base + posBuff + negBuff

		if (playerap > playerint) or (playeragi > playerint) then
			role = 'Melee'
		else
			role = 'Caster'
		end
	end

	if self.role ~= role then
		self.role = role
		self.callbacks:Fire('RoleChanged')
	end

	if self.myrole and self.DispelClasses[self.myclass] ~= nil then
		self.DispelClasses[self.myclass].Magic = (self.myrole == 'HEALER')
	end
end

do -- other non-english locales require this
	E.UnlocalizedClasses = {}
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do E.UnlocalizedClasses[v] = k end
	for k,v in pairs(_G.LOCALIZED_CLASS_NAMES_FEMALE) do E.UnlocalizedClasses[v] = k end

	function E:UnlocalizedClassName(className)
		return (className and className ~= "") and E.UnlocalizedClasses[className]
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs.INCOMPATIBLE_ADDON.button1 = addon
	E.PopupDialogs.INCOMPATIBLE_ADDON.button2 = 'ElvUI '..module
	E.PopupDialogs.INCOMPATIBLE_ADDON.addon = addon
	E.PopupDialogs.INCOMPATIBLE_ADDON.module = module
	E:StaticPopup_Show('INCOMPATIBLE_ADDON', addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return end
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
		return true
	else
		return false
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= 'table' then currentTable = {} end

	if type(defaultTable) == 'table' then
		for option, value in pairs(defaultTable) do
			if type(value) == 'table' then
				value = self:CopyTable(currentTable[option], value)
			end

			currentTable[option] = value
		end
	end

	return currentTable
end

function E:RemoveEmptySubTables(tbl)
	if type(tbl) ~= 'table' then
		E:Print('Bad argument #1 to \'RemoveEmptySubTables\' (table expected)')
		return
	end

	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			if next(v) == nil then
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
	if type(cleanTable) ~= 'table' then
		E:Print('Bad argument #1 to \'RemoveTableDuplicates\' (table expected)')
		return
	end
	if type(checkTable) ~=  'table' then
		E:Print('Bad argument #2 to \'RemoveTableDuplicates\' (table expected)')
		return
	end

	local cleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == 'table' and checkTable[option] and type(checkTable[option]) == 'table' then
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

--Compare 2 tables and remove blacklisted key/value pairs
--param cleanTable : table you want cleaned
--param blacklistTable : table you want to check against.
--return : a copy of cleanTable with blacklisted key/value pairs removed
function E:FilterTableFromBlacklist(cleanTable, blacklistTable)
	if type(cleanTable) ~= 'table' then
		E:Print('Bad argument #1 to \'FilterTableFromBlacklist\' (table expected)')
		return
	end
	if type(blacklistTable) ~=  'table' then
		E:Print('Bad argument #2 to \'FilterTableFromBlacklist\' (table expected)')
		return
	end

	local cleaned = {}
	for option, value in pairs(cleanTable) do
		if type(value) == 'table' and blacklistTable[option] and type(blacklistTable[option]) == 'table' then
			cleaned[option] = self:FilterTableFromBlacklist(value, blacklistTable[option])
		else
			-- Filter out blacklisted keys
			if (blacklistTable[option] ~= true) then
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
	if type(inTable) ~= 'table' then
		E:Print('Invalid argument #1 to E:TableToLuaString (table expected)')
		return
	end

	local ret = '{\n'
	local function recurse(table, level)
		for i,v in pairs(table) do
			ret = ret..strrep('    ', level)..'['
			if type(i) == 'string' then
				ret = ret..'"'..i..'"'
			else
				ret = ret..i
			end
			ret = ret..'] = '

			if type(v) == 'number' then
				ret = ret..v..',\n'
			elseif type(v) == 'string' then
				ret = ret..'"'..v:gsub('\\', '\\\\'):gsub('\n', '\\n'):gsub('"', '\\"'):gsub('\124', '\124\124')..'",\n'
			elseif type(v) == 'boolean' then
				if v then
					ret = ret..'true,\n'
				else
					ret = ret..'false,\n'
				end
			elseif type(v) == 'table' then
				ret = ret..'{\n'
				recurse(v, level + 1)
				ret = ret..strrep('    ', level)..'},\n'
			else
				ret = ret..'"'..tostring(v)..'",\n'
			end
		end
	end

	if inTable then
		recurse(inTable, 1)
	end
	ret = ret..'}'

	return ret
end

local profileFormat = {
	['profile'] = 'E.db',
	['private'] = 'E.private',
	['global'] = 'E.global',
	['filters'] = 'E.global',
	['styleFilters'] = 'E.global',
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
			if type(v) == 'string' then
				str = str..'["'..v..'"]'
			else
				str = str..'['..v..']'
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

			returnString = returnString..'['

			if type(k) == 'string' then
				returnString = returnString..'"'..k..'"'
			else
				returnString = returnString..k
			end

			if type(v) == 'table' then
				tinsert(lineStructureTable, k)
				sameLine = true
				returnString = returnString..']'
				recurse(v)
			else
				sameLine = false
				returnString = returnString..'] = '

				if type(v) == 'number' then
					returnString = returnString..v..'\n'
				elseif type(v) == 'string' then
					returnString = returnString..'"'..v:gsub('\\', '\\\\'):gsub('\n', '\\n'):gsub('"', '\\"'):gsub('\124', '\124\124')..'"\n'
				elseif type(v) == 'boolean' then
					if v then
						returnString = returnString..'true\n'
					else
						returnString = returnString..'false\n'
					end
				else
					returnString = returnString..'"'..tostring(v)..'"\n'
				end
			end
		end

		tremove(lineStructureTable)
		lineStructure = buildLineStructure()
	end

	if inTable and profileType then
		recurse(inTable)
	end

	return returnString
end

--Split string by multi-character delimiter (the strsplit / string.split function provided by WoW doesn't allow multi-character delimiter)
function E:SplitString(s, delim)
	assert(type (delim) == 'string' and len(delim) > 0, 'bad delimiter')

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

local SendMessageWaiting -- only allow 1 delay at a time regardless of eventing
function E:SendMessage()
	if IsInRaid() then
		C_ChatInfo_SendAddonMessage('ELVUI_VERSIONCHK', E.version, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID')
	elseif IsInGroup() then
		C_ChatInfo_SendAddonMessage('ELVUI_VERSIONCHK', E.version, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'PARTY')
	elseif IsInGuild() then
		C_ChatInfo_SendAddonMessage('ELVUI_VERSIONCHK', E.version, 'GUILD')
	end

	SendMessageWaiting = nil
end

local SendRecieveGroupSize = 0
local myRealm = gsub(E.myrealm,'[%s%-]','')
local myName = E.myname..'-'..myRealm
local function SendRecieve(_, event, prefix, message, _, sender)
	if event == 'CHAT_MSG_ADDON' then
		if sender == myName then return end
		if prefix == 'ELVUI_VERSIONCHK' then
			local msg, ver = tonumber(message), tonumber(E.version)
			local inCombat = InCombatLockdown()

			if ver ~= G.general.version then
				if not E.shownUpdatedWhileRunningPopup and not inCombat then
					E:StaticPopup_Show('ELVUI_UPDATED_WHILE_RUNNING', nil, nil, {mismatch = ver > G.general.version})

					E.shownUpdatedWhileRunningPopup = true
				end
			elseif msg and (msg > ver) then -- you're outdated D:
				if not E.recievedOutOfDateMessage then
					E:Print(L["ElvUI is out of date. You can download the newest version from www.tukui.org. Get premium membership and have ElvUI automatically updated with the Tukui Client!"])

					if msg and ((msg - ver) >= 0.05) and not inCombat then
						E:StaticPopup_Show('ELVUI_UPDATE_AVAILABLE')
					end

					E.recievedOutOfDateMessage = true
				end
			end
		end
	elseif event == 'GROUP_ROSTER_UPDATE' then
		local num = GetNumGroupMembers()
		if num ~= SendRecieveGroupSize then
			if num > 1 and num > SendRecieveGroupSize then
				if not SendMessageWaiting then
					SendMessageWaiting = E:Delay(10, E.SendMessage)
				end
			end
			SendRecieveGroupSize = num
		end
	elseif event == 'PLAYER_ENTERING_WORLD' then
		if not SendMessageWaiting then
			SendMessageWaiting = E:Delay(10, E.SendMessage)
		end
	end
end

_G.C_ChatInfo.RegisterAddonMessagePrefix('ELVUI_VERSIONCHK')

local f = CreateFrame('Frame')
f:RegisterEvent('CHAT_MSG_ADDON')
f:RegisterEvent('GROUP_ROSTER_UPDATE')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:SetScript('OnEvent', SendRecieve)

function E:UpdateStart(skipCallback, skipUpdateDB)
	if not skipUpdateDB then
		E:UpdateDB()
	end

	E:UpdateMoverPositions()
	E:UpdateMediaItems()
	E:UpdateUnitFrames()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateDB()
	E.private = E.charSettings.profile
	E.db = E.data.profile
	E.global = E.data.global
	E.db.theme = nil
	E.db.install_complete = nil

	E:DBConversions()
	Auras.db = E.db.auras
	ActionBars.db = E.db.actionbar
	Bags.db = E.db.bags
	Chat.db = E.db.chat
	DataBars.db = E.db.databars
	DataTexts.db = E.db.datatexts
	NamePlates.db = E.db.nameplates
	Tooltip.db = E.db.tooltip
	UnitFrames.db = E.db.unitframe
	Threat.db = E.db.general.threat
	Totems.db = E.db.general.totems

	--Not part of staggered update
end

function E:UpdateMoverPositions()
	--The mover is positioned before it is resized, which causes issues for unitframes
	--Allow movers to be "pushed" outside the screen, when they are resized they should be back in the screen area.
	--We set movers to be clamped again at the bottom of this function.
	E:SetMoversClampedToScreen(false)
	E:SetMoversPositions()

	--Not part of staggered update
end

function E:UpdateUnitFrames()
	if E.private.unitframe.enable then
		UnitFrames:Update_AllFrames()
	end

	--Not part of staggered update
end

function E:UpdateMediaItems(skipCallback)
	E:UpdateMedia()
	E:UpdateFrameTemplates()
	E:UpdateStatusBars()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateLayout(skipCallback)
	Layout:ToggleChatPanels()
	Layout:BottomPanelVisibility()
	Layout:TopPanelVisibility()
	Layout:SetDataPanelStyle()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateActionBars(skipCallback)
	ActionBars:Extra_SetAlpha()
	ActionBars:Extra_SetScale()
	ActionBars:ToggleCooldownOptions()
	ActionBars:UpdateButtonSettings()
	ActionBars:UpdateMicroPositionDimensions()
	ActionBars:UpdatePetCooldownSettings()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateNamePlates(skipCallback)
	NamePlates:ConfigureAll()
	NamePlates:StyleFilterInitialize()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateTooltip()
	-- for plugins :3
end

function E:UpdateBags(skipCallback)
	Bags:Layout()
	Bags:Layout(true)
	Bags:SizeAndPositionBagBar()
	Bags:UpdateCountDisplay()
	Bags:UpdateItemLevelDisplay()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateChat(skipCallback)
	Chat:PositionChat(true)
	Chat:SetupChat()
	Chat:UpdateAnchors()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateDataBars(skipCallback)
	DataBars:EnableDisable_AzeriteBar()
	DataBars:EnableDisable_ExperienceBar()
	DataBars:EnableDisable_HonorBar()
	DataBars:EnableDisable_ReputationBar()
	DataBars:UpdateDataBarDimensions()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateDataTexts(skipCallback)
	DataTexts:LoadDataTexts()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateMinimap(skipCallback)
	Minimap:UpdateSettings()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateAuras(skipCallback)
	if ElvUIPlayerBuffs then Auras:UpdateHeader(ElvUIPlayerBuffs) end
	if ElvUIPlayerDebuffs then Auras:UpdateHeader(ElvUIPlayerDebuffs) end

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateMisc(skipCallback)
	AFK:Toggle()
	Blizzard:SetObjectiveFrameHeight()

	Threat:ToggleEnable()
	Threat:UpdatePosition()

	Totems:PositionAndSize()
	Totems:ToggleEnable()

	if not skipCallback then
		E.callbacks:Fire("StaggeredUpdate")
	end
end

function E:UpdateEnd()
	E:UpdateCooldownSettings('all')

	if E.RefreshGUI then
		E:RefreshGUI()
	end

	E:SetMoversClampedToScreen(true) -- Go back to using clamp after resizing has taken place.

	if (E.installSetup ~= true) and (E.private.install_complete == nil or (E.private.install_complete and type(E.private.install_complete) == 'boolean') or (E.private.install_complete and type(tonumber(E.private.install_complete)) == 'number' and tonumber(E.private.install_complete) <= 3.83)) then
		E.installSetup = nil
		E:Install()
	end

	if E.staggerUpdateRunning then
		--We're doing a staggered update, but plugins expect the old UpdateAll to be called
		--So call it, but skip updates inside it
		E:UpdateAll(false)
	end

	--Done updating, let code now
	E.staggerUpdateRunning = false
end

local staggerDelay = 0.02
local staggerTable = {}
local function CallStaggeredUpdate()
	local nextUpdate, nextDelay = staggerTable[1]
	if nextUpdate then
		tremove(staggerTable, 1)

		if nextUpdate == 'UpdateNamePlates' or nextUpdate == 'UpdateBags' then
			nextDelay = 0.05
		end

		C_Timer_After(nextDelay or staggerDelay, E[nextUpdate])
	end
end

E:RegisterCallback("StaggeredUpdate", CallStaggeredUpdate)

function E:StaggeredUpdateAll(event, installSetup)
	if not self.initialized then
		C_Timer_After(1, function()
			E:StaggeredUpdateAll(event, installSetup)
		end)

		return
	end

	self.installSetup = installSetup
	if (installSetup or event and event == "OnProfileChanged" or event == "OnProfileCopied") and not self.staggerUpdateRunning then
		tinsert(staggerTable, "UpdateLayout")
		if E.private.actionbar.enable then
			tinsert(staggerTable, "UpdateActionBars")
		end
		if E.private.nameplates.enable then
			tinsert(staggerTable, "UpdateNamePlates")
		end
		if E.private.bags.enable then
			tinsert(staggerTable, "UpdateBags")
		end
		if E.private.chat.enable then
			tinsert(staggerTable, "UpdateChat")
		end
		tinsert(staggerTable, "UpdateDataBars")
		tinsert(staggerTable, "UpdateDataTexts")
		if E.private.general.minimap.enable then
			tinsert(staggerTable, "UpdateMinimap")
		end
		if ElvUIPlayerBuffs or ElvUIPlayerDebuffs then
			tinsert(staggerTable, "UpdateAuras")
		end
		tinsert(staggerTable, "UpdateMisc")
		tinsert(staggerTable, "UpdateEnd")

		--Stagger updates
		self.staggerUpdateRunning = true
		self:UpdateStart()
	else
		--Fire away
		E:UpdateAll(true)
	end
end

function E:UpdateAll(doUpdates)
	if doUpdates then
		E:UpdateStart(true)

		self:UpdateLayout()
		self:UpdateTooltip()
		self:UpdateActionBars()
		self:UpdateBags()
		self:UpdateChat()
		self:UpdateDataBars()
		self:UpdateDataTexts()
		self:UpdateMinimap()
		self:UpdateNamePlates()
		self:UpdateAuras()
		self:UpdateMisc()
		self:UpdateEnd()
	end
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		obj:SetParent(E.HiddenFrame)
	end

	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'AddNonPetBattleFrames')
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, data in pairs(E.FrameLocks) do
		local obj = _G[object] or object
		local parent, strata
		if type(data) == 'table' then
			parent, strata = data.parent, data.strata
		elseif data == true then
			parent = _G.UIParent
		end
		obj:SetParent(parent)
		if strata then
			obj:SetFrameStrata(strata)
		end
	end

	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
end

function E:RegisterPetBattleHideFrames(object, originalParent, originalStrata)
	if not object or not originalParent then
		E:Print('Error. Usage: RegisterPetBattleHideFrames(object, originalParent, originalStrata)')
		return
	end

	object = _G[object] or object
	--If already doing pokemon
	if C_PetBattles_IsInBattle() then
		object:SetParent(E.HiddenFrame)
	end
	E.FrameLocks[object] = {
		['parent'] = originalParent,
		['strata'] = originalStrata or nil,
	}
end

function E:UnregisterPetBattleHideFrames(object)
	if not object then
		E:Print('Error. Usage: UnregisterPetBattleHideFrames(object)')
		return
	end

	object = _G[object] or object
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
	if UnitHasVehicleUI('player') then
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

local EventRegister = {}
local EventFrame = CreateFrame('Frame')
EventFrame:SetScript('OnEvent', function(_, event, ...)
	if EventRegister[event] then
		for object, functions in pairs(EventRegister[event]) do
			for _, func in ipairs(functions) do
				--Call the functions that are registered with this object, and pass the object and other arguments back
				func(object, event, ...)
			end
		end
	end
end)

--- Registers specified event and adds specified func to be called for the specified object.
-- Unless all parameters are supplied it will not register.
-- If the specified object has already been registered for the specified event
-- then it will just add the specified func to a table of functions that should be called.
-- When a registered event is triggered, then the registered function is called with
-- the object as first parameter, then event, and then all the parameters for the event itself.
-- @param event The event you want to register.
-- @param object The object you want to register the event for.
-- @param func The function you want executed for this object.
function E:RegisterEventForObject(event, object, func)
	if not event or not object or not func then
		E:Print('Error. Usage: RegisterEventForObject(event, object, func)')
		return
	end

	if not EventRegister[event] then --Check if event has already been registered
		EventRegister[event] = {}
		EventFrame:RegisterEvent(event)
	else
		if not EventRegister[event][object] then --Check if this object has already been registered
			EventRegister[event][object] = {func}
		else
			tinsert(EventRegister[event][object], func) --Add func that should be called for this object on this event
		end
	end
end

--- Unregisters specified function for the specified object on the specified event.
-- Unless all parameters are supplied it will not unregister.
-- @param event The event you want to unregister an object from.
-- @param object The object you want to unregister a func from.
-- @param func The function you want unregistered for the object.
function E:UnregisterEventForObject(event, object, func)
	if not event or not object or not func then
		E:Print('Error. Usage: UnregisterEventForObject(event, object, func)')
		return
	end

	--Find the specified function for the specified object and remove it from the register
	if EventRegister[event] and EventRegister[event][object] then
		for index, registeredFunc in ipairs(EventRegister[event][object]) do
			if func == registeredFunc then
				tremove(EventRegister[event][object], index)
				break
			end
		end

		--If this object no longer has any functions registered then remove it from the register
		if #EventRegister[event][object] == 0 then
			EventRegister[event][object] = nil
		end

		--If this event no longer has any objects registered then unregister it and remove it from the register
		if not next(EventRegister[event]) then
			EventFrame:UnregisterEvent(event)
			EventRegister[event] = nil
		end
	end
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

local function errorhandler(err)
	return _G.geterrorhandler()(err)
end

function E:CallLoadFunc(func, ...)
	xpcall(func, errorhandler, ...)
end

function E:CallLoadedModule(obj, silent, object, index)
	local name, func
	if type(obj) == 'table' then name, func = unpack(obj) else name = obj end
	local module = name and self:GetModule(name, silent)

	if not module then return end
	if func and type(func) == 'string' then
		E:CallLoadFunc(module[func], module)
	elseif func and type(func) == 'function' then
		E:CallLoadFunc(func, module)
	elseif module.Initialize then
		E:CallLoadFunc(module.Initialize, module)
	end

	if object and index then object[index] = nil end
end

function E:RegisterInitialModule(name, func)
	self.RegisteredInitialModules[#self.RegisteredInitialModules + 1] = (func and {name, func}) or name
end

function E:RegisterModule(name, func)
	if self.initialized then
		E:CallLoadedModule((func and {name, func}) or name)
	else
		self.RegisteredModules[#self.RegisteredModules + 1] = (func and {name, func}) or name
	end
end

function E:InitializeInitialModules()
	for index, object in ipairs(E.RegisteredInitialModules) do
		E:CallLoadedModule(object, true, E.RegisteredInitialModules, index)
	end
end

function E:InitializeModules()
	for index, object in ipairs(E.RegisteredModules) do
		E:CallLoadedModule(object, true, E.RegisteredModules, index)
	end
end

function E:RefreshModulesDB()
	twipe(UnitFrames.db)
	UnitFrames.db = self.db.unitframe
end

function E:DBConversions()
	--Fix issue where UIScale was incorrectly stored as string
	E.global.general.UIScale = tonumber(E.global.general.UIScale)

	--Not sure how this one happens, but prevent it in any case
	if E.global.general.UIScale <= 0 then
		E.global.general.UIScale = G.general.UIScale
	end

	if gameLocale and E.global.general.locale == 'auto' then
		E.global.general.locale = gameLocale
	end

	--Combat & Resting Icon options update
	if E.db.unitframe.units.player.combatIcon ~= nil then
		E.db.unitframe.units.player.CombatIcon.enable = E.db.unitframe.units.player.combatIcon
		E.db.unitframe.units.player.combatIcon = nil
	end
	if E.db.unitframe.units.player.restIcon ~= nil then
		E.db.unitframe.units.player.RestIcon.enable = E.db.unitframe.units.player.restIcon
		E.db.unitframe.units.player.restIcon = nil
	end

	-- [Fader] Combat Fade options for Player
	if E.db.unitframe.units.player.combatfade ~= nil then
		local enabled = E.db.unitframe.units.player.combatfade
		E.db.unitframe.units.player.fader.enable = enabled

		if enabled then -- use the old min alpha too
			E.db.unitframe.units.player.fader.minAlpha = 0
		end

		E.db.unitframe.units.player.combatfade = nil
	end

	-- [Fader] Range check options for Units
	do
		local outsideAlpha
		if E.db.unitframe.OORAlpha ~= nil then
			outsideAlpha = E.db.unitframe.OORAlpha
			E.db.unitframe.OORAlpha = nil
		end

		local rangeCheckUnits = { 'target', 'targettarget', 'targettargettarget', 'focus', 'focustarget', 'pet', 'pettarget', 'boss', 'arena', 'party', 'raid', 'raid40', 'raidpet', 'tank', 'assist' }
		for _, unit in pairs(rangeCheckUnits) do
			if E.db.unitframe.units[unit].rangeCheck ~= nil then
				local enabled = E.db.unitframe.units[unit].rangeCheck
				E.db.unitframe.units[unit].fader.enable = enabled
				E.db.unitframe.units[unit].fader.range = enabled

				if outsideAlpha then
					E.db.unitframe.units[unit].fader.minAlpha = outsideAlpha
				end

				E.db.unitframe.units[unit].rangeCheck = nil
			end
		end
	end

	--Convert old "Buffs and Debuffs" font size option to individual options
	if E.db.auras.fontSize then
		local fontSize = E.db.auras.fontSize
		E.db.auras.buffs.countFontSize = fontSize
		E.db.auras.buffs.durationFontSize = fontSize
		E.db.auras.debuffs.countFontSize = fontSize
		E.db.auras.debuffs.durationFontSize = fontSize
		E.db.auras.fontSize = nil
	end

	--Convert Nameplate Aura Duration to new Cooldown system
	if E.db.nameplates.durationFont then
		E.db.nameplates.cooldown.fonts.font = E.db.nameplates.durationFont
		E.db.nameplates.cooldown.fonts.fontSize = E.db.nameplates.durationFontSize
		E.db.nameplates.cooldown.fonts.fontOutline = E.db.nameplates.durationFontOutline

		E.db.nameplates.durationFont = nil
		E.db.nameplates.durationFontSize = nil
		E.db.nameplates.durationFontOutline = nil
	end

	if E.db.nameplates.lowHealthThreshold > 0.8 then
		E.db.nameplates.lowHealthThreshold = 0.8
	end

	if E.db.nameplates.units.TARGET.nonTargetTransparency ~= nil then
		E.global.nameplate.filters.ElvUI_NonTarget.actions.alpha = E.db.nameplates.units.TARGET.nonTargetTransparency * 100
		E.db.nameplates.units.TARGET.nonTargetTransparency = nil
	end

	if E.db.nameplates.units.TARGET.scale ~= nil then
		E.global.nameplate.filters.ElvUI_Target.actions.scale = E.db.nameplates.units.TARGET.scale
		E.db.nameplates.units.TARGET.scale = nil
	end

	if not E.db.chat.panelColorConverted then
		local color = E.db.general.backdropfadecolor
		E.db.chat.panelColor = {r = color.r, g = color.g, b = color.b, a = color.a}
		E.db.chat.panelColorConverted = true
	end

	--Vendor Greys option is now in bags table
	if E.db.general.vendorGrays ~= nil then
		E.db.bags.vendorGrays.enable = E.db.general.vendorGrays
		E.db.general.vendorGraysDetails = nil
		E.db.general.vendorGrays = nil
	end

	--Heal Prediction is now a table instead of a bool
	local healPredictionUnits = {'player','target','focus','pet','arena','party','raid','raid40','raidpet'}
	for _, unit in pairs(healPredictionUnits) do
		if type(E.db.unitframe.units[unit].healPrediction) ~= 'table' then
			local enabled = E.db.unitframe.units[unit].healPrediction
			E.db.unitframe.units[unit].healPrediction = {}
			E.db.unitframe.units[unit].healPrediction.enable = enabled
		end
	end

	--Health Backdrop Multiplier
	if E.db.unitframe.colors.healthmultiplier ~= nil then
		if E.db.unitframe.colors.healthmultiplier > 0.75 then
			E.db.unitframe.colors.healthMultiplier = 0.75
		else
			E.db.unitframe.colors.healthMultiplier = E.db.unitframe.colors.healthmultiplier
		end

		E.db.unitframe.colors.healthmultiplier = nil
	end

	--Tooltip FactionColors Setting
	for i=1, 8 do
		local oldTable = E.db.tooltip.factionColors[''..i]
		if oldTable then
			local newTable = E:CopyTable({}, P.tooltip.factionColors[i]) -- import full table
			E.db.tooltip.factionColors[i] = E:CopyTable(newTable, oldTable)
			E.db.tooltip.factionColors[''..i] = nil
		end
	end

	--v11 Nameplates Reset
	if not E.db.v11NamePlateReset and E.private.nameplates.enable then
		local styleFilters = E:CopyTable({}, E.db.nameplates.filters)
		E.db.nameplates = E:CopyTable({}, P.nameplates)
		E.db.nameplates.filters = E:CopyTable({}, styleFilters)
		NamePlates:CVarReset()
		E.db.v11NamePlateReset = true
	end

	-- Wipe some old variables off profiles
	if E.global.uiScaleInformed then E.global.uiScaleInformed = nil end
	if E.global.nameplatesResetInformed then E.global.nameplatesResetInformed = nil end
	if E.global.userInformedNewChanges1 then E.global.userInformedNewChanges1 = nil end

	-- cvar nameplate visibility stuff
	if E.db.nameplates.visibility.nameplateShowAll ~= nil then
		E.db.nameplates.visibility.showAll = E.db.nameplates.visibility.nameplateShowAll
		E.db.nameplates.visibility.nameplateShowAll = nil
	end
	if E.db.nameplates.units.FRIENDLY_NPC.showAlways ~= nil then
		E.db.nameplates.visibility.friendly.npcs = E.db.nameplates.units.FRIENDLY_NPC.showAlways
		E.db.nameplates.units.FRIENDLY_NPC.showAlways = nil
	end
	if E.db.nameplates.units.FRIENDLY_PLAYER.minions ~= nil then
		E.db.nameplates.visibility.friendly.minions = E.db.nameplates.units.FRIENDLY_PLAYER.minions
		E.db.nameplates.units.FRIENDLY_PLAYER.minions = nil
	end
	if E.db.nameplates.units.ENEMY_NPC.minors ~= nil then
		E.db.nameplates.visibility.enemy.minus = E.db.nameplates.units.ENEMY_NPC.minors
		E.db.nameplates.units.ENEMY_NPC.minors = nil
	end
	if E.db.nameplates.units.ENEMY_PLAYER.minions ~= nil or E.db.nameplates.units.ENEMY_NPC.minions ~= nil then
		E.db.nameplates.visibility.enemy.minions = E.db.nameplates.units.ENEMY_PLAYER.minions or E.db.nameplates.units.ENEMY_NPC.minions
		E.db.nameplates.units.ENEMY_PLAYER.minions = nil
		E.db.nameplates.units.ENEMY_NPC.minions = nil
	end
end

local CPU_USAGE = {}
local function CompareCPUDiff(showall, minCalls)
	local greatestUsage, greatestCalls, greatestName, newName, newFunc
	local greatestDiff, lastModule, mod, usage, calls, diff = 0

	for name, oldUsage in pairs(CPU_USAGE) do
		newName, newFunc = strmatch(name, '^([^:]+):(.+)$')
		if not newFunc then
			E:Print('CPU_USAGE:', name, newFunc)
		else
			if newName ~= lastModule then
				mod = E:GetModule(newName, true) or E
				lastModule = newName
			end
			usage, calls = GetFunctionCPUUsage(mod[newFunc], true)
			diff = usage - oldUsage
			if showall and (calls > minCalls) then
				E:Print('Name('..name..')  Calls('..calls..') MS('..(usage or 0)..') Diff('..(diff > 0 and format('%.3f', diff) or 0)..')')
			end
			if (diff > greatestDiff) and calls > minCalls then
				greatestName, greatestUsage, greatestCalls, greatestDiff = name, usage, calls, diff
			end
		end
	end

	if greatestName then
		E:Print(greatestName.. ' had the CPU usage of: '..(greatestUsage > 0 and format('%.3f', greatestUsage) or 0)..'ms. And has been called '.. greatestCalls..' times.')
	else
		E:Print('CPU Usage: No CPU Usage differences found.')
	end

	twipe(CPU_USAGE)
end

function E:GetTopCPUFunc(msg)
	if not GetCVarBool('scriptProfile') then
		E:Print('For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0.')
		return
	end

	local module, showall, delay, minCalls = strmatch(msg, '^(%S+)%s*(%S*)%s*(%S*)%s*(.*)$')
	local checkCore, mod = (not module or module == '') and 'E'

	showall = (showall == 'true' and true) or false
	delay = (delay == 'nil' and nil) or tonumber(delay) or 5
	minCalls = (minCalls == 'nil' and nil) or tonumber(minCalls) or 15

	twipe(CPU_USAGE)
	if module == 'all' then
		for moduName, modu in pairs(self.modules) do
			for funcName, func in pairs(modu) do
				if (funcName ~= 'GetModule') and (type(func) == 'function') then
					CPU_USAGE[moduName..':'..funcName] = GetFunctionCPUUsage(func, true)
				end
			end
		end
	else
		if not checkCore then
			mod = self:GetModule(module, true)
			if not mod then
				self:Print(module..' not found, falling back to checking core.')
				mod, checkCore = self, 'E'
			end
		else
			mod = self
		end
		for name, func in pairs(mod) do
			if (name ~= 'GetModule') and type(func) == 'function' then
				CPU_USAGE[(checkCore or module)..':'..name] = GetFunctionCPUUsage(func, true)
			end
		end
	end

	self:Delay(delay, CompareCPUDiff, showall, minCalls)
	self:Print('Calculating CPU Usage differences (module: '..(checkCore or module)..', showall: '..tostring(showall)..', minCalls: '..tostring(minCalls)..', delay: '..tostring(delay)..')')
end

local function SetOriginalHeight()
	if InCombatLockdown() then
		E:RegisterEvent('PLAYER_REGEN_ENABLED', SetOriginalHeight)
		return
	end
	E:UnregisterEvent('PLAYER_REGEN_ENABLED')
	E.UIParent:SetHeight(E.UIParent.origHeight)
end

local function SetModifiedHeight()
	if InCombatLockdown() then
		E:RegisterEvent('PLAYER_REGEN_ENABLED', SetModifiedHeight)
		return
	end
	E:UnregisterEvent('PLAYER_REGEN_ENABLED')
	local height = E.UIParent.origHeight - (_G.OrderHallCommandBar:GetHeight() + E.Border)
	E.UIParent:SetHeight(height)
end

--This function handles disabling of OrderHall Bar or resizing of ElvUIParent if needed
local function HandleCommandBar()
	if E.global.general.commandBarSetting == 'DISABLED' then
		local bar = _G.OrderHallCommandBar
		bar:UnregisterAllEvents()
		bar:SetScript('OnShow', bar.Hide)
		bar:Hide()
		_G.UIParent:UnregisterEvent('UNIT_AURA')--Only used for OrderHall Bar
	elseif E.global.general.commandBarSetting == 'ENABLED_RESIZEPARENT' then
		_G.OrderHallCommandBar:HookScript('OnShow', SetModifiedHeight)
		_G.OrderHallCommandBar:HookScript('OnHide', SetOriginalHeight)
	end
end

function E:Dump(object, inspect)
	if GetAddOnEnableState(E.myname, 'Blizzard_DebugTools') == 0 then
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

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)

	self.myguid = UnitGUID('player')
	self.data = E.Libs.AceDB:New('ElvDB', self.DF)
	self.data.RegisterCallback(self, 'OnProfileChanged', 'StaggeredUpdateAll')
	self.data.RegisterCallback(self, 'OnProfileCopied', 'StaggeredUpdateAll')
	self.data.RegisterCallback(self, 'OnProfileReset', 'OnProfileReset')
	self.charSettings = E.Libs.AceDB:New('ElvPrivateDB', self.privateVars)
	E.Libs.DualSpec:EnhanceDatabase(self.data, 'ElvUI')
	self.private = self.charSettings.profile
	self.db = self.data.profile
	self.global = self.data.global
	self:CheckIncompatible()
	self:DBConversions()
	self:UIScale()

	if not E.db.general.cropIcon then E.TexCoords = {0, 1, 0, 1} end
	self:BuildPrefixValues()

	self:LoadCommands() --Load Commands
	self:InitializeModules() --Load Modules
	self:LoadMovers() --Load Movers
	self:UpdateCooldownSettings('all')
	self.initialized = true

	if E.db.general.smoothingAmount and (E.db.general.smoothingAmount ~= 0.33) then
		E:SetSmoothingAmount(E.db.general.smoothingAmount)
	end

	if self.private.install_complete == nil then
		self:Install()
	end

	if not find(date(), '04/01/') then
		E.global.aprilFools = nil
	end

	if self:HelloKittyFixCheck() then
		self:HelloKittyFix()
	end

	self:UpdateMedia()
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')
	self:RegisterEvent('UI_SCALE_CHANGED', 'PixelScaleChanged')
	self:RegisterEvent('PET_BATTLE_CLOSE', 'AddNonPetBattleFrames')
	self:RegisterEvent('PET_BATTLE_OPENING_START', 'RemoveNonPetBattleFrames')
	self:RegisterEvent('UNIT_ENTERED_VEHICLE', 'EnterVehicleHideFrames')
	self:RegisterEvent('UNIT_EXITED_VEHICLE', 'ExitVehicleShowFrames')
	self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'CheckRole')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')

	if self.db.general.kittys then
		self:CreateKittys()
		self:Delay(5, self.Print, self, L["Type /hellokitty to revert to old settings."])
	end

	self:Tutorials()
	self:RefreshModulesDB()
	Minimap:UpdateSettings()

	if GetCVarBool("scriptProfile") then
		E:StaticPopup_Show('SCRIPT_PROFILE')
	end

	if self.db.general.loginmessage then
		local msg = format(L["LOGIN_MSG"], self.media.hexvaluecolor, self.media.hexvaluecolor, self.version)
		if Chat.Initialized then msg = select(2, Chat:FindURL('CHAT_MSG_DUMMY', msg)) end
		print(msg)
	end

	if _G.OrderHallCommandBar then
		HandleCommandBar()
	else
		local frame = CreateFrame('Frame')
		frame:RegisterEvent('ADDON_LOADED')
		frame:SetScript('OnEvent', function(Frame, event, addon)
			if event == 'ADDON_LOADED' and addon == 'Blizzard_OrderHallUI' then
				if InCombatLockdown() then
					Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
				else
					HandleCommandBar()
				end
				Frame:UnregisterEvent(event)
			elseif event == 'PLAYER_REGEN_ENABLED' then
				HandleCommandBar()
				Frame:UnregisterEvent(event)
			end
		end)
	end
end
