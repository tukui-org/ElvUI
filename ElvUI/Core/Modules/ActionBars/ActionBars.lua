local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G, wipe = _G, wipe
local ipairs, pairs, strmatch, next, unpack, tonumber = ipairs, pairs, strmatch, next, unpack, tonumber
local format, gsub, strsplit, strfind, strsub, strupper = format, gsub, strsplit, strfind, strsub, strupper

local ClearOnBarHighlightMarks = ClearOnBarHighlightMarks
local ClearOverrideBindings = ClearOverrideBindings
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetOverrideBarIndex = GetOverrideBarIndex
local GetTempShapeshiftBarIndex = GetTempShapeshiftBarIndex
local GetVehicleBarIndex = GetVehicleBarIndex
local HasOverrideActionBar = HasOverrideActionBar
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local InClickBindingMode = InClickBindingMode
local InCombatLockdown = InCombatLockdown
local IsItemAction = IsItemAction
local IsPossessBarVisible = IsPossessBarVisible
local PetDismiss = PetDismiss
local RegisterStateDriver = RegisterStateDriver
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local SetClampedTextureRotation = SetClampedTextureRotation
local SetModifiedClick = SetModifiedClick
local SetOverrideBindingClick = SetOverrideBindingClick
local UIParent = UIParent
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
local SaveBindings = SaveBindings
local VehicleExit = VehicleExit

local SPELLS_PER_PAGE = SPELLS_PER_PAGE
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL
local CLICK_BINDING_NOT_AVAILABLE = CLICK_BINDING_NOT_AVAILABLE
local BINDING_SET = Enum.BindingSet

local GetNextCastSpell = C_AssistedCombat and C_AssistedCombat.GetNextCastSpell
local GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo or GetSpellBookItemInfo
local ClearPetActionHighlightMarks = ClearPetActionHighlightMarks or PetActionBar.ClearPetActionHighlightMarks

local GetProfessionQuality = C_ActionBar.GetProfessionQuality
local IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local C_PlayerInfo_GetGlidingInfo = C_PlayerInfo.GetGlidingInfo
local FindSpellBookSlotForSpell = C_SpellBook.FindSpellBookSlotForSpell or SpellBook_GetSpellBookSlot
local ActionBarController_UpdateAllSpellHighlights = ActionBarController_UpdateAllSpellHighlights

local GetCVarBool = C_CVar.GetCVarBool

local LAB = E.Libs.LAB
local LSM = E.Libs.LSM
local LCG = E.Libs.CustomGlow
local Masque = E.Masque
local FlyoutMasqueGroup = Masque and Masque:Group('ElvUI', 'ActionBar Flyouts')
local VehicleMasqueGroup = Masque and Masque:Group('ElvUI', 'ActionBar Leave Vehicle')

local buttonDefaults = {
	hideElements = {},
	colors = {},
	text = {
		hotkey = { font = {}, color = {}, position = {} },
		count = { font = {}, color = {}, position = {} },
		macro = { font = {}, color = {}, position = {} },
	},
}

