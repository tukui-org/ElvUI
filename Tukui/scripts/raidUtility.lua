--Raid Utility by Elv22
if TukuiCF["raidframes"].enable ~= true then return end

--Create main frame
local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
TukuiDB.CreatePanel(RaidUtilityPanel, TukuiDB.Scale(170), (TukuiDB.Scale(5)*4) + (TukuiDB.Scale(20)*4), "TOP", UIParent, "TOP", TukuiDB.Scale(-300), TukuiDB.Scale(-1))
local r,g,b,_ = TukuiCF["media"].backdropcolor
RaidUtilityPanel:SetBackdropColor(r,g,b,0.6)
TukuiDB.CreateShadow(RaidUtilityPanel)
RaidUtilityPanel:SetAlpha(0)

local function UtilToggler()
	if HiddenToggleButton:GetAlpha() == 0 then
		--hide
		RaidUtilityPanel:SetAlpha(0)
		HiddenToggleButton:SetAlpha(1)
		HiddenToggleButton:EnableMouse(true)
		WorldMarkerButton:EnableMouse(false)
		ShownToggleButton:EnableMouse(false)
		DisbandRaidButton:EnableMouse(false)
		RoleCheckButton:EnableMouse(false)
		ReadyCheckButton:EnableMouse(false)
		MainTankButton:EnableMouse(false)
		MainAssistButton:EnableMouse(false)
		BlueFlare:EnableMouse(false)
		GreenFlare:EnableMouse(false)
		PurpleFlare:EnableMouse(false)
		RedFlare:EnableMouse(false)
		WhiteFlare:EnableMouse(false)
		ClearFlare:EnableMouse(false)
	else
		--show
		RaidUtilityPanel:SetAlpha(1)
		HiddenToggleButton:SetAlpha(0)
		HiddenToggleButton:EnableMouse(false)
		WorldMarkerButton:EnableMouse(true)
		ShownToggleButton:EnableMouse(true)
		DisbandRaidButton:EnableMouse(true)
		RoleCheckButton:EnableMouse(true)
		MainTankButton:EnableMouse(true)
		ReadyCheckButton:EnableMouse(true)
		MainAssistButton:EnableMouse(true)
		BlueFlare:EnableMouse(true)
		GreenFlare:EnableMouse(true)
		PurpleFlare:EnableMouse(true)
		RedFlare:EnableMouse(true)
		WhiteFlare:EnableMouse(true)
		ClearFlare:EnableMouse(true)
	end
end


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
	TukuiDB.SetTemplate(b)
	b:EnableMouse(false)
	if text then
		local t = b:CreateFontString(nil,"OVERLAY",b)
		t:SetFont(TukuiCF.media.font,12,"OUTLINE")
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

--Create button for when frame is hidden
CreateButton("HiddenToggleButton", UIParent, nil, RaidUtilityPanel:GetWidth() / 1.5, TukuiDB.Scale(18), "TOP", UIParent, "TOP", TukuiDB.Scale(-300), TukuiDB.Scale(-1), "Raid Utility", nil)
HiddenToggleButton:EnableMouse(true)
HiddenToggleButton:SetAlpha(1)
HiddenToggleButton:SetScript("OnMouseUp", function(self)
	UtilToggler()
end)

--Create button for when frame is shown
CreateButton("ShownToggleButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() / 2.5, TukuiDB.Scale(18), "TOP", RaidUtilityPanel, "BOTTOM", 0, TukuiDB.Scale(-1), CLOSE, nil)
ShownToggleButton:SetScript("OnMouseUp", function(self)
	UtilToggler()
end)

--Disband Raid button
CreateButton("DisbandRaidButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", RaidUtilityPanel, "TOP", 0, TukuiDB.Scale(-5), "Disband Group", nil)
DisbandRaidButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		StaticPopup_Show("DISBAND_RAID")
		UtilToggler()
	end
end)

--Role Check button
CreateButton("RoleCheckButton", RaidUtilityPanel, nil, RaidUtilityPanel:GetWidth() * 0.8, TukuiDB.Scale(18), "TOP", DisbandRaidButton, "BOTTOM", 0, TukuiDB.Scale(-5), ROLE_POLL, nil)
RoleCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		InitiateRolePoll()
		UtilToggler()
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
		UtilToggler()
	end
end)

--World Marker button
CreateButton("WorldMarkerButton", RaidUtilityPanel, nil, RoleCheckButton:GetWidth() * 0.2, TukuiDB.Scale(18), "TOPRIGHT", MainAssistButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5), nil, "Interface\\RaidFrame\\Raid-WorldPing")
WorldMarkerButton:SetScript("OnMouseDown", function() ToggleFrame(MarkerFrame) end)

