local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local GetBindingKey = GetBindingKey
local PetHasActionBar = PetHasActionBar
local GetPetActionInfo = GetPetActionInfo
local IsPetAttackAction = IsPetAttackAction
local PetActionButton_StartFlash = PetActionButton_StartFlash
local PetActionButton_StopFlash = PetActionButton_StopFlash
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
local GetPetActionSlotUsable = GetPetActionSlotUsable
local SetDesaturation = SetDesaturation
local PetActionBar_ShowGrid = PetActionBar_ShowGrid
local PetActionBar_UpdateCooldowns = PetActionBar_UpdateCooldowns
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group('ElvUI', 'Pet Bar')

local bar = CreateFrame('Frame', 'ElvUI_BarPet', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')
bar.buttons = {}

function AB:UpdatePet(event, unit)
	if event == 'UNIT_AURA' and unit ~= 'pet' then return end

	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)
		local buttonName = 'PetActionButton'..i
		local autoCast = _G[buttonName..'AutoCastable']
		local button = _G[buttonName]

		button:SetAlpha(1)
		button.icon:Hide()
		button.isToken = isToken

		if not isToken then
			button.ICON:SetTexture(texture)
			button.tooltipName = name
		else
			button.ICON:SetTexture(_G[texture])
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
				PetActionButton_StartFlash(button)
			end
		else
			button:SetChecked(false)

			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(button)
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

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(button.ICON, nil)
			else
				SetDesaturation(button.ICON, 1)
			end

			button.ICON:Show()
		else
			button.ICON:Hide()
		end

		if not PetHasActionBar() and texture and name ~= 'PET_ACTION_FOLLOW' then
			PetActionButton_StopFlash(button)
			SetDesaturation(button.ICON, 1)
			button:SetChecked(0)
		end
	end
end

