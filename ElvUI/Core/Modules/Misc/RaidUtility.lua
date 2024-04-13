local E, L, V, P, G = unpack(ElvUI)
local RU = E:GetModule('RaidUtility')
local S = E:GetModule('Skins')

local _G = _G
local unpack, next = unpack, next
local strsub, format, gsub, type = strsub, format, gsub, type
local strfind, tinsert, wipe, sort = strfind, tinsert, wipe, sort

local IsInRaid = IsInRaid
local CreateFrame = CreateFrame
local DoReadyCheck = DoReadyCheck
local GameTooltip_Hide = GameTooltip_Hide
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local GetTexCoordsByGrid = GetTexCoordsByGrid
local InCombatLockdown = InCombatLockdown
local InitiateRolePoll = InitiateRolePoll
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local SecureHandler_OnClick = SecureHandler_OnClick
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local IsEveryoneAssistant = IsEveryoneAssistant
local SetEveryoneIsAssistant = SetEveryoneIsAssistant
local PlaySound = PlaySound
local IsInGroup = IsInGroup

local SetRestrictPings = C_PartyInfo.SetRestrictPings
local GetRestrictPings = C_PartyInfo.GetRestrictPings

local IG_MAINMENU_OPTION_CHECKBOX_ON = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local NUM_RAID_GROUPS = NUM_RAID_GROUPS
local PANEL_HEIGHT = E.Retail and 154 or 130
local PANEL_WIDTH = 230
local BUTTON_HEIGHT = 20

-- GLOBALS: C_PartyInfo

local roles = {
	{ role = 'TANK' },
	{ role = 'HEALER' },
	{ role = 'DAMAGER' }
}

local buttonEvents = {
	'GROUP_ROSTER_UPDATE',
	'PARTY_LEADER_CHANGED'
}

local function SetGrabCoords(data, xOffset, yOffset)
	data.texA, data.texB, data.texC, data.texD = GetTexCoordsByGrid(xOffset, yOffset, 256, 256, 67, 67)
end

SetGrabCoords(roles[1], 1, 2)
SetGrabCoords(roles[2], 2, 1)
SetGrabCoords(roles[3], 2, 2)

local ShowButton = CreateFrame('Button', 'RaidUtility_ShowButton', E.UIParent, 'SecureHandlerClickTemplate')
ShowButton:SetMovable(true)
ShowButton:SetClampedToScreen(true)
ShowButton:SetClampRectInsets(0, 0, -1, 1)
ShowButton:Hide()

function RU:SetEnabled(button, enabled, isLeader)
	if button.SetChecked then
		button:SetChecked(enabled)
	else
		button:SetEnabled(enabled)
	end

	if button.Text then -- show text grey when isLeader is false, nil and true should be white
		button.Text:SetFormattedText('%s%s|r', ((isLeader ~= nil and isLeader) or (isLeader == nil and enabled)) and '|cFFffffff' or '|cFF888888', button.label)
	end
end

function RU:CleanButton(button)
	button.BottomLeft:SetAlpha(0)
	button.BottomRight:SetAlpha(0)
	button.BottomMiddle:SetAlpha(0)
	button.TopMiddle:SetAlpha(0)
	button.TopLeft:SetAlpha(0)
	button.TopRight:SetAlpha(0)
	button.MiddleLeft:SetAlpha(0)
	button.MiddleRight:SetAlpha(0)
	button.MiddleMiddle:SetAlpha(0)

	button:SetHighlightTexture(E.ClearTexture)
	button:SetDisabledTexture(E.ClearTexture)
end

function RU:NotInPVP()
	local _, instanceType = GetInstanceInfo()
	return instanceType ~= 'pvp' and instanceType ~= 'arena'
end

function RU:IsLeader()
	return UnitIsGroupLeader('player') and RU:NotInPVP()
end