AB.RegisterCooldown = E.RegisterCooldown
AB.handledBars = {} --List of all bars
AB.handledbuttons = {} --List of all buttons that have been modified.
AB.barDefaults = {
	bar1 = { page = 1, bindButtons = 'ACTIONBUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-1,191' },
	bar2 = { page = 2, bindButtons = 'ELVUIBAR2BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,0,4' },
	bar3 = { page = 3, bindButtons = 'MULTIACTIONBAR3BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-1,139' },
	bar4 = { page = 4, bindButtons = 'MULTIACTIONBAR4BUTTON', position = 'RIGHT,ElvUIParent,RIGHT,-4,0' },
	bar5 = { page = 5, bindButtons = 'MULTIACTIONBAR2BUTTON', position = 'BOTTOM,ElvUIParent,BOTTOM,-279,4' },
	bar6 = { page = 6, bindButtons = 'MULTIACTIONBAR1BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,264' },
	bar7 = { page = 7, bindButtons = 'ELVUIBAR7BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,298' },
	bar8 = { page = 8, bindButtons = 'ELVUIBAR8BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,332' },
	bar9 = { page = 9, bindButtons = 'ELVUIBAR9BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,366' },
	bar10 = { page = 10, bindButtons = 'ELVUIBAR10BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar13 = { page = 13, bindButtons = 'MULTIACTIONBAR5BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar14 = { page = 14, bindButtons = 'MULTIACTIONBAR6BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' },
	bar15 = { page = 15, bindButtons = 'MULTIACTIONBAR7BUTTON', position = 'BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-4,400' }
}

do
	-- https://github.com/Gethe/wow-ui-source/blob/6eca162dbca161e850b735bd5b08039f96caf2df/Interface/FrameXML/OverrideActionBar.lua#L136
	local fullConditions = (E.Retail or E.Mists) and format('[overridebar] %d; [vehicleui][possessbar] %d;', GetOverrideBarIndex(), GetVehicleBarIndex()) or ''
	AB.barDefaults.bar1.conditions = fullConditions..format('[shapeshift] %d; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:5] 11;', GetTempShapeshiftBarIndex())
end

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
			local offset = ((oldHeight - backdropSpacing + buttonSpacing) * (heightMult - 1)) - (backdropSpacing * (heightMult - 2))
			local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
			bar.backdrop:Point(anchorPoint, lastShownButton, anchorPoint, 0, anchorUp and offset or -offset)
		end
		if useWidthMult then
			local offset = ((oldWidth - backdropSpacing + buttonSpacing) * (widthMult - 1)) - (backdropSpacing * (widthMult - 2))
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
	button:SetAttribute('showgrid', 1)
	button:EnableMouse(not db.clickThrough)
	button:Size(buttonWidth, buttonHeight)

	button:ClearAllPoints()
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
	local icon = button.icon or button.Icon
	if not icon then return end

	if button.db and not button.db.keepSizeRatio then
		local width, height = button:GetSize()
		local left, right, top, bottom = E:CropRatio(width, height)
		icon:SetTexCoord(left, right, top, bottom)
	elseif not masque then
		icon:SetTexCoord(unpack(E.TexCoords))
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

function AB:ActivePages(page)
	local pages = {}
	local clean = gsub(page, '%[.-]', '')

	for _, index in next, { strsplit(';', clean) } do
		local num = tonumber(index)
		if num then
			pages[num] = true
		end
	end

	return pages
end

function AB:HandleButtonState(button, index, vehicleIndex, pages)
	for k = 1, 18 do
		if pages and pages[k] then
			button:SetState(k, 'action', (k - 1) * 12 + index)
		else
			button:SetState(k, 'empty')
		end
	end

	if pages and vehicleIndex and index == 12 then
		button:SetState(vehicleIndex, 'custom', AB.customExitButton)
	end
end

function AB:PositionAndSizeBar(barName)
	local db = AB.db[barName]
	local bar = AB.handledBars[barName]

	local enabled = db.enabled
	local buttonSpacing = db.buttonSpacing
	local backdropSpacing = db.backdropSpacing
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local point = db.point

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
	local vehicleIndex = (E.Retail or E.Mists) and GetVehicleBarIndex()

	-- paging needs to be updated even if the bar is disabled
	local defaults = AB.barDefaults[barName]
	local page = AB:GetPage(barName, defaults.page, defaults.conditions)
	RegisterStateDriver(bar, 'page', page)
	bar:SetAttribute('page', page)

	local reticleColor = E:UpdateClassColor(AB.db.targetReticleColor)
	local pages = enabled and AB:ActivePages(page) or nil
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

		local targetReticle = button.TargetReticleAnimFrame
		if targetReticle then
			targetReticle.Base:SetVertexColor(reticleColor.r, reticleColor.g, reticleColor.b)
		end

		AB:HandleButtonState(button, i, vehicleIndex, pages)
		AB:HandleButton(bar, button, i, lastButton, lastColumnButton)
		AB:StyleButton(button, nil, bar.MasqueGroup and E.private.actionbar.masque.actionbars)
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	if Masque and E.private.actionbar.masque.actionbars then
		AB:UpdateMasque(bar)
	end

	if enabled then
		E:EnableMover(bar.mover.name)
		bar:Show()

		local visibility = gsub(db.visibility, '[\n\r]', '')
		RegisterStateDriver(bar, 'visibility', visibility)
	else
		E:DisableMover(bar.mover.name)
		bar:Hide()

		UnregisterStateDriver(bar, 'visibility')
	end

	E:SetMoverSnapOffset('ElvAB_'..bar.id, db.buttonSpacing * 0.5)
end

function AB:CreateBar(id)
	local barName = 'ElvUI_Bar'..id
	local bar = CreateFrame('Frame', barName, E.UIParent, 'SecureHandlerStateTemplate')
	if not E.Retail then
		SecureHandlerSetFrameRef(bar, 'MainMenuBarArtFrame', _G.MainMenuBarArtFrame)
	end

	bar.MasqueGroup = Masque and Masque:Group('ElvUI', format('ActionBar %d', id))

	local barKey = 'bar'..id
	AB.handledBars[barKey] = bar

	local defaults = AB.barDefaults[barKey]
	local point, anchor, attachTo, x, y = strsplit(',', defaults.position)
	bar:Point(point, anchor, attachTo, x, y)
	bar.id = id

	bar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, nil, 0)

	bar.buttons = {}
	bar.bindButtons = defaults.bindButtons
	AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	for i = 1, 12 do
		local button = LAB:CreateButton(i, format('%sButton%d', barName, i), bar)

		button.AuraCooldown.targetAura = true
		E:RegisterCooldown(button.AuraCooldown, 'actionbar')

		if E.Retail then
			button.ProfessionQualityOverlayFrame = CreateFrame('Frame', nil, button, 'ActionButtonProfessionOverlayTemplate')
		end

		local targetReticle = button.TargetReticleAnimFrame
		if targetReticle then
			targetReticle:SetAllPoints()

			targetReticle.Base:SetTexCoord(unpack(E.TexCoords))
			targetReticle.Base:SetTexture(E.Media.Textures.TargetReticle)
			targetReticle.Base:SetInside()

			targetReticle.Highlight:SetInside()
		end

		button.MasqueSkinned = true -- skip LAB styling (we handle it and masque as well)

		if Masque and E.private.actionbar.masque.actionbars then
			button:AddToMasque(bar.MasqueGroup)
		end

		AB:HookScript(button, 'OnEnter', 'Button_OnEnter')
		AB:HookScript(button, 'OnLeave', 'Button_OnLeave')

		button.parentName = barName
		bar.buttons[i] = button
	end

	if defaults.conditions and strfind(defaults.conditions, '[form,noform]') then
		bar:SetAttribute('newCondition', gsub(defaults.conditions, ' %[form,noform%] 0; ', ''))
		bar:SetAttribute('hasTempBar', true)
	else
		bar:SetAttribute('hasTempBar', false)
	end

	bar:SetAttribute('_onstate-page', [[
		if newstate == 'possess' or newstate == '11' then
			if HasVehicleActionBar() then
				newstate = GetVehicleBarIndex()
			elseif HasOverrideActionBar() then
				newstate = GetOverrideBarIndex()
			elseif HasTempShapeshiftActionBar() then
				newstate = GetTempShapeshiftBarIndex()
			elseif HasBonusActionBar() then
				newstate = GetBonusBarIndex()
			else
				newstate = 12
			end
		end

		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
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

	if AB.NeedsExtraButtonsReparent then
		AB:ExtraButtons_Reparent()
		AB.NeedsExtraButtonsReparent = nil
	end

	if AB.NeedsExtraButtonsRescale then
		AB:ExtraButtons_UpdateScale()
		AB.NeedsExtraButtonsRescale = nil
	end

	AB:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function AB:CreateVehicleLeave()
	local db = E.db.actionbar.vehicleExitButton
	if not db.enable then return end

	local button = _G.MainMenuBarVehicleLeaveButton
	local holder = CreateFrame('Frame', 'VehicleLeaveButtonHolder', E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 0, 300)
	holder:Size(button:GetSize())
	E:CreateMover(holder, 'VehicleLeaveButton', L["VehicleLeaveButton"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,vehicleExitButton')

	button:ClearAllPoints()
	button:SetParent(UIParent)
	button:Point('CENTER', holder)

	-- taints because of EditModeManager, in UpdateBottomActionBarPositions
	button:SetScript('OnShow', nil)
	button:SetScript('OnHide', nil)
	button:KillEditMode()

	if Masque and E.private.actionbar.masque.actionbars then
		button:StyleButton(true, true, true)
		VehicleMasqueGroup:AddButton(button)
	else
		button:CreateBackdrop(nil, true)
		button:GetNormalTexture():SetTexCoord(0.140625 + .08, 0.859375 - .06, 0.140625 + .08, 0.859375 - .08)
		button:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		button:StyleButton(nil, true, true)

		hooksecurefunc(button, 'SetHighlightTexture', function(btn, tex)
			if tex ~= btn.hover then
				button:SetHighlightTexture(btn.hover)
			end
		end)
	end

	hooksecurefunc(button, 'SetPoint', function(_, _, parent)
		if parent ~= holder then
			button:ClearAllPoints()
			button:SetParent(UIParent)
			button:Point('CENTER', holder)
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

	if Masque and E.private.actionbar.masque.actionbars then
		AB:UpdateMasque(nil, VehicleMasqueGroup)
	end
end

function AB:ReassignBindings(event)
	if event == 'UPDATE_BINDINGS' then
		AB:UpdatePetBindings()
		AB:UpdateStanceBindings()

		if E.Retail then
			AB:UpdateExtraBindings()
		end
	end

	AB:UnregisterEvent('PLAYER_REGEN_DISABLED')

	if InCombatLockdown() then return end

	for _, bar in pairs(AB.handledBars) do
		if bar then
			ClearOverrideBindings(bar)

			for _, button in ipairs(bar.buttons) do
				if button.keyBoundTarget then
					for _, key in next, { GetBindingKey(button.keyBoundTarget) } do
						if key ~= '' then
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

	local function SaveSetting(option, value)
		for i = 1, 10 do
			E.db.actionbar['bar'..i][option] = value
		end

		for i = 13, 15 do
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
				SaveSetting(object..upperOption, value)
			end
		else
			SaveSetting(option, value)
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
			AB:PositionAndSizeBar(barName) -- db is set here, button style, and paging also runs here

			for _, button in ipairs(bar.buttons) do
				AB:StyleFlyout(button)

				if button.ProfessionQualityOverlayFrame then
					AB:ConfigureProfessionQuality(button)
				end
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

		if E.Retail then
			AB:UpdateExtraBindings()
			AB:UpdateFlyoutButtons()

			-- handle LAB custom flyout button sizes again
			if LAB.FlyoutButtons then
				AB:LAB_FlyoutSpells()
			end
		end
	end
end

function AB:GetPage(bar, defaultPage, condition)
	if not condition then condition = '' end

	local page = AB.db[bar].paging[E.myclass]
	if page then condition = condition..' '..gsub(page, '[\n\r]', '') end

	return condition..' '..defaultPage
end

function AB:StyleButton(button, noBackdrop, useMasque, ignoreNormal)
	local name = button:GetName()
	local icon = button.icon or _G[name..'Icon']
	local hotkey = button.HotKey or _G[name..'HotKey']
	local shine = button.AutoCastShine or _G[name..'Shine']
	local flash = button.Flash or _G[name..'Flash']
	local border = button.Border or _G[name..'Border']
	local normal = button.NormalTexture or _G[name..'NormalTexture']
	local normal2 = button:GetNormalTexture()
	local slotbg = button.SlotBackground
	local action = button.NewActionTexture
	local mask = button.IconMask

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.ignoreNormal = ignoreNormal

	icon:SetDrawLayer('ARTWORK', -1)
	hotkey:SetDrawLayer('OVERLAY')
	hotkey:SetParent(button) -- otherwise its on level 500 thanks to ActionButtonTextOverlayContainerMixin

	if normal and not ignoreNormal then normal:SetTexture() normal:Hide() normal:SetAlpha(0) end
	if normal2 then normal2:SetTexture() normal2:Hide() normal2:SetAlpha(0) end
	if border and not button.useMasque then border:Kill() end
	if action then action:SetAlpha(0) end
	if slotbg then slotbg:Hide() end
	if mask and not useMasque then mask:Hide() end

	if not noBackdrop and not useMasque then
		button:SetTemplate(AB.db.transparent and 'Transparent', true)
	end

	if flash then
		if AB.db.flashAnimation then
			local flashOffset = E.PixelMode and 2 or 4

			flash:SetColorTexture(1.0, 0.2, 0.2, 0.45)
			flash:ClearAllPoints()
			flash:SetOutside(icon, flashOffset, flashOffset)
			flash:SetDrawLayer('BACKGROUND', -1)
		else
			flash:SetTexture()
		end
	end

	if useMasque then -- note: trim handled after masque messes with it
		button:StyleButton(true, true, true)
	else
		button:StyleButton()
		AB:TrimIcon(button)
		icon:SetInside()
	end

	if shine then
		shine:SetAllPoints()
	end

	if button.SpellHighlightTexture then
		button.SpellHighlightTexture:SetColorTexture(1, 1, 0, 0.45)
		button.SpellHighlightTexture:SetAllPoints()
	end

	if not AB.handledbuttons[button] then
		E:RegisterCooldown(button.cooldown, 'actionbar')
		AB.handledbuttons[button] = true
	end

	if button.style then -- Boss Button
		button.style:SetDrawLayer('BACKGROUND', -7)
	end

	AB:FixKeybindText(button)

	if button.ProfessionQualityOverlayFrame then
		AB:UpdateProfessionQuality(button)
	end
end

function AB:UpdateMasque(bar, masqueGroup)
	local masque = (bar and bar.MasqueGroup) or masqueGroup
	masque:ReSkin()

	if bar and bar.buttons then -- masque retrims them all so we have to too
		for _, btn in next, bar.buttons do
			AB:TrimIcon(btn, true)
		end
	end
end

function AB:ConfigureProfessionQuality(button)
	local db = button.db and button.db.professionQuality
	if db then
		button.ProfessionQualityOverlayFrame:ClearAllPoints()
		button.ProfessionQualityOverlayFrame:Point(db.point, db.xOffset, db.yOffset)
		button.ProfessionQualityOverlayFrame:SetAlpha(db.alpha)
		button.ProfessionQualityOverlayFrame:SetScale(db.scale)
	end
end

function AB:UpdateProfessionQuality(button)
	local db, atlas = button.db and button.db.professionQuality
	local enable = db and db.enable
	if enable then
		local action = button._state_type == 'action' and button._state_action
		local quality = action and IsItemAction(action) and GetProfessionQuality(action)
		atlas = quality and format('Professions-Icon-Quality-Tier%d', quality)

		if atlas then
			button.ProfessionQualityOverlayFrame.Texture:SetAtlas(atlas, true)
		end
	end

	button.ProfessionQualityOverlayFrame:SetShown(enable and not not atlas)
end

function AB:ColorSwipeTexture(cooldown)
	if not cooldown then return end

	local color = (cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL and AB.db.colorSwipeLOC) or AB.db.colorSwipeNormal
	cooldown:SetSwipeColor(color.r, color.g, color.b, color.a)
end

function AB:FadeBlingTexture(cooldown, alpha)
	if not cooldown then return end
	cooldown:SetBlingTexture(alpha > 0.5 and (E.Retail and 131010 or [[interface\cooldown\star4.blp]]) or E.Media.Textures.Invisible)
end

function AB:FadeBlings(alpha)
	if AB.db.hideCooldownBling then return end

	for _, bar in next, { AB.fadeParent:GetChildren() } do
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
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha or 1)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Bar_OnLeave(bar)
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - (AB.db.globalFadeAlpha or 0)
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
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), bar.db.alpha or 1)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end
end

function AB:Button_OnLeave(button)
	local bar = button:GetParent()
	if bar:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		local a = 1 - (AB.db.globalFadeAlpha or 0)
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

do
	local function CanGlide() -- required when reloading because the event wont fire yet
		local isGliding, canGlide = C_PlayerInfo_GetGlidingInfo()
		return isGliding or canGlide
	end

	local canGlide = false -- sometimes the Vigor bar is not activated yet
	function AB:FadeParent_OnEvent(event, arg)
		if event == 'PLAYER_CAN_GLIDE_CHANGED' then
			canGlide = arg
		end

		if (E.Retail and (canGlide or CanGlide() or IsPossessBarVisible() or HasOverrideActionBar()))
		or UnitCastingInfo('player') or UnitChannelInfo('player') or UnitExists('target') or UnitExists('focus')
		or UnitExists('vehicle') or UnitAffectingCombat('player') or (UnitHealth('player') ~= UnitHealthMax('player')) then
			self.mouseLock = true
			E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
			AB:FadeBlings(1)
		else
			self.mouseLock = false
			local a = 1 - (AB.db.globalFadeAlpha or 0)
			E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), a)
			AB:FadeBlings(a)
		end
	end
end

do -- these calls are tainted when accessed by ValidateActionBarTransition
	local noops = { 'ClearAllPoints', 'SetPoint', 'SetScale', 'SetShown' }
	function AB:SetNoopsi(frame)
		if not frame then return end
		for _, func in pairs(noops) do
			if frame[func] ~= E.noop then
				frame[func] = E.noop
			end
		end
	end
end

do
	local function BindOnEnter(button)
		AB:BindUpdate(button, 'SPELL')
	end

	local function FixButton(button)
		if E.Retail then
			if button.OnIconEnter == AB.SpellButtonOnEnter then
				return -- don't do this twice, ever
			end

			button.OnIconEnter = AB.SpellButtonOnEnter
			button.OnIconLeave = AB.SpellButtonOnLeave

			local spellButton = button.Button
			if spellButton then -- actual spell button
				if spellButton.BorderShadow then
					spellButton.BorderShadow:SetAlpha(0)
				end

				spellButton:HookScript('OnEnter', BindOnEnter)
			end
		else
			if button.OnEnter == AB.SpellButtonOnEnter then
				return -- don't do this twice, ever
			end

			button:SetScript('OnEnter', AB.SpellButtonOnEnter)
			button:SetScript('OnLeave', AB.SpellButtonOnLeave)

			button.OnEnter = AB.SpellButtonOnEnter
			button.OnLeave = AB.SpellButtonOnLeave

			for i = 1, 12 do
				_G['SpellButton'..i]:HookScript('OnEnter', BindOnEnter)
			end

			AB:StyleFlyout(button) -- not a part of the taint fix, this just gets the arrows in line
		end
	end

	local function SetTab()
		local spellbook = _G.PlayerSpellsFrame.SpellBookFrame
		if not (spellbook and spellbook.PagedSpellsFrame) then return end

		for _, frame in spellbook.PagedSpellsFrame:EnumerateFrames() do
			if frame.HasValidData and frame:HasValidData() then -- Avoid header or spacer frames
				FixButton(frame)
			end
		end
	end

	function AB:FixSpellBookTaint() -- let spell book buttons work without tainting by replacing this function
		if E.Retail then -- same deal with profession buttons, this will fix the tainting
			hooksecurefunc(_G.PlayerSpellsFrame.SpellBookFrame, 'SetTab', SetTab)
		else
			for i = 1, SPELLS_PER_PAGE do
				local button = _G['SpellButton'..i]
				if button then
					FixButton(button)
				end
			end
		end
	end
end

function AB:SpellBookTooltipOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < TOOLTIP_UPDATE_TIME then return end
	self.elapsed = 0

	local owner = self:GetOwner()
	if owner then AB.SpellButtonOnEnter(owner) end
end

function AB:SpellButtonOnEnter(_, tt)
	-- TT:MODIFIER_STATE_CHANGED uses this function to safely update the spellbook tooltip when the actionbar module is disabled
	if not tt then tt = E.SpellBookTooltip end

	if tt:IsForbidden() then return end
	tt:SetOwner(self, self.Button and 'ANCHOR_CURSOR' or 'ANCHOR_RIGHT') -- 11.0 fix this more

	if E.Retail and InClickBindingMode() and not self.canClickBind then
		tt:AddLine(CLICK_BINDING_NOT_AVAILABLE, 1, .3, .3)
		tt:Show()
		return
	end

	local slotIndex = self.slotIndex or (FindSpellBookSlotForSpell and FindSpellBookSlotForSpell(self))
	local slotBank = self.spellBank or (_G.SpellBookFrame and _G.SpellBookFrame.bookType)
	if not (slotIndex and slotBank) then return end -- huh?

	local needsUpdate = tt:SetSpellBookItem(slotIndex, slotBank) -- need this here when its GameTooltip

	local highlight = self.SpellHighlightTexture
	if highlight and highlight:IsShown() then
		local color = _G.LIGHTBLUE_FONT_COLOR
		tt:AddLine(_G.SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, color.r, color.g, color.b)
	end

	if tt == E.SpellBookTooltip then
		tt:SetScript('OnUpdate', (needsUpdate and AB.SpellBookTooltipOnUpdate) or nil)
	end

	if E.Retail then
		ClearOnBarHighlightMarks()
		ClearPetActionHighlightMarks()

		local slotType, actionID = GetSpellBookItemInfo(slotIndex, slotBank)
		if slotType == 'SPELL' then
			UpdateOnBarHighlightMarksBySpell(actionID)
		elseif slotType == 'FLYOUT' then
			UpdateOnBarHighlightMarksByFlyout(actionID) -- Cata Flyout one will error cause its not updated
		elseif slotType == 'PETACTION' then
			UpdateOnBarHighlightMarksByPetAction(actionID)

			if UpdatePetActionHighlightMarks then
				UpdatePetActionHighlightMarks(actionID)
			else
				_G.PetActionBar:UpdatePetActionHighlightMarks(actionID)
			end
		end

		if ActionBarController_UpdateAllSpellHighlights then
			ActionBarController_UpdateAllSpellHighlights()
		end
	end

	tt:Show()
end

function AB:UpdateSpellBookTooltip(event)
	-- only need to check the shown state when its not called from TT:MODIFIER_STATE_CHANGED which already checks the shown state
	local button = (not event or E.SpellBookTooltip:IsShown()) and E.SpellBookTooltip:GetOwner()
	if button then AB.SpellButtonOnEnter(button) end
end

function AB:SpellButtonOnLeave()
	ClearOnBarHighlightMarks()
	ClearPetActionHighlightMarks()

	if ActionBarController_UpdateAllSpellHighlights then
		ActionBarController_UpdateAllSpellHighlights()
	end

	E.SpellBookTooltip:Hide()
	E.SpellBookTooltip:SetScript('OnUpdate', nil)
end

function AB:ButtonEventsRegisterFrame(added)
	local frames = _G.ActionBarButtonEventsFrame.frames
	for index = #frames, 1, -1 do
		local frame = frames[index]
		local wasAdded = frame == added
		if not added or wasAdded then
			if not strmatch(frame:GetName(), 'ExtraActionButton%d') then
				frames[index] = nil
			end

			if wasAdded then
				break
			end
		end
	end
end

function AB:IconIntroTracker_Skin()
	local l, r, t, b = unpack(E.TexCoords)
	for _, iconIntro in ipairs(self.iconList) do
		if not iconIntro.IsSkinned then
			iconIntro.trail1.icon:SetTexCoord(l, r, t, b)
			iconIntro.trail1.bg:SetTexCoord(l, r, t, b)

			iconIntro.trail2.icon:SetTexCoord(l, r, t, b)
			iconIntro.trail2.bg:SetTexCoord(l, r, t, b)

			iconIntro.trail3.icon:SetTexCoord(l, r, t, b)
			iconIntro.trail3.bg:SetTexCoord(l, r, t, b)

			iconIntro.icon.icon:SetTexCoord(l, r, t, b)
			iconIntro.icon.bg:SetTexCoord(l, r, t, b)

			iconIntro.IsSkinned = true
		end
	end
end

do
	local untaint = {
		MultiBar5 = true,
		MultiBar6 = true,
		MultiBar7 = true,
		MultiBarLeft = true,
		MultiBarRight = true,
		MultiBarBottomLeft = true,
		MultiBarBottomRight = true,
		MicroButtonAndBagsBar = true,
		OverrideActionBar = true,
		MainMenuBar = true,
		[E.Retail and 'StanceBar' or 'StanceBarFrame'] = true,
		[E.Retail and 'PetActionBar' or 'PetActionBarFrame'] = true,
		[E.Retail and 'PossessActionBar' or 'PossessBarFrame'] = true
	}

	local untaintButtons = {
		MultiCastActionButton = (E.Mists and E.myclass ~= 'SHAMAN') or nil,
		OverrideActionBarButton = E.Mists or nil
	}

	local settingsHider = CreateFrame('Frame')
	settingsHider:SetScript('OnEvent', function(frame, event)
		HideUIPanel(_G.SettingsPanel)
		frame:UnregisterEvent(event)
	end)

	local function SettingsListScrollUpdateChild(child)
		local option = child.data and child.data.setting
		local variable = option and option.variable
		if variable and strsub(variable, 0, -3) == 'PROXY_SHOW_ACTIONBAR' then
			local num = tonumber(strsub(variable, 22))
			if num and num <= 5 then -- NUM_ACTIONBAR_PAGES - 1
				child.Text:SetFormattedText(L["Remove Bar %d Action Page"], num)
			else
				child.Checkbox:SetEnabled(false)
				child:DisplayEnabled(false)
			end
		end
	end

	local function SettingsListScrollUpdate(frame)
		frame:ForEachFrame(SettingsListScrollUpdateChild)
	end

	function AB:SettingsPanel_OnHide()
		self:Flush()
		self:ClearActiveCategoryTutorial()

		_G.UpdateMicroButtons() -- keep this to maintain the hook

		if not InCombatLockdown() then
			local checked = _G.Settings.GetValue('PROXY_CHARACTER_SPECIFIC_BINDINGS')
			local bindingSet = checked and BINDING_SET.Character or BINDING_SET.Account
			SaveBindings(bindingSet)
		end

		if not E.Classic then
			_G.EventRegistry:TriggerEvent('SettingsPanel.OnHide')
		end
	end

	function AB:SettingsPanel_TransitionBackOpeningPanel()
		if InCombatLockdown() then
			settingsHider:RegisterEvent('PLAYER_REGEN_ENABLED')
			self:SetScale(0.00001)
		else
			HideUIPanel(self)
		end
	end

	function AB:DisableBlizzard()
		for name in next, untaint do
			if not E.Retail then
				_G.UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
			end

			local frame = _G[name]
			if frame then
				frame:SetParent(E.HiddenFrame)
				frame:UnregisterAllEvents()

				if not E.Retail then
					AB:SetNoopsi(frame)
				elseif name == 'PetActionBar' then -- EditMode messes with it, be specific otherwise bags taint
					frame.UpdateVisibility = E.noop
				end
			end
		end

		if not E.Retail then
			AB:FixSpellBookTaint()
		end

		-- shut down some events for things we dont use
		_G.ActionBarController:UnregisterAllEvents()
		_G.ActionBarController:RegisterEvent('SETTINGS_LOADED') -- this is needed for page controller to spawn properly

		_G.ActionBarActionEventsFrame:UnregisterAllEvents()
		_G.ActionBarButtonEventsFrame:UnregisterAllEvents()

		-- used for ExtraActionButton
		_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED') -- needed to let the ExtraActionButton show
		_G.ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN') -- needed for cooldowns of them both

		-- modified to fix a taint when closing the options while in combat
		_G.SettingsPanel:SetScript('OnHide', AB.SettingsPanel_OnHide)

		if E.Retail then
			_G.StatusTrackingBarManager:Kill()
			_G.ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show

			-- take encounter bar out of edit mode
			_G.EncounterBar:KillEditMode()

			-- lets only keep ExtraActionButtons in here
			hooksecurefunc(_G.ActionBarButtonEventsFrame, 'RegisterFrame', AB.ButtonEventsRegisterFrame)
			AB.ButtonEventsRegisterFrame()

			-- crop the new spells being added to the actionbars
			_G.IconIntroTracker:HookScript('OnEvent', AB.IconIntroTracker_Skin)

			-- dont reopen game menu and fix settings panel not being able to close during combat
			_G.SettingsPanel.TransitionBackOpeningPanel = AB.SettingsPanel_TransitionBackOpeningPanel

			-- change the text of the remove paging
			hooksecurefunc(_G.SettingsPanel.Container.SettingsList.ScrollBox, 'Update', SettingsListScrollUpdate)
		else
			AB:SetNoopsi(_G.MainMenuBarArtFrame)
			AB:SetNoopsi(_G.MainMenuBarArtFrameBackground)
			_G.MainMenuBarArtFrame:UnregisterAllEvents()

			-- this would taint along with the same path as the SetNoopers: ValidateActionBarTransition
			_G.VerticalMultiBarsContainer:Size(10) -- dummy values so GetTop etc doesnt fail without replacing
			AB:SetNoopsi(_G.VerticalMultiBarsContainer)
		end

		for name in next, untaintButtons do
			local index = 1
			local button = _G[name..index]
			while button do
				button:Hide()
				button:UnregisterAllEvents()
				button:SetAttribute('statehidden', true)

				index = index + 1
				button = _G[name..index]
			end
		end

		if E.Retail or E.Mists then
			if _G.PlayerTalentFrame then
				_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
			else
				hooksecurefunc('TalentFrame_LoadUI', function()
					_G.PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
				end)
			end
		end
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

function AB:GetTextJustify(anchor)
	return (anchor == 'TOPLEFT' or anchor == 'BOTTOMLEFT') and 'LEFT' or (anchor == 'TOP' or anchor == 'BOTTOM') and 'CENTER' or 'RIGHT'
end

function AB:GetHotkeyConfig(db)
	local font = LSM:Fetch('font', db and db.hotkeyFont or AB.db.font)
	local size = db and db.hotkeyFontSize or AB.db.fontSize
	local flags = db and db.hotkeyFontOutline or AB.db.font

	local anchor = db and db.hotkeyTextPosition or 'TOPRIGHT'
	local offsetX = db and db.hotkeyTextXOffset or 0
	local offsetY = db and db.hotkeyTextYOffset or -3

	local color = db and db.useHotkeyColor and db.hotkeyColor or AB.db.fontColor
	local show = not (db and not db.hotkeytext)

	return font, size, flags, anchor, offsetX, offsetY, AB:GetTextJustify(anchor), { color.r or 1, color.g or 1, color.b or 1 }, show
end

do
	local fixBars = {}
	if E.Mists then
		fixBars.MULTIACTIONBAR5BUTTON = 'ELVUIBAR13BUTTON'
		fixBars.MULTIACTIONBAR6BUTTON = 'ELVUIBAR14BUTTON'
		fixBars.MULTIACTIONBAR7BUTTON = 'ELVUIBAR15BUTTON'
	end

	function AB:GetKeyTarget(buttonName, id)
		return format('%s%d', fixBars[buttonName] or buttonName, id)
	end
end

function AB:UpdateButtonConfig(barName, buttonName)
	if InCombatLockdown() then
		AB.NeedsUpdateButtonSettings = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local bar = AB.handledBars[barName]
	if not bar.buttonConfig then
		bar.buttonConfig = E:CopyTable({}, buttonDefaults)
	end

	local config = bar.buttonConfig
	local text = config.text
	local db = AB.db[barName]

	do -- hotkey text
		local font, size, flags, anchor, offsetX, offsetY, justify, color = AB:GetHotkeyConfig(db)
		text.hotkey.color = color
		text.hotkey.font.font = font
		text.hotkey.font.size = size
		text.hotkey.font.flags = flags
		text.hotkey.position.anchor = anchor
		text.hotkey.position.relAnchor = false
		text.hotkey.position.offsetX = offsetX
		text.hotkey.position.offsetY = offsetY
		text.hotkey.justifyH = justify
	end

	do -- count text
		text.count.font.font = LSM:Fetch('font', db and db.countFont or AB.db.font)
		text.count.font.size = db and db.countFontSize or AB.db.fontSize
		text.count.font.flags = db and db.countFontOutline or AB.db.font
		text.count.position.anchor = db and db.countTextPosition or 'BOTTOMRIGHT'
		text.count.position.relAnchor = false
		text.count.position.offsetX = db and db.countTextXOffset or 0
		text.count.position.offsetY = db and db.countTextYOffset or 2
		text.count.justifyH = AB:GetTextJustify(text.count.position.anchor)

		local c = db and db.useCountColor and db.countColor or AB.db.fontColor
		text.count.color = { c.r, c.g, c.b }
	end

	do -- macro text
		text.macro.font.font = LSM:Fetch('font', db and db.macroFont or AB.db.font)
		text.macro.font.size = db and db.macroFontSize or AB.db.fontSize
		text.macro.font.flags = db and db.macroFontOutline or AB.db.font
		text.macro.position.anchor = db and db.macroTextPosition or 'BOTTOM'
		text.macro.position.relAnchor = false
		text.macro.position.offsetX = db and db.macroTextXOffset or 0
		text.macro.position.offsetY = db and db.macroTextYOffset or 1
		text.macro.justifyH = AB:GetTextJustify(text.macro.position.anchor)

		local c = db and db.useMacroColor and db.macroColor or AB.db.fontColor
		text.macro.color = { c.r, c.g, c.b }
	end

	config.hideElements.count = not db.counttext
	config.hideElements.macro = not db.macrotext
	config.hideElements.hotkey = not db.hotkeytext

	config.enabled = db.enabled -- only used to keep events off for targetReticle
	config.showGrid = db.showGrid
	config.targetReticle = db.targetReticle
	config.clickOnDown = GetCVarBool('ActionButtonUseKeyDown')
	config.outOfRangeColoring = (AB.db.useRangeColorText and 'hotkey') or 'button'
	config.colors.range = E:SetColorTable(config.colors.range, AB.db.noRangeColor)
	config.colors.mana = E:SetColorTable(config.colors.mana, AB.db.noPowerColor)
	config.colors.usable = E:SetColorTable(config.colors.usable, AB.db.usableColor)
	config.colors.notUsable = E:SetColorTable(config.colors.notUsable, AB.db.notUsableColor)
	config.useDrawBling = not AB.db.hideCooldownBling
	config.useDrawSwipeOnCharges = AB.db.useDrawSwipeOnCharges
	config.handleOverlay = AB.db.handleOverlay
	SetModifiedClick('PICKUPACTION', AB.db.movementModifier)

	if not buttonName then
		buttonName = bar.bindButtons
	end

	for i, button in ipairs(bar.buttons) do
		AB:ToggleCountDownNumbers(bar, button)

		local keyTarget = AB:GetKeyTarget(buttonName, i)
		config.keyBoundTarget = keyTarget -- for LAB
		button.keyBoundTarget = keyTarget -- for bind mode
		button.postKeybind = AB.FixKeybindText

		button:SetAttribute('buttonlock', AB.db.lockActionBars or nil)
		button:SetAttribute('checkselfcast', AB.db.checkSelfCast or nil)
		button:SetAttribute('checkfocuscast', AB.db.checkFocusCast or nil)
		button:SetAttribute('checkmouseovercast', GetCVarBool('enableMouseoverCast') or nil)
		button:SetAttribute('unit2', AB.db.rightClickSelfCast and 'player' or nil)

		button:UpdateConfig(config)
	end
end

do
	local stockFont, stockFontSize, stockFontOutline
	if E.locale == 'koKR' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\2002.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif E.locale == 'zhTW' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\arheiuhk_bd.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif E.locale == 'zhCN' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\FRIZQT__.TTF]], 11, 'MONOCHROME, OUTLINE'
	else
		stockFont, stockFontSize, stockFontOutline = [[Fonts\ARIALN.TTF]], 12, 'MONOCHROME, THICKOUTLINE'
	end

	-- handle for pet/stance/etc not main bars
	function AB:FixKeybindColor(button)
		local hotkey = button.HotKey
		if not hotkey then return end

		local font, size, flags, anchor, offsetX, offsetY, justify, color, show = AB:GetHotkeyConfig(button:GetParent().db)

		hotkey:SetShown(show)

		local text = hotkey:GetText()
		if text == _G.RANGE_INDICATOR then
			hotkey:SetFont(stockFont, stockFontSize, stockFontOutline)
			hotkey:SetTextColor(0.9, 0.9, 0.9)
		elseif text then
			hotkey:FontTemplate(font, size, flags)
			hotkey:SetTextColor(unpack(color))
		end

		if not button.useMasque then
			hotkey:SetJustifyH(justify)
			hotkey:ClearAllPoints()
			hotkey:Point(anchor, offsetX, offsetY)
		end
	end
