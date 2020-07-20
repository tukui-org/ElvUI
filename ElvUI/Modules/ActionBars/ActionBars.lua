local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local ipairs, pairs, select = ipairs, pairs, select
local ceil, unpack = ceil, unpack
local format, gsub, strsplit, strfind = format, gsub, strsplit, strfind

local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetFlyoutID = GetFlyoutID
local GetMouseFocus = GetMouseFocus
local GetNumFlyouts, GetFlyoutInfo = GetNumFlyouts, GetFlyoutInfo
local GetOverrideBarIndex = GetOverrideBarIndex
local GetVehicleBarIndex = GetVehicleBarIndex
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local PetDismiss = PetDismiss
local RegisterStateDriver = RegisterStateDriver
local SetClampedTextureRotation = SetClampedTextureRotation
local SetCVar = SetCVar
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick
local UnitAffectingCombat = UnitAffectingCombat
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnregisterStateDriver = UnregisterStateDriver
local VehicleExit = VehicleExit
local SPELLS_PER_PAGE = SPELLS_PER_PAGE
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group("ElvUI", "ActionBars")

local hiddenParent = CreateFrame("Frame", nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

AB.RegisterCooldown = E.RegisterCooldown
AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = {
		page = 1,
		bindButtons = "ACTIONBUTTON",
		conditions = format("[overridebar] %d; [vehicleui] %d; [possessbar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetOverrideBarIndex(), GetVehicleBarIndex(), GetVehicleBarIndex()),
		position = 'BOTTOM,ElvUIParent,BOTTOM,-1,191',
	},
	bar2 = {
		page = 5,
		bindButtons = "MULTIACTIONBAR2BUTTON",
		conditions = "",
		position = 'BOTTOM,ElvUIParent,BOTTOM,0,4',
	},
	bar3 = {
		page = 6,
		bindButtons = "MULTIACTIONBAR1BUTTON",
		conditions = "",
		position = 'BOTTOM,ElvUIParent,BOTTOM,-1,139',
	},
	bar4 = {
		page = 4,
		bindButtons = "MULTIACTIONBAR4BUTTON",
		conditions = "",
		position = "RIGHT,ElvUIParent,RIGHT,-4,0",
	},
	bar5 = {
		page = 3,
		bindButtons = "MULTIACTIONBAR3BUTTON",
		conditions = "",
		position = 'BOTTOM,ElvUIParent,BOTTOM,-92,57',
	},
	bar6 = {
		page = 2,
		bindButtons = "ELVUIBAR6BUTTON",
		conditions = "",
		position = "BOTTOM,ElvUI_Bar2,TOP,0,2",
	},
	bar7 = {
		page = 7,
		bindButtons = 'EXTRABAR7BUTTON',
		conditions = '',
		position = 'BOTTOM,ElvUI_Bar1,TOP,0,82',
	},
	bar8 = {
		page = 8,
		bindButtons = 'EXTRABAR8BUTTON',
		conditions = '',
		position = 'BOTTOM,ElvUI_Bar1,TOP,0,122',
	},
	bar9 = {
		page = 9,
		bindButtons = 'EXTRABAR9BUTTON',
		conditions = '',
		position = 'BOTTOM,ElvUI_Bar1,TOP,0,162',
	},
	bar10 = {
		page = 10,
		bindButtons = 'EXTRABAR10BUTTON',
		conditions = '',
		position = 'BOTTOM,ElvUI_Bar1,TOP,0,202',
	},
}

AB.customExitButton = {
	func = function()
		if UnitExists('vehicle') then
			VehicleExit()
		else
			PetDismiss()
		end
	end,
	texture = [[Interface\Icons\Spell_Shadow_SacrificialShield]],
	tooltip = _G.LEAVE_VEHICLE,
}

function AB:PositionAndSizeBar(barName)
	local buttonSpacing = E:Scale(AB.db[barName].buttonspacing)
	local backdropSpacing = E:Scale((AB.db[barName].backdropSpacing or AB.db[barName].buttonspacing))
	local buttonsPerRow = AB.db[barName].buttonsPerRow
	local numButtons = AB.db[barName].buttons
	local size = E:Scale(AB.db[barName].buttonsize)
	local point = AB.db[barName].point
	local numColumns = ceil(numButtons / buttonsPerRow)
	local widthMult = AB.db[barName].widthMult
	local heightMult = AB.db[barName].heightMult
	local visibility = AB.db[barName].visibility
	local bar = AB.handledBars[barName]

	bar.db = AB.db[barName]
	bar.db.position = nil; --Depreciated

	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if numColumns < 1 then
		numColumns = 1
	end

	if bar.db.backdrop == true then
		bar.backdrop:Show()
	else
		bar.backdrop:Hide()
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local sideSpacing = (bar.db.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	--Size of all buttons + Spacing between all buttons + Spacing between additional rows of buttons + Spacing between backdrop and buttons + Spacing on end borders with non-thin borders
	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult - 1)) + (sideSpacing*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult - 1)) + (sideSpacing*2)
	bar:SetSize(barWidth, barHeight)

	bar.mouseover = bar.db.mouseover

	local horizontalGrowth, verticalGrowth
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN"
	else
		verticalGrowth = "UP"
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT"
	else
		horizontalGrowth = "LEFT"
	end

	if bar.db.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(bar.db.alpha)
	end

	if bar.db.inheritGlobalFade then
		bar:SetParent(AB.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	bar:EnableMouse(not bar.db.clickThrough)

	local button, lastButton, lastColumnButton
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i]
		lastButton = bar.buttons[i-1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:SetAttribute("showgrid", 1)
		button:Size(size)
		button:EnableMouse(not bar.db.clickThrough)

		if i == 1 then
			local x, y
			if point == "BOTTOMLEFT" then
				x, y = sideSpacing, sideSpacing
			elseif point == "TOPRIGHT" then
				x, y = -sideSpacing, -sideSpacing
			elseif point == "TOPLEFT" then
				x, y = sideSpacing, -sideSpacing
			else
				x, y = -sideSpacing, sideSpacing
			end

			button:Point(point, bar, point, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = "TOP", "BOTTOM"
			if verticalGrowth == 'UP' then
				y = buttonSpacing
				buttonPoint = "BOTTOM"
				anchorPoint = "TOP"
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, 0, y)
		else
			local x = buttonSpacing
			local buttonPoint, anchorPoint = "LEFT", "RIGHT"
			if horizontalGrowth == 'LEFT' then
				x = -buttonSpacing
				buttonPoint = "RIGHT"
				anchorPoint = "LEFT"
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, 0)
		end

		if i > numButtons then
			button:Hide()
		else
			button:Show()
		end

		AB:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars)
	end

	if bar.db.enabled or not bar.initialized then
		if not bar.db.mouseover then
			bar:SetAlpha(bar.db.alpha)
		end

		local page = AB:GetPage(barName, AB.barDefaults[barName].page, AB.barDefaults[barName].conditions)
		if AB.barDefaults['bar'..bar.id].conditions:find("[form,noform]") then
			bar:SetAttribute("hasTempBar", true)

			local newCondition = gsub(AB.barDefaults['bar'..bar.id].conditions, " %[form,noform%] 0; ", "")
			bar:SetAttribute("newCondition", newCondition)
		else
			bar:SetAttribute("hasTempBar", false)
		end

		bar:Show()
		RegisterStateDriver(bar, "visibility", visibility); -- this is ghetto
		RegisterStateDriver(bar, "page", page)
		bar:SetAttribute("page", page)

		if not bar.initialized then
			bar.initialized = true
			AB:PositionAndSizeBar(barName)
			return
		end
		E:EnableMover(bar.mover:GetName())
	else
		E:DisableMover(bar.mover:GetName())
		bar:Hide()
		UnregisterStateDriver(bar, "visibility")
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, bar.db.buttonspacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:ReSkin()
	end
