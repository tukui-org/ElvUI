local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc')
local LSM = E.Libs.LSM

local _G = _G
local next = next
local pairs = pairs
local unpack = unpack
local UnitGUID = UnitGUID
local CreateFrame = CreateFrame

local InspectItems = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"",
	"ChestSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"WristSlot",
	"HandsSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"BackSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
}

function M:CreateInspectTexture(slot, x, y)
	local texture = slot:CreateTexture()
	texture:Point("BOTTOM", slot, x, y)
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:Size(14)

	local backdrop = CreateFrame('Frame', nil, slot)
	backdrop:SetTemplate(nil, nil, true)
	backdrop:SetBackdropColor(0,0,0,0)
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function M:GetInspectPoints(id)
	if not id then return end

	if id <= 5 or (id == 9 or id == 15) then
		return 40, 3, 18, "BOTTOMLEFT" -- Left side
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then
		return -40, 3, 18, "BOTTOMRIGHT" -- Right side
	else
		return 0, 45, 60, "BOTTOM"
	end
end

function M:UpdateInspectInfo(_, arg1)
	M:UpdatePageInfo(_G.InspectFrame, 'Inspect', arg1)
end

function M:UpdateCharacterInfo(event)
	if not E.db.general.itemLevel.displayCharacterInfo then return end

	M:UpdatePageInfo(_G.CharacterFrame, 'Character', nil, event)
end

function M:UpdateCharacterItemLevel()
	M:UpdateAverageString(_G.CharacterFrame, 'Character')
end

function M:ClearPageInfo(frame, which)
	if not (frame and frame.ItemLevelText) then return end
	frame.ItemLevelText:SetText('')

	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText('')
			inspectItem.iLvlText:SetText('')

			for y=1, 10 do
				inspectItem['textureSlot'..y]:SetTexture()
			end
		end
	end
end

function M:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		M:CreateSlotStrings(_G.CharacterFrame, 'Character')
	end

	if E.db.general.itemLevel.displayCharacterInfo then
		M:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateCharacterInfo')
		M:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE', 'UpdateCharacterItemLevel')
		_G.CharacterStatsPane.ItemLevelFrame.Value:Hide()

		if not _G.CharacterFrame.CharacterInfoHooked then
			_G.CharacterFrame:HookScript('OnShow', M.UpdateCharacterInfo)
			_G.CharacterFrame.CharacterInfoHooked = true
		end

		if not setupCharacterPage then
			M:UpdateCharacterInfo()
		end
	else
		M:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		M:UnregisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
		_G.CharacterStatsPane.ItemLevelFrame.Value:Show()
		M:ClearPageInfo(_G.CharacterFrame, 'Character')
	end

	if E.db.general.itemLevel.displayInspectInfo then
		M:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
	else
		M:UnregisterEvent('INSPECT_READY')
		M:ClearPageInfo(_G.InspectFrame, 'Inspect')
	end
end

function M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
	iLevelDB[i] = iLvl

	inspectItem.enchantText:SetText(enchant)
	if enchantColors then
		inspectItem.enchantText:SetTextColor(unpack(enchantColors))
	end

	inspectItem.iLvlText:SetText(iLvl)
	if itemLevelColors then
		inspectItem.iLvlText:SetTextColor(unpack(itemLevelColors))
	end

	for x = 1, 10 do
		local texture = inspectItem["textureSlot"..x]
		local backdrop = inspectItem["textureSlotBackdrop"..x]

		if gems and next(gems) then
			local index, gem = next(gems)
			texture:SetTexture(gem)
			backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			backdrop:Show()
			gems[index] = nil
		elseif essences and next(essences) then
			local index, essence = next(essences)

			local r, g, b
			if essence[2] == 'tooltip-heartofazerothessence-major' then
				r, g, b = 0.8, 0.7, 0
			else -- 'tooltip-heartofazerothessence-minor'
				r, g, b = 0.4, 0.4, 0.4
			end

			local selected = essence[1]
			texture:SetTexture(selected)
			backdrop:SetBackdropBorderColor(r, g, b)
			backdrop:Show()

			if selected then
				backdrop:SetBackdropColor(0,0,0,0)
			else
				backdrop:SetBackdropColor(unpack(E.media.backdropcolor))
			end

			essences[index] = nil
		else
			texture:SetTexture()
			backdrop:Hide()
		end
	end
end

