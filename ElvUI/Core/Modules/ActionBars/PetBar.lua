local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local gsub = gsub
local ipairs = ipairs
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local PetHasActionBar = PetHasActionBar
local GetPetActionInfo = GetPetActionInfo
local IsPetAttackAction = IsPetAttackAction
local GetPetActionCooldown = GetPetActionCooldown
local RegisterStateDriver = RegisterStateDriver
local GameTooltip = GameTooltip

local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
local PetActionButton_StartFlash = PetActionButton_StartFlash
local PetActionButton_StopFlash = PetActionButton_StopFlash

local PetActionBar_UpdateCooldowns = PetActionBar_UpdateCooldowns

local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group('ElvUI', 'Pet Bar')

local bar = CreateFrame('Frame', 'ElvUI_BarPet', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')
bar.buttons = {}

function AB:UpdatePet(event, unit)
	if (event == 'UNIT_FLAGS' and unit ~= 'pet') or (event == 'UNIT_PET' and unit ~= 'player') then return end

	for i, button in ipairs(bar.buttons) do
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)
		local buttonName = 'PetActionButton'..i
		local autoCast = button.AutoCastable or _G[buttonName..'AutoCastable']

		button:SetAlpha(1)
		button.isToken = isToken
		button.icon:Show()

		if not isToken then
			button.icon:SetTexture(texture)
			button.tooltipName = name
		else
			button.icon:SetTexture(_G[texture])
			button.tooltipName = _G[name]
		end

		if spellID then
			local spell = _G.Spell:CreateFromSpellID(spellID)
			button.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
				button.tooltipSubtext = spell:GetSpellSubtext()
			end)
		end

		if isActive and name ~= 'PET_ACTION_FOLLOW' then
			button:SetChecked(true)

			if IsPetAttackAction(i) then
				if PetActionButton_StartFlash then
					PetActionButton_StartFlash(button)
				else
					button:StartFlash()
				end
			end
		else
			button:SetChecked(false)

			if IsPetAttackAction(i) then
				if PetActionButton_StopFlash then
					PetActionButton_StopFlash(button)
				else
					button:StopFlash()
				end
			end
		end

		if autoCastAllowed then
			autoCast:Show()
		else
			autoCast:Hide()
		end

		if autoCastEnabled then
			AutoCastShine_AutoCastStart(button.AutoCastShine)
		else
			AutoCastShine_AutoCastStop(button.AutoCastShine)
		end

		if not PetHasActionBar() and texture and name ~= 'PET_ACTION_FOLLOW' then
			if PetActionButton_StopFlash then
				PetActionButton_StopFlash(button)
			else
				button:StopFlash()
			end

			button.icon:SetDesaturation(1)
			button:SetChecked(false)
		end
	end
end

function AB:PositionAndSizeBarPet()
	local db = AB.db.barPet
	if not db then return end

	local buttonSpacing = db.buttonSpacing
	local backdropSpacing = db.backdropSpacing
	local buttonsPerRow = db.buttonsPerRow
	local numButtons = db.buttons
	local buttonWidth = db.buttonSize
	local buttonHeight = db.keepSizeRatio and db.buttonSize or db.buttonHeight
	local point = db.point

	local autoCastWidth = (buttonWidth * 0.5) - (buttonWidth / 7.5)
	local autoCastHeight = (buttonHeight * 0.5) - (buttonHeight / 7.5)

	bar.db = db
	bar.mouseover = db.mouseover

	if numButtons < buttonsPerRow then buttonsPerRow = numButtons end

	if db.enabled then
		bar:SetScale(1)
		bar:SetAlpha(db.alpha)
		E:EnableMover(bar.mover.name)
	else
		bar:SetScale(0.0001)
		bar:SetAlpha(0)
		E:DisableMover(bar.mover.name)
	end

	bar:SetParent(db.inheritGlobalFade and AB.fadeParent or E.UIParent)
	bar:EnableMouse(not db.clickThrough)
	bar:SetAlpha(bar.mouseover and 0 or db.alpha)
	AB:FadeBarBlings(bar, bar.mouseover and 0 or db.alpha)

	bar.backdrop:SetShown(db.backdrop)
	bar.backdrop:ClearAllPoints()

	AB:MoverMagic(bar)

	local anchorRowButton, lastShownButton
	local horizontal, anchorUp, anchorLeft = AB:GetGrowth(point)
	local useMasque = MasqueGroup and E.private.actionbar.masque.petBar

	for i, button in ipairs(bar.buttons) do
		local lastButton = _G['PetActionButton'..i-1]
		local lastColumnButton = _G['PetActionButton'..i-buttonsPerRow]
		local autoCast = button.AutoCastable

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

		autoCast:SetOutside(button, autoCastWidth, autoCastHeight)
		AB:HandleButton(bar, button, i, lastButton, lastColumnButton)
		AB:StyleButton(button, nil, useMasque, true)
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, db.widthMult, db.heightMult, anchorUp, anchorLeft, horizontal, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	local visibility = gsub(db.visibility, '[\n\r]', '')
	RegisterStateDriver(bar, 'show', visibility)

	if useMasque then
		MasqueGroup:ReSkin()

		for _, button in ipairs(bar.buttons) do
			AB:TrimIcon(button, true)
		end
	end
