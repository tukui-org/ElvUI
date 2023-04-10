local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local ipairs, pairs, gsub = ipairs, pairs, gsub

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local hooksecurefunc = hooksecurefunc

local Masque = E.Masque
local MasqueGroup = Masque and Masque:Group('ElvUI', 'Totem Bar')

local bar = CreateFrame('Frame', 'ElvUI_TotemBar', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')

local SLOT_BORDER_COLORS = {
	summon					= {r = 0, g = 0, b = 0},
	[_G.EARTH_TOTEM_SLOT]	= {r = 0.23, g = 0.45, b = 0.13},
	[_G.FIRE_TOTEM_SLOT]	= {r = 0.58, g = 0.23, b = 0.10},
	[_G.WATER_TOTEM_SLOT]	= {r = 0.19, g = 0.48, b = 0.60},
	[_G.AIR_TOTEM_SLOT]		= {r = 0.42, g = 0.18, b = 0.74}
}

local SLOT_EMPTY_TCOORDS = {
	[_G.EARTH_TOTEM_SLOT]	= {left = 0.52, right = 0.75, top = 0.01, bottom = 0.13},
	[_G.FIRE_TOTEM_SLOT]	= {left = 0.52, right = 0.76, top = 0.39, bottom = 0.51},
	[_G.WATER_TOTEM_SLOT]	= {left = 0.30, right = 0.54, top = 0.82, bottom = 0.93},
	[_G.AIR_TOTEM_SLOT]		= {left = 0.52, right = 0.75, top = 0.14, bottom = 0.26}
}

function AB:MultiCastFlyoutFrameOpenButton_Show(button, which, parent)
	local color = which == 'page' and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[parent:GetID()]
	button:SetBackdropBorderColor(color.r, color.g, color.b)

	button:ClearAllPoints()
	if AB.db.totemBar.flyoutDirection == 'UP' then
		button:Point('BOTTOM', parent, 'TOP')
	else
		button:Point('TOP', parent, 'BOTTOM')
	end
end

function AB:MultiCastActionButton_Update(button)
	if InCombatLockdown() then
		AB.NeedsPositionAndSizeTotemBar = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
	end
end

function AB:StyleTotemSlotButton(button, slot)
	if button.useMasque then return end
	local color = SLOT_BORDER_COLORS[slot]
	if color then
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.ignoreBorderColors = true
	end
end

function AB:SkinMultiCastButton(button, noBackdrop, useMasque)
	if button.isSkinned then return end

	local name = button:GetName()
	local highlight = _G[name..'Highlight']
	local icon = button.icon or button.background
	local normal = button.NormalTexture or _G[name..'NormalTexture']

	button.noBackdrop = noBackdrop
	button.useMasque = useMasque
	button.db = AB.db.totemBar

	if normal then normal:SetTexture(nil) end
	if button.overlayTex then button.overlayTex:Hide() end
	if highlight then highlight:SetTexture(nil) end

	if not button.noBackdrop and not button.useMasque then
		button:SetTemplate()
	end

	if not useMasque then
		button:StyleButton()
		icon:SetDrawLayer('ARTWORK')
		icon:SetInside(button)
	else
		button:StyleButton(true, true, true)
	end

	if button.cooldown then
		AB:ColorSwipeTexture(button.cooldown)
		E:RegisterCooldown(button.cooldown, 'actionbar')
	end

	button.parentName = 'ElvUI_TotemBar'
	AB.handledbuttons[button] = true
	bar.buttons[button] = true
	button.isSkinned = true
end

function AB:MultiCastFlyoutFrame_ToggleFlyout(frame, which, parent)
	frame.top:SetTexture(nil)
	frame.middle:SetTexture(nil)

	local color = which == 'page' and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[parent:GetID()]
	local useMasque = MasqueGroup and E.private.actionbar.masque.actionbars
	local numButtons, totalHeight = 0, 0

	local buttonWidth = AB.db.totemBar.flyoutSize
	local buttonHeight = (AB.db.totemBar.keepSizeRatio and AB.db.totemBar.flyoutSize) or AB.db.totemBar.flyoutHeight
	local buttonSpacing = AB.db.totemBar.flyoutSpacing

	for i, button in ipairs(frame.buttons) do
		if not button.isSkinned then
			AB:SkinMultiCastButton(button, nil, useMasque)

			-- these only need mouseover script, dont need the bind key script
			AB:HookScript(button, 'OnEnter', 'TotemBar_OnEnter')
			AB:HookScript(button, 'OnLeave', 'TotemBar_OnLeave')
		end

		if button:IsShown() then
			numButtons = numButtons + 1

			if not useMasque then
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end

			button:Size(buttonWidth, buttonHeight)
			button:ClearAllPoints()

			AB:TrimIcon(button, useMasque)

			local anchor = (i == 1 and parent) or frame.buttons[i - 1]
			if AB.db.totemBar.flyoutDirection == 'UP' then
				button:Point('BOTTOM', anchor, 'TOP', 0, buttonSpacing)
			else
				button:Point('TOP', anchor, 'BOTTOM', 0, -buttonSpacing)
			end

			totalHeight = totalHeight + button:GetHeight() + buttonSpacing
		end
	end

	if which == 'slot' then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()]
		frame.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom)
	end

	local closeButton = _G.MultiCastFlyoutFrameCloseButton
	closeButton:SetBackdropBorderColor(color.r, color.g, color.b)

	frame:ClearAllPoints()
	closeButton:ClearAllPoints()
	if AB.db.totemBar.flyoutDirection == 'UP' then
		frame:Point('BOTTOM', parent, 'TOP')
		closeButton:Point('TOP', frame, 'TOP')
	else
		frame:Point('TOP', parent, 'BOTTOM')
		closeButton:Point('BOTTOM', frame, 'BOTTOM')
	end

	frame:Height(totalHeight + closeButton:GetHeight())
