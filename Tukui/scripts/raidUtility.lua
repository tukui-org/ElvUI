--Raid Utility by Elv22
if TukuiCF["raidframes"].enable ~= true then return end

--Create main frame
local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
TukuiDB.CreatePanel(RaidUtilityPanel, TukuiDB.Scale(170), (TukuiDB.Scale(5)*4) + (TukuiDB.Scale(18)*3), "TOP", UIParent, "TOP", TukuiDB.Scale(-300), TukuiDB.Scale(-1))
local r,g,b,_ = TukuiCF["media"].backdropcolor
RaidUtilityPanel:SetBackdropColor(r,g,b,0.6)
TukuiDB.CreateShadow(RaidUtilityPanel)
RaidUtilityPanel:Hide()

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

--Create button for when frame is hidden
local HiddenToggleButton = CreateFrame("Button", nil, UIParent)
HiddenToggleButton:SetHeight(TukuiDB.Scale(18))
HiddenToggleButton:SetWidth(RaidUtilityPanel:GetWidth() / 1.5)
TukuiDB.SetTemplate(HiddenToggleButton)
HiddenToggleButton:SetPoint("TOP", UIParent, "TOP", TukuiDB.Scale(-300), TukuiDB.Scale(-1))
HiddenToggleButton:SetScript("OnEnter", ButtonEnter)
HiddenToggleButton:SetScript("OnLeave", ButtonLeave)
HiddenToggleButton:SetScript("OnMouseUp", function(self)
	RaidUtilityPanel:Show()
	HiddenToggleButton:Hide()
end)

local HiddenToggleButtonText = HiddenToggleButton:CreateFontString(nil,"OVERLAY",HiddenToggleButton)
HiddenToggleButtonText:SetFont(TukuiCF.media.font,12,"OUTLINE")
HiddenToggleButtonText:SetText("Raid Utility")
HiddenToggleButtonText:SetPoint("CENTER")
HiddenToggleButtonText:SetJustifyH("CENTER")

--Create button for when frame is shown
local ShownToggleButton = CreateFrame("Button", nil, RaidUtilityPanel)
ShownToggleButton:SetHeight(TukuiDB.Scale(18))
ShownToggleButton:SetWidth(RaidUtilityPanel:GetWidth() / 2.5)
TukuiDB.SetTemplate(ShownToggleButton)
ShownToggleButton:SetPoint("TOP", RaidUtilityPanel, "BOTTOM", 0, TukuiDB.Scale(-1))
ShownToggleButton:SetScript("OnEnter", ButtonEnter)
ShownToggleButton:SetScript("OnLeave", ButtonLeave)
ShownToggleButton:SetScript("OnMouseUp", function(self)
	RaidUtilityPanel:Hide()
	HiddenToggleButton:Show()
end)

local ShownToggleButtonText = ShownToggleButton:CreateFontString(nil,"OVERLAY",ShownToggleButton)
ShownToggleButtonText:SetFont(TukuiCF.media.font,12,"OUTLINE")
ShownToggleButtonText:SetText("Close")
ShownToggleButtonText:SetPoint("CENTER")
ShownToggleButtonText:SetJustifyH("CENTER")

--Disband Raid button
local DisbandRaidButton = CreateFrame("Button", nil, RaidUtilityPanel)
DisbandRaidButton:SetHeight(TukuiDB.Scale(18))
DisbandRaidButton:SetWidth(RaidUtilityPanel:GetWidth() * 0.8)
TukuiDB.SetTemplate(DisbandRaidButton)
DisbandRaidButton:SetPoint("TOP", RaidUtilityPanel, "TOP", 0, TukuiDB.Scale(-5))
DisbandRaidButton:SetScript("OnEnter", ButtonEnter)
DisbandRaidButton:SetScript("OnLeave", ButtonLeave)
DisbandRaidButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		StaticPopup_Show("DISBAND_RAID")
		RaidUtilityPanel:Hide()
		HiddenToggleButton:Show()
	end
end)

local DisbandRaidButtonText = DisbandRaidButton:CreateFontString(nil,"OVERLAY",DisbandRaidButton)
DisbandRaidButtonText:SetFont(TukuiCF.media.font,12,"OUTLINE")
DisbandRaidButtonText:SetText("Disband Group")
DisbandRaidButtonText:SetPoint("CENTER")
DisbandRaidButtonText:SetJustifyH("CENTER")

