--[[
	Copyright (c) 2007-2012 Trond A Ekseth troeks@gmail.com

	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
]]

-- Code heavily modified by Elv, Simpy, and Blazeflack
-- Original code by Haste from https://github.com/haste/Butsu

local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local LCG = E.Libs.ButtonGlow

local _G = _G
local unpack = unpack
local tinsert = tinsert
local next = next
local max = max

local CloseLoot = CloseLoot
local CreateFrame = CreateFrame
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local GameTooltip = GameTooltip
local GetCursorPosition = GetCursorPosition
local GetCVarBool = GetCVarBool
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetNumLootItems = GetNumLootItems
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local LootSlotHasItem = LootSlotHasItem
local ResetCursor = ResetCursor
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local LootSlot = LootSlot

local StaticPopup_Hide = StaticPopup_Hide
local MasterLooterFrame_Show = MasterLooterFrame_Show
local MasterLooterFrame_UpdatePlayers = MasterLooterFrame_UpdatePlayers

local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local LOOT = LOOT

local iconSize, lootFrame, lootFrameHolder = 30

local coinTextureIDs = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true,
}

local function SlotEnter(slot)
	local id = slot:GetID()
	if LootSlotHasItem(id) then
		GameTooltip:SetOwner(slot, 'ANCHOR_RIGHT')
		GameTooltip:SetLootItem(id)
		CursorUpdate(slot)
	end

	slot.drop:Show()
	slot.drop:SetVertexColor(1, 1, 0)
end

local function SlotLeave(slot)
	if slot.quality and (slot.quality > 1) then
		local color = ITEM_QUALITY_COLORS[slot.quality]
		slot.drop:SetVertexColor(color.r, color.g, color.b)
	else
		slot.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local function SlotClick(slot)
	local frame = _G.LootFrame
	frame.selectedQuality = slot.quality
	frame.selectedItemName = slot.name:GetText()
	frame.selectedTexture = slot.icon:GetTexture()
	frame.selectedLootButton = slot:GetName()
	frame.selectedSlot = slot:GetID()

	if IsModifiedClick() then
		_G.HandleModifiedItemClick(GetLootSlotLink(frame.selectedSlot))
	else
		StaticPopup_Hide('CONFIRM_LOOT_DISTRIBUTION')
		LootSlot(frame.selectedSlot)
	end
end

local function SlotShow(slot)
	if GameTooltip:IsOwned(slot) then
		GameTooltip:SetOwner(slot, 'ANCHOR_RIGHT')
		GameTooltip:SetLootItem(slot:GetID())
		CursorOnUpdate(slot)
	end
end

local function FrameHide()
	StaticPopup_Hide('CONFIRM_LOOT_DISTRIBUTION')
	CloseLoot()

	if _G.MasterLooterFrame then
		_G.MasterLooterFrame:Hide()
	end
end

local function AnchorSlots(frame)
	local shownSlots = 0

	for _, slot in next, frame.slots do
		if slot:IsShown() then
			shownSlots = shownSlots + 1

			slot:Point('TOP', lootFrame, 4, (-8 + iconSize) - (shownSlots * iconSize))
		end
	end

	frame:Height(max(shownSlots * iconSize + 16, 20))
end

local function CreateSlot(id)
	local size = (iconSize - 2)

	local slot = CreateFrame('Button', 'ElvLootSlot'..id, lootFrame)
	slot:Point('LEFT', 8, 0)
	slot:Point('RIGHT', -8, 0)
	slot:Height(size)
	slot:SetID(id)

	slot:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

	slot:SetScript('OnEnter', SlotEnter)
	slot:SetScript('OnLeave', SlotLeave)
	slot:SetScript('OnClick', SlotClick)
	slot:SetScript('OnShow', SlotShow)

	local iconFrame = CreateFrame('Frame', nil, slot)
	iconFrame:Size(size)
	iconFrame:Point('RIGHT', slot)
	iconFrame:SetTemplate()
	slot.iconFrame = iconFrame
	E.frames[iconFrame] = nil

	local icon = iconFrame:CreateTexture(nil, 'ARTWORK')
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside()
	slot.icon = icon

	local count = iconFrame:CreateFontString(nil, 'OVERLAY')
	count:SetJustifyH'RIGHT'
	count:Point('BOTTOMRIGHT', iconFrame, -2, 2)
	count:FontTemplate(nil, nil, 'OUTLINE')
	count:SetText(1)
	slot.count = count

	local name = slot:CreateFontString(nil, 'OVERLAY')
	name:SetJustifyH('LEFT')
	name:Point('LEFT', slot)
	name:Point('RIGHT', icon, 'LEFT')
	name:SetNonSpaceWrap(true)
	name:FontTemplate(nil, nil, 'OUTLINE')
	slot.name = name

	local drop = slot:CreateTexture(nil, 'ARTWORK')
	drop:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
	drop:Point('LEFT', icon, 'RIGHT', 0, 0)
	drop:Point('RIGHT', slot)
	drop:SetAllPoints(slot)
	drop:SetAlpha(.3)
	slot.drop = drop

	local questTexture = iconFrame:CreateTexture(nil, 'OVERLAY')
	questTexture:SetInside()
	questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
	questTexture:SetTexCoord(unpack(E.TexCoords))
	slot.questTexture = questTexture

	lootFrame.slots[id] = slot
	return slot