function RU:HasPermission()
	return (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player')) and RU:NotInPVP()
end

function RU:InGroup()
	return IsInGroup() and RU:NotInPVP()
end

-- Change border when mouse is inside the button
function RU:OnEnter_Button()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

-- Change border back to normal when mouse leaves button
function RU:OnLeave_Button()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

function RU:CreateCheckBox(name, parent, template, size, point, relativeto, point2, xOfs, yOfs, label, events, eventFunc, clickFunc)
	local checkbox = type(name) == 'table' and name
	local box = checkbox or CreateFrame('CheckButton', name, parent, template)
	box:Size(size)
	box.label = label or ''

	if events then
		box:UnregisterAllEvents()

		for _, event in next, events do
			box:RegisterEvent(event)
		end
	end

	box:SetScript('OnEvent', eventFunc)
	box:SetScript('OnClick', clickFunc)

	if not box.isSkinned then
		S:HandleCheckBox(box)
	end

	if box.Text then
		box.Text:Point('LEFT', box, 'RIGHT', 2, 0)
		box.Text:SetText(box.label)
	end

	if not box:GetPoint() then
		box:Point(point, relativeto, point2, xOfs, yOfs)
	end

	if eventFunc then
		eventFunc(box)
	end

	RU.CheckBoxes[name] = box

	return box
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, label, texture, events, eventFunc, mouseFunc)
	local button = type(name) == 'table' and name
	local btn = button or CreateFrame('Button', name, parent, template)
	btn:HookScript('OnEnter', RU.OnEnter_Button)
	btn:HookScript('OnLeave', RU.OnLeave_Button)
	btn:Size(width, height)
	btn:SetTemplate(nil, true)
	btn.label = label or ''

	if events then
		btn:UnregisterAllEvents()

		for _, event in next, events do
			btn:RegisterEvent(event)
		end
	end

	btn:SetScript('OnEvent', eventFunc)
	btn:SetScript('OnMouseUp', mouseFunc)

	if not btn:GetPoint() then
		btn:Point(point, relativeto, point2, xOfs, yOfs)
	end

	if label then
		local text = btn:CreateFontString(nil, 'OVERLAY')
		text:FontTemplate()
		text:Point('CENTER', btn, 'CENTER', 0, -1)
		text:SetJustifyH('CENTER')
		text:SetText(btn.label)
		btn:SetFontString(text)
		btn.Text = text
	elseif texture then
		local tex = btn:CreateTexture(nil, 'OVERLAY')
		tex:SetTexture(texture)
		tex:Point('TOPLEFT', btn, 'TOPLEFT', 1, -1)
		tex:Point('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', -1, 1)
		tex.tex = texture
		btn.texture = tex
	end

	if eventFunc then
		eventFunc(btn)
	end

	RU.Buttons[name] = btn

	return btn
end

function RU:UpdateMedia()
	for _, btn in next, RU.Buttons do
		if btn.Text then btn.Text:FontTemplate() end
		if btn.texture then btn.texture:SetTexture(btn.texture.tex) end
		btn:SetTemplate(nil, true)
	end

	if RU.MarkerButton then
		RU.MarkerButton:SetTemplate(nil, true)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		RU:RegisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
		return
	end

	local panel = _G.RaidUtilityPanel
	local status = RU:InGroup()
	ShowButton:SetShown(status and not panel.toggled)
	panel:SetShown(status and panel.toggled)

	if event == 'PLAYER_REGEN_ENABLED' then
		RU:UnregisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
	elseif RU.updateMedia and event == 'PLAYER_ENTERING_WORLD' then
		RU:UpdateMedia()
		RU.updateMedia = nil
	end
end

function RU:OnClick_RaidUtilityPanel(...)
	SecureHandler_OnClick(self, '_onclick', ...)
end

function RU:DragStart_ShowButton()
	self:StartMoving()
end

function RU:DragStop_ShowButton()
	self:StopMovingOrSizing()

	local point = self:GetPoint()
	local xOffset = self:GetCenter()
	local screenWidth = E.UIParent:GetWidth() * 0.5
	xOffset = xOffset - screenWidth

	self:ClearAllPoints()
	if strfind(point, 'BOTTOM') then
		self:Point('BOTTOM', E.UIParent, 'BOTTOM', xOffset, -1)
	else
		self:Point('TOP', E.UIParent, 'TOP', xOffset, 1)
	end
end

function RU:OnClick_ShowButton()
	_G.RaidUtilityPanel.toggled = true

	RU:PositionRoleIcons()
end

function RU:OnClick_CloseButton()
	_G.RaidUtilityPanel.toggled = false
end

function RU:OnClick_DisbandRaidButton()
	if RU:InGroup() then
		E:StaticPopup_Show('DISBAND_RAID')
	end
end

function RU:OnEvent_ReadyCheckButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_ReadyCheckButton()
	if RU:InGroup() then
		DoReadyCheck()
	end
end

function RU:OnEvent_RoleCheckButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_RoleCheckButton()
	if RU:InGroup() then
		InitiateRolePoll()
	end
end

function RU:OnClick_RaidCountdownButton()
	if RU:InGroup() then
		C_PartyInfo.DoCountdown(10)
	end
end

function RU:OnClick_RaidControlButton()
	ToggleFriendsFrame(E.Retail and 3 or 4)
end

