local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0');
--/run E, C, L = unpack(ElvUI); AB = E:GetModule('ActionBars'); AB:ToggleMovers()

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
local ceil = math.ceil
local format, gsub, split, strfind = string.format, string.gsub, string.split, strfind
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitOnTaxi = UnitOnTaxi
local VehicleExit = VehicleExit
local PetDismiss = PetDismiss
local CanExitVehicle = CanExitVehicle
local ActionBarController_GetCurrentActionBarState = ActionBarController_GetCurrentActionBarState
local TaxiRequestEarlyLanding = TaxiRequestEarlyLanding
local MainMenuBarVehicleLeaveButton_OnEnter = MainMenuBarVehicleLeaveButton_OnEnter
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local GameTooltip_Hide = GameTooltip_Hide
local InCombatLockdown = InCombatLockdown
local ClearOverrideBindings = ClearOverrideBindings
local GetBindingKey = GetBindingKey
local SetOverrideBindingClick = SetOverrideBindingClick
local SetClampedTextureRotation = SetClampedTextureRotation
local GetVehicleBarIndex = GetVehicleBarIndex
local GetOverrideBarIndex = GetOverrideBarIndex
local SetModifiedClick = SetModifiedClick
local GetNumFlyouts, GetFlyoutInfo = GetNumFlyouts, GetFlyoutInfo
local GetFlyoutID = GetFlyoutID
local GetMouseFocus = GetMouseFocus
local HasOverrideActionBar, HasVehicleActionBar = HasOverrideActionBar, HasVehicleActionBar
local GetCVarBool, SetCVar = GetCVarBool, SetCVar
local C_PetBattlesIsInBattle = C_PetBattles.IsInBattle
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local LE_ACTIONBAR_STATE_MAIN = LE_ACTIONBAR_STATE_MAIN

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LeaveVehicleButton, Minimap, SpellFlyout, SpellFlyoutHorizontalBackground
-- GLOBALS: SpellFlyoutVerticalBackground, IconIntroTracker, MultiCastActionBarFrame
-- GLOBALS: PetActionBarFrame, PossessBarFrame, OverrideActionBar, StanceBarFrame
-- GLOBALS: MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight
-- GLOBALS: ActionBarController, MainMenuBar, MainMenuExpBar, ReputationWatchBar
-- GLOBALS: MainMenuBarArtFrame, InterfaceOptionsCombatPanelActionButtonUseKeyDown
-- GLOBALS: InterfaceOptionsActionBarsPanelAlwaysShowActionBars
-- GLOBALS: InterfaceOptionsActionBarsPanelBottomRight, InterfaceOptionsActionBarsPanelBottomLeft
-- GLOBALS: InterfaceOptionsActionBarsPanelRight, InterfaceOptionsActionBarsPanelRightTwo
-- GLOBALS: InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton
-- GLOBALS: InterfaceOptionsActionBarsPanelLockActionBars
-- GLOBALS: InterfaceOptionsActionBarsPanelPickupActionKeyDropDown
-- GLOBALS: InterfaceOptionsStatusTextPanelXP
-- GLOBALS: PlayerTalentFrame, SpellFlyoutBackgroundEnd

local Sticky = LibStub("LibSimpleSticky-1.0");
local _LOCK
local LAB = LibStub("LibActionButton-1.0-ElvUI")
local LSM = LibStub("LibSharedMedia-3.0")

local Masque = LibStub("Masque", true)
local MasqueGroup = Masque and Masque:Group("ElvUI", "ActionBars")

AB.RegisterCooldown = E.RegisterCooldown

