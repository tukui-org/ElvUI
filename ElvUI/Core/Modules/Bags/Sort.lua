local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Bags')
local Search = E.Libs.ItemSearch

local ipairs, pairs, select, unpack, pcall = ipairs, pairs, select, unpack, pcall
local strmatch, gmatch, strfind = strmatch, gmatch, strfind
local tinsert, tremove, sort, wipe = tinsert, tremove, sort, wipe
local tonumber, floor, band = tonumber, floor, bit.band

local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetCursorInfo = GetCursorInfo
local GetGuildBankItemInfo = GetGuildBankItemInfo
local GetGuildBankItemLink = GetGuildBankItemLink
local GetGuildBankTabInfo = GetGuildBankTabInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetItemFamily = GetItemFamily
local GetItemInfo = GetItemInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local PickupGuildBankItem = PickupGuildBankItem
local QueryGuildBankTab = QueryGuildBankTab
local SplitGuildBankItem = SplitGuildBankItem

local NUM_BAG_SLOTS = NUM_BAG_SLOTS + (E.Retail and 1 or 0) -- add the profession bag
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS
local BANK_CONTAINER = BANK_CONTAINER

local C_PetJournalGetPetInfoBySpeciesID = C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID
local ItemClass_Armor = Enum.ItemClass.Armor
local ItemClass_Weapon = Enum.ItemClass.Weapon

local ContainerIDToInventoryID = ContainerIDToInventoryID or (C_Container and C_Container.ContainerIDToInventoryID)
local GetContainerItemID = GetContainerItemID or (C_Container and C_Container.GetContainerItemID)
local GetContainerItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)
local GetContainerNumFreeSlots = GetContainerNumFreeSlots or (C_Container and C_Container.GetContainerNumFreeSlots)
local GetContainerNumSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local PickupContainerItem = PickupContainerItem or (C_Container and C_Container.PickupContainerItem)
local SplitContainerItem = SplitContainerItem or (C_Container and C_Container.SplitContainerItem)

local guildBags = {51,52,53,54,55,56,57,58}
local bankBags = {BANK_CONTAINER}
local MAX_MOVE_TIME = 1.25

for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
	tinsert(bankBags, i)
end

local playerBags = {}
for i = 0, NUM_BAG_SLOTS do
	tinsert(playerBags, i)
end

local allBags = {}
for _,i in ipairs(playerBags) do
	tinsert(allBags, i)
end
for _,i in ipairs(bankBags) do
	tinsert(allBags, i)
end

for _,i in ipairs(guildBags) do
	tinsert(allBags, i)
end

local coreGroups = {
	guild = guildBags,
	bank = bankBags,
	bags = playerBags,
	all = allBags,
}

local bagCache = {}
local bagIDs = {}
local bagQualities = {}
local bagPetIDs = {}
local bagStacks = {}
local bagMaxStacks = {}
local bagGroups = {}
local initialOrder = {}
local bagSorted, bagLocked = {}, {}
local bagRole
local moves = {}
local targetItems = {}
local sourceUsed = {}
local targetSlots = {}
local specialtyBags = {}
local emptySlots = {}

local moveRetries = 0
local lastItemID, lockStop, lastDestination, lastMove
local moveTracker = {}

local inventorySlots = {
	INVTYPE_AMMO = 0,
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 12,
	INVTYPE_CLOAK = 13,
	INVTYPE_WEAPON = 14,
	INVTYPE_SHIELD = 15,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 18,
	INVTYPE_WEAPONOFFHAND = 19,
	INVTYPE_HOLDABLE = 20,
	INVTYPE_RANGED = 21,
	INVTYPE_THROWN = 22,
	INVTYPE_RANGEDRIGHT = 23,
	INVTYPE_RELIC = 24,
	INVTYPE_TABARD = 25,
}