function AB:PositionAndSizeBarPet()
	local buttonSpacing = self.db.barPet.buttonspacing
	local backdropSpacing = self.db.barPet.backdropSpacing
	local buttonsPerRow = self.db.barPet.buttonsPerRow
	local numButtons = self.db.barPet.buttons
	local size = self.db.barPet.buttonsize
	local autoCastSize = (size / 2) - (size / 7.5)
	local point = self.db.barPet.point
	local widthMult = self.db.barPet.widthMult
	local heightMult = self.db.barPet.heightMult
	local visibility = self.db.barPet.visibility

	bar.db = self.db.barPet
	bar.db.position = nil; --Depreciated

	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	if self.db.barPet.enabled then
		bar:SetScale(1)
		bar:SetAlpha(bar.db.alpha)
		E:EnableMover(bar.mover:GetName())
	else
		bar:SetScale(0.0001)
		bar:SetAlpha(0)
		E:DisableMover(bar.mover:GetName())
	end

	local verticalGrowth = (point == 'TOPLEFT' or point == 'TOPRIGHT') and 'DOWN' or 'UP'
	local horizontalGrowth = (point == 'BOTTOMLEFT' or point == 'TOPLEFT') and 'RIGHT' or 'LEFT'
	local anchorUp, anchorLeft = verticalGrowth == 'UP', horizontalGrowth == 'LEFT'

	bar.backdrop:SetShown(self.db.barPet.backdrop)
	bar.backdrop:ClearAllPoints()

	-- mover magic ~Simpy
	bar:ClearAllPoints()
	if not bar.backdrop:IsShown() then
		bar:SetPoint('BOTTOMLEFT', bar.mover)
	elseif anchorUp then
		bar:SetPoint('BOTTOMLEFT', bar.mover, 'BOTTOMLEFT', anchorLeft and E.Border or -E.Border, -E.Border)
	else
		bar:SetPoint('TOPLEFT', bar.mover, 'TOPLEFT', anchorLeft and E.Border or -E.Border, E.Border)
	end

	bar.mouseover = self.db.barPet.mouseover
	if bar.mouseover then
		bar:SetAlpha(0)
		AB:FadeBarBlings(bar, 0)
	else
		bar:SetAlpha(bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end

	if self.db.barPet.inheritGlobalFade then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	bar:EnableMouse(not self.db.barPet.clickThrough)

	local button, lastButton, lastColumnButton, anchorRowButton, lastShownButton, autoCast
	local firstButtonSpacing = (self.db.barPet.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	for i = 1, NUM_PET_ACTION_SLOTS do
		button = _G['PetActionButton'..i]
		lastButton = _G['PetActionButton'..i-1]
		autoCast = _G['PetActionButton'..i..'AutoCastable']
		lastColumnButton = _G['PetActionButton'..i-buttonsPerRow]

		bar.buttons[i] = button

		button:SetParent(bar)
		button:ClearAllPoints()
		button:SetAttribute('showgrid', 1)
		button:Size(size)
		button:EnableMouse(not self.db.barPet.clickThrough)
		autoCast:SetOutside(button, autoCastSize, autoCastSize)

		if i == 1 then
			local x, y
			if point == 'BOTTOMLEFT' then
				x, y = firstButtonSpacing, firstButtonSpacing
			elseif point == 'TOPRIGHT' then
				x, y = -firstButtonSpacing, -firstButtonSpacing
			elseif point == 'TOPLEFT' then
				x, y = firstButtonSpacing, -firstButtonSpacing
			else
				x, y = -firstButtonSpacing, firstButtonSpacing
			end

			button:Point(point, bar, point, x, y)
			anchorRowButton = button
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0
			local y = -buttonSpacing
			local buttonPoint, anchorPoint = 'TOP', 'BOTTOM'
			if anchorUp then
				y = buttonSpacing
				buttonPoint = 'BOTTOM'
				anchorPoint = 'TOP'
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y)
		else
			local x = buttonSpacing
			local y = 0
			local buttonPoint, anchorPoint = 'LEFT', 'RIGHT'
			if anchorLeft then
				x = -buttonSpacing
				buttonPoint = 'RIGHT'
				anchorPoint = 'LEFT'
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y)
		end

		if i == 1 then
			bar.backdrop:Point(point, button, point, anchorLeft and backdropSpacing or -backdropSpacing, anchorUp and -backdropSpacing or backdropSpacing)
		elseif i == buttonsPerRow then
			bar.backdrop:Point(horizontalGrowth, button, horizontalGrowth, anchorLeft and -backdropSpacing or backdropSpacing, 0)
			anchorRowButton = button
		end

		if i > numButtons then
			button:SetScale(0.0001)
			button:SetAlpha(0)
		else
			button:SetScale(1)
			button:SetAlpha(bar.db.alpha)

			local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
			bar.backdrop:Point(anchorPoint, button, anchorPoint, 0, anchorUp and backdropSpacing or -backdropSpacing)
			lastShownButton = button
		end

		self:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.petBar and true or nil)
	end

	AB:HandleBackdropMultiplier(bar, buttonSpacing, widthMult, heightMult, anchorUp, anchorLeft, horizontalGrowth, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	RegisterStateDriver(bar, 'show', visibility)

	if MasqueGroup and E.private.actionbar.masque.petBar then MasqueGroup:ReSkin() end
end

function AB:UpdatePetCooldownSettings()
	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = _G['PetActionButton'..i]
		if button and button.cooldown then
			button.cooldown:SetDrawBling(not self.db.hideCooldownBling)
		end
	end
end

function AB:UpdatePetBindings()
	for i = 1, NUM_PET_ACTION_SLOTS do
		if self.db.hotkeytext then
			local key = GetBindingKey('BONUSACTIONBUTTON'..i)
			_G['PetActionButton'..i..'HotKey']:Show()
			_G['PetActionButton'..i..'HotKey']:SetText(key)
			self:FixKeybindText(_G['PetActionButton'..i])
		else
			_G['PetActionButton'..i..'HotKey']:Hide()
		end
	end
end

function AB:CreateBarPet()
	bar.backdrop = CreateFrame('Frame', nil, bar, 'BackdropTemplate')
	bar.backdrop:SetTemplate(AB.db.transparent and 'Transparent')
	bar.backdrop:SetFrameLevel(0)

	if self.db.bar4.enabled then
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

	bar:SetScript('OnHide', function()
		for i = 1, NUM_PET_ACTION_SLOTS, 1 do
			local button = _G['PetActionButton'..i]
			if button.spellDataLoadedCancelFunc then
				button.spellDataLoadedCancelFunc()
				button.spellDataLoadedCancelFunc = nil
			end
		end
	end)

	_G.PetActionBarFrame.showgrid = 1
	PetActionBar_ShowGrid()

	self:RegisterEvent('PET_BAR_UPDATE', 'UpdatePet')
	self:RegisterEvent('PLAYER_CONTROL_GAINED', 'UpdatePet')
	self:RegisterEvent('PLAYER_CONTROL_LOST', 'UpdatePet')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdatePet')
	self:RegisterEvent('PLAYER_FARSIGHT_FOCUS_CHANGED', 'UpdatePet')
	self:RegisterEvent('SPELLS_CHANGED', 'UpdatePet')
	self:RegisterEvent('UNIT_FLAGS', 'UpdatePet')
	self:RegisterEvent('UNIT_PET', 'UpdatePet')
	self:RegisterEvent('PET_BAR_UPDATE_COOLDOWN', PetActionBar_UpdateCooldowns)

	E:CreateMover(bar, 'PetAB', L["Pet Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,barPet')
	self:PositionAndSizeBarPet()
	self:UpdatePetBindings()

	self:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	self:HookScript(bar, 'OnLeave', 'Bar_OnLeave')
	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = _G['PetActionButton'..i]
		if not button.ICON then
			button.ICON = button:CreateTexture('PetActionButton'..i..'ICON')
			button.ICON:SetTexCoord(unpack(E.TexCoords))
			button.ICON:SetInside()

			if button.pushed then
				button.pushed:SetDrawLayer('ARTWORK', 1)
			end
		end

		self:HookScript(button, 'OnEnter', 'Button_OnEnter')
		self:HookScript(button, 'OnLeave', 'Button_OnLeave')

		if MasqueGroup and E.private.actionbar.masque.petBar then
			MasqueGroup:AddButton(button, {Icon=button.ICON})
		end
	end
end
