local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- Setup Shapeshift Bar
---------------------------------------------------------------------------
-- used for anchor totembar or shapeshiftbar
local ElvuiShift = CreateFrame("Frame","ElvuiShiftBar",ElvuiActionBarBackground)
if C["actionbar"].microbar == true then
	ElvuiShift:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 3, -38)
else
	ElvuiShift:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 2, -2)
end
ElvuiShift:SetWidth(200)
ElvuiShift:SetHeight(E.petbuttonsize)

if C["actionbar"].hideshapeshift == true then
	ElvuiShift:Hide()
end

E.CreateMover(ElvuiShift, "ShapeShiftMover", "Class Bar", true)

-- hide it if not needed and stop executing code
if C.actionbar.hideshapeshift then ElvuiShift:Hide() return end

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
			if C["actionbar"].verticalstance ~= true then
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", ElvuiShift, 0, 0)
				else
					local previous = _G["ShapeshiftButton"..i-1]
					button:SetPoint("LEFT", previous, "RIGHT", E.buttonspacing, 0)
				end
			else
				if i == 1 then
					button:SetPoint("BOTTOMLEFT", ElvuiShift, 0, 0)
				else
					local previous = _G["ShapeshiftButton"..i-1]
					button:SetPoint("TOP", previous, "BOTTOM", 0, -E.buttonspacing)
				end			
			end
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			end
		end
		RegisterStateDriver(self, "visibility", States[E.myclass] or "hide")
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
		E.ElvuiShiftBarUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		E.StyleShift()
	else
		E.ElvuiShiftBarUpdate()
	end
end)

if C["actionbar"].shapeshiftmouseover == true then
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local b = _G["ShapeshiftButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() ShapeShiftMouseOver(1) end)
		b:HookScript("OnLeave", function() ShapeShiftMouseOver(0) end)
	end
end