--Role Check button
local RoleCheckButton = CreateFrame("Button", nil, RaidUtilityPanel)
RoleCheckButton:SetHeight(TukuiDB.Scale(18))
RoleCheckButton:SetWidth(RaidUtilityPanel:GetWidth() * 0.8)
TukuiDB.SetTemplate(RoleCheckButton)
RoleCheckButton:SetPoint("TOP", DisbandRaidButton, "BOTTOM", 0, TukuiDB.Scale(-5))
RoleCheckButton:SetScript("OnEnter", ButtonEnter)
RoleCheckButton:SetScript("OnLeave", ButtonLeave)
RoleCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		InitiateRolePoll()
		RaidUtilityPanel:Hide()
		HiddenToggleButton:Show()
	end
end)

local RoleCheckButtonText = RoleCheckButton:CreateFontString(nil,"OVERLAY",RoleCheckButton)
RoleCheckButtonText:SetFont(TukuiCF.media.font,12,"OUTLINE")
RoleCheckButtonText:SetText(ROLE_POLL)
RoleCheckButtonText:SetPoint("CENTER")
RoleCheckButtonText:SetJustifyH("CENTER")

--Ready Check button
local ReadyCheckButton = CreateFrame("Button", nil, RaidUtilityPanel)
ReadyCheckButton:SetHeight(TukuiDB.Scale(18))
ReadyCheckButton:SetWidth(RoleCheckButton:GetWidth() * 0.75)
TukuiDB.SetTemplate(ReadyCheckButton)
ReadyCheckButton:SetPoint("TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, TukuiDB.Scale(-5))
ReadyCheckButton:SetScript("OnEnter", ButtonEnter)
ReadyCheckButton:SetScript("OnLeave", ButtonLeave)
ReadyCheckButton:SetScript("OnMouseUp", function(self)
	if CheckRaidStatus() then
		DoReadyCheck()
		RaidUtilityPanel:Hide()
		HiddenToggleButton:Show()
	end
end)

local ReadyCheckButtonText = ReadyCheckButton:CreateFontString(nil,"OVERLAY",ReadyCheckButton)
ReadyCheckButtonText:SetFont(TukuiCF.media.font,12,"OUTLINE")
ReadyCheckButtonText:SetText(READY_CHECK)
ReadyCheckButtonText:SetPoint("CENTER")
ReadyCheckButtonText:SetJustifyH("CENTER")

--World Marker button
local WorldMarkerButton = CreateFrame("Button", nil, RaidUtilityPanel)
WorldMarkerButton:SetHeight(TukuiDB.Scale(18))
WorldMarkerButton:SetWidth(RoleCheckButton:GetWidth() * 0.2)
TukuiDB.SetTemplate(WorldMarkerButton)
WorldMarkerButton:SetPoint("TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-5))

--Start Hack
--This will fuck up the points of some of the buttons on blizzard's raid frame manager
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetAllPoints(WorldMarkerButton)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent(WorldMarkerButton)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetAlpha(0)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnEnter", function()
	local color = RAID_CLASS_COLORS[TukuiDB.myclass]
	WorldMarkerButton:SetBackdropBorderColor(color.r, color.g, color.b)
end)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:HookScript("OnLeave", function()
	WorldMarkerButton:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end)
--Remember boys & girls.. put back your toys when your done playing..
--Fix buttons that we screwed up, this isn't necessary but whatever..
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("RIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 0)
CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("RIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT")
--Hack Complete

local WorldMarkerButtonTexture = WorldMarkerButton:CreateTexture(nil,"OVERLAY",nil)
WorldMarkerButtonTexture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
WorldMarkerButtonTexture:SetPoint("TOPLEFT", WorldMarkerButton, "TOPLEFT", TukuiDB.mult, -TukuiDB.mult)
WorldMarkerButtonTexture:SetPoint("BOTTOMRIGHT", WorldMarkerButton, "BOTTOMRIGHT", -TukuiDB.mult, TukuiDB.mult)

--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("RAID_ROSTER_UPDATE")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
LeadershipCheck:SetScript("OnEvent", function(self, event)
	if CheckRaidStatus() then
		RaidUtilityPanel:Hide()
		HiddenToggleButton:Show()
	else
		--Hide Everything..
		HiddenToggleButton:Hide()	
		RaidUtilityPanel:Hide()	
	end
end)

