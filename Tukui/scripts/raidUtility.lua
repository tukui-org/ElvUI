--Raid Utility by Elv22
if TukuiCF["raidframes"].disableblizz ~= true then return end

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
	elseif texture then
		local t = b:CreateTexture(nil,"OVERLAY",nil)
		t:SetTexture(texture)
		t:SetPoint("TOPLEFT", b, "TOPLEFT", TukuiDB.mult, -TukuiDB.mult)
		t:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -TukuiDB.mult, TukuiDB.mult)	
	end
end

--Create button to toggle the frame
CreateButton("ShowButton", RaidUtilityPanel, "SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth() / 2.5, TukuiDB.Scale(18), "TOP", UIParent, "TOP", -300, 2, tukuilocal.core_raidutil, nil)
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
CreateButton("DisbandRaidButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", RaidUtilityPanel, "TOP", 0, TukuiDB.Scale(-5), tukuilocal.core_raidutil_disbandgroup, nil)
DisbandRaidButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		StaticPopup_Show("DISBAND_RAID")
	end
end)

--Role Check button
CreateButton("RoleCheckButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", DisbandRaidButton, "BOTTOM", 0, TukuiDB.Scale(-5), ROLE_POLL, nil)
RoleCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		InitiateRolePoll()
	end
end)

--MainTank Button
CreateButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - TukuiDB.Scale(2), TukuiDB.Scale(18), "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, TukuiDB.Scale(-5), MAINTANK, nil)
MainTankButton:SetAttribute("type", "maintank")
MainTankButton:SetAttribute("unit", "target")
MainTankButton:SetAttribute("action", "set")

--MainAssist Button
CreateButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate", (DisbandRaidButton:GetWidth() / 2) - TukuiDB.Scale(2), TukuiDB.Scale(18), "TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5), MAINASSIST, nil)
MainAssistButton:SetAttribute("type", "mainassist")
MainAssistButton:SetAttribute("unit", "target")
MainAssistButton:SetAttribute("action", "set")

--Ready Check button
CreateButton("ReadyCheckButton", RaidUtilityPanel, nil, RoleCheckButton:GetWidth() * 0.75, TukuiDB.Scale(18), "TOPLEFT", MainTankButton, "BOTTOMLEFT", 0, TukuiDB.Scale(-5), READY_CHECK, nil)
ReadyCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		DoReadyCheck()
	end
end)

--World Marker button
CreateButton("WorldMarkerButton", RaidUtilityPanel, "SecureHandlerClickTemplate", RoleCheckButton:GetWidth() * 0.2, TukuiDB.Scale(18), "TOPRIGHT", MainAssistButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5), nil, "Interface\\RaidFrame\\Raid-WorldPing")
WorldMarkerButton:SetAttribute("_onclick", [=[
 if self:GetChildren():IsShown() then
	self:GetChildren():Hide()
 else
	self:GetChildren():Show()
 end
]=])

-- Marker Buttons
local function CreateMarkerButton(name, text, point, relativeto, point2)
	local f = CreateFrame("Button", name, MarkerFrame, "SecureActionButtonTemplate")
	f:SetPoint(point, relativeto, point2, 0, TukuiDB.Scale(-5))
	f:SetWidth(MarkerFrame:GetWidth())
	f:SetHeight((MarkerFrame:GetHeight() / 6) + TukuiDB.Scale(-5))
	f:SetFrameLevel(MarkerFrame:GetFrameLevel() + 1)
	f:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	
	local t = f:CreateFontString(nil,"OVERLAY",f)
	t:SetFont(TukuiCF.media.font,TukuiCF["general"].fontscale,"OUTLINE")
	t:SetText(text)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")	
	
	f:SetAttribute("type", "macro")
end

--Marker Holder Frame
local MarkerFrame = CreateFrame("Frame", "MarkerFrame", WorldMarkerButton)
TukuiDB.SetTemplate(MarkerFrame)
MarkerFrame:SetBackdropColor(r,g,b,0.6)
TukuiDB.CreateShadow(MarkerFrame)
MarkerFrame:SetWidth(RaidUtilityPanel:GetWidth() * 0.4)
MarkerFrame:SetHeight(RaidUtilityPanel:GetHeight()* 1.2)
MarkerFrame:SetPoint("TOPLEFT", WorldMarkerButton, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
MarkerFrame:Hide()

--Setup Secure Buttons
CreateMarkerButton("BlueFlare", "|cff519AE8"..tukuilocal.core_raidutil_blue.."|r", "TOPLEFT", MarkerFrame, "TOPLEFT")
BlueFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button1
]])
CreateMarkerButton("GreenFlare", "|cff24B358"..tukuilocal.core_raidutil_green.."|r", "TOPLEFT", BlueFlare, "BOTTOMLEFT")
GreenFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button2
]])
CreateMarkerButton("PurpleFlare", "|cff852096"..tukuilocal.core_raidutil_purple.."|r", "TOPLEFT", GreenFlare, "BOTTOMLEFT")
PurpleFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button3
]])
CreateMarkerButton("RedFlare", "|cffD60629"..tukuilocal.core_raidutil_red.."|r", "TOPLEFT", PurpleFlare, "BOTTOMLEFT")
RedFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button4
]])
CreateMarkerButton("WhiteFlare", tukuilocal.core_raidutil_white, "TOPLEFT", RedFlare, "BOTTOMLEFT")
WhiteFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button5
]])
CreateMarkerButton("ClearFlare", tukuilocal.core_raidutil_clear, "TOPLEFT", WhiteFlare, "BOTTOMLEFT")
ClearFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button6
]])
MarkerFrame:SetHeight(MarkerFrame:GetHeight() + TukuiDB.Scale(4))

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
