local E, L, V, P, G = unpack(ElvUI)
local RU = E:GetModule('RaidUtility')
local S = E:GetModule('Skins')

local _G = _G
local unpack, next, mod, floor = unpack, next, mod, floor
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
local SetDungeonDifficultyID = SetDungeonDifficultyID
local GetDungeonDifficultyID = GetDungeonDifficultyID
local IsInGroup = IsInGroup
local PlaySound = PlaySound
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitName = UnitName

local ConvertToRaid = C_PartyInfo.ConvertToRaid
local ConvertToParty = C_PartyInfo.ConvertToParty
local SetRestrictPings = C_PartyInfo.SetRestrictPings
local GetRestrictPings = C_PartyInfo.GetRestrictPings
local RestrictPingsTo = Enum.RestrictPingsTo

local IG_MAINMENU_OPTION_CHECKBOX_ON = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local NUM_RAID_GROUPS = NUM_RAID_GROUPS or 8
local NUM_RAID_ICONS = NUM_RAID_ICONS or 8
local PANEL_HEIGHT = E.Retail and 180 or 124
local PANEL_WIDTH = 250
local BUTTON_HEIGHT = 20
local TARGET_SIZE = 22

local CWM = _G.SLASH_CLEAR_WORLD_MARKER1
local TM = _G.SLASH_TARGET_MARKER4
local WM = _G.SLASH_WORLD_MARKER1

-- GLOBALS: C_PartyInfo

local raidMarkers = {}
local roleRoster = {}
local roleCount = {}
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
		button.enabled = enabled
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

function RU:CreateDropdown(name, parent, template, width, point, relativeto, point2, xOfs, yOfs, label, events, eventFunc, func)
	local data = type(name) == 'table' and name
	local dropdown = data or CreateFrame('DropdownButton', name, parent, template)

	if events then
		dropdown:UnregisterAllEvents()

		for _, event in next, events do
			dropdown:RegisterEvent(event)
		end
	end

	dropdown:SetScript('OnEvent', eventFunc)

	if not dropdown:GetPoint() then
		dropdown:Point(point, relativeto, point2, xOfs, yOfs)
	end

	if eventFunc then
		eventFunc(dropdown)
	end

	if not dropdown.label then -- stuff to do once
		dropdown.label = dropdown:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		dropdown.label:Point('LEFT', dropdown.backdrop, 'RIGHT', 4, 0)
		dropdown.label:SetText(label or '')
		dropdown.label:FontTemplate(nil, 12, 'SHADOW')

		S:HandleDropDownBox(dropdown, width)

		func(dropdown)
	end

	return dropdown
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

	if not box.IsSkinned then
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

function RU:CreateRoleIcons()
	local RoleIcons = CreateFrame('Frame', 'RaidUtilityRoleIcons', _G.RaidUtilityPanel)
	RoleIcons:Size(PANEL_WIDTH * 0.4, BUTTON_HEIGHT + 8)
	RoleIcons:SetTemplate('Transparent')
	RoleIcons:RegisterEvent('PLAYER_ENTERING_WORLD')
	RoleIcons:RegisterEvent('GROUP_ROSTER_UPDATE')
	RoleIcons:SetScript('OnEvent', RU.OnEvent_RoleIcons)
	RoleIcons.icons = {}

	for i, data in next, roles do
		local frame = CreateFrame('Frame', '$parent_'..data.role, RoleIcons)

		if i == 1 then
			frame:Point('TOPLEFT', 3, -1)
		else
			local previous = roles[i-1]
			if previous and previous.role then
				frame:Point('LEFT', _G['RaidUtilityRoleIcons_'..previous.role], 'RIGHT', 6, 0)
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

	return RoleIcons
end

function RU:TargetIcons_GetCoords(button)
	local index = button:GetID()
	local idx = (index - 1) * 0.25

	local left = mod(idx, 1)
	local right = left + 0.25
	local top = floor(idx) * 0.25
	local bottom = top + 0.25

	local tex = button:GetNormalTexture()
	tex:SetTexCoord(left, right, top, bottom)
end