end

function AB:CreateBar(id)
	local bar = CreateFrame('Frame', 'ElvUI_Bar'..id, E.UIParent, 'SecureHandlerStateTemplate')
	bar:SetFrameRef("MainMenuBarArtFrame", _G.MainMenuBarArtFrame)

	local point, anchor, attachTo, x, y = strsplit(',', AB.barDefaults['bar'..id].position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id
	bar:CreateBackdrop(AB.db.transparent and 'Transparent')
	bar:SetFrameStrata("LOW")

	--Use this method instead of :SetAllPoints, as the size of the mover would otherwise be incorrect
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", E.Spacing, -E.Spacing)
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -E.Spacing, E.Spacing)

	bar.buttons = {}
	bar.bindButtons = AB.barDefaults['bar'..id].bindButtons
	self:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	self:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	for i = 1, 12 do
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

		self:HookScript(bar.buttons[i], 'OnEnter', 'Button_OnEnter')
		self:HookScript(bar.buttons[i], 'OnLeave', 'Button_OnLeave')
	end
	AB:UpdateButtonConfig(bar, bar.bindButtons)

	if AB.barDefaults['bar'..id].conditions:find("[form]") then
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
			self:GetFrameRef("MainMenuBarArtFrame"):SetAttribute("actionpage", newstate) --Update MainMenuBarArtFrame too. See issue #1848
		else
			local newCondition = self:GetAttribute("newCondition")
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
				self:GetFrameRef("MainMenuBarArtFrame"):SetAttribute("actionpage", newstate)
			end
		end
	]])

	AB.handledBars['bar'..id] = bar
	E:CreateMover(bar, 'ElvAB_'..id, L["Bar "]..id, nil, nil, nil,'ALL,ACTIONBARS',nil,'actionbar,playerBars,bar'..id)
	AB:PositionAndSizeBar('bar'..id)
	return bar
end

