--------------------------------------------------------------------
-- MINIMAP BORDER
--------------------------------------------------------------------

local p = CreateFrame("Frame", "TukuiMinimap", Minimap)
TukuiDB.CreatePanel(p, 144, 144, "CENTER", Minimap, "CENTER", -0, 0)
p:ClearAllPoints()
p:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
p:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))

--------------------------------------------------------------------
-- MINIMAP ROUND TO SQUARE AND MINIMAP SETTING
--------------------------------------------------------------------

Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", TukuiDB.Scale(-24), TukuiDB.Scale(-24))
Minimap:SetSize(TukuiDB.Scale(144), TukuiDB.Scale(144))

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
MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, TukuiDB.Scale(3), TukuiDB.Scale(4))
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\mail")

-- Move battleground icon
MiniMapBattlefieldFrame:ClearAllPoints()
MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, TukuiDB.Scale(3), 0)
MiniMapBattlefieldBorder:Hide()

-- Hide world map button
MiniMapWorldMapButton:Hide()

-- shitty 3.3 flag to move
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

local function UpdateLFG()
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(1))
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

----------------------------------------------------------------------------------------
-- Right click menu
----------------------------------------------------------------------------------------

local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = CHARACTER_BUTTON,
    func = function() ToggleCharacter("PaperDollFrame") end},
    {text = SPELLBOOK_ABILITIES_BUTTON,
    func = function() ToggleFrame(SpellBookFrame) end},
    {text = TALENTS_BUTTON,
    func = function() ToggleTalentFrame() end},
    {text = ACHIEVEMENT_BUTTON,
    func = function() ToggleAchievementFrame() end},
    {text = QUESTLOG_BUTTON,
    func = function() ToggleFrame(QuestLogFrame) end},
    {text = SOCIAL_BUTTON,
    func = function() ToggleFriendsFrame(1) end},
    {text = PLAYER_V_PLAYER,
    func = function() ToggleFrame(PVPParentFrame) end},
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
	if btn == "RightButton" then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
	elseif btn == "MiddleButton" then
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
TukuiDB.SetTemplate(LFDSearchStatus)

----------------------------------------------------------------------------------------
-- Animation Coords and Current Zone. Awesome feature by AlleyKat.
----------------------------------------------------------------------------------------

-- Set Anim func
local set_anim = function (self,k,x,y)
	self.anim = self:CreateAnimationGroup("Move_In")
	self.anim.in_a = self.anim:CreateAnimation("Translation")
	self.anim.in_a:SetDuration(0)
	self.anim.in_a:SetOrder(1)
	self.anim.in_b = self.anim:CreateAnimation("Translation")
	self.anim.in_b:SetDuration(.3)
	self.anim.in_b:SetOrder(2)
	self.anim.in_b:SetSmoothing("OUT")
	self.anim_o = self:CreateAnimationGroup("Move_Out")
	self.anim_o.b = self.anim_o:CreateAnimation("Translation")
	self.anim_o.b:SetDuration(.3)
	self.anim_o.b:SetOrder(1)
	self.anim_o.b:SetSmoothing("IN")
	self.anim.in_a:SetOffset(x,y)
	self.anim.in_b:SetOffset(-x,-y)
	self.anim_o.b:SetOffset(x,y)
	if k then self.anim_o:SetScript("OnFinished",function() self:Hide() end) end
end
 
--Style Zone and Coord panels
local m_zone = CreateFrame("Frame",nil,UIParent)
TukuiDB.CreatePanel(m_zone, 0, 20, "TOPLEFT", Minimap, "TOPLEFT", TukuiDB.Scale(2),TukuiDB.Scale(-2))
m_zone:SetFrameLevel(5)
m_zone:SetFrameStrata("LOW")
m_zone:SetPoint("TOPRIGHT",Minimap,TukuiDB.Scale(-2),TukuiDB.Scale(-2))

set_anim(m_zone,true,0,TukuiDB.Scale(60))
m_zone:Hide()

local m_zone_text = m_zone:CreateFontString(nil,"Overlay")
m_zone_text:SetFont(TukuiCF["media"].font,12)
m_zone_text:SetPoint("Center",0,0)
m_zone_text:SetJustifyH("CENTER")
m_zone_text:SetJustifyV("MIDDLE")
m_zone_text:SetHeight(TukuiDB.Scale(12))
m_zone_text:SetWidth(m_zone:GetWidth()-6)

local m_coord = CreateFrame("Frame",nil,UIParent)
TukuiDB.CreatePanel(m_coord, 40, 20, "BOTTOMLEFT", Minimap, "BOTTOMLEFT", TukuiDB.Scale(2),TukuiDB.Scale(2))
m_coord:SetFrameStrata("LOW")

set_anim(m_coord,true,TukuiDB.Scale(320),0)
m_coord:Hide()	

local m_coord_text = m_coord:CreateFontString(nil,"Overlay")
m_coord_text:SetFont(TukuiCF["media"].font,12)
m_coord_text:SetPoint("Center",TukuiDB.Scale(-1),0)
m_coord_text:SetJustifyH("CENTER")
m_coord_text:SetJustifyV("MIDDLE")
 
-- Set Scripts and etc.
Minimap:SetScript("OnEnter",function()
	m_zone.anim_o:Stop()
	m_coord.anim_o:Stop()
	m_zone:Show()
	m_coord:Show()
	m_coord.anim:Play()
	m_zone.anim:Play()
end)
 
Minimap:SetScript("OnLeave",function()
	m_coord.anim:Stop()
	m_coord.anim_o:Play()
	m_zone.anim:Stop()
	m_zone.anim_o:Play()
end)
 
m_coord_text:SetText("00,00")
 
local ela,go = 0,false
 
m_coord.anim:SetScript("OnFinished",function() go = true end)
m_coord.anim_o:SetScript("OnPlay",function() go = false end)
 
local coord_Update = function(self,t)
	ela = ela - t
	if ela > 0 or not(go) then return end
	local x,y = GetPlayerMapPosition("player")
	local xt,yt
	x = math.floor(100 * x)
	y = math.floor(100 * y)
	if x == 0 and y == 0 then
		m_coord_text:SetText("X _ X")
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
		m_coord_text:SetText(xt..","..yt)
	end
	ela = .2
end
 
m_coord:SetScript("OnUpdate",coord_Update)
 
local zone_Update = function()
	local pvp = GetZonePVPInfo()
	m_zone_text:SetText(GetMinimapZoneText())
	if pvp == "friendly" then
		m_zone_text:SetTextColor(0.1, 1.0, 0.1)
	elseif pvp == "sanctuary" then
		m_zone_text:SetTextColor(0.41, 0.8, 0.94)
	elseif pvp == "arena" or pvp == "hostile" then
		m_zone_text:SetTextColor(1.0, 0.1, 0.1)
	elseif pvp == "contested" then
		m_zone_text:SetTextColor(1.0, 0.7, 0.0)
	else
		m_zone_text:SetTextColor(1.0, 1.0, 1.0)
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