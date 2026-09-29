local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LCG = E.Libs.CustomGlow

local _G = _G
local strfind = strfind
local next, unpack = next, unpack

local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetLootSlotInfo = GetLootSlotInfo
local IsFishingLoot = IsFishingLoot
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName

local GetItemQualityByID = C_Item.GetItemQualityByID
local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems
local C_LootHistory_GetItem = C_LootHistory.GetItem

local LOOT, ITEMS = LOOT, ITEMS

local fullFillWidth = 234 -- picked by Blizzard in LootHistory.lua
local fullDropWidth = fullFillWidth + 30 -- some padding to let it match (via the skinning)

local data = S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'LootFrame')
data.toggle = 'loot'

local function LootHistoryElements(button) -- headers and padding rows share the scroll box
	local item = button.Item
	if not item then return end

	local atlas = item.IconOverlay:GetAtlas() -- SetItemButtonOverlay puts a wooden frame on housing items
	item.IconOverlay:SetAlpha((atlas and strfind(atlas, 'housing-item-wood-frame', 1, true)) and 0 or 1)

	if button.IsSkinned then return end

	button.BackgroundArtFrame:StripTextures()
	button.BackgroundArtFrame:CreateBackdrop('Transparent')

	item:StripTextures()
	S:HandleIcon(item.icon, true)
	S:HandleIconBorder(item.IconBorder, item.icon.backdrop)

	button.IsSkinned = true
end

local function HandleScrollElements(frame)
	frame:ForEachFrame(LootHistoryElements)
end

local function LootFrameUpdateChild(button)
	local item = button.Item
	if item then
		local icon = item.icon
		if not icon.backdrop then
			item:StyleButton()
			icon:SetInside(item)

			S:HandleIcon(icon, true)
		end

		item.NormalTexture:SetAlpha(0)
		item.IconBorder:SetAlpha(0)

		-- icon border isn't updated for white/grey so pull color from the name
		local r, g, b = button.Text:GetVertexColor()
		icon.backdrop:SetBackdropBorderColor(r, g, b)
	end

	if button.NameFrame and not button.NameFrame.backdrop then
		button.NameFrame:StripTextures()
		button.NameFrame:CreateBackdrop('Transparent')
		button.NameFrame.backdrop:SetAllPoints()
		button.NameFrame.backdrop:SetFrameLevel(2)
	end

	if button.IconQuestTexture then button.IconQuestTexture:SetAlpha(0) end
	if button.BorderFrame then button.BorderFrame:SetAlpha(0) end
	if button.HighlightNameFrame then button.HighlightNameFrame:SetAlpha(0) end
	if button.PushedNameFrame then button.PushedNameFrame:SetAlpha(0) end

end

local function LootFrameUpdate(frame)
	frame:ForEachFrame(LootFrameUpdateChild)
end

local function MasterLooterShow()
	local looter = _G.MasterLooterFrame
	local item = looter.Item
	local icon = item.Icon
	local r, g, b = E:GetItemQualityColor(_G.LootFrame.selectedQuality or 1)

	local texture = icon:GetTexture() -- keep before strip textures
	item:StripTextures()
	item:SetTemplate()
	item:SetBackdropBorderColor(r, g, b)

	icon:SetTexture(texture)
	icon:SetTexCoords()

	for _, child in next, { looter:GetChildren() } do
		if not child.IsSkinned and not child:GetName() and child:IsObjectType('Button') then
			if child:GetPushedTexture() then
				S:HandleCloseButton(child)
			else
				child:SetTemplate()
				child:StyleButton()
			end

			child.IsSkinned = true
		end
	end
end

