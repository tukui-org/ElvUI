-- credits : Roth, Alza

if not TukuiDB["actionbar"].enable == true 
	or (IsAddOnLoaded("Dominos") 
	or IsAddOnLoaded("Bartender4") 
	or IsAddOnLoaded("Macaroon")) then
		return 
end

local db = TukuiDB["actionbar"]

TukuiDB.absettings = {
	["BonusBar"]   = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Bar2"]       = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Bar3"]       = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Right"]      = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Left"]       = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Pet"]        = {ma = "BOTTOMLEFT", p = ActionBarBackground, a = "BOTTOMLEFT", x = TukuiDB:Scale(4), y = TukuiDB:Scale(4), scale = 1},
	["Shapeshift"] = {ma = "TOPLEFT", p = UIParent, a = "TOPLEFT", x = 0,  y = 0, scale = 1},
}

local settings = TukuiDB.absettings
local _G = getfenv(0)

local CreateHolder = function(name, width, height, setting, numslots, buttonname)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetWidth(width)
	frame:SetHeight(height)
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
local fshift = CreateHolder("tShapeShiftHolder", TukuiDB:Scale(29), TukuiDB:Scale(58), "Shapeshift", NUM_SHAPESHIFT_SLOTS, "ShapeshiftButton")

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
	b:SetPoint("LEFT",b2,"RIGHT", TukuiDB:Scale(4), 0)
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
	b:SetPoint("LEFT",b2,"RIGHT", TukuiDB:Scale(4), 0)
end


