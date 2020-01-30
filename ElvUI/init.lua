--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Lua functions
local _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, tcopy = _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, table.copy
local tinsert, sort, ipairs, select = tinsert, sort, ipairs, select
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
local DisableAddOn = DisableAddOn
local ReloadUI = ReloadUI

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
local GameTooltip = GameTooltip
-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

_G.BINDING_HEADER_ELVUI = GetAddOnMetadata(..., 'Title')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local E = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
E.callbacks = E.callbacks or CallbackHandler:New(E)
E.DF = {profile = {}, global = {}}; E.privateVars = {profile = {}} -- Defaults
E.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree'}

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
	local arg2,arg3 = '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function E:EscapeString(str)
		return gsub(str,arg2,arg3)
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
	GameMenuButton:SetText(format('|cfffe7b2c%s|r', AddOnName))
	GameMenuButton:SetScript('OnClick', function()
		E:ToggleOptionsUI()
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

function E:PositionGameMenuButton()
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

function E:Config_ResetSettings()
	E.configSavedPositionTop, E.configSavedPositionLeft = nil, nil
	E.global.general.AceGUI = E:CopyTable({}, E.DF.global.general.AceGUI)
end

function E:Config_GetPosition()
	return E.configSavedPositionTop, E.configSavedPositionLeft
end

function E:Config_GetSize()
	return E.global.general.AceGUI.width, E.global.general.AceGUI.height
end

function E:Config_UpdateSize(reset)
	local frame = E:Config_GetWindow()
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(800, 600)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(AddOnName, self:Config_GetDefaultSize())

	local status = frame.obj and frame.obj.status
	if status then
		if reset then
			self:Config_ResetSettings()

			status.top, status.left = self:Config_GetPosition()
			status.width, status.height = self:Config_GetDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = self:Config_GetPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end
	end
end

function E:Config_GetDefaultSize()
	local width, height = E:Config_GetSize()
	local maxWidth, maxHeight = E.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function E:Config_StopMoving()
	if self.obj and self.obj.status then
		E.configSavedPositionTop, E.configSavedPositionLeft = E:Round(self:GetTop(), 2), E:Round(self:GetLeft(), 2)
		E.global.general.AceGUI.width, E.global.general.AceGUI.height = E:Round(self:GetWidth(), 2), E:Round(self:GetHeight(), 2)
	end
end

local function Config_ButtonOnEnter(self)
	if GameTooltip:IsForbidden() or not self.desc then return end

	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 2)
	GameTooltip:AddLine(self.desc, 1, 1, 1, true)
	GameTooltip:Show()
end

local function Config_ButtonOnLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function Config_StripNameColor(name)
	if type(name) == 'function' then name = name() end
	return name:gsub('|c[fF][fF]%x%x%x%x%x%x',''):gsub('|r',''):gsub('|T.-|t','')
end

local function Config_SortButtons(a,b)
	local A1, B1 = a[1], b[1]
	if A1 and B1 then
		if A1 == B1 then
			local A3, B3 = a[3], b[3]
			if A3 and B3 and (A3.name and B3.name) then
				return Config_StripNameColor(A3.name) < Config_StripNameColor(B3.name)
			end
		end
		return A1 < B1
	end
end

local function ConfigSliderOnMouseWheel(self, offset)
	local _, maxValue = self:GetMinMaxValues()
	if maxValue == 0 then return end

	local newValue = self:GetValue() - offset
	if newValue < 0 then newValue = 0 end
	if newValue > maxValue then return end

	self:SetValue(newValue)
	self.buttons:Point("TOPLEFT", 0, newValue * 36)
end

local function ConfigSliderOnValueChanged(self, value)
	self:SetValue(value)
	self.buttons:Point("TOPLEFT", 0, value * 36)
end

function E:Config_SetButtonText(btn, noColor)
	local name = btn.info.name
	if type(name) == 'function' then name = name() end

	if noColor then
		btn:SetText(name:gsub('|c[fF][fF]%x%x%x%x%x%x',''):gsub('|r',''))
	else
		btn:SetText(name)
	end
