local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local AB = E:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0');
--/run E, C, L = unpack(ElvUI); AB = E:GetModule('ActionBars'); AB:ToggleMovers()

local Sticky = LibStub("LibSimpleSticky-1.0");
local _LOCK
local LAB = LibStub("LibActionButton-1.0")

local gsub = string.gsub
E.ActionBars = AB

AB["handledBars"] = {} --List of all bars
AB["handledbuttons"] = {} --List of all buttons that have been modified.
AB["movers"] = {} --List of all created movers.
E['snapBars'] = { E.UIParent }

function AB:Initialize()
	self.db = E.db.actionbar
	if E.global.actionbar.enable ~= true then return; end
	E.ActionBars = AB;
	
	self:DisableBlizzard()
	
	self:CreateActionBars()
	self:LoadKeyBinder()
	self:UpdateCooldownSettings()
	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:RegisterEvent('CVAR_UPDATE')
	self:ReassignBindings()
end

function AB:CreateActionBars()
	self:SetupExtraButton()
	for i=1, 5 do
		self['CreateBar'..i](self)
	end
	self:CreateBarPet()
	self:CreateBarShapeShift()
	self:CreateVehicleLeave()

	if E.myclass == "SHAMAN" then
		self:CreateTotemBar()
	end  
	
	self:UpdateButtonSettings()
end

function AB:PLAYER_REGEN_ENABLED()
	self:UpdateButtonSettings()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:CreateVehicleLeave()
	local vehicle = CreateFrame("Button", 'LeaveVehicleButton', E.UIParent, "SecureHandlerClickTemplate")
	vehicle:Size(26)
	vehicle:Point("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
	vehicle:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetHighlightTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
	vehicle:SetTemplate("Default")
	vehicle:RegisterForClicks("AnyUp")
	vehicle:SetScript("OnClick", function() VehicleExit() end)
	RegisterStateDriver(vehicle, "visibility", "[vehicleui] show;[target=vehicle,exists] show;hide")
end

function AB:ReassignBindings()
	if InCombatLockdown() then return end	
	for bar, _ in pairs(self["handledBars"]) do
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

function AB:UpdateButtonSettings()
	if E.global.actionbar.enable ~= true then return end
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	for button, _ in pairs(self["handledbuttons"]) do
		if button then
			self:StyleButton(button, button.noBackdrop)
			self:StyleFlyout(button)
		else
			self["handledbuttons"][button] = nil
		end
	end

	for i=1, 5 do
		self['PositionAndSizeBar'..i](self)
	end	
	self:PositionAndSizeBarPet()
	self:PositionAndSizeBarShapeShift()
	
	--Movers snap update
	for _, mover in pairs(AB['movers']) do
		mover.bar:SetScript("OnDragStart", function(mover) 
			if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
			
			if E.db.general.stickyFrames then
				local offset = 2
				local name = mover.name
				if name and self.db[name] and self.db[name].buttonspacing then
					offset = self.db[name].buttonspacing / 2
				end
				if mover.padding then offset = mover.padding end
				Sticky:StartMoving(mover, E['snapBars'], offset, offset, offset, offset)
			else
				mover:StartMoving()
			end
		end)	
	end
	
	for bar, barName in pairs(self["handledBars"]) do
		self:UpdateButtonConfig(bar, bar.bindButtons)
	end
end

function AB:CVAR_UPDATE(event)
	for bar, barName in pairs(self["handledBars"]) do
		self:UpdateButtonConfig(bar, bar.bindButtons)
	end
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

function AB:StyleButton(button, noBackdrop)	
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

	if flash then flash:SetTexture(nil); end
	if normal then normal:SetTexture(nil); normal:Hide(); normal:SetAlpha(0); end	
	if normal2 then normal2:SetTexture(nil); normal2:Hide(); normal2:SetAlpha(0); end	
	if border then border:Kill(); end
			
	if not button.noBackdrop then
		button.noBackdrop = noBackdrop;
	end
	
	if count then
		count:ClearAllPoints();
		count:SetPoint("BOTTOMRIGHT", 0, 2);
		count:FontTemplate(nil, 11, "OUTLINE");
	end

	if not button.noBackdrop and not button.backdrop then
		button:CreateBackdrop('Default', true)
		button.backdrop:SetAllPoints()
	end
	
	if icon then
		icon:SetTexCoord(unpack(E.TexCoords));
		icon:ClearAllPoints()
		icon:Point('TOPLEFT', 2, -2)
		icon:Point('BOTTOMRIGHT', -2, 2)
	end
	
	if shine then
		shine:SetAllPoints()
	end
	
	if self.db.hotkeytext then
		hotkey:FontTemplate(nil, E.db.actionbar.fontsize, "OUTLINE");
	end
	
	--Extra Action Button
	if button.style then
		button.style:SetParent(button.backdrop)
		button.style:SetDrawLayer('BACKGROUND', -7)	
	end
	
	button.FlyoutUpdateFunc = AB.StyleFlyout
	self:FixKeybindText(button);
	button:StyleButton();
	self["handledbuttons"][button] = true;
end

function AB:Bar_OnEnter(bar)
	UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), 1)