function RU:OnEvent_MainTankButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnEvent_MainAssistButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_EveryoneAssist()
	if RU:IsLeader() then
		PlaySound(IG_MAINMENU_OPTION_CHECKBOX_ON)
		SetEveryoneIsAssistant(self:GetChecked())
	else
		self:SetChecked(IsEveryoneAssistant())
	end
end

function RU:OnEvent_EveryoneAssist()
	RU:SetEnabled(self, IsEveryoneAssistant(), RU:IsLeader())
end

function RU:OnClick_RestrictPings()
	if RU:HasPermission() then
		PlaySound(IG_MAINMENU_OPTION_CHECKBOX_ON)
		SetRestrictPings(self:GetChecked())
	else
		self:SetChecked(GetRestrictPings())
	end
end

function RU:OnEvent_RestrictPings()
	RU:SetEnabled(self, GetRestrictPings(), RU:HasPermission())
end

-- Credits oRA3 for the RoleIcons
local function sortColoredNames(a, b)
	return strsub(a, 11) < strsub(b, 11)
end

local roleIconRoster = {}
function RU:OnEnter_Role()
	wipe(roleIconRoster)

	for i = 1, NUM_RAID_GROUPS do
		roleIconRoster[i] = {}
	end

	local role = self.role
	local point = E:GetScreenQuadrant(ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'BOTTOMRIGHT') or (bottom and 'BOTTOMLEFT') or (left and 'TOPRIGHT') or 'TOPLEFT'
	local anchorX = left and 2 or -2

	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(E.UIParent, 'ANCHOR_NONE')
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G['INLINE_' .. role .. '_ICON'] .. _G[role])

	for i = 1, GetNumGroupMembers() do
		local name, _, group, _, _, class, _, _, _, _, _, groupRole = GetRaidRosterInfo(i)
		if name and groupRole == role then
			local color = E:ClassColor(class, true) or PRIEST_COLOR
			tinsert(roleIconRoster[group], format('|cff%02x%02x%02x%s', color.r * 255, color.g * 255, color.b * 255, gsub(name, '%-.+', '*')))
		end
	end

	for group, list in next, roleIconRoster do
		sort(list, sortColoredNames)

		for _, name in next, list do
			GameTooltip:AddLine(format('[%d] %s', group, name), 1, 1, 1)
		end

		roleIconRoster[group] = nil
	end

	GameTooltip:Show()
end

function RU:PositionRoleIcons()
	if E.Retail or E.Cata then
		_G.RaidUtilityRoleIcons:ClearAllPoints()

		local point = E:GetScreenQuadrant(ShowButton)
		if point and strfind(point, 'LEFT') then
			_G.RaidUtilityRoleIcons:Point('LEFT', _G.RaidUtilityPanel, 'RIGHT', -1, 0)
		else
			_G.RaidUtilityRoleIcons:Point('RIGHT', _G.RaidUtilityPanel, 'LEFT', 1, 0)
		end
	end
end

local count = {}
function RU:OnEvent_RoleIcons()
	local isInRaid = IsInRaid()
	self:SetShown(isInRaid)

	if not isInRaid then return end

	RU:PositionRoleIcons()

	wipe(count)

	for i = 1, GetNumGroupMembers() do
		local role = UnitGroupRolesAssigned('raid'..i)
		if role and role ~= 'NONE' then
			count[role] = (count[role] or 0) + 1
		end
	end

	for Role, icon in next, _G.RaidUtilityRoleIcons.icons do
		icon.count:SetText(count[Role] or 0)
	end
end

