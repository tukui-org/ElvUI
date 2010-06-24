-- special thank's to Roth, Alza for their awesome work which helped me to build tukui action bar.

if not TukuiDB["actionbar"].enable == true then return end

local db = TukuiDB["actionbar"]

-- hide options that we don't need.
InterfaceOptionsActionBarsPanelBottomLeft:Hide()
InterfaceOptionsActionBarsPanelBottomRight:Hide()
InterfaceOptionsActionBarsPanelRight:Hide()
InterfaceOptionsActionBarsPanelRightTwo:Hide()
InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Hide()

-- this thing below is only "invisible" frame holder to setup for action bar. Moving or changing these lines will do nothing visually in-game.
-- we create invisible bar holder frame to avoid bugs, example, vehicle, seen in the past version of Tukui when showing or hidding bar.
-- Running our codes via frame holder instead of blizzard default action bar frame name allow us to do what we want with 0 errors/crash.
TukuiDB.absettings = {
	["BonusBar"]   = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Bar2"]       = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Bar3"]       = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Right"]      = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Left"]       = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Pet"]        = {ma = "BOTTOMLEFT", p = TukuiActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Shapeshift"] = {ma = "TOPLEFT", p = UIParent, a = "TOPLEFT", x = 0,  y = 0, scale = 1},
}

local settings = TukuiDB.absettings
local _G = getfenv(0)

-- invisible frame holder creation and position.
local CreateHolder = function(name, width, height, setting, numslots, buttonname)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetWidth(TukuiDB:Scale(width))
	frame:SetHeight(TukuiDB:Scale(height))
	frame:SetPoint(settings[setting].ma, settings[setting].p, settings[setting].a, settings[setting].x / settings[setting].scale, settings[setting].y / settings[setting].scale)

	return frame
end

------------------------------------------------------------------------------------------
-- the bar holder
------------------------------------------------------------------------------------------

local fbar1 = CreateHolder("tBar1Holder", 1, 1, "BonusBar", 12, "BonusActionButton", "ActionButton")
local fbar2 = CreateHolder("tBar2Holder", 1, 1, "Bar2", 12, "MultiBarBottomLeftButton")
local fbar3 = CreateHolder("tBar3Holder", 1, 1, "Bar3", 12, "MultiBarBottomRightButton")
local fbar4 = CreateHolder("tBar4Holder", 1, 1, "Right", 12, "MultiBarRightButton")
local fbar5 = CreateHolder("tBar5Holder", 1, 1, "Left", 12, "MultiBarLeftButton")
local fpet = CreateHolder("tPetBarHolder", 1, 1, "Pet", NUM_PET_ACTION_SLOTS, "PetActionButton")
local fshift = CreateHolder("tShapeShiftHolder", 29, 58, "Shapeshift", NUM_SHAPESHIFT_SLOTS, "ShapeshiftButton")

------------------------------------------------------------------------------------------
-- these bars will always exist, on any tukui action bar layout.
------------------------------------------------------------------------------------------

-- main action bar
for i = 1, 12 do
	_G["ActionButton"..i]:SetParent(fbar1)
end