local function StartBonusRoll()
	local frame = _G.BonusRollFrame

	-- keep the status bar a frame above but its increased 1 extra beacuse mera has a grid layer
	frame.PromptFrame.Timer:OffsetFrameLevel(2, frame)
	frame.BlackBackgroundHoist.backdrop:OffsetFrameLevel(1, frame)

	-- set currency icons position at bottom right (or left of the spec icon, on the bottom right)
	frame.CurrentCountFrame:ClearAllPoints()

	local bonusSpecIcon = frame.SpecIcon
	bonusSpecIcon.backdrop:SetShown(bonusSpecIcon:IsShown() and bonusSpecIcon:GetTexture() ~= nil)

	if bonusSpecIcon.backdrop:IsShown() then
		frame.CurrentCountFrame:Point('RIGHT', bonusSpecIcon.backdrop, 'LEFT', -2, -2)
	else
		frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
	end

	-- skin currency icons
	local ccf, pfifc = frame.CurrentCountFrame.Text, frame.PromptFrame.InfoFrame.Cost
	local text1, text2 = ccf:GetText(), pfifc:GetText()
	if text1 and strfind(text1, '|t') then ccf:SetText(text1:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
	if text2 and strfind(text2, '|t') then pfifc:SetText(text2:gsub('|T(.-):.-|t', '|T%1:16:16:0:0:64:64:5:59:5:59|t')) end
end

local function SpecIconHide(bonusSpecIcon)
	if bonusSpecIcon.backdrop:IsShown() then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('BOTTOMRIGHT', frame, -2, 1)
		bonusSpecIcon.backdrop:Hide()
	end
end

local function SpecIconShow(bonusSpecIcon)
	if not bonusSpecIcon.backdrop:IsShown() and bonusSpecIcon:GetTexture() ~= nil then
		local frame = _G.BonusRollFrame
		frame.CurrentCountFrame:ClearAllPoints()
		frame.CurrentCountFrame:Point('RIGHT', frame.SpecIcon.backdrop, 'LEFT', -2, -2)
		bonusSpecIcon.backdrop:Show()
	end
end

local function EncounterDropdownWidth(dropdown, width)
	if width ~= fullDropWidth then
		dropdown:SetWidth(fullDropWidth)
	end
end

local function UpdateLoots()
	local numItems = C_LootHistory_GetNumItems()
	for i = 1, numItems do
		local frame = _G.LootHistoryFrame.itemFrames[i]
		if not frame.IsSkinned then
			local Icon = frame.Icon:GetTexture()
			frame:StripTextures()
			frame.Icon:SetTexture(Icon)
			frame.Icon:SetTexCoords()

			-- Create a backdrop around the icon
			frame:CreateBackdrop()
			frame.backdrop:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.backdrop)

			local _, itemLink = C_LootHistory_GetItem(frame.itemIdx)
			local itemRarity = itemLink and GetItemQualityByID(itemLink)
			if itemRarity then
				local r, g, b = E:GetItemQualityColor(itemRarity)
				frame.backdrop:SetBackdropBorderColor(r, g, b)
			end

			frame.IsSkinned = true
		end
	end
end

local function ClassicMasterLooterShow()
	local item = _G.MasterLooterFrame.Item
	local icon = item.Icon
	local texture = icon:GetTexture()

	item.IconBorder:SetAlpha(0)
	item:StripTextures()
	icon:SetTexture(texture)
	icon:SetTexCoords()

	if not item.backdrop then
		item:CreateBackdrop()
		item.backdrop:SetOutside(icon)
	end

	local r, g, b = E:GetItemQualityColor(_G.LootFrame.selectedQuality)
	item.backdrop:SetBackdropBorderColor(r, g, b)
end

local function MasterLooterUpdatePlayers()
	for _, child in next, { _G.MasterLooterFrame:GetChildren() } do
		if not child.IsSkinned and child:IsObjectType('Button') then -- player buttons are created on demand
			child:SetTemplate()
			child:StyleButton()

			child.IsSkinned = true
		end
	end
end

local function LootUpdateButton(index)
	local LootFrame = _G.LootFrame
	local numLootItems = LootFrame.numLootItems
	--Logic to determine how many items to show per page
	local numLootToShow = _G.LOOTFRAME_NUMBUTTONS
	if numLootItems > _G.LOOTFRAME_NUMBUTTONS then
		numLootToShow = numLootToShow - 1 -- Make space for the page buttons
	end

	local button = _G['LootButton'..index]
	local slot = (numLootToShow * (LootFrame.page - 1)) + index
	if button:IsShown() then
		local texture, _, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)

		if texture then
			if questId and not isActive then
				LCG.ShowOverlayGlow(button)
			elseif questId or isQuestItem then
				LCG.ShowOverlayGlow(button)
			else
				LCG.HideOverlayGlow(button)
			end
		end
	end
end