end

function M:LOOT_SLOT_CLEARED(_, id)
	if not lootFrame:IsShown() then return end

	local slot = lootFrame.slots[id]
	if slot then
		slot:Hide()
	end

	AnchorSlots(lootFrame)
end

function M:LOOT_CLOSED()
	StaticPopup_Hide('LOOT_BIND')
	lootFrame:Hide()

	for _, slot in next, lootFrame.slots do
		slot:Hide()
	end
end

function M:LOOT_OPENED(_, autoloot)
	lootFrame:Show()

	if not lootFrame:IsShown() then
		CloseLoot(not autoloot)
	end

	if IsFishingLoot() then
		lootFrame.title:SetText(L["Fishy Loot"])
	elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
		lootFrame.title:SetText(UnitName('target'))
	else
		lootFrame.title:SetText(LOOT)
	end

	lootFrame:ClearAllPoints()

	-- Blizzard uses strings here
	if GetCVarBool('lootUnderMouse') then
		local scale = lootFrame:GetEffectiveScale()
		local x, y = GetCursorPosition()

		lootFrame:Point('TOPLEFT', _G.UIParent, 'BOTTOMLEFT', (x / scale) - 40, (y / scale) + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
		E:DisableMover('LootFrameMover')
	else
		lootFrame:Point('TOPLEFT', lootFrameHolder, 'TOPLEFT')
		E:EnableMover('LootFrameMover')
	end

	local max_quality, max_width = 0, 0
	local numItems = GetNumLootItems()
	if numItems > 0 then
		for i = 1, numItems do
			local slot = lootFrame.slots[i] or CreateSlot(i)
			local textureID, item, count, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality or 0]

			if coinTextureIDs[textureID] then
				item = item:gsub('\n', ', ')
			end

			if count and (count > 1) then
				slot.count:SetText(count)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if quality and (quality > 1) then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				slot.drop:Hide()
			end

			slot.quality = quality
			slot.name:SetText(item)
			slot.name:SetTextColor(color.r, color.g, color.b)
			slot.icon:SetTexture(textureID)

			max_width = max(max_width, slot.name:GetStringWidth())

			if quality then
				max_quality = max(max_quality, quality)
			end

			local questTexture = slot.questTexture
			if questId and not isActive then
				questTexture:Show()
				LCG.ShowOverlayGlow(slot.iconFrame)
			elseif questId or isQuestItem then
				questTexture:Hide()
				LCG.ShowOverlayGlow(slot.iconFrame)
			else
				questTexture:Hide()
				LCG.HideOverlayGlow(slot.iconFrame)
			end

			-- Check for FasterLooting scripts or w/e (if bag is full)
			if textureID then
				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = lootFrame.slots[1] or CreateSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L["No Loot"])
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture()

		max_width = max(max_width, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	AnchorSlots(lootFrame)

	local color = ITEM_QUALITY_COLORS[max_quality]
	lootFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	lootFrame:Width(max(max_width + 60, lootFrame.title:GetStringWidth()  + 5))
end

function M:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(_G.LootFrame.selectedLootButton)
end

function M:UPDATE_MASTER_LOOT_LIST()
	if _G.LootFrame.selectedLootButton then MasterLooterFrame_UpdatePlayers() end
end

function M:LoadLoot()
	if not E.private.general.loot then return end

	lootFrameHolder = CreateFrame('Frame', 'ElvLootFrameHolder', E.UIParent)
	lootFrameHolder:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 418, -186)
	lootFrameHolder:Size(150, 22)

	lootFrame = CreateFrame('Button', 'ElvLootFrame', lootFrameHolder)
	lootFrame:Hide()
	lootFrame:SetClampedToScreen(true)
	lootFrame:Point('TOPLEFT')
	lootFrame:Size(256, 64)
	lootFrame:SetTemplate('Transparent')
	lootFrame:SetFrameStrata(_G.LootFrame:GetFrameStrata())
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, 'OVERLAY')
	lootFrame.title:FontTemplate(nil, nil, 'OUTLINE')
	lootFrame.title:Point('BOTTOMLEFT', lootFrame, 'TOPLEFT', 0, 1)
	lootFrame.slots = {}
	lootFrame:SetScript('OnHide', FrameHide) -- mimic LootFrame_OnHide, mostly
	E.frames[lootFrame] = nil

	M:RegisterEvent('LOOT_OPENED')
	M:RegisterEvent('LOOT_SLOT_CLEARED')
	M:RegisterEvent('LOOT_CLOSED')
	M:RegisterEvent('OPEN_MASTER_LOOT_LIST')
	M:RegisterEvent('UPDATE_MASTER_LOOT_LIST')

	E:CreateMover(lootFrameHolder, 'LootFrameMover', L["Loot Frame"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements')

	_G.LootFrame:UnregisterAllEvents()
	tinsert(_G.UISpecialFrames, 'ElvLootFrame')

	-- fix blizzard setpoint connection bs
	hooksecurefunc(_G.MasterLooterFrame, 'Hide', _G.MasterLooterFrame.ClearAllPoints)
end
