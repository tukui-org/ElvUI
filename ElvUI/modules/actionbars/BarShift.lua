if (not ElvCF["actionbar"].enable == true) then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- Setup Shapeshift Bar
---------------------------------------------------------------------------
local numshape = 0
for i = 1, NUM_SHAPESHIFT_SLOTS do
	if _G["ShapeshiftButton"..i] and _G["ShapeshiftButton"..i]:IsShown() then numshape = numshape + 1 end
end

-- used for anchor totembar or shapeshiftbar
local ElvuiShift = CreateFrame("Frame","ElvuiShiftBar",ElvuiActionBarBackground)
if ElvCF["actionbar"].microbar == true then
	ElvuiShift:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 3, -38)
else
	ElvuiShift:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 2, -2)
end
local w = numshape * (ElvDB.petbuttonspacing + ElvDB.petbuttonsize)
if w < 100 then w = 100 end
ElvuiShift:SetWidth(w)
ElvuiShift:SetHeight(ElvDB.petbuttonsize)

if ElvCF["actionbar"].hideshapeshift == true then
	ElvuiShift:Hide()
end

ElvDB.CreateMover(ElvuiShift, "ShapeShiftMover", "Class Bar")

-- hide it if not needed and stop executing code
if ElvCF.actionbar.hideshapeshift then ElvuiShift:Hide() return end

-- create the shapeshift bar if we enabled it
local bar = CreateFrame("Frame", "ElvuiShapeShift", ElvuiShift, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(ElvuiShift)

local States = {
	["DRUID"] = "show",
	["WARRIOR"] = "show",
	["PALADIN"] = "show",
	["DEATHKNIGHT"] = "show",
	["ROGUE"] = "show,",
	["PRIEST"] = "show,",
	["HUNTER"] = "show,",
	["WARLOCK"] = "show,",
}

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
bar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
bar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
bar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
bar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			if ElvCF["actionbar"].verticalstance ~= true then
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", ElvuiShift, 0, 0)
				else
					local previous = _G["ShapeshiftButton"..i-1]
					button:SetPoint("LEFT", previous, "RIGHT", ElvDB.petbuttonspacing, 0)
				end
			else
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", ElvuiShift, 0, 0)
				else
					local previous = _G["ShapeshiftButton"..i-1]
					button:SetPoint("TOP", previous, "BOTTOM", 0, -ElvDB.petbuttonspacing)
				end			
			end
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			end
		end
		RegisterStateDriver(self, "visibility", States[ElvDB.myclass] or "hide")
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		-- Update Shapeshift Bar Button Visibility
		-- I seriously don't know if it's the best way to do it on spec changes or when we learn a new stance.
		if InCombatLockdown() then return end -- > just to be safe ;p
		local button
		for i = 1, NUM_SHAPESHIFT_SLOTS do
			button = _G["ShapeshiftButton"..i]
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			else
				button:Hide()
			end
		end
		ElvDB.ElvuiShiftBarUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		ElvDB.StyleShift()
	else
		ElvDB.ElvuiShiftBarUpdate()
	end
end)

if ElvCF["actionbar"].shapeshiftmouseover == true then
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local b = _G["ShapeshiftButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() ShapeShiftMouseOver(1) end)
		b:HookScript("OnLeave", function() ShapeShiftMouseOver(0) end)
	end
end