end

function E:Config_CreateSeparatorLine(frame, lastButton)
	local line = frame.leftHolder.buttons:CreateTexture()
	line:SetTexture(E.Media.Textures.White8x8)
	line:SetVertexColor(.9, .8, 0, .7)
	line:Size(179, 2)
	line:Point("TOP", lastButton, "BOTTOM", 0, -6)
	line.separator = true
	return line
end

function E:Config_SetButtonColor(btn, disabled)
	if disabled then
		btn:Disable()
		btn:SetBackdropBorderColor(.9, .8, 0, 1)
		btn:SetBackdropColor(.9, .8, 0, 0.5)
		btn.Text:SetTextColor(1, 1, 1)
		E:Config_SetButtonText(btn, true)
	else
		btn:Enable()
		btn:SetBackdropColor(unpack(E.media.backdropcolor))
		local r, g, b = unpack(E.media.bordercolor)
		btn:SetBackdropBorderColor(r, g, b, 1)
		btn.Text:SetTextColor(.9, .8, 0)
		E:Config_SetButtonText(btn)
	end
end

function E:Config_CreateButton(info, frame, unskinned, ...)
	local btn = CreateFrame(...)
	btn.frame = frame
	btn.desc = info.desc
	btn.info = info

	if not unskinned then
		E.Skins:HandleButton(btn)
	end

	E:Config_SetButtonText(btn)
	E:Config_SetButtonColor(btn, btn.info.key == 'general')
	btn:HookScript('OnEnter', Config_ButtonOnEnter)
	btn:HookScript('OnLeave', Config_ButtonOnLeave)
	btn:SetScript('OnClick', info.func)
	btn:Width(btn:GetTextWidth() + 40)
	btn.ignoreBorderColors = true

	return btn
end

function E:Config_UpdateLeftButtons()
	local frame = E:Config_GetWindow()
	if not (frame and frame.leftHolder) then return end

	local status = frame.obj.status
	local selected = status and status.groups.selected
	for key, btn in pairs(frame.leftHolder.buttons) do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			E:Config_SetButtonColor(btn, key == selected)
		end
	end
end

function E:Config_UpdateLeftScroller()
	if not (self and self.leftHolder) then return end

	local left = self.leftHolder
	local buttons = left.buttons
	local slider = left.slider
	local max = 0
	slider:SetMinMaxValues(0, max)
	slider:SetValue(0)
	left.buttons:Point("TOPLEFT", 0, 0)

	local buttonsBottom = buttons:GetBottom()
	for _, btn in pairs(buttons) do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			if buttonsBottom > btn:GetBottom() then
				max = max + 1
				slider:SetMinMaxValues(0, max)
			end
		end
	end

	if max == 0 then
		slider.thumb:Hide()
	else
		slider.thumb:Show()
	end
end

function E:Config_SaveOldPosition(frame)
	if frame.GetNumPoints and not frame.oldPosition then
		frame.oldPosition = {}
		for i = 1, frame:GetNumPoints() do
			tinsert(frame.oldPosition, {frame:GetPoint(i)})
		end
	end
end

function E:Config_RestoreOldPosition(frame)
	local position = frame.oldPosition
	if position then
		frame:ClearAllPoints()
		for i = 1, #position do
			frame:Point(unpack(position[i]))
		end
	end
end

function E:Config_CreateLeftButtons(frame, unskinned, options)
	local opts = {}
	for key, info in pairs(options) do
		tinsert(opts, {info.order, key, info})
	end
	sort(opts, Config_SortButtons)

	local buttons, last = frame.leftHolder.buttons
	for _, opt in ipairs(opts) do
		local info = opt[3]
		local key = opt[2]

		info.key = key
		info.func = function()
			local ACD = E.Libs.AceConfigDialog
			if ACD then ACD:SelectGroup("ElvUI", key) end
		end

		local btn = E:Config_CreateButton(info, frame, unskinned, 'Button', nil, buttons, 'UIPanelButtonTemplate')
		btn:Width(177)

		if not last then
			btn:Point("TOP", buttons, "TOP", 0, 0)
		else
			btn:Point("TOP", last, "BOTTOM", 0, (last.separator and -6) or -4)
		end

		buttons[key] = btn
		last = btn

		if key == 'unitframe' or (key == 'profiles' and E.Options.args.plugins) then
			last = E:Config_CreateSeparatorLine(frame, last)
		end
	end
