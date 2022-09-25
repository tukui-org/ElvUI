local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local gsub = gsub
local format, ipairs = format, ipairs
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftForm = GetShapeshiftForm
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetSpellTexture = GetSpellTexture
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS

local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group('ElvUI', 'Stance Bar')
local WispSplode = [[Interface\Icons\Spell_Nature_WispSplode]]
local bar = CreateFrame('Frame', 'ElvUI_StanceBar', E.UIParent, 'SecureHandlerStateTemplate')
bar.buttons = {}

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if i <= numForms then
			local cooldown = _G['ElvUI_StanceBarButton'..i..'Cooldown']
			local start, duration, active = GetShapeshiftFormCooldown(i)
			if (active and active ~= 0) and start > 0 and duration > 0 then
				cooldown:SetCooldown(start, duration)
				cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5) --Cooldown Bling Fix
			else
				cooldown:Clear()
			end
		end
	end
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms()
	local stance = GetShapeshiftForm()
	local darken = AB.db.stanceBar.style == 'darkenInactive'

	for i = 1, NUM_STANCE_SLOTS do
		local button = _G['ElvUI_StanceBarButton'..i]

		if i > numForms then
			break
		else
			local texture, isActive, isCastable, spellID = GetShapeshiftFormInfo(i)
			button.icon:SetTexture(((darken or not isActive) and spellID and GetSpellTexture(spellID)) or WispSplode)
			button.icon:SetInside()

			if not button.useMasque then
				button.cooldown:SetAlpha(texture and 1 or 0)

				if isActive then
					_G.StanceBarFrame.lastSelected = button:GetID()

					button:SetChecked(numForms == 1 and darken)
					button.checked:SetColorTexture(1, 1, 1, 0.3)
				elseif numForms == 1 or stance == 0 then
					button:SetChecked(false)
				else
					button:SetChecked(darken)
					button.checked:SetAlpha(1)

					if darken then
						button.checked:SetColorTexture(0, 0, 0, 0.6)
					else
						button.checked:SetColorTexture(1, 1, 1, 0.6)
					end
				end
			else
				button:SetChecked(isActive)
			end

			if isCastable then
				button.icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				button.icon:SetVertexColor(0.3, 0.3, 0.3)
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local db = AB.db.stanceBar

	local buttonSpacing = db.buttonSpacing
	local backdropSpacing = db.backdropSpacing
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local point = db.point

	bar.db = db
	bar.mouseover = db.mouseover

	if bar.LastButton then
		if numButtons > bar.LastButton then numButtons = bar.LastButton end
		if buttonsPerRow > bar.LastButton then buttonsPerRow = bar.LastButton end
	end
	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	bar:SetParent(db.inheritGlobalFade and AB.fadeParent or E.UIParent)
	bar:EnableMouse(not db.clickThrough)
	bar:SetAlpha(bar.mouseover and 0 or db.alpha)
	AB:FadeBarBlings(bar, bar.mouseover and 0 or db.alpha)

	bar.backdrop:SetShown(db.backdrop)
	bar.backdrop:ClearAllPoints()

	AB:MoverMagic(bar)

	local _, horizontal, anchorUp, anchorLeft = AB:GetGrowth(point)
	local button, lastButton, lastColumnButton, anchorRowButton, lastShownButton
	local useMasque = MasqueGroup and E.private.actionbar.masque.stanceBar

	for i = 1, NUM_STANCE_SLOTS do
		button = _G['ElvUI_StanceBarButton'..i]
		lastButton = _G['ElvUI_StanceBarButton'..i-1]
		lastColumnButton = _G['ElvUI_StanceBarButton'..i-buttonsPerRow]

		if not E.Retail then
			button.commandName = 'SHAPESHIFTBUTTON'..i -- to support KB like retail
		end

		button.db = db

		if i == 1 or i == buttonsPerRow then
			anchorRowButton = button
		end

		if i > numButtons then
			button:SetScale(0.0001)
			button:SetAlpha(0)
			button.handleBackdrop = nil
		else
			button:SetScale(1)
			button:SetAlpha(db.alpha)
			lastShownButton = button
			button.handleBackdrop = true -- keep over HandleButton
		end

		AB:HandleButton(bar, button, i, lastButton, lastColumnButton)
		AB:StyleButton(button, nil, useMasque, true)

		if useMasque then
			MasqueGroup:AddButton(bar.buttons[i])
		elseif db.style == 'darkenInactive' then
			button.checked:SetBlendMode('BLEND')
		else
			button.checked:SetBlendMode('ADD')
		end
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	if db.enabled then
		E:EnableMover(bar.mover.name)
	else
		E:DisableMover(bar.mover.name)
	end

	local visibility = gsub(db.visibility, '[\n\r]', '')
	RegisterStateDriver(bar, 'visibility', (not db.enabled or GetNumShapeshiftForms() == 0) and 'hide' or visibility)

	if useMasque then
		MasqueGroup:ReSkin()

		for _, btn in ipairs(bar.buttons) do
			AB:TrimIcon(btn, true)
		end
	end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then
		AB.NeedsAdjustMaxStanceButtons = event or true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	for _, button in ipairs(bar.buttons) do
		button:Hide()
	end

	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame('CheckButton', format(bar:GetName()..'Button%d', i), bar, 'StanceButtonTemplate')
			bar.buttons[i]:SetID(i)

			AB:HookScript(bar.buttons[i], 'OnEnter', 'Button_OnEnter')
			AB:HookScript(bar.buttons[i], 'OnLeave', 'Button_OnLeave')
		end

		local blizz = _G[format('StanceButton%d', i)]
		if blizz and blizz.commandName then
			bar.buttons[i].commandName = blizz.commandName
		end

		if i <= numButtons then
			bar.buttons[i]:Show()
			bar.LastButton = i
		end
	end

	AB:PositionAndSizeBarShapeShift()

	-- sometimes after combat lock down `event` may be true because of passing it back with `AB.NeedsAdjustMaxStanceButtons`
	if event == 'UPDATE_SHAPESHIFT_FORMS' or event == 'PLAYER_ENTERING_WORLD' then
		AB:StyleShapeShift()
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_STANCE_SLOTS do
		local button = _G['ElvUI_StanceBarButton'..i]
		if not button then break end

		button.HotKey:SetText(GetBindingKey('SHAPESHIFTBUTTON'..i))
		AB:FixKeybindText(button)
	end
end

function AB:CreateBarShapeShift()
	bar:CreateBackdrop(AB.db.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, nil, 0)

	bar:Point('TOPLEFT', E.UIParent, 'BOTTOMLEFT', 4, -769)

	AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	AB:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN')
	AB:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', 'AdjustMaxStanceButtons')
	AB:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'StyleShapeShift')
	AB:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', 'StyleShapeShift')
	AB:RegisterEvent('ACTIONBAR_PAGE_CHANGED', 'StyleShapeShift')

	E:CreateMover(bar, 'ShiftAB', L["Stance Bar"], nil, -3, nil, 'ALL,ACTIONBARS', nil, 'actionbar,stanceBar')
end
