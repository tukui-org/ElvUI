local ElvCF = ElvCF
local ElvDB = ElvDB

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", ElvDB.Scale(-5), ElvDB.Scale(-5))
Minimap:SetSize(ElvDB.Scale(144), ElvDB.Scale(144))


ElvDB.CreateMover(Minimap, "MinimapMover", "Minimap") --Too easy muahaha

-- Hide Border
MinimapBorder:Hide()
MinimapBorderTop:Hide()

-- Hide Zoom Buttons
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

-- Hide Voice Chat Frame
MiniMapVoiceChatFrame:Hide()

-- Hide North texture at top
MinimapNorthTag:SetTexture(nil)

-- Hide Game Time
GameTimeFrame:Hide()

-- Hide Zone Frame
MinimapZoneTextButton:Hide()

-- Hide Tracking Button
MiniMapTracking:Hide()

-- Hide Mail Button
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, ElvDB.Scale(3), ElvDB.Scale(4))
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\mail")

-- Move battleground icon
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, ElvDB.Scale(3), 0)
MiniMapBattlefieldBorder:Hide()

-- Hide world map button
MiniMapWorldMapButton:Hide()

-- shitty 3.3 flag to move
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetParent(Minimap)
GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

local function UpdateLFG()
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(1))
	MiniMapLFGFrameBorder:Hide()
end
hooksecurefunc("MiniMapLFG_UpdateIsShown", UpdateLFG)

-- Enable mouse scrolling
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

ElvuiMinimap:RegisterEvent("ADDON_LOADED")
ElvuiMinimap:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TimeManager" then
		-- Hide Game Time
		ElvDB.Kill(TimeManagerClockButton)
		--ElvDB.Kill(InterfaceOptionsDisplayPanelShowClock)
	elseif addon == "Blizzard_FeedbackUI" then
		ElvDB.Kill(FeedbackUIButton)
	end
end)

if FeedbackUIButton then
	ElvDB.Kill(FeedbackUIButton)
end


----------------------------------------------------------------------------------------
-- Right click menu
----------------------------------------------------------------------------------------
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = CHARACTER_BUTTON,
		func = function() ToggleCharacter("PaperDollFrame") end},
    {text = TALENTS_BUTTON,
		func = function() if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end if not GlyphFrame then LoadAddOn("Blizzard_GlyphUI") end PlayerTalentFrame_Toggle() end},
    {text = ACHIEVEMENT_BUTTON,
		func = function() ToggleAchievementFrame() end},
    {text = QUESTLOG_BUTTON,
		func = function() ToggleFrame(QuestLogFrame) end},
    {text = SOCIAL_BUTTON,
		func = function() ToggleFriendsFrame(1) end},
    {text = PLAYER_V_PLAYER,
		func = function() ToggleFrame(PVPFrame) end},
    {text = ACHIEVEMENTS_GUILD_TAB,
		func = function() if IsInGuild() then if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end GuildFrame_Toggle() GuildFrame_TabClicked(GuildFrameTab2) end end},
    {text = LFG_TITLE,
		func = function() ToggleFrame(LFDParentFrame) end},
    {text = L_LFRAID,
		func = function() ToggleFrame(LFRParentFrame) end},
    {text = HELP_BUTTON,
		func = function() ToggleHelpFrame() end},
    {text = L_CALENDAR,
		func = function() if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle() end},
}

