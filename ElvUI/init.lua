--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Lua functions
local _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, tcopy = _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, table.copy
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetLocale = GetLocale
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local issecurevariable = issecurevariable
local LoadAddOn = LoadAddOn
local ReloadUI = ReloadUI

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

_G.BINDING_HEADER_ELVUI = GetAddOnMetadata(..., 'Title')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local AddOn = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
AddOn.callbacks = AddOn.callbacks or CallbackHandler:New(AddOn)
AddOn.DF = {profile = {}, global = {}}; AddOn.privateVars = {profile = {}} -- Defaults
AddOn.Options = {type = 'group', name = AddOnName, args = {}}

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = AddOn.privateVars.profile
Engine[4] = AddOn.DF.profile
Engine[5] = AddOn.DF.global
_G[AddOnName] = Engine

do
	local locale = GetLocale()
	local convert = {enGB = 'enUS', esES = 'esMX', itIT = 'enUS'}
	local gameLocale = convert[locale] or locale or 'enUS'

	function AddOn:GetLocale()
		return gameLocale
	end
end

do
	AddOn.Libs = {}
	AddOn.LibsMinor = {}
	function AddOn:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == 'table' and type(minor) == 'number' then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	AddOn:AddLib('AceAddon', AceAddon, AceAddonMinor)
	AddOn:AddLib('AceDB', 'AceDB-3.0')
	AddOn:AddLib('EP', 'LibElvUIPlugin-1.0')
	AddOn:AddLib('LSM', 'LibSharedMedia-3.0')
	AddOn:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	AddOn:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	AddOn:AddLib('LDB', 'LibDataBroker-1.1')
	AddOn:AddLib('DualSpec', 'LibDualSpec-1.0')
	AddOn:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	AddOn:AddLib('SpellRange', 'SpellRange-1.0')
	AddOn:AddLib('ButtonGlow', 'LibButtonGlow-1.0', true)
	AddOn:AddLib('ItemSearch', 'LibItemSearch-1.2-ElvUI')
	AddOn:AddLib('Compress', 'LibCompress')
	AddOn:AddLib('Base64', 'LibBase64-1.0-ElvUI')
	AddOn:AddLib('Masque', 'Masque', true)
	AddOn:AddLib('Translit', 'LibTranslit-1.0')
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	-- backwards compatible for plugins
	AddOn.LSM = AddOn.Libs.LSM
	AddOn.Masque = AddOn.Libs.Masque
end

