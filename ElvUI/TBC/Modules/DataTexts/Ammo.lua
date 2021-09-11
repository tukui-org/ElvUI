local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
if E.myclass ~= 'HUNTER' and E.myclass ~= 'ROGUE' and E.myclass ~= 'WARLOCK' and E.myclass ~= 'WARRIOR' then return end

local DT = E:GetModule('DataTexts')

local _G = _G
local select, wipe = select, wipe
local format, strjoin = format, strjoin

local GetItemInfo = GetItemInfo
local GetItemInfoInstant = GetItemInfoInstant
local GetItemCount = GetItemCount
local GetContainerItemID = GetContainerItemID
local GetInventoryItemCount = GetInventoryItemCount
local GetInventoryItemID = GetInventoryItemID
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemQualityColor = GetItemQualityColor
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local INVTYPE_AMMO = INVTYPE_AMMO
local INVSLOT_RANGED = INVSLOT_RANGED
local INVSLOT_AMMO = INVSLOT_AMMO
local LE_ITEM_CLASS_QUIVER = LE_ITEM_CLASS_QUIVER
local LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_CONTAINER

local iconString = '|T%s:16:16:0:0:64:64:4:55:4:55|t'
local displayString = ''

local lastPanel
local itemName = {}

local waitingItemID
local function OnEvent(self, event, ...)
	local name, count, itemID, itemEquipLoc

	if event == 'GET_ITEM_INFO_RECEIVED' then
		itemID = ...

		if itemID ~= waitingItemID then return end
		waitingItemID = nil

		if not itemName[itemID] then
			itemName[itemID] = GetItemInfo(itemID)
		end

		self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
	end

	if E.myclass == 'WARLOCK' then
		name, count = itemName[6265] or GetItemInfo(6265), GetItemCount(6265)

		if name and not itemName[6265] then
			itemName[6265] = name
		end

		self.text:SetFormattedText(displayString, name or 'Soul Shard', count or 0) -- Does not need localized. It gets updated.
	else
		local RangeItemID = GetInventoryItemID('player', INVSLOT_RANGED)
		if RangeItemID then
			itemEquipLoc = select(4, GetItemInfoInstant(RangeItemID))
		end

		if itemEquipLoc == 'INVTYPE_THROWN' then
			itemID, count = RangeItemID, GetInventoryItemCount('player', INVSLOT_RANGED)
		else
			itemID, count = GetInventoryItemID('player', INVSLOT_AMMO), GetInventoryItemCount('player', INVSLOT_AMMO)
		end

		if (itemID and itemID > 0) and (count > 0) then
			if itemID then
				name = itemName[itemID] or GetItemInfo(itemID)
			end
			if name and not itemName[itemID] then
				itemName[itemID] = name
			end

			self.text:SetFormattedText(displayString, name or INVTYPE_AMMO, count or 0) -- Does not need localized. It gets updated.
		else
			self.text:SetFormattedText(displayString, INVTYPE_AMMO, 0)
		end
	end

	if not name then
		waitingItemID = itemID
		self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
	end

	lastPanel = self
end

local itemCount = {}
local function OnEnter()
	DT.tooltip:ClearLines()
	if E.myclass == 'HUNTER' or E.myclass == 'ROGUE' or E.myclass == 'WARRIOR' then
		wipe(itemCount)
		DT.tooltip:AddLine(INVTYPE_AMMO)

		for i = 0, NUM_BAG_FRAMES do
			for j = 1, GetContainerNumSlots(i) do
				local itemID = GetContainerItemID(i, j)
				if itemID and not itemCount[itemID] then
					local name, _, quality, _, _, _, _, _, equipLoc, texture = GetItemInfo(itemID)
					local count = GetItemCount(itemID)
					if equipLoc == 'INVTYPE_AMMO' or equipLoc == 'INVTYPE_THROWN' then
						DT.tooltip:AddDoubleLine(strjoin('', format(iconString, texture), ' ', name), count, GetItemQualityColor(quality))
						itemCount[itemID] = count
					end
				end
			end
		end

		DT.tooltip:AddLine(' ')
	end

	for i = 1, NUM_BAG_SLOTS do
		local itemID = GetInventoryItemID('player', ContainerIDToInventoryID(i))
		if itemID then
			local name, _, quality, _, _, _, itemSubType, _, _, texture, itemClassID, itemSubClassID = GetItemInfo(itemID)
			if itemSubClassID == LE_ITEM_CLASS_QUIVER or itemClassID == LE_ITEM_CLASS_CONTAINER and itemSubClassID == 1 then
				local free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
				local used = total - free

				DT.tooltip:AddLine(itemSubType)
				DT.tooltip:AddDoubleLine(strjoin('', format(iconString, texture), '  ', name), format('%d / %d', used, total), GetItemQualityColor(quality))
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick(_, btn)
	if btn == 'LeftButton' then
		if not E.private.bags.enable then
			for i = 1, NUM_BAG_SLOTS do
				local itemID = GetInventoryItemID('player', ContainerIDToInventoryID(i))
				if itemID then
					local itemClassID, itemSubClassID = select(11, GetItemInfo(itemID))
					if itemSubClassID == LE_ITEM_CLASS_QUIVER or itemClassID == LE_ITEM_CLASS_CONTAINER and itemSubClassID == 1 then
						_G.ToggleBag(i)
					end
				end
			end
		else
			_G.ToggleAllBags()
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%d|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Ammo', nil, {'BAG_UPDATE', 'UNIT_INVENTORY_CHANGED'}, OnEvent, nil, OnClick, OnEnter, nil, L["Ammo/Shard Counter"])