end

function AB:Bar_OnLeave(bar)
	UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), 1)
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
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

		_G['BonusActionButton'..i]:Hide()
		_G['BonusActionButton'..i]:UnregisterAllEvents()
		_G['BonusActionButton'..i]:SetAttribute("statehidden", true)
		
		if E.myclass ~= 'SHAMAN' then
			_G['MultiCastActionButton'..i]:Hide()
			_G['MultiCastActionButton'..i]:UnregisterAllEvents()
			_G['MultiCastActionButton'..i]:SetAttribute("statehidden", true)
		end
	end
	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil
	
	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:Hide()
	MainMenuBar:SetParent(UIHider)

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIHider)

	ShapeshiftBarFrame:UnregisterAllEvents()
	ShapeshiftBarFrame:Hide()
	ShapeshiftBarFrame:SetParent(UIHider)

	BonusActionBarFrame:UnregisterAllEvents()
	BonusActionBarFrame:Hide()
	BonusActionBarFrame:SetParent(UIHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIHider)
	
	VehicleMenuBar:UnregisterAllEvents()
	VehicleMenuBar:Hide()
	VehicleMenuBar:SetParent(UIHider)
	
	if E.myclass ~= 'SHAMAN' then
		MultiCastActionBarFrame:UnregisterAllEvents()
		MultiCastActionBarFrame:Hide()
		MultiCastActionBarFrame:SetParent(UIHider)
	end

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end
	
	ActionBarButtonEventsFrame:UnregisterAllEvents()
	ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	ActionBarButtonEventsFrame:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
	ActionBarActionEventsFrame:UnregisterAllEvents()
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return; end
	if not bar.buttonConfig then bar.buttonConfig = { hideElements = {} } end
	bar.buttonConfig.hideElements.macro = self.db.macrotext
	bar.buttonConfig.hideElements.hotkey = self.db.hotkeytext
	bar.buttonConfig.showGrid = GetCVar('alwaysShowActionBars') == '1' and true or false
	bar.buttonConfig.clickOnDown = GetCVar('ActionButtonUseKeyDown') == '1' and true or false

	for i, button in pairs(bar.buttons) do
		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", GetCVar('lockActionBars') == '1' and true or false)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		
		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey'];
	local text = hotkey:GetText();
	
	if text then
		text = gsub(text, 'SHIFT%-', L['KEY_SHIFT']);
		text = gsub(text, 'ALT%-', L['KEY_ALT']);
		text = gsub(text, 'CTRL%-', L['KEY_CTRL']);
		text = gsub(text, 'BUTTON', L['KEY_MOUSEBUTTON']);
		text = gsub(text, 'MOUSEWHEELUP', L['KEY_MOUSEWHEELUP']);
		text = gsub(text, 'MOUSEWHEELDOWN', L['KEY_MOUSEWHEELDOWN']);
		text = gsub(text, 'NUMPAD', L['KEY_NUMPAD']);
		text = gsub(text, 'PAGEUP', L['KEY_PAGEUP']);
		text = gsub(text, 'PAGEDOWN', L['KEY_PAGEDOWN']);
		text = gsub(text, 'SPACE', L['KEY_SPACE']);
		text = gsub(text, 'INSERT', L['KEY_INSERT']);
		text = gsub(text, 'HOME', L['KEY_HOME']);
		text = gsub(text, 'DELETE', L['KEY_DELETE']);
		text = gsub(text, 'MOUSEWHEELUP', L['KEY_MOUSEWHEELUP']);
		text = gsub(text, 'MOUSEWHEELDOWN', L['KEY_MOUSEWHEELDOWN']);

		hotkey:SetText(text);
	end
	
	hotkey:ClearAllPoints()
	hotkey:Point("TOPRIGHT", 0, -3);  
end

function AB:ToggleMovers(move)
	if InCombatLockdown() then return end
	if move then
		for name, _ in pairs(self.movers) do
			local mover = self.movers[name].bar
			mover:Show()
		end
		_LOCK = true
	else
		for name, _ in pairs(self.movers) do
			local mover = self.movers[name].bar
			mover:Hide()
		end
		_LOCK = nil
	end
