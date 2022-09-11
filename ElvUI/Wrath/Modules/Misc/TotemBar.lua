local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local ipairs, pairs = ipairs, pairs
local unpack, gsub = unpack, gsub

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local hooksecurefunc = hooksecurefunc

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
	if E.db.general.totems.flyoutDirection == 'UP' then
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
	local color = SLOT_BORDER_COLORS[slot]
	if color then
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.ignoreBorderColors = true
	end
end

function AB:SkinSummonButton(button)
	local name = button:GetName()
	local icon = _G[name..'Icon']
	local highlight = _G[name..'Highlight']
	local normal = _G[name..'NormalTexture']

	button:SetTemplate()
	button:StyleButton()

	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetDrawLayer('ARTWORK')
	icon:SetInside(button)

	highlight:SetTexture(nil)
	normal:SetTexture(nil)
end

function AB:MultiCastFlyoutFrame_ToggleFlyout(frame, which, parent)
	frame.top:SetTexture(nil)
	frame.middle:SetTexture(nil)

	local color = which == 'page' and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[parent:GetID()]
	local numButtons = 0
	local totalHeight = 0

	for i, button in ipairs(frame.buttons) do
		if not button.isSkinned then
			button:SetTemplate()
			button:StyleButton()

			button.icon:SetDrawLayer('ARTWORK')
			button.icon:SetInside(button)

			-- these only need mouseover script, dont need the bind key script
			AB:HookScript(button, 'OnEnter', 'TotemBar_OnEnter')
			AB:HookScript(button, 'OnLeave', 'TotemBar_OnLeave')

			bar.buttons[button] = true

			button.isSkinned = true
		end

		if button:IsShown() then
			numButtons = numButtons + 1
			button:Size(E.db.general.totems.flyoutSize)
			button:ClearAllPoints()

			if E.db.general.totems.flyoutDirection == 'UP' then
				button:Point('BOTTOM', i == 1 and parent or frame.buttons[i - 1], 'TOP', 0, E.db.general.totems.flyoutSpacing)
			else
				button:Point('TOP', i == 1 and parent or frame.buttons[i - 1], 'BOTTOM', 0, -E.db.general.totems.flyoutSpacing)
			end

			button:SetBackdropBorderColor(color.r, color.g, color.b)

			button.icon:SetTexCoord(unpack(E.TexCoords))
			totalHeight = totalHeight + button:GetHeight() + E.db.general.totems.flyoutSpacing
		end
	end

	if which == 'slot' then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()]
		frame.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom)
	end

	local closeButton = _G.MultiCastFlyoutFrameCloseButton
	frame.buttons[1]:SetBackdropBorderColor(color.r, color.g, color.b)
	closeButton:SetBackdropBorderColor(color.r, color.g, color.b)

	frame:ClearAllPoints()
	closeButton:ClearAllPoints()
	if E.db.general.totems.flyoutDirection == 'UP' then
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
	return bar.mouseover and E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), E.db.general.totems.alpha)
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
	local buttonSpacing = E.db.general.totems.spacing
	local size = E.db.general.totems.buttonSize

	local mainSize = (size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1))
	bar:Width(mainSize)
	barFrame:Width(mainSize)
	bar:Height(size + 2)
	barFrame:Height(size + 2)

	local _, barFrameAnchor = barFrame:GetPoint()
	if barFrameAnchor ~= bar then
		barFrame:SetPoint('TOP', bar)
		barFrame:SetPoint('BOTTOMLEFT', bar)
		barFrame:SetPoint('BOTTOM', barFrameAnchor)
	end -- this is Simpy voodoo, dont change it

	bar.mouseover = E.db.general.totems.mouseover
	bar:SetAlpha(bar.mouseover and 0 or E.db.general.totems.alpha)

	local visibility = E.db.general.totems.visibility
	visibility = gsub(visibility, '[\n\r]','')

	RegisterStateDriver(bar, 'visibility', visibility)

	local summonButton = _G.MultiCastSummonSpellButton
	summonButton:ClearAllPoints()
	summonButton:Point('BOTTOMLEFT')
	summonButton:Size(size)

	for i = 1, numActiveSlots do
		local button = _G['MultiCastSlotButton'..i]
		local lastButton = _G['MultiCastSlotButton'..i - 1]

		button:Size(size)
		button:ClearAllPoints()

		if i == 1 then
			button:Point('LEFT', summonButton, 'RIGHT', buttonSpacing, 0)
		else
			button:Point('LEFT', lastButton, 'RIGHT', buttonSpacing, 0)
		end
	end

	_G.MultiCastRecallSpellButton:Size(size)
	AB:MultiCastRecallSpellButton_Update()

	_G.MultiCastFlyoutFrameCloseButton:Width(size)
	_G.MultiCastFlyoutFrameOpenButton:Width(size)
end

