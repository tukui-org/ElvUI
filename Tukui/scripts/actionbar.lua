if not TukuiCF["actionbar"].enable == true then return end
local db = TukuiCF["actionbar"]

------------------------------------------------------------------------------------------
-- the bar holder
------------------------------------------------------------------------------------------

-- create it
local TukuiBar1 = CreateFrame("Frame","TukuiBar1",UIParent) 
local TukuiBar2 = CreateFrame("Frame","TukuiBar2",UIParent) 
local TukuiBar3 = CreateFrame("Frame","TukuiBar3",UIParent) 
local TukuiBar4 = CreateFrame("Frame","TukuiBar4",UIParent) 
local TukuiBar5 = CreateFrame("Frame","TukuiBar5",UIParent) 
local TukuiPet = CreateFrame("Frame","TukuiPet",UIParent) 
local TukuiShift = CreateFrame("Frame","TukuiShift",UIParent)

-- move & set it
TukuiBar1:SetAllPoints(TukuiActionBarBackground)
TukuiBar2:SetAllPoints(TukuiActionBarBackground)
TukuiBar3:SetAllPoints(TukuiActionBarBackground)
TukuiBar4:SetAllPoints(TukuiActionBarBackground)
TukuiBar5:SetAllPoints(TukuiActionBarBackground)
TukuiPet:SetAllPoints(TukuiPetActionBarBackground)
TukuiShift:SetPoint("TOPLEFT", 2, -2)
TukuiShift:SetWidth(29)
TukuiShift:SetHeight(58)

------------------------------------------------------------------------------------------
-- these bars will always exist, on any tukui action bar layout.
------------------------------------------------------------------------------------------

-- main action bar
for i = 1, 12 do
	_G["ActionButton"..i]:SetParent(TukuiBar1)
end

ActionButton1:ClearAllPoints()
ActionButton1:SetPoint("BOTTOMLEFT", TukuiDB.Scale(4), TukuiDB.Scale(4))
for i=2, 12 do
	local b = _G["ActionButton"..i]
	local b2 = _G["ActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
end

-- bonus action bar
BonusActionBarFrame:SetParent(TukuiBar1)
BonusActionBarFrame:SetWidth(0.1) -- fix a bug on button 13,14,15,16
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()
BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint("BOTTOMLEFT", 0, TukuiDB.Scale(4))
for i=2, 12 do
	local b = _G["BonusActionButton"..i]
	local b2 = _G["BonusActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
end

-- shapeshift
ShapeshiftBarFrame:SetParent(TukuiShift)
ShapeshiftBarFrame:SetWidth(0.00001)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetHeight(TukuiDB.Scale(29))
ShapeshiftButton1:SetWidth(TukuiDB.Scale(29))
ShapeshiftButton1:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(29))
local function MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(29))
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)
for i=2, 10 do
	local b = _G["ShapeshiftButton"..i]
	local b2 = _G["ShapeshiftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.petbuttonspacing, 0)
end

if TukuiDB.myclass == "SHAMAN" then
	if MultiCastActionBarFrame then
		MultiCastActionBarFrame:SetParent(TukuiShift)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(23))
 
		for i = 1, 4 do
			local b = _G["MultiCastSlotButton"..i]
			local b2 = _G["MultiCastActionButton"..i]
 
			b:ClearAllPoints()
			b:SetAllPoints(b2)
		end
 
		MultiCastActionBarFrame.SetParent = TukuiDB.dummy
		MultiCastActionBarFrame.SetPoint = TukuiDB.dummy
		MultiCastRecallSpellButton.SetPoint = TukuiDB.dummy -- bug fix, see http://www.tukui.org/v2/forums/topic.php?id=2405
	end
end

-- possess bar, we don't care about this one, we just hide it.
PossessBarFrame:SetParent(TukuiShift)
PossessBarFrame:SetScale(0.0001)
PossessBarFrame:SetAlpha(0)