end

function E:Config_CloseClicked()
	if self.originalClose then
		self.originalClose:Click()
	end
end

function E:Config_GetWindow()
	local ACD = E.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName]
	return ConfigOpen and ConfigOpen.frame
end

function E:Config_WindowClosed()
	if not self.bottomHolder then return end

	local frame = E:Config_GetWindow()
	if not frame or frame ~= self then
		self.bottomHolder:Hide()
		self.leftHolder:Hide()
		self.topHolder:Hide()
		self.leftHolder.slider:Hide()
		self.closeButton:Hide()
		self.originalClose:Show()

		E:Config_RestoreOldPosition(self.topHolder.version)
		E:Config_RestoreOldPosition(self.obj.content)
	end
end

function E:Config_WindowOpened(frame)
	if frame and frame.bottomHolder then
		frame.bottomHolder:Show()
		frame.leftHolder:Show()
		frame.topHolder:Show()
		frame.leftHolder.slider:Show()
		frame.closeButton:Show()
		frame.originalClose:Hide()

		local unskinned = not E.private.skins.ace3.enable
		local offset = unskinned and 14 or 8
		local version = frame.topHolder.version
		E:Config_SaveOldPosition(version)
		version:ClearAllPoints()
		version:Point("LEFT", frame.topHolder, "LEFT", unskinned and 8 or 6, unskinned and -4 or 0)

		local holderHeight = frame.bottomHolder:GetHeight()
		local content = frame.obj.content
		E:Config_SaveOldPosition(content)
		content:ClearAllPoints()
		content:Point("TOPLEFT", frame, "TOPLEFT", offset, -(unskinned and 50 or 40))
		content:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -offset, holderHeight + 3)
	end
end

function E:Config_CreateBottomButtons(frame, unskinned)
	local L = self.Libs.ACL:GetLocale('ElvUI', self.global.general.locale or 'enUS')

	local last
	for _, info in pairs({
		{
			var = 'RepositionWindow',
			name = L["Reposition Window"],
			desc = L["Reset the size and position of this frame."],
			func = function()
				self:Config_UpdateSize(true)
			end
		},
		{
			var = 'ToggleTutorials',
			name = L["Toggle Tutorials"],
			func = function()
				self:Tutorials(true)
				self:ToggleOptionsUI()
			end
		},
		{
			var = 'Install',
			name = L["Install"],
			desc = L["Run the installation process."],
			func = function()
				self:Install()
				self:ToggleOptionsUI()
			end
		},
		{
			var = 'ResetAnchors',
			name = L["Reset Anchors"],
			desc = L["Reset all frames to their original positions."],
			func = function()
				self:ResetUI()
			end
		},
		{
			var = 'ToggleAnchors',
			name = L["Toggle Anchors"],
			desc = L["Unlock various elements of the UI to be repositioned."],
			func = function()
				self:ToggleMoveMode()
			end
		}
	}) do
		local btn = E:Config_CreateButton(info, frame, unskinned, 'Button', nil, frame.bottomHolder, 'UIPanelButtonTemplate')
		local offset = unskinned and 14 or 8

		if not last then
			btn:Point("BOTTOMLEFT", frame.bottomHolder, "BOTTOMLEFT", unskinned and 24 or offset, offset)
			last = btn
		else
			btn:Point("LEFT", last, "RIGHT", 4, 0)
			last = btn
		end

		frame.bottomHolder[info.var] = btn
	end
end

