--[[
	~AddOn Engine~
	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

local _G, next, strfind = _G, next, strfind
local gsub, tinsert, type = gsub, tinsert, type

local GetAddOnEnableState = GetAddOnEnableState
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale
local GetTime = GetTime
local CreateFrame = CreateFrame
local DisableAddOn = DisableAddOn
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI

local RegisterCVar = C_CVar.RegisterCVar
local UIDropDownMenu_SetAnchor = UIDropDownMenu_SetAnchor

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
E.DF = {profile = {}, global = {}}; E.privateVars = {profile = {}} -- Defaults
E.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree'}
E.callbacks = E.callbacks or CallbackHandler:New(E)
E.wowpatch, E.wowbuild, E.wowdate, E.wowtoc = GetBuildInfo()
E.locale = GetLocale()

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.ElvUI = Engine

E.oUF = _G.ElvUF
assert(E.oUF, 'ElvUI was unable to locate oUF.')

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

-- Expansions
E.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
E.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
E.TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC -- not used
E.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

-- Item Qualitiy stuff, also used by MerathilisUI
E.QualityColors = CopyTable(_G.BAG_ITEM_QUALITY_COLORS)
E.QualityColors[-1] = {r = 0, g = 0, b = 0}
E.QualityColors[Enum.ItemQuality.Poor] = {r = .61, g = .61, b = .61}
E.QualityColors[Enum.ItemQuality.Common or Enum.ItemQuality.Standard] = {r = 0, g = 0, b = 0}

do
	function E:AddonCompartmentFunc()
		E:ToggleOptions()
	end

	_G.ElvUI_AddonCompartmentFunc = E.AddonCompartmentFunc
end

do -- this is different from E.locale because we need to convert for ace locale files
	local convert = {enGB = 'enUS', esES = 'esMX', itIT = 'enUS'}
	local gameLocale = convert[E.locale] or E.locale or 'enUS'

	function E:GetLocale()
		return gameLocale
	end
end

do
	E.Libs = { version = tonumber(GetAddOnMetadata('ElvUI_Libraries', 'Version')) }
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

	E:AddLib('AceAddon', AceAddon, AceAddonMinor)
	E:AddLib('AceDB', 'AceDB-3.0')
	E:AddLib('ACH', 'LibAceConfigHelper')
	E:AddLib('EP', 'LibElvUIPlugin-1.0')
	E:AddLib('LSM', 'LibSharedMedia-3.0')
	E:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	E:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	E:AddLib('LDB', 'LibDataBroker-1.1')
	E:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	E:AddLib('RangeCheck', 'LibRangeCheck-2.0')
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

	if E.Retail or E.Wrath then
		E:AddLib('DualSpec', 'LibDualSpec-1.0')
	end

	if not E.Retail then
		E:AddLib('LCS', 'LibClassicSpecs-ElvUI')

		if E.Classic then
			E:AddLib('LCD', 'LibClassicDurations')
			E:AddLib('LCC', 'LibClassicCasterino')

			if E.Libs.LCD then
				E.Libs.LCD:Register('ElvUI')
			end
		end
	end

	-- backwards compatible for plugins
	E.LSM = E.Libs.LSM
	E.UnitFrames.LSM = E.Libs.LSM
	E.Masque = E.Libs.Masque
end

do -- expand LibCustomGlow for button handling
	local LCG, frames = E.Libs.CustomGlow, {}
	function LCG.ShowOverlayGlow(button, custom)
		local opt = custom or E.db.general.customGlow
		local glow = LCG.startList[opt.style]
		if glow then
			local pixel, cast = opt.style == 'Pixel Glow', opt.style == 'Autocast Shine'
			local arg3, arg4, arg6, arg9, arg11

			if pixel or cast then arg3, arg4 = opt.lines, opt.speed else arg3 = opt.speed end
			if pixel then arg6, arg11 = opt.size, opt.frameLevel elseif cast then arg9 = opt.frameLevel end

			glow(button, opt.useColor and ((custom and custom.color) or E.media.customGlowColor), arg3, arg4, nil, arg6, nil, nil, arg9, nil, arg11)

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
		'WunderUI',
	}

	if not IsAddOnLoaded('ShadowedUnitFrames') then
		tinsert(alwaysDisable, 'kExtraBossFrames')
	end

	for _, addon in next, alwaysDisable do
		DisableAddOn(addon)
	end
end

function E:SetEasyMenuAnchor(menu, frame)
	local point = E:GetScreenQuadrant(frame)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'TOPLEFT') or (bottom and 'TOPRIGHT') or (left and 'BOTTOMLEFT') or 'BOTTOMRIGHT'

	UIDropDownMenu_SetAnchor(menu, 0, 0, anchor1, frame, anchor2)
end

function E:ResetProfile()
	E:StaggeredUpdateAll()
end

function E:OnProfileReset()
	E:StaticPopup_Show('RESET_PROFILE_PROMPT')
end

function E:ResetPrivateProfile()
	ReloadUI()
end

function E:OnPrivateProfileReset()
	E:StaticPopup_Show('RESET_PRIVATE_PROFILE_PROMPT')
end

function E:OnEnable()
	E:Initialize()
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

	E.ScanTooltip = CreateFrame('GameTooltip', 'ElvUI_ScanTooltip', _G.UIParent, 'GameTooltipTemplate')
	E.EasyMenu = CreateFrame('Frame', 'ElvUI_EasyMenu', _G.UIParent, 'UIDropDownMenuTemplate')

	E.PixelMode = E.twoPixelsPlease or E.private.general.pixelPerfect -- keep this over `UIScale`
	E.Border = (E.PixelMode and not E.twoPixelsPlease) and 1 or 2
	E.Spacing = E.PixelMode and 0 or 1
	E.loadedtime = GetTime()

	E:UIMult()
	E:UpdateMedia()
	E:InitializeInitialModules()

	if E.private.general.minimap.enable then
		E.Minimap:SetGetMinimapShape() -- This is just to support for other mods, keep below UIMult
	end

	if E.Classic then
		RegisterCVar('fstack_showhighlight', '1')
	end

	if GetAddOnEnableState(E.myname, 'Tukui') == 2 then
		E:StaticPopup_Show('TUKUI_ELVUI_INCOMPATIBLE')
	end
end