-- shapeshift or totem bar
ShapeshiftBarFrame:SetParent(fshift)
ShapeshiftBarFrame:SetWidth(0.01)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetHeight(29)
ShapeshiftButton1:SetWidth(29)
ShapeshiftButton1:SetPoint("BOTTOMLEFT",fshift,0,TukuiDB:Scale(29))
local function rABS_MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT",fshift,0,TukuiDB:Scale(29))
end
hooksecurefunc("ShapeshiftBar_Update", rABS_MoveShapeshift)
for i=2, 10 do
	local b = _G["ShapeshiftButton"..i]
	local b2 = _G["ShapeshiftButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("LEFT",b2,"RIGHT", TukuiDB:Scale(4), 0)
end
if UnitLevel("player") >= 30 and select(2, UnitClass("Player")) == "SHAMAN" then
	MultiCastActionBarFrame:SetParent(fshift)
	MultiCastActionBarFrame:SetWidth(.01)

	MultiCastSummonSpellButton:SetParent(fshift)
	MultiCastSummonSpellButton:ClearAllPoints()
	MultiCastSummonSpellButton:SetPoint("LEFT",fshift,"RIGHT",10,0)
	for i=1, 4 do
		_G["MultiCastSlotButton"..i]:SetParent(fshift)
	end
	MultiCastSlotButton1:ClearAllPoints()
	MultiCastSlotButton1:SetPoint("LEFT",MultiCastSummonSpellButton,"RIGHT",2,0)
	MultiCastRecallSpellButton:ClearAllPoints()
	MultiCastRecallSpellButton:SetPoint("LEFT",MultiCastActionButton4,"RIGHT",1,0)
	for i=2, 4 do
		local b = _G["MultiCastSlotButton"..i]
		local b2 = _G["MultiCastSlotButton"..i-1]
		b:ClearAllPoints()
		b:SetPoint("LEFT",b2,"RIGHT",2,0)
	end
		
	MultiCastRecallSpellButton:ClearAllPoints()
	MultiCastRecallSpellButton:SetPoint("LEFT",MultiCastSlotButton4,"RIGHT",2,0)
		
	for i=1, 12 do
		local b = _G["MultiCastActionButton"..i], b2
		b:ClearAllPoints()
		if i % 4 == 1 then
			b:SetPoint("CENTER",MultiCastSlotButton1,"CENTER",0,0)
		else
			b2 = _G["MultiCastActionButton"..i-1]
		b:SetPoint("LEFT",b2,"RIGHT",5,0)
		end
	end
		
	local dummy = function() return end
	for i=1, 4 do
		local b = _G["MultiCastSlotButton"..i]
		b.SetParent = dummy
		b.SetPoint = dummy
	end
	MultiCastRecallSpellButton.SetParent = dummy
	MultiCastRecallSpellButton.SetPoint = dummy
end

-- possess bar, we don't care about this one, we just hide it.
PossessBarFrame:SetParent(fshift)
PossessBarFrame:SetScale(0.0001)
PossessBarFrame:SetAlpha(0)

-- pet action bar.
PetActionBarFrame:SetParent(fpet)
PetActionBarFrame:SetWidth(0.01)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint("TOP", PetActionBarBackground, "TOP", 0, TukuiDB:Scale(-4))
for i=2, 10 do
	local b = _G["PetActionButton"..i]
	local b2 = _G["PetActionButton"..i-1]
	b:ClearAllPoints()
	b:SetPoint("TOP", b2,"BOTTOM", 0, TukuiDB:Scale(-4))
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
   fbar4:Show()
   MultiBarRightButton1:ClearAllPoints()
   MultiBarRightButton1:SetPoint("TOPRIGHT", ActionBarBackgroundRight,"TOPRIGHT", TukuiDB:Scale(-4), TukuiDB:Scale(-4))
   for i= 2, 12 do
      local b = _G["MultiBarRightButton"..i]
      local b2 = _G["MultiBarRightButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("TOP", b2,"BOTTOM", 0, TukuiDB:Scale(-4))
   end
end
if db.rightbars > 1 then
   fbar3:Show()
   MultiBarBottomRightButton1:ClearAllPoints()
   MultiBarBottomRightButton1:SetPoint("TOPLEFT", ActionBarBackgroundRight,"TOPLEFT", TukuiDB:Scale(4), TukuiDB:Scale(-4))
   for i= 2, 12 do
      local b = _G["MultiBarBottomRightButton"..i]
      local b2 = _G["MultiBarBottomRightButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("TOP", b2,"BOTTOM", 0, TukuiDB:Scale(-4))
   end    
end
if db.rightbars > 2 then
   fbar5:Show()
   MultiBarLeftButton1:ClearAllPoints()
   MultiBarLeftButton1:SetPoint("TOP", ActionBarBackgroundRight,"TOP", 0, TukuiDB:Scale(-4))
   for i= 2, 12 do
      local b = _G["MultiBarLeftButton"..i]
      local b2 = _G["MultiBarLeftButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("TOP", b2,"BOTTOM", 0, TukuiDB:Scale(-4))
   end
end

-- now look for others shit, if found, set bar or override settings bar above.
if TukuiDB.lowversion == true then
   if db.bottomrows == 2 then
      fbar2:Show()
      MultiBarBottomLeftButton1:ClearAllPoints()
      MultiBarBottomLeftButton1:SetPoint("BOTTOM", ActionButton1, "TOP", 0,TukuiDB:Scale(4))
      for i=2, 12 do
         local b = _G["MultiBarBottomLeftButton"..i]
         local b2 = _G["MultiBarBottomLeftButton"..i-1]
         b:ClearAllPoints()
         b:SetPoint("LEFT",b2,"RIGHT", TukuiDB:Scale(4), 0)
      end   
   end
else
   fbar2:Show()
   MultiBarBottomLeftButton1:ClearAllPoints()
   MultiBarBottomLeftButton1:SetPoint("LEFT", ActionButton12, "RIGHT", TukuiDB:Scale(4),0)
   for i=2, 12 do
      local b = _G["MultiBarBottomLeftButton"..i]
      local b2 = _G["MultiBarBottomLeftButton"..i-1]
      b:ClearAllPoints()
      b:SetPoint("LEFT",b2,"RIGHT", TukuiDB:Scale(4), 0)
   end
   MultiBarBottomLeftButton11:SetAlpha(0)
   MultiBarBottomLeftButton11:SetScale(0.0001)
   MultiBarBottomLeftButton12:SetAlpha(0)
   MultiBarBottomLeftButton12:SetScale(0.0001)   
   if db.bottomrows == 2 then
      fbar5:Show()
      MultiBarBottomRightButton1:ClearAllPoints()
      MultiBarBottomRightButton1:SetPoint("BOTTOM", ActionButton1,"TOP", 0, TukuiDB:Scale(4))
      for i= 2, 12 do
         local b = _G["MultiBarBottomRightButton"..i]
         local b2 = _G["MultiBarBottomRightButton"..i-1]
         b:ClearAllPoints()
         b:SetPoint("LEFT", b2,"RIGHT", TukuiDB:Scale(4), 0)
      end
      fbar3:Show()
      MultiBarLeftButton1:ClearAllPoints()
      MultiBarLeftButton1:SetPoint("LEFT", MultiBarBottomRightButton12,"RIGHT", TukuiDB:Scale(4), 0)
      for i= 2, 12 do
         local b = _G["MultiBarLeftButton"..i]
         local b2 = _G["MultiBarLeftButton"..i-1]
         b:ClearAllPoints()
         b:SetPoint("LEFT", b2,"RIGHT", TukuiDB:Scale(4), 0)
      end
      MultiBarLeftButton11:SetScale(0.0001)
      MultiBarLeftButton11:SetAlpha(0)
      MultiBarLeftButton12:SetScale(0.0001)
      MultiBarLeftButton12:SetAlpha(0)
   end
end

------------------------------------------------------------------------------------------
-- function and others stuff
------------------------------------------------------------------------------------------

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

local FramesToHide = {
	MainMenuBar,
	VehicleMenuBar,
}  

for _, f in pairs(FramesToHide) do
	f:SetScale(0.001)
	f:SetAlpha(0)
	f:EnableMouse(false)
end

local vehicle = CreateFrame("BUTTON", nil, UIParent, "SecureActionButtonTemplate")
vehicle:SetWidth(26)
vehicle:SetHeight(26)
vehicle:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 2, -26)

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
		if db.rightbars > 0 then
			ActionBarBackgroundRight:SetAlpha(0)
			RightBarLine:SetAlpha(0)
			CubeRightBarUP:SetAlpha(0)
			CubeRightBarDown:SetAlpha(0)
		end
	elseif (((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and arg1 == "player") then
		vehicle:SetAlpha(0)
		if db.rightbars > 0 then
			ActionBarBackgroundRight:SetAlpha(1)
			RightBarLine:SetAlpha(1)
			CubeRightBarUP:SetAlpha(1)
			CubeRightBarDown:SetAlpha(1)
		end
	end
end)  
vehicle:SetAlpha(0)

local ssmover = CreateFrame("Frame","ssmoverholder", UIParent)
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
		fshift:RegisterForDrag("LeftButton","RightButton")
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

--[[ Range coloring. This function is taken from nMainBar, so all credits for it go to Neal ]]
function ActionButton_OnUpdate(self, elapsed)
    if(ActionButton_IsFlashing(self)) then
        local flashtime = self.flashtime
        flashtime = flashtime - elapsed

        if ( flashtime <= 0 ) then
            local overtime = -flashtime
            if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
                overtime = 0
            end
            flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

            local flashTexture = _G[self:GetName().."Flash"]
            if (flashTexture:IsShown()) then
                flashTexture:Hide()
            else
                flashTexture:Show()
            end
        end
        
        self.flashtime = flashtime
    end

    local rangeTimer = self.rangeTimer
    if(rangeTimer) then
        rangeTimer = rangeTimer - elapsed
        if(rangeTimer<=0) then

            local isInRange = false
            if(ActionHasRange(self.action) and IsActionInRange(self.action)==0) then
                _G[self:GetName().."Icon"]:SetVertexColor(0.9, 0.1, 0.1)
                isInRange = true
            end

            if (self.isInRange~=isInRange) then
                self.isInRange = isInRange
                ActionButton_UpdateUsable(self)
            end
            rangeTimer = 0.2
        end
        self.rangeTimer = rangeTimer
    end
end

local function mouseoverpet(alpha)
	PetActionBarBackground:SetAlpha(alpha)
	for i=1, NUM_PET_ACTION_SLOTS do
		local pb = _G["PetActionButton"..i]
		pb:SetAlpha(alpha)
	end
end

local function mouseoverstance(alpha)
	if UnitLevel("player") >= 30 and select(2, UnitClass("Player")) == "SHAMAN" then
		for i=1, 4 do
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
	ActionBarBackgroundRight:SetAlpha(alpha)
	RightBarLine:SetAlpha(alpha)
	CubeRightBarUP:SetAlpha(alpha)
	CubeRightBarDown:SetAlpha(alpha)
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
	RightBarLine:SetAlpha(0)
	CubeRightBarUP:SetAlpha(0)
	CubeRightBarDown:SetAlpha(0)
	ActionBarBackgroundRight:EnableMouse(true)
	PetActionBarBackground:EnableMouse(true)
	ActionBarBackgroundRight:SetAlpha(0)
	PetActionBarBackground:SetAlpha(0)
	ActionBarBackgroundRight:SetScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
	ActionBarBackgroundRight:SetScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
	PetActionBarBackground:SetScript("OnEnter", function(self) mouseoverpet(1) rightbaralpha(1) end)
	PetActionBarBackground:SetScript("OnLeave", function(self) mouseoverpet(0) rightbaralpha(0) end)
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

if db.hideshapeshift == true then
	fshift:Hide()
end