local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local unpack, ipairs, pairs = unpack, ipairs, pairs
local gsub, strmatch = gsub, strmatch

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local hooksecurefunc = hooksecurefunc

local bar = CreateFrame('Frame', 'ElvUI_BarTotem', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')

local SLOT_BORDER_COLORS = {
	summon					= {r = 0, g = 0, b = 0},
	[_G.EARTH_TOTEM_SLOT]	= {r = 0.23, g = 0.45, b = 0.13},
	[_G.FIRE_TOTEM_SLOT]	= {r = 0.58, g = 0.23, b = 0.10},
	[_G.WATER_TOTEM_SLOT]	= {r = 0.19, g = 0.48, b = 0.60},
	[_G.AIR_TOTEM_SLOT]		= {r = 0.42, g = 0.18, b = 0.74}
}

local SLOT_EMPTY_TCOORDS = {
	[_G.EARTH_TOTEM_SLOT]	= {left = 66/128, right = 96/128, top = 3/256,   bottom = 33/256},
	[_G.FIRE_TOTEM_SLOT]	= {left = 67/128, right = 97/128, top = 100/256, bottom = 130/256},
	[_G.WATER_TOTEM_SLOT]	= {left = 39/128, right = 69/128, top = 209/256, bottom = 239/256},
	[_G.AIR_TOTEM_SLOT]		= {left = 66/128, right = 96/128, top = 36/256,  bottom = 66/256}
}

function AB:MultiCastFlyoutFrameOpenButton_Show(button, type, parent)
	local color = type == 'page' and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[parent:GetID()]
	button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	button:ClearAllPoints()
	if E.db.general.totems.flyoutDirection == 'UP' then
		button:Point('BOTTOM', parent, 'TOP')
		button.icon:SetRotation(0)
	elseif E.db.general.totems.flyoutDirection == 'DOWN' then
		button:Point('TOP', parent, 'BOTTOM')
		button.icon:SetRotation(3.14)
	end
end

function AB:MultiCastActionButton_Update(button)
	if InCombatLockdown() then
		AB.NeedsPositionAndSizeBarTotem = true
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

	button:SetTemplate('Default')
	button:StyleButton()

	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetDrawLayer('ARTWORK')
	icon:SetInside(button)

	highlight:SetTexture(nil)
	normal:SetTexture(nil)
end

function AB:MultiCastFlyoutFrame_ToggleFlyout(frame, type, parent)
	frame.top:SetTexture(nil)
	frame.middle:SetTexture(nil)

	local color = type == 'page' and SLOT_BORDER_COLORS.summon or SLOT_BORDER_COLORS[parent:GetID()]
	local numButtons = 0
	local totalHeight = 0

	for i, button in ipairs(frame.buttons) do
		if not button.isSkinned then
			button:SetTemplate('Default')
			button:StyleButton()

			AB:HookScript(button, 'OnEnter', 'TotemOnEnter')
			AB:HookScript(button, 'OnLeave', 'TotemOnLeave')

			button:SetFrameStrata('MEDIUM')
			button.icon:SetDrawLayer('ARTWORK')
			button.icon:SetInside(button)

			bar.buttons[button] = true

			button.isSkinned = true
		end

		if button:IsShown() then
			numButtons = numButtons + 1
			button:Size(E.db.general.totems.flyoutSize)
			button:ClearAllPoints()

			if E.db.general.totems.flyoutDirection == 'UP' then
				if i == 1 then
					button:Point('BOTTOM', parent, 'TOP', 0, E.db.general.totems.flyoutSpacing)
				else
					button:Point('BOTTOM', frame.buttons[i - 1], 'TOP', 0, E.db.general.totems.flyoutSpacing)
				end
			elseif E.db.general.totems.flyoutDirection == 'DOWN' then
				if i == 1 then
					button:Point('TOP', parent, 'BOTTOM', 0, -E.db.general.totems.flyoutSpacing)
				else
					button:Point('TOP', frame.buttons[i - 1], 'BOTTOM', 0, -E.db.general.totems.flyoutSpacing)
				end
			end

			button:SetBackdropBorderColor(color.r, color.g, color.b)

			button.icon:SetTexCoord(unpack(E.TexCoords))
			totalHeight = totalHeight + button:GetHeight() + E.db.general.totems.flyoutSpacing
		end
	end

	if type == 'slot' then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()]
		frame.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom)
	end

	local closeButton = _G.MultiCastFlyoutFrameCloseButton
	frame.buttons[1]:SetBackdropBorderColor(color.r, color.g, color.b)
	closeButton.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	frame:ClearAllPoints()
	closeButton:ClearAllPoints()
	if E.db.general.totems.flyoutDirection == 'UP' then
		frame:Point('BOTTOM', parent, 'TOP')

		closeButton:Point('TOP', frame, 'TOP')
		closeButton.icon:SetRotation(3.14)
	elseif E.db.general.totems.flyoutDirection == 'DOWN' then
		frame:Point('TOP', parent, 'BOTTOM')

		closeButton:Point('BOTTOM', frame, 'BOTTOM')
		closeButton.icon:SetRotation(0)
	end

	frame:Height(totalHeight + closeButton:GetHeight())