local pageNodes = {}
function E:Config_GetToggleMode(frame, msg)
	local pages, msgStr
	if msg and msg ~= '' then
		pages = {strsplit(',', msg)}
		msgStr = gsub(msg, ',', '\001')
	end

	local empty = pages ~= nil
	if not frame or empty then
		if empty then
			local ACD = E.Libs.AceConfigDialog
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ('^'..E:EscapeString(mainSel)..'\001')
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index+1], pageNodes[index+2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..E:EscapeString(pages[i])..'$') and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index+1], pageNodes[index+2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if frame and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				return 'Close'
			else
				return 'Open', pages
			end
		else
			return 'Open'
		end
	else
		return 'Close'
	end
end

function E:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self.ShowOptionsUI = true
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
			if (not noConfig) and GetAddOnMetadata('ElvUI_OptionsUI', 'Version') ~= '1.07' then
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

	local ACD = E.Libs.AceConfigDialog
	local frame = E:Config_GetWindow()
	local mode, pages = E:Config_GetToggleMode(frame, msg)
	if ACD then ACD[mode](ACD, AddOnName) end

	if not frame then
		frame = E:Config_GetWindow()
	end

	if mode == 'Open' and frame then
		if not E.GUIFrame then
			E.GUIFrame = frame

			self:Config_UpdateSize()
			hooksecurefunc(E.Libs.AceConfigRegistry, 'NotifyChange', E.Config_UpdateLeftButtons)
		end

		if frame.bottomHolder then
			E:Config_WindowOpened(frame)
		else -- window was released or never opened
			hooksecurefunc(frame, 'StopMovingOrSizing', E.Config_StopMoving)
			frame:HookScript('OnSizeChanged', E.Config_UpdateLeftScroller)
			frame:HookScript('OnHide', E.Config_WindowClosed)

			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:IsObjectType('Button') and child:GetText() == _G.CLOSE then
					frame.originalClose = child
					child:Hide()
				end
			end

			local unskinned = not E.private.skins.ace3.enable
			if unskinned then
				for i=1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions())
					if region:IsObjectType('Texture') and region:GetTexture() == 131080 then
						region:SetAlpha(0)
					end
				end
			end

			local bottom = CreateFrame('Frame', nil, frame)
			bottom:Point("BOTTOMLEFT", 2, 2)
			bottom:Point("BOTTOMRIGHT", -2, 2)
			bottom:Height(37)
			frame.bottomHolder = bottom

			local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
			close:SetScript("OnClick", E.Config_CloseClicked)
			close:SetFrameLevel(1000)
			close:Point("TOPRIGHT", unskinned and -8 or 1, unskinned and -8 or 2)
			close:Size(32)
			close.originalClose = frame.originalClose
			frame.closeButton = close

			local left = CreateFrame('Frame', nil, frame)
			left:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
			left:Point("TOPLEFT", unskinned and 10 or 2, unskinned and -6 or -2)
			left:Width(181)
			frame.leftHolder = left

			local top = CreateFrame('Frame', nil, frame)
			top.version = frame.obj.titletext
			top:Point("TOPRIGHT", frame, -2, 0)
			top:Point("TOPLEFT", left, "TOPRIGHT", 1, 0)
			top:Height(24)
			frame.topHolder = top

			local logo = left:CreateTexture()
			logo:SetTexture(E.Media.Textures.Logo)
			logo:Point("TOPLEFT", frame, "TOPLEFT", unskinned and 40 or 30, unskinned and -8 or -2)
			logo:Size(126, 64)
			left.logo = logo

			local buttonsHolder = CreateFrame('Frame', nil, left)
			buttonsHolder:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
			buttonsHolder:Point("TOPLEFT", left, "TOPLEFT", 0, -70)
			buttonsHolder:Width(181)
			buttonsHolder:SetFrameLevel(5)
			buttonsHolder:SetClipsChildren(true)
			left.buttonsHolder = buttonsHolder

			local buttons = CreateFrame('Frame', nil, buttonsHolder)
			buttons:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
			buttons:Point("TOPLEFT", 0, 0)
			buttons:Width(181)
			left.buttons = buttons

			local slider = CreateFrame('Slider', nil, frame)
			slider:SetThumbTexture(E.Media.Textures.White8x8)
			slider:SetScript('OnMouseWheel', ConfigSliderOnMouseWheel)
			slider:SetScript('OnValueChanged', ConfigSliderOnValueChanged)
			slider:SetOrientation("VERTICAL")
			slider:SetObeyStepOnDrag(true)
			slider:SetFrameLevel(4)
			slider:SetValueStep(1)
			slider:SetValue(0)
			slider:Width(192)
			slider:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
			slider:Point("TOPLEFT", buttons, "TOPLEFT", 0, 0)
			slider.buttons = buttons
			left.slider = slider

			local thumb = slider:GetThumbTexture()
			thumb:Point("LEFT", left, "RIGHT", 2, 0)
			thumb:SetVertexColor(1, 1, 1, 0.5)
			thumb:SetSize(10, 14)
			left.slider.thumb = thumb

			if not unskinned then
				bottom:SetTemplate("Transparent")
				left:SetTemplate("Transparent")
				top:SetTemplate("Transparent")
				E.Skins:HandleCloseButton(close)
			end

			self:Config_CreateLeftButtons(frame, unskinned, E.Options.args)
			self:Config_CreateBottomButtons(frame, unskinned)

			local titlebg = frame.obj.titlebg
			titlebg:ClearAllPoints()
			titlebg:SetPoint("TOPLEFT", frame)
			titlebg:SetPoint("TOPRIGHT", frame)

			E.Config_UpdateLeftScroller(frame)
		end

		if ACD and pages then
			ACD:SelectGroup(AddOnName, unpack(pages))
		end
	end

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