if ElvCF["actionbar"].enable == true and ElvCF["actionbar"].microbar ~= true then
	SpellbookMicroButton:SetParent(Minimap)
	SpellbookMicroButton:ClearAllPoints()
	SpellbookMicroButton:SetPoint("RIGHT")
	SpellbookMicroButton:SetFrameStrata("TOOLTIP")
	SpellbookMicroButton:SetFrameLevel(100)
	SpellbookMicroButton:SetAlpha(0)
	SpellbookMicroButton:HookScript("OnEnter", function(self)  end)
	SpellbookMicroButton:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	SpellbookMicroButton.Hide = ElvDB.dummy
	SpellbookMicroButton.SetParent = ElvDB.dummy
	SpellbookMicroButton.ClearAllPoints = ElvDB.dummy
	SpellbookMicroButton.SetPoint = ElvDB.dummy
	SpellbookMicroButton:SetHighlightTexture("")
	SpellbookMicroButton.SetHighlightTexture = ElvDB.dummy
	
	local pushed = SpellbookMicroButton:GetPushedTexture()
	local normal = SpellbookMicroButton:GetNormalTexture()
	local disabled = SpellbookMicroButton:GetDisabledTexture()
	
	local f = CreateFrame("Frame", nil, SpellbookMicroButton)
	f:SetFrameLevel(1)
	f:SetFrameStrata("LOW")
	f:SetPoint("BOTTOMLEFT", SpellbookMicroButton, "BOTTOMLEFT", 2, 0)
	f:SetPoint("TOPRIGHT", SpellbookMicroButton, "TOPRIGHT", -2, -28)
	ElvDB.SetNormTexTemplate(f)	
	SpellbookMicroButton.frame = f
	
	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", SpellbookMicroButton.frame, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(-2))
	pushed:SetPoint("BOTTOMRIGHT", SpellbookMicroButton.frame, "BOTTOMRIGHT", ElvDB.Scale(-2), ElvDB.Scale(2))
	
	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT", SpellbookMicroButton.frame, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(-2))
	normal:SetPoint("BOTTOMRIGHT", SpellbookMicroButton.frame, "BOTTOMRIGHT", ElvDB.Scale(-2), ElvDB.Scale(2))
	
	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:ClearAllPoints()
		disabled:SetPoint("TOPLEFT", SpellbookMicroButton.frame, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(-2))
		disabled:SetPoint("BOTTOMRIGHT", SpellbookMicroButton.frame, "BOTTOMRIGHT", ElvDB.Scale(-2), ElvDB.Scale(2))
	end
	
	SpellbookMicroButton:HookScript("OnEnter", function(self) local color = RAID_CLASS_COLORS[ElvDB.myclass] self.frame:SetBackdropBorderColor(color.r, color.g, color.b) self:SetAlpha(1) end)
	SpellbookMicroButton:HookScript("OnLeave", function(self) self.frame:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor)) self:SetAlpha(0) end)
end

Minimap:SetScript("OnMouseUp", function(self, btn)
	if btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
	elseif btn == "MiddleButton" and ElvCF["actionbar"].enable == true and ElvCF["actionbar"].microbar ~= true then
		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		Minimap_OnClick(self)
	end
end)


-- Set Square Map Mask
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')

-- For others mods with a minimap button, set minimap buttons position in square mode.
function GetMinimapShape() return 'SQUARE' end

-- reskin LFG dropdown
ElvDB.SetTemplate(LFDSearchStatus)

 
--Style Zone and Coord panels
local m_zone = CreateFrame("Frame",nil,UIParent)
ElvDB.CreatePanel(m_zone, 0, 20, "TOPLEFT", Minimap, "TOPLEFT", ElvDB.Scale(2),ElvDB.Scale(-2))
m_zone:SetFrameLevel(5)
m_zone:SetFrameStrata("LOW")
m_zone:SetPoint("TOPRIGHT",Minimap,ElvDB.Scale(-2),ElvDB.Scale(-2))
m_zone:SetBackdropColor(0,0,0,0)
m_zone:SetBackdropBorderColor(0,0,0,0)
m_zone:Hide()

local m_zone_text = m_zone:CreateFontString(nil,"Overlay")
m_zone_text:SetFont(ElvCF["media"].font,ElvCF["general"].fontscale,"OUTLINE")
m_zone_text:SetPoint("Center",0,0)
m_zone_text:SetJustifyH("CENTER")
m_zone_text:SetJustifyV("MIDDLE")
m_zone_text:SetHeight(ElvDB.Scale(12))