function AB:PLAYER_REGEN_ENABLED()
	if AB.NeedsUpdateButtonSettings then
		AB:UpdateButtonSettings()
		AB.NeedsUpdateButtonSettings = nil
	end
	if AB.NeedsUpdateMicroBarVisibility then
		AB:UpdateMicroBarVisibility()
		AB.NeedsUpdateMicroBarVisibility = nil
	end
	if AB.NeedsAdjustMaxStanceButtons then
		AB:AdjustMaxStanceButtons(AB.NeedsAdjustMaxStanceButtons) --sometimes it holds the event, otherwise true. pass it before we nil it.
		AB.NeedsAdjustMaxStanceButtons = nil
	end
	AB:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if not db.enable then return end

	local holder = CreateFrame('Frame', 'VehicleLeaveButtonHolder', E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 300)
	holder:Size(_G.MainMenuBarVehicleLeaveButton:GetSize())
	E:CreateMover(holder, 'VehicleLeaveButton', L["VehicleLeaveButton"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,vehicleExitButton')

	local Button = _G.MainMenuBarVehicleLeaveButton
	Button:ClearAllPoints()
	Button:SetParent(_G.UIParent)
	Button:SetPoint('CENTER', holder, 'CENTER')

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		Button:StyleButton(true, true, true)
	else
		Button:CreateBackdrop(nil, true)
		Button:GetNormalTexture():SetTexCoord(0.140625 + .08, 0.859375 - .06, 0.140625 + .08, 0.859375 - .08)
		Button:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		Button:StyleButton(nil, true, true)
	end

	hooksecurefunc(Button, 'SetPoint', function(_, _, parent)
		if parent ~= holder then
			Button:ClearAllPoints()
			Button:SetParent(_G.UIParent)
			Button:SetPoint('CENTER', holder, 'CENTER')
		end
	end)

	hooksecurefunc(Button, 'SetHighlightTexture', function(btn, tex)
		if tex ~= btn.hover then
			Button:SetHighlightTexture(btn.hover)
		end
	end)

	AB:UpdateVehicleLeave()
end

function AB:UpdateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	_G.MainMenuBarVehicleLeaveButton:Size(db.size)
	_G.MainMenuBarVehicleLeaveButton:SetFrameStrata(db.strata)
	_G.MainMenuBarVehicleLeaveButton:SetFrameLevel(db.level)
	_G.VehicleLeaveButtonHolder:Size(db.size)
end

function AB:ReassignBindings(event)
	if event == "UPDATE_BINDINGS" then
		AB:UpdatePetBindings()
		AB:UpdateStanceBindings()
	end

	AB:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
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
end

function AB:RemoveBindings()
	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)
		end
	end

	AB:RegisterEvent("PLAYER_REGEN_DISABLED", "ReassignBindings")
end

function AB:UpdateBar1Paging()
	if AB.db.bar6.enabled then
		AB.barDefaults.bar1.conditions = format("[possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetOverrideBarIndex())
	else
		AB.barDefaults.bar1.conditions = format("[possessbar] %d; [overridebar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;", GetVehicleBarIndex(), GetOverrideBarIndex())
	end
end

function AB:UpdateButtonSettingsForBar(barName)
	local bar = AB.handledBars[barName]
	AB:UpdateButtonConfig(bar, bar.bindButtons)
end

function AB:UpdateButtonSettings()
	if not E.private.actionbar.enable then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	for button in pairs(AB.handledbuttons) do
		if button then
			AB:StyleButton(button, button.noBackdrop, button.useMasque, button.ignoreNormal)
			AB:StyleFlyout(button)
		else
			AB.handledbuttons[button] = nil
		end
	end

	AB:UpdatePetBindings()
	AB:UpdateStanceBindings()

	for barName, bar in pairs(AB.handledBars) do
		if bar then
			AB:UpdateButtonConfig(bar, bar.bindButtons)
			AB:PositionAndSizeBar(barName)
		end
	end

	AB:AdjustMaxStanceButtons()
	AB:PositionAndSizeBarPet()
	AB:PositionAndSizeBarShapeShift()
end

function AB:GetPage(bar, defaultPage, condition)
	local page = AB.db[bar].paging[E.myclass]
	if not condition then condition = '' end
	if not page then
		page = ''
	elseif page:match('[\n\r]') then
		page = page:gsub('[\n\r]','')
	end

	if page then
		condition = condition.." "..page
	end
	condition = condition.." "..defaultPage

	return condition
end

function AB:StyleButton(button, noBackdrop, useMasque, ignoreNormal)
	local name = button:GetName()
	local macroText = _G[name.."Name"]
	local icon = _G[name.."Icon"]
	local shine = _G[name.."Shine"]
	local count = _G[name.."Count"]
	local flash	 = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border  = _G[name.."Border"]
	local normal  = _G[name.."NormalTexture"]
	local normal2 = button:GetNormalTexture()

	local color = AB.db.fontColor
	local countPosition = AB.db.countTextPosition or 'BOTTOMRIGHT'
	local countXOffset = AB.db.countTextXOffset or 0
	local countYOffset = AB.db.countTextYOffset or 2

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	if normal and not ignoreNormal then normal:SetTexture(); normal:Hide(); normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture(); normal2:Hide(); normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if count then
		count:ClearAllPoints()
		count:Point(countPosition, countXOffset, countYOffset)
		count:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)
		count:SetTextColor(color.r, color.g, color.b)
	end

	if macroText then
		macroText:ClearAllPoints()
		macroText:Point("BOTTOM", 0, 1)
		macroText:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)
		macroText:SetTextColor(color.r, color.g, color.b)
	end

	if not button.noBackdrop and not button.backdrop and not button.useMasque then
		button:CreateBackdrop(AB.db.transparent and 'Transparent', true)
		button.backdrop:SetAllPoints()
	end

	if flash then
		if AB.db.flashAnimation then
			flash:SetColorTexture(1.0, 0.2, 0.2, 0.45)
			flash:ClearAllPoints()
			flash:SetOutside(icon, 2, 2)
			flash:SetDrawLayer("BACKGROUND", -1)
		else
			flash:SetTexture()
		end
	end

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if button.SpellHighlightTexture then
		button.SpellHighlightTexture:SetColorTexture(1, 1, 0, 0.45)
		button.SpellHighlightTexture:SetAllPoints()
	end

	if AB.db.hotkeytext or AB.db.useRangeColorText then
		hotkey:FontTemplate(LSM:Fetch("font", AB.db.font), AB.db.fontSize, AB.db.fontOutline)
		if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
			button.HotKey:SetTextColor(color.r, color.g, color.b)
		end
	end

	--Extra Action Button
	if button.style then
		button.style:SetDrawLayer('BACKGROUND', -7)
	end

	button.FlyoutUpdateFunc = AB.StyleFlyout
	AB:FixKeybindText(button)

	if not button.useMasque then
		button:StyleButton()
	else
		button:StyleButton(true, true, true)
	end

	if not AB.handledbuttons[button] then
		button.cooldown.CooldownOverride = 'actionbar'

		E:RegisterCooldown(button.cooldown)

		AB.handledbuttons[button] = true
	end