do --taint workarounds by townlong-yak.com (rearranged by Simpy)
	--CommunitiesUI			- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeTaint
	if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1 end
	--CommunitiesUI #2		- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
	if (_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1 end

	--	*NOTE* Simpy: these two were updated to fix an issue which was caused on the dropdowns with submenus
	--HonorFrameLoadTaint	- https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
	if (_G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 1 then _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION = 1 end
	--RefreshOverread		- https://www.townlong-yak.com/bugs/Mx7CWN-RefreshOverread
	if (_G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 1 then _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION = 1 end

	if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 or _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION == 1 or _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
		local function drop(t, k)
			local c = 42
			t[k] = nil
			while not issecurevariable(t, k) do
				if t[c] == nil then
					t[c] = nil
				end
				c = c + 1
			end
		end

		hooksecurefunc('UIDropDownMenu_InitializeHelper', function(frame)
			if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 or _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
				for i=1, _G.UIDROPDOWNMENU_MAXLEVELS do
					local d = _G['DropDownList' .. i]
					if d and d.numButtons then
						for j = d.numButtons+1, _G.UIDROPDOWNMENU_MAXBUTTONS do
							local b, _ = _G['DropDownList' .. i .. 'Button' .. j]
							if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 and not (issecurevariable(b, 'value') or b:IsShown()) then
								b.value = nil
								repeat j, b['fx' .. j] = j+1, nil
								until issecurevariable(b, 'value')
							end
							if _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
								_ = issecurevariable(b, 'checked')      or drop(b, 'checked')
								_ = issecurevariable(b, 'notCheckable') or drop(b, 'notCheckable')
							end
						end
					end
				end
			end

			if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION == 1 then
				if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, 'displayMode') then
					_G.UIDROPDOWNMENU_OPEN_MENU = nil
					local prefix, i = ' \0', 1
					repeat i, _G[prefix .. i] = i + 1, nil
					until issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU)
				end
			end
		end)
	end

	if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION == 1 then
		local function CleanDropdowns()
			if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION == 1 then
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
		end

		hooksecurefunc('Communities_LoadUI', CleanDropdowns)
		hooksecurefunc('SetCVar', function(n)
			if n == 'lastSelectedClubId' then
				CleanDropdowns()
			end
		end)
	end
end
