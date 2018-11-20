local E, L, V, P, G = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local RU = E:NewModule('RaidUtility', 'AceEvent-3.0');

--Cache global variables
--Lua functions
local _G = _G
local unpack, ipairs, pairs, next = unpack, ipairs, pairs, next
local tinsert, twipe, tsort = table.insert, table.wipe, table.sort
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InitiateRolePoll = InitiateRolePoll
local DoReadyCheck = DoReadyCheck
local ToggleFriendsFrame = ToggleFriendsFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetTexCoordsForRole = GetTexCoordsForRole
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GameTooltip_Hide = GameTooltip_Hide

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DisbandRaidButton, ROLE_POLL, RoleCheckButton, READY_CHECK, ReadyCheckButton
-- GLOBALS: RaidControlButton, CompactRaidFrameManager, RaidUtilityPanel, RAID_CONTROL
-- GLOBALS: CompactRaidFrameManagerDisplayFrameHiddenModeToggle, RaidUtility_ShowButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, CLOSE
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLockedModeToggle, RaidUtility_CloseButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll
-- GLOBALS: GameTooltip, RaidUtilityRoleIcons, NUM_RAID_GROUPS, CUSTOM_CLASS_COLORS

E.RaidUtility = RU
local PANEL_HEIGHT = 100

--Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader('player') or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

--Change border when mouse is inside the button
local function ButtonEnter(self)
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

--Change border back to normal when mouse leaves button
local function ButtonLeave(self)
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

-- Function to create buttons in this module
function RU:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local b = CreateFrame("Button", name, parent, template)
	b:Width(width)
	b:Height(height)
	b:Point(point, relativeto, point2, xOfs, yOfs)
	b:HookScript("OnEnter", ButtonEnter)
	b:HookScript("OnLeave", ButtonLeave)
	b:SetTemplate("Transparent")

	if text then
		local t = b:CreateFontString(nil,"OVERLAY",b)
		t:FontTemplate()
		t:Point("CENTER", b, 'CENTER', 0, -1)
		t:SetJustifyH("CENTER")
		t:SetText(text)
		b:SetFontString(t)
	elseif texture then
		local t = b:CreateTexture(nil,"OVERLAY",nil)
		t:SetTexture(texture)
		t:Point("TOPLEFT", b, "TOPLEFT", E.mult, -E.mult)
		t:Point("BOTTOMRIGHT", b, "BOTTOMRIGHT", -E.mult, E.mult)
	end
end

