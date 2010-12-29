--Raid Utility by Elv22
if TukuiCF["raidframes"].disableblizz ~= true then return end


--Change border when mouse is inside the button
local function ButtonEnter(self)
	local color = RAID_CLASS_COLORS[TukuiDB.myclass]
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end

--Change border back to normal when mouse leaves button
local function ButtonLeave(self)
	self:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end

--Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if (IsRaidLeader() or IsRaidOfficer()) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

--We need this because blizzard raid utility displays if you arent raid leader, we only want it when you are raidleader/assist
local function ToggleRaidUtil(self, event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
		
	if not CheckRaidStatus() then
		CompactRaidFrameManager:Hide()
	end
	
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("RAID_ROSTER_UPDATE")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
LeadershipCheck:SetScript("OnEvent", ToggleRaidUtil)

-- Function to create buttons in this module
local function CreateButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local b = CreateFrame("Button", name, parent, template)
	b:SetWidth(width)
	b:SetHeight(height)
	b:SetPoint(point, relativeto, point2, xOfs, yOfs)
	b:HookScript("OnEnter", ButtonEnter)
	b:HookScript("OnLeave", ButtonLeave)
	b:EnableMouse(true)
	TukuiDB.SetTemplate(b)
	if text then
		local t = b:CreateFontString(nil,"OVERLAY",b, "OUTLINE")
		t:SetFont(TukuiCF.media.font,10,nil)
		t:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
		t:SetPoint("CENTER")
		t:SetJustifyH("CENTER")
		t:SetText(text)
		b:SetFontString(t)
	elseif texture then
		local t = b:CreateTexture(nil,"OVERLAY",nil)
		t:SetTexture(texture)
		t:SetPoint("TOPLEFT", b, "TOPLEFT", TukuiDB.mult, -TukuiDB.mult)
		t:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -TukuiDB.mult, TukuiDB.mult)	
	end
end

--Disband Raid button
CreateButton("DisbandRaidButton", CompactRaidFrameManagerDisplayFrameLeaderOptions, "UIMenuButtonStretchTemplate", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:GetWidth(), CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:GetHeight(), "TOPLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "BOTTOMLEFT", 0, TukuiDB.Scale(-1), tukuilocal.core_raidutil_disbandgroup, nil)
DisbandRaidButton:SetScript("OnClick", function(self)
	StaticPopup_Show("DISBAND_RAID")
end)

--MainTank Button
CreateButton("MainTankButton", CompactRaidFrameManagerDisplayFrameLeaderOptions, "UIMenuButtonStretchTemplate, SecureActionButtonTemplate", (CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:GetWidth() / 2) - 1, CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:GetHeight(), "BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll, "TOPLEFT", 0, 1, MAINTANK, nil)
MainTankButton:SetAttribute("type", "maintank")
MainTankButton:SetAttribute("unit", "target")
MainTankButton:SetAttribute("action", "set")

--MainAssist Button
CreateButton("MainAssistButton", CompactRaidFrameManagerDisplayFrameLeaderOptions, "UIMenuButtonStretchTemplate, SecureActionButtonTemplate", (CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:GetWidth() / 2) - 1, CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:GetHeight(), "BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll, "TOPRIGHT", 0, 1, MAINASSIST, nil)
MainAssistButton:SetAttribute("type", "mainassist")
MainAssistButton:SetAttribute("unit", "target")
MainAssistButton:SetAttribute("action", "set")

--Destroy some things
do
	for i=1, MAX_RAID_GROUPS do
		local f = _G["CompactRaidFrameManagerDisplayFrameFilterGroup"..i]
		TukuiDB.Kill(f)
	end
	
	local buttons = {
		"CompactRaidFrameManagerDisplayFrameFilterRoleTank",
		"CompactRaidFrameManagerDisplayFrameFilterRoleHealer",
		"CompactRaidFrameManagerDisplayFrameFilterRoleDamager",
		"CompactRaidFrameManagerDisplayFrameLockedModeToggle",
		"CompactRaidFrameManagerContainerResizeFrame",
		"CompactRaidFrameManagerDisplayFrameHiddenModeToggle",
		"CompactRaidFrameManagerDisplayFrameOptionsButton"
	}
	
	local textures = {
		"CompactRaidFrameManagerBorderTopLeft",
		"CompactRaidFrameManagerBorderTopRight",
		"CompactRaidFrameManagerBorderBottomLeft",
		"CompactRaidFrameManagerBorderBottomRight",
		"CompactRaidFrameManagerBorderTop",
		"CompactRaidFrameManagerBorderBottom",
		"CompactRaidFrameManagerBorderRight",
		"CompactRaidFrameManagerBg",
		"CompactRaidFrameManagerDisplayFrameHeaderDelineator",
		"CompactRaidFrameManagerDisplayFrameFooterDelineator",
		"CompactRaidFrameManagerDisplayFrameHeaderBackground"
	}
	
	for i, button in pairs(buttons) do
		TukuiDB.Kill(_G[button])
	end
	
	for i, texture in pairs(textures) do
		_G[texture]:SetTexture("")
	end
	
end

--Reskin Stuff
do
	local buttons = {
		"CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck",
		"CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton",
		"CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll",
		"DisbandRaidButton",
		"MainTankButton",
		"MainAssistButton"
	}

	for i, button in pairs(buttons) do
		local f = _G[button]
		_G[button.."Left"]:SetAlpha(0)
		_G[button.."Middle"]:SetAlpha(0)
		_G[button.."Right"]:SetAlpha(0)		
		f:SetHighlightTexture("")
		f:SetDisabledTexture("")
		f:HookScript("OnEnter", ButtonEnter)
		f:HookScript("OnLeave", ButtonLeave)
		TukuiDB.SetNormTexTemplate(f)
	end
	
	TukuiDB.SetTransparentTemplate(CompactRaidFrameManager)
	TukuiDB.CreateShadow(CompactRaidFrameManager)
end

--Move and Resize
do
	CompactRaidFrameManagerToggleButton:ClearAllPoints()
	CompactRaidFrameManagerToggleButton:SetPoint("RIGHT", CompactRaidFrameManager, "RIGHT", -TukuiDB.mult, 0)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidMarker6:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidMarker6:SetPoint("BOTTOMLEFT", MainTankButton, "TOPLEFT", 0, 15)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
	CompactRaidFrameManager:SetHeight(185)
	CompactRaidFrameManager.SetHeight = TukuiDB.dummy -- Dont resize the frame ever again
end