end

function AB:ColorSwipeTexture(cooldown)
	if not cooldown then return end

	local color = (cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and AB.db.colorSwipeLOC) or AB.db.colorSwipeNormal
	cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
end

function AB:FadeBlingTexture(cooldown, alpha)
	if not cooldown then return end
	cooldown:SetBlingTexture(alpha > 0.5 and 131010 or [[Interface\AddOns\ElvUI\Media\Textures\Blank]])  -- interface/cooldown/star4.blp
end

function AB:FadeBlings(alpha)
	if AB.db.hideCooldownBling then return end
	for button in pairs(AB.handledbuttons) do
		if button.header and button.header:GetParent() == AB.fadeParent then
			AB:FadeBlingTexture(button.cooldown, alpha)
		end
	end
end

function AB:FadeBarBlings(bar, alpha)
	if AB.db.hideCooldownBling then return end
	if bar.buttons then
		for _, button in ipairs(bar.buttons) do
			AB:FadeBlingTexture(button.cooldown, alpha)
		end
	end
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == AB.fadeParent then
		if(not AB.fadeParent.mouseLock) then
			E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	elseif(bar.mouseover) then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == AB.fadeParent then
		if not AB.fadeParent.mouseLock then
			local a = 1 - AB.db.globalFadeAlpha
			E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	elseif bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent then
		if not AB.fadeParent.mouseLock then
			E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
			AB:FadeBlings(1)
		end
	elseif bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent then
		if not AB.fadeParent.mouseLock then
			local a = 1 - AB.db.globalFadeAlpha
			E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	elseif bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function AB:BlizzardOptionsPanel_OnEvent()
	_G.InterfaceOptionsActionBarsPanelBottomRight.Text:SetFormattedText(L["Remove Bar %d Action Page"], 2)
	_G.InterfaceOptionsActionBarsPanelBottomLeft.Text:SetFormattedText(L["Remove Bar %d Action Page"], 3)
	_G.InterfaceOptionsActionBarsPanelRightTwo.Text:SetFormattedText(L["Remove Bar %d Action Page"], 4)
	_G.InterfaceOptionsActionBarsPanelRight.Text:SetFormattedText(L["Remove Bar %d Action Page"], 5)

	_G.InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter', nil)
	_G.InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter', nil)
end

function AB:FadeParent_OnEvent()
	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")
	local combat = UnitAffectingCombat("player")
	if (cast or channel) or (cur ~= max) or (target or focus) or combat then
		self.mouseLock = true
		E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		AB:FadeBlings(1)
	else
		self.mouseLock = false
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), a)
		AB:FadeBlings(a)
	end
end

function AB:IconIntroTracker_Toggle()
	local IconIntroTracker = _G.IconIntroTracker
	if AB.db.addNewSpells then
		IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
		UnregisterStateDriver(IconIntroTracker, 'visibility')
	else
		IconIntroTracker:UnregisterAllEvents()
		RegisterStateDriver(IconIntroTracker, 'visibility', 'hide')
	end