function AB:UpdateTotemBindings()
	local font = LSM:Fetch('font', E.db.general.totems.font)
	local size, outline = E.db.general.totems.fontSize, E.db.general.totems.fontOutline

	_G.MultiCastSummonSpellButtonHotKey:SetTextColor(1, 1, 1)
	_G.MultiCastSummonSpellButtonHotKey:FontTemplate(font, size, outline)
	AB:FixKeybindText(_G.MultiCastSummonSpellButton)

	_G.MultiCastRecallSpellButtonHotKey:SetTextColor(1, 1, 1)
	_G.MultiCastRecallSpellButtonHotKey:FontTemplate(font, size, outline)
	AB:FixKeybindText(_G.MultiCastRecallSpellButton)

	for i = 1, 12 do
		local hotkey = _G['MultiCastActionButton'..i..'HotKey']
		hotkey:SetTextColor(1, 1, 1)
		hotkey:FontTemplate(font, size, outline)
		AB:FixKeybindText(_G['MultiCastActionButton'..i])
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

	local closeButton = _G.MultiCastFlyoutFrameCloseButton
	closeButton:SetTemplate()
	closeButton.normalTexture:ClearAllPoints()
	closeButton.normalTexture:SetPoint('CENTER')
	closeButton.normalTexture:SetSize(16, 16)
	closeButton.normalTexture:SetTexture(E.Media.Textures.ArrowUp)
	closeButton.normalTexture:SetTexCoord(0, 1, 0, 1)
	closeButton.normalTexture:SetRotation(3.14)
	closeButton.normalTexture.SetTexCoord = E.noop
	closeButton:StyleButton()
	bar.buttons[closeButton] = true

	local openButton = _G.MultiCastFlyoutFrameOpenButton
	openButton:SetTemplate()
	openButton.normalTexture:ClearAllPoints()
	openButton.normalTexture:SetPoint('CENTER')
	openButton.normalTexture:SetSize(16, 16)
	openButton.normalTexture:SetTexture(E.Media.Textures.ArrowUp)
	openButton.normalTexture:SetTexCoord(0, 1, 0, 1)
	openButton.normalTexture.SetTexCoord = E.noop
	openButton:StyleButton()
	bar.buttons[openButton] = true

	for i = 1, 4 do
		local button = _G['MultiCastSlotButton'..i]
		local overlay = _G['MultiCastSlotButton'..i].overlayTex

		button:SetTemplate()
		button:StyleButton()

		button.background:SetTexCoord(unpack(E.TexCoords))
		button.background:SetDrawLayer('ARTWORK')
		button.background:SetInside(button)

		overlay:Hide()

		bar.buttons[button] = true
	end

	local isShaman = E.myclass == 'SHAMAN'
	for i = 1, 12 do
		local button = _G['MultiCastActionButton'..i]
		local icon = _G['MultiCastActionButton'..i..'Icon']
		local hotkey = _G['MultiCastActionButton'..i..'HotKey']
		local normal = _G['MultiCastActionButton'..i..'NormalTexture']
		local cooldown = _G['MultiCastActionButton'..i..'Cooldown']
		local overlay = _G['MultiCastActionButton'..i].overlayTex

		if isShaman then
			button:SetAttribute('type2', 'destroytotem')
			button:SetAttribute('*totem-slot*', _G.SHAMAN_TOTEM_PRIORITIES[i])
		end

		button:StyleButton()
		normal:SetTexture('')
		overlay:Hide()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer('ARTWORK')
		icon:SetInside()

		hotkey.SetVertexColor = E.noop
		button.commandName = button.buttonType .. button.buttonIndex -- hotkey support

		E:RegisterCooldown(cooldown)

		bar.buttons[button] = true
	end

	local summonButton = _G.MultiCastSummonSpellButton
	AB:SkinSummonButton(summonButton)
	summonButton.commandName = summonButton.buttonType..'1' -- hotkey support
	bar.buttons[summonButton] = true

	local spellButton = _G.MultiCastRecallSpellButton
	AB:SkinSummonButton(spellButton)
	spellButton.commandName = spellButton.buttonType..'1' -- hotkey support
	bar.buttons[spellButton] = true

	for button in pairs(bar.buttons) do
		button:HookScript('OnEnter', AB.TotemButton_OnEnter)
		button:HookScript('OnLeave', AB.TotemButton_OnLeave)
	end

	hooksecurefunc(spellButton, 'SetPoint', function(button, point, attachTo, anchorPoint, xOffset, yOffset)
		if InCombatLockdown() then
			AB.NeedsRecallButtonUpdate = true
			AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		elseif xOffset ~= E.db.general.totems.spacing or button:GetPoint(2) then
			button:ClearAllPoints()
			button:SetPoint(point, attachTo, anchorPoint, E.db.general.totems.spacing, yOffset)
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

	E:CreateMover(bar, 'TotemBarMover', L["Class Totems"], nil, nil, nil, nil, nil, 'general,totems')
end
