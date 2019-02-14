local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local select, tonumber = select, tonumber
local next, max, wipe = next, max, wipe

local _G = _G
local UnitIsUnit = UnitIsUnit
local GetCVarBool = GetCVarBool
local GetItemInfo = GetItemInfo
local GetAverageItemLevel = GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInspectSpecialization = GetInspectSpecialization

local MATCH_ITEM_LEVEL = _G.ITEM_LEVEL:gsub('%%d', '(%%d+)')
local MATCH_ENCHANT = _G.ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')
local X2_INVTYPES, X2_EXCEPTIONS, ARMOR_SLOTS = {
	INVTYPE_2HWEAPON = true,
	INVTYPE_RANGEDRIGHT = true,
	INVTYPE_RANGED = true,
}, {
	[2] = 19, -- wands, use INVTYPE_RANGEDRIGHT, but are 1H
}, {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

function E:GetGearSlotInfo(unit, slot, deepScan)
	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetInventoryItem(unit, slot)
	E.ScanTooltip:Show()

	local iLvl, enchantText, enchantColors, itemLevelColors
	local textures

	if deepScan then
		for i = 1, 10 do
			local tex = _G["ElvUI_ScanTooltipTexture"..i]
			local hasTexture = tex and tex:GetTexture()
			if hasTexture then
				if not textures then textures = {} end
				textures[i] = hasTexture
				tex:SetTexture()
			end
		end
		for x = 1, E.ScanTooltip:NumLines() do
			local line = _G["ElvUI_ScanTooltipTextLeft"..x]
			if line then
				local lineText = line:GetText()
				local lr, lg, lb = line:GetTextColor()
				local tr, tg, tb = _G.ElvUI_ScanTooltipTextLeft1:GetTextColor()
				local itemLevel = lineText and lineText:match(MATCH_ITEM_LEVEL)
				local enchant = lineText:match(MATCH_ENCHANT)
				if enchant then
					enchantText = enchant:sub(1, 18)
					enchantColors = {lr, lg, lb}
				end
				if itemLevel then
					iLvl = tonumber(itemLevel)
					itemLevelColors = {tr, tg, tb}
				end
			end
		end
	else
		local colorblind = GetCVarBool('colorblindmode') and 4 or 3
		for x = 2, colorblind do
			local line = _G["ElvUI_ScanTooltipTextLeft"..x]
			if line then
				local lineText = line:GetText()
				local itemLevel = lineText and lineText:match(MATCH_ITEM_LEVEL)
				if itemLevel then
					iLvl = tonumber(itemLevel)
				end
			end
		end
	end

	E.ScanTooltip:Hide()

	return iLvl, enchantText, deepScan and textures, enchantColors, itemLevelColors
end

--Credit ls & Acidweb
function E:CalculateAverageItemLevel(iLevelDB, unit)
	local spec = GetInspectSpecialization(unit)
	local isOK, total, link = true, 0

	if not spec or spec == 0 then
		isOK = false
	end

	-- Armour
	for _, id in next, ARMOR_SLOTS do
		link = GetInventoryItemLink(unit, id)
		if link then
			local cur = iLevelDB[id]
			if cur and cur > 0 then
				total = total + cur
			end
		elseif GetInventoryItemTexture(unit, id) then
			isOK = false
		end
	end

	-- Main hand
	local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass, _ = 0
	link = GetInventoryItemLink(unit, 16)
	if link then
		mainItemLevel = iLevelDB[16]
		_, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 16) then
		isOK = false
	end

	-- Off hand
	local offItemLevel, offEquipLoc = 0
	link = GetInventoryItemLink(unit, 17)
	if link then
		offItemLevel = iLevelDB[17]
		_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 17) then
		isOK = false
	end

	if mainItemLevel and offItemLevel then
		if (mainQuality == 6) or (not offEquipLoc and X2_INVTYPES[mainEquipLoc] and X2_EXCEPTIONS[mainItemClass] ~= mainItemSubClass and spec ~= 72) then
			mainItemLevel = max(mainItemLevel, offItemLevel)
			total = total + mainItemLevel * 2
		else
			total = total + mainItemLevel + offItemLevel
		end
	end

	return isOK and total / 16
end

local iLevelDB = {}
function E:GetUnitItemLevel(unit)
	if UnitIsUnit("player", unit) then
		return select(2, GetAverageItemLevel()), nil
	end

	wipe(iLevelDB)
	for i = 1, 17 do
		if i ~= 4 then
			iLevelDB[i] = E:GetGearSlotInfo(unit, i)
		end
	end

	return E:CalculateAverageItemLevel(iLevelDB, unit)
end
