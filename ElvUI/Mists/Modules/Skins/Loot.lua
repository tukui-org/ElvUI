local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LCG = E.Libs.CustomGlow

local _G = _G
local next = next

local GetLootSlotInfo = GetLootSlotInfo
local hooksecurefunc = hooksecurefunc
local IsFishingLoot = IsFishingLoot
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName

local GetItemQualityByID = C_Item.GetItemQualityByID

local C_LootHistory_GetNumItems = C_LootHistory.GetNumItems
local C_LootHistory_GetItem = C_LootHistory.GetItem
local LOOT, ITEMS = LOOT, ITEMS

local function UpdateLoots()
	local numItems = C_LootHistory_GetNumItems()
	for i=1, numItems do
		local frame = _G.LootHistoryFrame.itemFrames[i]
		if frame and not frame.IsSkinned then
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

function S:LootFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.loot) then return end

	-- Loot history frame
	local LootHistoryFrame = _G.LootHistoryFrame
	LootHistoryFrame:StripTextures()
	S:HandleCloseButton(LootHistoryFrame.CloseButton)
	LootHistoryFrame:StripTextures()
	LootHistoryFrame:SetTemplate('Transparent')
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
	MasterLooterFrame.Item.NameBorderMid:StripTextures()
	MasterLooterFrame.Item.NameBorderLeft:StripTextures()
	MasterLooterFrame.Item.NameBorderRight:StripTextures()

	hooksecurefunc('MasterLooterFrame_Show', function()
		local item = MasterLooterFrame.Item
		if item then
			local icon = item.Icon
			local texture = icon:GetTexture()

			if item.IconBorder then
				item.IconBorder:SetAlpha(0)
			end

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
	end)

	hooksecurefunc('MasterLooterFrame_UpdatePlayers', function()
		for _, child in next, { MasterLooterFrame:GetChildren() } do
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
	end)

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

	hooksecurefunc('LootFrame_UpdateButton', function(index)
		local numLootItems = LootFrame.numLootItems
		--Logic to determine how many items to show per page
		local numLootToShow = _G.LOOTFRAME_NUMBUTTONS
		if LootFrame.AutoLootTable then
			numLootItems = #LootFrame.AutoLootTable
		end
		if numLootItems > _G.LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1 -- Make space for the page buttons
		end

		local button = _G['LootButton'..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index
		if button and button:IsShown() then
			local texture, _, isQuestItem, questId, isActive
			if LootFrame.AutoLootTable then
				local entry = LootFrame.AutoLootTable[slot]
				if entry.hide then
					button:Hide()
					return
				else
					texture = entry.texture
					isQuestItem = entry.isQuestItem
					questId = entry.questId
					isActive = entry.isActive
				end
			else
				texture, _, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
			end

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
	end)

	LootFrame:HookScript('OnShow', function(frame)
		if IsFishingLoot() then
			frame.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
			frame.Title:SetText(UnitName('target'))
		else
			frame.Title:SetText(LOOT)
		end
	end)

	S:HandleNextPrevButton(_G.LootFrameDownButton)
	S:HandleNextPrevButton(_G.LootFrameUpButton)
end

S:AddCallback('LootFrame')
