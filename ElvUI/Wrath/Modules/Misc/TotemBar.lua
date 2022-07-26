local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local unpack, ipairs, pairs = unpack, ipairs, pairs
local gsub, match = string.gsub, string.match

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver

local bar = CreateFrame('Frame', 'ElvUI_BarTotem', E.UIParent, 'SecureHandlerStateTemplate')
bar:SetFrameStrata('LOW')

local SLOT_BORDER_COLORS = {
	['summon']			= {r = 0, g = 0, b = 0},
	[EARTH_TOTEM_SLOT]	= {r = 0.23, g = 0.45, b = 0.13},
	[FIRE_TOTEM_SLOT]	= {r = 0.58, g = 0.23, b = 0.10},
	[WATER_TOTEM_SLOT]	= {r = 0.19, g = 0.48, b = 0.60},
	[AIR_TOTEM_SLOT]	= {r = 0.42, g = 0.18, b = 0.74}
}

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT]	= {left = 66/128, right = 96/128, top = 3/256,   bottom = 33/256},
	[FIRE_TOTEM_SLOT]	= {left = 67/128, right = 97/128, top = 100/256, bottom = 130/256},
	[WATER_TOTEM_SLOT]	= {left = 39/128, right = 69/128, top = 209/256, bottom = 239/256},
	[AIR_TOTEM_SLOT]	= {left = 66/128, right = 96/128, top = 36/256,  bottom = 66/256}
}

local oldMultiCastRecallSpellButton_Update = MultiCastRecallSpellButton_Update
function MultiCastRecallSpellButton_Update(self)
	if InCombatLockdown() then AB.NeedRecallButtonUpdate = true; AB:RegisterEvent('PLAYER_REGEN_ENABLED') return end

	oldMultiCastRecallSpellButton_Update(self)
end

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
	if InCombatLockdown() then bar.eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED') return end
	button:ClearAllPoints()
	button:SetAllPoints(button.slotButton)
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
	for i, button in ipairs(frame.buttons) do
		if not button.isSkinned then
			button:SetTemplate('Default')
			button:StyleButton()

			AB:HookScript(button, 'OnEnter', 'TotemOnEnter')
			AB:HookScript(button, 'OnLeave', 'TotemOnLeave')

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
		end
	end

	if type == 'slot' then
		local tCoords = SLOT_EMPTY_TCOORDS[parent:GetID()]
		frame.buttons[1].icon:SetTexCoord(tCoords.left, tCoords.right, tCoords.top, tCoords.bottom)
	end

	frame.buttons[1]:SetBackdropBorderColor(color.r, color.g, color.b)
	MultiCastFlyoutFrameCloseButton.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	frame:ClearAllPoints()
	MultiCastFlyoutFrameCloseButton:ClearAllPoints()
	if E.db.general.totems.flyoutDirection == 'UP' then
		frame:Point('BOTTOM', parent, 'TOP')

		MultiCastFlyoutFrameCloseButton:Point('TOP', frame, 'TOP')
		MultiCastFlyoutFrameCloseButton.icon:SetRotation(3.14)
	elseif E.db.general.totems.flyoutDirection == 'DOWN' then
		frame:Point('TOP', parent, 'BOTTOM')

		MultiCastFlyoutFrameCloseButton:Point('BOTTOM', frame, 'BOTTOM')
		MultiCastFlyoutFrameCloseButton.icon:SetRotation(0)
	end

	frame:Height(((E.db.general.totems.buttonSize + E.db.general.totems.flyoutSpacing) * numButtons) + MultiCastFlyoutFrameCloseButton:GetHeight())
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

	local buttonSpacing = E.db.general.totems.spacing
	local size = E.db.general.totems.buttonSize
	local numActiveSlots = MultiCastActionBarFrame.numActiveSlots

	-- TODO: Wrath
	bar:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)))
	MultiCastActionBarFrame:Width((size * (2 + numActiveSlots)) + (buttonSpacing * (2 + numActiveSlots - 1)))
	bar:Height(size + 2)
	MultiCastActionBarFrame:Height(size + 2)

	bar.mouseover = E.db.general.totems.mouseover
	if bar.mouseover then
		bar:SetAlpha(0)
	else
		bar:SetAlpha(E.db.general.totems.alpha)
	end

	local visibility = E.db.general.totems.visibility
	if visibility and match(visibility, '[\n\r]') then
		visibility = gsub(visibility, '[\n\r]','')
	end

	RegisterStateDriver(bar, 'visibility', visibility)

	MultiCastSummonSpellButton:ClearAllPoints()
	MultiCastSummonSpellButton:Size(size)
	MultiCastSummonSpellButton:Point('BOTTOMLEFT', E.Border*2, E.Border*2) -- TODO: Wrath

	for i = 1, numActiveSlots do
		local button = _G['MultiCastSlotButton'..i]
		local lastButton = _G['MultiCastSlotButton'..i - 1]

		button:ClearAllPoints()
		button:Size(size)

		if i == 1 then
			button:Point('LEFT', MultiCastSummonSpellButton, 'RIGHT', buttonSpacing, 0)
		else
			button:Point('LEFT', lastButton, 'RIGHT', buttonSpacing, 0)
		end
	end

	MultiCastRecallSpellButton:Size(size)
	MultiCastRecallSpellButton_Update(MultiCastRecallSpellButton)

	MultiCastFlyoutFrameCloseButton:Width(size)
	MultiCastFlyoutFrameOpenButton:Width(size)