-- Marker Buttons
local function CreateMarkerButton(name, text, point, relativeto, point2)
	local f = CreateFrame("Button", name, MarkerFrame, "SecureActionButtonTemplate")
	f:SetPoint(point, relativeto, point2, 0, TukuiDB.Scale(-5))
	f:SetWidth(MarkerFrame:GetWidth())
	f:SetHeight((MarkerFrame:GetHeight() / 6) + TukuiDB.Scale(-5))
	f:SetFrameLevel(MarkerFrame:GetFrameLevel() + 1)
	f:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	f:EnableMouse(false)
	
	local t = f:CreateFontString(nil,"OVERLAY",f)
	t:SetFont(TukuiCF.media.font,12,"OUTLINE")
	t:SetText(text)
	t:SetPoint("CENTER")
	t:SetJustifyH("CENTER")	
	
	f:SetAttribute("type", "macro")
end

--Marker Holder Frame
local MarkerFrame = CreateFrame("Frame", "MarkerFrame", RaidUtilityPanel)
TukuiDB.SetTemplate(MarkerFrame)
MarkerFrame:SetBackdropColor(r,g,b,0.6)
TukuiDB.CreateShadow(MarkerFrame)
MarkerFrame:SetWidth(RaidUtilityPanel:GetWidth() * 0.4)
MarkerFrame:SetHeight(RaidUtilityPanel:GetHeight()* 1.2)
MarkerFrame:SetPoint("TOPLEFT", WorldMarkerButton, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
MarkerFrame:Hide()

--Setup Secure Buttons
CreateMarkerButton("BlueFlare", "|cff519AE8Blue|r", "TOPLEFT", MarkerFrame, "TOPLEFT")
BlueFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button1
]])
CreateMarkerButton("GreenFlare", "|cff24B358Green|r", "TOPLEFT", BlueFlare, "BOTTOMLEFT")
GreenFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button2
]])
CreateMarkerButton("PurpleFlare", "|cff852096Purple|r", "TOPLEFT", GreenFlare, "BOTTOMLEFT")
PurpleFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button3
]])
CreateMarkerButton("RedFlare", "|cffD60629Red|r", "TOPLEFT", PurpleFlare, "BOTTOMLEFT")
RedFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button4
]])
CreateMarkerButton("WhiteFlare", "White", "TOPLEFT", RedFlare, "BOTTOMLEFT")
WhiteFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button5
]])
CreateMarkerButton("ClearFlare", "Clear", "TOPLEFT", WhiteFlare, "BOTTOMLEFT")
ClearFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button6
]])
MarkerFrame:SetHeight(MarkerFrame:GetHeight() + TukuiDB.Scale(4))

--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("RAID_ROSTER_UPDATE")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
LeadershipCheck:SetScript("OnEvent", function(self, event)
	if CheckRaidStatus() then
		RaidUtilityPanel:SetAlpha(0)
		HiddenToggleButton:SetAlpha(1)
		HiddenToggleButton:EnableMouse(true)
		WorldMarkerButton:EnableMouse(false)
		ShownToggleButton:EnableMouse(false)
		DisbandRaidButton:EnableMouse(false)
		RoleCheckButton:EnableMouse(false)
		ReadyCheckButton:EnableMouse(false)
		MainTankButton:EnableMouse(false)
		MainAssistButton:EnableMouse(false)
		BlueFlare:EnableMouse(false)
		GreenFlare:EnableMouse(false)
		PurpleFlare:EnableMouse(false)
		RedFlare:EnableMouse(false)
		WhiteFlare:EnableMouse(false)
		ClearFlare:EnableMouse(false)
	else
		--Hide Everything..
		RaidUtilityPanel:SetAlpha(0)
		HiddenToggleButton:SetAlpha(0)
		HiddenToggleButton:EnableMouse(false)
		WorldMarkerButton:EnableMouse(false)
		ShownToggleButton:EnableMouse(false)
		DisbandRaidButton:EnableMouse(false)
		RoleCheckButton:EnableMouse(false)
		MainTankButton:EnableMouse(false)
		MainAssistButton:EnableMouse(false)
		ReadyCheckButton:EnableMouse(false)
		BlueFlare:EnableMouse(false)
		GreenFlare:EnableMouse(false)
		PurpleFlare:EnableMouse(false)
		RedFlare:EnableMouse(false)
		WhiteFlare:EnableMouse(false)
		ClearFlare:EnableMouse(false)
	end
end)