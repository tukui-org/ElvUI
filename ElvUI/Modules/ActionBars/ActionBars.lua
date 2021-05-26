local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local ipairs, pairs, select, strmatch, unpack = ipairs, pairs, select, strmatch, unpack
local format, gsub, strsplit, strfind, strupper = format, gsub, strsplit, strfind, strupper

local ClearOnBarHighlightMarks = ClearOnBarHighlightMarks
local ClearOverrideBindings = ClearOverrideBindings
local ClearPetActionHighlightMarks = ClearPetActionHighlightMarks
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetOverrideBarIndex = GetOverrideBarIndex
local GetSpellBookItemInfo = GetSpellBookItemInfo
local GetVehicleBarIndex = GetVehicleBarIndex
local HasOverrideActionBar = HasOverrideActionBar
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsPossessBarVisible = IsPossessBarVisible
local PetDismiss = PetDismiss
local RegisterStateDriver = RegisterStateDriver
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
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
local UpdateOnBarHighlightMarksByFlyout = UpdateOnBarHighlightMarksByFlyout
local UpdateOnBarHighlightMarksByPetAction = UpdateOnBarHighlightMarksByPetAction
local UpdateOnBarHighlightMarksBySpell = UpdateOnBarHighlightMarksBySpell
local UpdatePetActionHighlightMarks = UpdatePetActionHighlightMarks
local VehicleExit = VehicleExit

local SPELLS_PER_PAGE = SPELLS_PER_PAGE
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group('ElvUI', 'ActionBars')
local defaultFont, defaultFontSize, defaultFontOutline

