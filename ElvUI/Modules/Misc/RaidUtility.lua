local E, L, V, P, G = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local RU = E:GetModule('RaidUtility')

local _G = _G
local unpack, ipairs, pairs, next = unpack, ipairs, pairs, next
local strfind, tinsert, wipe, sort = strfind, tinsert, wipe, sort

local IsInRaid = IsInRaid
local CreateFrame = CreateFrame
local DoReadyCheck = DoReadyCheck
local GameTooltip_Hide = GameTooltip_Hide
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local GetTexCoordsForRole = GetTexCoordsForRole
local InCombatLockdown = InCombatLockdown
local InitiateRolePoll = InitiateRolePoll
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local SecureHandler_OnClick = SecureHandler_OnClick
local ToggleFriendsFrame = ToggleFriendsFrame
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local C_PartyInfo_DoCountdown = C_PartyInfo.DoCountdown

local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local NUM_RAID_GROUPS = NUM_RAID_GROUPS
local PANEL_HEIGHT = 110
local PANEL_WIDTH = 230
local BUTTON_HEIGHT = 20

--Check if We are Raid Leader or Raid Officer
function RU:CheckRaidStatus()
	if UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') then
		local _, instanceType = GetInstanceInfo()
		return instanceType ~= 'pvp' and instanceType ~= 'arena'
	end
end

--Change border when mouse is inside the button
function RU:ButtonEnter()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

--Change border back to normal when mouse leaves button
function RU:ButtonLeave()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local b = CreateFrame('Button', name, parent, template)
	b:Size(width, height)
	b:Point(point, relativeto, point2, xOfs, yOfs)
	b:HookScript('OnEnter', RU.ButtonEnter)
	b:HookScript('OnLeave', RU.ButtonLeave)
	b:SetTemplate(nil, true)

	if text then
		local t = b:CreateFontString(nil, 'OVERLAY')
		t:FontTemplate()
		t:Point('CENTER', b, 'CENTER', 0, -1)
		t:SetJustifyH('CENTER')
		t:SetText(text)
		b:SetFontString(t)
		b.text = t
	elseif texture then
		local t = b:CreateTexture(nil, 'OVERLAY')
		t:SetTexture(texture)
		t:Point('TOPLEFT', b, 'TOPLEFT', 1, -1)
		t:Point('BOTTOMRIGHT', b, 'BOTTOMRIGHT', -1, 1)
		t.tex = texture
		b.texture = t
	end

	RU.Buttons[name] = b
	return b
end

function RU:UpdateMedia()
	for _, btn in pairs(RU.Buttons) do
		if btn.text then btn.text:FontTemplate() end
		if btn.texture then btn.texture:SetTexture(btn.texture.tex) end
		btn:SetTemplate(nil, true)
	end

	if RU.MarkerButton then
		RU.MarkerButton:SetTemplate(nil, true)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
		return
	end

	local RaidUtilityPanel = _G.RaidUtilityPanel
	local RaidUtility_ShowButton = _G.RaidUtility_ShowButton
	if RU:CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtility_ShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtility_ShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtility_ShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED', 'ToggleRaidUtil')
	elseif self.updateMedia and event == 'PLAYER_ENTERING_WORLD' then
		self:UpdateMedia()
		self.updateMedia = nil
	end
end

-- Credits oRA3 for the RoleIcons
local function sortColoredNames(a, b)
	return a:sub(11) < b:sub(11)
end