end

function AB:FixKeybindText(button)
	local text = button.HotKey:GetText()
	if text and text ~= _G.RANGE_INDICATOR then
		text = gsub(text, 'SHIFT%-', L["KEY_SHIFT"])
		text = gsub(text, 'ALT%-', L["KEY_ALT"])
		text = gsub(text, 'CTRL%-', L["KEY_CTRL"])
		text = gsub(text, 'META%-', L["KEY_META"])
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
		text = gsub(text, 'NDIVIDE', L["KEY_NDIVIDE"])
		text = gsub(text, 'NMULTIPLY', L["KEY_NMULTIPLY"])
		text = gsub(text, 'NMINUS', L["KEY_NMINUS"])
		text = gsub(text, 'NPLUS', L["KEY_NPLUS"])
		text = gsub(text, 'NEQUALS', L["KEY_NEQUALS"])

		button.HotKey:SetText(text)
	end
end

local function SkinFlyout()
	if _G.SpellFlyout.Background then _G.SpellFlyout.Background:Hide() end
	if _G.SpellFlyoutBackgroundEnd then _G.SpellFlyoutBackgroundEnd:Hide() end
	if _G.SpellFlyoutHorizontalBackground then _G.SpellFlyoutHorizontalBackground:Hide() end
	if _G.SpellFlyoutVerticalBackground then _G.SpellFlyoutVerticalBackground:Hide() end