local function LootFrameOnShow(frame)
	if IsFishingLoot() then
		frame.Title:SetText(L["Fishy Loot"])
	elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
		frame.Title:SetText(UnitName('target'))
	else
		frame.Title:SetText(LOOT)
	end
end

function S:LootFrame()
	if E.Modern then
		local LootFrame = _G.LootFrame
		LootFrame:StripTextures()
		LootFrame:SetTemplate('Transparent')
		LootFrame.Bg:SetAlpha(0)
		S:HandleCloseButton(LootFrame.ClosePanelButton)
		hooksecurefunc(LootFrame.ScrollBox, 'Update', LootFrameUpdate)

		local HistoryFrame = _G.GroupLootHistoryFrame
		HistoryFrame:StripTextures()
		HistoryFrame:SetTemplate('Transparent')
		HistoryFrame.Bg:SetAlpha(0)

		local Dropdown = HistoryFrame.EncounterDropdown
		S:HandleDropDownBox(Dropdown)
		hooksecurefunc(Dropdown, 'SetWidth', EncounterDropdownWidth)
		Dropdown:ClearAllPoints()
		Dropdown:Point('TOP', -6, -32)

		local Timer = HistoryFrame.Timer
		Timer:StripTextures()
		Timer:CreateBackdrop('Transparent')
		Timer:SetWidth(fullFillWidth) -- dont use Width
		Timer:ClearAllPoints()
		Timer:Point('TOP', Dropdown, 'BOTTOM', 6, 2)

		Timer.Fill:SetTexture(E.media.normTex)
		Timer.Fill:SetVertexColor(unpack(E.media.rgbvaluecolor))
		Timer.Fill:ClearAllPoints()
		Timer.Fill:Point('LEFT', Timer.backdrop, 1, 0)

		S:HandleCloseButton(HistoryFrame.ClosePanelButton)
		S:HandleTrimScrollBar(HistoryFrame.ScrollBar)
		hooksecurefunc(HistoryFrame.ScrollBox, 'Update', HandleScrollElements)

		local LootResize = HistoryFrame.ResizeButton
		LootResize:StripTextures()
		LootResize:SetTemplate()
		LootResize:ClearAllPoints()
		LootResize:Point('TOP', HistoryFrame, 'BOTTOM', 0, -2)
		LootResize:Size(HistoryFrame:GetWidth(), 19)

		LootResize.text = LootResize:CreateFontString(nil, 'OVERLAY')
		LootResize.text:FontTemplate(nil, 16, 'OUTLINE')
		LootResize.text:SetJustifyH('CENTER')
		LootResize.text:Point('CENTER', LootResize)
		LootResize.text:SetText('v v v v')

		local MasterLooterFrame = _G.MasterLooterFrame
		MasterLooterFrame:StripTextures()
		MasterLooterFrame:SetTemplate()
		hooksecurefunc('MasterLooterFrame_Show', MasterLooterShow)
	else
		-- Loot history frame
		local LootHistoryFrame = _G.LootHistoryFrame
		LootHistoryFrame:StripTextures()
		LootHistoryFrame:SetTemplate('Transparent')
		S:HandleCloseButton(LootHistoryFrame.CloseButton)
		LootHistoryFrame.ResizeButton:StripTextures()
		LootHistoryFrame.ResizeButton.text = LootHistoryFrame.ResizeButton:CreateFontString(nil, 'OVERLAY')
		LootHistoryFrame.ResizeButton.text:FontTemplate(nil, 16, 'OUTLINE')
		LootHistoryFrame.ResizeButton.text:SetJustifyH('CENTER')
		LootHistoryFrame.ResizeButton.text:Point('CENTER', LootHistoryFrame.ResizeButton)
		LootHistoryFrame.ResizeButton.text:SetText('v v v v')
		LootHistoryFrame.ResizeButton:SetTemplate()
		LootHistoryFrame.ResizeButton:Width(LootHistoryFrame:GetWidth())
		LootHistoryFrame.ResizeButton:Height(19)
		LootHistoryFrame.ResizeButton:ClearAllPoints()
		LootHistoryFrame.ResizeButton:Point('TOP', LootHistoryFrame, 'BOTTOM', 0, -2)
		_G.LootHistoryFrameScrollFrame:StripTextures()
		S:HandleScrollBar(_G.LootHistoryFrameScrollFrameScrollBar)

		hooksecurefunc('LootHistoryFrame_FullUpdate', UpdateLoots)

		-- Master Looter Frame
		local MasterLooterFrame = _G.MasterLooterFrame
		MasterLooterFrame.NineSlice:SetTemplate('Transparent')

		local item = MasterLooterFrame.Item
		item.NameBorderMid:StripTextures()
		item.NameBorderLeft:StripTextures()
		item.NameBorderRight:StripTextures()

		local _, _, _, closeFrameButton = MasterLooterFrame:GetChildren() -- NineSlice, Item, player1, unnamed UIPanelCloseButton; the other player buttons are created on demand
		S:HandleCloseButton(closeFrameButton)

		hooksecurefunc('MasterLooterFrame_Show', ClassicMasterLooterShow)
		hooksecurefunc('MasterLooterFrame_UpdatePlayers', MasterLooterUpdatePlayers)

		local LootFrame = _G.LootFrame
		S:HandleFrame(LootFrame, true)
		LootFrame:Height(LootFrame:GetHeight() - 30)
		_G.LootFramePortraitOverlay:SetParent(E.HiddenFrame)

		for _, region in next, { LootFrame:GetRegions() } do
			if region:IsObjectType('FontString') and region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end

		LootFrame.Title:ClearAllPoints()
		LootFrame.Title:Point('TOPLEFT', LootFrame, 'TOPLEFT', 4, -4)
		LootFrame.Title:SetJustifyH('LEFT')

		for i = 1, _G.LOOTFRAME_NUMBUTTONS do
			local button = _G['LootButton'..i]
			_G['LootButton'..i..'NameFrame']:Hide()

			S:HandleItemButton(button, true)
			S:HandleIconBorder(button.IconBorder, button.backdrop)

			button:NudgePoint(nil, 30, nil, nil, true)
		end

		hooksecurefunc('LootFrame_UpdateButton', LootUpdateButton)
		LootFrame:HookScript('OnShow', LootFrameOnShow)

		S:HandleNextPrevButton(_G.LootFrameDownButton)
		S:HandleNextPrevButton(_G.LootFrameUpButton)
	end

	local BonusRollFrame = _G.BonusRollFrame
	BonusRollFrame:StripTextures()
	BonusRollFrame:SetTemplate('Transparent')
	BonusRollFrame.SpecRing:SetTexture()
	BonusRollFrame.CurrentCountFrame.Text:FontTemplate()
	hooksecurefunc('BonusRollFrame_StartBonusRoll', StartBonusRoll)

	local BonusPrompt = BonusRollFrame.PromptFrame
	BonusPrompt.IconBackdrop = CreateFrame('Frame', nil, BonusPrompt)
	BonusPrompt.IconBackdrop:OffsetFrameLevel(-1)
	BonusPrompt.IconBackdrop:SetOutside(BonusPrompt.Icon)
	BonusPrompt.IconBackdrop:SetTemplate()
	BonusPrompt.Icon:SetTexCoords()

	BonusPrompt.Timer:SetStatusBarTexture(E.media.normTex)
	BonusPrompt.Timer:SetStatusBarColor(unpack(E.media.rgbvaluecolor))

	local BonusHoist = BonusRollFrame.BlackBackgroundHoist
	BonusHoist.Background:Hide()
	BonusHoist.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
	BonusHoist.backdrop:SetTemplate()
	BonusHoist.backdrop:SetOutside(BonusPrompt.Timer)

	local BonusSpecIcon = BonusRollFrame.SpecIcon
	BonusSpecIcon.backdrop = CreateFrame('Frame', nil, BonusRollFrame)
	BonusSpecIcon.backdrop:SetTemplate()
	BonusSpecIcon.backdrop:Point('BOTTOMRIGHT', BonusRollFrame, -2, 2)
	BonusSpecIcon.backdrop:Size(BonusSpecIcon:GetSize())
	BonusSpecIcon.backdrop:SetFrameLevel(6)

	BonusSpecIcon:SetParent(BonusSpecIcon.backdrop)
	BonusSpecIcon:SetTexCoords()
	BonusSpecIcon:SetInside()

	hooksecurefunc(BonusSpecIcon, 'Hide', SpecIconHide)
	hooksecurefunc(BonusSpecIcon, 'Show', SpecIconShow)
end