end

function AB:ResetMovers(...)
	local bar = ...
	for name, _ in pairs(self.movers) do
		local mover = self.movers[name].bar
		if bar == '' then
			mover:ClearAllPoints()
			mover:Point(self.movers[name]["p"], self.movers[name]["p2"], self.movers[name]["p3"], self.movers[name]["p4"], self.movers[name]["p5"])
			
			if self.db[name] then
				self.db[name]['position'] = nil		
			end
		elseif bar == mover.textString then
			mover:ClearAllPoints()
			mover:Point(self.movers[name]["p"], self.movers[name]["p2"], self.movers[name]["p3"], self.movers[name]["p4"], self.movers[name]["p5"])
			
			if self.db[name] then
				self.db[name]['position'] = nil
			end
		end
	end
end

function AB:SetMoverPositions()
	if E.global.actionbar.enable ~= true then return end
	for name, _ in pairs(self.movers) do
		local f = self.movers[name].bar
		if f and self.db[name] and self.db[name]['position'] then
			f:ClearAllPoints()
			f:SetPoint(self.db[name]["position"].p, UIParent, self.db[name]["position"].p2, self.db[name]["position"].p3, self.db[name]["position"].p4)
		elseif f then
			f:ClearAllPoints()
			f:Point(self.movers[name]["p"], self.movers[name]["p2"], self.movers[name]["p3"], self.movers[name]["p4"], self.movers[name]["p5"])		
		end	
	end
end

function AB:CreateMover(bar, text, name, padding)
	local p, p2, p3, p4, p5 = bar:GetPoint()

	local mover = CreateFrame('Button', nil, E.UIParent)
	mover:SetSize(bar:GetSize())
	mover:SetFrameStrata('HIGH')
	mover:SetTemplate('Default', true)	
	mover.name = name
	tinsert(E['snapBars'], mover)
	
	if self.movers[name] == nil then 
		self.movers[name] = {}
		self.movers[name]["bar"] = mover
		self.movers[name]["p"] = p
		self.movers[name]["p2"] = p2 or UIParent
		self.movers[name]["p3"] = p3
		self.movers[name]["p4"] = p4
		self.movers[name]["p5"] = p5
	end	

	if self.db and self.db[name] and self.db[name]["position"] then
		mover:SetPoint(self.db[name]["position"].p, UIParent, self.db[name]["position"].p2, self.db[name]["position"].p3, self.db[name]["position"].p4)
	else
		mover:SetPoint(p, p2, p3, p4, p5)
	end
	
	mover.padding = padding
	mover:RegisterForDrag("LeftButton", "RightButton")
	mover:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		if E.db.general.stickyFrames then
			local offset = AB.db[name].buttonspacing/2
			if padding then offset = padding end
			Sticky:StartMoving(self, E['snapBars'], offset, offset, offset, offset)
		else
			self:StartMoving()
		end
	end)

	mover:SetScript("OnDragStop", function(frame) 
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		if E.db.general.stickyFrames then
			Sticky:StopMoving(frame)
		else
			frame:StopMovingOrSizing()
		end
		
		if self.db[name] == nil then self.db[name] = {} end
		if self.db[name]['position'] == nil then self.db[name]['position'] = {} end
		
		self.db[name]['position'] = {}
		
		local p, _, p2, p3, p4 = frame:GetPoint()
		self.db[name]['position']["p"] = p
		self.db[name]['position']["p2"] = p2
		self.db[name]['position']["p3"] = p3
		self.db[name]['position']["p4"] = p4
		AB:UpdateButtonSettings()
		
		frame:SetUserPlaced(false)
	end)	
	
	bar:ClearAllPoints()
	bar:SetPoint(p3, mover, p3, 0, 0)

	local fs = mover:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate()
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(unpack(E["media"].rgbvaluecolor))
	mover:SetFontString(fs)
	mover.text = fs
	mover.textString = text
	
	mover:SetScript("OnEnter", function(self) 
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
	end)
	mover:SetScript("OnLeave", function(self)
		self.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
		self:SetTemplate("Default", true)
	end)
	
	mover:RegisterEvent('PLAYER_REGEN_DISABLED')
	mover:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
		end
	end)
	
	mover:SetMovable(true)
	mover:Hide()	
	bar.mover = mover
end


local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max ammount of buttons
		if _G["SpellFlyoutButton"..i] then
			AB:StyleButton(_G["SpellFlyoutButton"..i])
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
SpellFlyout:HookScript("OnShow", SetupFlyoutButton)


function AB:StyleFlyout(button)
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
			buttons = numSlots
			break
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

E:RegisterModule(AB:GetName())