local hiddenParent = CreateFrame('Frame', nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

AB.RegisterCooldown = E.RegisterCooldown
AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = {
		page = 1,
		bindButtons = 'ACTIONBUTTON',
		conditions = format('[overridebar] %d; [vehicleui] %d; [possessbar] %d; [shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;', GetOverrideBarIndex(), GetVehicleBarIndex(), GetVehicleBarIndex()),
		position = 'BOTTOM,ElvUIParent,BOTTOM,-1,191',
	},
	bar2 = {
		page = 2,
		bindButtons = 'ELVUIBAR2BUTTON',
		position = 'BOTTOM,ElvUIParent,BOTTOM,0,4',
	},
	bar3 = {
		page = 3,
		bindButtons = 'MULTIACTIONBAR3BUTTON',
		position = 'BOTTOM,ElvUIParent,BOTTOM,-1,139',
	},
	bar4 = {
		page = 4,
		bindButtons = 'MULTIACTIONBAR4BUTTON',
		position = 'RIGHT,ElvUIParent,RIGHT,-4,0',
	},
	bar5 = {
		page = 5,
		bindButtons = 'MULTIACTIONBAR2BUTTON',
		position = 'BOTTOM,ElvUIParent,BOTTOM,-279,4',
	},
	bar6 = {
		page = 6,
		bindButtons = 'MULTIACTIONBAR1BUTTON',
		position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,264',
	},
	bar7 = {
		page = 7,
		bindButtons = 'ELVUIBAR7BUTTON',
		position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,298',
	},
	bar8 = {
		page = 8,
		bindButtons = 'ELVUIBAR8BUTTON',
		position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,332',
	},
	bar9 = {
		page = 9,
		bindButtons = 'ELVUIBAR9BUTTON',
		position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,366',
	},
	bar10 = {
		page = 10,
		bindButtons = 'ELVUIBAR10BUTTON',
		position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400',
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

function AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, widthMult, heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	if not bar.backdrop:IsShown() then return end

	local useWidthMult = widthMult > 1
	local useHeightMult = heightMult > 1
	if useWidthMult or useHeightMult then
		local oldWidth, oldHeight = bar.backdrop:GetSize()
		if useHeightMult then
			local offset = ((oldHeight + buttonSpacing) * (heightMult - 1)) - backdropSpacing
			local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
			bar.backdrop:Point(anchorPoint, lastShownButton, anchorPoint, 0, anchorUp and offset or -offset)
		end
		if useWidthMult then
			local offset = ((oldWidth + buttonSpacing) * (widthMult - 1)) - backdropSpacing
			bar.backdrop:Point(horizontal, anchorRowButton, horizontal, anchorLeft and -offset or offset, 0)
		end
	end
end

function AB:HandleBackdropMover(bar, backdropSpacing)
	local width, height = bar.backdrop:GetSize()
	if not bar.backdrop:IsShown() then
		local spacing = backdropSpacing * 2
		bar:SetSize(width - spacing, height - spacing)
	else
		bar:SetSize(width, height)
	end
end

function AB:HandleButton(bar, button, index, lastButton, lastColumnButton)
	local db = bar.db

	local numButtons = db.buttons
	local buttonsPerRow = db.buttonsPerRow
	local buttonWidth = db.buttonSize
	local buttonHeight = db.keepSizeRatio and db.buttonSize or db.buttonHeight

	if bar.LastButton then
		if numButtons > bar.LastButton then numButtons = bar.LastButton end
		if buttonsPerRow > bar.LastButton then buttonsPerRow = bar.LastButton end
	end

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(db.point)
	local point, relativeFrame, relativePoint, x, y
	if index == 1 then
		local firstButtonSpacing = db.backdrop and (E.Border + db.backdropSpacing) or E.Spacing
		if db.point == 'BOTTOMLEFT' then
			x, y = firstButtonSpacing, firstButtonSpacing
		elseif db.point == 'TOPRIGHT' then
			x, y = -firstButtonSpacing, -firstButtonSpacing
		elseif db.point == 'TOPLEFT' then
			x, y = firstButtonSpacing, -firstButtonSpacing
		else
			x, y = -firstButtonSpacing, firstButtonSpacing
		end

		point, relativeFrame, relativePoint = db.point, bar, db.point
	elseif (index - 1) % buttonsPerRow == 0 then
		point, relativeFrame, relativePoint, x, y = 'TOP', lastColumnButton, 'BOTTOM', 0, -db.buttonSpacing
		if anchorUp then
			point, relativePoint, y = 'BOTTOM', 'TOP', db.buttonSpacing
		end
	else
		point, relativeFrame, relativePoint, x, y = 'LEFT', lastButton, 'RIGHT', db.buttonSpacing, 0
		if anchorLeft then
			point, relativePoint, x = 'RIGHT', 'LEFT', -db.buttonSpacing
		end
	end

	button:SetParent(bar)
	button:ClearAllPoints()
	button:SetAttribute('showgrid', 1)
	button:EnableMouse(not db.clickThrough)
	button:Size(buttonWidth, buttonHeight)
	button:Point(point, relativeFrame, relativePoint, x, y)

	if index == 1 then
		bar.backdrop:Point(point, button, point, anchorLeft and db.backdropSpacing or -db.backdropSpacing, anchorUp and -db.backdropSpacing or db.backdropSpacing)
	elseif index == buttonsPerRow then
		bar.backdrop:Point(horizontal, button, horizontal, anchorLeft and -db.backdropSpacing or db.backdropSpacing, 0)
	end

	if button.handleBackdrop then
		local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
		bar.backdrop:Point(anchorPoint, button, anchorPoint, 0, anchorUp and db.backdropSpacing or -db.backdropSpacing)
	end
end

function AB:TrimIcon(button, masque)
	if not button.icon then return end

	local left, right, top, bottom = unpack(button.db and button.db.customCoords or E.TexCoords)
	local changeRatio = button.db and not button.db.keepSizeRatio
	if changeRatio then
		local width, height = button:GetSize()
		local ratio = width / height
		if ratio > 1 then
			local trimAmount = (1 - (1 / ratio)) / 2
			top = top + trimAmount
			bottom = bottom - trimAmount
		else
			local trimAmount = (1 - ratio) / 2
			left = left + trimAmount
			right = right - trimAmount
		end
	end

	-- always when masque is off, otherwise only when keepSizeRatio is off
	if not masque or changeRatio then
		button.icon:SetTexCoord(left, right, top, bottom)
	end
end

function AB:GetGrowth(point)
	local vertical = (point == 'TOPLEFT' or point == 'TOPRIGHT') and 'DOWN' or 'UP'
	local horizontal = (point == 'BOTTOMLEFT' or point == 'TOPLEFT') and 'RIGHT' or 'LEFT'
	local anchorUp, anchorLeft = vertical == 'UP', horizontal == 'LEFT'

	return vertical, horizontal, anchorUp, anchorLeft
end

function AB:MoverMagic(bar) -- ~Simpy
	local _, _, anchorUp, anchorLeft = AB:GetGrowth(bar.db.point)

	bar:ClearAllPoints()
	if not bar.backdrop:IsShown() then
		bar:SetPoint('BOTTOMLEFT', bar.mover)
	elseif anchorUp then
		bar:SetPoint('BOTTOMLEFT', bar.mover, 'BOTTOMLEFT', anchorLeft and E.Border or -E.Border, -E.Border)
	else
		bar:SetPoint('TOPLEFT', bar.mover, 'TOPLEFT', anchorLeft and E.Border or -E.Border, E.Border)
	end
end

function AB:PositionAndSizeBar(barName)
	local db = AB.db[barName]
	local bar = AB.handledBars[barName]

	local buttonSpacing = db.buttonSpacing
	local backdropSpacing = db.backdropSpacing
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local point = db.point
	local visibility = db.visibility

	bar.db = db
	bar.mouseover = db.mouseover

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	bar:SetParent(db.inheritGlobalFade and AB.fadeParent or E.UIParent)
	bar:EnableMouse(not db.clickThrough)
	bar:SetAlpha(bar.mouseover and 0 or db.alpha)
	bar:SetFrameStrata(db.frameStrata or 'LOW')
	bar:SetFrameLevel(db.frameLevel)

	AB:FadeBarBlings(bar, bar.mouseover and 0 or db.alpha)

	bar.backdrop:SetShown(db.backdrop)
	bar.backdrop:SetFrameStrata(db.frameStrata or 'LOW')
	bar.backdrop:SetFrameLevel(db.frameLevel - 1)
	bar.backdrop:ClearAllPoints()

	AB:MoverMagic(bar)

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(point)
	local button, lastButton, lastColumnButton, anchorRowButton, lastShownButton

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		lastButton = bar.buttons[i-1]
		lastColumnButton = bar.buttons[i-buttonsPerRow]
		button = bar.buttons[i]
		button.db = db

		if i == 1 or i == buttonsPerRow then
			anchorRowButton = button
		end

		if i > numButtons then
			button:Hide()
			button.handleBackdrop = nil
		else
			button:Show()
			button.handleBackdrop = true -- keep over HandleButton
			lastShownButton = button
		end

		AB:HandleButton(bar, button, i, lastButton, lastColumnButton)
		AB:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars)
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	-- paging needs to be updated even if the bar is disabled
	local defaults = AB.barDefaults[barName]
	local page = AB:GetPage(barName, defaults.page, defaults.conditions)
	RegisterStateDriver(bar, 'page', page)
	bar:SetAttribute('page', page)

	if db.enabled then
		visibility = gsub(visibility, '[\n\r]', '')

		E:EnableMover(bar.mover:GetName())
		RegisterStateDriver(bar, 'visibility', visibility)
		bar:Show()
	else
		E:DisableMover(bar.mover:GetName())
		UnregisterStateDriver(bar, 'visibility')
		bar:Hide()
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, db.buttonSpacing / 2)

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:ReSkin()

		-- masque retrims them all so we have to too
		for btn in pairs(AB.handledbuttons) do
			AB:TrimIcon(btn, true)
		end
	end