local conjured_items = E.Retail and {
	[5512] = true, -- Healthstone
	[162518] = true, -- Mystical Flask
	[113509] = true, -- Conjured Mana Bun
} or { -- TBC and Classic
	-- Mage Water
	[5350]	= true, -- Conjured Water
	[2288]	= true, -- Conjured Fresh Water (Level 5)
	[2136]	= true, -- Conjured Purified Water (Level 15)
	[3772]	= true, -- Conjured Spring Water (Level 25)
	[8077]	= true, -- Conjured Mineral Water (Level 35)
	[8078]	= true, -- Conjured Sparkling Water (Level 45)
	[8079]	= true, -- Conjured Crystal Water (Level 55)
	[30703] = true, -- Conjured Mountain Spring Water (Level 60)
	[22018] = true, -- Conjured Glacier Water (Level 65)

	-- Mage Food
	[5349]	= true, -- Conjured Muffin
	[1113]	= true, -- Conjured Bread (Level 5)
	[1114]	= true, -- Conjured Rye (Level 15)
	[1487]	= true, -- Conjured Pumpernickel (Level 25)
	[8075]	= true, -- Conjured Sourdough (Level 35)
	[8076]	= true, -- Conjured Sweet Roll (Level 45)
	[22895] = true, -- Conjured Cinnamon Roll (Level 55)
	[22019] = true, -- Conjured Croissant (Level 65)

	-- Mage Mana
	[5514]	= true, -- Mana Agate
	[5513]	= true, -- Mana Jade
	[8007]	= true, -- Mana Citrine
	[8008]	= true, -- Mana Ruby
	[22044] = true, -- Mana Emerald

	-- Warlock Soulstones
	[5232]	= true, -- Minor Soulstone
	[16892] = true, -- Lesser Soulstone
	[16893] = true, -- Soulstone
	[16895] = true, -- Greater Soulstone
	[16896] = true, -- Major Soulstone
	[22116] = true, -- Master Soulstone

	-- Warlock Firestones
	[1254]	= true, -- Lesser Firestone
	[13699] = true, -- Firestone
	[13700] = true, -- Greater Firestone
	[13701] = true, -- Major Firestone
	[22128] = true, -- Master Firestone

	-- Warlock Spellstones
	[5522]	= true, -- Spellstone
	[13602] = true, -- Greater Spellstone
	[13603] = true, -- Major Spellstone
	[22646] = true, -- Master Spellstone

	-- Warlock Healthstones
	[5512]	= true, -- Minor Healthstone
	[19004] = true, -- Minor Healthstone (1/2 Improved Healthstone)
	[19005] = true, -- Minor Healthstone (2/2 Improved Healthstone)
	[5511]	= true, -- Lesser Healthstone
	[19006] = true, -- Lesser Healthstone (1/2 Improved Healthstone)
	[19007] = true, -- Lesser Healthstone (2/2 Improved Healthstone)
	[5509]	= true, -- Healthstone
	[19008] = true, -- Healthstone (1/2 Improved Healthstone)
	[19009] = true, -- Healthstone (2/2 Improved Healthstone)
	[5510]	= true, -- Greater Healthstone
	[19010] = true, -- Greater Healthstone (1/2 Improved Healthstone)
	[19011] = true, -- Greater Healthstone (2/2 Improved Healthstone)
	[9421]	= true, -- Major Healthstone
	[19012] = true, -- Major Healthstone (1/2 Improved Healthstone)
	[19013] = true, -- Major Healthstone (2/2 Improved Healthstone)
	[22103] = true, -- Master Healthstone
	[22104] = true, -- Master Healthstone (1/2 Improved Healthstone)
	[22105] = true, -- Master Healthstone (2/2 Improved Healthstone)
}

local safe = {
	[BANK_CONTAINER] = true,
	[0] = true
}

local WAIT_TIME = 0.05
do
	local t = 0
	local frame = CreateFrame('Frame')
	frame:SetScript('OnUpdate', function(_, elapsed)
		t = t + (elapsed or 0.01)
		if t > WAIT_TIME then
			t = 0
			B:DoMoves()
		end
	end)
	frame:Hide()
	B.SortUpdateTimer = frame
end

local function IsGuildBankBag(bagid)
	return bagid > 50 and bagid <= 58
end