end

function AB:TotemOnEnter()
	if bar.mouseover then
		E:UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), E.db.general.totems.alpha)
	end
end

function AB:TotemOnLeave()
	if bar.mouseover then
		E:UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
	end
end

function AB:ShowMultiCastActionBar()
	AB:PositionAndSizeBarTotem()
end

function AB:PositionAndSizeBarTotem()
	if InCombatLockdown() then
		AB.NeedsPositionAndSizeBarTotem = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local barFrame = _G.MultiCastActionBarFrame
	local numActiveSlots = barFrame.numActiveSlots
	local buttonSpacing = E.db.general.totems.spacing
	local size = E.db.general.totems.buttonSize

	-- TODO: Wrath fix pixels
	local mainSize = (size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1))
	bar:Width(mainSize)
	barFrame:Width(mainSize)
	bar:Height(size + 2)
	barFrame:Height(size + 2)

	bar.mouseover = E.db.general.totems.mouseover
	if bar.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(E.db.general.totems.alpha)
	end

	local visibility = E.db.general.totems.visibility
	if visibility and strmatch(visibility, '[\n\r]') then
		visibility = gsub(visibility, '[\n\r]','')
	end

	RegisterStateDriver(bar, 'visibility', visibility)

	local summonButton = _G.MultiCastSummonSpellButton
	summonButton:ClearAllPoints()
	summonButton:Size(size)
	summonButton:Point('BOTTOMLEFT', E.Border*2, E.Border*2) -- TODO: Wrath

	for i = 1, numActiveSlots do
		local button = _G['MultiCastSlotButton'..i]
		local lastButton = _G['MultiCastSlotButton'..i - 1]

		button:ClearAllPoints()
		button:Size(size)

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
	_G.MultiCastSummonSpellButtonHotKey:SetTextColor(1, 1, 1)
	_G.MultiCastSummonSpellButtonHotKey:FontTemplate(LSM:Fetch('font', E.db.general.totems.font), E.db.general.totems.fontSize, E.db.general.totems.fontOutline)
	AB:FixKeybindText(_G.MultiCastSummonSpellButton)

	_G.MultiCastRecallSpellButtonHotKey:SetTextColor(1, 1, 1)
	_G.MultiCastRecallSpellButtonHotKey:FontTemplate(LSM:Fetch('font', E.db.general.totems.font), E.db.general.totems.fontSize, E.db.general.totems.fontOutline)
	AB:FixKeybindText(_G.MultiCastRecallSpellButton)

	local font = LSM:Fetch('font', E.db.general.totems.font)
	local size, outline = E.db.general.totems.fontSize, E.db.general.totems.fontOutline
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
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 250)
	bar.buttons = {}

	local barFrame = _G.MultiCastActionBarFrame
	barFrame:SetParent(bar)
	barFrame:ClearAllPoints()
	barFrame:SetPoint('BOTTOMLEFT', bar, 'BOTTOMLEFT', -E.Border, -E.Border)
	barFrame:SetScript('OnUpdate', nil)
	barFrame:SetScript('OnShow', nil)
	barFrame:SetScript('OnHide', nil)
	barFrame.SetParent = E.noop
	barFrame.SetPoint = E.noop

	local closeButton = _G.MultiCastFlyoutFrameCloseButton
	closeButton:CreateBackdrop('Default', true, true)
	closeButton.backdrop:SetPoint('TOPLEFT', 0, -(E.Border + E.Spacing))
	closeButton.backdrop:SetPoint('BOTTOMRIGHT', 0, E.Border + E.Spacing)
	closeButton.icon = closeButton:CreateTexture(nil, 'ARTWORK')
	closeButton.icon:Size(16)
	closeButton.icon:SetPoint('CENTER')
	closeButton.icon:SetTexture(E.Media.Textures.ArrowUp)
	closeButton.normalTexture:SetTexture('')
	closeButton:StyleButton()
	closeButton.hover:SetInside(closeButton.backdrop)
	closeButton.pushed:SetInside(closeButton.backdrop)
	bar.buttons[closeButton] = true

	local openButton = _G.MultiCastFlyoutFrameOpenButton
	openButton:CreateBackdrop('Default', true, true)
	openButton.backdrop:SetPoint('TOPLEFT', 0, -(E.Border + E.Spacing))
	openButton.backdrop:SetPoint('BOTTOMRIGHT', 0, E.Border + E.Spacing)
	openButton.icon = openButton:CreateTexture(nil, 'ARTWORK')
	openButton.icon:Size(16)
	openButton.icon:SetPoint('CENTER')
	openButton.icon:SetTexture(E.Media.Textures.ArrowUp)
	openButton.normalTexture:SetTexture('')
	openButton:StyleButton()
	openButton.hover:SetInside(openButton.backdrop)
	openButton.pushed:SetInside(openButton.backdrop)
	bar.buttons[openButton] = true

	local summonButton = _G.MultiCastSummonSpellButton
	AB:SkinSummonButton(summonButton)
	bar.buttons[summonButton] = true

	local spellButton = _G.MultiCastRecallSpellButton
	AB:SkinSummonButton(spellButton)
	bar.buttons[spellButton] = true

	hooksecurefunc(spellButton, 'SetPoint', function(button, point, attachTo, anchorPoint, xOffset, yOffset)
		if xOffset ~= E.db.general.totems.spacing then
			if InCombatLockdown() then
				AB.NeedsRecallButtonUpdate = true
				AB:RegisterEvent('PLAYER_REGEN_ENABLED')
			else
				button:ClearAllPoints()
				button:SetPoint(point, attachTo, anchorPoint, E.db.general.totems.spacing, yOffset)
			end
		end
	end)

	-- TODO: Wrath (Check for a better skinning method)
	for i = 1, 4 do
		local button = _G['MultiCastSlotButton'..i]
		local overlay = _G['MultiCastSlotButton'..i].overlayTex

		button:SetTemplate('Default')
		button:StyleButton()

		button.background:SetTexCoord(unpack(E.TexCoords))
		button.background:SetDrawLayer('ARTWORK')
		button.background:SetInside(button)

		overlay:Hide()

		bar.buttons[button] = true
	end

	-- TODO: Wrath (Check for a better skinning method)
	for i = 1, 12 do
		local button = _G['MultiCastActionButton'..i]
		local icon = _G['MultiCastActionButton'..i..'Icon']
		local normal = _G['MultiCastActionButton'..i..'NormalTexture']
		local cooldown = _G['MultiCastActionButton'..i..'Cooldown']
		local overlay = _G['MultiCastActionButton'..i].overlayTex

		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer('ARTWORK')
		icon:SetInside()

		normal:SetTexture('')

		overlay:Hide()

		_G['MultiCastActionButton'..i..'HotKey'].SetVertexColor = E.noop

		E:RegisterCooldown(cooldown)

		bar.buttons[button] = true
	end

	for button in pairs(bar.buttons) do
		button:HookScript('OnEnter', AB.TotemOnEnter)
		button:HookScript('OnLeave', AB.TotemOnLeave)
	end

	AB:UpdateTotemBindings()

	AB:RawHook('MultiCastRecallSpellButton_Update', 'MultiCastRecallSpellButton_Update', true)

	AB:SecureHook('MultiCastFlyoutFrameOpenButton_Show')
	AB:SecureHook('MultiCastActionButton_Update')
	AB:SecureHook('MultiCastSlotButton_Update', 'StyleTotemSlotButton')
	AB:SecureHook('MultiCastFlyoutFrame_ToggleFlyout')
	AB:SecureHook('ShowMultiCastActionBar')

	AB:HookScript(_G.MultiCastActionBarFrame, 'OnEnter', 'TotemOnEnter')
	AB:HookScript(_G.MultiCastActionBarFrame, 'OnLeave', 'TotemOnLeave')

	AB:HookScript(_G.MultiCastFlyoutFrame, 'OnEnter', 'TotemOnEnter')
	AB:HookScript(_G.MultiCastFlyoutFrame, 'OnLeave', 'TotemOnLeave')

	E:CreateMover(bar, 'TotemBarMover', L["Class Totems"], nil, nil, nil, nil, nil, 'general,totems')
end