local roleIconRoster = {}
function RU:RoleOnEnter()
	wipe(roleIconRoster)

	for i = 1, NUM_RAID_GROUPS do
		roleIconRoster[i] = {}
	end

	local role = self.role
	local point = E:GetScreenQuadrant(_G.RaidUtility_ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'BOTTOMRIGHT') or (bottom and 'BOTTOMLEFT') or (left and 'TOPRIGHT') or 'TOPLEFT'
	local anchorX = left and 2 or -2

	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(E.UIParent, 'ANCHOR_NONE')
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G['INLINE_' .. role .. '_ICON'] .. _G[role])

	local name, group, class, groupRole, color, coloredName, _
	for i = 1, GetNumGroupMembers() do
		name, _, group, _, _, class, _, _, _, _, _, groupRole = GetRaidRosterInfo(i)
		if name and groupRole == role then
			color = E:ClassColor(class, true) or PRIEST_COLOR
			coloredName = ('|cff%02x%02x%02x%s'):format(color.r * 255, color.g * 255, color.b * 255, name:gsub('%-.+', '*'))
			tinsert(roleIconRoster[group], coloredName)
		end
	end

	for Group, list in ipairs(roleIconRoster) do
		sort(list, sortColoredNames)
		for _, Name in ipairs(list) do
			GameTooltip:AddLine(('[%d] %s'):format(Group, Name), 1, 1, 1)
		end
		roleIconRoster[Group] = nil
	end

	GameTooltip:Show()
end

function RU:PositionRoleIcons()
	local point = E:GetScreenQuadrant(_G.RaidUtility_ShowButton)
	local left = point and strfind(point, 'LEFT')
	_G.RaidUtilityRoleIcons:ClearAllPoints()
	if left then
		_G.RaidUtilityRoleIcons:Point('LEFT', _G.RaidUtilityPanel, 'RIGHT', -1, 0)
	else
		_G.RaidUtilityRoleIcons:Point('RIGHT', _G.RaidUtilityPanel, 'LEFT', 1, 0)
	end
end