end

local function FlyoutButtonAnchor(frame)
	local parent = frame:GetParent()
	local _, parentAnchorButton = parent:GetPoint()
	if not AB.handledbuttons[parentAnchorButton] then return end

	return parentAnchorButton:GetParent()
end

function AB:FlyoutButton_OnEnter()
	local anchor = FlyoutButtonAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end

	AB:BindUpdate(self, 'FLYOUT')
end

function AB:FlyoutButton_OnLeave()
	local anchor = FlyoutButtonAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

local function SpellFlyoutAnchor(frame)
	local _, anchorButton = frame:GetPoint()
	if not AB.handledbuttons[anchorButton] then return end

	return anchorButton:GetParent()
end

function AB:SpellFlyout_OnEnter()
	local anchor = SpellFlyoutAnchor(self)
	if anchor then AB:Bar_OnEnter(anchor) end
end

function AB:SpellFlyout_OnLeave()
	local anchor = SpellFlyoutAnchor(self)
	if anchor then AB:Bar_OnLeave(anchor) end
end

function AB:UpdateFlyoutButtons()
	if _G.LABFlyoutHandlerFrame then
		_G.LABFlyoutHandlerFrame.Background:Hide()
	end

	-- spellbook flyouts
	local isShown, i = _G.SpellFlyout:IsShown(), 1
	local flyoutName = E.Retail and 'SpellFlyoutPopupButton' or 'SpellFlyoutButton'
	local btn = _G[flyoutName..i]
	while btn do
		if isShown then
			AB:SetupFlyoutButton(btn)
		end

		AB:StyleFlyout(btn)

		if not btn.isFlyout then
			btn.isFlyout = true -- so we can ignore it on binding
		end

		i = i + 1
		btn = _G[flyoutName..i]
	end