local function UpdateLocation(from, to)
	if bagIDs[from] == bagIDs[to] and (bagStacks[to] < bagMaxStacks[to]) then
		local stackSize = bagMaxStacks[to]
		if (bagStacks[to] + bagStacks[from]) > stackSize then
			bagStacks[from] = bagStacks[from] - (stackSize - bagStacks[to])
			bagStacks[to] = stackSize
		else
			bagStacks[to] = bagStacks[to] + bagStacks[from]
			bagStacks[from] = nil
			bagIDs[from] = nil
			bagQualities[from] = nil
			bagMaxStacks[from] = nil
		end
	else
		bagIDs[from], bagIDs[to] = bagIDs[to], bagIDs[from]
		bagQualities[from], bagQualities[to] = bagQualities[to], bagQualities[from]
		bagStacks[from], bagStacks[to] = bagStacks[to], bagStacks[from]
		bagMaxStacks[from], bagMaxStacks[to] = bagMaxStacks[to], bagMaxStacks[from]
	end
end

local function PrimarySort(a, b)
	local aName, _, _, aLvl, _, _, _, _, _, _, aPrice = GetItemInfo(bagIDs[a])
	local bName, _, _, bLvl, _, _, _, _, _, _, bPrice = GetItemInfo(bagIDs[b])

	if aLvl ~= bLvl and aLvl and bLvl then
		return aLvl > bLvl
	end
	if aPrice ~= bPrice and aPrice and bPrice then
		return aPrice > bPrice
	end

	if aName and bName then
		return aName < bName
	end
end

local function DefaultSort(a, b)
	local aID = bagIDs[a]
	local bID = bagIDs[b]

	if not aID or not bID then return aID end

	if E.Retail and bagPetIDs[a] and bagPetIDs[b] then
		local aName, _, aType = C_PetJournalGetPetInfoBySpeciesID(aID)
		local bName, _, bType = C_PetJournalGetPetInfoBySpeciesID(bID)

		if aType and bType and aType ~= bType then
			return aType > bType
		end

		if aName and bName and aName ~= bName then
			return aName < bName
		end
	end

	local aOrder, bOrder = initialOrder[a], initialOrder[b]

	if aID == bID then
		local aCount = bagStacks[a]
		local bCount = bagStacks[b]
		if aCount and bCount and aCount == bCount then
			return aOrder < bOrder
		elseif aCount and bCount then
			return aCount < bCount
		end
	end

	local _, _, _, _, _, _, _, _, aEquipLoc, _, _, aItemClassId, aItemSubClassId = GetItemInfo(aID)
	local _, _, _, _, _, _, _, _, bEquipLoc, _, _, bItemClassId, bItemSubClassId = GetItemInfo(bID)

	local aRarity, bRarity = bagQualities[a], bagQualities[b]

	if bagPetIDs[a] then
		aRarity = 1
	end

	if bagPetIDs[b] then
		bRarity = 1
	end

	if conjured_items[aID] then
		aRarity = -99
	end

	if conjured_items[bID] then
		bRarity = -99
	end

	if aRarity ~= bRarity and aRarity and bRarity then
		return aRarity > bRarity
	end

	if aItemClassId ~= bItemClassId then
		return (aItemClassId or 99) < (bItemClassId or 99)
	end

	if aItemClassId == ItemClass_Armor or aItemClassId == ItemClass_Weapon then
		aEquipLoc = inventorySlots[aEquipLoc] or -1
		bEquipLoc = inventorySlots[bEquipLoc] or -1
		if aEquipLoc == bEquipLoc then
			return PrimarySort(a, b)
		end

		if aEquipLoc and bEquipLoc then
			return aEquipLoc < bEquipLoc
		end
	end
	if aItemClassId == bItemClassId and (aItemSubClassId == bItemSubClassId) then
		return PrimarySort(a, b)
	end

	return (aItemSubClassId or 99) < (bItemSubClassId or 99)
end

local function ReverseSort(a, b)
	return DefaultSort(b, a)
end

local function UpdateSorted(source, destination)
	for i, bs in pairs(bagSorted) do
		if bs == source then
			bagSorted[i] = destination
		elseif bs == destination then
			bagSorted[i] = source
		end
	end
