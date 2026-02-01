--[[
	~AddOn Engine~
	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

local _G = _G
local strsplit, gsub, tinsert, next, type, wipe = strsplit, gsub, tinsert, next, type, wipe
local tostring, tonumber, strfind, strmatch = tostring, tonumber, strfind, strmatch

local CreateFrame = CreateFrame
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetTime = GetTime
local ReloadUI = ReloadUI
local WorldFrame = WorldFrame
local UIParent = UIParent
local UnitGUID = UnitGUID

local UIDropDownMenu_SetAnchor = UIDropDownMenu_SetAnchor

local DisableAddOn = C_AddOns.DisableAddOn
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local C_AddOns_GetAddOnEnableState = C_AddOns.GetAddOnEnableState

local GetCVar = C_CVar.GetCVar
local SetCVar = C_CVar.SetCVar

-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

local oUF = _G.ElvUF
assert(oUF, 'ElvUI was unable to locate oUF.')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
E.DF = {profile = {}, global = {}}; E.privateVars = {profile = {}} -- Defaults
E.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree', get = E.noop, name = ''}
E.callbacks = E.callbacks or CallbackHandler:New(E)
E.wowpatch, E.wowbuild, E.wowdate, E.wowtoc = GetBuildInfo()
E.locale = GetLocale()
E.oUF = oUF

-- moved this to oUF relink it so it works on E
E.ColorGradient = oUF.ColorGradient
E.IsSecretValue = oUF.IsSecretValue
E.IsSecretTable = oUF.IsSecretTable
E.NotSecretValue = oUF.NotSecretValue
E.NotSecretTable = oUF.NotSecretTable
E.HasSecretValues = oUF.HasSecretValues
E.NoSecretValues = oUF.NoSecretValues

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.ElvUI = Engine

E.ActionBars = E:NewModule('ActionBars','AceHook-3.0','AceEvent-3.0')
E.AFK = E:NewModule('AFK','AceEvent-3.0','AceTimer-3.0')
E.Auras = E:NewModule('Auras','AceHook-3.0','AceEvent-3.0')
E.Bags = E:NewModule('Bags','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.Blizzard = E:NewModule('Blizzard','AceEvent-3.0','AceHook-3.0')
E.Chat = E:NewModule('Chat','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.DataBars = E:NewModule('DataBars','AceEvent-3.0')
E.DataTexts = E:NewModule('DataTexts','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.DebugTools = E:NewModule('DebugTools','AceEvent-3.0','AceHook-3.0')
E.Distributor = E:NewModule('Distributor','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
E.EditorMode = E:NewModule('EditorMode','AceEvent-3.0')
E.Layout = E:NewModule('Layout','AceEvent-3.0')
E.Minimap = E:NewModule('Minimap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.Misc = E:NewModule('Misc','AceEvent-3.0','AceTimer-3.0','AceHook-3.0')
E.ModuleCopy = E:NewModule('ModuleCopy','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
E.NamePlates = E:NewModule('NamePlates','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.PluginInstaller = E:NewModule('PluginInstaller')
E.PrivateAuras = E:NewModule('PrivateAuras')
E.RaidUtility = E:NewModule('RaidUtility','AceEvent-3.0')
E.Skins = E:NewModule('Skins','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.Tooltip = E:NewModule('Tooltip','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.TotemTracker = E:NewModule('TotemTracker','AceEvent-3.0')
E.UnitFrames = E:NewModule('UnitFrames','AceTimer-3.0','AceEvent-3.0','AceHook-3.0')
E.WorldMap = E:NewModule('WorldMap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')

E.InfoColor = '|cff1784d1' -- blue
E.InfoColor2 = '|cff9b9b9b' -- silver
E.twoPixelsPlease = false -- changing this option is not supported! :P

do -- Expansions
	E.TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
	E.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
	E.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
	E.Mists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
	E.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	E.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

	local season = C_Seasons and C_Seasons.GetActiveSeason()
	E.ClassicHC = season == 3 -- Hardcore
	E.ClassicSOD = season == 2 -- Season of Discovery
	E.ClassicAnniv = season == 11 -- Anniversary
	E.ClassicAnnivHC = season == 12 -- Anniversary Hardcore

	local IsHardcoreActive = C_GameRules.IsHardcoreActive
	E.IsHardcoreActive = IsHardcoreActive and IsHardcoreActive()

	local IsEngravingEnabled = C_Engraving and C_Engraving.IsEngravingEnabled
	E.IsEngravingEnabled = IsEngravingEnabled and IsEngravingEnabled()
end

-- DONT USE: Deprecated
E.QualityColors = CopyTable(_G.BAG_ITEM_QUALITY_COLORS)
E.QualityColors[Enum.ItemQuality.Poor] = { r = .61, g = .61, b = .61, a = 1 }
E.QualityColors[Enum.ItemQuality.Common or Enum.ItemQuality.Standard] = { r = 0, g = 0, b = 0, a = 1 }
E.QualityColors[-1] = { r = 0, g = 0, b = 0, a = 1 }

do
	function E:AddonCompartmentFunc()
		E:ToggleOptions()
	end

	_G.ElvUI_AddonCompartmentFunc = E.AddonCompartmentFunc
end

do -- this is different from E.locale because we need to convert for ace locale files
	local convert = { enGB = 'enUS' }
	local gameLocale = convert[E.locale] or E.locale or 'enUS'

	function E:GetLocale()
		return gameLocale
	end
end

function E:ParseVersionString(addon)
	local version = GetAddOnMetadata(addon, 'Version')
	if strfind(version, 'project%-version') then
		return 15.02, '15.02-git', nil, true
	else
		local release, extra = strmatch(version, '^v?([%d.]+)(.*)')
		return tonumber(release), release..extra, extra ~= ''
	end
end

do
	E.Libs = { version = E:ParseVersionString('ElvUI_Libraries') }
	E.LibsMinor = {}

	function E:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == 'table' and type(minor) == 'number' then
			E.Libs[name], E.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			E.Libs[name], E.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	function E:DispelListUpdated()
		if not E.Retail then return end

		E:UpdateDispelCurves()
	end

	E:AddLib('AceAddon', AceAddon, AceAddonMinor)
	E:AddLib('AceDB', 'AceDB-3.0')
	E:AddLib('ACH', 'LibAceConfigHelper')
	E:AddLib('EP', 'LibElvUIPlugin-1.0')
	E:AddLib('LSM', 'LibSharedMedia-3.0')
	E:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	E:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	E:AddLib('LDB', 'LibDataBroker-1.1')
	E:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	E:AddLib('CustomGlow', 'LibCustomGlow-1.0')
	E:AddLib('Deflate', 'LibDeflate')
	E:AddLib('Masque', 'Masque', true)
	E:AddLib('Translit', 'LibTranslit-1.0')
	E:AddLib('Dispel', 'LibDispel-1.0')

	-- libraries used for options
	E:AddLib('AceGUI', 'AceGUI-3.0')
	E:AddLib('AceConfig', 'AceConfig-3.0-ElvUI')
	E:AddLib('AceConfigDialog', 'AceConfigDialog-3.0-ElvUI')
	E:AddLib('AceConfigRegistry', 'AceConfigRegistry-3.0-ElvUI')
	E:AddLib('AceDBOptions', 'AceDBOptions-3.0')

	if E.Retail or E.Wrath or E.Mists or E.TBC or E.ClassicSOD or E.ClassicAnniv or E.ClassicAnnivHC then
		E:AddLib('DualSpec', 'LibDualSpec-1.0')
	end

	-- so we can retrigger the curves
	local dispel = E.Libs.Dispel
	if dispel and dispel.ListUpdated then
		E:SecureHook(dispel, 'ListUpdated', E.DispelListUpdated)
	end

	-- backwards compatible for plugins
	E.LSM = E.Libs.LSM
	E.UnitFrames.LSM = E.Libs.LSM
	E.Masque = E.Libs.Masque
end

do -- expand LibCustomGlow for button handling
	local LCG, frames, proc = E.Libs.CustomGlow, {}, { xOffset = 3, yOffset = 3 }
	function LCG.ShowOverlayGlow(button, custom)
		local db = custom or E.db.general.customGlow
		local glow = LCG.startList[db.style]
		if glow then -- TODO: frameLevel isnt actually used yet
			local color = db.useColor and ((custom and custom.color) or E.media.customGlowColor)

			if db.style == 'Proc Glow' then -- this uses an options table
				proc.color = color
				proc.duration = db.duration
				proc.startAnim = db.startAnimation
				proc.frameLevel = db.frameLevel

				glow(button, proc)
			else
				local pixel, cast = db.style == 'Pixel Glow', db.style == 'Autocast Shine'
				local arg3, arg4, arg6, arg9, arg11

				if pixel or cast then arg3, arg4 = db.lines, db.speed else arg3 = db.speed end
				if pixel then arg6, arg11 = db.size, db.frameLevel elseif cast then arg9 = db.frameLevel end

				glow(button, color, arg3, arg4, nil, arg6, nil, nil, arg9, nil, arg11)
			end

			frames[button] = true
		end
	end

	function LCG.HideOverlayGlow(button, style)
		local glow = LCG.stopList[style or E.db.general.customGlow.style]
		if glow then
			glow(button)

			frames[button] = nil
		end
	end

	function E:StopAllCustomGlows()
		for button in next, frames do
			LCG.HideOverlayGlow(button)
		end
	end
end

do
	local a,b,c = '','([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function E:EscapeString(s) return gsub(s,b,c) end

	local d = {'|[TA].-|[ta]','|c[fF][fF]%x%x%x%x%x%x','|r','^%s+','%s+$'}
	function E:StripString(s, ignoreTextures)
		for i = ignoreTextures and 2 or 1, #d do s = gsub(s,d[i],a) end
		return s
	end
end

do
	local alwaysDisable = {
		'ElvUI_AuraBarsMovers',
		'ElvUI_CastBarOverlay',
		'ElvUI_CustomTags',
		'ElvUI_CustomTweaks',
		'ElvUI_DTBars2',
		'ElvUI_EverySecondCounts',
		'ElvUI_ExtraActionBars',
		'ElvUI_ExtraDataTexts',
		'ElvUI_QuestXP',
		'ElvUI_UnitFramePlugin',
		'ElvUI_VisualAuraTimers',
		'ElvUI_SecondsToBuff',
		'ElvUI_BuffHighlight',
		'ElvUI_RatioMinimapAuras',
	}

	if not IsAddOnLoaded('ShadowedUnitFrames') then
		tinsert(alwaysDisable, 'kExtraBossFrames')
	end

	function E:DisableAddons()
		for _, addon in next, alwaysDisable do
			DisableAddOn(addon, E.myguid)
		end
	end
end

do
	local others = {} -- addons we check for
	local addons = { -- a few are not exact matches
		ArkInventory = true,
		BigWigs = true,
		ColorPickerPlus = true,
		ColorTools = true,
		DejaCharacterStats = true,
		DugisGuideViewerZ = true,
		OptionHouse = true,
		Questie = true,
		SimplePowerBar = true,
		Tukui = true,
		DBM = 'DBM-Core',
		ConsolePort = 'ConsolePort_Menu',
		KalielsTracker = '!KalielsTracker',
	}

	E.OtherAddons = others

	function E:CheckAddons()
		for key, value in next, addons do
			if type(value) == 'string' then
				others[key] = E:IsAddOnEnabled(value)
			else
				others[key] = E:IsAddOnEnabled(key)
			end
		end
	end
end

do
	local fps = {}
	E.FPS = fps

	local CollectRate = function(rate)
		fps.count = (fps.count or 0) + 1
		fps.total = (fps.total or 0) + rate

		fps.rate = rate
		fps.average = fps.total / fps.count

		if not fps.high or (rate > fps.high) then
			fps.high = rate
		end

		if not fps.low or (rate < fps.low) then
			fps.low = rate
		end
	end

	local ignore, wait, rate = true, 0, 0
	local TrackRate = function(_, elapsed)
		if wait < 1 then
			wait = wait + elapsed
			rate = rate + 1
		else
			wait = 0

			if ignore then -- ignore the first update
				ignore = false
			else
				CollectRate(rate)
			end

			rate = 0 -- ok reset it
		end
	end

	local ResetRate = function()
		wipe(fps)

		ignore = true -- ignore the first again
	end

	local frame = CreateFrame('Frame')
	frame:SetScript('OnUpdate', TrackRate)
	frame:SetScript('OnEvent', ResetRate)
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function E:SetCVar(cvar, value, ...)
	local valstr = ((type(value) == 'boolean') and (value and '1' or '0')) or tostring(value)
	if GetCVar(cvar) ~= valstr then
		SetCVar(cvar, valstr, ...)
	end
end

function E:GetAddOnEnableState(addon, character)
	return C_AddOns_GetAddOnEnableState(addon, character)
end

function E:IsAddOnEnabled(addon)
	return E:GetAddOnEnableState(addon, E.myguid) == 2
end

function E:SetEasyMenuAnchor(menu, frame)
	local point = E:GetScreenQuadrant(frame)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'TOPLEFT') or (bottom and 'TOPRIGHT') or (left and 'BOTTOMLEFT') or 'BOTTOMRIGHT'

	UIDropDownMenu_SetAnchor(menu, 1, -1, anchor1, frame, anchor2)
end

function E:ResetProfile()
	E:StaggeredUpdateAll()
end

function E:OnProfileReset()
	E:ResetProfile()
end

function E:ResetPrivateProfile()
	ReloadUI()
end

function E:OnPrivateProfileReset()
	E:ResetPrivateProfile()
end

function E:OnEnable()
	E:Initialize()
end

do
	local info = {
		Auras = 'auras',
		ActionBars = 'actionbar',
		Bags = 'bags',
		Chat = 'chat',
		DataBars = 'databars',
		DataTexts = 'datatexts',
		NamePlates = 'nameplates',
		Tooltip = 'tooltip',
		UnitFrames = 'unitframe'
	}

	function E:SetupDB()
		for key, value in next, info do
			local module = E[key]
			if module then
				module.db = E.db[value]
			end
		end

		E.Minimap.db = E.db.general.minimap
		E.TotemTracker.db = E.db.general.totems
		E.Skins.db = E.private.skins
	end
end

function E:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil --Depreciated
	ElvPrivateData = nil --Depreciated
	ElvData = nil --Depreciated

	E.db = E:CopyTable({}, E.DF.profile)
	E.global = E:CopyTable({}, E.DF.global)
	E.private = E:CopyTable({}, E.privateVars.profile)

	if ElvDB then
		if ElvDB.global then
			E:CopyTable(E.global, ElvDB.global)
		end

		local key = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		if key and ElvDB.profiles and ElvDB.profiles[key] then
			E:CopyTable(E.db, ElvDB.profiles[key])
		end
	end

	if ElvPrivateDB then
		local key = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		if key and ElvPrivateDB.profiles and ElvPrivateDB.profiles[key] then
			E:CopyTable(E.private, ElvPrivateDB.profiles[key])
		end
	end

	E.SpellBookTooltip = CreateFrame('GameTooltip', 'ElvUI_SpellBookTooltip', UIParent, 'GameTooltipTemplate')
	E.ConfigTooltip = CreateFrame('GameTooltip', 'ElvUI_ConfigTooltip', UIParent, 'GameTooltipTemplate')
	E.ScanTooltip = CreateFrame('GameTooltip', 'ElvUI_ScanTooltip', WorldFrame, 'GameTooltipTemplate')
	E.EasyMenu = CreateFrame('Frame', 'ElvUI_EasyMenu', UIParent, 'UIDropDownMenuTemplate')

	E.PixelMode = E.twoPixelsPlease or E.private.general.pixelPerfect -- keep this over `UIScale`
	E.Border = (E.PixelMode and not E.twoPixelsPlease) and 1 or 2
	E.Spacing = E.PixelMode and 0 or 1

	E.myClassColor = E:ClassColor(E.myclass, true)
	E.loadedtime = GetTime()

	local playerGUID = UnitGUID('player')
	local _, serverID = strsplit('-', playerGUID)
	E.serverID = tonumber(serverID)
	E.myguid = playerGUID

	E:DisableAddons()
	E:CheckAddons()
	E:SetupDB()
	E:UIMult()
	E:UpdateMedia()

	if not E.OtherAddons.Tukui then
		E:InitializeInitialModules()
	end

	if E.private.general.minimap.enable then
		E.Minimap:SetGetMinimapShape() -- this is just to support for other mods, keep below UIMult
	end
end