do
	local ground = { 5, 6, 3, 2, 7, 1, 4, 8 }
	local keys = { SHIFT = 'shift-', ALT = 'alt-', CTRL = 'ctrl-' }

	function RU:TargetIcons_Update()
		for id, button in next, raidMarkers do
			for _, key in next, keys do -- clear the last ones
				button:SetAttribute(key..'type*', nil)
			end

			RU:TargetIcons_UpdateMacro(button, id)
		end
	end

	function RU:TargetIcons_UpdateMacro(button, i)
		local id = ground[i]
		local tm = format('%s %d', TM, i)

		if E.Classic then
			button:SetAttribute('type', 'macro')
			button:SetAttribute('macrotext', tm)
		else
			local modType = E.db.general.raidUtility.modifierSwap or 'world'
			local modifier = keys[E.db.general.raidUtility.modifier] or 'shift-'
			local wm = format(i == 0 and '%s 0' or '%s %d\n%s %d', CWM, id, WM, id)
			local world = modType == 'world'

			button:SetAttribute(modifier..'type*', 'macro')
			button:SetAttribute('macrotext', world and wm or tm)
			button:SetAttribute('macrotext1', world and tm or wm)
			button:SetAttribute('macrotext2', world and tm or wm)
			button:SetAttribute('macrotext3', world and tm or wm)
		end
	end
end