ActionButton1:ClearAllPoints()
ActionButton1:SetPoint("BOTTOMLEFT", fbar1, "BOTTOMLEFT")
for i=2, 12 do
	local b = _G["ActionButton"..i]
	local b2 = _G["ActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
end

-- bonus action bar
BonusActionBarFrame:SetParent(fbar1)
BonusActionBarFrame:SetWidth(0.01)
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()
BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint("BOTTOMLEFT", fbar1, "BOTTOMLEFT")
for i=2, 12 do
	local b = _G["BonusActionButton"..i]
	local b2 = _G["BonusActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
end


-- shapeshift or totem bar
ShapeshiftBarFrame:SetParent(fshift)
ShapeshiftBarFrame:SetWidth(0.01)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetHeight(TukuiDB:Scale(29))
ShapeshiftButton1:SetWidth(TukuiDB:Scale(29))
ShapeshiftButton1:SetPoint("BOTTOMLEFT", fshift, 0, TukuiDB:Scale(29))
local function rABS_MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT", fshift, 0, TukuiDB:Scale(29))
end
hooksecurefunc("ShapeshiftBar_Update", rABS_MoveShapeshift)
for i=2, 10 do
	local b = _G["ShapeshiftButton"..i]
	local b2 = _G["ShapeshiftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.petbuttonspacing, 0)
end
if UnitLevel("player") >= 30 and select(2, UnitClass("Player")) == "SHAMAN" then
	MultiCastActionBarFrame:SetParent(fshift)
	MultiCastActionBarFrame:SetWidth(0.01)

	MultiCastSummonSpellButton:SetParent(fshift)
	MultiCastSummonSpellButton:ClearAllPoints()
	MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT", fshift, 0, TukuiDB:Scale(29))

	for i=1, 4 do
		_G["MultiCastSlotButton"..i]:SetParent(fshift)
	end
	MultiCastSlotButton1:ClearAllPoints()
	MultiCastSlotButton1:SetPoint("LEFT", MultiCastSummonSpellButton, "RIGHT", TukuiDB:Scale(2), 0)
	for i=2, 4 do
		local b = _G["MultiCastSlotButton"..i]
		local b2 = _G["MultiCastSlotButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("LEFT", b2, "RIGHT", TukuiDB:Scale(2), 0)
	end
		
	MultiCastRecallSpellButton:ClearAllPoints()
	MultiCastRecallSpellButton:SetPoint("LEFT", MultiCastSlotButton4, "RIGHT", TukuiDB:Scale(2), 0)
		
	for i=1, 12 do
		local b = _G["MultiCastActionButton"..i]
		local b2 = _G["MultiCastSlotButton"..(i % 4 == 0 and 4 or i % 4)]
		b:ClearAllPoints()
		b:SetPoint("CENTER", b2, "CENTER", 0, 0)
	end
		
	for i=1, 4 do
		local b = _G["MultiCastSlotButton"..i]
		b.SetParent = TukuiDB.dummy
		b.SetPoint = TukuiDB.dummy
	end
	MultiCastRecallSpellButton.SetParent = TukuiDB.dummy
	MultiCastRecallSpellButton.SetPoint = TukuiDB.dummy
end

-- possess bar, we don't care about this one, we just hide it.
PossessBarFrame:SetParent(fshift)
PossessBarFrame:SetScale(0.0001)
PossessBarFrame:SetAlpha(0)

-- pet action bar.
PetActionBarFrame:SetParent(fpet)
PetActionBarFrame:SetWidth(0.01)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint("TOP", TukuiPetActionBarBackground, "TOP", 0, TukuiDB:Scale(-4))
for i=2, 10 do
	local b = _G["PetActionButton"..i]
	local b2 = _G["PetActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.petbuttonspacing)
end

------------------------------------------------------------------------------------------
-- now let's parent, set and hide extras action bar.
------------------------------------------------------------------------------------------

MultiBarBottomLeft:SetParent(fbar2)
fbar2:Hide()

MultiBarBottomRight:SetParent(fbar3)
fbar3:Hide()

MultiBarRight:SetParent(fbar4)
fbar4:Hide()

MultiBarLeft:SetParent(fbar5)
fbar5:Hide()

------------------------------------------------------------------------------------------
-- now let's show what we need by checking our config.lua
------------------------------------------------------------------------------------------

-- look for right bars
if db.rightbars > 0 then
   TukuiActionBarBackgroundRight:SetFrameStrata("BACKGROUND")
   TukuiActionBarBackgroundRight:SetFrameLevel(1)
   fbar4:Show()
   MultiBarRightButton1:ClearAllPoints()
   MultiBarRightButton1:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", TukuiDB:Scale(-4), TukuiDB:Scale(-4))
   for i= 2, 12 do
      local b = _G["MultiBarRightButton"..i]
      local b2 = _G["MultiBarRightButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
   end
end
if db.rightbars > 1 then
   fbar3:Show()
   MultiBarBottomRightButton1:ClearAllPoints()
   MultiBarBottomRightButton1:SetPoint("TOPLEFT", TukuiActionBarBackgroundRight, "TOPLEFT", TukuiDB:Scale(4), TukuiDB:Scale(-4))
   for i= 2, 12 do
      local b = _G["MultiBarBottomRightButton"..i]
      local b2 = _G["MultiBarBottomRightButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
   end    
end
if db.rightbars > 2 then
   fbar5:Show()
   MultiBarLeftButton1:ClearAllPoints()
   MultiBarLeftButton1:SetPoint("TOP", TukuiActionBarBackgroundRight, "TOP", 0, TukuiDB:Scale(-4))
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
      fbar2:Show()
      MultiBarBottomLeftButton1:ClearAllPoints()
      MultiBarBottomLeftButton1:SetPoint("BOTTOM", ActionButton1, "TOP", 0, TukuiDB:Scale(4))
      for i=2, 12 do
         local b = _G["MultiBarBottomLeftButton"..i]
         local b2 = _G["MultiBarBottomLeftButton"..i-1]
         b:ClearAllPoints()
         b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
      end   
   end
else
   fbar2:Show()
   MultiBarBottomLeftButton1:ClearAllPoints()
   MultiBarBottomLeftButton1:SetPoint("LEFT", ActionButton12, "RIGHT", TukuiDB:Scale(4), 0)
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
      fbar5:Show()
      MultiBarBottomRightButton1:ClearAllPoints()
      MultiBarBottomRightButton1:SetPoint("BOTTOM", ActionButton1, "TOP", 0, TukuiDB:Scale(4))
      for i= 2, 12 do
         local b = _G["MultiBarBottomRightButton"..i]
         local b2 = _G["MultiBarBottomRightButton"..i-1]
         b:ClearAllPoints()
         b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
      end
      fbar3:Show()
      MultiBarLeftButton1:ClearAllPoints()
      MultiBarLeftButton1:SetPoint("LEFT", MultiBarBottomRightButton12, "RIGHT", TukuiDB:Scale(4), 0)
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
local function rABS_showhideactionbuttons(alpha)
	for i = 1, 12 do
		_G["ActionButton"..i]:SetAlpha(alpha)
	end
end
BonusActionBarFrame:HookScript("OnShow", function(self) rABS_showhideactionbuttons(0) end)
BonusActionBarFrame:HookScript("OnHide", function(self) rABS_showhideactionbuttons(1) end)
if BonusActionBarFrame:IsShown() then
	rABS_showhideactionbuttons(0)
end

-- hide these blizzard frames
local FramesToHide = {
	MainMenuBar,
	VehicleMenuBar,
}  

for _, f in pairs(FramesToHide) do
	f:SetScale(0.001)
	f:SetAlpha(0)
	f:EnableMouse(false)
end

-- vehicle button under minimap
local vehicle = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")
vehicle:SetWidth(TukuiDB:Scale(26))
vehicle:SetHeight(TukuiDB:Scale(26))
vehicle:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", TukuiDB:Scale(2), TukuiDB:Scale(-26))

vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", function() VehicleExit() end)

vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
vehicle:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
vehicle:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
TukuiDB:SetTemplate(vehicle)

vehicle:RegisterEvent("UNIT_ENTERING_VEHICLE")
vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITING_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicle:SetScript("OnEvent", function(self, event, arg1)
	if (((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and arg1 == "player") then
		vehicle:SetAlpha(1)
	elseif (((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
		vehicle:SetAlpha(0)
	end
end)  
vehicle:SetAlpha(0)

-- shapeshift command to move it in-game
local ssmover = CreateFrame("Frame", "ssmoverholder", UIParent)
ssmover:SetAllPoints(fshift)
TukuiDB:SetTemplate(ssmover)
ssmover:SetAlpha(0)
fshift:SetMovable(true)
fshift:SetUserPlaced(true)
local ssmove = false
local function showmovebutton()
	if ssmove == false then
		ssmove = true
		ssmover:SetAlpha(1)
		fshift:EnableMouse(true)
		fshift:RegisterForDrag("LeftButton", "RightButton")
		fshift:SetScript("OnDragStart", function(self) self:StartMoving() end)
		fshift:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	elseif ssmove == true then
		ssmove = false
		ssmover:SetAlpha(0)
		fshift:EnableMouse(false)
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
	if UnitLevel("player") >= 30 and select(2, UnitClass("Player")) == "SHAMAN" then
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
	if UnitLevel("player") >= 30 and select(2, UnitClass("Player")) == "SHAMAN" then
		fshift:HookScript("OnEnter", function(self) MultiCastSummonSpellButton:SetAlpha(1) MultiCastRecallSpellButton:SetAlpha(1) mouseoverstance(1) end)
		fshift:HookScript("OnLeave", function(self) MultiCastSummonSpellButton:SetAlpha(0) MultiCastRecallSpellButton:SetAlpha(0) mouseoverstance(0) end)
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
		fshift:HookScript("OnEnter", function(self) mouseoverstance(1) end)
		fshift:HookScript("OnLeave", function(self) mouseoverstance(0) end)
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
	fshift:Hide()
end