end

function AB:TotemButton_OnEnter()
	-- totem keybind support from actionbar module
	if E.private.actionbar.enable then
		AB:BindUpdate(self)
	end

	AB:TotemBar_OnEnter()
end

function AB:TotemButton_OnLeave()
	AB:TotemBar_OnLeave()
end

function AB:TotemBar_OnEnter()
	return bar.mouseover and E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), AB.db.totemBar.alpha)
end

function AB:TotemBar_OnLeave()
	return bar.mouseover and E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:PositionAndSizeTotemBar()
	if InCombatLockdown() then
		AB.NeedsPositionAndSizeTotemBar = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local barFrame = _G.MultiCastActionBarFrame
	local numActiveSlots = barFrame.numActiveSlots
	local buttonSpacing = AB.db.totemBar.spacing

	local buttonWidth = AB.db.totemBar.buttonSize
	local buttonHeight = (AB.db.totemBar.keepSizeRatio and AB.db.totemBar.buttonSize) or AB.db.totemBar.buttonHeight
	local useMasque = MasqueGroup and E.private.actionbar.masque.actionbars

	local mainWidth = (buttonWidth * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1))
	bar:Width(mainWidth)
	barFrame:Width(mainWidth)
	bar:Height(buttonHeight + 2)
	barFrame:Height(buttonHeight + 2)

	local _, barFrameAnchor = barFrame:GetPoint()
	if barFrameAnchor ~= bar then
		barFrame:SetPoint('TOP', bar)
		barFrame:SetPoint('BOTTOMLEFT', bar)
		barFrame:SetPoint('BOTTOM', barFrameAnchor)
	end -- this is Simpy voodoo, dont change it

	bar.mouseover = AB.db.totemBar.mouseover
	bar:SetAlpha(bar.mouseover and 0 or AB.db.totemBar.alpha)

	local visibility = gsub(AB.db.totemBar.visibility, '[\n\r]', '')
	RegisterStateDriver(bar, 'visibility', visibility)

	local summonButton = _G.MultiCastSummonSpellButton
	summonButton:ClearAllPoints()
	summonButton:Point('BOTTOMLEFT')
	summonButton:Size(buttonWidth, buttonHeight)

	for i = 1, numActiveSlots do
		local button = _G['MultiCastSlotButton'..i]
		local actionButton = _G['MultiCastActionButton'..i]
		local lastButton = _G['MultiCastSlotButton'..i - 1]

		button:Size(buttonWidth, buttonHeight)
		button:ClearAllPoints()

		actionButton:SetSize(button:GetSize()) -- these need to match for icon trim setting
		AB:TrimIcon(actionButton, useMasque)

		if i == 1 then
			button:Point('LEFT', summonButton, 'RIGHT', buttonSpacing, 0)
		else
			button:Point('LEFT', lastButton, 'RIGHT', buttonSpacing, 0)
		end
	end

	_G.MultiCastRecallSpellButton:Size(buttonWidth, buttonHeight)
	AB:MultiCastRecallSpellButton_Update()

	AB:TrimIcon(summonButton, useMasque)
	AB:TrimIcon(_G.MultiCastRecallSpellButton, useMasque)

	_G.MultiCastFlyoutFrameCloseButton:Width(buttonWidth)
	_G.MultiCastFlyoutFrameOpenButton:Width(buttonWidth)
end

function AB:UpdateTotemBindings()
	local font = LSM:Fetch('font', AB.db.totemBar.font)
	local size, outline = AB.db.totemBar.fontSize, AB.db.totemBar.fontOutline

	_G.MultiCastSummonSpellButtonHotKey:FontTemplate(font, size, outline)
	_G.MultiCastSummonSpellButtonHotKey:SetTextColor(1, 1, 1)
	AB:FixKeybindText(_G.MultiCastSummonSpellButton)

	_G.MultiCastRecallSpellButtonHotKey:FontTemplate(font, size, outline)
	_G.MultiCastRecallSpellButtonHotKey:SetTextColor(1, 1, 1)
	AB:FixKeybindText(_G.MultiCastRecallSpellButton)

	for i = 1, 12 do
		local button = _G['MultiCastActionButton'..i]
		button.HotKey:FontTemplate(font, size, outline)
		button.HotKey:SetTextColor(1, 1, 1)
		AB:FixKeybindText(button)
	end