end

function AB:HideFlyoutShadow(button)
	if button.BorderShadow then button.BorderShadow:SetAlpha(0) end
	if button.FlyoutBorder then button.FlyoutBorder:SetAlpha(0) end
	if button.FlyoutBorderShadow then button.FlyoutBorderShadow:SetAlpha(0) end
end

function AB:SetupFlyoutButton(button)
	if not AB.handledbuttons[button] then
		AB:StyleButton(button, nil, FlyoutMasqueGroup and E.private.actionbar.masque.actionbars)
		AB:HideFlyoutShadow(button)

		button:HookScript('OnEnter', AB.FlyoutButton_OnEnter)
		button:HookScript('OnLeave', AB.FlyoutButton_OnLeave)
	end

	if not InCombatLockdown() then
		button:Size(AB.db.flyoutSize)
	end

	if FlyoutMasqueGroup and E.private.actionbar.masque.actionbars then
		FlyoutMasqueGroup:RemoveButton(button) --Remove first to fix issue with backdrops appearing at the wrong flyout menu
		FlyoutMasqueGroup:AddButton(button)
	end
end

function AB:StyleFlyout(button, arrow)
	local bar = button:GetParent()
	local barName = bar:GetName()

	local parent = bar:GetParent()
	local owner = parent and parent:GetParent()
	local ownerName = owner and owner:GetName()

	local btn = (ownerName == 'SpellBookSpellIconsFrame' and parent) or button
	if not arrow then arrow = btn.FlyoutArrow or (btn.GetArrowRotation and btn.Arrow) or (btn.FlyoutArrowContainer and btn.FlyoutArrowContainer.FlyoutArrowNormal) end
	if not arrow then return end

	AB:HideFlyoutShadow(button)

	if barName == 'SpellBookSpellIconsFrame' or ownerName == 'SpellBookSpellIconsFrame' then
		local distance = (_G.SpellFlyout and _G.SpellFlyout:IsShown() and _G.SpellFlyout:GetParent() == parent) and 7 or 4
		arrow:ClearAllPoints()
		arrow:Point('RIGHT', btn, 'RIGHT', distance, 0)
	elseif bar and button.isFlyoutButton then -- Change arrow direction depending on what bar the button is on
		local direction = (bar.db and bar.db.flyoutDirection) or 'AUTOMATIC'
		local point = direction == 'AUTOMATIC' and E:GetScreenQuadrant(bar)
		if point == 'UNKNOWN' then return end

		local noCombat = not InCombatLockdown()
		local distance = (_G.LABFlyoutHandlerFrame and _G.LABFlyoutHandlerFrame:IsShown() and _G.LABFlyoutHandlerFrame:GetParent() == button) and 5 or 2
		if direction == 'DOWN' or (point and strfind(point, 'TOP')) then
			arrow:ClearAllPoints()
			arrow:Point('BOTTOM', button, 'BOTTOM', 0, -distance)
			SetClampedTextureRotation(arrow, 180)
			if noCombat then button:SetAttribute('flyoutDirection', 'DOWN') end
		elseif direction == 'LEFT' or point == 'RIGHT' then
			arrow:ClearAllPoints()
			arrow:Point('LEFT', button, 'LEFT', -distance, 0)
			SetClampedTextureRotation(arrow, 270)
			if noCombat then button:SetAttribute('flyoutDirection', 'LEFT') end
		elseif direction == 'RIGHT' or point == 'LEFT' then
			arrow:ClearAllPoints()
			arrow:Point('RIGHT', button, 'RIGHT', distance, 0)
			SetClampedTextureRotation(arrow, 90)
			if noCombat then button:SetAttribute('flyoutDirection', 'RIGHT') end
		elseif direction == 'UP' or point == 'CENTER' or (point and strfind(point, 'BOTTOM')) then
			arrow:ClearAllPoints()
			arrow:Point('TOP', button, 'TOP', 0, distance)
			SetClampedTextureRotation(arrow, 0)
			if noCombat then button:SetAttribute('flyoutDirection', 'UP') end
		end
	end