end

function AB:CreateBar(id)
	local bar = CreateFrame('Frame', 'ElvUI_Bar'..id, E.UIParent, 'SecureHandlerStateTemplate')
	SecureHandlerSetFrameRef(bar, 'MainMenuBarArtFrame', _G.MainMenuBarArtFrame)
	AB.handledBars['bar'..id] = bar

	local defaults = AB.barDefaults['bar'..id]
	local point, anchor, attachTo, x, y = strsplit(',', defaults.position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id

	bar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, 0)

	bar.buttons = {}
	bar.bindButtons = defaults.bindButtons
	AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	for i = 1, 12 do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName()..'Button%d', i), bar, nil)
		bar.buttons[i]:SetState(0, 'action', i)

		for k = 1, 14 do
			bar.buttons[i]:SetState(k, 'action', (k - 1) * 12 + i)
		end

		if i == 12 then
			bar.buttons[i]:SetState(12, 'custom', AB.customExitButton)
		end

		if MasqueGroup and E.private.actionbar.masque.actionbars then
			bar.buttons[i]:AddToMasque(MasqueGroup)
		end

		AB:HookScript(bar.buttons[i], 'OnEnter', 'Button_OnEnter')
		AB:HookScript(bar.buttons[i], 'OnLeave', 'Button_OnLeave')
	end

	if defaults.conditions and strfind(defaults.conditions, '[form,noform]') then
		bar:SetAttribute('newCondition', gsub(defaults.conditions, ' %[form,noform%] 0; ', ''))
		bar:SetAttribute('hasTempBar', true)
	else
		bar:SetAttribute('hasTempBar', false)
	end

	bar:SetAttribute('_onstate-page', [[
		if HasTempShapeshiftActionBar() and self:GetAttribute('hasTempBar') then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		if newstate ~= 0 then
			self:SetAttribute('state', newstate)
			control:ChildUpdate('state', newstate)
			self:GetFrameRef('MainMenuBarArtFrame'):SetAttribute('actionpage', newstate) --Update MainMenuBarArtFrame too. See issue #1848
		else
			local newCondition = self:GetAttribute('newCondition')
			if newCondition then
				newstate = SecureCmdOptionParse(newCondition)
				self:SetAttribute('state', newstate)
				control:ChildUpdate('state', newstate)
				self:GetFrameRef('MainMenuBarArtFrame'):SetAttribute('actionpage', newstate)
			end
		end
	]])

	E:CreateMover(bar, 'ElvAB_'..id, L["Bar "]..id, nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,playerBars,bar'..id)

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
	if AB.NeedsReparentExtraButtons then
		AB:ExtraButtons_Reparent()
		AB.NeedsReparentExtraButtons = nil
	end

	AB:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if not db.enable then return end

	local holder = CreateFrame('Frame', 'VehicleLeaveButtonHolder', E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 300)
	holder:Size(_G.MainMenuBarVehicleLeaveButton:GetSize())
	E:CreateMover(holder, 'VehicleLeaveButton', L["VehicleLeaveButton"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,vehicleExitButton')

	local Button = _G.MainMenuBarVehicleLeaveButton
	Button:ClearAllPoints()
	Button:SetParent(_G.UIParent)
	Button:Point('CENTER', holder, 'CENTER')

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
			Button:Point('CENTER', holder, 'CENTER')
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
	if event == 'UPDATE_BINDINGS' then
		AB:UpdatePetBindings()
		AB:UpdateStanceBindings()
		AB:UpdateExtraBindings()
	end

	AB:UnregisterEvent('PLAYER_REGEN_DISABLED')

	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)

			for _, button in ipairs(bar.buttons) do
				if button.keyBoundTarget then
					for k=1, select('#', GetBindingKey(button.keyBoundTarget)) do
						local key = select(k, GetBindingKey(button.keyBoundTarget))
						if key and key ~= '' then
							SetOverrideBindingClick(bar, false, key, button:GetName())
						end
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

	AB:RegisterEvent('PLAYER_REGEN_DISABLED', 'ReassignBindings')
end

do
	local texts = { 'hotkey', 'macro', 'count' }
	local bars = { 'barPet', 'stanceBar', 'vehicleExitButton', 'extraActionButton' }

	local function saveSetting(option, value)
		for i = 1, 10 do
			E.db.actionbar['bar'..i][option] = value
		end

		for _, bar in pairs(bars) do
			E.db.actionbar[bar][option] = value
		end
	end

	function AB:ApplyTextOption(option, value, fonts)
		if fonts then
			local upperOption = gsub(option, '^%w', strupper) -- font>Font, fontSize>FontSize, fontOutline>FontOutline
			for _, object in pairs(texts) do
				saveSetting(object..upperOption, value)
			end
		else
			saveSetting(option, value)
		end

		AB:UpdateButtonSettings()
	end
end

function AB:UpdateButtonSettings(specific)
	if not E.private.actionbar.enable then return end

	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	for barName, bar in pairs(AB.handledBars) do
		if not specific or specific == barName then
			AB:UpdateButtonConfig(barName, bar.bindButtons) -- config them first
			AB:PositionAndSizeBar(barName) -- db is set here, button style also runs here
			for _, button in ipairs(bar.buttons) do
				AB:StyleFlyout(button)
			end
		end
	end

	if not specific then
		-- we can safely toggle these events when we arent using the handle overlay
		if AB.db.handleOverlay then
			LAB.eventFrame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')
			LAB.eventFrame:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_HIDE')
		else
			LAB.eventFrame:UnregisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')
			LAB.eventFrame:UnregisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_HIDE')
		end

		AB:AdjustMaxStanceButtons()
		AB:PositionAndSizeBarPet()
		AB:PositionAndSizeBarShapeShift()

		AB:UpdatePetBindings()
		AB:UpdateStanceBindings() -- call after AdjustMaxStanceButtons
		AB:UpdateExtraBindings()

		AB:UpdateFlyoutButtons()
	end
end

function AB:GetPage(bar, defaultPage, condition)
	local page = AB.db[bar].paging[E.myclass]
	if not condition then condition = '' end

	if page then
		page = gsub(page, '[\n\r]', '')

		condition = condition..' '..page
	end

	condition = condition..' '..defaultPage

	return condition
end

function AB:StyleButton(button, noBackdrop, useMasque, ignoreNormal)
	local name = button:GetName()
	local macroText = _G[name..'Name']
	local icon = _G[name..'Icon']
	local shine = _G[name..'Shine']
	local count = _G[name..'Count']
	local flash = _G[name..'Flash']
	local border = _G[name..'Border']
	local normal = _G[name..'NormalTexture']
	local normal2 = button:GetNormalTexture()

	local db = button:GetParent().db
	local color = AB.db.fontColor
	local font, fontSize, fontOutline = AB.db.font, AB.db.fontSize, AB.db.fontOutline

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	icon:SetDrawLayer('ARTWORK')

	if normal and not ignoreNormal then normal:SetTexture(); normal:Hide(); normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture(); normal2:Hide(); normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end

	if count then
		local position, xOffset, yOffset = db and db.countTextPosition or 'BOTTOMRIGHT', db and db.countTextXOffset or 0, db and db.countTextYOffset or 2

		count:ClearAllPoints()
		count:Point(position, xOffset, yOffset)
		count:FontTemplate(LSM:Fetch('font', db and db.countFont or font), db and db.countFontSize or fontSize, db and db.countFontOutline or fontOutline)

		if db then
			count:SetShown(db.counttext)
		end

		local c = db and db.useCountColor and db.countColor or color
		count:SetTextColor(c.r, c.g, c.b)
	end

	if macroText then
		local position, xOffset, yOffset = db and db.macroTextPosition or 'BOTTOM', db and db.macroTextXOffset or 0, db and db.macroTextYOffset or 1

		macroText:ClearAllPoints()
		macroText:Point(position, xOffset, yOffset)
		macroText:FontTemplate(LSM:Fetch('font', db and db.macroFont or font), db and db.macroFontSize or fontSize, db and db.macroFontOutline or fontOutline)

		local c = db and db.useMacroColor and db.macroColor or color
		macroText:SetTextColor(c.r, c.g, c.b)
	end

	if not button.noBackdrop and not button.useMasque then
		button:SetTemplate(AB.db.transparent and 'Transparent', true)
	end

	if flash then
		if AB.db.flashAnimation then
			flash:SetColorTexture(1.0, 0.2, 0.2, 0.45)
			flash:ClearAllPoints()
			flash:SetOutside(icon, 2, 2)
			flash:SetDrawLayer('BACKGROUND', -1)
		else
			flash:SetTexture()
		end
	end

	if not useMasque then
		AB:TrimIcon(button)
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if not ignoreNormal then -- stance buttons dont need this
		button.FlyoutUpdateFunc = AB.StyleFlyout
	end

	if button.SpellHighlightTexture then
		button.SpellHighlightTexture:SetColorTexture(1, 1, 0, 0.45)
		button.SpellHighlightTexture:SetAllPoints()
	end

	if not AB.handledbuttons[button] then
		button.cooldown.CooldownOverride = 'actionbar'
		E:RegisterCooldown(button.cooldown)
		AB.handledbuttons[button] = true
	end

	if AB.db.useRangeColorText then
		AB:UpdateHotkeyColor(button)
	end

	if button.style then -- Boss Button
		button.style:SetDrawLayer('BACKGROUND', -7)
	end

	AB:FixKeybindText(button)

	if not button.useMasque then
		button:StyleButton()
	else
		button:StyleButton(true, true, true)
	end
end

function AB:UpdateHotkeyColor(button)
	local db = button.db
	local c = AB.db.useRangeColorText and button.outOfRange and AB.db.noRangeColor or db and db.useHotkeyColor and db.hotkeyColor or AB.db.fontColor
	button.HotKey:SetTextColor(c.r, c.g, c.b)
end

function AB:ColorSwipeTexture(cooldown)
	if not cooldown then return end

	local color = (cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and AB.db.colorSwipeLOC) or AB.db.colorSwipeNormal
	cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
end

function AB:FadeBlingTexture(cooldown, alpha)
	if not cooldown then return end
	cooldown:SetBlingTexture(alpha > 0.5 and 131010 or [[Interface\AddOns\ElvUI\Media\Textures\Blank]]) -- interface/cooldown/star4.blp
end

function AB:FadeBlings(alpha)
	if AB.db.hideCooldownBling then return end

	for i = 1, AB.fadeParent:GetNumChildren() do
		local bar = select(i, AB.fadeParent:GetChildren())
		if bar.buttons then
			for _, button in ipairs(bar.buttons) do
				AB:FadeBlingTexture(button.cooldown, alpha)
			end
		end
	end
end

function AB:FadeBarBlings(bar, alpha)
	if AB.db.hideCooldownBling then return end

	for _, button in ipairs(bar.buttons) do
		AB:FadeBlingTexture(button.cooldown, alpha)
	end
end

function AB:Bar_OnEnter(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end

	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
		AB:FadeBarBlings(bar, 0)
	end
end

function AB:Button_OnEnter(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
		AB:FadeBlings(1)
	end

	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - AB.db.globalFadeAlpha
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), a)
		AB:FadeBlings(a)
	end

	if bar.mouseover then
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
	if UnitCastingInfo('player') or UnitChannelInfo('player') or UnitExists('target') or UnitExists('focus') or UnitExists('vehicle')
	or UnitAffectingCombat('player') or (UnitHealth('player') ~= UnitHealthMax('player')) or IsPossessBarVisible() or HasOverrideActionBar() then
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
		IconIntroTracker:RegisterEvent('SPELL_PUSHED_TO_ACTIONBAR')
		UnregisterStateDriver(IconIntroTracker, 'visibility')
	else
		IconIntroTracker:UnregisterAllEvents()
		RegisterStateDriver(IconIntroTracker, 'visibility', 'hide')
	end
end

-- these calls are tainted when accessed by ValidateActionBarTransition
local noops = { 'ClearAllPoints', 'SetPoint', 'SetScale', 'SetShown' }
function AB:SetNoopsi(frame)
	for _, func in pairs(noops) do
		if frame[func] ~= E.noop then
			frame[func] = E.noop
		end
	end
end

local SpellBookTooltip = CreateFrame('GameTooltip', 'ElvUISpellBookTooltip', E.UIParent, 'GameTooltipTemplate')
function AB:SpellBookTooltipOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < TOOLTIP_UPDATE_TIME then return end
	self.elapsed = 0

	local owner = self:GetOwner()
	if owner then AB.SpellButtonOnEnter(owner) end
end

function AB:SpellButtonOnEnter(_, tt)
	-- copied from SpellBookFrame to remove:
	--- ActionBarController_UpdateAll, PetActionHighlightMarks, and BarHighlightMarks

	-- TT:MODIFIER_STATE_CHANGED uses this function to safely update the spellbook tooltip when the actionbar module is disabled
	if not tt then tt = SpellBookTooltip end

	if tt:IsForbidden() then return end
	tt:SetOwner(self, 'ANCHOR_RIGHT')

	local slot = _G.SpellBook_GetSpellBookSlot(self)
	local needsUpdate = tt:SetSpellBookItem(slot, _G.SpellBookFrame.bookType)

	ClearOnBarHighlightMarks()
	ClearPetActionHighlightMarks()

	local slotType, actionID = GetSpellBookItemInfo(slot, _G.SpellBookFrame.bookType)
	if slotType == 'SPELL' then
		UpdateOnBarHighlightMarksBySpell(actionID)
	elseif slotType == 'FLYOUT' then
		UpdateOnBarHighlightMarksByFlyout(actionID)
	elseif slotType == 'PETACTION' then
		UpdateOnBarHighlightMarksByPetAction(actionID)
		UpdatePetActionHighlightMarks(actionID)
	end

	local highlight = self.SpellHighlightTexture
	if highlight and highlight:IsShown() then
		local color = _G.LIGHTBLUE_FONT_COLOR
		tt:AddLine(_G.SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, color.r, color.g, color.b)
	end

	if tt == SpellBookTooltip then
		tt:SetScript('OnUpdate', (needsUpdate and AB.SpellBookTooltipOnUpdate) or nil)
	end

	tt:Show()
end

function AB:UpdateSpellBookTooltip(event)
	-- only need to check the shown state when its not called from TT:MODIFIER_STATE_CHANGED which already checks the shown state
	local button = (not event or SpellBookTooltip:IsShown()) and SpellBookTooltip:GetOwner()
	if button then AB.SpellButtonOnEnter(button) end
end

function AB:SpellButtonOnLeave()
	ClearOnBarHighlightMarks()
	ClearPetActionHighlightMarks()

	SpellBookTooltip:Hide()
	SpellBookTooltip:SetScript('OnUpdate', nil)
end

function AB:ButtonEventsRegisterFrame(added)
	local frames = _G.ActionBarButtonEventsFrame.frames
	for index = #frames, 1, -1 do
		local frame = frames[index]
		local wasAdded = frame == added
		if not added or wasAdded then
			if not strmatch(frame:GetName(), 'ExtraActionButton%d') then
				_G.ActionBarButtonEventsFrame.frames[index] = nil
			end

			if wasAdded then
				break
			end
		end
	end
end

function AB:DisableBlizzard()
	-- dont blindly add to this table, the first 5 get their events registered
	for i, name in ipairs({'OverrideActionBar', 'StanceBarFrame', 'PossessBarFrame', 'PetActionBarFrame', 'MultiCastActionBarFrame', 'MainMenuBar', 'MicroButtonAndBagsBar', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarLeft', 'MultiBarRight'}) do
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

	-- Spellbook open in combat taint, only happens sometimes
	_G.MultiActionBar_HideAllGrids = E.noop
	_G.MultiActionBar_ShowAllGrids = E.noop

	-- shut down some events for things we dont use
	AB:SetNoopsi(_G.MainMenuBarArtFrame)
	AB:SetNoopsi(_G.MainMenuBarArtFrameBackground)
	_G.MainMenuBarArtFrame:UnregisterAllEvents()
	_G.StatusTrackingBarManager:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:UnregisterAllEvents()
	_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED') -- these are needed to let the ExtraActionButton show
	_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN') -- needed for ExtraActionBar cooldown
	_G.ActionBarActionEventsFrame:UnregisterAllEvents()
	_G.ActionBarController:UnregisterAllEvents()
	_G.ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show

	-- lets only keep ExtraActionButtons in here
	hooksecurefunc(_G.ActionBarButtonEventsFrame, 'RegisterFrame', AB.ButtonEventsRegisterFrame)
	AB.ButtonEventsRegisterFrame()

	-- this would taint along with the same path as the SetNoopers: ValidateActionBarTransition
	_G.VerticalMultiBarsContainer:Size(10, 10) -- dummy values so GetTop etc doesnt fail without replacing
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
		_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function()
			_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
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
		if button.cooldown and button.cooldown.timer and (bar and bar.buttonConfig) then
			-- button.config will get updated from `button:UpdateConfig` in `AB:UpdateButtonConfig`
			bar.buttonConfig.disableCountDownNumbers = not not E:ToggleBlizzardCooldownText(button.cooldown, button.cooldown.timer, true)
		end
	elseif bar then -- ref: E:UpdateCooldownOverride
		if bar.buttons then
			for _, btn in ipairs(bar.buttons) do
				if btn and btn.config and (btn.cooldown and btn.cooldown.timer) then
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

function AB:UpdateButtonConfig(barName, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local barDB = AB.db[barName]
	local bar = AB.handledBars[barName]

	buttonName = buttonName or bar.bindButtons

	if not bar.buttonConfig then bar.buttonConfig = { hideElements = {}, colors = {} } end

	bar.buttonConfig.hideElements.macro = not barDB.macrotext
	bar.buttonConfig.hideElements.hotkey = not barDB.hotkeytext
	bar.buttonConfig.showGrid = barDB.showGrid
	bar.buttonConfig.clickOnDown = AB.db.keyDown
	bar.buttonConfig.outOfRangeColoring = (AB.db.useRangeColorText and 'hotkey') or 'button'
	bar.buttonConfig.colors.range = E:SetColorTable(bar.buttonConfig.colors.range, AB.db.noRangeColor)
	bar.buttonConfig.colors.mana = E:SetColorTable(bar.buttonConfig.colors.mana, AB.db.noPowerColor)
	bar.buttonConfig.colors.usable = E:SetColorTable(bar.buttonConfig.colors.usable, AB.db.usableColor)
	bar.buttonConfig.colors.notUsable = E:SetColorTable(bar.buttonConfig.colors.notUsable, AB.db.notUsableColor)
	bar.buttonConfig.useDrawBling = not AB.db.hideCooldownBling
	bar.buttonConfig.useDrawSwipeOnCharges = AB.db.useDrawSwipeOnCharges
	bar.buttonConfig.handleOverlay = AB.db.handleOverlay
	SetModifiedClick('PICKUPACTION', AB.db.movementModifier)

	for i, button in ipairs(bar.buttons) do
		AB:ToggleCountDownNumbers(bar, button)

		bar.buttonConfig.keyBoundTarget = format(buttonName..'%d', i)
		button.keyBoundTarget = bar.buttonConfig.keyBoundTarget
		button.postKeybind = AB.FixKeybindText
		button:SetAttribute('buttonlock', AB.db.lockActionBars)
		button:SetAttribute('checkselfcast', true)
		button:SetAttribute('checkfocuscast', true)
		if AB.db.rightClickSelfCast then
			button:SetAttribute('unit2', 'player')
		end

		button:UpdateConfig(bar.buttonConfig)
	end
end

function AB:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey']
	local text = hotkey:GetText()

	local db = button:GetParent().db
	local hotkeyPosition = db and db.hotkeyTextPosition or 'TOPRIGHT'
	local hotkeyXOffset = db and db.hotkeyTextXOffset or 0
	local hotkeyYOffset = db and db.hotkeyTextYOffset or -3
	local color = db and db.useHotkeyColor and db.hotkeyColor or AB.db.fontColor

	local justify = 'RIGHT'
	if hotkeyPosition == 'TOPLEFT' or hotkeyPosition == 'BOTTOMLEFT' then
		justify = 'LEFT'
	elseif hotkeyPosition == 'TOP' or hotkeyPosition == 'BOTTOM' then
		justify = 'CENTER'
	end

	if text then
		if text == _G.RANGE_INDICATOR then
			hotkey:SetFont(defaultFont, defaultFontSize, defaultFontOutline)
			hotkey.SetVertexColor = nil
		else
			hotkey:FontTemplate(LSM:Fetch('font', db and db.hotkeyFont or AB.db.font), db and db.hotkeyFontSize or AB.db.fontSize, db and db.hotkeyFontOutline or AB.db.fontOutline)

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
			text = gsub(text, 'NMULTIPLY', '*')
			text = gsub(text, 'NMINUS', 'N-')
			text = gsub(text, 'NPLUS', 'N+')
			text = gsub(text, 'NEQUALS', 'N=')
			hotkey.SetVertexColor = E.noop
		end

		hotkey:SetText(text)
		hotkey:SetJustifyH(justify)
	end

	hotkey:SetTextColor(color.r, color.g, color.b)

	if not button.__LAB_Version then
		if db and not db.hotkeytext then
			hotkey:Hide()
		else
			hotkey:Show()
		end
	end

	if not button.useMasque then
		hotkey:ClearAllPoints()
		hotkey:Point(hotkeyPosition, hotkeyXOffset, hotkeyYOffset)
	end
end

local function flyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	local _, parentAnchorButton = parent:GetPoint()
	if not AB.handledbuttons[parentAnchorButton] then return end

	return parentAnchorButton:GetParent()
end

function AB:FlyoutButton_OnEnter()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end

	AB:BindUpdate(self, 'FLYOUT')
end

function AB:FlyoutButton_OnLeave()
	local anchor = flyoutButtonAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

local function spellFlyoutAnchor(frame)
	local _, anchorButton = frame:GetPoint()
	if not AB.handledbuttons[anchorButton] then return end

	return anchorButton:GetParent()
end

function AB:SpellFlyout_OnEnter()
	local anchor = spellFlyoutAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end
end

function AB:SpellFlyout_OnLeave()
	local anchor = spellFlyoutAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

function AB:UpdateFlyoutButtons()
	local btn, i = _G['SpellFlyoutButton1'], 1
	while btn do
		AB:SetupFlyoutButton(btn)
		btn.isFlyout = true

		i = i + 1
		btn = _G['SpellFlyoutButton'..i]
	end
end

function AB:SetupFlyoutButton(button)
	if not AB.handledbuttons[button] then
		AB:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars)
		button:HookScript('OnEnter', AB.FlyoutButton_OnEnter)
		button:HookScript('OnLeave', AB.FlyoutButton_OnLeave)
	end

	if not InCombatLockdown() then
		button:Size(AB.db.flyoutSize)
	end

	if MasqueGroup and E.private.actionbar.masque.actionbars then
		MasqueGroup:RemoveButton(button) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
		MasqueGroup:AddButton(button)
	end
end

function AB:StyleFlyout(button)
	if not (button.FlyoutBorder and button.FlyoutArrow and button.FlyoutArrow:IsShown() and LAB.buttonRegistry[button]) then return end

	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)

	_G.SpellFlyoutHorizontalBackground:SetAlpha(0)
	_G.SpellFlyoutVerticalBackground:SetAlpha(0)
	_G.SpellFlyoutBackgroundEnd:SetAlpha(0)

	local actionbar = button:GetParent()
	local parent = actionbar and actionbar:GetParent()
	local parentName = parent and parent:GetName()
	if parentName == 'SpellBookSpellIconsFrame' then
		return
	elseif actionbar then
		-- Change arrow direction depending on what bar the button is on

		local arrowDistance = 2
		if _G.SpellFlyout:IsShown() and _G.SpellFlyout:GetParent() == button then
			arrowDistance = 5
		end

		local direction = (actionbar.db and actionbar.db.flyoutDirection) or 'AUTOMATIC'
		local point = direction == 'AUTOMATIC' and E:GetScreenQuadrant(actionbar)
		if point == 'UNKNOWN' then return end

		local noCombat = not InCombatLockdown()
		if direction == 'DOWN' or (point and strfind(point, 'TOP')) then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point('BOTTOM', button, 'BOTTOM', 0, -arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if noCombat then button:SetAttribute('flyoutDirection', 'DOWN') end
		elseif direction == 'LEFT' or point == 'RIGHT' then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point('LEFT', button, 'LEFT', -arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if noCombat then button:SetAttribute('flyoutDirection', 'LEFT') end
		elseif direction == 'RIGHT' or point == 'LEFT' then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point('RIGHT', button, 'RIGHT', arrowDistance, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if noCombat then button:SetAttribute('flyoutDirection', 'RIGHT') end
		elseif direction == 'UP' or point == 'CENTER' or (point and strfind(point, 'BOTTOM')) then
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:Point('TOP', button, 'TOP', 0, arrowDistance)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if noCombat then button:SetAttribute('flyoutDirection', 'UP') end
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
		if button._state_type == 'action' then
			local _, duration = button:GetCooldown()
			AB:UpdateChargeCooldown(button, duration)
			AB:SetButtonDesaturation(button, duration)
		end
	end
end

function AB:SetButtonDesaturation(button, duration)
	if button.LevelLinkLockIcon:IsShown() then
		button.saturationLocked = nil
		return
	end

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
	button:HookScript('OnMouseUp', AB.LAB_MouseUp)
	button:HookScript('OnMouseDown', AB.LAB_MouseDown)
end

function AB:LAB_ButtonUpdate(button)
	local db = button.db
	local color = db and db.useCountColor and db.countColor or AB.db.fontColor

	button.Count:SetTextColor(color.r, color.g, color.b)

	if button.SetBackdropBorderColor then
		local border = (AB.db.equippedItem and button:IsEquipped() and AB.db.equippedItemColor) or E.db.general.bordercolor
		button:SetBackdropBorderColor(border.r, border.g, border.b)
	end
end

function AB:LAB_UpdateRange(button)
	AB:UpdateHotkeyColor(button)
end

function AB:LAB_CooldownDone(button)
	AB:SetButtonDesaturation(button, 0)
end

function AB:LAB_CooldownUpdate(button, _, duration)
	if button._state_type == 'action' then
		AB:UpdateChargeCooldown(button, duration)
		AB:SetButtonDesaturation(button, duration)
	end

	if button.cooldown then
		AB:ColorSwipeTexture(button.cooldown)
	end
end

function AB:PLAYER_ENTERING_WORLD()
	AB:AdjustMaxStanceButtons('PLAYER_ENTERING_WORLD')
end

function AB:Initialize()
	AB.db = E.db.actionbar

	if not E.private.actionbar.enable then return end
	AB.Initialized = true

	LAB.RegisterCallback(AB, 'OnButtonUpdate', AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, 'OnUpdateRange', AB.LAB_UpdateRange)
	LAB.RegisterCallback(AB, 'OnButtonCreated', AB.LAB_ButtonCreated)
	LAB.RegisterCallback(AB, 'OnChargeCreated', AB.LAB_ChargeCreated)
	LAB.RegisterCallback(AB, 'OnCooldownUpdate', AB.LAB_CooldownUpdate)
	LAB.RegisterCallback(AB, 'OnCooldownDone', AB.LAB_CooldownDone)

	AB.fadeParent = CreateFrame('Frame', 'Elv_ABFade', _G.UIParent)
	AB.fadeParent:SetAlpha(1 - AB.db.globalFadeAlpha)
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_DISABLED')
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_ENABLED')
	AB.fadeParent:RegisterEvent('PLAYER_TARGET_CHANGED')
	AB.fadeParent:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
	AB.fadeParent:RegisterEvent('UPDATE_POSSESS_BAR')
	AB.fadeParent:RegisterEvent('VEHICLE_UPDATE')
	AB.fadeParent:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_HEALTH', 'player')
	AB.fadeParent:RegisterEvent('PLAYER_FOCUS_CHANGED')
	AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)

	if E.locale == 'koKR' then
		defaultFont, defaultFontSize, defaultFontOutline = [[Fonts\2002.TTF]], 11, "MONOCHROME, THICKOUTLINE"
	elseif E.locale == 'zhTW' then
		defaultFont, defaultFontSize, defaultFontOutline = [[Fonts\arheiuhk_bd.TTF]], 11, "MONOCHROME, THICKOUTLINE"
	elseif E.locale == 'zhCN' then
		defaultFont, defaultFontSize, defaultFontOutline = [[Fonts\FRIZQT__.TTF]], 11, 'MONOCHROME, OUTLINE'
	else
		defaultFont, defaultFontSize, defaultFontOutline = [[Fonts\ARIALN.TTF]], 12, "MONOCHROME, THICKOUTLINE"
	end

	AB:DisableBlizzard()
	AB:SetupExtraButton()
	AB:SetupMicroBar()

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

	AB:RegisterEvent('PLAYER_ENTERING_WORLD')
	AB:RegisterEvent('UPDATE_BINDINGS', 'ReassignBindings')
	AB:RegisterEvent('PET_BATTLE_CLOSE', 'ReassignBindings')
	AB:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')
	AB:RegisterEvent('SPELL_UPDATE_COOLDOWN', 'UpdateSpellBookTooltip')

	if _G.KeyBindingFrame then
		AB:SwapKeybindButton()
	else
		AB:RegisterEvent('ADDON_LOADED', 'SwapKeybindButton')
	end

	if C_PetBattles_IsInBattle() then
		AB:RemoveBindings()
	else
		AB:ReassignBindings()
	end

	-- We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	SetCVar('lockActionBars', (AB.db.lockActionBars == true and 1 or 0))
	_G.LOCK_ACTIONBAR = (AB.db.lockActionBars == true and '1' or '0') -- Keep an eye on this, in case it taints

	hooksecurefunc(_G.SpellFlyout, 'Show', AB.UpdateFlyoutButtons)
	_G.SpellFlyout:HookScript('OnEnter', AB.SpellFlyout_OnEnter)
	_G.SpellFlyout:HookScript('OnLeave', AB.SpellFlyout_OnLeave)
end

E:RegisterModule(AB:GetName())