end

-- these calls are tainted when accessed by ValidateActionBarTransition
local noops = { "ClearAllPoints", "SetPoint", "SetScale", "SetShown", "SetSize" }
function AB:SetNoopsi(frame)
	for _, func in pairs(noops) do
		if frame[func] ~= E.noop then
			frame[func] = E.noop
		end
	end
end

local SpellBookTooltip = CreateFrame("GameTooltip", "ElvUISpellBookTooltip", E.UIParent, "GameTooltipTemplate")
SpellBookTooltip.updateTooltip = TOOLTIP_UPDATE_TIME
function AB:SpellBookTooltipOnUpdate(elapsed)
	self.updateTooltip = self.updateTooltip - elapsed
	if self.updateTooltip > 0 then return end
	self.updateTooltip = TOOLTIP_UPDATE_TIME

	local owner = self:GetOwner()
	if owner and owner.UpdateTooltip then
		owner:UpdateTooltip()
	elseif self.UpdateTooltip then
		self:UpdateTooltip()
	end
end

function AB:SpellButtonOnEnter(_, tt)
	-- copied from SpellBookFrame to remove:
	--- ActionBarController_UpdateAll, PetActionHighlightMarks, and BarHighlightMarks

	-- TT:MODIFIER_STATE_CHANGED uses this function to safely update the spellbook tooltip when the actionbar module is disabled
	if not tt then tt = SpellBookTooltip end

	if tt:IsForbidden() then return end
	tt:SetOwner(self, 'ANCHOR_RIGHT')

	local slot = _G.SpellBook_GetSpellBookSlot(self)
	local needsUpdate = tt:SetSpellBookItem(slot, _G.SpellBookFrame.bookType) and tt == SpellBookTooltip
	self.UpdateTooltip = (needsUpdate and AB.SpellButtonOnEnter) or nil

	if needsUpdate then
		tt:SetScript('OnUpdate', AB.SpellBookTooltipOnUpdate)
	end

	local highlight = self.SpellHighlightTexture
	if highlight and highlight:IsShown() then
		local color = _G.LIGHTBLUE_FONT_COLOR
		tt:AddLine(_G.SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, color.r, color.g, color.b)
	end

	tt:Show()
end

function AB:SpellButtonUpdateButton(event)
	-- only need to check the shown state when its not called from TT:MODIFIER_STATE_CHANGED which already checks the shown state
	local button = (not event or SpellBookTooltip:IsShown()) and SpellBookTooltip:GetOwner()
	if button then AB.SpellButtonOnEnter(button) end
end

function AB:SpellButtonOnLeave()
	SpellBookTooltip:Hide()
	SpellBookTooltip:SetScript('OnUpdate', nil)
end

function AB:DisableBlizzard()
	-- dont blindly add to this table, the first 5 get their events registered
	for i, name in ipairs({"OverrideActionBar", "StanceBarFrame", "PossessBarFrame", "PetActionBarFrame", "MultiCastActionBarFrame", "MainMenuBar", "MicroButtonAndBagsBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight"}) do
		_G.UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil

		local frame = _G[name]
		if i < 6 then frame:UnregisterAllEvents() end
		frame:SetParent(hiddenParent)
		AB:SetNoopsi(frame)
	end

	-- let spell book buttons work without tainting by replacing this function
	for i = 1, SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		button:SetScript('OnEnter', AB.SpellButtonOnEnter)
		button:SetScript('OnLeave', AB.SpellButtonOnLeave)
	end

	-- MainMenuBar:ClearAllPoints taint during combat
	_G.MainMenuBar.SetPositionForStatusBars = E.noop

	-- shut down some events for things we dont use
	AB:SetNoopsi(_G.MainMenuBarArtFrame)
	AB:SetNoopsi(_G.MainMenuBarArtFrameBackground)
	_G.MainMenuBarArtFrame:UnregisterAllEvents()
	_G.StatusTrackingBarManager:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED') -- these are needed to let the ExtraActionButton show
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show

	-- this would taint along with the same path as the SetNoopers: ValidateActionBarTransition
	_G.VerticalMultiBarsContainer:SetSize(10, 10) -- dummy values so GetTop etc doesnt fail without replacing
	AB:SetNoopsi(_G.VerticalMultiBarsContainer)

	-- hide some interface options we dont use
	_G.InterfaceOptionsActionBarsPanelStackRightBars:SetScale(0.5)
	_G.InterfaceOptionsActionBarsPanelStackRightBars:SetAlpha(0)
	_G.InterfaceOptionsActionBarsPanelStackRightBarsText:Hide() -- hides the !
	_G.InterfaceOptionsActionBarsPanelRightTwoText:SetTextColor(1,1,1) -- no yellow
	_G.InterfaceOptionsActionBarsPanelRightTwoText.SetTextColor = E.noop -- i said no yellow
	_G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetScale(0.0001)
	_G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.0001)
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	_G.InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	_G.InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)

	AB:IconIntroTracker_Toggle() --Enable/disable functionality to automatically put spells on the actionbar.
	AB:SecureHook('BlizzardOptionsPanel_OnEvent')

	if _G.PlayerTalentFrame then
		_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end
