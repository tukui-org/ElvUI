local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Bags')
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local gsub = gsub
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetCVarBool = GetCVarBool
local RegisterStateDriver = RegisterStateDriver
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots

local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local commandNames = {
	[-1] = 'TOGGLEBACKPACK',
	[0] = 'TOGGLEBAG4',
	'TOGGLEBAG3',	-- 1
	'TOGGLEBAG2',	-- 2
	'TOGGLEBAG1'	-- 3
}

function B:BagBar_OnEnter()
	return E.db.bags.bagBar.mouseover and E:UIFrameFadeIn(B.BagBar, 0.2, B.BagBar:GetAlpha(), 1)
end

function B:BagBar_OnLeave()
	return E.db.bags.bagBar.mouseover and E:UIFrameFadeOut(B.BagBar, 0.2, B.BagBar:GetAlpha(), 0)
end

function B:BagButton_OnEnter()
	-- bag keybind support from actionbar module
	if E.private.actionbar.enable then
		AB:BindUpdate(self)
	end

	B:BagBar_OnEnter()
end

function B:BagButton_OnLeave()
	B:BagBar_OnLeave()
end

function B:KeyRing_OnEnter()
	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
		GameTooltip:AddLine(_G.KEYRING, 1, 1, 1)
		GameTooltip:Show()
	end

	B:BagBar_OnEnter()
end

function B:KeyRing_OnLeave()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end

	B:BagBar_OnEnter()
end

function B:SkinBag(bag)
	local icon = bag.icon or _G[bag:GetName()..'IconTexture']
	bag.oldTex = icon:GetTexture()

	bag:StripTextures(E.Retail)
	bag:SetTemplate()
	bag:StyleButton(true)

	if E.Retail then
		bag:GetNormalTexture():SetAlpha(0)
		bag:GetHighlightTexture():SetAlpha(0)
		bag.CircleMask:Hide()

		icon.Show = nil
		icon:Show()
	end

	icon:SetInside()
	icon:SetTexture((not bag.oldTex or bag.oldTex == 1721259) and E.Media.Textures.Backpack or bag.oldTex)
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not B.BagBar then return end

	local db = E.db.bags.bagBar
	local bagBarSize = db.size
	local buttonSpacing = db.spacing
	local growthDirection = db.growthDirection
	local sortDirection = db.sortDirection
	local showBackdrop = db.showBackdrop
	local justBackpack = db.justBackpack
	local backdropSpacing = not showBackdrop and 0 or db.backdropSpacing

	local visibility = gsub(db.visibility, '[\n\r]', '')
	RegisterStateDriver(B.BagBar, 'visibility', visibility)

	B.BagBar:SetAlpha(db.mouseover and 0 or 1)

	_G.MainMenuBarBackpackButtonCount:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

	local firstButton, lastButton
	for i, button in ipairs(B.BagBar.buttons) do
		if E.Retail then
			button.filterIcon.FilterBackdrop:Size(bagBarSize * 0.5)
		end

		button:Size(bagBarSize)
		button:ClearAllPoints()
		button:SetShown(i == 1 and justBackpack or not justBackpack)

		if sortDirection == 'ASCENDING'then
			if i == 1 then firstButton = button else lastButton = button end
		else
			if i == 1 then lastButton = button else firstButton = button end
		end

		local prevButton = B.BagBar.buttons[i-1]
		if growthDirection == 'HORIZONTAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', B.BagBar, 'LEFT', backdropSpacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', buttonSpacing, 0)
			end
		elseif growthDirection == 'VERTICAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', B.BagBar, 'TOP', 0, -backdropSpacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -buttonSpacing)
			end
		elseif growthDirection == 'HORIZONTAL' and sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', B.BagBar, 'RIGHT', -backdropSpacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', B.BagBar, 'BOTTOM', 0, backdropSpacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, buttonSpacing)
			end
		end

		B:GetBagAssignedInfo(button)
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = buttonSpacing * NUM_BAG_FRAMES
	local bdpDoubled = backdropSpacing * 2

	B.BagBar.backdrop:ClearAllPoints()
	B.BagBar.backdrop:Point('TOPLEFT', firstButton, 'TOPLEFT', -backdropSpacing, backdropSpacing)
	B.BagBar.backdrop:Point('BOTTOMRIGHT', justBackpack and firstButton or lastButton, 'BOTTOMRIGHT', backdropSpacing, -backdropSpacing)
	B.BagBar.backdrop:SetShown(showBackdrop)

	if growthDirection == 'HORIZONTAL' then
		B.BagBar:Size(btnSize + btnSpace + bdpDoubled, bagBarSize + bdpDoubled)
	else
		B.BagBar:Size(bagBarSize + bdpDoubled, btnSize + btnSpace + bdpDoubled)
	end

	B.BagBar.mover:SetSize(B.BagBar.backdrop:GetSize())
	B:UpdateMainButtonCount()
end