end

function AB:UpdateAuraCooldown(button, duration)
	local cd = button and button.AuraCooldown
	if not cd then return end

	local oldstate = cd.hideText
	cd.hideText = (not E.db.cooldown.targetAura) or (button.chargeCooldown and not button.chargeCooldown.hideText) or (button.cooldown and button.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL) or (duration and duration > 1.5) or nil
	if cd.timer and (oldstate ~= cd.hideText) then
		E:ToggleBlizzardCooldownText(cd, cd.timer)
		E:Cooldown_TimerUpdate(cd.timer)
	end
end

function AB:UpdateChargeCooldown(button, duration)
	local cd = button and button.chargeCooldown
	if not cd then return end

	local oldstate = cd.hideText
	cd.hideText = (not AB.db.chargeCooldown) or (duration and duration > 1.5) or nil
	if cd.timer and (oldstate ~= cd.hideText) then
		E:ToggleBlizzardCooldownText(cd, cd.timer)
		E:Cooldown_TimerUpdate(cd.timer)
	end
end

function AB:SetTargetAuraDuration(value)
	LAB:SetTargetAuraDuration(value)
end

function AB:SetTargetAuraCooldowns(enabled)
	local enable, reverse = E.db.cooldown.enable, E.db.actionbar.cooldown.reverse
	LAB:SetTargetAuraCooldowns(enabled and (enable and not reverse) or (not enable and reverse))
