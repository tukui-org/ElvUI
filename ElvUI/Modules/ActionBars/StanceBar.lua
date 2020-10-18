local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local unpack = unpack
local format, strfind = format, strfind
local CooldownFrame_Set = CooldownFrame_Set
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftForm = GetShapeshiftForm
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetSpellInfo = GetSpellInfo
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
	local start, duration, enable, cooldown
	for i = 1, NUM_STANCE_SLOTS do
		if i <= numForms then
			cooldown = _G['ElvUI_StanceBarButton'..i..'Cooldown']
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)
			cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5) --Cooldown Bling Fix
		end
	end

	self:StyleShapeShift('UPDATE_SHAPESHIFT_COOLDOWN')
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms()
	local stance = GetShapeshiftForm()
	local darkenInactive = self.db.stanceBar.style == 'darkenInactive'

	for i = 1, NUM_STANCE_SLOTS do
		local buttonName = 'ElvUI_StanceBarButton'..i
		local button = _G[buttonName]
		local cooldown = _G[buttonName..'Cooldown']

		button.icon:Hide()

		if i <= numForms then
			local texture, isActive, isCastable, spellID, _ = GetShapeshiftFormInfo(i)

			if darkenInactive then
				_, _, texture = GetSpellInfo(spellID)
			end

			if not texture then texture = WispSplode end

			button.ICON:SetTexture(texture)

			if not button.useMasque then
				cooldown:SetAlpha(1)

				if isActive then
					_G.StanceBarFrame.lastSelected = button:GetID()
					if numForms == 1 then
						button.checked:SetColorTexture(1, 1, 1, 0.5)
						button:SetChecked(true)
					else
						button.checked:SetColorTexture(1, 1, 1, 0.5)
						button:SetChecked(not darkenInactive)
					end
				else
					if numForms == 1 or stance == 0 then
						button:SetChecked(false)
					else
						button:SetChecked(darkenInactive)
						button.checked:SetAlpha(1)
						if darkenInactive then
							button.checked:SetColorTexture(0, 0, 0, 0.5)
						else
							button.checked:SetColorTexture(1, 1, 1, 0.5)
						end
					end
				end
			else
				if isActive then
					button:SetChecked(true)
				else
					button:SetChecked(false)
				end
			end

			if isCastable then
				button.ICON:SetVertexColor(1.0, 1.0, 1.0)
			else
				button.ICON:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local buttonSpacing = self.db.stanceBar.buttonspacing
	local backdropSpacing = self.db.stanceBar.backdropSpacing
	local buttonsPerRow = self.db.stanceBar.buttonsPerRow
	local numButtons = self.db.stanceBar.buttons
	local size = self.db.stanceBar.buttonsize
	local point = self.db.stanceBar.point
	local widthMult = self.db.stanceBar.widthMult
	local heightMult = self.db.stanceBar.heightMult

	--Convert 'TOP' or 'BOTTOM' to anchor points we can use
	local position = E:GetScreenQuadrant(bar)
	if strfind(position, 'LEFT') or position == 'TOP' or position == 'BOTTOM' then
		if point == 'TOP' then point = 'TOPLEFT' elseif point == 'BOTTOM' then point = 'BOTTOMLEFT' end
	elseif point == 'TOP' then point = 'TOPRIGHT' elseif point == 'BOTTOM' then point = 'BOTTOMRIGHT' end

	bar.db = self.db.stanceBar

	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton
	end
	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton
	end
	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons
	end

	local verticalGrowth = (point == 'TOPLEFT' or point == 'TOPRIGHT') and 'DOWN' or 'UP'
	local horizontalGrowth = (point == 'BOTTOMLEFT' or point == 'TOPLEFT') and 'RIGHT' or 'LEFT'
	local anchorUp, anchorLeft = verticalGrowth == 'UP', horizontalGrowth == 'LEFT'

	bar.backdrop:SetShown(self.db.stanceBar.backdrop)
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

	bar.mouseover = self.db.stanceBar.mouseover
	if bar.mouseover then
		bar:SetAlpha(0)
		AB:FadeBarBlings(bar, 0)
	else
		bar:SetAlpha(bar.db.alpha)
		AB:FadeBarBlings(bar, bar.db.alpha)
	end

	if self.db.stanceBar.inheritGlobalFade then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	bar:EnableMouse(not self.db.stanceBar.clickThrough)

	local button, lastButton, lastColumnButton, anchorRowButton, lastShownButton
	local useMasque = MasqueGroup and E.private.actionbar.masque.stanceBar
	local firstButtonSpacing = (self.db.stanceBar.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)

	for i = 1, NUM_STANCE_SLOTS do
		button = _G['ElvUI_StanceBarButton'..i]
		lastButton = _G['ElvUI_StanceBarButton'..i-1]
		lastColumnButton = _G['ElvUI_StanceBarButton'..i-buttonsPerRow]
		button:SetParent(bar)
		button:ClearAllPoints()
		button:Size(size)
		button:EnableMouse(not self.db.stanceBar.clickThrough)

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
			button:SetAlpha(0)
		else
			button:SetAlpha(bar.db.alpha)

			local anchorPoint = anchorUp and 'TOP' or 'BOTTOM'
			bar.backdrop:Point(anchorPoint, button, anchorPoint, 0, anchorUp and backdropSpacing or -backdropSpacing)
			lastShownButton = button
		end

		if not button.ICON then
			button.ICON = button:CreateTexture('ElvUI_StanceBarButton'..i..'ICON')
			button.ICON:SetTexCoord(unpack(E.TexCoords))
			button.ICON:SetInside()

			if button.pushed then
				button.pushed:SetDrawLayer('ARTWORK', 1)
			end
		end

		if useMasque then
			MasqueGroup:AddButton(bar.buttons[i], {Icon=bar.buttons[i].ICON})
		end

		if not button.FlyoutUpdateFunc then
			self:StyleButton(button, nil, useMasque and true or nil, true)

			if not useMasque then
				if self.db.stanceBar.style == 'darkenInactive' then
					button.checked:SetBlendMode('BLEND')
				else
					button.checked:SetBlendMode('ADD')
				end
			end
		end
	end

	AB:HandleBackdropMultiplier(bar, backdropSpacing, buttonSpacing, widthMult, heightMult, anchorUp, anchorLeft, horizontalGrowth, lastShownButton, anchorRowButton)
	AB:HandleBackdropMover(bar, backdropSpacing)

	if useMasque then
		MasqueGroup:ReSkin()
	end

	if self.db.stanceBar.enabled then
		local visibility = self.db.stanceBar.visibility
		if visibility and visibility:match('[\n\r]') then
			visibility = visibility:gsub('[\n\r]','')
		end

		RegisterStateDriver(bar, 'visibility', (GetNumShapeshiftForms() == 0 and 'hide') or visibility)
		E:EnableMover(bar.mover:GetName())
	else
		RegisterStateDriver(bar, 'visibility', 'hide')
		E:DisableMover(bar.mover:GetName())
	end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then
		AB.NeedsAdjustMaxStanceButtons = event or true
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	for i = 1, #bar.buttons do
		bar.buttons[i]:Hide()
	end

	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame('CheckButton', format(bar:GetName()..'Button%d', i), bar, 'StanceButtonTemplate')
			bar.buttons[i]:SetID(i)

			self:HookScript(bar.buttons[i], 'OnEnter', 'Button_OnEnter')
			self:HookScript(bar.buttons[i], 'OnLeave', 'Button_OnLeave')
		end

		local blizz = _G[format('StanceButton%d', i)]
		if blizz and blizz.commandName then
			bar.buttons[i].commandName = blizz.commandName
		end

		if i <= numButtons then
			bar.buttons[i]:Show()
			bar.LastButton = i
		else
			bar.buttons[i]:Hide()
		end
	end

	self:PositionAndSizeBarShapeShift()

	-- sometimes after combat lock down `event` may be true because of passing it back with `AB.NeedsAdjustMaxStanceButtons`
	if event == 'UPDATE_SHAPESHIFT_FORMS' or event == 'PLAYER_ENTERING_WORLD' then
		self:StyleShapeShift()
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_STANCE_SLOTS do
		local button = _G['ElvUI_StanceBarButton'..i]
		if not button then break end

		if self.db.hotkeytext then
			button.HotKey:Show()
			button.HotKey:SetText(GetBindingKey('SHAPESHIFTBUTTON'..i))

			self:FixKeybindText(button)
		else
			button.HotKey:Hide()
		end
	end
end

function AB:CreateBarShapeShift()
	bar.backdrop = CreateFrame('Frame', nil, bar, 'BackdropTemplate')
	bar.backdrop:SetTemplate(AB.db.transparent and 'Transparent')
	bar.backdrop:SetFrameLevel(0)

	bar:Point('TOPLEFT', E.UIParent, 'BOTTOMLEFT', 4, -769)

	self:HookScript(bar, 'OnEnter', 'Bar_OnEnter')
	self:HookScript(bar, 'OnLeave', 'Bar_OnLeave')

	self:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN')
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', 'AdjustMaxStanceButtons')
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'StyleShapeShift')
	self:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', 'StyleShapeShift')
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED', 'StyleShapeShift')

	E:CreateMover(bar, 'ShiftAB', L["Stance Bar"], nil, -3, nil, 'ALL,ACTIONBARS', nil, 'actionbar,stanceBar', true)
end