end

local function ShouldMove(source, destination)
	if destination == source then return end

	if not bagIDs[source] then return end
	if bagIDs[source] == bagIDs[destination] and bagStacks[source] == bagStacks[destination] then return end

	return true
end

local function IterateForwards(bagList, i)
	i = i + 1
	local step = 1
	for _,bag in ipairs(bagList) do
		local slots = B:GetNumSlots(bag, bagRole)
		if i > slots + step then
			step = step + slots
		else
			for slot = 1, slots do
				if step == i then
					return i, bag, slot
				end
				step = step + 1
			end
		end
	end
	bagRole = nil
end

local function IterateBackwards(bagList, i)
	i = i + 1
	local step = 1
	for ii = #bagList, 1, -1 do
		local bag = bagList[ii]
		local slots = B:GetNumSlots(bag, bagRole)
		if i > slots + step then
			step = step + slots
		else
			for slot=slots, 1, -1 do
				if step == i then
					return i, bag, slot
				end
				step = step + 1
			end
		end
	end
	bagRole = nil
end

function B:IterateBags(bagList, reverse, role)
	bagRole = role
	return (reverse and IterateBackwards or IterateForwards), bagList, 0
end

function B:GetItemLink(bag, slot)
	if IsGuildBankBag(bag) then
		return GetGuildBankItemLink(bag - 50, slot)
	else
		return GetContainerItemLink(bag, slot)
	end
end

function B:GetItemID(bag, slot)
	if IsGuildBankBag(bag) then
		local link = B:GetItemLink(bag, slot)
		return link and tonumber(strmatch(link, 'item:(%d+)'))
	else
		return GetContainerItemID(bag, slot)
	end
end

function B:GetItemInfo(bag, slot)
	if IsGuildBankBag(bag) then
		return GetGuildBankItemInfo(bag - 50, slot)
	else
		local info = B:GetContainerItemInfo(bag, slot)
		if info then
			return info.iconFileID, info.stackCount, info.isLocked
		end
	end
end

function B:PickupItem(bag, slot)
	if IsGuildBankBag(bag) then
		return PickupGuildBankItem(bag - 50, slot)
	else
		return PickupContainerItem(bag, slot)
	end
end

function B:SplitItem(bag, slot, amount)
	if IsGuildBankBag(bag) then
		return SplitGuildBankItem(bag - 50, slot, amount)
	else
		return SplitContainerItem(bag, slot, amount)
	end
end

function B:GetNumSlots(bag)
	if IsGuildBankBag(bag) then
		local name, _, canView = GetGuildBankTabInfo(bag - 50)
		if name and canView then
			return 98
		end
	else
		return GetContainerNumSlots(bag)
	end

	return 0
end

function B:ConvertLinkToID(link)
	if not link then return end

	local item = strmatch(link, 'item:(%d+)')
	if item then return tonumber(item) end

	local ks = strmatch(link, 'keystone:(%d+)')
	if ks then return tonumber(ks), nil, true end

	local bp = strmatch(link, 'battlepet:(%d+)')
	if bp then return tonumber(bp), true end
end

local function DefaultCanMove()
	return true
end

function B:Encode_BagSlot(bag, slot)
	return (bag*100) + slot
end

function B:Decode_BagSlot(int)
	return floor(int*0.01), int % 100
end

function B:IsPartial(bag, slot)
	local bagSlot = B:Encode_BagSlot(bag, slot)
	return ((bagMaxStacks[bagSlot] or 0) - (bagStacks[bagSlot] or 0)) > 0
end

function B:EncodeMove(source, target)
	return (source * 10000) + target
end

function B:DecodeMove(move)
	local s = floor(move*0.0001)
	local t = move%10000
	s = (t>9000) and (s+1) or s
	t = (t>9000) and (t-10000) or t
	return s, t
end

function B:AddMove(source, destination)
	UpdateLocation(source, destination)
	tinsert(moves, 1, B:EncodeMove(source, destination))
end