end

function AB:ToggleCooldownOptions()
	for button in pairs(LAB.actionButtons) do
		if button._state_type == 'action' then
			local _, duration = button:GetCooldown()
			AB:SetButtonDesaturation(button, duration)
			AB:UpdateChargeCooldown(button, duration)
			AB:UpdateAuraCooldown(button, duration)
		end
	end
end

function AB:SetButtonDesaturation(button, duration)
	if button.LevelLinkLockIcon and button.LevelLinkLockIcon:IsShown() then
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

function AB:LAB_FlyoutUpdate(btn)
	AB:StyleFlyout(btn)
end

function AB:LAB_FlyoutSpells()
	if LAB.FlyoutButtons then
		for _, btn in next, LAB.FlyoutButtons do
			AB:SetupFlyoutButton(btn)
		end
	end
end

function AB:LAB_FlyoutCreated(btn)
	AB:SetupFlyoutButton(btn)

	btn:SetScale(1)
	btn.MasqueSkinned = true -- skip LAB styling
end

function AB:LAB_ChargeCreated(_, cd)
	E:RegisterCooldown(cd, 'actionbar')
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
	if button.SetBackdropBorderColor then
		local border = (AB.db.equippedItem and button:IsEquipped() and AB.db.equippedItemColor) or E.db.general.bordercolor
		button:SetBackdropBorderColor(border.r, border.g, border.b)
	end

	if button.ProfessionQualityOverlayFrame then
		AB:UpdateProfessionQuality(button)
	end
end

function AB:LAB_CooldownDone(button)
	AB:SetButtonDesaturation(button, 0)

	if button._state_type == 'action' then
		AB:UpdateAuraCooldown(button)
	end
end

function AB:LAB_CooldownUpdate(button, _, duration)
	if button._state_type == 'action' then
		AB:SetButtonDesaturation(button, duration)
		AB:UpdateChargeCooldown(button, duration)
		AB:UpdateAuraCooldown(button, duration)
	end

	if button.cooldown then
		AB:ColorSwipeTexture(button.cooldown)
	end
end

function AB:PLAYER_ENTERING_WORLD(event, initLogin, isReload)
	AB:AdjustMaxStanceButtons(event)
end

