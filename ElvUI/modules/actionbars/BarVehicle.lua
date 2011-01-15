if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- Setup Vehicle Bar
---------------------------------------------------------------------------

local vbar = CreateFrame("Frame", "ElvuiVehicleBar", ElvuiVehicleBarBackground, "SecureHandlerStateTemplate")
vbar:ClearAllPoints()
vbar:SetAllPoints(ElvuiVehicleBarBackground)

vbar:RegisterEvent("UNIT_ENTERED_VEHICLE")
vbar:RegisterEvent("UNIT_DISPLAYPOWER")
vbar:RegisterEvent("PLAYER_LOGIN")
vbar:RegisterEvent("PLAYER_ENTERING_WORLD")
vbar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, VEHICLE_MAX_ACTIONBUTTONS do
			button = _G["VehicleMenuBarActionButton"..i]
			self:SetFrameRef("VehicleMenuBarActionButton"..i, button)
		end	
		
		self:SetAttribute("_onstate-vehicleupdate", [[
			if newstate == "s1" then
				self:GetParent():Show()
			else
				self:GetParent():Hide()
			end
		]])
		
		RegisterStateDriver(self, "vehicleupdate", "[vehicleui]s1;s2")
	elseif event == "PLAYER_ENTERING_WORLD" then
		local button
		for i = 1, VEHICLE_MAX_ACTIONBUTTONS do
			button = _G["VehicleMenuBarActionButton"..i]
			button:SetSize(ElvDB.buttonsize*1.2, ElvDB.buttonsize*1.2)
			button:ClearAllPoints()
			button:SetParent(ElvuiVehicleBar)
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", ElvuiVehicleBar, ElvDB.buttonspacing*1.2, ElvDB.buttonspacing*1.2)
			else
				local previous = _G["VehicleMenuBarActionButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", ElvDB.buttonspacing*1.2, 0)
			end
		end
	else
		VehicleMenuBar_OnEvent(self, event, ...)
	end
end)

--Create our custom Vehicle Button Hotkeys, because blizzard is fucking gay and won't let us reposition the default ones
do
	for i=1, VEHICLE_MAX_ACTIONBUTTONS do
		_G["ElvuiVehicleHotkey"..i] = _G["VehicleMenuBarActionButton"..i]:CreateFontString("ElvuiVehicleHotkey"..i, "OVERLAY", nil)
		_G["ElvuiVehicleHotkey"..i]:ClearAllPoints()
		_G["ElvuiVehicleHotkey"..i]:SetPoint("TOPRIGHT", 0, ElvDB.Scale(-3))
		_G["ElvuiVehicleHotkey"..i]:SetFont(ElvCF["media"].font, 14, "OUTLINE")
		_G["ElvuiVehicleHotkey"..i].ClearAllPoints = ElvDB.dummy
		_G["ElvuiVehicleHotkey"..i].SetPoint = ElvDB.dummy
		
		if not ElvCF["actionbar"].hotkey == true then
			_G["ElvuiVehicleHotkey"..i]:SetText("")
			_G["ElvuiVehicleHotkey"..i]:Hide()
			_G["ElvuiVehicleHotkey"..i].Show = ElvDB.dummy
		else
			_G["ElvuiVehicleHotkey"..i]:SetText(_G["VehicleMenuBarActionButton"..i.."HotKey"]:GetText())
		end
	end
end

local UpdateVehHotkeys = function()
	if not UnitHasVehicleUI("player") then return end
	if ElvCF["actionbar"].hotkey ~= true then return end
	for i=1, VEHICLE_MAX_ACTIONBUTTONS do
		_G["ElvuiVehicleHotkey"..i]:SetText(_G["VehicleMenuBarActionButton"..i.."HotKey"]:GetText())
		_G["ElvuiVehicleHotkey"..i]:SetTextColor(_G["VehicleMenuBarActionButton"..i.."HotKey"]:GetTextColor())
	end
end

local VehTextUpdate = CreateFrame("Frame")
VehTextUpdate:RegisterEvent("UNIT_ENTERING_VEHICLE")
VehTextUpdate:RegisterEvent("UNIT_ENTERED_VEHICLE")
VehTextUpdate:SetScript("OnEvent", UpdateVehHotkeys)

-- vehicle button under minimap
local vehicle = CreateFrame("Button", nil, UIParent, "SecureHandlerClickTemplate")
vehicle:SetWidth(ElvDB.Scale(26))
vehicle:SetHeight(ElvDB.Scale(26))
vehicle:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", ElvDB.Scale(2), ElvDB.Scale(2))
vehicle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
vehicle:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
vehicle:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
ElvDB.SetTemplate(vehicle)
vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", function() VehicleExit() end)
RegisterStateDriver(vehicle, "visibility", "[vehicleui][target=vehicle,noexists] hide;show")

-- vehicle on vehicle bar, dont need to have a state driver.. its parented to vehicle bar
local vehicle2 = CreateFrame("BUTTON", nil, ElvuiVehicleBarBackground, "SecureActionButtonTemplate")
vehicle2:SetWidth(ElvDB.buttonsize*1.2)
vehicle2:SetHeight(ElvDB.buttonsize*1.2)
vehicle2:SetPoint("RIGHT", ElvuiVehicleBarBackground, "RIGHT", -ElvDB.buttonspacing*1.2, 0)
vehicle2:RegisterForClicks("AnyUp")
vehicle2:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
vehicle2:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
vehicle2:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
ElvDB.SetTemplate(vehicle2)
vehicle2:SetScript("OnClick", function() VehicleExit() end)