function RU:ToggleRaidUtil(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", 'ToggleRaidUtil')
		return
	end

	if CheckRaidStatus() then
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

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", 'ToggleRaidUtil')
	end
end

-- Credits oRA3 for the RoleIcons
local function sortColoredNames(a, b)
	return a:sub(11) < b:sub(11)
end

local roleIconRoster = {}
local function onEnter(self)
	twipe(roleIconRoster)

	for i = 1, NUM_RAID_GROUPS do
		roleIconRoster[i] = {}
	end

	local role = self.role
	local point = E:GetScreenQuadrant(RaidUtility_ShowButton)
	local bottom = point and find(point, "BOTTOM")
	local left = point and find(point, "LEFT")

	local anchor1 = (bottom and left and "BOTTOMLEFT") or (bottom and "BOTTOMRIGHT") or (left and "TOPLEFT") or "TOPRIGHT"
	local anchor2 = (bottom and left and "BOTTOMRIGHT") or (bottom and "BOTTOMLEFT") or (left and "TOPRIGHT") or "TOPLEFT"
	local anchorX = left and 2 or -2

	GameTooltip:SetOwner(E.UIParent, "ANCHOR_NONE")
	GameTooltip:Point(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G["INLINE_" .. role .. "_ICON"] .. _G[role])

	local name, group, class, groupRole, color, coloredName, _
	for i = 1, GetNumGroupMembers() do
		name, _, group, _, _, class, _, _, _, _, _, groupRole = GetRaidRosterInfo(i)
		if name and groupRole == role then
			color = class == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			coloredName = ("|cff%02x%02x%02x%s"):format(color.r * 255, color.g * 255, color.b * 255, name:gsub("%-.+", "*"))
			tinsert(roleIconRoster[group], coloredName)
		end
	end

	for group, list in ipairs(roleIconRoster) do
		tsort(list, sortColoredNames)
		for _, name in ipairs(list) do
			GameTooltip:AddLine(("[%d] %s"):format(group, name), 1, 1, 1)
		end
		roleIconRoster[group] = nil
	end

	GameTooltip:Show()
end

local function RaidUtility_PositionRoleIcons()
	local point = E:GetScreenQuadrant(RaidUtility_ShowButton)
	local left = point and find(point, "LEFT")
	RaidUtilityRoleIcons:ClearAllPoints()
	if left then
		RaidUtilityRoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", -1, 0)
	else
		RaidUtilityRoleIcons:SetPoint("RIGHT", RaidUtilityPanel, "LEFT", 1, 0)
	end
end

local count = {}
local function UpdateIcons(self)
	local raid = IsInRaid()
	local party --= IsInGroup() --We could have this in party :thinking:

	if not (raid or party) then
		self:Hide()
		return
	else
		self:Show()
		RaidUtility_PositionRoleIcons()
	end

	twipe(count)

	local role
	for i = 1, GetNumGroupMembers() do
		role = UnitGroupRolesAssigned((raid and "raid" or "party")..i)
		if role and role ~= "NONE" then
			count[role] = (count[role] or 0) + 1
		end
	end

	if (not raid) and party then -- only need this party (we believe)
		local myRole = E:GetPlayerRole()
		if myRole then
			count[myRole] = (count[myRole] or 0) + 1
		end
	end

	for role, icon in next, RaidUtilityRoleIcons.icons do
		icon.count:SetText(count[role] or 0)
	end
end

function RU:Initialize()
	if E.private.general.raidUtility == false then return end

	--Create main frame
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", E.UIParent, "SecureHandlerBaseTemplate")
	RaidUtilityPanel:SetScript("OnMouseUp", function(panel, ...)
		SecureHandler_OnClick(panel, "_onclick", ...);
	end)
	RaidUtilityPanel:SetTemplate('Transparent')
	RaidUtilityPanel:Width(230)
	RaidUtilityPanel:Height(PANEL_HEIGHT)
	RaidUtilityPanel:Point('TOP', E.UIParent, 'TOP', -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")
	E.FrameLocks.RaidUtilityPanel = true

	--Show Button
	self:CreateUtilButton("RaidUtility_ShowButton", E.UIParent, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", E.UIParent, "TOP", -400, E.Border, RAID_CONTROL, nil)
	RaidUtility_ShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
	RaidUtility_ShowButton:SetAttribute("_onclick", ([=[
		local raidUtil = self:GetFrameRef("RaidUtilityPanel")
		local closeButton = raidUtil:GetFrameRef("RaidUtility_CloseButton")

		self:Hide()
		raidUtil:Show()

		local point = self:GetPoint()
		local raidUtilPoint, closeButtonPoint, yOffset

		if string.find(point, "BOTTOM") then
			raidUtilPoint = "BOTTOM"
			closeButtonPoint = "TOP"
			yOffset = 1
		else
			raidUtilPoint = "TOP"
			closeButtonPoint = "BOTTOM"
			yOffset = -1
		end

		yOffset = yOffset * (tonumber(%d))

		raidUtil:ClearAllPoints()
		closeButton:ClearAllPoints()
		raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint)
		closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset)
	]=]):format(-E.Border + E.Spacing*3))
	RaidUtility_ShowButton:SetScript("OnMouseUp", function()
		RaidUtilityPanel.toggled = true
		RaidUtility_PositionRoleIcons()
	end)
	RaidUtility_ShowButton:SetMovable(true)
	RaidUtility_ShowButton:SetClampedToScreen(true)
	RaidUtility_ShowButton:SetClampRectInsets(0, 0, -1, 1)
	RaidUtility_ShowButton:RegisterForDrag("RightButton")
	RaidUtility_ShowButton:SetFrameStrata("HIGH")
	RaidUtility_ShowButton:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	E.FrameLocks['RaidUtility_ShowButton'] = true

	RaidUtility_ShowButton:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point = self:GetPoint()
		local xOffset = self:GetCenter()
		local screenWidth = E.UIParent:GetWidth() / 2
		xOffset = xOffset - screenWidth
		self:ClearAllPoints()
		if find(point, "BOTTOM") then
			self:Point('BOTTOM', E.UIParent, 'BOTTOM', xOffset, -1)
		else
			self:Point('TOP', E.UIParent, 'TOP', xOffset, 1)
		end
	end)

	--Close Button
	self:CreateUtilButton("RaidUtility_CloseButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil)
	RaidUtility_CloseButton:SetFrameRef("RaidUtility_ShowButton", RaidUtility_ShowButton)
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtility_ShowButton"):Show();]=])
	RaidUtility_CloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton)

	--Role Icons
	local RoleIcons = CreateFrame("Frame", "RaidUtilityRoleIcons", RaidUtilityPanel)
	RoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", -1, 0)
	RoleIcons:SetSize(36, PANEL_HEIGHT)
	RoleIcons:SetTemplate("Transparent")
	RoleIcons:RegisterEvent("PLAYER_ENTERING_WORLD")
	RoleIcons:RegisterEvent("GROUP_ROSTER_UPDATE")
	RoleIcons:SetScript("OnEvent", UpdateIcons)

	RoleIcons.icons = {}

	local roles = {"TANK", "HEALER", "DAMAGER"}
	for i, role in ipairs(roles) do
		local frame = CreateFrame("Frame", "$parent_"..role, RoleIcons)
		if i == 1 then
			frame:Point("BOTTOM", 0, 4)
		else
			frame:Point("BOTTOM", _G["RaidUtilityRoleIcons_"..roles[i-1]], "TOP", 0, 4)
		end

		frame:SetSize(28, 28)
		--frame:SetTemplate("Default")

		local texture = frame:CreateTexture(nil, "OVERLAY")
		texture:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\UI-LFG-ICON-ROLES") --(337499)
		local texA, texB, texC, texD = GetTexCoordsForRole(role)
		texture:SetTexCoord(texA, texB, texC, texD)
		--[[if E.PixelMode then
			texture:SetTexCoord(texA+0.0015, texB-0.005, texC-0.005, texD-0.01)
		else
			texture:SetTexCoord(texA+0.01, texB-0.01, texC+0.001, texD-0.015)
		end]]
		local texturePlace = --[[(E.PixelMode and 4) or]] 2
		texture:Point("TOPLEFT", frame, "TOPLEFT", -texturePlace, texturePlace)
		texture:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", texturePlace, -texturePlace)
		frame.texture = texture

		local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		count:Point("BOTTOMRIGHT", -2, 2)
		count:SetText(0)
		frame.count = count

		frame.role = role
		frame:SetScript("OnEnter", onEnter)
		frame:SetScript("OnLeave", GameTooltip_Hide)

		RoleIcons.icons[role] = frame
	end

	--Disband Raid button
	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L["Disband Group"], nil)
	DisbandRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			E:StaticPopup_Show("DISBAND_RAID")
		end
	end)

	--Role Check button
	self:CreateUtilButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", DisbandRaidButton, "BOTTOM", 0, -5, ROLE_POLL, nil)
	RoleCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	--MainTank Button
	--[[self:CreateUtilButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -5, MAINTANK, nil)
	MainTankButton:SetAttribute("type", "maintank")
	MainTankButton:SetAttribute("unit", "target")
	MainTankButton:SetAttribute("action", "toggle")

	--MainAssist Button
	self:CreateUtilButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -5, MAINASSIST, nil)
	MainAssistButton:SetAttribute("type", "mainassist")
	MainAssistButton:SetAttribute("unit", "target")
	MainAssistButton:SetAttribute("action", "toggle")]]

	--Ready Check button
	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.75, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -5, READY_CHECK, nil)
	ReadyCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	--Raid Control Panel
	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth(), 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -5, L["Raid Menu"], nil)
	RaidControlButton:SetScript("OnMouseUp", function()
		ToggleFriendsFrame(3)
	end)

	local buttons = {
		"DisbandRaidButton",
		"RoleCheckButton",
		"ReadyCheckButton",
		"RaidControlButton",
		"RaidUtility_ShowButton",
		"RaidUtility_CloseButton"
	}

	if CompactRaidFrameManager then
		--Reposition/Resize and Reuse the World Marker Button
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Point("TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -5)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Height(18)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:Width(RoleCheckButton:GetWidth() * 0.22)

		--Put other stuff back
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:Point("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:Point("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:Point("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:Point("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 0, 1)

		tinsert(buttons, "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton")
	else
		E:StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
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

		f:SetHighlightTexture("")
		f:SetDisabledTexture("")
		f:HookScript("OnEnter", ButtonEnter)
		f:HookScript("OnLeave", ButtonLeave)
		f:SetTemplate("Default", true)
	end

	--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent("GROUP_ROSTER_UPDATE", 'ToggleRaidUtil')
	self:RegisterEvent("PLAYER_ENTERING_WORLD", 'ToggleRaidUtil')
end

local function InitializeCallback()
	RU:Initialize()
end

E:RegisterInitialModule(RU:GetName(), InitializeCallback)