function B:ScanBags()
	for _, bag, slot in B:IterateBags(allBags) do
		local bagSlot = B:Encode_BagSlot(bag, slot)
		local itemLink = B:GetItemLink(bag, slot)
		local itemID, isBattlePet, isKeystone = B:ConvertLinkToID(itemLink)
		if itemID then
			if isBattlePet then
				bagPetIDs[bagSlot] = itemID
				bagMaxStacks[bagSlot] = 1
			elseif isKeystone then
				bagMaxStacks[bagSlot] = 1
				bagQualities[bagSlot] = 4
				bagStacks[bagSlot] = 1
			else
				bagMaxStacks[bagSlot] = select(8, GetItemInfo(itemID))
			end

			bagIDs[bagSlot] = itemID
			if not isKeystone then
				bagQualities[bagSlot] = select(3, GetItemInfo(itemLink))
				bagStacks[bagSlot] = select(2, B:GetItemInfo(bag, slot))
			end
		end
	end
end

function B:IsSpecialtyBag(bagID)
	if safe[bagID] or IsGuildBankBag(bagID) then return false end

	local inventorySlot = ContainerIDToInventoryID(bagID)
	if not inventorySlot then return false end

	local bag = GetInventoryItemLink('player', inventorySlot)
	if not bag then return false end

	local family = GetItemFamily(bag)
	if family == 0 or family == nil then return false end

	return family
end

function B:CanItemGoInBag(bag, slot, targetBag)
	if IsGuildBankBag(targetBag) then return true end

	local item = bagIDs[B:Encode_BagSlot(bag, slot)]
	local itemFamily = GetItemFamily(item)
	if itemFamily and itemFamily > 0 then
		local equipSlot = select(9, GetItemInfo(item))
		if equipSlot == 'INVTYPE_BAG' then
			itemFamily = 1
		end
	end
	local bagFamily = select(2, GetContainerNumFreeSlots(targetBag))
	if itemFamily then
		return (bagFamily == 0) or band(itemFamily, bagFamily) > 0
	else
		return false
	end
end

function B.Compress(...)
	for i=1, select('#', ...) do
		local bags = select(i, ...)
		B.Stack(bags, bags, B.IsPartial)
	end
end

function B.Stack(sourceBags, targetBags, canMove)
	if not canMove then canMove = DefaultCanMove end
	for _, bag, slot in B:IterateBags(targetBags, nil, 'deposit') do
		local bagSlot = B:Encode_BagSlot(bag, slot)
		local itemID = bagIDs[bagSlot]

		if itemID and (bagStacks[bagSlot] ~= bagMaxStacks[bagSlot]) then
			targetItems[itemID] = (targetItems[itemID] or 0) + 1
			tinsert(targetSlots, bagSlot)
		end
	end

	for _, bag, slot in B:IterateBags(sourceBags, true, 'withdraw') do
		local sourceSlot = B:Encode_BagSlot(bag, slot)
		local itemID = bagIDs[sourceSlot]
		if itemID and targetItems[itemID] and canMove(itemID, bag, slot) then
			for i = #targetSlots, 1, -1 do
				local targetedSlot = targetSlots[i]
				if bagIDs[sourceSlot] and bagIDs[targetedSlot] == itemID and targetedSlot ~= sourceSlot and not (bagStacks[targetedSlot] == bagMaxStacks[targetedSlot]) and not sourceUsed[targetedSlot] then
					B:AddMove(sourceSlot, targetedSlot)
					sourceUsed[sourceSlot] = true

					if bagStacks[targetedSlot] == bagMaxStacks[targetedSlot] then
						targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
					end
					if bagStacks[sourceSlot] == 0 then
						targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
						break
					end
					if not targetItems[itemID] then break end
				end
			end
		end
	end

	wipe(targetItems)
	wipe(targetSlots)
	wipe(sourceUsed)
end