do
	-- some functions to show the rotation assisted highlighting
	function AB:AssistedUpdate(nextSpell)
		for button in pairs(LAB.activeButtons) do
			local spellID = button:GetSpellId()
			local nextcast, alertActive = spellID and spellID == nextSpell, LAB.activeAlerts[spellID]
			if (nextcast or alertActive) and _G.AssistedCombatManager:IsRotationSpell(spellID) then
				AB.AssistGlowOptions.color = (nextcast and AB.AssistGlowNextCast) or AB.AssistGlowAlternative
				AB.AssistGlowOptions.useColor = true

				LCG.ShowOverlayGlow(button, AB.AssistGlowOptions)
				LAB.activeAssist[spellID] = true
			elseif spellID and not alertActive then
				LCG.HideOverlayGlow(button)

				if LAB.activeAssist[spellID] then
					LAB.activeAssist[spellID] = nil
				end
			end
		end
	end

	function AB:AssistedGlowUpdate()
		AB.AssistGlowOptions = E:CopyTable({}, E.db.general.customGlow)
		AB.AssistGlowNextCast = E:SetColorTable(AB.AssistGlowNextCast, E:UpdateClassColor(E.db.general.rotationAssist.nextcast))
		AB.AssistGlowAlternative = E:SetColorTable(AB.AssistGlowAlternative, E:UpdateClassColor(E.db.general.rotationAssist.alternative))
	end

	local checkForVisibleButton = false -- we need this changed to function
	function AB:AssistedOnUpdate(elapsed)
		self.updateTimeLeft = self.updateTimeLeft - elapsed

		if self.updateTimeLeft <= 0 then
			self.updateTimeLeft = self:GetUpdateRate()

			local spellID = GetNextCastSpell(checkForVisibleButton)
			if spellID ~= self.lastNextCastSpellID then
				self.lastNextCastSpellID = spellID
				self:UpdateAllAssistedHighlightFramesForSpell(spellID)

				-- we dont need this tho
				-- EventRegistry:TriggerEvent('AssistedCombatManager.OnAssistedHighlightSpellChange')
			end
		end
	end

	-- a few functions to modify what spells are rotation assisted
	function AB:RotationUpdate()
		AB:RotationSpellsAdjust()
	end

	function AB:RotationSpellsClear()
		AB:RotationSpellsAdjust(true) -- set them back to true
		wipe(E.db.general.rotationAssist.spells[E.myclass]) -- clear our table now
	end

	function AB:RotationSpellsAdjust(value)
		local rotations = _G.AssistedCombatManager.rotationSpells -- Blizzards table
		if not next(rotations) then return end

		local spells = E.db.general.rotationAssist.spells[E.myclass] -- our table for toggling
		for spellID, active in next, spells do
			if rotations[spellID] ~= nil then
				if value ~= nil then
					rotations[spellID] = value
				else
					rotations[spellID] = active
				end
			else -- remove old ones
				spells[spellID] = nil
			end
		end

		_G.AssistedCombatManager:ForceUpdateAtEndOfFrame()
	end
end

function AB:Initialize()
	_G.BINDING_HEADER_ELVUI = E.title

	for _, barNumber in pairs({2, 7, 8, 9, 10}) do
		for slot = 1, 12 do
			_G[format('BINDING_NAME_ELVUIBAR%dBUTTON%d', barNumber, slot)] = format('ActionBar %d Button %d', barNumber, slot)
		end
	end

	if not E.private.actionbar.enable then return end
	AB.Initialized = true

	LAB.RegisterCallback(AB, 'OnButtonUpdate', AB.LAB_ButtonUpdate)
	LAB.RegisterCallback(AB, 'OnButtonCreated', AB.LAB_ButtonCreated)
	LAB.RegisterCallback(AB, 'OnFlyoutButtonCreated', AB.LAB_FlyoutCreated)
	LAB.RegisterCallback(AB, 'OnFlyoutSpells', AB.LAB_FlyoutSpells)
	LAB.RegisterCallback(AB, 'OnFlyoutUpdate', AB.LAB_FlyoutUpdate)
	LAB.RegisterCallback(AB, 'OnChargeCreated', AB.LAB_ChargeCreated)
	LAB.RegisterCallback(AB, 'OnCooldownUpdate', AB.LAB_CooldownUpdate)
	LAB.RegisterCallback(AB, 'OnCooldownDone', AB.LAB_CooldownDone)

	AB.fadeParent = CreateFrame('Frame', 'Elv_ABFade', UIParent)
	AB.fadeParent:SetAlpha(1 - (AB.db.globalFadeAlpha or 0))
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_DISABLED')
	AB.fadeParent:RegisterEvent('PLAYER_REGEN_ENABLED')
	AB.fadeParent:RegisterEvent('PLAYER_TARGET_CHANGED')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
	AB.fadeParent:RegisterUnitEvent('UNIT_HEALTH', 'player')

	if not E.Classic then
		AB.fadeParent:RegisterEvent('PLAYER_FOCUS_CHANGED')
	end

	if E.Retail then
		AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_START', 'player')
		AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_STOP', 'player')
		AB.fadeParent:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
		AB.fadeParent:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
		AB.fadeParent:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
		AB.fadeParent:RegisterEvent('UPDATE_POSSESS_BAR')
		AB.fadeParent:RegisterEvent('PLAYER_CAN_GLIDE_CHANGED')
	end

	if E.Retail or E.Mists then
		AB.fadeParent:RegisterEvent('VEHICLE_UPDATE')
		AB.fadeParent:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
		AB.fadeParent:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')

		AB:RegisterEvent('PET_BATTLE_CLOSE', 'ReassignBindings')
		AB:RegisterEvent('PET_BATTLE_OPENING_DONE', 'RemoveBindings')
	end

	AB.fadeParent:SetScript('OnEvent', AB.FadeParent_OnEvent)

	AB:DisableBlizzard()
	AB:SetupMicroBar()

	for i = 1, 10 do
		AB:CreateBar(i)
	end

	for i = 13, 15 do
		AB:CreateBar(i)
	end

	AB:CreateBarPet()
	AB:CreateBarShapeShift()
	AB:CreateVehicleLeave()
	AB:UpdateButtonSettings()
	AB:UpdatePetCooldownSettings()
	AB:ToggleCooldownOptions()
	AB:LoadKeyBinder()

	AB:RegisterEvent('ADDON_LOADED')
	AB:RegisterEvent('PLAYER_ENTERING_WORLD')
	AB:RegisterEvent('UPDATE_BINDINGS', 'ReassignBindings')
	AB:RegisterEvent('SPELL_UPDATE_COOLDOWN', 'UpdateSpellBookTooltip')

	AB:SetTargetAuraDuration(E.db.cooldown.targetAuraDuration)

	if _G.MacroFrame then
		AB:ADDON_LOADED(nil, 'Blizzard_MacroUI')
	end

	if E.Retail or E.Mists then
		AB:SetupExtraButtons()
	end

	if (E.Retail or E.Mists) and IsInBattle() then
		AB:RemoveBindings()
	else
		AB:ReassignBindings()
	end

	-- We handle actionbar lock for regular bars, but the lock on PetBar needs to be handled by WoW so make some necessary updates
	E:SetCVar('lockActionBars', AB.db.lockActionBars and 1 or 0)
	_G.LOCK_ACTIONBAR = (AB.db.lockActionBars and '1' or '0') -- Keep an eye on this, in case it taints

	if E.Retail then
		hooksecurefunc(_G.SpellFlyout, 'Show', AB.UpdateFlyoutButtons)
		hooksecurefunc(_G.SpellFlyout, 'Hide', AB.UpdateFlyoutButtons)

		_G.SpellFlyout:HookScript('OnEnter', AB.SpellFlyout_OnEnter)
		_G.SpellFlyout:HookScript('OnLeave', AB.SpellFlyout_OnLeave)

		AB:AssistedGlowUpdate()
		hooksecurefunc(_G.AssistedCombatManager, 'UpdateAllAssistedHighlightFramesForSpell', AB.AssistedUpdate)
		_G.EventRegistry:RegisterCallback('AssistedCombatManager.RotationSpellsUpdated', AB.RotationUpdate)
		_G.AssistedCombatManager.OnUpdate = AB.AssistedOnUpdate -- use our update function instead
	end

	if not E.Classic then
		hooksecurefunc(_G.SpellFlyout, 'Toggle', SkinFlyout)
	end
end

E:RegisterModule(AB:GetName())