E.ActionBars = AB
AB["handledBars"] = {} --List of all bars
AB["handledbuttons"] = {} --List of all buttons that have been modified.
AB["barDefaults"] = {
	["bar1"] = {
		['page'] = 1,
		['bindButtons'] = "ACTIONBUTTON",
		['conditions'] = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex()),
		['position'] = "BOTTOM,ElvUIParent,BOTTOM,0,4",
	},
	["bar2"] = {
		['page'] = 5,
		['bindButtons'] = "MULTIACTIONBAR2BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,ElvUI_Bar1,TOP,0,2",
	},
	["bar3"] = {
		['page'] = 6,
		['bindButtons'] = "MULTIACTIONBAR1BUTTON",
		['conditions'] = "",
		['position'] = "LEFT,ElvUI_Bar1,RIGHT,4,0",
	},
	["bar4"] = {
		['page'] = 4,
		['bindButtons'] = "MULTIACTIONBAR4BUTTON",
		['conditions'] = "",
		['position'] = "RIGHT,ElvUIParent,RIGHT,-4,0",
	},
	["bar5"] = {
		['page'] = 3,
		['bindButtons'] = "MULTIACTIONBAR3BUTTON",
		['conditions'] = "",
		['position'] = "RIGHT,ElvUI_Bar1,LEFT,-4,0",
	},
	["bar6"] = {
		['page'] = 2,
		['bindButtons'] = "ELVUIBAR6BUTTON",
		['conditions'] = "",
		['position'] = "BOTTOM,ElvUI_Bar2,TOP,0,2",
	},
}

AB.customExitButton = {
	func = function(button)
		if UnitExists('vehicle') then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = "Interface\\Icons\\Spell_Shadow_SacrificialShield",
	tooltip = LEAVE_VEHICLE,
}

function AB:PositionAndSizeBar(barName)
	local spacing = E:Scale(self.db[barName].buttonspacing);
	local buttonsPerRow = self.db[barName].buttonsPerRow;
	local numButtons = self.db[barName].buttons;
	local size = E:Scale(self.db[barName].buttonsize);
	local point = self.db[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db[barName].widthMult;
	local heightMult = self.db[barName].heightMult;
	local bar = self["handledBars"][barName]

	bar.db = self.db[barName]
	bar.db.position = nil; --Depreciated

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));

	bar.mouseover = self.db[barName].mouseover

	if self.db[barName].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end

	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	local button, lastButton, lastColumnButton ;
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		lastButton = bar.buttons[i-1];
		lastColumnButton = bar.buttons[i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size)
		button:SetAttribute("showgrid", 1);

		if self.db[barName].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');
			end

			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');
			end
		else
			bar:SetAlpha(self.db[barName].alpha);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end

			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');
				self:Unhook(button, 'OnLeave');
			end
		end

		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end

			button:Point(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if i > numButtons then
			button:Hide()
		else
			button:Show()
		end

		self:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars and true or nil);
		button:SetCheckedTexture("")
	end

	if self.db[barName].enabled or not bar.initialized then
		if not self.db[barName].mouseover then
			bar:SetAlpha(self.db[barName].alpha);
		end

		local page = self:GetPage(barName, self['barDefaults'][barName].page, self['barDefaults'][barName].conditions)
		if AB['barDefaults']['bar'..bar.id].conditions:find("[form,noform]") then
			bar:SetAttribute("hasTempBar", true)

			local newCondition = page
			newCondition = gsub(AB['barDefaults']['bar'..bar.id].conditions, " %[form,noform%] 0; ", "")
			bar:SetAttribute("newCondition", newCondition)
		else
			bar:SetAttribute("hasTempBar", false)
		end

		bar:Show()
		RegisterStateDriver(bar, "visibility", self.db[barName].visibility); -- this is ghetto
		RegisterStateDriver(bar, "page", page);

		if not bar.initialized then
			bar.initialized = true;
			AB:PositionAndSizeBar(barName)
			return
		end
	else
		bar:Hide()
		UnregisterStateDriver(bar, "visibility");
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, bar.db.buttonspacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then MasqueGroup:ReSkin() end
end