local blackListedSlots = {}
local blackList = {}
local blackListQueries = {}
function B:BuildBlacklist(...)
	for entry in pairs(...) do
		local itemName = GetItemInfo(entry)

		if itemName then
			blackList[itemName] = true
		elseif entry ~= '' then
			if strfind(entry, '%[') and strfind(entry, '%]') then
				--For some reason the entry was not treated as a valid item. Extract the item name.
				entry = strmatch(entry, '%[(.*)%]')
			end
			blackListQueries[#blackListQueries+1] = entry
		end
	end
end

function B.Sort(bags, sorter, invertDirection)
	if not sorter then sorter = invertDirection and ReverseSort or DefaultSort end

	--Wipe tables before we begin
	wipe(blackList)
	wipe(blackListQueries)
	wipe(blackListedSlots)

	--Build blacklist of items based on the profile and global list
	B:BuildBlacklist(B.db.ignoredItems)
	B:BuildBlacklist(E.global.bags.ignoredItems)

	for i, bag, slot in B:IterateBags(bags, nil, 'both') do
		if not E.Retail or not B:IsSortIgnored(bag) then
			local bagSlot = B:Encode_BagSlot(bag, slot)
			local link = B:GetItemLink(bag, slot)

			if link then
				if blackList[GetItemInfo(link)] then
					blackListedSlots[bagSlot] = true
				end

				if not blackListedSlots[bagSlot] then
					local method
					for _,itemsearchquery in pairs(blackListQueries) do
						method = Search.Matches
						if Search.Filters.tipPhrases.keywords[itemsearchquery] then
							method = Search.TooltipPhrase
							itemsearchquery = Search.Filters.tipPhrases.keywords[itemsearchquery]
						end
						local success, result = pcall(method, Search, link, itemsearchquery)
						if success and result then
							blackListedSlots[bagSlot] = result
							break
						end
					end
				end
			end

			if not blackListedSlots[bagSlot] then
				initialOrder[bagSlot] = i
				tinsert(bagSorted, bagSlot)
			end
		end
	end

	sort(bagSorted, sorter)

	local passNeeded = true
	while passNeeded do
		passNeeded = false

		local i = 1
		for _, bag, slot in B:IterateBags(bags, nil, 'both') do
			local destination = B:Encode_BagSlot(bag, slot)
			if not blackListedSlots[destination] and (not E.Retail or not B:IsSortIgnored(bag)) then
				local source = bagSorted[i]
				if ShouldMove(source, destination) then
					if not (bagLocked[source] or bagLocked[destination]) then
						B:AddMove(source, destination)
						UpdateSorted(source, destination)
						bagLocked[source] = true
						bagLocked[destination] = true
					else
						passNeeded = true
					end
				end
				i = i + 1
			end
		end

		wipe(bagLocked)
	end

	wipe(bagSorted)
	wipe(initialOrder)
end

function B.FillBags(from, to)
	B.Stack(from, to)
	for _, bag in ipairs(to) do
		if B:IsSpecialtyBag(bag) then
			tinsert(specialtyBags, bag)
		end
	end
	if #specialtyBags > 0 then
		B:Fill(from, specialtyBags)
	end

	B.Fill(from, to)
	wipe(specialtyBags)
end

function B.Fill(sourceBags, targetBags, reverse, canMove)
	if not canMove then canMove = DefaultCanMove end

	--Wipe tables before we begin
	wipe(blackList)
	wipe(blackListedSlots)

	--Build blacklist of items based on the profile and global list
	B:BuildBlacklist(B.db.ignoredItems)
	B:BuildBlacklist(E.global.bags.ignoredItems)

	for _, bag, slot in B:IterateBags(targetBags, reverse, 'deposit') do
		local bagSlot = B:Encode_BagSlot(bag, slot)
		if not bagIDs[bagSlot] then
			tinsert(emptySlots, bagSlot)
		end
	end

	for _, bag, slot in B:IterateBags(sourceBags, not reverse, 'withdraw') do
		if #emptySlots == 0 then break end
		local bagSlot = B:Encode_BagSlot(bag, slot)
		local targetBag = B:Decode_BagSlot(emptySlots[1])
		local link = B:GetItemLink(bag, slot)

		if link and blackList[GetItemInfo(link)] then
			blackListedSlots[bagSlot] = true
		end

		if bagIDs[bagSlot] and B:CanItemGoInBag(bag, slot, targetBag) and canMove(bagIDs[bagSlot], bag, slot) and not blackListedSlots[bagSlot] then
			B:AddMove(bagSlot, tremove(emptySlots, 1))
		end
	end

	wipe(emptySlots)
end

function B.SortBags(...)
	for i=1, select('#', ...) do
		local bags = select(i, ...)
		for _, slotNum in ipairs(bags) do
			local bagType = B:IsSpecialtyBag(slotNum)
			if bagType == false then bagType = 'Normal' end
			if not bagCache[bagType] then bagCache[bagType] = {} end
			tinsert(bagCache[bagType], slotNum)
		end

		for bagType, sortedBags in pairs(bagCache) do
			if bagType ~= 'Normal' then
				B.Stack(sortedBags, sortedBags, B.IsPartial)
				B.Stack(bagCache.Normal, sortedBags)
				B.Fill(bagCache.Normal, sortedBags, B.db.sortInverted)
				B.Sort(sortedBags, nil, B.db.sortInverted)
				wipe(sortedBags)
			end
		end

		if bagCache.Normal then
			B.Stack(bagCache.Normal, bagCache.Normal, B.IsPartial)
			B.Sort(bagCache.Normal, nil, B.db.sortInverted)
			wipe(bagCache.Normal)
		end

		wipe(bagCache)
		wipe(bagGroups)
	end
end

function B:StartStacking()
	wipe(bagMaxStacks)
	wipe(bagStacks)
	wipe(bagIDs)
	wipe(bagQualities)
	wipe(bagPetIDs)
	wipe(moveTracker)

	if #moves > 0 then
		B.SortUpdateTimer:Show()
	else
		B:StopStacking()
	end
end

function B:RegisterUpdateDelayed()
	local shouldUpdateFade

	for _, bagFrame in pairs(B.BagFrames) do
		if bagFrame.sortingSlots then
			bagFrame.sortingSlots = nil -- need this above update slots to clear the overlay
			shouldUpdateFade = true -- we should refresh the bag search after sorting

			B:UpdateAllSlots(bagFrame)
			B:SetListeners(bagFrame)
		end
	end

	if shouldUpdateFade then
		B:RefreshSearch() -- this will clear the bag lock look during a sort
	end
end

function B:StopStacking(message, noUpdate)
	wipe(moves)
	wipe(moveTracker)
	moveRetries, lastItemID, lockStop, lastDestination, lastMove = 0, nil, nil, nil, nil

	B.SortUpdateTimer:Hide()

	if not noUpdate then
		--Add a delayed update call, as BAG_UPDATE fires slightly delayed
		-- and we don't want the last few unneeded updates to be catched
		E:Delay(0.6, B.RegisterUpdateDelayed)
	end

	if message then
		E:Print(message)
	end
end

function B:DoMove(move)
	if GetCursorInfo() == 'item' then
		return false, 'cursorhasitem'
	end

	local source, target = B:DecodeMove(move)
	local sourceBag, sourceSlot = B:Decode_BagSlot(source)
	local targetBag, targetSlot = B:Decode_BagSlot(target)

	local _, sourceCount, sourceLocked = B:GetItemInfo(sourceBag, sourceSlot)
	local _, targetCount, targetLocked = B:GetItemInfo(targetBag, targetSlot)

	if sourceLocked or targetLocked then
		return false, 'source/target_locked'
	end

	local sourceItemID = B:GetItemID(sourceBag, sourceSlot)
	local targetItemID = B:GetItemID(targetBag, targetSlot)

	if not sourceItemID then
		if moveTracker[source] then
			return false, 'move incomplete'
		else
			return B:StopStacking(L["Confused.. Try Again!"])
		end
	end

	local stackSize = select(8, GetItemInfo(sourceItemID))
	if sourceItemID == targetItemID and (targetCount ~= stackSize) and ((targetCount + sourceCount) > stackSize) then
		B:SplitItem(sourceBag, sourceSlot, stackSize - targetCount)
	else
		B:PickupItem(sourceBag, sourceSlot)
	end

	if GetCursorInfo() == 'item' then
		B:PickupItem(targetBag, targetSlot)
	end

	local sourceGuild = IsGuildBankBag(sourceBag)
	local targetGuild = IsGuildBankBag(targetBag)

	if sourceGuild then
		QueryGuildBankTab(sourceBag - 50)
	end
	if targetGuild then
		QueryGuildBankTab(targetBag - 50)
	end

	return true, sourceItemID, source, targetItemID, target, sourceGuild or targetGuild
end

function B:DoMoves()
	if InCombatLockdown() then
		return B:StopStacking(L["Confused.. Try Again!"])
	end

	local cursorType, cursorItemID = GetCursorInfo()
	if cursorType == 'item' and cursorItemID then
		if lastItemID ~= cursorItemID then
			return B:StopStacking(L["Confused.. Try Again!"])
		end

		if moveRetries < 100 then
			local targetBag, targetSlot = B:Decode_BagSlot(lastDestination)
			local _, _, targetLocked = B:GetItemInfo(targetBag, targetSlot)
			if not targetLocked then
				B:PickupItem(targetBag, targetSlot)
				WAIT_TIME = 0.1
				lockStop = GetTime()
				moveRetries = moveRetries + 1
				return
			end
		end
	end

	if lockStop then
		for slot, itemID in pairs(moveTracker) do
			local actualItemID = B:GetItemID(B:Decode_BagSlot(slot))
			if actualItemID ~= itemID then
				WAIT_TIME = 0.1
				if (GetTime() - lockStop) > MAX_MOVE_TIME then
					if lastMove and moveRetries < 100 then
						local success, moveID, moveSource, targetID, moveTarget, wasGuild = B:DoMove(lastMove)
						WAIT_TIME = wasGuild and 0.5 or 0.1

						if not success then
							lockStop = GetTime()
							moveRetries = moveRetries + 1
							return
						end

						moveTracker[moveSource] = targetID
						moveTracker[moveTarget] = moveID
						lastDestination = moveTarget
						-- lastMove = moves[i] --Where does 'i' come from???
						lastItemID = moveID
						-- tremove(moves, i) --Where does 'i' come from???
						return
					end

					B:StopStacking()
					return
				end
				return --give processing time to happen
			end
			moveTracker[slot] = nil
		end
	end

	lastItemID, lockStop, lastDestination, lastMove = nil, nil, nil, nil
	wipe(moveTracker)

	local success, moveID, targetID, moveSource, moveTarget, wasGuild
	if #moves > 0 then
		for i = #moves, 1, -1 do
			success, moveID, moveSource, targetID, moveTarget, wasGuild = B:DoMove(moves[i])
			if not success then
				WAIT_TIME = wasGuild and 0.3 or 0.1
				lockStop = GetTime()
				return
			end
			moveTracker[moveSource] = targetID
			moveTracker[moveTarget] = moveID
			lastDestination = moveTarget
			lastMove = moves[i]
			lastItemID = moveID
			tremove(moves, i)

			if moves[i-1] then
				WAIT_TIME = wasGuild and 0.3 or 0
				return
			end
		end
	end
	B:StopStacking()
end

function B:GetGroup(id)
	if strmatch(id, '^[-%d,]+$') then
		local bags = {}
		for b in gmatch(id, '-?%d+') do
			tinsert(bags, tonumber(b))
		end
		return bags
	end
	return coreGroups[id]
end

function B:CommandDecorator(func, groupsDefaults)
	return function(groups)
		if B.SortUpdateTimer:IsShown() then
			B:StopStacking(L["Already Running.. Bailing Out!"], true)
			return
		end

		wipe(bagGroups)
		if not groups or #groups == 0 then
			groups = groupsDefaults
		end
		for bags in (groups or ''):gmatch('%S+') do
			if bags == 'guild' then
				bags = B:GetGroup(bags)
				if bags then
					tinsert(bagGroups, {bags[GetCurrentGuildBankTab()]})
				end
			else
				bags = B:GetGroup(bags)
				if bags then
					tinsert(bagGroups, bags)
				end
			end
		end

		B:ScanBags()
		if func(unpack(bagGroups)) == false then
			return
		end
		wipe(bagGroups)
		B:StartStacking()
	end
end