function M:UpdateAverageString(frame, which, iLevelDB)
	local isCharPage = which == 'Character'
	local AvgItemLevel = (isCharPage and E:GetPlayerItemLevel()) or E:CalculateAverageItemLevel(iLevelDB, frame.unit)
	if AvgItemLevel then
		if isCharPage then
			frame.ItemLevelText:SetText(AvgItemLevel)
			frame.ItemLevelText:SetTextColor(_G.CharacterStatsPane.ItemLevelFrame.Value:GetTextColor())
		else
			frame.ItemLevelText:SetFormattedText(L["Item level: %.2f"], AvgItemLevel)
		end
	else
		frame.ItemLevelText:SetText('')
	end
end

function M:TryGearAgain(frame, which, i, deepScan, iLevelDB, inspectItem)
	E:Delay(0.05, function()
		if which == 'Inspect' and (not frame or not frame.unit) then return end

		local unit = (which == 'Character' and 'player') or frame.unit
		local iLvl, enchant, gems, essences, enchantColors, itemLevelColors = E:GetGearSlotInfo(unit, i, deepScan)
		if iLvl == 'tooSoon' then return end

		M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
	end)
end

function M:UpdatePageInfo(frame, which, guid, event)
	if not (which and frame and frame.ItemLevelText) then return end
	if which == 'Inspect' and (not frame or not frame.unit or (guid and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then return end

	local iLevelDB = {}
	local waitForItems
	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText('')
			inspectItem.iLvlText:SetText('')

			local unit = (which == 'Character' and 'player') or frame.unit
			local iLvl, enchant, gems, essences, enchantColors, itemLevelColors = E:GetGearSlotInfo(unit, i, true)
			if iLvl == 'tooSoon' then
				if not waitForItems then waitForItems = true end
				M:TryGearAgain(frame, which, i, true, iLevelDB, inspectItem)
			else
				M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
			end
		end
	end

	if event and event == 'PLAYER_EQUIPMENT_CHANGED' then
		return
	end

	if waitForItems then
		E:Delay(0.10, M.UpdateAverageString, M, frame, which, iLevelDB)
	else
		M:UpdateAverageString(frame, which, iLevelDB)
	end
end

function M:CreateSlotStrings(frame, which)
	if not (frame and which) then return end

	local itemLevelFont = E.db.general.itemLevel.itemLevelFont
	local itemLevelFontSize = E.db.general.itemLevel.itemLevelFontSize or 12
	local itemLevelFontOutline = E.db.general.itemLevel.itemLevelFontOutline or 'OUTLINE'

	if which == 'Inspect' then
		frame.ItemLevelText = _G.InspectPaperDollItemsFrame:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:Point("BOTTOMRIGHT", -6, 6)
	else
		frame.ItemLevelText = _G.CharacterStatsPane.ItemLevelFrame:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:Point("BOTTOM", _G.CharacterStatsPane.ItemLevelFrame.Value, "BOTTOM", 0, 0)
	end
	frame.ItemLevelText:FontTemplate(nil, which == 'Inspect' and 12 or 20)

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]
			local x, y, z, justify = M:GetInspectPoints(i)
			slot.iLvlText = slot:CreateFontString(nil, "OVERLAY")
			slot.iLvlText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
			slot.iLvlText:Point("BOTTOM", slot, x, y)

			slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
			slot.enchantText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)

			if i == 16 or i == 17 then
				slot.enchantText:Point(i==16 and "BOTTOMRIGHT" or "BOTTOMLEFT", slot, i==16 and -40 or 40, 3)
			else
				slot.enchantText:Point(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or -5), z)
			end

			for u=1, 10 do
				local offset = 8+(u*16)
				local newX = ((justify == "BOTTOMLEFT" or i == 17) and x+offset) or x-offset
				slot["textureSlot"..u], slot["textureSlotBackdrop"..u] = M:CreateInspectTexture(slot, newX, --[[newY or]] y)
			end
		end
	end
end

function M:SetupInspectPageInfo()
	M:CreateSlotStrings(_G.InspectFrame, 'Inspect')
end

function M:UpdateInspectPageFonts(which)
	local itemLevelFont = E.db.general.itemLevel.itemLevelFont
	local itemLevelFontSize = E.db.general.itemLevel.itemLevelFontSize or 12
	local itemLevelFontOutline = E.db.general.itemLevel.itemLevelFontOutline or 'OUTLINE'

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]
			if slot then
				slot.iLvlText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
				slot.enchantText:FontTemplate(LSM:Fetch("font", itemLevelFont), itemLevelFontSize, itemLevelFontOutline)
			end
		end
	end
end