-- pet action bar.
PetActionBarFrame:SetParent(TukuiPet)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint("TOP", TukuiPetActionBarBackground, "TOP", 0, TukuiDB.Scale(-4))
for i=2, 10 do
	local b = _G["PetActionButton"..i]
	local b2 = _G["PetActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.petbuttonspacing)
end

------------------------------------------------------------------------------------------
-- now let's parent, set and hide extras action bar.
------------------------------------------------------------------------------------------

MultiBarBottomLeft:SetParent(TukuiBar2)
TukuiBar2:Hide()

MultiBarBottomRight:SetParent(TukuiBar3)
TukuiBar3:Hide()

MultiBarRight:SetParent(TukuiBar4)
TukuiBar4:Hide()

MultiBarLeft:SetParent(TukuiBar5)
TukuiBar5:Hide()

------------------------------------------------------------------------------------------
-- now let's show what we need by checking our config.lua
------------------------------------------------------------------------------------------

-- look for right bars
if db.rightbars > 0 then
	TukuiActionBarBackgroundRight:SetFrameStrata("BACKGROUND")
	TukuiActionBarBackgroundRight:SetFrameLevel(1)
	TukuiBar4:Show()
	MultiBarRightButton1:ClearAllPoints()
	MultiBarRightButton1:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(-4))
	for i= 2, 12 do
		local b = _G["MultiBarRightButton"..i]
		local b2 = _G["MultiBarRightButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
	end
end

if db.rightbars > 1 then
	TukuiBar3:Show()
	MultiBarBottomRightButton1:ClearAllPoints()
	MultiBarBottomRightButton1:SetPoint("TOPLEFT", TukuiActionBarBackgroundRight, "TOPLEFT", TukuiDB.Scale(4), TukuiDB.Scale(-4))
	for i= 2, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
	end    
end

if db.rightbars > 2 then
	TukuiBar5:Show()
	MultiBarLeftButton1:ClearAllPoints()
	MultiBarLeftButton1:SetPoint("TOP", TukuiActionBarBackgroundRight, "TOP", 0, TukuiDB.Scale(-4))
	for i= 2, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
	end
end

-- now look for others shit, if found, set bar or override settings bar above.
if TukuiDB.lowversion == true then
	if db.bottomrows == 2 then
		TukuiBar2:Show()
		MultiBarBottomLeftButton1:ClearAllPoints()
		MultiBarBottomLeftButton1:SetPoint("BOTTOM", ActionButton1, "TOP", 0, TukuiDB.Scale(4))
		for i=2, 12 do
			local b = _G["MultiBarBottomLeftButton"..i]
			local b2 = _G["MultiBarBottomLeftButton"..i-1]
			b:ClearAllPoints()
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		end   
	end
else
	TukuiBar2:Show()
	MultiBarBottomLeftButton1:ClearAllPoints()
	MultiBarBottomLeftButton1:SetPoint("LEFT", ActionButton12, "RIGHT", TukuiDB.Scale(4), 0)
	for i=2, 12 do
		local b = _G["MultiBarBottomLeftButton"..i]
		local b2 = _G["MultiBarBottomLeftButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
	end
	MultiBarBottomLeftButton11:SetAlpha(0)
	MultiBarBottomLeftButton11:SetScale(0.0001)
	MultiBarBottomLeftButton12:SetAlpha(0)
	MultiBarBottomLeftButton12:SetScale(0.0001)   
	if db.bottomrows == 2 then
		TukuiBar5:Show()
		MultiBarBottomRightButton1:ClearAllPoints()
		MultiBarBottomRightButton1:SetPoint("BOTTOM", ActionButton1, "TOP", 0, TukuiDB.Scale(4))
		for i= 2, 12 do
			local b = _G["MultiBarBottomRightButton"..i]
			local b2 = _G["MultiBarBottomRightButton"..i-1]
			b:ClearAllPoints()
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		end
		TukuiBar3:Show()
		MultiBarLeftButton1:ClearAllPoints()
		MultiBarLeftButton1:SetPoint("LEFT", MultiBarBottomRightButton12, "RIGHT", TukuiDB.Scale(4), 0)
		for i= 2, 12 do
			local b = _G["MultiBarLeftButton"..i]
			local b2 = _G["MultiBarLeftButton"..i-1]
			b:ClearAllPoints()
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		end
		MultiBarLeftButton11:SetScale(0.0001)
		MultiBarLeftButton11:SetAlpha(0)
		MultiBarLeftButton12:SetScale(0.0001)
		MultiBarLeftButton12:SetAlpha(0)
	end
end

------------------------------------------------------------------------------------------
-- functions and others stuff
------------------------------------------------------------------------------------------

-- bonus bar (vehicle, rogue, etc)
local function BonusBarAlpha(alpha)
	local f = "ActionButton"
	for i=1, 12 do
		_G[f..i]:SetAlpha(alpha)
	end
end
BonusActionBarFrame:HookScript("OnShow", function(self) BonusBarAlpha(0) end)
BonusActionBarFrame:HookScript("OnHide", function(self) BonusBarAlpha(1) end)
if BonusActionBarFrame:IsShown() then
	BonusBarAlpha(0)
end

-- hide these blizzard frames
local FramesToHide = {
	MainMenuBar,
	VehicleMenuBar,
} 

for _, f in pairs(FramesToHide) do
	f:SetScale(0.00001)
	f:SetAlpha(0)
end

-- vehicle button under minimap
local vehicle = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")
vehicle:SetWidth(TukuiDB.Scale(26))
vehicle:SetHeight(TukuiDB.Scale(26))
vehicle:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-26))

vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", function() VehicleExit() end)

vehicle:SetNormalTexture("Interface\\AddOns\\Tukui\\media\\textures\\vehicleexit")
vehicle:SetPushedTexture("Interface\\AddOns\\Tukui\\media\\textures\\vehicleexit")
vehicle:SetHighlightTexture("Interface\\AddOns\\Tukui\\media\\textures\\vehicleexit")
TukuiDB.SetTemplate(vehicle)

vehicle:RegisterEvent("UNIT_ENTERING_VEHICLE")
vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITING_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
vehicle:SetScript("OnEvent", function(self, event, arg1)
	if (((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
		vehicle:SetAlpha(1)
	elseif (((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") or (event=="ZONE_CHANGED_NEW_AREA" and not UnitHasVehicleUI("player")) then
		vehicle:SetAlpha(0)
	end
end)  
vehicle:SetAlpha(0)

-- shapeshift command to move it in-game
local ssmover = CreateFrame("Frame", "ssmoverholder", UIParent)
ssmover:SetAllPoints(TukuiShift)
TukuiDB.SetTemplate(ssmover)
ssmover:SetAlpha(0)
TukuiShift:SetMovable(true)
TukuiShift:SetUserPlaced(true)
local ssmove = false
local function showmovebutton()
	if ssmove == false then
		ssmove = true
		ssmover:SetAlpha(1)
		TukuiShift:EnableMouse(true)
		TukuiShift:RegisterForDrag("LeftButton", "RightButton")
		TukuiShift:SetScript("OnDragStart", function(self) self:StartMoving() end)
		TukuiShift:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	elseif ssmove == true then
		ssmove = false
		ssmover:SetAlpha(0)
		TukuiShift:EnableMouse(false)
	end
end
SLASH_SHOWMOVEBUTTON1 = "/mss"
SlashCmdList["SHOWMOVEBUTTON"] = showmovebutton

-- mouseover option
local function mouseoverpet(alpha)
	TukuiPetActionBarBackground:SetAlpha(alpha)
	for i=1, NUM_PET_ACTION_SLOTS do
		local pb = _G["PetActionButton"..i]
		pb:SetAlpha(alpha)
	end
end

local function mouseoverstance(alpha)
	if TukuiDB.myclass == "SHAMAN" then
		for i=1, 12 do
			local pb = _G["MultiCastActionButton"..i]
			pb:SetAlpha(alpha)
		end
		for i=1, 4 do
			local pb = _G["MultiCastSlotButton"..i]
			pb:SetAlpha(alpha)
		end
	else
		for i=1, 10 do
			local pb = _G["ShapeshiftButton"..i]
			pb:SetAlpha(alpha)
		end
	end
end

local function rightbaralpha(alpha)
	TukuiActionBarBackgroundRight:SetAlpha(alpha)
	TukuiRightBarLine:SetAlpha(alpha)
	TukuiCubeRightBarUP:SetAlpha(alpha)
	TukuiCubeRightBarDown:SetAlpha(alpha)
	if db.rightbars > 2 then
		if MultiBarLeft:IsShown() then
			for i=1, 12 do
				local pb = _G["MultiBarLeftButton"..i]
				pb:SetAlpha(alpha)
			end
			MultiBarLeft:SetAlpha(alpha)
		end
	end
	if db.rightbars > 1 then
		if MultiBarBottomRight:IsShown() then
			for i=1, 12 do
				local pb = _G["MultiBarBottomRightButton"..i]
				pb:SetAlpha(alpha)
			end
			MultiBarBottomRight:SetAlpha(alpha)
		end
	end
	if db.rightbars > 0 then
		if MultiBarRight:IsShown() then
			for i=1, 12 do
				local pb = _G["MultiBarRightButton"..i]
				pb:SetAlpha(alpha)
			end
			MultiBarRight:SetAlpha(alpha)
		end
	end
end

if db.rightbarmouseover == true and db.rightbars > 0 then
	TukuiRightBarLine:SetAlpha(0)
	TukuiCubeRightBarUP:SetAlpha(0)
	TukuiCubeRightBarDown:SetAlpha(0)
	TukuiActionBarBackgroundRight:EnableMouse(true)
	TukuiPetActionBarBackground:EnableMouse(true)
	TukuiActionBarBackgroundRight:SetAlpha(0)
	TukuiPetActionBarBackground:SetAlpha(0)
	TukuiActionBarBackgroundRight:SetScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
	TukuiActionBarBackgroundRight:SetScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
	TukuiPetActionBarBackground:SetScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
	TukuiPetActionBarBackground:SetScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
	for i=1, 12 do
		local pb = _G["MultiBarRightButton"..i]
		pb:SetAlpha(0)
		pb:HookScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
		pb:HookScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
		if not (db.rightbars == 1 and db.bottomrows == 2 and TukuiDB.lowversion ~= true) then
			local pb = _G["MultiBarLeftButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
			pb:HookScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
			local pb = _G["MultiBarBottomRightButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
			pb:HookScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
		end
	end
	for i=1, NUM_PET_ACTION_SLOTS do
		local pb = _G["PetActionButton"..i]
		pb:SetAlpha(0)
		pb:HookScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
		pb:HookScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
	end
end

if db.shapeshiftmouseover == true then
	if TukuiDB.myclass == "SHAMAN" then
		TukuiShift:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
		TukuiShift:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
		MultiCastSummonSpellButton:SetAlpha(0)
		MultiCastSummonSpellButton:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
		MultiCastSummonSpellButton:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
		MultiCastRecallSpellButton:SetAlpha(0)
		MultiCastRecallSpellButton:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
		MultiCastRecallSpellButton:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
		MultiCastFlyoutFrameOpenButton:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
		MultiCastFlyoutFrameOpenButton:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)		

		for i=1, 4 do
			local pb = _G["MultiCastSlotButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
			pb:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
		end
		for i=1, 4 do
			local pb = _G["MultiCastActionButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
			pb:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
		end
	else
		TukuiShift:HookScript("OnEnter", function(self) mouseoverstance(1) end)
		TukuiShift:HookScript("OnLeave", function(self) mouseoverstance(0) end)
		for i=1, 10 do
			local pb = _G["ShapeshiftButton"..i]
			pb:SetAlpha(0)
			pb:HookScript("OnEnter", function(self) mouseoverstance(1) end)
			pb:HookScript("OnLeave", function(self) mouseoverstance(0) end)
		end
	end
end

-- option to hide shapeshift or totem bar.
if db.hideshapeshift == true then
	TukuiShift:Hide()
end

-- Hide options for action bar in default interface option.
InterfaceOptionsActionBarsPanelBottomLeft:Hide()
InterfaceOptionsActionBarsPanelBottomRight:Hide()
InterfaceOptionsActionBarsPanelRight:Hide()
InterfaceOptionsActionBarsPanelRightTwo:Hide()
InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Hide()

-- always hide these textures (it's the textures in /interface/ShapeshiftBar folder)
SlidingActionBarTexture0:SetTexture(nil)
SlidingActionBarTexture1:SetTexture(nil)
ShapeshiftBarLeft:SetTexture(nil)
ShapeshiftBarRight:SetTexture(nil)
ShapeshiftBarMiddle:SetTexture(nil)