end

function AB:UpdatePetCooldownSettings()
	for _, button in ipairs(bar.buttons) do
		if button.cooldown then
			button.cooldown:SetDrawBling(not AB.db.hideCooldownBling)
		end
	end
end

function AB:UpdatePetBindings()
	for i, button in ipairs(bar.buttons) do
		if button.HotKey then
			button.HotKey:SetText(GetBindingKey('BONUSACTIONBUTTON'..i))
			AB:FixKeybindText(button)
		end
	end
end

function AB:UpdatePetCooldowns()
	if PetActionBar_UpdateCooldowns then
		PetActionBar_UpdateCooldowns()
	else
		local forbidden = GameTooltip:IsForbidden()
		local owner = GameTooltip:GetOwner()

		for i, button in ipairs(bar.buttons) do
			local start, duration = GetPetActionCooldown(i)
			button.cooldown:SetCooldown(start, duration)

			if not forbidden and owner == button then
				button:OnEnter(button)
			end
		end
	end
end

function AB:PetBar_OnShow()
	-- holder
end

function AB:PetBar_OnHide()
	for _, button in ipairs(bar.buttons) do
		if button.spellDataLoadedCancelFunc then
			button.spellDataLoadedCancelFunc()
			button.spellDataLoadedCancelFunc = nil
		end
	end
end

function AB:CreateBarPet()
	bar.backdrop = CreateFrame('Frame', nil, bar)
	bar.backdrop:SetTemplate(AB.db.transparent and 'Transparent')
	bar.backdrop:SetFrameLevel(0)

	for i = 1, _G.NUM_PET_ACTION_SLOTS do
		local button = _G['PetActionButton'..i]
		button:Show() -- for some reason they start hidden on DF ?
		bar.buttons[i] = button

		if not E.Retail then
			button.commandName = 'BONUSACTIONBUTTON'..i -- to support KB like retail
		end

		AB:HookScript(button, 'OnEnter', 'Button_OnEnter')
		AB:HookScript(button, 'OnLeave', 'Button_OnLeave')

		if MasqueGroup and E.private.actionbar.masque.petBar then
			MasqueGroup:AddButton(button)
		end
	end

	if AB.db.bar4.enabled then
		bar:Point('RIGHT', _G.ElvUI_Bar4, 'LEFT', -4, 0)
	else
		bar:Point('RIGHT', E.UIParent, 'RIGHT', -4, 0)
	end

	bar:SetAttribute('_onstate-show', [[
		if newstate == 'hide' then
			self:Hide()
		else
			self:Show()
		end
	]])

	bar:SetScript('OnHide', AB.PetBar_OnHide)
	bar:SetScript('OnShow', AB.PetBar_OnShow)

	if E.Retail then
		AB:RegisterEvent('PET_UI_UPDATE', 'UpdatePet')
	end

	AB:RegisterEvent('PET_BAR_UPDATE', 'UpdatePet')
	AB:RegisterEvent('PLAYER_CONTROL_GAINED', 'UpdatePet')
	AB:RegisterEvent('PLAYER_CONTROL_LOST', 'UpdatePet')
	AB:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdatePet')
	AB:RegisterEvent('PLAYER_FARSIGHT_FOCUS_CHANGED', 'UpdatePet')
	AB:RegisterEvent('SPELLS_CHANGED', 'UpdatePet')
	AB:RegisterEvent('UNIT_FLAGS', 'UpdatePet')
	AB:RegisterEvent('UNIT_PET', 'UpdatePet')
	AB:RegisterEvent('PET_BAR_UPDATE_COOLDOWN', 'UpdatePetCooldowns')

	E:CreateMover(bar, 'PetAB', L["Pet Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,barPet')

	AB:UpdatePetBindings()

	AB:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	AB:HookScript(bar, 'OnLeave', 'Bar_OnLeave')
end
