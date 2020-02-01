--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Lua functions
local _G = _G
local format, gsub, type, tcopy = format, gsub, type, table.copy
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnMetadata = GetAddOnMetadata
local GetLocale = GetLocale
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local DisableAddOn = DisableAddOn
local ReloadUI = ReloadUI

local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

_G.BINDING_HEADER_ELVUI = GetAddOnMetadata(..., 'Title')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
E.DF = {profile = {}, global = {}}; E.privateVars = {profile = {}} -- Defaults
E.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree'}
E.callbacks = E.callbacks or CallbackHandler:New(E)

Engine[1] = E
Engine[2] = {}
Engine[3] = E.privateVars.profile
Engine[4] = E.DF.profile
Engine[5] = E.DF.global
_G.ElvUI = Engine

do
	local locale = GetLocale()
	local convert = {enGB = 'enUS', esES = 'esMX', itIT = 'enUS'}
	local gameLocale = convert[locale] or locale or 'enUS'

	function E:GetLocale()
		return gameLocale
	end
end

do
	E.Libs = {}
	E.LibsMinor = {}
	function E:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == 'table' and type(minor) == 'number' then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	E:AddLib('AceAddon', AceAddon, AceAddonMinor)
	E:AddLib('AceDB', 'AceDB-3.0')
	E:AddLib('EP', 'LibElvUIPlugin-1.0')
	E:AddLib('LSM', 'LibSharedMedia-3.0')
	E:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	E:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	E:AddLib('LDB', 'LibDataBroker-1.1')
	E:AddLib('DualSpec', 'LibDualSpec-1.0')
	E:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	E:AddLib('SpellRange', 'SpellRange-1.0')
	E:AddLib('ButtonGlow', 'LibButtonGlow-1.0', true)
	E:AddLib('ItemSearch', 'LibItemSearch-1.2-ElvUI')
	E:AddLib('Compress', 'LibCompress')
	E:AddLib('Base64', 'LibBase64-1.0-ElvUI')
	E:AddLib('Masque', 'Masque', true)
	E:AddLib('Translit', 'LibTranslit-1.0')
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	-- backwards compatible for plugins
	E.LSM = E.Libs.LSM
	E.Masque = E.Libs.Masque
end

E.oUF = Engine.oUF
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
E.Layout = E:NewModule('Layout','AceEvent-3.0')
E.Minimap = E:NewModule('Minimap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.Misc = E:NewModule('Misc','AceEvent-3.0','AceTimer-3.0')
E.ModuleCopy = E:NewModule('ModuleCopy','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
E.NamePlates = E:NewModule('NamePlates','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
E.PluginInstaller = E:NewModule('PluginInstaller')
E.RaidUtility = E:NewModule('RaidUtility','AceEvent-3.0')
E.Skins = E:NewModule('Skins','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.Threat = E:NewModule('Threat','AceEvent-3.0')
E.Tooltip = E:NewModule('Tooltip','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
E.TotemBar = E:NewModule('Totems','AceEvent-3.0')
E.UnitFrames = E:NewModule('UnitFrames','AceTimer-3.0','AceEvent-3.0','AceHook-3.0')
E.WorldMap = E:NewModule('WorldMap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')

do
	local a1,a2,a3 = '','([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function E:EscapeString(s) return gsub(s,a2,a3) end

	local a4,a5,a6,a7 = '|c[fF][fF]%x%x%x%x%x%x','|r','|[TA].-|[ta]','^%s*'
	function E:StripString(s)
		return gsub(gsub(gsub(gsub(s,a4,a1),a5,a1),a6,a1),a7,a1)
	end
end

do
	DisableAddOn("ElvUI_VisualAuraTimers")
	DisableAddOn("ElvUI_ExtraActionBars")
	DisableAddOn("ElvUI_CastBarOverlay")
	DisableAddOn("ElvUI_EverySecondCounts")
	DisableAddOn("ElvUI_AuraBarsMovers")
	DisableAddOn("ElvUI_CustomTweaks")
end

function E:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil; --Depreciated
	ElvPrivateData = nil; --Depreciated
	ElvData = nil; --Depreciated

	self.db = tcopy(self.DF.profile, true)
	self.global = tcopy(self.DF.global, true)

	local ElvDB = ElvDB
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end

		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true)

	local ElvPrivateDB = ElvPrivateDB
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end

	self.twoPixelsPlease = false
	self.ScanTooltip = CreateFrame('GameTooltip', 'ElvUI_ScanTooltip', _G.UIParent, 'GameTooltipTemplate')
	self.PixelMode = self.twoPixelsPlease or self.private.general.pixelPerfect -- keep this over `UIScale`
	self:UIScale(true)
	self:UpdateMedia()
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if self.private.general.minimap.enable then
		self.Minimap:SetGetMinimapShape()
		_G.Minimap:SetMaskTexture(130937) -- interface/chatframe/chatframebackground.blp
	else
		_G.Minimap:SetMaskTexture(186178) -- textures/minimapmask.blp
	end

	if GetAddOnEnableState(self.myname, 'Tukui') == 2 then
		self:StaticPopup_Show('TUKUI_ELVUI_INCOMPATIBLE')
	end

	local GameMenuButton = CreateFrame('Button', nil, GameMenuFrame, 'GameMenuButtonTemplate')
	GameMenuButton:SetText(format('|cfffe7b2c%s|r', E.name))
	GameMenuButton:SetScript('OnClick', function() E:ToggleOptionsUI() HideUIPanel(GameMenuFrame) end)
	GameMenuFrame[E.name] = GameMenuButton

	if not IsAddOnLoaded('ConsolePortUI_Menu') then -- #390
		GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:Point('TOPLEFT', GameMenuButtonAddons, 'BOTTOMLEFT', 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', self.PositionGameMenuButton)
	end

	self.loadedtime = GetTime()
end

function E:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[E.name] then
		GameMenuFrame[E.name]:ClearAllPoints()
		GameMenuFrame[E.name]:Point('TOPLEFT', relTo, 'BOTTOMLEFT', 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point('TOPLEFT', GameMenuFrame[E.name], 'BOTTOMLEFT', 0, offY)
	end
end

local LoadUI=CreateFrame('Frame')
LoadUI:RegisterEvent('PLAYER_LOGIN')
LoadUI:SetScript('OnEvent', function()
	E:Initialize()
end)

function E:ResetProfile()
	local profileKey

	local ElvPrivateDB = ElvPrivateDB
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
	end

	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil
	end

	ElvCharacterDB = nil
	ReloadUI()
end

function E:OnProfileReset()
	self:StaticPopup_Show('RESET_PROFILE_PROMPT')
end