local count = {}
local function UpdateIcons(self)
	if not IsInRaid() then
		self:Hide()
		return
	else
		self:Show()
		RU:PositionRoleIcons()
	end

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
	if E.private.general.raidUtility == false then return end
	self.Initialized = true
	self.updateMedia = true -- update fonts and textures on entering world once, used to set the custom media from a plugin
	self.Buttons = {}

	local RaidUtilityPanel = CreateFrame('Frame', 'RaidUtilityPanel', E.UIParent, 'SecureHandlerBaseTemplate')
	RaidUtilityPanel:SetScript('OnMouseUp', function(panel, ...) SecureHandler_OnClick(panel, '_onclick', ...) end)
	RaidUtilityPanel:SetTemplate('Transparent')
	RaidUtilityPanel:Size(PANEL_WIDTH, PANEL_HEIGHT)
	RaidUtilityPanel:Point('TOP', E.UIParent, 'TOP', -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata('HIGH')
	E.FrameLocks.RaidUtilityPanel = true

	local ShowButton = self:CreateUtilButton('RaidUtility_ShowButton', E.UIParent, 'UIMenuButtonStretchTemplate, SecureHandlerClickTemplate', 136, 18, 'TOP', E.UIParent, 'TOP', -400, E.Border, _G.RAID_CONTROL)
	SecureHandlerSetFrameRef(ShowButton, 'RaidUtilityPanel', RaidUtilityPanel)
	ShowButton:SetAttribute('_onclick', ([=[
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
	]=]):format(-E.Border + E.Spacing*3))
	ShowButton:SetScript('OnMouseUp', function()
		RaidUtilityPanel.toggled = true
		RU:PositionRoleIcons()
	end)
	ShowButton:SetMovable(true)
	ShowButton:SetClampedToScreen(true)
	ShowButton:SetClampRectInsets(0, 0, -1, 1)
	ShowButton:RegisterForDrag('RightButton')
	ShowButton:SetFrameStrata('HIGH')
	ShowButton:SetScript('OnDragStart', function(sb)
		sb:StartMoving()
	end)
	ShowButton:SetScript('OnDragStop', function(sb)
		sb:StopMovingOrSizing()
		local point = sb:GetPoint()
		local xOffset = sb:GetCenter()
		local screenWidth = E.UIParent:GetWidth() / 2
		xOffset = xOffset - screenWidth
		sb:ClearAllPoints()
		if strfind(point, 'BOTTOM') then
			sb:Point('BOTTOM', E.UIParent, 'BOTTOM', xOffset, -1)
		else
			sb:Point('TOP', E.UIParent, 'TOP', xOffset, 1)
		end
	end)
	E.FrameLocks.RaidUtility_ShowButton = true

	local CloseButton = self:CreateUtilButton('RaidUtility_CloseButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate, SecureHandlerClickTemplate', 136, 18, 'TOP', RaidUtilityPanel, 'BOTTOM', 0, -1, _G.CLOSE)
	SecureHandlerSetFrameRef(CloseButton, 'RaidUtility_ShowButton', ShowButton)
	CloseButton:SetAttribute('_onclick', [=[self:GetParent():Hide(); self:GetFrameRef('RaidUtility_ShowButton'):Show();]=])
	CloseButton:SetScript('OnMouseUp', function() RaidUtilityPanel.toggled = false end)
	SecureHandlerSetFrameRef(RaidUtilityPanel, 'RaidUtility_CloseButton', CloseButton)

	local RoleIcons = CreateFrame('Frame', 'RaidUtilityRoleIcons', RaidUtilityPanel)
	RoleIcons:Point('LEFT', RaidUtilityPanel, 'RIGHT', -1, 0)
	RoleIcons:Size(36, PANEL_HEIGHT)
	RoleIcons:SetTemplate('Transparent')
	RoleIcons:RegisterEvent('PLAYER_ENTERING_WORLD')
	RoleIcons:RegisterEvent('GROUP_ROSTER_UPDATE')
	RoleIcons:SetScript('OnEvent', UpdateIcons)
	RoleIcons.icons = {}

	local roles = {'TANK', 'HEALER', 'DAMAGER'}
	for i, role in ipairs(roles) do
		local frame = CreateFrame('Frame', '$parent_'..role, RoleIcons)
		if i == 1 then
			frame:Point('TOP', 0, -5)
		else
			frame:Point('TOP', _G['RaidUtilityRoleIcons_'..roles[i-1]], 'BOTTOM', 0, -8)
		end

		local texture = frame:CreateTexture(nil, 'OVERLAY')
		texture:SetTexture(E.Media.Textures.RoleIcons) --(337499)
		local texA, texB, texC, texD = GetTexCoordsForRole(role)
		texture:SetTexCoord(texA, texB, texC, texD)
		texture:Point('TOPLEFT', frame, 'TOPLEFT', -2, 2)
		texture:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 2, -2)
		frame.texture = texture

		local Count = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		Count:Point('BOTTOMRIGHT', -2, 2)
		Count:SetText(0)
		frame.count = Count

		frame.role = role
		frame:SetScript('OnEnter', RU.RoleOnEnter)
		frame:SetScript('OnLeave', GameTooltip_Hide)
		frame:Size(28)

		RoleIcons.icons[role] = frame
	end

	local BUTTON_WIDTH = PANEL_WIDTH - 20
	self:CreateUtilButton('DisbandRaidButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate', BUTTON_WIDTH, BUTTON_HEIGHT, 'TOP', RaidUtilityPanel, 'TOP', 0, -5, L["Disband Group"])
	_G.DisbandRaidButton:SetScript('OnMouseUp', function()
		if RU:CheckRaidStatus() then
			E:StaticPopup_Show('DISBAND_RAID')
		end
	end)

	self:CreateUtilButton('RoleCheckButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate', BUTTON_WIDTH, BUTTON_HEIGHT, 'TOP', _G.DisbandRaidButton, 'BOTTOM', 0, -5, _G.ROLE_POLL)
	_G.RoleCheckButton:SetScript('OnMouseUp', function() if RU:CheckRaidStatus() then InitiateRolePoll() end end)

	--[[self:CreateUtilButton('MainTankButton', RaidUtilityPanel, 'SecureActionButtonTemplate, UIMenuButtonStretchTemplate', (DisbandRaidButton:GetWidth() / 2) - 2, BUTTON_HEIGHT, 'TOPLEFT', RoleCheckButton, 'BOTTOMLEFT', 0, -5, MAINTANK)
	MainTankButton:SetAttribute('type', 'maintank')
	MainTankButton:SetAttribute('unit', 'target')
	MainTankButton:SetAttribute('action', 'toggle')

	self:CreateUtilButton('MainAssistButton', RaidUtilityPanel, 'SecureActionButtonTemplate, UIMenuButtonStretchTemplate', (DisbandRaidButton:GetWidth() / 2) - 2, BUTTON_HEIGHT, 'TOPRIGHT', RoleCheckButton, 'BOTTOMRIGHT', 0, -5, MAINASSIST)
	MainAssistButton:SetAttribute('type', 'mainassist')
	MainAssistButton:SetAttribute('unit', 'target')
	MainAssistButton:SetAttribute('action', 'toggle')]]

	self:CreateUtilButton('ReadyCheckButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate', BUTTON_WIDTH * 0.79, BUTTON_HEIGHT, 'TOPLEFT', _G.RoleCheckButton, 'BOTTOMLEFT', 0, -5, _G.READY_CHECK)
	_G.ReadyCheckButton:SetScript('OnMouseUp', function() if RU:CheckRaidStatus() then DoReadyCheck() end end)

	self:CreateUtilButton('RaidControlButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate', BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', _G.ReadyCheckButton, 'BOTTOMLEFT', 0, -5, L["Raid Menu"])
	_G.RaidControlButton:SetScript('OnMouseUp', function() ToggleFriendsFrame(3) end)

	self:CreateUtilButton('RaidCountdownButton', RaidUtilityPanel, 'UIMenuButtonStretchTemplate', BUTTON_WIDTH * 0.49, BUTTON_HEIGHT, 'TOPLEFT', _G.RaidControlButton, 'TOPRIGHT', 2, 0, _G.PLAYER_COUNTDOWN_BUTTON)
	_G.RaidCountdownButton:SetScript('OnMouseUp', function() C_PartyInfo_DoCountdown(10) end)

	local buttons = {
		'DisbandRaidButton',
		'RoleCheckButton',
		'ReadyCheckButton',
		'RaidControlButton',
		'RaidCountdownButton',
		'RaidUtility_ShowButton',
		'RaidUtility_CloseButton'
	}

	if _G.CompactRaidFrameManager then
		--Reposition/Resize and Reuse the World Marker Button
		tinsert(buttons, 'CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton')
		local marker = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
		marker:SetParent('RaidUtilityPanel')
		marker:ClearAllPoints()
		marker:Point('TOPRIGHT', _G.RoleCheckButton, 'BOTTOMRIGHT', 0, -5)
		marker:Size(BUTTON_WIDTH * 0.2, BUTTON_HEIGHT)
		marker:HookScript('OnEnter', RU.ButtonEnter)
		marker:HookScript('OnLeave', RU.ButtonLeave)
		self.MarkerButton = marker

		-- Since we steal the Marker Button for our utility panel, move the Ready Check button over a bit
		local readyCheck = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck
		readyCheck:ClearAllPoints()
		readyCheck:Point('BOTTOMLEFT', _G.CompactRaidFrameManagerDisplayFrameLockedModeToggle, 'TOPLEFT', 0, 1)
		readyCheck:Point('BOTTOMRIGHT', _G.CompactRaidFrameManagerDisplayFrameHiddenModeToggle, 'TOPRIGHT', 0, 1)
		self.ReadyCheck = readyCheck
	else
		E:StaticPopup_Show('WARNING_BLIZZARD_ADDONS')
	end

	--Reskin Stuff
	for _, button in pairs(buttons) do
		local f = _G[button]
		f.BottomLeft:SetAlpha(0)
		f.BottomRight:SetAlpha(0)
		f.BottomMiddle:SetAlpha(0)
		f.TopMiddle:SetAlpha(0)
		f.TopLeft:SetAlpha(0)
		f.TopRight:SetAlpha(0)
		f.MiddleLeft:SetAlpha(0)
		f.MiddleRight:SetAlpha(0)
		f.MiddleMiddle:SetAlpha(0)

		f:SetHighlightTexture('')
		f:SetDisabledTexture('')
	end

	--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent('GROUP_ROSTER_UPDATE', 'ToggleRaidUtil')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'ToggleRaidUtil')
end

E:RegisterInitialModule(RU:GetName())