end

function AB:UpdateTotemBindings()
	MultiCastSummonSpellButtonHotKey:SetTextColor(1, 1, 1)
	MultiCastSummonSpellButtonHotKey:FontTemplate(LSM:Fetch('font', E.db.general.totems.font), E.db.general.totems.fontSize, E.db.general.totems.fontOutline)
	AB:FixKeybindText(MultiCastSummonSpellButton)

	MultiCastRecallSpellButtonHotKey:SetTextColor(1, 1, 1)
	MultiCastRecallSpellButtonHotKey:FontTemplate(LSM:Fetch('font', E.db.general.totems.font), E.db.general.totems.fontSize, E.db.general.totems.fontOutline)
	AB:FixKeybindText(MultiCastRecallSpellButton)

	for i = 1, 12 do
		local hotKey = _G['MultiCastActionButton'..i..'HotKey']

		hotKey:SetTextColor(1, 1, 1)
		hotKey:FontTemplate(LSM:Fetch('font', E.db.general.totems.font), E.db.general.totems.fontSize, E.db.general.totems.fontOutline)
		AB:FixKeybindText(_G['MultiCastActionButton'..i])
	end
end

function AB:CreateTotemBar()
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 250)
	bar.buttons = {}

	bar.eventFrame = CreateFrame('Frame')
	bar.eventFrame:Hide()
	bar.eventFrame:SetScript('OnEvent', function()
		AB:PositionAndSizeBarTotem()
		AB:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end)

	MultiCastActionBarFrame:SetParent(bar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint('BOTTOMLEFT', bar, 'BOTTOMLEFT', -E.Border, -E.Border)
	MultiCastActionBarFrame:SetScript('OnUpdate', nil)
	MultiCastActionBarFrame:SetScript('OnShow', nil)
	MultiCastActionBarFrame:SetScript('OnHide', nil)
	MultiCastActionBarFrame.SetParent = E.noop
	MultiCastActionBarFrame.SetPoint = E.noop

	AB:HookScript(MultiCastActionBarFrame, 'OnEnter', 'TotemOnEnter')
	AB:HookScript(MultiCastActionBarFrame, 'OnLeave', 'TotemOnLeave')

	AB:HookScript(MultiCastFlyoutFrame, 'OnEnter', 'TotemOnEnter')
	AB:HookScript(MultiCastFlyoutFrame, 'OnLeave', 'TotemOnLeave')

	local closeButton = MultiCastFlyoutFrameCloseButton
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

	local openButton = MultiCastFlyoutFrameOpenButton
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

	AB:SkinSummonButton(MultiCastSummonSpellButton)
	bar.buttons[MultiCastSummonSpellButton] = true

	hooksecurefunc(MultiCastRecallSpellButton, 'SetPoint', function(self, point, attachTo, anchorPoint, xOffset, yOffset)
		if xOffset ~= E.db.general.totems.spacing then
			if InCombatLockdown() then AB.NeedRecallButtonUpdate = true AB:RegisterEvent('PLAYER_REGEN_ENABLED') return end
			self:ClearAllPoints()
			self:SetPoint(point, attachTo, anchorPoint, E.db.general.totems.spacing, yOffset)
		end
	end)

	AB:SkinSummonButton(MultiCastRecallSpellButton)
	bar.buttons[MultiCastRecallSpellButton] = true

	-- TODO: Wrath (Check for a better skinning method)
	for i = 1, 4 do
		local button = _G['MultiCastSlotButton'..i]
		local overlay = _G['MultiCastSlotButton'..i]['overlayTex']

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
		local overlay = _G['MultiCastActionButton'..i]['overlayTex']

		button:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer('ARTWORK')
		icon:SetInside()

		normal:Hide()

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

	AB:SecureHook('MultiCastFlyoutFrameOpenButton_Show')
	AB:SecureHook('MultiCastActionButton_Update')
	AB:SecureHook('MultiCastSlotButton_Update', 'StyleTotemSlotButton')
	AB:SecureHook('MultiCastFlyoutFrame_ToggleFlyout')
	AB:SecureHook('ShowMultiCastActionBar')

	E:CreateMover(bar, 'TotemBarMover', L["Class Totems"], nil, nil, nil, nil, nil, 'general,totems')
end
