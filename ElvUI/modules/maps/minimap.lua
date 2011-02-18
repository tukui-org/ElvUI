
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", E.Scale(-5), E.Scale(-5))
Minimap:SetSize(E.Scale(144), E.Scale(144))


function E.PostMinimapMove(frame)
	local point, _, _, _, _ = frame:GetPoint()
	if E.Movers[frame:GetName()]["moved"] ~= true then
		frame:ClearAllPoints()
		frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", E.Scale(-6), E.Scale(-6))
	end
	
	if point:match("TOP") then
		ElvuiMinimapStatsLeft:ClearAllPoints()
		ElvuiMinimapStatsLeft:Point("TOPLEFT", ElvuiMinimap, "BOTTOMLEFT", 0, -3)
		ElvuiMinimapStatsRight:ClearAllPoints()
		ElvuiMinimapStatsRight:Point("TOPRIGHT", ElvuiMinimap, "BOTTOMRIGHT", 0, -3)
		if RaidBuffReminder then
			RaidBuffReminder:ClearAllPoints()
			RaidBuffReminder:Point("TOPLEFT", ElvuiMinimapStatsLeft, "BOTTOMLEFT", 0, -3)
		end	
	else
		ElvuiMinimapStatsLeft:ClearAllPoints()
		ElvuiMinimapStatsLeft:Point("BOTTOMLEFT", ElvuiMinimap, "TOPLEFT", 0, 3)
		ElvuiMinimapStatsRight:ClearAllPoints()
		ElvuiMinimapStatsRight:Point("BOTTOMRIGHT", ElvuiMinimap, "TOPRIGHT", 0, 3)	
		if RaidBuffReminder then
			RaidBuffReminder:ClearAllPoints()
			RaidBuffReminder:Point("BOTTOMLEFT", ElvuiMinimapStatsLeft, "TOPLEFT", 0, 3)
		end		
	end
end

E.CreateMover(Minimap, "MinimapMover", "Minimap", nil, E.PostMinimapMove) --Too easy muahaha

--just incase these dont fit on the screen when you move the minimap
LFDSearchStatus:SetClampedToScreen(true)
LFDDungeonReadyStatus:SetClampedToScreen(true)

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
MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, E.Scale(3), E.Scale(4))
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\mail")

-- Move battleground icon
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, E.Scale(3), 0)
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
	MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", E.Scale(2), E.Scale(1))
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
		TimeManagerClockButton:Kill()
		--InterfaceOptionsDisplayPanelShowClock:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end)

if FeedbackUIButton then
	FeedbackUIButton:Kill()
end


----------------------------------------------------------------------------------------
-- Right click menu
----------------------------------------------------------------------------------------
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = CHARACTER_BUTTON,
    func = function() ToggleCharacter("PaperDollFrame") end},
    {text = SPELLBOOK_ABILITIES_BUTTON,
    func = function() if InCombatLockdown() then return end ToggleFrame(SpellBookFrame) end},
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
    func = function() if IsInGuild() then if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end GuildFrame_Toggle() end end},
    {text = LFG_TITLE,
    func = function() ToggleFrame(LFDParentFrame) end},
    {text = L_LFRAID,
    func = function() ToggleFrame(LFRParentFrame) end},
    {text = HELP_BUTTON,
    func = function() ToggleHelpFrame() end},
    {text = L_CALENDAR,
    func = function()
    if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end
        Calendar_Toggle()
    end},
}

Minimap:SetScript("OnMouseUp", function(self, btn)
	local position = TukuiMinimap:GetPoint()
	if btn == "RightButton" then
		local xoff = 0
		
		if position:match("RIGHT") then xoff = E.Scale(-16) end
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, TukuiMinimap, xoff, E.Scale(-2))
	elseif btn == "MiddleButton" and C["actionbar"].enable == true and C["actionbar"].microbar ~= true then
		if position:match("LEFT") then
			EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		else
			EasyMenu(menuList, menuFrame, "cursor", -160, 0, "MENU", 2)
		end
	else
		Minimap_OnClick(self)
	end
end)

-- Set Square Map Mask
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')

-- For others mods with a minimap button, set minimap buttons position in square mode.
function GetMinimapShape() return 'SQUARE' end

-- reskin LFG dropdown
LFDSearchStatus:SetTemplate("Default")

 
--Style Zone and Coord panels
local m_zone = CreateFrame("Frame",nil,UIParent)
m_zone:CreatePanel("Default", 0, 20, "TOPLEFT", Minimap, "TOPLEFT", E.Scale(2),E.Scale(-2))
m_zone:SetFrameLevel(5)
m_zone:SetFrameStrata("LOW")
m_zone:SetPoint("TOPRIGHT",Minimap,E.Scale(-2),E.Scale(-2))
m_zone:SetBackdropColor(0,0,0,0)
m_zone:SetBackdropBorderColor(0,0,0,0)
m_zone:Hide()

local m_zone_text = m_zone:CreateFontString(nil,"Overlay")
m_zone_text:SetFont(C["media"].font,C["general"].fontscale,"OUTLINE")
m_zone_text:SetPoint("Center",0,0)
m_zone_text:SetJustifyH("CENTER")
m_zone_text:SetJustifyV("MIDDLE")
m_zone_text:SetHeight(E.Scale(12))

local m_coord = CreateFrame("Frame",nil,UIParent)
m_coord:CreatePanel("Default", 40, 20, "BOTTOMLEFT", Minimap, "BOTTOMLEFT", E.Scale(2),E.Scale(2))
m_coord:SetFrameStrata("LOW")
m_coord:SetBackdropColor(0,0,0,0)
m_coord:SetBackdropBorderColor(0,0,0,0)
m_coord:Hide()	

local m_coord_text = m_coord:CreateFontString(nil,"Overlay")
m_coord_text:SetFont(C["media"].font,C["general"].fontscale,"OUTLINE")
m_coord_text:SetPoint("Center",E.Scale(-1),0)
m_coord_text:SetJustifyH("CENTER")
m_coord_text:SetJustifyV("MIDDLE")
 
-- Set Scripts and etc.
Minimap:SetScript("OnEnter",function()	
	m_coord:Show()
	m_zone:Show()
end)
 
Minimap:SetScript("OnLeave",function()
	m_coord:Hide()
	m_zone:Hide()
end)

if C["actionbar"].enable == true and C["actionbar"].microbar ~= true then
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
		m_coord_text:SetText(xt..E.ValColor..",|r"..yt)
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