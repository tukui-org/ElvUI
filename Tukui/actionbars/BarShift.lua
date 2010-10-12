if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Setup Shapeshift Bar, using Blizzard SS bar.
---------------------------------------------------------------------------

local TukuiShift = CreateFrame("Frame","TukuiShiftBar",UIParent)
TukuiShift:SetPoint("TOPLEFT", 2, -2)
TukuiShift:SetWidth(29)
TukuiShift:SetHeight(58)

-- shapeshift
ShapeshiftBarFrame:SetParent(TukuiShift)
ShapeshiftBarFrame:SetWidth(0.00001)
for i=1, 10 do
	local b = _G["ShapeshiftButton"..i]
	local b2 = _G["ShapeshiftButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		b:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(29))
	else
		b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.petbuttonspacing, 0)
	end
end

-- hook setpoint
local function MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT", TukuiShift, 0, TukuiDB.Scale(29))
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)

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

-- hide it if not needed
if TukuiCF.actionbar.hideshapeshift then
	TukuiShift:Hide()
end