function RU:CreateTargetIcons()
	local TargetIcons = CreateFrame('Frame', 'RaidUtilityTargetIcons', _G.RaidUtilityPanel)
	TargetIcons:Size(PANEL_WIDTH, BUTTON_HEIGHT + 8)
	TargetIcons:SetTemplate('Transparent')
	TargetIcons.icons = {}

	local num, previous = NUM_RAID_ICONS + 1 -- include clear
	for i = 1, num do
		local id = num - i
		local button = CreateFrame('Button', '$parent_TargetIcon'..i, TargetIcons, 'SecureActionButtonTemplate')
		button:SetScript('OnMouseDown', RU.TargetIcons_MouseDown)
		button:SetScript('OnMouseUp', RU.TargetIcons_MouseUp)
		button:SetScript('OnEnter', RU.TargetIcons_OnEnter)
		button:SetScript('OnLeave', RU.TargetIcons_OnLeave)
		button:SetAttribute('type1', 'macro')
		button:SetAttribute('type2', 'macro')
		button:SetAttribute('type3', 'macro')
		button:SetNormalTexture(i == num and [[Interface\Buttons\UI-GroupLoot-Pass-Up]] or [[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		button:SetID(id)
		button:Size(TARGET_SIZE)
		button.keys = {}

		E:RegisterClicks(button)
		RU:TargetIcons_UpdateMacro(button, id)

		raidMarkers[id] = button

		if i == 1 then
			button:SetPoint('TOPLEFT', TargetIcons, 6, -3)
		else
			button:SetPoint('LEFT', previous, 'RIGHT', 6, 0)
		end

		previous = button

		local tex = button:GetNormalTexture()
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', button)
		tex:Size(TARGET_SIZE)

		if i ~= num then
			RU:TargetIcons_GetCoords(button)
		end
	end

	return TargetIcons
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

function RU:TargetIcons_OnEnter()
	if E.Classic or _G.GameTooltip:IsForbidden() or not E.db.general.raidUtility.showTooltip then return end

	local isTarget = E.db.general.raidUtility.modifierSwap == 'target'
	_G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
	_G.GameTooltip:SetText(L["Raid Markers"])
	_G.GameTooltip:AddLine(' ')
	_G.GameTooltip:AddDoubleLine(isTarget and _G.TARGET or _G.WORLD, L[E.db.general.raidUtility.modifier or "SHIFT"], 0, 1, 0, 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(isTarget and _G.WORLD or _G.TARGET, _G.NONE, 0, 1, 0, 1, 1, 1)
	_G.GameTooltip:Show()
end

function RU:TargetIcons_OnLeave()
	_G.GameTooltip:Hide()
end

function RU:TargetIcons_MouseDown()
	local tex = self:GetNormalTexture()
	local width, height = self:GetSize()
	tex:SetSize(width-4, height-4)
end

function RU:TargetIcons_MouseUp()
	local tex = self:GetNormalTexture()
	tex:SetSize(self:GetSize())
end

function RU:OnClick_RaidUtilityPanel(...)
	SecureHandler_OnClick(self, '_onclick', ...)
end

function RU:DragStart_ShowButton()
	if InCombatLockdown() then return end

	self:StartMoving()
end

function RU:DragStop_ShowButton()
	if InCombatLockdown() then return end

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

	RU:PositionSections()
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
	if self.enabled and RU:InGroup() then
		DoReadyCheck()
	end
end

function RU:OnEvent_RoleCheckButton()
	RU:SetEnabled(self, RU:HasPermission())
end

function RU:OnClick_RoleCheckButton()
	if self.enabled and RU:InGroup() then
		InitiateRolePoll()
	end
end

function RU:OnClick_RaidCountdownButton()
	if RU:InGroup() then
		C_PartyInfo.DoCountdown(10)
	end
end

function RU:OnClick_RaidControlButton()
	ToggleFriendsFrame(3)
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

do
	local function IsSelected(restrictEnum)
		return GetRestrictPings() == restrictEnum
	end

	local function SetSelected(restrictEnum)
		SetRestrictPings(IsSelected(restrictEnum) and RestrictPingsTo.None or restrictEnum)
	end

	local function SetMenu(_, root)
		root:SetTag('ELVUI_RAID_UTILITY_RESTRICT_PINGS')
		root:CreateRadio(_G.NONE, IsSelected, SetSelected, RestrictPingsTo.None)
		root:CreateRadio(_G.RAID_MANAGER_RESTRICT_PINGS_TO_LEAD, IsSelected, SetSelected, RestrictPingsTo.Lead)
		root:CreateRadio(_G.RAID_MANAGER_RESTRICT_PINGS_TO_ASSIST, IsSelected, SetSelected, RestrictPingsTo.Assist)
		root:CreateRadio(_G.RAID_MANAGER_RESTRICT_PINGS_TO_TANKS_HEALERS, IsSelected, SetSelected, RestrictPingsTo.TankHealer)
	end

	function RU:OnDropdown_RestrictPings()
		self:SetupMenu(SetMenu)
	end
end

function RU:OnEvent_RestrictPings()
	self:GenerateMenu()
end

do
	local function IsSelected(difficultyID)
		return GetDungeonDifficultyID() == difficultyID
	end

	local function SetSelected(difficultyID)
		SetDungeonDifficultyID(difficultyID)
	end

	local function SetMenu(_, root)
		root:SetTag('ELVUI_RAID_UTILITY_DIFFICULTY')
		root:CreateRadio(_G.PLAYER_DIFFICULTY1, IsSelected, SetSelected, 1)
		root:CreateRadio(_G.PLAYER_DIFFICULTY2, IsSelected, SetSelected, 2)
		root:CreateRadio(_G.PLAYER_DIFFICULTY6, IsSelected, SetSelected, 23)
	end

	function RU:OnDropdown_DungeonDifficulty()
		self:SetupMenu(SetMenu)
	end
end

function RU:OnEvent_DungeonDifficulty()
	self:GenerateMenu()
end

do
	local function IsSelected(isRaid)
		return IsInRaid() == isRaid
	end

	local function SetSelected(isRaid)
		if isRaid then
			ConvertToRaid()
		else
			ConvertToParty()
		end
	end

	local function SetMenu(_, rootDescription)
		rootDescription:SetTag('MENU_RAID_FRAME_CONVERT_PARTY')
		rootDescription:CreateRadio(_G.RAID, IsSelected, SetSelected, true)
		rootDescription:CreateRadio(_G.PARTY, IsSelected, SetSelected, not true)
	end

	function RU:OnDropdown_ModeControl()
		self:SetupMenu(SetMenu)
	end
end

function RU:OnEvent_ModeControl()
	self:GenerateMenu()
end

function RU:RoleIcons_SortNames(b) -- self is a
	return strsub(self, 11) < strsub(b, 11)
end

function RU:RoleIcons_AddNames(tbl, name, unitClass)
	local color = E:ClassColor(unitClass, true) or PRIEST_COLOR
	tinsert(tbl, format('|cff%02x%02x%02x%s', color.r * 255, color.g * 255, color.b * 255, gsub(name, '%-.+', '*')))
end

function RU:RoleIcons_AddPartyUnit(unit, iconRole)
	local name = UnitExists(unit) and UnitName(unit)
	local unitRole = name and UnitGroupRolesAssigned(unit)
	if unitRole == iconRole then
		local _, unitClass = UnitClass(unit)
		RU:RoleIcons_AddNames(roleRoster[0], name, unitClass)
	end
end

-- Credits oRA3 for the RoleIcons
function RU:OnEnter_Role()
	wipe(roleRoster)

	for i = 0, NUM_RAID_GROUPS do -- use 0 for party
		roleRoster[i] = {}
	end

	local iconRole = self.role
	local isRaid = IsInRaid()
	if IsInGroup() and not isRaid then
		RU:RoleIcons_AddPartyUnit('player', iconRole)
	end

	for i = 1, GetNumGroupMembers() do
		if isRaid then
			local name, _, group, _, _, unitClass, _, _, _, _, _, unitRole = GetRaidRosterInfo(i)
			if name and unitRole == iconRole then
				RU:RoleIcons_AddNames(roleRoster[group], name, unitClass)
			end
		else
			RU:RoleIcons_AddPartyUnit('party'..i, iconRole)
		end
	end

	local point = E:GetScreenQuadrant(ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')
	local left = point and strfind(point, 'LEFT')

	local anchor1 = (bottom and left and 'BOTTOMLEFT') or (bottom and 'BOTTOMRIGHT') or (left and 'TOPLEFT') or 'TOPRIGHT'
	local anchor2 = (bottom and left and 'BOTTOMRIGHT') or (bottom and 'BOTTOMLEFT') or (left and 'TOPRIGHT') or 'TOPLEFT'
	local anchorX = left and 2 or -2

	local GameTooltip = _G.GameTooltip
	GameTooltip:SetOwner(E.UIParent, 'ANCHOR_NONE')
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G['INLINE_'..iconRole..'_ICON'] .. _G[iconRole])

	for group, list in next, roleRoster do
		sort(list, RU.RoleIcons_SortNames)

		for _, name in next, list do
			GameTooltip:AddLine((group == 0 and name) or format('[%d] %s', group, name), 1, 1, 1)
		end

		roleRoster[group] = nil
	end

	GameTooltip:Show()
end

function RU:ReanchorSection(section, bottom, target)
	if section then
		section:ClearAllPoints()

		if bottom then
			section:Point('BOTTOMLEFT', target, 'TOPLEFT', 0, 1)
		else
			section:Point('TOPLEFT', target, 'BOTTOMLEFT', 0, -1)
		end
	end
end

function RU:PositionSections()
	local point = E:GetScreenQuadrant(ShowButton)
	local bottom = point and strfind(point, 'BOTTOM')

	if not InCombatLockdown() then
		RU:ReanchorSection(_G.RaidUtilityTargetIcons, bottom)
	end

	RU:ReanchorSection(_G.RaidUtilityRoleIcons, bottom, _G.RaidUtilityTargetIcons)
end

function RU:OnEvent_RoleIcons(event, initLogin, isReload)
	RU:PositionSections()

	if event ~= 'PLAYER_ENTERING_WORLD' or (initLogin or isReload) then
		wipe(roleCount)

		local isRaid = IsInRaid()
		local unit = isRaid and 'raid' or 'party'
		for i = 1, GetNumGroupMembers() do
			local role = UnitGroupRolesAssigned(unit..i)
			if role and role ~= 'NONE' then
				roleCount[role] = (roleCount[role] or 0) + 1
			end
		end

		if IsInGroup() and not isRaid then
			local role = UnitGroupRolesAssigned('player')
			if role and role ~= 'NONE' then
				roleCount[role] = (roleCount[role] or 0) + 1
			end
		end

		for role, icon in next, _G.RaidUtilityRoleIcons.icons do
			icon.count:SetText(roleCount[role] or 0)
		end
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

	RU:CreateUtilButton(ShowButton, nil, nil, 136, BUTTON_HEIGHT, 'TOP', E.UIParent, 'TOP', -400, E.Border, _G.RAID_CONTROL, nil, nil, nil, RU.OnClick_ShowButton)
	SecureHandlerSetFrameRef(ShowButton, 'RaidUtilityPanel', RaidUtilityPanel)
	ShowButton:RegisterForDrag('RightButton')
	ShowButton:SetFrameStrata('HIGH')
	ShowButton:SetAttribute('_onclick', format([=[
		local utility = self:GetFrameRef('RaidUtilityPanel')
		local close = utility:GetFrameRef('RaidUtility_CloseButton')

		self:Hide()
		utility:Show()
		utility:ClearAllPoints()
		close:ClearAllPoints()

		local x, y, classic = %d, %d, %d == 1
		local point = self:GetPoint()
		if point and strfind(point, 'BOTTOM') then
			utility:SetPoint('BOTTOM', self)

			if classic then
				close:SetPoint('BOTTOM', utility, 'TOP', x, y)
			else
				close:SetPoint('BOTTOMRIGHT', utility, 'TOPRIGHT', -x, y)
			end
		else
			utility:SetPoint('TOP', self)

			if classic then
				close:SetPoint('TOP', utility, 'BOTTOM', x, -y)
			else
				close:SetPoint('TOPRIGHT', utility, 'BOTTOMRIGHT', -x, -y)
			end
		end
	]=], E.allowRoles and E:Scale(1) or 0, E:Scale(30), E.allowRoles and 0 or 1))
	ShowButton:SetScript('OnDragStart', RU.DragStart_ShowButton)
	ShowButton:SetScript('OnDragStop', RU.DragStop_ShowButton)
	E.FrameLocks.RaidUtility_ShowButton = true

	RU:CreateTargetIcons()

	local CloseButton = RU:CreateUtilButton('RaidUtility_CloseButton', RaidUtilityPanel, 'SecureHandlerClickTemplate', PANEL_WIDTH * 0.6, BUTTON_HEIGHT + (E.allowRoles and 8 or 0), 'TOP', RaidUtilityPanel, 'BOTTOM', 0, 0, _G.CLOSE, nil, nil, nil, RU.OnClick_CloseButton)
	SecureHandlerSetFrameRef(CloseButton, 'RaidUtility_ShowButton', ShowButton)
	CloseButton:SetAttribute('_onclick', [=[self:GetParent():Hide(); self:GetFrameRef('RaidUtility_ShowButton'):Show()]=])
	SecureHandlerSetFrameRef(RaidUtilityPanel, 'RaidUtility_CloseButton', CloseButton)

	local BUTTON_WIDTH = PANEL_WIDTH - 20
	local RaidControlButton = RU:CreateUtilButton('RaidUtility_RaidControlButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidUtilityPanel, 'TOPLEFT', 5, -4, L["Raid Menu"], nil, nil, nil, RU.OnClick_RaidControlButton)
	local ReadyCheckButton = RU:CreateUtilButton('RaidUtility_ReadyCheckButton', RaidUtilityPanel, nil, (BUTTON_WIDTH * (E.allowRoles and 0.5 or 1)) + (E.allowRoles and 0 or 5), BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'BOTTOMLEFT', 0, -5, _G.READY_CHECK, nil, buttonEvents, RU.OnEvent_ReadyCheckButton, RU.OnClick_ReadyCheckButton)
	RU:CreateUtilButton('RaidUtility_DisbandRaidButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', RaidControlButton, 'TOPRIGHT', 5, 0, L["Disband Group"], nil, nil, nil, RU.OnClick_DisbandRaidButton)

	local MainTankButton = RU:CreateUtilButton('RaidUtility_MainTankButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'BOTTOMLEFT', 0, -5, _G.MAINTANK, nil, buttonEvents, RU.OnEvent_MainTankButton)
	MainTankButton:SetAttribute('type', 'maintank')
	MainTankButton:SetAttribute('unit', 'target')
	MainTankButton:SetAttribute('action', 'toggle')
	E:RegisterClicks(MainTankButton)

	local MainAssistButton = RU:CreateUtilButton('RaidUtility_MainAssistButton', RaidUtilityPanel, 'SecureActionButtonTemplate', BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'TOPRIGHT', 5, 0, _G.MAINASSIST, nil, buttonEvents, RU.OnEvent_MainAssistButton)
	MainAssistButton:SetAttribute('type', 'mainassist')
	MainAssistButton:SetAttribute('unit', 'target')
	MainAssistButton:SetAttribute('action', 'toggle')
	E:RegisterClicks(MainAssistButton)

	local RaidCountdownButton
	if hasCountdown then
		RaidCountdownButton = RU:CreateUtilButton('RaidUtility_RaidCountdownButton', RaidUtilityPanel, nil, (BUTTON_WIDTH * (E.Retail and 0.5 or 1)) + (E.Retail and 0 or 5), BUTTON_HEIGHT, 'TOPLEFT', MainTankButton, 'BOTTOMLEFT', 0, -5, L["Countdown"], nil, nil, nil, RU.OnClick_RaidCountdownButton)
	end

	if E.allowRoles then
		RU:CreateUtilButton('RaidUtility_RoleCheckButton', RaidUtilityPanel, nil, BUTTON_WIDTH * 0.5, BUTTON_HEIGHT, 'TOPLEFT', ReadyCheckButton, 'TOPRIGHT', 5, 0, _G.ROLE_POLL, nil, buttonEvents, RU.OnEvent_RoleCheckButton, RU.OnClick_RoleCheckButton)
		RU:CreateRoleIcons()
	end

	if E.Retail then -- these use the new dropdown stuff
		RU:CreateDropdown('RaidUtility_RestrictPings', RaidUtilityPanel, 'WowStyle1DropdownTemplate', 85, 'TOPLEFT', RaidCountdownButton or MainTankButton, 'BOTTOMLEFT', 5, -5, L["Restrict Pings"], { 'PLAYER_ROLES_ASSIGNED' }, RU.OnEvent_RestrictPings, RU.OnDropdown_RestrictPings)
		RU:CreateDropdown('RaidUtility_DungeonDifficulty', RaidUtilityPanel, 'WowStyle1DropdownTemplate', 85, 'TOPLEFT', RaidCountdownButton or MainTankButton, 'BOTTOMLEFT', 5, -(BUTTON_HEIGHT + 10), _G.CRF_DIFFICULTY, { 'PLAYER_DIFFICULTY_CHANGED' }, RU.OnEvent_DungeonDifficulty, RU.OnDropdown_DungeonDifficulty)
		RU:CreateDropdown('RaidUtility_ModeControl', RaidUtilityPanel, 'WowStyle1DropdownTemplate', BUTTON_WIDTH * 0.5, 'TOPLEFT', RaidCountdownButton or MainTankButton, 'TOPRIGHT', 5, 2, nil, { 'PLAYER_ROLES_ASSIGNED' }, RU.OnEvent_ModeControl, RU.OnDropdown_ModeControl)
	end

	RU:CreateCheckBox('RaidUtility_EveryoneAssist', RaidUtilityPanel, 'UICheckButtonTemplate', BUTTON_HEIGHT + 4, 'TOPLEFT', _G.RaidUtility_DungeonDifficulty or RaidCountdownButton or MainTankButton, 'BOTTOMLEFT', -4, -3, _G.ALL_ASSIST_LABEL_LONG, buttonEvents, RU.OnEvent_EveryoneAssist, RU.OnClick_EveryoneAssist)

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	RU:RegisterEvent('GROUP_ROSTER_UPDATE', 'ToggleRaidUtil')
	RU:RegisterEvent('PLAYER_ENTERING_WORLD', 'ToggleRaidUtil')
end

E:RegisterModule(RU:GetName())