function B:UpdateMainButtonCount()
	local mainCount = B.BagBar.buttons[1].Count
	mainCount:SetShown(GetCVarBool('displayFreeBagSlots'))
	mainCount:SetText(CalculateTotalNumberOfFreeBagSlots())
end

function B:BagButton_OnClick(key)
	if E.Retail and key == 'RightButton' then
		B.AssignBagDropdown.holder = self
		_G.ToggleDropDownMenu(1, nil, B.AssignBagDropdown, 'cursor')
	end
end

function B:BagButton_UpdateTextures()
	local pushed = self:GetPushedTexture()
	pushed:SetInside()
	pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)

	if self.SlotHighlightTexture then
		self.SlotHighlightTexture:SetColorTexture(1, 1, 1, 0.3)
		self.SlotHighlightTexture:SetInside()
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	B.BagBar = CreateFrame('Frame', 'ElvUIBagBar', E.UIParent)
	B.BagBar:Point('TOPRIGHT', _G.RightChatPanel, 'TOPLEFT', -4, 0)
	B.BagBar:CreateBackdrop(E.db.bags.transparent and 'Transparent', nil, nil, nil, nil, nil, nil, true)
	B.BagBar:SetScript('OnEnter', B.BagBar_OnEnter)
	B.BagBar:SetScript('OnLeave', B.BagBar_OnLeave)
	B.BagBar:EnableMouse(true)
	B.BagBar.buttons = {}

	_G.MainMenuBarBackpackButton:SetParent(B.BagBar)
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(LSM:Fetch('font', E.db.bags.bagBar.font), E.db.bags.bagBar.fontSize, E.db.bags.bagBar.fontOutline)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:Point('BOTTOMRIGHT', _G.MainMenuBarBackpackButton, 'BOTTOMRIGHT', -1, 4)
	_G.MainMenuBarBackpackButton:HookScript('OnEnter', B.BagButton_OnEnter)
	_G.MainMenuBarBackpackButton:HookScript('OnLeave', B.BagButton_OnLeave)

	if not E.Retail then
		_G.MainMenuBarBackpackButton.commandName = commandNames[-1]
	end

	tinsert(B.BagBar.buttons, _G.MainMenuBarBackpackButton)
	B:SkinBag(_G.MainMenuBarBackpackButton)
	B.BagButton_UpdateTextures(_G.MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES-1 do
		local b = _G['CharacterBag'..i..'Slot']
		b:HookScript('OnEnter', B.BagButton_OnEnter)
		b:HookScript('OnLeave', B.BagButton_OnLeave)
		b:SetParent(B.BagBar)
		B:SkinBag(b)

		if E.Retail then
			hooksecurefunc(b, 'UpdateTextures', B.BagButton_UpdateTextures)
		else
			B.BagButton_UpdateTextures(b)

			b.commandName = commandNames[i]
		end

		tinsert(B.BagBar.buttons, b)
	end

	local ReagentSlot = _G.CharacterReagentBag0Slot
	if ReagentSlot then
		ReagentSlot:SetParent(B.BagBar)
		ReagentSlot:HookScript('OnEnter', B.BagButton_OnEnter)
		ReagentSlot:HookScript('OnLeave', B.BagButton_OnLeave)

		B:SkinBag(ReagentSlot)

		tinsert(B.BagBar.buttons, ReagentSlot)

		hooksecurefunc(ReagentSlot, 'UpdateTextures', B.BagButton_UpdateTextures)
		hooksecurefunc(ReagentSlot, 'SetBarExpanded', B.SizeAndPositionBagBar)
	end

	local KeyRing = _G.KeyRingButton
	if KeyRing then
		KeyRing:SetParent(B.BagBar)
		KeyRing:SetScript('OnEnter', B.KeyRing_OnEnter)
		KeyRing:SetScript('OnLeave', B.KeyRing_OnLeave)

		KeyRing:StripTextures()
		KeyRing:SetTemplate(nil, true)
		KeyRing:StyleButton(true)

		B:SetButtonTexture(KeyRing, [[Interface\ICONS\INV_Misc_Key_03]])

		tinsert(B.BagBar.buttons, KeyRing)
	end

	for i, button in ipairs(B.BagBar.buttons) do
		button.BagID = i - 1

		if E.Retail then -- Item Assignment
			B:CreateFilterIcon(button)
		end

		if button ~= KeyRing then
			button:HookScript('OnClick', B.BagButton_OnClick)
		end
	end

	E:CreateMover(B.BagBar, 'BagsMover', L["Bag Bar"], nil, nil, nil, nil, nil, 'bags,general')
	B.BagBar:SetPoint('BOTTOMLEFT', B.BagBar.mover)
	B:RegisterEvent('BAG_SLOT_FLAGS_UPDATED', 'SizeAndPositionBagBar')
	B:RegisterEvent('BAG_UPDATE_DELAYED', 'UpdateMainButtonCount')
	B:SizeAndPositionBagBar()
end