function AB:CreateBar(id)
	local bar = CreateFrame('Frame', 'ElvUI_Bar'..id, E.UIParent, 'SecureHandlerStateTemplate');
	local point, anchor, attachTo, x, y = split(',', self['barDefaults']['bar'..id].position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id
	bar:CreateBackdrop('Default');
	bar:SetFrameStrata("LOW")
	bar.backdrop:SetAllPoints();
	bar.buttons = {}
	bar.bindButtons = self['barDefaults']['bar'..id].bindButtons

	for i=1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 14 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end

		if i == 12 then
			bar.buttons[i]:SetState(12, "custom", AB.customExitButton)
		end
		
		if MasqueGroup and E.private.actionbar.masque.actionbars then
			bar.buttons[i]:AddToMasque(MasqueGroup)
		end
	end
	self:UpdateButtonConfig(bar, bar.bindButtons)

	if AB['barDefaults']['bar'..id].conditions:find("[form]") then
		bar:SetAttribute("hasTempBar", true)
	else
		bar:SetAttribute("hasTempBar", false)
	end

	bar:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar") then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		if newstate ~= 0 then
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		else
			local newCondition = self:GetAttribute("newCondition")
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			end
		end
	]]);


	self["handledBars"]['bar'..id] = bar;
	self:PositionAndSizeBar('bar'..id);
	E:CreateMover(bar, 'ElvAB_'..id, L["Bar "]..id, nil, nil, nil,'ALL,ACTIONBARS')
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

local function Vehicle_OnEvent(self, event)
	if ( CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN ) then
		self:Show()
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self:EnableMouse(true)
	else
		self:Hide()
	end
end

local function Vehicle_OnClick(self)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();
		self:GetNormalTexture():SetVertexColor(1, 0, 0)
		self:EnableMouse(false)
	else
		VehicleExit();
	end
end