local m_coord = CreateFrame("Frame",nil,UIParent)
ElvDB.CreatePanel(m_coord, 40, 20, "BOTTOMLEFT", Minimap, "BOTTOMLEFT", ElvDB.Scale(2),ElvDB.Scale(2))
m_coord:SetFrameStrata("LOW")
m_coord:SetBackdropColor(0,0,0,0)
m_coord:SetBackdropBorderColor(0,0,0,0)
m_coord:Hide()	

local m_coord_text = m_coord:CreateFontString(nil,"Overlay")
m_coord_text:SetFont(ElvCF["media"].font,ElvCF["general"].fontscale,"OUTLINE")
m_coord_text:SetPoint("Center",ElvDB.Scale(-1),0)
m_coord_text:SetJustifyH("CENTER")
m_coord_text:SetJustifyV("MIDDLE")
 
-- Set Scripts and etc.
Minimap:SetScript("OnEnter",function()	
	m_coord:Show()
	m_zone:Show()
	if ElvCF["actionbar"].enable == true and ElvCF["actionbar"].microbar ~= true then
		SpellbookMicroButton:SetAlpha(1)
	end
end)
 
Minimap:SetScript("OnLeave",function()
	m_coord:Hide()
	m_zone:Hide()
	if ElvCF["actionbar"].enable == true and ElvCF["actionbar"].microbar ~= true then
		SpellbookMicroButton:SetAlpha(0)
	end
end)

if ElvCF["actionbar"].enable == true and ElvCF["actionbar"].microbar ~= true then
	SpellbookMicroButton:HookScript("OnEnter", function() 	
		m_coord:Show()
		m_zone:Show() 
	end)

	SpellbookMicroButton:HookScript("OnLeave", function() 	
		m_coord:Hide()
		m_zone:Hide()
	end)
end

m_coord_text:SetText("00,00")
 
local ela = 0
local coord_Update = function(self,t)
	local inInstance, _ = IsInInstance()
	ela = ela - t
	if ela > 0 then return end
	local x,y = GetPlayerMapPosition("player")
	local xt,yt
	x = math.floor(100 * x)
	y = math.floor(100 * y)
	if x == 0 and y == 0 and not inInstance then
		SetMapToCurrentZone()
	elseif x ==0 and y==0 then
		m_coord_text:SetText(" ")	
	else
		if x < 10 then
			xt = "0"..x
		else
			xt = x
		end
		if y < 10 then
			yt = "0"..y
		else
			yt = y
		end
		m_coord_text:SetText(xt..ElvDB.ValColor..",|r"..yt)
	end
	ela = .2
end
 
m_coord:SetScript("OnUpdate",coord_Update)
 
local zone_Update = function()
	local pvpType = GetZonePVPInfo()
	m_zone_text:SetText(strsub(GetMinimapZoneText(),1,23))
	if pvpType == "arena" then
		m_zone_text:SetTextColor(0.84, 0.03, 0.03)
	elseif pvpType == "friendly" then
		m_zone_text:SetTextColor(0.05, 0.85, 0.03)
	elseif pvpType == "contested" then
		m_zone_text:SetTextColor(0.9, 0.85, 0.05)
	elseif pvpType == "hostile" then 
		m_zone_text:SetTextColor(0.84, 0.03, 0.03)
	elseif pvpType == "sanctuary" then
		m_zone_text:SetTextColor(0.0352941, 0.58823529, 0.84705882)
	elseif pvpType == "combat" then
		m_zone_text:SetTextColor(0.84, 0.03, 0.03)
	else
		m_zone_text:SetTextColor(0.84, 0.03, 0.03)
	end
end
 
m_zone:RegisterEvent("PLAYER_ENTERING_WORLD")
m_zone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
m_zone:RegisterEvent("ZONE_CHANGED")
m_zone:RegisterEvent("ZONE_CHANGED_INDOORS")
m_zone:SetScript("OnEvent",zone_Update) 
 
local a,k = CreateFrame("Frame"),4
a:SetScript("OnUpdate",function(self,t)
	k = k - t
	if k > 0 then return end
	self:Hide()
	zone_Update()
end)