function RU:Initialize()
	if not (E.private.general.raidUtility and E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid) then return end

	RU.Initialized = true
	RU.updateMedia = true -- update fonts and textures on entering world once, used to set the custom media from a plugin

	RU.Buttons = {}
	RU.CheckBoxes = {}

	local hasCountdown = C_PartyInfo.DoCountdown
	local countdownHeight = hasCountdown and 0 or 25

	local RaidUtilityPanel = CreateFrame('Frame', 'RaidUtilityPanel', E.UIParent, 'SecureHandlerBaseTemplate')
	RaidUtilityPanel:SetScript('OnMouseUp', RU.OnClick_RaidUtilityPanel)
	RaidUtilityPanel:SetTemplate('Transparent')
	RaidUtilityPanel:Size(PANEL_WIDTH, PANEL_HEIGHT - countdownHeight)
	RaidUtilityPanel:Point('TOP', E.UIParent, 'TOP', -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata('HIGH')
	E.FrameLocks.RaidUtilityPanel = true

	RU:CreateUtilButton(ShowButton, nil, nil, 136, 18, 'TOP', E.UIParent, 'TOP', -400, E.Border, _G.RAID_CONTROL, nil, nil, nil, RU.OnClick_ShowButton)
	SecureHandlerSetFrameRef(ShowButton, 'RaidUtilityPanel', RaidUtilityPanel)
	ShowButton:RegisterForDrag('RightButton')
	ShowButton:SetFrameStrata('HIGH')
	ShowButton:SetAttribute('_onclick', format([=[
		local raidUtil = self:GetFrameRef('RaidUtilityPanel')
		local closeButton = raidUtil:GetFrameRef('RaidUtility_CloseButton')

		self:Hide()
		raidUtil:Show()

		local point = self:GetPoint()
		local raidUtilPoint, closeButtonPoint, yOffset

		if strfind(point, 'BOTTOM') then
			raidUtilPoint = 'BOTTOM'
			closeButtonPoint = 'TOP'
			yOffset = 1
		else
			raidUtilPoint = 'TOP'
			closeButtonPoint = 'BOTTOM'
			yOffset = -1
		end

		yOffset = yOffset * (tonumber(%d))

		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint)
		closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset)
	]=], -E.Border + E.Spacing*3))
	ShowButton:SetScript('OnDragStart', RU.DragStart_ShowButton)
	ShowButton:SetScript('OnDragStop', RU.DragStop_ShowButton)
	E.FrameLocks.RaidUtility_ShowButton = true

	local CloseButton = RU:CreateUtilButton('RaidUtility_CloseButton', RaidUtilityPanel, 'SecureHandlerClickTemplate', 136, 18, 'TOP', RaidUtilityPanel, 'BOTTOM', 0, -1, _G.CLOSE, nil, nil, nil, RU.OnClick_CloseButton)
	SecureHandlerSetFrameRef(CloseButton, 'RaidUtility_ShowButton', ShowButton)
	CloseButton:SetAttribute('_onclick', [=[self:GetParent():Hide(); self:GetFrameRef('RaidUtility_ShowButton'):Show()]=])
	SecureHandlerSetFrameRef(RaidUtilityPanel, 'RaidUtility_CloseButton', CloseButton)

	if E.Retail or E.Cata then
		local RoleIcons = CreateFrame('Frame', 'RaidUtilityRoleIcons', RaidUtilityPanel)
		RoleIcons:Point('LEFT', RaidUtilityPanel, 'RIGHT', -1, 0)
		RoleIcons:Size(36, PANEL_HEIGHT - countdownHeight)
		RoleIcons:SetTemplate('Transparent')
		RoleIcons:RegisterEvent('PLAYER_ENTERING_WORLD')
		RoleIcons:RegisterEvent('GROUP_ROSTER_UPDATE')
		RoleIcons:SetScript('OnEvent', RU.OnEvent_RoleIcons)
		RoleIcons.icons = {}

		for i, data in next, roles do
			local frame = CreateFrame('Frame', '$parent_'..data.role, RoleIcons)

			if i == 1 then
				frame:Point('TOP', 0, -5)
			else
				local previous = roles[i-1]
				if previous and previous.role then
					frame:Point('TOP', _G['RaidUtilityRoleIcons_'..previous.role], 'BOTTOM', 0, -8)
				end
			end

			local texture = frame:CreateTexture(nil, 'OVERLAY')
			texture:SetTexture(E.Media.Textures.RoleIcons) -- 337499
			texture:SetTexCoord(data.texA, data.texB, data.texC, data.texD)
			texture:Point('TOPLEFT', frame, 'TOPLEFT', -2, 2)
			texture:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 2, -2)
			frame.texture = texture

			local Count = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
			Count:Point('BOTTOMRIGHT', -2, 2)
			Count:SetText(0)
			frame.count = Count

			frame.role = data.role
			frame:SetScript('OnEnter', RU.OnEnter_Role)
			frame:SetScript('OnLeave', GameTooltip_Hide)
			frame:Size(28)

			RoleIcons.icons[data.role] = frame
		end
	end

	local BUTTON_WIDTH = PANEL_WIDTH - 20
	local RaidControlButton = RU:CreateUtilButton('RaidUtility_RaidControlButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', RaidUtilityPanel, 'TOPLEFT', 10, -4, L["Raid Menu"], nil, nil, nil, RU.OnClick_RaidControlButton)
	local ReadyCheckButton = RU:CreateUtilButton('RaidUtility_ReadyCheckButton', RaidUtilityPanel, nil, BUTTON_WIDTH * (E.Classic and 1 or 0.49), BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'BOTTOMLEFT', 0, -5, _G.READY_CHECK, nil, buttonEvents, RU.OnEvent_ReadyCheckButton, RU.OnClick_ReadyCheckButton)
	RU:CreateUtilButton('RaidUtility_DisbandRaidButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'TOPRIGHT', 3, 0, L["Disband Group"], nil, nil, nil, RU.OnClick_DisbandRaidButton)

	if E.Retail or E.Cata then
		RU:CreateUtilButton('RaidUtility_RoleCheckButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'TOPRIGHT', 3, 0, _G.ROLE_POLL, nil, buttonEvents, RU.OnEvent_RoleCheckButton, RU.OnClick_RoleCheckButton)
	end

	local MainTankButton = RU:CreateUtilButton('RaidUtility_MainTankButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'BOTTOMLEFT', 0, -5, _G.MAINTANK, nil, buttonEvents, RU.OnEvent_MainTankButton)
	MainTankButton:SetAttribute('type', 'maintank')
	MainTankButton:SetAttribute('unit', 'target')
	MainTankButton:SetAttribute('action', 'toggle')
	MainTankButton:RegisterForClicks('AnyDown', 'AnyUp')

	local MainAssistButton = RU:CreateUtilButton('RaidUtility_MainAssistButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'TOPRIGHT', 3, 0, _G.MAINASSIST, nil, buttonEvents, RU.OnEvent_MainAssistButton)
	MainAssistButton:SetAttribute('type', 'mainassist')
	MainAssistButton:SetAttribute('unit', 'target')
	MainAssistButton:SetAttribute('action', 'toggle')
	MainAssistButton:RegisterForClicks('AnyDown', 'AnyUp')

	local RaidCountdownButton
	if hasCountdown then
		RaidCountdownButton = RU:CreateUtilButton('RaidUtility_RaidCountdownButton', RaidUtilityPanel, nil, BUTTON_WIDTH * (E.Retail and 0.78 or 1), BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'BOTTOMLEFT', 0, -5, L["Countdown"], nil, nil, nil, RU.OnClick_RaidCountdownButton)
	end

	local EveryoneAssist = RU:CreateCheckBox('RaidUtility_EveryoneAssist', RaidUtilityPanel, 'UICheckButtonTemplate', BUTTON_HEIGHT + 4, 'TOPLEFT', RaidCountdownButton or MainTankButton, 'BOTTOMLEFT', -4, -3, _G.ALL_ASSIST_LABEL_LONG, buttonEvents, RU.OnEvent_EveryoneAssist, RU.OnClick_EveryoneAssist)
	if SetRestrictPings then
		RU:CreateCheckBox('RaidUtility_RestrictPings', RaidUtilityPanel, 'UICheckButtonTemplate', BUTTON_HEIGHT + 4, 'TOPLEFT', EveryoneAssist, 'BOTTOMLEFT', 0, 0, _G.RAID_MANAGER_RESTRICT_PINGS, buttonEvents, RU.OnEvent_RestrictPings, RU.OnClick_RestrictPings)
	end

	if E.Retail then
		if _G.CompactRaidFrameManager then
			-- Reposition/Resize and Reuse the World Marker Button
			local marker = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
			marker:SetParent(RaidUtilityPanel)
			marker:ClearAllPoints()
			marker:Point('TOPLEFT', RaidCountdownButton, 'TOPRIGHT', 3, 0)
			marker:Size(BUTTON_WIDTH * 0.2, BUTTON_HEIGHT)
			marker:HookScript('OnEnter', RU.OnEnter_Button)
			marker:HookScript('OnLeave', RU.OnLeave_Button)
			RU:CleanButton(marker)
			RU.MarkerButton = marker

			-- Since we steal the Marker Button for our utility panel, move the Ready Check button over a bit
			local readyCheck = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck
			readyCheck:ClearAllPoints()
			readyCheck:Point('BOTTOMLEFT', _G.CompactRaidFrameManagerDisplayFrameLockedModeToggle, 'TOPLEFT', 0, 1)
			readyCheck:Point('BOTTOMRIGHT', _G.CompactRaidFrameManagerDisplayFrameHiddenModeToggle, 'TOPRIGHT', 0, 1)
			RU.ReadyCheck = readyCheck
		else
			E:StaticPopup_Show('WARNING_BLIZZARD_ADDONS')
		end
	end

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	RU:RegisterEvent('GROUP_ROSTER_UPDATE', 'ToggleRaidUtil')
	RU:RegisterEvent('PLAYER_ENTERING_WORLD', 'ToggleRaidUtil')
end

E:RegisterModule(RU:GetName())