end

function AB:MultiCastRecallSpellButton_Update(button)
	if InCombatLockdown() then
		AB.NeedsRecallButtonUpdate = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		if not button then button = _G.MultiCastRecallSpellButton end -- if we call it with no button, assume it's this one
		if button and button:GetID() then
			if self.hooks.MultiCastRecallSpellButton_Update then
				self.hooks.MultiCastRecallSpellButton_Update(button)
			else -- not hooked yet, call it straight (can taint)
				_G.MultiCastRecallSpellButton_Update(button)
			end
		end
	end
end

function AB:MultiCastFlyoutFrameStyle(button, rotate)
	button:SetTemplate()
	button:StyleButton()
	button.normalTexture:ClearAllPoints()
	button.normalTexture:SetPoint('CENTER')
	button.normalTexture:SetSize(16, 16)
	button.normalTexture:SetTexture(E.Media.Textures.ArrowUp)
	button.normalTexture:SetTexCoord(0, 1, 0, 1)
	button.normalTexture.SetTexCoord = E.noop

	if rotate then
		button.normalTexture:SetRotation(3.14)
	end

	bar.buttons[button] = true
end

function AB:CreateTotemBar()
	AB.TotemBar = bar -- Initialized

	bar:Size(200, 30)
	bar:Point('BOTTOM', E.UIParent, 0, 250)
	bar.buttons = {}

	local barFrame = _G.MultiCastActionBarFrame
	barFrame:SetScript('OnUpdate', nil)
	barFrame:SetScript('OnShow', nil)
	barFrame:SetScript('OnHide', nil)
	barFrame:SetParent(bar)

	AB:MultiCastFlyoutFrameStyle(_G.MultiCastFlyoutFrameCloseButton, true)
	AB:MultiCastFlyoutFrameStyle(_G.MultiCastFlyoutFrameOpenButton)

	for i = 1, 4 do
		local button = _G['MultiCastSlotButton'..i]
		button.icon = button.background
		AB:SkinMultiCastButton(button, nil, MasqueGroup and E.private.actionbar.masque.actionbars)
	end

	local isShaman = E.myclass == 'SHAMAN'
	for i = 1, 12 do
		local button = _G['MultiCastActionButton'..i]

		if isShaman then
			button:SetAttribute('type2', 'destroytotem')
			button:SetAttribute('*totem-slot*', _G.SHAMAN_TOTEM_PRIORITIES[i])
		end

		AB:SkinMultiCastButton(button, true, MasqueGroup and E.private.actionbar.masque.actionbars)

		button.HotKey.SetVertexColor = E.noop
		button.commandName = button.buttonType .. button.buttonIndex -- hotkey support
	end

	local summonButton = _G.MultiCastSummonSpellButton
	AB:SkinMultiCastButton(summonButton)
	summonButton.commandName = summonButton.buttonType..'1' -- hotkey support

	local spellButton = _G.MultiCastRecallSpellButton
	AB:SkinMultiCastButton(spellButton)
	spellButton.commandName = spellButton.buttonType..'1' -- hotkey support

	for button in pairs(bar.buttons) do
		button:HookScript('OnEnter', AB.TotemButton_OnEnter)
		button:HookScript('OnLeave', AB.TotemButton_OnLeave)
	end

	hooksecurefunc(spellButton, 'SetPoint', function(button, point, attachTo, anchorPoint, xOffset, yOffset)
		if InCombatLockdown() then
			AB.NeedsRecallButtonUpdate = true
			AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		elseif xOffset ~= AB.db.totemBar.spacing or button:GetPoint(2) then
			button:ClearAllPoints()
			button:SetPoint(point, attachTo, anchorPoint, AB.db.totemBar.spacing, yOffset)
		end
	end)

	AB:UpdateTotemBindings()

	AB:RawHook('MultiCastRecallSpellButton_Update', 'MultiCastRecallSpellButton_Update', true)

	AB:SecureHook('MultiCastFlyoutFrameOpenButton_Show')
	AB:SecureHook('MultiCastActionButton_Update')
	AB:SecureHook('MultiCastFlyoutFrame_ToggleFlyout')
	AB:SecureHook('MultiCastSlotButton_Update', 'StyleTotemSlotButton')

	AB:HookScript(_G.MultiCastActionBarFrame, 'OnEnter', 'TotemBar_OnEnter')
	AB:HookScript(_G.MultiCastActionBarFrame, 'OnLeave', 'TotemBar_OnLeave')

	AB:HookScript(_G.MultiCastFlyoutFrame, 'OnEnter', 'TotemBar_OnEnter')
	AB:HookScript(_G.MultiCastFlyoutFrame, 'OnLeave', 'TotemBar_OnLeave')

	E:CreateMover(bar, 'TotemBarMover', L["Totem Bar"], nil, nil, nil, nil, nil, 'actionbar,totemBar')
end
