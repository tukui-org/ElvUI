local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');

local _G = _G
local unpack = unpack
local pairs = pairs

local IsAddOnLoaded = IsAddOnLoaded

local InspectItems = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"",
	"InspectChestSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectBackSlot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
}

function M:CreateInspectTexture(slot, x, y)
	local texture = _G[slot]:CreateTexture()
	texture:Point("BOTTOM", _G[slot], x, y)
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

function M:ToggleInspectInfo()
	if E.db.general.displayInspectInfo then
		M:RegisterEvent('INSPECT_READY', 'UpdateInspectInfo')
	else
		M:UnregisterEvent('INSPECT_READY')

		if not (_G.InspectFrame and _G.InspectFrame.ItemLevelText) then return end
		_G.InspectFrame.ItemLevelText:SetText('')

		for i=1, 17 do
			if i ~= 4 then
				local inspectItem = _G[InspectItems[i]]
				inspectItem.enchantText:SetText()
				inspectItem.iLvlText:SetText()

				for y=1, 10 do
					inspectItem['textureSlot'..y]:SetTexture()
				end
			end
		end
	end
end

function M:UpdateInspectInfo()
	if not (_G.InspectFrame and _G.InspectFrame.ItemLevelText) then return end
	local unit = _G.InspectFrame.unit or "target"
	local iLevelDB = {}

	local iLvl, enchant, textures, enchantColors, itemLevelColors

	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[InspectItems[i]]
			inspectItem.enchantText:SetText()
			inspectItem.iLvlText:SetText()

			iLvl, enchant, textures, enchantColors, itemLevelColors = E:GetGearSlotInfo(unit, i, true)

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
				inspectItem["textureSlot"..x]:SetTexture(textures[x])
			end
		end
	end

	local inspectOK, iLevel = E:CalculateAverageItemLevel(iLevelDB, _G.InspectFrame.unit or "target")
	if inspectOK then
		_G.InspectFrame.ItemLevelText:SetFormattedText(L["Item level: %.2f"], iLevel)
	else
		_G.InspectFrame.ItemLevelText:SetText('')
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_InspectUI" then
		_G.InspectFrame.ItemLevelText = _G.InspectFrame:CreateFontString(nil, "ARTWORK")
		_G.InspectFrame.ItemLevelText:Point("BOTTOMRIGHT", _G.InspectFrame, "BOTTOMRIGHT", -6, 6)
		_G.InspectFrame.ItemLevelText:FontTemplate(nil, 12)

		for i, slot in pairs(InspectItems) do
			if i ~= 4 then
				local x, y, z, justify = M:GetInspectPoints(i)
				_G[slot].iLvlText = _G[slot]:CreateFontString(nil, "OVERLAY")
				_G[slot].iLvlText:FontTemplate(nil, 12)
				_G[slot].iLvlText:Point("BOTTOM", _G[slot], x, y)

				_G[slot].enchantText = _G[slot]:CreateFontString(nil, "OVERLAY")
				_G[slot].enchantText:FontTemplate(nil, 11)

				if i == 16 or i == 17 then
					_G[slot].enchantText:Point(i==16 and "BOTTOMRIGHT" or "BOTTOMLEFT", _G[slot], i==16 and -40 or 40, 3)
				else
					_G[slot].enchantText:Point(justify, _G[slot], x + (justify == "BOTTOMLEFT" and 5 or -5), z)
				end

				for u=1, 10 do
					local offset = 8+(u*16)
					local newX = ((justify == "BOTTOMLEFT" or i == 17) and x+offset) or x-offset
					_G[slot]["textureSlot"..u] = M:CreateInspectTexture(slot, newX, --[[newY or]] y)
				end
			end
		end

		self:UnregisterEvent("ADDON_LOADED")
	end
end

function M:LoadInspectInfo()
	if IsAddOnLoaded("Blizzard_InspectUI") then
		self:ADDON_LOADED(nil, "Blizzard_InspectUI")
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end
