--Raid Utility by Elv22
if TukuiCF["raidframes"].disableblizz ~= true then return end
TukuiDB.Kill(CompactRaidFrameManager) --Get rid of old module

local panel_height = ((TukuiDB.Scale(5)*4) + (TukuiDB.Scale(20)*4))

--Create main frame
local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
TukuiDB.CreatePanel(RaidUtilityPanel, TukuiDB.Scale(170), panel_height, "TOP", UIParent, "TOP", -300, panel_height + 15)
local r,g,b,_ = TukuiCF["media"].backdropcolor
RaidUtilityPanel:SetBackdropColor(r,g,b,0.6)
TukuiDB.CreateShadow(RaidUtilityPanel)

--Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if (UnitIsRaidOfficer("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

--Change border when mouse is inside the button
local function ButtonEnter(self)
	local color = RAID_CLASS_COLORS[TukuiDB.myclass]
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end

--Change border back to normal when mouse leaves button
local function ButtonLeave(self)
	self:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end

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
		local t = b:CreateFontString(nil,"OVERLAY",b)
		t:SetFont(TukuiCF.media.font,TukuiCF["general"].fontscale,"OUTLINE")
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

--Create button to toggle the frame
CreateButton("ShowButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth() / 2.5, TukuiDB.Scale(18), "TOP", UIParent, "TOP", -300, 2, tukuilocal.core_raidutil, nil)
ShowButton:SetAttribute("_onclick", [=[
 if select(5, self:GetPoint()) > 0 then
	 self:GetParent():ClearAllPoints()
	 self:GetParent():SetPoint("TOP", UIParent, "TOP", -300, 1)
	 self:ClearAllPoints()
	 self:SetPoint("TOP", UIParent, "TOP", -300, -100)
 else
	 self:GetParent():ClearAllPoints()
	 self:GetParent():SetPoint("TOP", UIParent, "TOP", -300, 500)
	 self:ClearAllPoints()
	 self:SetPoint("TOP", UIParent, "TOP", -300, 1) 
 end
]=])

--Disband Raid button
CreateButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", RaidUtilityPanel, "TOP", 0, TukuiDB.Scale(-5), tukuilocal.core_raidutil_disbandgroup, nil)
DisbandRaidButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		StaticPopup_Show("DISBAND_RAID")
	end
end)

--Role Check button
CreateButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", DisbandRaidButton, "BOTTOM", 0, TukuiDB.Scale(-5), ROLE_POLL, nil)
RoleCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		InitiateRolePoll()
	end
end)

--MainTank Button
CreateButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - TukuiDB.Scale(2), TukuiDB.Scale(18), "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, TukuiDB.Scale(-5), MAINTANK, nil)
MainTankButton:SetAttribute("type", "maintank")
MainTankButton:SetAttribute("unit", "target")
MainTankButton:SetAttribute("action", "set")

--MainAssist Button
CreateButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - TukuiDB.Scale(2), TukuiDB.Scale(18), "TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5), MAINASSIST, nil)
MainAssistButton:SetAttribute("type", "mainassist")
MainAssistButton:SetAttribute("unit", "target")
MainAssistButton:SetAttribute("action", "set")

--Ready Check button
CreateButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.75, TukuiDB.Scale(18), "TOPLEFT", MainTankButton, "BOTTOMLEFT", 0, TukuiDB.Scale(-5), READY_CHECK, nil)
ReadyCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		DoReadyCheck()
	end
end)

--Reposition/Resize and Reuse the World Marker Button
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", MainAssistButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5))
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHeight(TukuiDB.Scale(18))
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetWidth(RoleCheckButton:GetWidth() * 0.22)

--Put other stuff back
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)

CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 0, 1)

--Reskin Stuff
do
	local buttons = {
		"CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton",
		"DisbandRaidButton",
		"MainTankButton",
		"MainAssistButton",
		"RoleCheckButton",
		"ReadyCheckButton",
		"ShowButton"
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
end


local function ToggleRaidUtil(self, event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
		
	if CheckRaidStatus() then
		RaidUtilityPanel:Show()
	else
		RaidUtilityPanel:Hide()
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