function AB:UpdateVehicleLeave()
	local button = LeaveVehicleButton
	if not button then return; end
	
	local pos = E.db.general.minimap.icons.vehicleLeave.position or "BOTTOMLEFT"
	local size = E.db.general.minimap.icons.vehicleLeave.size or 26
	button:ClearAllPoints()
	button:SetPoint(pos, Minimap, pos, E.db.general.minimap.icons.vehicleLeave.xOffset or 2, E.db.general.minimap.icons.vehicleLeave.yOffset or 2)
	button:SetSize(size, size)
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", 'LeaveVehicleButton', E.UIParent)
	vehicle:Size(26)
	vehicle:Point("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
	vehicle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetTemplate("Default")
	vehicle:RegisterForClicks("AnyUp")

	vehicle:SetScript("OnClick", Vehicle_OnClick)
	vehicle:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	vehicle:SetScript("OnLeave", GameTooltip_Hide)
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD");
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE");
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE");
	vehicle:RegisterEvent("VEHICLE_UPDATE");
	vehicle:SetScript("OnEvent", Vehicle_OnEvent)
	
	self:UpdateVehicleLeave()

	vehicle:Hide()
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		self:UpdatePetBindings();
		self:UpdateStanceBindings();
	end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end
	for _, bar in pairs(self["handledBars"]) do
		if not bar then return end

		ClearOverrideBindings(bar)
		for i = 1, #bar.buttons do
			local button = (bar.bindButtons.."%d"):format(i)
			local real_button = (bar:GetName().."Button%d"):format(i)
			for k=1, select('#', GetBindingKey(button)) do
				local key = select(k, GetBindingKey(button))
				if key and key ~= "" then
					SetOverrideBindingClick(bar, false, key, real_button)
				end
			end
		end
	end
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end
	for _, bar in pairs(self["handledBars"]) do
		if not bar then return end

		ClearOverrideBindings(bar)
	end

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end

function AB:UpdateBar1Paging()
	if self.db.bar6.enabled then
		E.ActionBars.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	else
		E.ActionBars.barDefaults.bar1.conditions = format("[vehicleui] %d; [possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex())
	end

	if (E.private.actionbar.enable ~= true or InCombatLockdown()) or not self.isInitialized then return; end
	local bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local bar5Option = InterfaceOptionsActionBarsPanelRight

	if (self.db.bar2.enabled and not bar2Option:GetChecked()) or (not self.db.bar2.enabled and bar2Option:GetChecked())  then
		bar2Option:Click()
	end

	if (self.db.bar3.enabled and not bar3Option:GetChecked()) or (not self.db.bar3.enabled and bar3Option:GetChecked())  then
		bar3Option:Click()
	end

	if not self.db.bar5.enabled and not self.db.bar4.enabled then
		if bar4Option:GetChecked() then
			bar4Option:Click()
		end

		if bar5Option:GetChecked() then
			bar5Option:Click()
		end
	elseif not self.db.bar5.enabled then
		if not bar5Option:GetChecked() then
			bar5Option:Click()
		end

		if not bar4Option:GetChecked() then
			bar4Option:Click()
		end
	elseif (self.db.bar4.enabled and not bar4Option:GetChecked()) or (not self.db.bar4.enabled and bar4Option:GetChecked()) then
		bar4Option:Click()
	elseif (self.db.bar5.enabled and not bar5Option:GetChecked()) or (not self.db.bar5.enabled and bar5Option:GetChecked()) then
		bar5Option:Click()
	end
end

function AB:UpdateButtonSettings()
	if E.private.actionbar.enable ~= true then return end
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	
	for button, _ in pairs(self["handledbuttons"]) do
		if button then
			self:StyleButton(button, button.noBackdrop, button.useMasque)
			self:StyleFlyout(button)
		else
			self["handledbuttons"][button] = nil
		end
	end

	self:UpdatePetBindings()
	self:UpdateStanceBindings()
	for barName, bar in pairs(self["handledBars"]) do
		self:UpdateButtonConfig(bar, bar.bindButtons)
	end
	
	for i=1, 6 do
		self:PositionAndSizeBar('bar'..i)
	end
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = self.db[bar]['paging'][E.myclass]
	if not condition then condition = '' end
	if not page then page = '' end
	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage

	return condition
end

function AB:StyleButton(button, noBackdrop, useMasque)
	local name = button:GetName();
	local icon = _G[name.."Icon"];
	local count = _G[name.."Count"];
	local flash	 = _G[name.."Flash"];
	local hotkey = _G[name.."HotKey"];
	local border  = _G[name.."Border"];
	local macroName = _G[name.."Name"];
	local normal  = _G[name.."NormalTexture"];
	local normal2 = button:GetNormalTexture()
	local shine = _G[name.."Shine"];
	local combat = InCombatLockdown()

	if not button.noBackdrop then
		button.noBackdrop = noBackdrop;
	end
	
	if not button.useMasque then
		button.useMasque = useMasque;
	end

	if flash then flash:SetTexture(nil); end
	if normal then normal:SetTexture(nil); normal:Hide(); normal:SetAlpha(0); end
	if normal2 then normal2:SetTexture(nil); normal2:Hide(); normal2:SetAlpha(0); end
	
	if border and not button.useMasque then
		border:Kill();
	end

	if count then
		count:ClearAllPoints();
		count:SetPoint("BOTTOMRIGHT", 0, 2);
		count:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop('Default', true)
		button.backdrop:SetAllPoints()
	end
	
	if icon then
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if self.db.hotkeytext then
		hotkey:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end

	--Extra Action Button
	if button.style then
		--button.style:SetParent(button.backdrop)
		button.style:SetDrawLayer('BACKGROUND', -7)
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	self:FixKeybindText(button);
	
	if not button.useMasque then
		button:StyleButton();
	else
		button:StyleButton(true, true, true)
	end

	if(not self.handledbuttons[button]) then
		E:RegisterCooldown(button.cooldown)

		self.handledbuttons[button] = true;
	end
end

function AB:Bar_OnEnter(bar)
	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
end

function AB:Bar_OnLeave(bar)
	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetFormattedText(L["Remove Bar %d Action Page"], 2)
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetFormattedText(L["Remove Bar %d Action Page"], 3)
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetFormattedText(L["Remove Bar %d Action Page"], 4)
	InterfaceOptionsActionBarsPanelRight.Text:SetFormattedText(L["Remove Bar %d Action Page"], 5)

	InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter', nil)
	InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter', nil)
end

function AB:DisableBlizzard()
	-- Hidden parent frame
	local UIHider = CreateFrame("Frame")
	UIHider:Hide()

	MultiBarBottomLeft:SetParent(UIHider)
	MultiBarBottomRight:SetParent(UIHider)
	MultiBarLeft:SetParent(UIHider)
	MultiBarRight:SetParent(UIHider)

	-- Hide MultiBar Buttons, but keep the bars alive
	for i=1,12 do
		_G["ActionButton" .. i]:Hide()
		_G["ActionButton" .. i]:UnregisterAllEvents()
		_G["ActionButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomLeftButton" .. i]:Hide()
		_G["MultiBarBottomLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomLeftButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarBottomRightButton" .. i]:Hide()
		_G["MultiBarBottomRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarBottomRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarRightButton" .. i]:Hide()
		_G["MultiBarRightButton" .. i]:UnregisterAllEvents()
		_G["MultiBarRightButton" .. i]:SetAttribute("statehidden", true)

		_G["MultiBarLeftButton" .. i]:Hide()
		_G["MultiBarLeftButton" .. i]:UnregisterAllEvents()
		_G["MultiBarLeftButton" .. i]:SetAttribute("statehidden", true)

		if _G["VehicleMenuBarActionButton" .. i] then
			_G["VehicleMenuBarActionButton" .. i]:Hide()
			_G["VehicleMenuBarActionButton" .. i]:UnregisterAllEvents()
			_G["VehicleMenuBarActionButton" .. i]:SetAttribute("statehidden", true)
		end

		if _G['OverrideActionBarButton'..i] then
			_G['OverrideActionBarButton'..i]:Hide()
			_G['OverrideActionBarButton'..i]:UnregisterAllEvents()
			_G['OverrideActionBarButton'..i]:SetAttribute("statehidden", true)
		end

		_G['MultiCastActionButton'..i]:Hide()
		_G['MultiCastActionButton'..i]:UnregisterAllEvents()
		_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIHider)

	for i=1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(UIHider)
		end
	end

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIHider)

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIHider)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(UIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)

	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(UIHider)

	--This frame puts spells on the damn actionbar, fucking obliterate that shit
	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(UIHider)

	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001)
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)
	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.00001)
	self:SecureHook('BlizzardOptionsPanel_OnEvent')
	--InterfaceOptionsFrameCategoriesButton6:SetScale(0.00001)
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	if not bar.buttonConfig then bar.buttonConfig = { hideElements = {}, colors = {} } end
	bar.buttonConfig.hideElements.macro = not self.db.macrotext
	bar.buttonConfig.hideElements.hotkey = not self.db.hotkeytext
	bar.buttonConfig.showGrid = self.db.showGrid
	bar.buttonConfig.clickOnDown = self.db.keyDown
	SetModifiedClick("PICKUPACTION", self.db.movementModifier)
	bar.buttonConfig.colors.range = E:GetColorTable(self.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:GetColorTable(self.db.noPowerColor)
	bar.buttonConfig.colors.hp = E:GetColorTable(self.db.noPowerColor)

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", true)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey'];
	local text = hotkey:GetText();

	if text then
		text = gsub(text, 'SHIFT%-', L["KEY_SHIFT"]);
		text = gsub(text, 'ALT%-', L["KEY_ALT"]);
		text = gsub(text, 'CTRL%-', L["KEY_CTRL"]);
		text = gsub(text, 'BUTTON', L["KEY_MOUSEBUTTON"]);
		text = gsub(text, 'MOUSEWHEELUP', L["KEY_MOUSEWHEELUP"]);
		text = gsub(text, 'MOUSEWHEELDOWN', L["KEY_MOUSEWHEELDOWN"]);
		text = gsub(text, 'NUMPAD', L["KEY_NUMPAD"]);
		text = gsub(text, 'PAGEUP', L["KEY_PAGEUP"]);
		text = gsub(text, 'PAGEDOWN', L["KEY_PAGEDOWN"]);
		text = gsub(text, 'SPACE', L["KEY_SPACE"]);
		text = gsub(text, 'INSERT', L["KEY_INSERT"]);
		text = gsub(text, 'HOME', L["KEY_HOME"]);
		text = gsub(text, 'DELETE', L["KEY_DELETE"]);
		text = gsub(text, 'NMULTIPLY', "*");
		text = gsub(text, 'NMINUS', "N-");
		text = gsub(text, 'NPLUS', "N+");

		hotkey:SetText(text);
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:SetPoint("TOPRIGHT", 0, -3);
	end
end

local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max amount of buttons
		if _G["SpellFlyoutButton"..i] then
			AB:StyleButton(_G["SpellFlyoutButton"..i], nil, MasqueGroup and E.private.actionbar.masque.actionbars and true or nil)
			_G["SpellFlyoutButton"..i]:StyleButton()
			_G["SpellFlyoutButton"..i]:HookScript('OnEnter', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB["handledbuttons"][parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				if parentAnchorBar.mouseover then
					AB:Bar_OnEnter(parentAnchorBar)
				end
			end)
			_G["SpellFlyoutButton"..i]:HookScript('OnLeave', function(self)
				local parent = self:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB["handledbuttons"][parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()

				if parentAnchorBar.mouseover then
					AB:Bar_OnLeave(parentAnchorBar)
				end
			end)
			
			if MasqueGroup and E.private.actionbar.masque.actionbars then
				MasqueGroup:RemoveButton(_G["SpellFlyoutButton"..i]) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
				MasqueGroup:AddButton(_G["SpellFlyoutButton"..i])
			end
		end
	end

	SpellFlyout:HookScript('OnEnter', function(self)
		local anchorButton = select(2, self:GetPoint())
		if not AB["handledbuttons"][anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		if parentAnchorBar.mouseover then
			AB:Bar_OnEnter(parentAnchorBar)
		end
	end)

	SpellFlyout:HookScript('OnLeave', function(self)
		local anchorButton = select(2, self:GetPoint())
		if not AB["handledbuttons"][anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		if parentAnchorBar.mouseover then
			AB:Bar_OnLeave(parentAnchorBar)
		end
	end)
end

function AB:StyleFlyout(button)
	if(not button.FlyoutArrow or not button.FlyoutArrow:IsShown()) then return end

	if not LAB.buttonRegistry[button] then return end
	if not button.FlyoutBorder then return end
	local combat = InCombatLockdown()

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i=1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			if numSlots > buttons then
				buttons = numSlots
			end
		end
	end

	--Change arrow direction depending on what bar the button is on
	local arrowDistance
	if ((SpellFlyout:IsShown() and SpellFlyout:GetParent() == button) or GetMouseFocus() == button) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end

	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then
		return
	end

	if button:GetParent() then
		local point = E:GetScreenQuadrant(button:GetParent())
		if point == "UNKNOWN" then return end

		if strfind(point, "TOP") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not combat then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif point == "RIGHT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not combat then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif point == "LEFT" then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not combat then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif point == "CENTER" or strfind(point, "BOTTOM") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not combat then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

function AB:VehicleFix()
	local barName = 'bar1'
	local bar = self["handledBars"][barName]
	local spacing = E:Scale(self.db[barName].buttonspacing);
	local numButtons = self.db[barName].buttons;
	local buttonsPerRow = self.db[barName].buttonsPerRow;
	local size = E:Scale(self.db[barName].buttonsize);
	local point = self.db[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);

	if (HasOverrideActionBar() or HasVehicleActionBar()) and numButtons == 12 then
		local widthMult = 1;
		local heightMult = 1;

		bar.backdrop:ClearAllPoints()
		bar.backdrop:SetPoint(self.db[barName].point, bar, self.db[barName].point)
		bar.backdrop:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
		bar.backdrop:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	else
		bar.backdrop:SetAllPoints()
	end
end

function AB:Initialize()
	self.db = E.db.actionbar
	if E.private.actionbar.enable ~= true then return; end
	E.ActionBars = AB;

	self:DisableBlizzard()

	self:SetupExtraButton()
	self:SetupMicroBar()
	self:UpdateBar1Paging()

	for i=1, 6 do
		self:CreateBar(i)
	end
	self:CreateBarPet()
	self:CreateBarShapeShift()
	self:CreateVehicleLeave()

	self:UpdateButtonSettings()

	self:LoadKeyBinder()
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:RegisterEvent("PET_BATTLE_CLOSE", "ReassignBindings")
	self:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')
	self:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR', 'VehicleFix')
	self:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR', 'VehicleFix')

	if C_PetBattlesIsInBattle() then
		self:RemoveBindings()
	else
		self:ReassignBindings()
	end

	if not GetCVarBool('lockActionBars') then
		SetCVar('lockActionBars', 1)
	end

	SpellFlyout:HookScript("OnShow", SetupFlyoutButton)
end

E:RegisterModule(AB:GetName())