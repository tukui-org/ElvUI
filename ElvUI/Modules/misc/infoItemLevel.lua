local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');

local _G = _G
local pairs = pairs
local unpack = unpack
local select = select
local GetAverageItemLevel = GetAverageItemLevel

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
	return texture
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

function M:UpdateInspectInfo()
	M:UpdatePageInfo(_G.InspectFrame, 'Inspect')
end

function M:UpdateCharacterInfo()
	if not E.db.general.displayCharacterInfo then return end

	M:UpdatePageInfo(_G.CharacterFrame, 'Character')
end

function M:ClearPageInfo(frame, which)
	if not (frame and frame.ItemLevelText) then return end
	frame.ItemLevelText:SetText('')

	for i=1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText()
			inspectItem.iLvlText:SetText()

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

	if E.db.general.displayCharacterInfo then
		M:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'UpdateCharacterInfo')

		if not _G.CharacterFrame.CharacterInfoHooked then
			_G.CharacterFrame:HookScript('OnShow', M.UpdateCharacterInfo)
			_G.CharacterFrame.CharacterInfoHooked = true
		end
	else
		M:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		M:ClearPageInfo(_G.CharacterFrame, 'Character')
	end

	if E.db.general.displayInspectInfo then
		M:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
	else
		M:UnregisterEvent('INSPECT_READY')
		M:ClearPageInfo(_G.InspectFrame, 'Inspect')
	end
end

function M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, textures, enchantColors, itemLevelColors)
	iLevelDB[i] = iLvl

	inspectItem.enchantText:SetText(enchant)
	if enchantColors then
		inspectItem.enchantText:SetTextColor(unpack(enchantColors))
	end

	inspectItem.iLvlText:SetText(iLvl)
	if itemLevelColors then
		inspectItem.iLvlText:SetTextColor(unpack(itemLevelColors))
	end

	for x=1, 10 do
		inspectItem["textureSlot"..x]:SetTexture(textures and textures[x])
	end
end

function M:UpdateAverageString(frame, which, iLevelDB)
	local AvgItemLevel = (which == 'Character' and E:Round((select(2, GetAverageItemLevel())), 2)) or E:CalculateAverageItemLevel(iLevelDB, frame.unit)
	if AvgItemLevel then
		frame.ItemLevelText:SetFormattedText(L["Item level: %.2f"], AvgItemLevel)
	else
		frame.ItemLevelText:SetText('')
	end
end

function M:TryGearAgain(unit, i, deepScan, iLevelDB, inspectItem)
	E:Delay(0.05, function()
		local iLvl, enchant, textures, enchantColors, itemLevelColors = E:GetGearSlotInfo(unit, i, deepScan)
		M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, textures, enchantColors, itemLevelColors)
	end)
end

function M:UpdatePageInfo(frame, which)
	if not (which and frame and frame.ItemLevelText) then return end
	if frame == _G.InspectFrame and (frame:IsShown() or not frame.unit) then return end

	local iLevelDB = {}
	local waitForItems
	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText()
			inspectItem.iLvlText:SetText()

			local unit = frame.unit or 'player'
			local iLvl, enchant, textures, enchantColors, itemLevelColors = E:GetGearSlotInfo(unit, i, true)
			if iLvl == 'tooSoon' then
				if not waitForItems then waitForItems = true end
				M:TryGearAgain(unit, i, true, iLevelDB, inspectItem)
			else
				M:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, textures, enchantColors, itemLevelColors)
			end
		end
	end

	if waitForItems then
		E:Delay(0.10, function() M:UpdateAverageString(frame, which, iLevelDB) end)
	else
		M:UpdateAverageString(frame, which, iLevelDB)
	end
end

function M:CreateSlotStrings(frame, which)
	if not (frame and which) then return end

	frame.ItemLevelText = frame:CreateFontString(nil, "ARTWORK")
	frame.ItemLevelText:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
	frame.ItemLevelText:FontTemplate(nil, 12)

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]
			local x, y, z, justify = M:GetInspectPoints(i)
			slot.iLvlText = slot:CreateFontString(nil, "OVERLAY")
			slot.iLvlText:FontTemplate(nil, 12)
			slot.iLvlText:Point("BOTTOM", slot, x, y)

			slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
			slot.enchantText:FontTemplate(nil, 11)

			if i == 16 or i == 17 then
				slot.enchantText:Point(i==16 and "BOTTOMRIGHT" or "BOTTOMLEFT", slot, i==16 and -40 or 40, 3)
			else
				slot.enchantText:Point(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or -5), z)
			end

			for u=1, 10 do
				local offset = 8+(u*16)
				local newX = ((justify == "BOTTOMLEFT" or i == 17) and x+offset) or x-offset
				slot["textureSlot"..u] = M:CreateInspectTexture(slot, newX, --[[newY or]] y)
			end
		end
	end
end

function M:SetupInspectPageInfo()
	M:CreateSlotStrings(_G.InspectFrame, 'Inspect')
end