end

function AB:ToggleCountDownNumbers(bar, button, cd)
	if cd then -- ref: E:CreateCooldownTimer
		local b = cd.GetParent and cd:GetParent()
		if cd.timer and (b and b.config) then
			-- update the new cooldown timer button config with the new setting
			b.config.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(cd, cd.timer, true)
		end
	elseif button then -- ref: AB:UpdateButtonConfig
		if (button.cooldown and button.cooldown.timer) and (bar and bar.buttonConfig) then
			-- button.config will get updated from `button:UpdateConfig` in `AB:UpdateButtonConfig`
			bar.buttonConfig.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(button.cooldown, button.cooldown.timer, true)
		end
	elseif bar then -- ref: E:UpdateCooldownOverride
		if bar.buttons then
			for _, btn in pairs(bar.buttons) do
				if (btn and btn.config) and (btn.cooldown and btn.cooldown.timer) then
					-- update the buttons config
					btn.config.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(btn.cooldown, btn.cooldown.timer, true)
				end
			end
			if bar.buttonConfig then
				-- we can actually clear this variable because it wont get used when this code runs
				bar.buttonConfig.disableCountDownNumbers = nil
			end
		end
	end
end

function AB:UpdateButtonConfig(bar, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	if not bar.buttonConfig then bar.buttonConfig = { hideElements = {}, colors = {} } end
	bar.buttonConfig.hideElements.macro = not AB.db.macrotext
	bar.buttonConfig.hideElements.hotkey = not AB.db.hotkeytext
	bar.buttonConfig.showGrid = AB.db["bar"..bar.id].showGrid
	bar.buttonConfig.clickOnDown = AB.db.keyDown
	bar.buttonConfig.outOfRangeColoring = (AB.db.useRangeColorText and 'hotkey') or 'button'
	bar.buttonConfig.colors.range = E:SetColorTable(bar.buttonConfig.colors.range, AB.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:SetColorTable(bar.buttonConfig.colors.mana, AB.db.noPowerColor)
	bar.buttonConfig.colors.usable = E:SetColorTable(bar.buttonConfig.colors.usable, AB.db.usableColor)
	bar.buttonConfig.colors.notUsable = E:SetColorTable(bar.buttonConfig.colors.notUsable, AB.db.notUsableColor)
	bar.buttonConfig.useDrawBling = not AB.db.hideCooldownBling
	bar.buttonConfig.useDrawSwipeOnCharges = AB.db.useDrawSwipeOnCharges
	SetModifiedClick("PICKUPACTION", AB.db.movementModifier)

	for i, button in pairs(bar.buttons) do
		AB:ToggleCountDownNumbers(bar, button)

		bar.buttonConfig.keyBoundTarget = format(buttonName.."%d", i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute("buttonlock", AB.db.lockActionBars)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		if AB.db.rightClickSelfCast then
			button:SetAttribute("unit2", "player")
		end

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey']
	local text = hotkey:GetText()

	local hotkeyPosition = E.db.actionbar.hotkeyTextPosition or 'TOPRIGHT'
	local hotkeyXOffset = E.db.actionbar.hotkeyTextXOffset or 0
	local hotkeyYOffset =  E.db.actionbar.hotkeyTextYOffset or -3

	local justify = "RIGHT"
	if hotkeyPosition == "TOPLEFT" or hotkeyPosition == "BOTTOMLEFT" then
		justify = "LEFT"
	elseif hotkeyPosition == "TOP" or hotkeyPosition == "BOTTOM" then
		justify = "CENTER"
	end

	if text then
		text = gsub(text, 'SHIFT%-', L["KEY_SHIFT"])
		text = gsub(text, 'ALT%-', L["KEY_ALT"])
		text = gsub(text, 'CTRL%-', L["KEY_CTRL"])
		text = gsub(text, 'BUTTON', L["KEY_MOUSEBUTTON"])
		text = gsub(text, 'MOUSEWHEELUP', L["KEY_MOUSEWHEELUP"])
		text = gsub(text, 'MOUSEWHEELDOWN', L["KEY_MOUSEWHEELDOWN"])
		text = gsub(text, 'NUMPAD', L["KEY_NUMPAD"])
		text = gsub(text, 'PAGEUP', L["KEY_PAGEUP"])
		text = gsub(text, 'PAGEDOWN', L["KEY_PAGEDOWN"])
		text = gsub(text, 'SPACE', L["KEY_SPACE"])
		text = gsub(text, 'INSERT', L["KEY_INSERT"])
		text = gsub(text, 'HOME', L["KEY_HOME"])
		text = gsub(text, 'DELETE', L["KEY_DELETE"])
		text = gsub(text, 'NMULTIPLY', "*")
		text = gsub(text, 'NMINUS', "N-")
		text = gsub(text, 'NPLUS', "N+")
		text = gsub(text, 'NEQUALS', "N=")

		hotkey:SetText(text)
		hotkey:SetJustifyH(justify)
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:Point(hotkeyPosition, hotkeyXOffset, hotkeyYOffset)
	end
end

AB.FlyoutButtons = 0
function AB:SetupFlyoutButton()
	for i = 1, AB.FlyoutButtons do
		--prevent error if you don't have max amount of buttons
		if _G["SpellFlyoutButton"..i] then
			AB:StyleButton(_G["SpellFlyoutButton"..i], nil, (MasqueGroup and E.private.actionbar.masque.actionbars) or nil)
			_G["SpellFlyoutButton"..i]:StyleButton()
			_G["SpellFlyoutButton"..i]:HookScript('OnEnter', function(btn)
				local parent = btn:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB.handledbuttons[parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnEnter(parentAnchorBar)
			end)
			_G["SpellFlyoutButton"..i]:HookScript('OnLeave', function(btn)
				local parent = btn:GetParent()
				local parentAnchorButton = select(2, parent:GetPoint())
				if not AB.handledbuttons[parentAnchorButton] then return end

				local parentAnchorBar = parentAnchorButton:GetParent()
				AB:Bar_OnLeave(parentAnchorBar)
			end)

			if MasqueGroup and E.private.actionbar.masque.actionbars then
				MasqueGroup:RemoveButton(_G["SpellFlyoutButton"..i]) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
				MasqueGroup:AddButton(_G["SpellFlyoutButton"..i])
			end
		end
	end

	_G.SpellFlyout:HookScript('OnEnter', function(btn)
		local anchorButton = select(2, btn:GetPoint())
		if not AB.handledbuttons[anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnEnter(parentAnchorBar)
	end)

	_G.SpellFlyout:HookScript('OnLeave', function(btn)
		local anchorButton = select(2, btn:GetPoint())
		if not AB.handledbuttons[anchorButton] then return end

		local parentAnchorBar = anchorButton:GetParent()
		AB:Bar_OnLeave(parentAnchorBar)
	end)
end

function AB:StyleFlyout(button)
	if not button.FlyoutArrow or not button.FlyoutArrow:IsShown() then return end

	if not LAB.buttonRegistry[button] then return end
	if not button.FlyoutBorder then return end
	local combat = InCombatLockdown()

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	_G.SpellFlyoutHorizontalBackground:SetAlpha(0)
	_G.SpellFlyoutVerticalBackground:SetAlpha(0)
	_G.SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i=1, GetNumFlyouts() do
		local _, _, numSlots, isKnown = GetFlyoutInfo(GetFlyoutID(i))
		if numSlots and isKnown and (numSlots > AB.FlyoutButtons) then
			AB.FlyoutButtons = numSlots
		end
	end

	local actionbar = button:GetParent()
	local parent = actionbar and actionbar:GetParent()
	local parentName = parent and parent:GetName()
	if parentName == "SpellBookSpellIconsFrame" then return end

	--Change arrow direction depending on what bar the button is on
	local arrowDistance = 2
	if ((_G.SpellFlyout:IsShown() and _G.SpellFlyout:GetParent() == button) or GetMouseFocus() == button) then
		arrowDistance = 5
	end

	if actionbar then
		local direction = actionbar.db and actionbar.db.flyoutDirection or "AUTOMATIC"
		local point = E:GetScreenQuadrant(actionbar)
		if point == "UNKNOWN" then return end

		if ((direction == "AUTOMATIC" and strfind(point, "TOP")) or direction == "DOWN") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("BOTTOM", button, "BOTTOM", 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not combat then button:SetAttribute("flyoutDirection", "DOWN") end
		elseif ((direction == "AUTOMATIC" and point == "RIGHT") or direction == "LEFT") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("LEFT", button, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not combat then button:SetAttribute("flyoutDirection", "LEFT") end
		elseif ((direction == "AUTOMATIC" and point == "LEFT") or direction == "RIGHT") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("RIGHT", button, "RIGHT", arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not combat then button:SetAttribute("flyoutDirection", "RIGHT") end
		elseif ((direction == "AUTOMATIC" and (point == "CENTER" or strfind(point, "BOTTOM"))) or direction == "UP") then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point("TOP", button, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not combat then button:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

function AB:UpdateChargeCooldown(button, duration)
	local cd = button and button.chargeCooldown
	if not cd then return end

	local oldstate = cd.hideText
	cd.hideText = (duration and duration > 1.5) or (AB.db.chargeCooldown == false) or nil
	if cd.timer and (oldstate ~= cd.hideText) then
		E:ToggleBlizzardCooldownText(cd, cd.timer)
		E:Cooldown_ForceUpdate(cd.timer)
	end
end

function AB:ToggleCooldownOptions()
	for button in pairs(LAB.actionButtons) do
		if button._state_type == "action" then
			local duration = select(2, button:GetCooldown())
			AB:UpdateChargeCooldown(button, duration)
			AB:SetButtonDesaturation(button, duration)
		end
	end
end

function AB:SetButtonDesaturation(button, duration)
	if AB.db.desaturateOnCooldown and (duration and duration > 1.5) then
		button.icon:SetDesaturated(true)
		button.saturationLocked = true
	else
		button.icon:SetDesaturated(false)
		button.saturationLocked = nil
	end
end

function AB:LAB_ChargeCreated(_, cd)
	cd.CooldownOverride = 'actionbar'
	E:RegisterCooldown(cd)
end

function AB:LAB_MouseUp()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(0)
	end
end

function AB:LAB_MouseDown()
	if self.config.clickOnDown then
		self:GetPushedTexture():SetAlpha(1)
	end
end

function AB:LAB_ButtonCreated(button)
	-- this fixes Key Down getting the pushed texture stuck
	button:HookScript("OnMouseUp", AB.LAB_MouseUp)
	button:HookScript("OnMouseDown", AB.LAB_MouseDown)
end

function AB:LAB_ButtonUpdate(button)
	local color = AB.db.fontColor
	button.Count:SetTextColor(color.r, color.g, color.b)
	if button.config and (button.config.outOfRangeColoring ~= "hotkey") then
		button.HotKey:SetTextColor(color.r, color.g, color.b)
	end

	if button.backdrop and AB.db.equippedItem then
		color = (button:IsEquipped() and AB.db.equippedItemColor) or E.db.general.bordercolor
		button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

function AB:LAB_CooldownDone(button)
	AB:SetButtonDesaturation(button, 0)
end

function AB:LAB_CooldownUpdate(button, _, duration)
	if button._state_type == "action" then
		AB:UpdateChargeCooldown(button, duration)
		AB:SetButtonDesaturation(button, duration)
	end

	if button.cooldown then
		AB:ColorSwipeTexture(button.cooldown)
	end
end

function AB:Initialize()
	AB.db = E.db.actionbar

	if not E.private.actionbar.enable then
		-- this is used by TT:MODIFIER_STATE_CHANGED to safely show the Spell ID in combat
		for i = 1, SPELLS_PER_PAGE do
			_G['SpellButton'..i]:HookScript('OnLeave', AB.SpellButtonOnLeave)
		end

		return
	end

	AB.Initialized = true

	LAB.RegisterCallback(AB, "OnButtonUpdate", AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, "OnButtonCreated", AB.LAB_ButtonCreated)
	LAB.RegisterCallback(AB, "OnChargeCreated", AB.LAB_ChargeCreated)
	LAB.RegisterCallback(AB, "OnCooldownUpdate", AB.LAB_CooldownUpdate)
	LAB.RegisterCallback(AB, "OnCooldownDone", AB.LAB_CooldownDone)

	AB.fadeParent = CreateFrame("Frame", "Elv_ABFade", _G.UIParent)
	AB.fadeParent:SetAlpha(1 - AB.db.globalFadeAlpha)
	AB.fadeParent:RegisterEvent("PLAYER_REGEN_DISABLED")
	AB.fadeParent:RegisterEvent("PLAYER_REGEN_ENABLED")
	AB.fadeParent:RegisterEvent("PLAYER_TARGET_CHANGED")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
	AB.fadeParent:RegisterUnitEvent("UNIT_HEALTH", "player")
	AB.fadeParent:RegisterEvent("PLAYER_FOCUS_CHANGED")
	AB.fadeParent:SetScript("OnEvent", AB.FadeParent_OnEvent)

	AB:DisableBlizzard()
	AB:SetupExtraButton()
	AB:SetupMicroBar()
	AB:UpdateBar1Paging()

	for i = 1, 10 do
		AB:CreateBar(i)
	end

	AB:CreateBarPet()
	AB:CreateBarShapeShift()
	AB:CreateVehicleLeave()
	AB:UpdateButtonSettings()
	AB:UpdatePetCooldownSettings()
	AB:ToggleCooldownOptions()
	AB:LoadKeyBinder()

	AB:RegisterEvent('UPDATE_BINDINGS', 'ReassignBindings')
	AB:RegisterEvent('PET_BATTLE_CLOSE', 'ReassignBindings')
	AB:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')
	AB:RegisterEvent('SPELL_UPDATE_COOLDOWN', 'SpellButtonUpdateButton')

	if C_PetBattles_IsInBattle() then
		AB:RemoveBindings()
	else
		AB:ReassignBindings()
	end

	-- We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	SetCVar('lockActionBars', (AB.db.lockActionBars == true and 1 or 0))
	_G.LOCK_ACTIONBAR = (AB.db.lockActionBars == true and "1" or "0") -- Keep an eye on this, in case it taints

	_G.SpellFlyout:HookScript("OnShow", AB.SetupFlyoutButton)
end

E:RegisterModule(AB:GetName())