AddOn.oUF = Engine.oUF
AddOn.ActionBars = AddOn:NewModule('ActionBars','AceHook-3.0','AceEvent-3.0')
AddOn.AFK = AddOn:NewModule('AFK','AceEvent-3.0','AceTimer-3.0')
AddOn.Auras = AddOn:NewModule('Auras','AceHook-3.0','AceEvent-3.0')
AddOn.Bags = AddOn:NewModule('Bags','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.Blizzard = AddOn:NewModule('Blizzard','AceEvent-3.0','AceHook-3.0')
AddOn.Chat = AddOn:NewModule('Chat','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.DataBars = AddOn:NewModule('DataBars','AceEvent-3.0')
AddOn.DataTexts = AddOn:NewModule('DataTexts','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.DebugTools = AddOn:NewModule('DebugTools','AceEvent-3.0','AceHook-3.0')
AddOn.Distributor = AddOn:NewModule('Distributor','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
AddOn.Layout = AddOn:NewModule('Layout','AceEvent-3.0')
AddOn.Minimap = AddOn:NewModule('Minimap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.Misc = AddOn:NewModule('Misc','AceEvent-3.0','AceTimer-3.0')
AddOn.ModuleCopy = AddOn:NewModule('ModuleCopy','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
AddOn.NamePlates = AddOn:NewModule('NamePlates','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.PluginInstaller = AddOn:NewModule('PluginInstaller')
AddOn.RaidUtility = AddOn:NewModule('RaidUtility','AceEvent-3.0')
AddOn.Skins = AddOn:NewModule('Skins','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.Threat = AddOn:NewModule('Threat','AceEvent-3.0')
AddOn.Tooltip = AddOn:NewModule('Tooltip','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.TotemBar = AddOn:NewModule('Totems','AceEvent-3.0')
AddOn.UnitFrames = AddOn:NewModule('UnitFrames','AceTimer-3.0','AceEvent-3.0','AceHook-3.0')
AddOn.WorldMap = AddOn:NewModule('WorldMap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')

do
	local arg2,arg3 = '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function AddOn:EscapeString(str)
		return gsub(str,arg2,arg3)
	end
end

function AddOn:OnInitialize()
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
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if GetAddOnEnableState(self.myname, 'Tukui') == 2 then
		self:StaticPopup_Show('TUKUI_ELVUI_INCOMPATIBLE')
	end

	local GameMenuButton = CreateFrame('Button', nil, GameMenuFrame, 'GameMenuButtonTemplate')
	GameMenuButton:SetText(format('|cfffe7b2c%s|r', AddOnName))
	GameMenuButton:SetScript('OnClick', function()
		AddOn:ToggleOptionsUI()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	if not IsAddOnLoaded('ConsolePortUI_Menu') then -- #390
		GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:Point('TOPLEFT', GameMenuButtonAddons, 'BOTTOMLEFT', 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', self.PositionGameMenuButton)
	end

	self.loadedtime = GetTime()
end

function AddOn:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:Point('TOPLEFT', relTo, 'BOTTOMLEFT', 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point('TOPLEFT', GameMenuFrame[AddOnName], 'BOTTOMLEFT', 0, offY)
	end
end

local LoadUI=CreateFrame('Frame')
LoadUI:RegisterEvent('PLAYER_LOGIN')
LoadUI:SetScript('OnEvent', function()
	AddOn:Initialize()
end)

function AddOn:PLAYER_REGEN_ENABLED()
	self:ToggleOptionsUI()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AddOn:PLAYER_REGEN_DISABLED()
	local err

	if IsAddOnLoaded('ElvUI_OptionsUI') then
		local ACD = self.Libs.AceConfigDialog
		if ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName] then
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			ACD:Close(AddOnName)
			err = true
		end
	end

	if self.CreatedMovers then
		for name in pairs(self.CreatedMovers) do
			local mover = _G[name]
			if mover and mover:IsShown() then
				mover:Hide()
				err = true
			end
		end
	end

	if err then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function AddOn:ResetProfile()
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

function AddOn:OnProfileReset()
	self:StaticPopup_Show('RESET_PROFILE_PROMPT')
end

function AddOn:ResetConfigSettings()
	AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft = nil, nil
	AddOn.global.general.AceGUI = AddOn:CopyTable({}, AddOn.DF.global.general.AceGUI)
end

function AddOn:GetConfigPosition()
	return AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft
end

function AddOn:GetConfigSize()
	return AddOn.global.general.AceGUI.width, AddOn.global.general.AceGUI.height
end

function AddOn:UpdateConfigSize(reset)
	local frame = self.GUIFrame
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(600, 500)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(AddOnName, self:GetConfigDefaultSize())

	local status = frame.obj and frame.obj.status
	if status then
		if reset then
			self:ResetConfigSettings()

			status.top, status.left = self:GetConfigPosition()
			status.width, status.height = self:GetConfigDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = self:GetConfigPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end
	end
end

function AddOn:GetConfigDefaultSize()
	local width, height = AddOn:GetConfigSize()
	local maxWidth, maxHeight = AddOn.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function AddOn:ConfigStopMovingOrSizing()
	if self.obj and self.obj.status then
		AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft = AddOn:Round(self:GetTop(), 2), AddOn:Round(self:GetLeft(), 2)
		AddOn.global.general.AceGUI.width, AddOn.global.general.AceGUI.height = AddOn:Round(self:GetWidth(), 2), AddOn:Round(self:GetHeight(), 2)
	end
end

local pageNodes = {}
function AddOn:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	if not IsAddOnLoaded('ElvUI_OptionsUI') then
		local noConfig
		local _, _, _, _, reason = GetAddOnInfo('ElvUI_OptionsUI')
		if reason ~= 'MISSING' and reason ~= 'DISABLED' then
			self.GUIFrame = false
			LoadAddOn('ElvUI_OptionsUI')

			--For some reason, GetAddOnInfo reason is 'DEMAND_LOADED' even if the addon is disabled.
			--Workaround: Try to load addon and check if it is loaded right after.
			if not IsAddOnLoaded('ElvUI_OptionsUI') then noConfig = true end

			-- version check elvui options if it's actually enabled
			if (not noConfig) and GetAddOnMetadata('ElvUI_OptionsUI', 'Version') ~= '1.06' then
				self:StaticPopup_Show('CLIENT_UPDATE_REQUEST')
			end
		else
			noConfig = true
		end

		if noConfig then
			self:Print('|cffff0000Error -- Addon "ElvUI_OptionsUI" not found or is disabled.|r')
			return
		end
	end

	local ACD = self.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName]

	local pages, msgStr
	if msg and msg ~= '' then
		pages = {strsplit(',', msg)}
		msgStr = gsub(msg, ',', '\001')
	end

	local mode = 'Close'
	if not ConfigOpen or (pages ~= nil) then
		if pages ~= nil then
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ('^'..self:EscapeString(mainSel)..'\001')
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index+1], pageNodes[index+2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..self:EscapeString(pages[i])..'$') and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index+1], pageNodes[index+2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if ConfigOpen and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				mode = 'Close'
			else
				mode = 'Open'
			end
		else
			mode = 'Open'
		end
	end

	if ACD then
		ACD[mode](ACD, AddOnName)
	end

	if mode == 'Open' then
		ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName]
		if ConfigOpen then
			local frame = ConfigOpen.frame
			if frame and not self.GUIFrame then
				self.GUIFrame = frame
				_G.ElvUIGUIFrame = self.GUIFrame

				self:UpdateConfigSize()
				hooksecurefunc(frame, 'StopMovingOrSizing', AddOn.ConfigStopMovingOrSizing)
			end
		end

		if ACD and pages then
			ACD:SelectGroup(AddOnName, unpack(pages))
		end
	end

	_G.GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end

--HonorFrameLoadTaint workaround
--credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
if (_G.UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
	_G.UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc('UIDropDownMenu_InitializeHelper', function()
		if _G.UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i=1, _G.UIDROPDOWNMENU_MAXLEVELS do
			for j=1, _G.UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G['DropDownList' .. i .. 'Button' .. j]
				if not (issecurevariable(b, 'value') or b:IsShown()) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1, nil
					until issecurevariable(b, 'value')
				end
			end
		end
	end)
end

--CommunitiesUI taint workaround
--credit: https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeTaint
if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
	_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
	hooksecurefunc('UIDropDownMenu_InitializeHelper', function(frame)
		if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
			return
		end
		if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame
		   and not issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, 'displayMode') then
			_G.UIDROPDOWNMENU_OPEN_MENU = nil
			local t, f, prefix, i = _G, issecurevariable, ' \0', 1
			repeat
				i, t[prefix .. i] = i + 1, nil
			until f('UIDROPDOWNMENU_OPEN_MENU')
		end
	end)
end

--CommunitiesUI taint workaround #2
--credit: https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
if (_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
	_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
	local function CleanDropdowns()
		if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
			return
		end
		local f, f2 = _G.FriendsFrame, _G.FriendsTabHeader
		local s = f:IsShown()
		f:Hide()
		f:Show()
		if not f2:IsShown() then
			f2:Show()
			f2:Hide()
		end
		if not s then
			f:Hide()
		end
	end
	hooksecurefunc('Communities_LoadUI', CleanDropdowns)
	hooksecurefunc('SetCVar', function(n)
		if n == 'lastSelectedClubId' then
			CleanDropdowns()
		end
	end)
end
