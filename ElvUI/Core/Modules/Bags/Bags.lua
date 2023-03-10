local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Bags')
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')
local AB = E:GetModule('ActionBars')
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local tinsert, tremove, wipe = tinsert, tremove, wipe
local type, ipairs, unpack, select = type, ipairs, unpack, select
local next, max, floor, format, strsub = next, max, floor, format, strsub

local EasyMenu = EasyMenu
local BreakUpLargeNumbers = BreakUpLargeNumbers
local CreateFrame = CreateFrame
local CursorHasItem = CursorHasItem
local DepositReagentBank = DepositReagentBank
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local GetBindingKey = GetBindingKey
local GetCVarBool = GetCVarBool
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemSpell = GetItemSpell
local GetKeyRingSize = GetKeyRingSize
local GetMoney = GetMoney
local GetNumBankSlots = GetNumBankSlots
local hooksecurefunc = hooksecurefunc
local IsInventoryItemProfessionBag = IsInventoryItemProfessionBag
local IsReagentBankUnlocked = IsReagentBankUnlocked
local PlaySound = PlaySound
local PickupBagFromSlot = PickupBagFromSlot
local PutItemInBackpack = PutItemInBackpack
local PutItemInBag = PutItemInBag
local PutKeyInKeyRing = PutKeyInKeyRing
local ReagentButtonInventorySlot = ReagentButtonInventorySlot
local SetBankAutosortDisabled = SetBankAutosortDisabled
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local SetItemButtonQuality = SetItemButtonQuality
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local StaticPopup_Show = StaticPopup_Show
local ToggleFrame = ToggleFrame
local UnitAffectingCombat = UnitAffectingCombat

local IsBagOpen, IsOptionFrameOpen = IsBagOpen, IsOptionFrameOpen
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local CloseBag, CloseBackpack, CloseBankFrame = CloseBag, CloseBackpack, CloseBankFrame

local EditBox_HighlightText = EditBox_HighlightText
local BankFrameItemButton_Update = BankFrameItemButton_Update
local BankFrameItemButton_UpdateLocked = BankFrameItemButton_UpdateLocked
local C_TransmogCollection_PlayerHasTransmogByItemInfo = C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo
local C_TransmogCollection_GetItemInfo = C_TransmogCollection and C_TransmogCollection.GetItemInfo
local C_Item_CanScrapItem = C_Item.CanScrapItem
local C_Item_DoesItemExist = C_Item.DoesItemExist
local C_Item_GetCurrentItemLevel = C_Item.GetCurrentItemLevel
local C_NewItems_IsNewItem = C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = C_NewItems.RemoveNewItem
local C_Item_IsBound = C_Item.IsBound

local SortBags = SortBags or (C_Container and C_Container.SortBags)
local SortBankBags = SortBankBags or (C_Container and C_Container.SortBankBags)
local SortReagentBankBags = SortReagentBankBags or (C_Container and C_Container.SortReagentBankBags)
local SplitContainerItem = SplitContainerItem or (C_Container and C_Container.SplitContainerItem)
local SetItemSearch = SetItemSearch or (C_Container and C_Container.SetItemSearch)
local GetBagSlotFlag = GetBagSlotFlag or (C_Container and C_Container.GetBagSlotFlag)
local SetBagSlotFlag = SetBagSlotFlag or (C_Container and C_Container.SetBagSlotFlag)
local GetBankBagSlotFlag = GetBankBagSlotFlag or (C_Container and C_Container.GetBankBagSlotFlag)
local SetBankBagSlotFlag = SetBankBagSlotFlag or (C_Container and C_Container.SetBankBagSlotFlag)
local ContainerIDToInventoryID = ContainerIDToInventoryID or (C_Container and C_Container.ContainerIDToInventoryID)
local GetBackpackAutosortDisabled = GetBackpackAutosortDisabled or (C_Container and C_Container.GetBackpackAutosortDisabled)
local GetBankAutosortDisabled = GetBankAutosortDisabled or (C_Container and C_Container.GetBankAutosortDisabled)
local GetContainerItemCooldown = GetContainerItemCooldown or (C_Container and C_Container.GetContainerItemCooldown)
local GetContainerNumFreeSlots = GetContainerNumFreeSlots or (C_Container and C_Container.GetContainerNumFreeSlots)
local GetContainerNumSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local SetBackpackAutosortDisabled = SetBackpackAutosortDisabled or (C_Container and C_Container.SetBackpackAutosortDisabled)
local SetInsertItemsLeftToRight = SetInsertItemsLeftToRight or (C_Container and C_Container.SetInsertItemsLeftToRight)
local UseContainerItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)

local CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y = CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y
local IG_BACKPACK_CLOSE = SOUNDKIT.IG_BACKPACK_CLOSE
local IG_BACKPACK_OPEN = SOUNDKIT.IG_BACKPACK_OPEN
local ITEMQUALITY_COMMON = Enum.ItemQuality.Common or Enum.ItemQuality.Standard
local ITEMQUALITY_POOR = Enum.ItemQuality.Poor
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS or 20
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local NUM_BAG_SLOTS = NUM_BAG_SLOTS + (E.Retail and 1 or 0) -- add the profession bag
local NUM_BANKGENERIC_SLOTS = NUM_BANKGENERIC_SLOTS
local NUM_CONTAINER_FRAMES = NUM_CONTAINER_FRAMES
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM
local REAGENTBANK_PURCHASE_TEXT = REAGENTBANK_PURCHASE_TEXT
local BINDING_NAME_TOGGLEKEYRING = BINDING_NAME_TOGGLEKEYRING

local BANK_CONTAINER = BANK_CONTAINER
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local REAGENTBANK_CONTAINER = REAGENTBANK_CONTAINER
local KEYRING_CONTAINER = KEYRING_CONTAINER
local REAGENT_CONTAINER = E.Retail and 5 or math.huge -- impossible id to prevent code on classic

local BAG_FILTER_ASSIGN_TO = BAG_FILTER_ASSIGN_TO
local BAG_FILTER_CLEANUP = BAG_FILTER_CLEANUP
local BAG_FILTER_IGNORE = BAG_FILTER_IGNORE

local BagSlotFlags = Enum.BagSlotFlags
local FILTER_FLAG_TRADE_GOODS = (BagSlotFlags and BagSlotFlags.PriorityTradeGoods) or LE_BAG_FILTER_FLAG_TRADE_GOODS
local FILTER_FLAG_CONSUMABLES = (BagSlotFlags and BagSlotFlags.PriorityConsumables) or LE_BAG_FILTER_FLAG_CONSUMABLES
local FILTER_FLAG_EQUIPMENT = (BagSlotFlags and BagSlotFlags.PriorityEquipment) or LE_BAG_FILTER_FLAG_EQUIPMENT
local FILTER_FLAG_IGNORE = (BagSlotFlags and BagSlotFlags.DisableAutoSort) or LE_BAG_FILTER_FLAG_IGNORE_CLEANUP
local FILTER_FLAG_JUNK = (BagSlotFlags and BagSlotFlags.PriorityJunk) or LE_BAG_FILTER_FLAG_JUNK
local FILTER_FLAG_QUEST = (BagSlotFlags and BagSlotFlags.PriorityQuestItems) or 32 -- didnt exist

local BAG_FILTER_LABELS = BAG_FILTER_LABELS or {
	[FILTER_FLAG_EQUIPMENT] = BAG_FILTER_EQUIPMENT,
	[FILTER_FLAG_CONSUMABLES] = BAG_FILTER_CONSUMABLES,
	[FILTER_FLAG_TRADE_GOODS] = BAG_FILTER_TRADE_GOODS,
	[FILTER_FLAG_JUNK] = BAG_FILTER_JUNK,
	[FILTER_FLAG_QUEST] = BAG_FILTER_QUEST_ITEMS or AUCTION_CATEGORY_QUEST_ITEMS,
}

B.GearFilters = {
	FILTER_FLAG_IGNORE,
	FILTER_FLAG_EQUIPMENT,
	FILTER_FLAG_CONSUMABLES,
	FILTER_FLAG_TRADE_GOODS,
	FILTER_FLAG_JUNK,
}

if not E.Classic then
	tinsert(B.GearFilters, FILTER_FLAG_QUEST)
end

do
	local GetContainerItemInfo = GetContainerItemInfo or (C_Container and C_Container.GetContainerItemInfo)
	local GetContainerItemQuestInfo = GetContainerItemQuestInfo or (C_Container and C_Container.GetContainerItemQuestInfo)
	local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo or (C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo)

	function B:GetBackpackCurrencyInfo(index)
		if _G.GetBackpackCurrencyInfo then
			local info = {}
			info.name, info.quantity, info.iconFileID, info.currencyTypesID = GetBackpackCurrencyInfo(index)
			return info
		else
			return GetBackpackCurrencyInfo(index)
		end
	end

	function B:GetContainerItemInfo(containerIndex, slotIndex)
		if _G.GetContainerItemInfo then
			local info = {}
			info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound = GetContainerItemInfo(containerIndex, slotIndex)
			return info
		else
			return GetContainerItemInfo(containerIndex, slotIndex) or {}
		end
	end

	function B:GetContainerItemQuestInfo(containerIndex, slotIndex)
		if _G.GetContainerItemQuestInfo then
			local info = {}
			info.isQuestItem, info.questID, info.isActive = GetContainerItemQuestInfo(containerIndex, slotIndex)
			return info
		else
			return GetContainerItemQuestInfo(containerIndex, slotIndex)
		end
	end
end

-- GLOBALS: ElvUIBags, ElvUIBagMover, ElvUIBankMover, ElvUIReagentBankFrame

local MAX_CONTAINER_ITEMS = 36
local CONTAINER_WIDTH = 192
local CONTAINER_SPACING = 0
local VISIBLE_CONTAINER_SPACING = 3
local CONTAINER_SCALE = 0.75
local BIND_START, BIND_END

B.numTrackedTokens = 0
B.QuestSlots = {}
B.ItemLevelSlots = {}
B.BAG_FILTER_ICONS = {
	[FILTER_FLAG_EQUIPMENT] = E.Media.Textures.ChestPlate,		-- Interface/ICONS/INV_Chest_Plate10
	[FILTER_FLAG_CONSUMABLES] = E.Media.Textures.GreenPotion,	-- Interface/ICONS/INV_Potion_93
	[FILTER_FLAG_TRADE_GOODS] = E.Media.Textures.FabricSilk,	-- Interface/ICONS/INV_Fabric_Silk_02
	[FILTER_FLAG_JUNK] = E.Media.Textures.GoldCoins,			-- Interface/ICONS/INV_Misc_Coin_01
	[FILTER_FLAG_QUEST] = E.Media.Textures.Scroll				-- Interface/ICONS/INV_Scroll_03
}

local itemSpellID = {
	-- Deposit Anima: Infuse (value) stored Anima into your covenant's Reservoir.
	[347555] = 3,
	[345706] = 5,
	[336327] = 35,
	[336456] = 250,

	-- Deliver Relic: Submit your findings to Archivist Roh-Suir to generate (value) Cataloged Research.
	[356931] = 6,
	[356933] = 1,
	[356934] = 8,
	[356935] = 16,
	[356936] = 48,
	[356937] = 26,
	[356938] = 100,
	[356939] = 150,
	[356940] = 300
}

B.IsEquipmentSlot = {
	INVTYPE_HEAD = true,
	INVTYPE_NECK = true,
	INVTYPE_SHOULDER = true,
	INVTYPE_BODY = true,
	INVTYPE_CHEST = true,
	INVTYPE_WAIST = true,
	INVTYPE_LEGS = true,
	INVTYPE_FEET = true,
	INVTYPE_WRIST = true,
	INVTYPE_HAND = true,
	INVTYPE_FINGER = true,
	INVTYPE_TRINKET = true,
	INVTYPE_WEAPON = true,
	INVTYPE_SHIELD = true,
	INVTYPE_RANGED = true,
	INVTYPE_CLOAK = true,
	INVTYPE_2HWEAPON = true,
	INVTYPE_TABARD = true,
	INVTYPE_ROBE = true,
	INVTYPE_WEAPONMAINHAND = true,
	INVTYPE_WEAPONOFFHAND = true,
	INVTYPE_HOLDABLE = true,
	INVTYPE_THROWN = true,
	INVTYPE_RANGEDRIGHT = true,
}

if E.Wrath then
	B.IsEquipmentSlot.INVTYPE_RELIC = true
end

local bagIDs, bankIDs = {0, 1, 2, 3, 4}, { -1 }
local bankOffset, maxBankSlots = (E.Classic or E.Wrath) and 4 or 5, E.Classic and 10 or E.Wrath and 11 or 12
local bankEvents = {'BAG_UPDATE_DELAYED', 'BAG_UPDATE', 'BAG_CLOSED', 'BANK_BAG_SLOT_FLAGS_UPDATED', 'PLAYERBANKBAGSLOTS_CHANGED', 'PLAYERBANKSLOTS_CHANGED'}
local bagEvents = {'BAG_UPDATE_DELAYED', 'BAG_UPDATE', 'BAG_CLOSED', 'ITEM_LOCK_CHANGED', 'BAG_SLOT_FLAGS_UPDATED', 'QUEST_ACCEPTED', 'QUEST_REMOVED'}
local presistentEvents = {
	PLAYERREAGENTBANKSLOTS_CHANGED = true,
	PLAYERBANKSLOTS_CHANGED = true,
	BAG_CONTAINER_UPDATE = true,
	BAG_UPDATE_DELAYED = true,
	BAG_UPDATE = true,
	BAG_CLOSED = true
}

for bankID = bankOffset + 1, maxBankSlots do
	tinsert(bankIDs, bankID)
end

if E.Retail then
	tinsert(bagEvents, 'BAG_CONTAINER_UPDATE')
	tinsert(bankEvents, 'BAG_CONTAINER_UPDATE')
	tinsert(bankEvents, 'PLAYERREAGENTBANKSLOTS_CHANGED')
	tinsert(bagIDs, REAGENT_CONTAINER)
else
	tinsert(bagIDs, KEYRING_CONTAINER)
end

function B:GetContainerFrame(arg)
	if arg == true then
		return B.BankFrame
	elseif type(arg) == 'number' then
		for _, bagID in next, B.BankFrame.BagIDs do
			if bagID == arg then
				return B.BankFrame
			end
		end
	end

	return B.BagFrame
end

function B:Tooltip_Show()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:SetOwner(self)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)

	if self.ttText2 then
		if self.ttText2desc then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(self.ttText2, self.ttText2desc, 1, 1, 1)
		else
			GameTooltip:AddLine(self.ttText2)
		end
	end

	if self.ttValue and self.ttValue() > 0 then
		GameTooltip:AddLine(E:FormatMoney(self.ttValue(), B.db.moneyFormat, not B.db.moneyCoins), 1, 1, 1)
	end

	GameTooltip:Show()
end

do
	local function DisableFrame(frame)
		if not frame then return end

		frame:UnregisterAllEvents()
		frame:SetScript('OnShow', nil)
		frame:SetScript('OnHide', nil)
		frame:SetParent(E.HiddenFrame)
		frame:ClearAllPoints()
		frame:Point('BOTTOM')
	end

	function B:DisableBlizzard()
		DisableFrame(_G.BankFrame)
		DisableFrame(_G.ContainerFrameCombinedBags)

		for i = 1, NUM_CONTAINER_FRAMES do
			_G['ContainerFrame'..i]:Kill()
		end
	end
end

do
	local MIN_REPEAT_CHARACTERS = 3
	function B:SearchUpdate()
		local search = self:GetText()
		if self.Instructions then
			self.Instructions:SetShown(search == '')
		end

		if #search > MIN_REPEAT_CHARACTERS then
			local repeating = true
			for i = 1, MIN_REPEAT_CHARACTERS, 1 do
				local x, y = 0-i, -1-i
				if strsub(search, x, x) ~= strsub(search, y, y) then
					repeating = false
					break
				end
			end

			if repeating then
				B:SearchClear()
				return
			end
		end

		SetItemSearch(search)
	end
end

function B:SearchRefresh()
	local text = B.BagFrame.editBox:GetText()

	B:SearchClear()

	B.BagFrame.editBox:SetText(text)
end

function B:SearchClear()
	B.BagFrame.editBox:SetText('')
	B.BagFrame.editBox:ClearFocus()

	B.BankFrame.editBox:SetText('')
	B.BankFrame.editBox:ClearFocus()

	SetItemSearch('')
end

function B:UpdateItemDisplay()
	if not E.private.bags.enable then return end

	for _, bagFrame in next, B.BagFrames do
		for _, bag in next, bagFrame.Bags do
			for _, slot in ipairs(bag) do
				slot.itemLevel:ClearAllPoints()
				slot.itemLevel:Point(B.db.itemLevelPosition, B.db.itemLevelxOffset, B.db.itemLevelyOffset)
				slot.itemLevel:FontTemplate(LSM:Fetch('font', B.db.itemLevelFont), B.db.itemLevelFontSize, B.db.itemLevelFontOutline)

				if B.db.itemLevelCustomColorEnable then
					slot.itemLevel:SetTextColor(B.db.itemLevelCustomColor.r, B.db.itemLevelCustomColor.g, B.db.itemLevelCustomColor.b)
				else
					local r, g, b = B:GetItemQualityColor(slot.rarity)
					slot.itemLevel:SetTextColor(r, g, b)
				end

				slot.bindType:FontTemplate(LSM:Fetch('font', B.db.itemLevelFont), B.db.itemLevelFontSize, B.db.itemLevelFontOutline)

				slot.centerText:FontTemplate(LSM:Fetch('font', B.db.itemInfoFont), B.db.itemInfoFontSize, B.db.itemInfoFontOutline)
				slot.centerText:SetTextColor(B.db.itemInfoColor.r, B.db.itemInfoColor.g, B.db.itemInfoColor.b)

				slot.Count:ClearAllPoints()
				slot.Count:Point(B.db.countPosition, B.db.countxOffset, B.db.countyOffset)
				slot.Count:FontTemplate(LSM:Fetch('font', B.db.countFont), B.db.countFontSize, B.db.countFontOutline)
			end
		end
	end
end

function B:UpdateAllSlots(frame)
	for _, bagID in next, frame.BagIDs do
		B:UpdateBagSlots(frame, bagID)
	end
end

function B:UpdateAllBagSlots(skip)
	if not E.private.bags.enable then return end

	for _, bagFrame in next, B.BagFrames do
		B:UpdateAllSlots(bagFrame)
	end

	if E.Retail and not skip then
		B:UpdateBagSlots(B.BankFrame, REAGENTBANK_CONTAINER)
	end
end

function B:IsItemEligibleForItemLevelDisplay(classID, subClassID, equipLoc, rarity)
	return (B.IsEquipmentSlot[equipLoc] or (classID == 3 and subClassID == 11)) and (rarity and rarity > 1)
end

function B:UpdateItemUpgradeIcon(slot)
	if not B.db.upgradeIcon or not slot.isEquipment then
		slot.UpgradeIcon:SetShown(false)
		slot:SetScript('OnUpdate', nil)
		return
	end

	local itemIsUpgrade, containerID, slotID = nil, slot.BagID, slot.SlotID

	-- We need to use the Pawn function here to show actually the icon, as Blizzard API doesnt seem to work.
	if _G.PawnIsContainerItemAnUpgrade then itemIsUpgrade = _G.PawnIsContainerItemAnUpgrade(containerID, slotID) end

	if itemIsUpgrade == nil then -- nil means not all the data was available to determine if this is an upgrade.
		slot.UpgradeIcon:SetShown(false)
		slot:SetScript('OnUpdate', B.UpgradeCheck_OnUpdate)
	else
		slot.UpgradeIcon:SetShown(itemIsUpgrade)
		slot:SetScript('OnUpdate', nil)
	end
end

local ITEM_UPGRADE_CHECK_TIME = 0.5
function B:UpgradeCheck_OnUpdate(elapsed)
	self.timeSinceUpgradeCheck = (self.timeSinceUpgradeCheck or 0) + elapsed
	if self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME then
		B:UpdateItemUpgradeIcon(self)
		self.timeSinceUpgradeCheck = 0
	end
end

function B:UpdateItemScrapIcon(slot)
	slot.ScrapIcon:SetShown(B.db.scrapIcon and C_Item_DoesItemExist(slot.itemLocation) and C_Item_CanScrapItem(slot.itemLocation))
end

function B:NewItemGlowSlotSwitch(slot, show)
	if slot and slot.newItemGlow then
		if show then
			slot.newItemGlow:Show()

			local bank = slot.bagFrame.isBank and B.BankFrame
			B:ShowItemGlow(bank or B.BagFrame, slot.newItemGlow)
		else
			slot.newItemGlow:Hide()

			-- also clear them on blizzard's side
			C_NewItems_RemoveNewItem(slot.BagID, slot.SlotID)
		end
	end
end

function B:BagFrameHidden(bagFrame)
	if not (bagFrame and bagFrame.BagIDs) then return end

	for _, bagID in next, bagFrame.BagIDs do
		local slotMax = B:GetContainerNumSlots(bagID)
		for slotID = 1, slotMax do
			B:NewItemGlowSlotSwitch(bagFrame.Bags[bagID][slotID])
		end
	end
end

function B:HideSlotItemGlow()
	B:NewItemGlowSlotSwitch(self)
end

function B:CheckSlotNewItem(slot, bagID, slotID)
	B:NewItemGlowSlotSwitch(slot, C_NewItems_IsNewItem(bagID, slotID))
end

function B:GetItemQualityColor(rarity)
	if rarity then
		return GetItemQualityColor(rarity)
	else
		return 1, 1, 1
	end
end

function B:UpdateSlotColors(slot, isQuestItem, questId, isActiveQuest)
	local questColors, r, g, b, a = B.db.qualityColors and (questId or isQuestItem) and B.QuestColors[not isActiveQuest and 'questStarter' or 'questItem']
	local qR, qG, qB = B:GetItemQualityColor(slot.rarity)

	if slot.itemLevel then
		if B.db.itemLevelCustomColorEnable then
			slot.itemLevel:SetTextColor(B.db.itemLevelCustomColor.r, B.db.itemLevelCustomColor.g, B.db.itemLevelCustomColor.b)
		else
			slot.itemLevel:SetTextColor(qR, qG, qB)
		end
	end

	if slot.bindType then
		slot.bindType:SetTextColor(qR, qG, qB)
	end

	if questColors then
		r, g, b, a = unpack(questColors)
	elseif B.db.qualityColors and (slot.rarity and slot.rarity > ITEMQUALITY_COMMON) then
		r, g, b = qR, qG, qB
	else
		local bag = slot.bagFrame.Bags[slot.BagID]
		local colors = bag and ((B.db.specialtyColors and B.ProfessionColors[bag.type]) or (B.db.showAssignedColor and B.AssignmentColors[bag.assigned]))
		if colors then
			r, g, b, a = colors.r, colors.g, colors.b, colors.a
		end
	end

	if not a then a = 1 end
	slot.forcedBorderColors = r and {r, g, b, a}
	if not r then r, g, b = unpack(E.media.bordercolor) end

	slot.newItemGlow:SetVertexColor(r, g, b, a)
	slot:SetBackdropBorderColor(r, g, b, a)

	if B.db.colorBackdrop then
		local fadeAlpha = B.db.transparent and E.media.backdropfadecolor[4]
		slot:SetBackdropColor(r, g, b, fadeAlpha or a)
	else
		slot:SetBackdropColor(unpack(B.db.transparent and E.media.backdropfadecolor or E.media.backdropcolor))
	end
end

function B:GetItemQuestInfo(itemLink, bindType, itemClassID)
	if bindType == 4 or itemClassID == LE_ITEM_CLASS_QUESTITEM then
		return true, true
	else
		E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
		E.ScanTooltip:SetHyperlink(itemLink)
		E.ScanTooltip:Show()

		local isQuestItem, isStarterItem
		for i = BIND_START, BIND_END do
			local line = _G['ElvUI_ScanTooltipTextLeft'..i]:GetText()

			if not line or line == '' then break end
			if not isQuestItem and line == _G.ITEM_BIND_QUEST then isQuestItem = true end
			if not isStarterItem and line == _G.ITEM_STARTS_QUEST then isStarterItem = true end
		end

		E.ScanTooltip:Hide()

		return isQuestItem or isStarterItem, not isStarterItem
	end
end

function B:UpdateItemLevel(slot)
	if slot.itemLink and B.db.itemLevel then
		local canShowItemLevel = B:IsItemEligibleForItemLevelDisplay(slot.itemClassID, slot.itemSubClassID, slot.itemEquipLoc, slot.rarity)
		local iLvl = canShowItemLevel and C_Item_DoesItemExist(slot.itemLocation) and C_Item_GetCurrentItemLevel(slot.itemLocation)
		local isShown = iLvl and iLvl >= B.db.itemLevelThreshold

		B.ItemLevelSlots[slot] = isShown or nil

		if isShown then
			slot.itemLevel:SetText(iLvl)
		end
	else
		B.ItemLevelSlots[slot] = nil
	end
end

function B:UpdateSlot(frame, bagID, slotID)
	local bag = frame.Bags[bagID]
	local slot = bag and bag[slotID]
	if not slot then return end

	local keyring = not E.Retail and (bagID == KEYRING_CONTAINER)
	local info = B:GetContainerItemInfo(bagID, slotID)

	slot.name, slot.spellID, slot.itemID, slot.rarity, slot.locked, slot.readable, slot.itemLink, slot.isBound = nil, nil, info.itemID, info.quality, info.isLocked, info.isReadable, info.hyperlink, info.isBound
	slot.isJunk = (slot.rarity and slot.rarity == ITEMQUALITY_POOR) and not info.hasNoValue
	slot.isEquipment, slot.junkDesaturate = nil, slot.isJunk and B.db.junkDesaturate
	slot.hasItem = (info.iconFileID and 1) or nil -- used for ShowInspectCursor

	SetItemButtonTexture(slot, (info.iconFileID ~= 4701874 and info.iconFileID) or E.Media.Textures.Invisible)
	SetItemButtonCount(slot, info.stackCount)
	SetItemButtonDesaturated(slot, slot.locked or slot.junkDesaturate)
	SetItemButtonQuality(slot, slot.rarity, slot.itemLink)

	slot.Count:SetTextColor(B.db.countFontColor.r, B.db.countFontColor.g, B.db.countFontColor.b)
	slot.itemLevel:SetText('')
	slot.bindType:SetText('')
	slot.centerText:SetText('')

	if keyring then
		slot.keyringTexture:SetShown(not info.iconFileID)
	end

	local isQuestItem, questId, isActiveQuest
	if slot.itemLink then
		local _, spellID = GetItemSpell(slot.itemLink)
		local name, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID, bindType = GetItemInfo(slot.itemLink)
		slot.name, slot.spellID, slot.isEquipment, slot.itemEquipLoc, slot.itemClassID, slot.itemSubClassID = name, spellID, B.IsEquipmentSlot[itemEquipLoc], itemEquipLoc, itemClassID, itemSubClassID

		if E.Retail then
			local questInfo = B:GetContainerItemQuestInfo(bagID, slotID)
			isQuestItem, questId, isActiveQuest = questInfo.isQuestItem, questInfo.questID, questInfo.isActive
		else
			slot.isBound = C_Item_IsBound(slot.itemLocation)
			isQuestItem, isActiveQuest = B:GetItemQuestInfo(slot.itemLink, bindType, itemClassID)
		end

		local BoE, BoU = bindType == 2, bindType == 3
		if B.db.showBindType and not slot.isBound and (BoE or BoU) then
			slot.bindType:SetText(BoE and L["BoE"] or L["BoU"])
		end

		local mult = E.Retail and B.db.itemInfo and itemSpellID[spellID]
		if mult then
			slot.centerText:SetText(mult * info.stackCount)
		end

		slot:RegisterEvent('INVENTORY_SEARCH_UPDATE')
		slot.searchOverlay:SetShown(info.isFiltered)
	else
		slot:UnregisterEvent('INVENTORY_SEARCH_UPDATE')
		slot.searchOverlay:SetShown(false)
	end

	if slot.spellID then
		B:UpdateCooldown(slot)
		slot:RegisterEvent('SPELL_UPDATE_COOLDOWN')
	else
		slot.Cooldown:Hide()
		slot:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
		SetItemButtonTextureVertexColor(slot, 1, 1, 1)
	end

	if E.Retail then
		if slot.ScrapIcon then B:UpdateItemScrapIcon(slot) end
		slot:UpdateItemContextMatching() -- Blizzards way to highlighting for Scrap, Rune Carving, Upgrade Items and whatever else.
	end

	B:UpdateItemLevel(slot)
	B:UpdateSlotColors(slot, isQuestItem, questId, isActiveQuest)

	if slot.questIcon then slot.questIcon:SetShown(B.db.questIcon and ((not E.Retail and isQuestItem or questId) and not isActiveQuest)) end
	if slot.JunkIcon then slot.JunkIcon:SetShown(slot.isJunk and B.db.junkIcon) end
	if slot.UpgradeIcon and E.Retail then B:UpdateItemUpgradeIcon(slot) end --Check if item is an upgrade and show/hide upgrade icon accordingly

	if B.db.newItemGlow then
		E:Delay(0.1, B.CheckSlotNewItem, B, slot, bagID, slotID)
	end

	if not frame.isBank then
		B.QuestSlots[slot] = questId or nil
	end

	if not slot.hasItem and not GameTooltip:IsForbidden() and GameTooltip:GetOwner() == slot then
		GameTooltip:Hide()
	end
end

function B:GetContainerNumSlots(bagID)
	return bagID == REAGENTBANK_CONTAINER and B.REAGENTBANK_SIZE or bagID == KEYRING_CONTAINER and GetKeyRingSize() or GetContainerNumSlots(bagID)
end

function B:UpdateBagButtons()
	local playerCombat = UnitAffectingCombat('player')
	B.BagFrame.bagsButton:SetEnabled(not playerCombat)
	B.BagFrame.bagsButton:GetNormalTexture():SetDesaturated(playerCombat)
end

function B:UpdateBagSlots(frame, bagID)
	local slotMax = B:GetContainerNumSlots(bagID)
	for slotID = 1, slotMax do
		B:UpdateSlot(frame, bagID, slotID)
	end
end

function B:SortingFadeBags(bagFrame, sortingSlots)
	if not (bagFrame and bagFrame.BagIDs) then return end
	bagFrame.sortingSlots = sortingSlots

	for _, bagID in next, bagFrame.BagIDs do
		local slotMax = B:GetContainerNumSlots(bagID)
		for slotID = 1, slotMax do
			bagFrame.Bags[bagID][slotID].searchOverlay:SetShown(true)
		end
	end
end

function B:Slot_OnEvent(event)
	if event == 'SPELL_UPDATE_COOLDOWN' then
		B:UpdateCooldown(self)
	elseif event == 'INVENTORY_SEARCH_UPDATE' then
		if self.BagID and self.SlotID then
			local info = B:GetContainerItemInfo(self.BagID, self.SlotID)
			self.searchOverlay:SetShown(info.isFiltered)
		end
	end
end

function B:Slot_OnEnter()
	B.HideSlotItemGlow(self)

	-- bag keybind support from actionbar module
	if not self.isReagent and E.private.actionbar.enable then
		AB:BindUpdate(self, 'BAG')
	end
end

function B:Slot_OnLeave() end

function B:Holder_OnReceiveDrag()
	PutItemInBag(self.isBank and self:GetInventorySlot() or self:GetID())
end

function B:Holder_OnDragStart()
	PickupBagFromSlot(self.isBank and self:GetInventorySlot() or self:GetID())
end

function B:Holder_OnClick(button)
	if self.BagID == BACKPACK_CONTAINER then
		B:BagItemAction(button, self, PutItemInBackpack)
	elseif self.BagID == KEYRING_CONTAINER then
		B:BagItemAction(button, self, PutKeyInKeyRing)
	elseif self.isBank then
		B:BagItemAction(button, self, PutItemInBag, self:GetInventorySlot())
	else
		B:BagItemAction(button, self, PutItemInBag, self:GetID())
	end
end

function B:Holder_OnEnter()
	if not self.bagFrame then return end

	B:SetSlotAlphaForBag(self.bagFrame, self.BagID)

	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

		if self.BagID == BACKPACK_CONTAINER then
			local kb = GetBindingKey('TOGGLEBACKPACK')
			GameTooltip:AddLine(kb and format('%s |cffffd200(%s)|r', _G.BACKPACK_TOOLTIP, kb) or _G.BACKPACK_TOOLTIP, 1, 1, 1)
		elseif self.BagID == BANK_CONTAINER then
			GameTooltip:AddLine(_G.BANK, 1, 1, 1)
		elseif self.BagID == KEYRING_CONTAINER then
			GameTooltip:AddLine(_G.KEYRING, 1, 1, 1)
		elseif self.bag.numSlots == 0 then
			GameTooltip:AddLine(self.BagID == REAGENT_CONTAINER and _G.EQUIP_CONTAINER_REAGENT or _G.EQUIP_CONTAINER, 1, 1, 1)
		elseif self.isBank then
			GameTooltip:SetInventoryItem('player', self:GetInventorySlot())
		else
			GameTooltip:SetInventoryItem('player', self:GetID())
		end

		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L["Shift + Left Click to Toggle Bag"], .8, .8, .8)

		if E.Retail or (self.BagID ~= BANK_CONTAINER and self.BagID ~= BACKPACK_CONTAINER and self.BagID ~= KEYRING_CONTAINER) then
			GameTooltip:AddLine(L["Right Click to Open Menu"], .8, .8, .8)
		end

		GameTooltip:Show()
	end
end

function B:Holder_OnLeave()
	if not self.bagFrame then return end

	B:ResetSlotAlphaForBags(self.bagFrame)

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function B:Cooldown_OnHide()
	self.start = nil
	self.duration = nil
end

function B:UpdateCooldown(slot)
	local start, duration, enabled = GetContainerItemCooldown(slot.BagID, slot.SlotID)
	if duration and duration > 0 and enabled == 0 then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4)
	else
		SetItemButtonTextureVertexColor(slot, 1, 1, 1)
	end

	local cd = slot.Cooldown
	if duration and duration > 0 and enabled == 1 then
		local newStart, newDuration = not cd.start or cd.start ~= start, not cd.duration or cd.duration ~= duration
		if newStart or newDuration then
			cd:SetCooldown(start, duration)

			cd.start = start
			cd.duration = duration
		end
	else
		cd:Hide()
	end
end

function B:SetSlotAlphaForBag(f, bag)
	for _, bagID in next, f.BagIDs do
		f.Bags[bagID]:SetAlpha(bagID == bag and 1 or .1)
	end
end

function B:ResetSlotAlphaForBags(f)
	for _, bagID in next, f.BagIDs do
		f.Bags[bagID]:SetAlpha(1)
	end
end

function B:REAGENTBANK_PURCHASED()
	B.BankFrame.reagentFrame.cover:Hide()
end

-- Look at ContainerFrameFilterDropDown_Initialize in FrameXML/ContainerFrame.lua
function B:AssignBagFlagMenu()
	local holder = B.AssignBagDropdown.holder
	local bagID = holder and holder.BagID
	if bagID and bagID ~= BANK_CONTAINER and not IsInventoryItemProfessionBag('player', holder:GetID()) then
		E:SetEasyMenuAnchor(E.EasyMenu, holder)
		EasyMenu((bagID == BACKPACK_CONTAINER or bagID == REAGENT_CONTAINER) and B.AssignMain or B.AssignMenu, E.EasyMenu, nil, nil, nil, 'MENU')
	end
end

function B:IsSortIgnored(bagID)
	if bagID == BANK_CONTAINER then
		return GetBankAutosortDisabled()
	elseif bagID == BACKPACK_CONTAINER then
		return GetBackpackAutosortDisabled()
	elseif bagID > NUM_BAG_SLOTS and E.Classic then
		return GetBankBagSlotFlag(bagID - NUM_BAG_SLOTS, FILTER_FLAG_IGNORE)
	else
		return GetBagSlotFlag(bagID, FILTER_FLAG_IGNORE)
	end
end

function B:GetFilterFlagInfo(bagID, isBank)
	for _, flag in next, B.GearFilters do
		if flag ~= FILTER_FLAG_IGNORE then
			local canAssign = bagID ~= BACKPACK_CONTAINER and bagID ~= BANK_CONTAINER and bagID ~= REAGENT_CONTAINER
			if canAssign and ((isBank and E.Classic and GetBankBagSlotFlag(bagID - NUM_BAG_SLOTS, flag)) or GetBagSlotFlag(bagID, flag)) then
				return flag, B.BAG_FILTER_ICONS[flag], B.AssignmentColors[flag]
			end
		end
	end
end

function B:SetFilterFlag(bagID, flag, value)
	B.AssignBagDropdown.holder = nil

	local isBank = bagID > NUM_BAG_SLOTS
	local canAssign = bagID ~= BACKPACK_CONTAINER and bagID ~= BANK_CONTAINER and bagID ~= REAGENT_CONTAINER
	return canAssign and ((isBank and E.Classic and SetBankBagSlotFlag(bagID - NUM_BAG_SLOTS, flag, value)) or SetBagSlotFlag(bagID, flag, value))
end

function B:GetBagAssignedInfo(holder, isBank)
	local active, icon, color = B:GetFilterFlagInfo(holder.BagID, isBank)

	if holder.filterIcon then
		holder.filterIcon:SetTexture(icon)
		holder.filterIcon:SetShown(active and B.db.showAssignedIcon)
	end

	if active and color then
		holder:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
		holder.forcedBorderColors = {color.r, color.g, color.b, color.a}

		return active
	else
		holder:SetBackdropBorderColor(unpack(E.media.bordercolor))
		holder.forcedBorderColors = nil
	end
end

function B:FilterIconShown(show)
	if self.FilterBackdrop then
		self.FilterBackdrop:SetShown(show)
	end
end

function B:CreateFilterIcon(parent)
	if parent.filterIcon then
		return parent.filterIcon
	end

	--Create the texture showing the assignment type
	local FilterBackdrop = CreateFrame('Frame', nil, parent)
	FilterBackdrop:Point('TOPLEFT', parent, 'TOPLEFT', E.Border, -E.Border)
	FilterBackdrop:SetTemplate()
	FilterBackdrop:Size(20, 20)

	parent.filterIcon = FilterBackdrop:CreateTexture(nil, 'OVERLAY')
	parent.filterIcon:SetTexture(E.Media.Textures.GreenPotion)
	parent.filterIcon:SetTexCoord(unpack(E.TexCoords))
	parent.filterIcon:SetInside()
	parent.filterIcon.FilterBackdrop = FilterBackdrop

	hooksecurefunc(parent.filterIcon, 'SetShown', B.FilterIconShown)
	parent.filterIcon:SetShown(false)
end

function B:Layout(isBank)
	if not E.private.bags.enable then return end

	local f = B:GetContainerFrame(isBank)
	if not f then return end

	local lastButton, lastRowButton, newBag
	local buttonSpacing = isBank and B.db.bankButtonSpacing or B.db.bagButtonSpacing
	local buttonSize = E:Scale(isBank and B.db.bankSize or B.db.bagSize)
	local containerWidth = ((isBank and B.db.bankWidth) or B.db.bagWidth)
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing))
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing
	local numContainerRows, numBags, numBagSlots = 0, 0, 0
	local bagSpacing = isBank and B.db.split.bankSpacing or B.db.split.bagSpacing
	local isSplit = B.db.split[isBank and 'bank' or 'player']
	local reverseSlots = B.db.reverseSlots

	f.totalSlots = 0
	f.holderFrame:SetWidth(holderWidth)

	if E.Retail and isBank then
		f.reagentFrame:SetWidth(holderWidth)
	end

	if isBank and not f.fullBank then
		f.fullBank = select(2, GetNumBankSlots())
		f.purchaseBagButton:SetShown(not f.fullBank)
	end

	for _, bagID in next, f.BagIDs do
		if isSplit then
			newBag = (bagID ~= BANK_CONTAINER or bagID ~= BACKPACK_CONTAINER) and B.db.split['bag'..bagID] or false
		end

		--Bag Slots
		local bag = f.Bags[bagID]
		local numSlots = B:GetContainerNumSlots(bagID)
		local bagShown = numSlots > 0 and B.db.shownBags['bag'..bagID]

		bag.numSlots = numSlots
		bag:SetShown(bagShown)

		if bagShown then
			for slotID, slot in ipairs(bag) do
				slot:SetShown(slotID <= numSlots)
			end

			for slotID = 1, numSlots do
				f.totalSlots = f.totalSlots + 1

				local slot = bag[slotID]
				slot:SetID(slotID)
				slot:SetSize(buttonSize, buttonSize)

				if slot.filterIcon then
					slot.filterIcon.FilterBackdrop:SetSize(buttonSize, buttonSize)
				end

				slot.JunkIcon:SetSize(buttonSize * 0.5, buttonSize * 0.5)

				if slot:GetPoint() then
					slot:ClearAllPoints()
				end

				if lastButton then
					local anchorPoint, relativePoint = (reverseSlots and 'BOTTOM' or 'TOP'), (reverseSlots and 'TOP' or 'BOTTOM')
					if isSplit and newBag and slotID == 1 then
						slot:Point(anchorPoint, lastRowButton, relativePoint, 0, reverseSlots and (buttonSpacing + bagSpacing) or -(buttonSpacing + bagSpacing))
						lastRowButton = slot
						numContainerRows = numContainerRows + 1
						numBags = numBags + 1
						numBagSlots = 0
					elseif isSplit and numBagSlots % numContainerColumns == 0 then
						slot:Point(anchorPoint, lastRowButton, relativePoint, 0, reverseSlots and buttonSpacing or -buttonSpacing)
						lastRowButton = slot
						numContainerRows = numContainerRows + 1
					elseif (not isSplit) and (f.totalSlots - 1) % numContainerColumns == 0 then
						slot:Point(anchorPoint, lastRowButton, relativePoint, 0, reverseSlots and buttonSpacing or -buttonSpacing)
						lastRowButton = slot
						numContainerRows = numContainerRows + 1
					else
						anchorPoint, relativePoint = (reverseSlots and 'RIGHT' or 'LEFT'), (reverseSlots and 'LEFT' or 'RIGHT')
						slot:Point(anchorPoint, lastButton, relativePoint, reverseSlots and -buttonSpacing or buttonSpacing, 0)
					end
				else
					local anchorPoint = reverseSlots and 'BOTTOMRIGHT' or 'TOPLEFT'
					slot:Point(anchorPoint, f.holderFrame, anchorPoint, 0, reverseSlots and f.bottomOffset - 8 or 0)
					lastRowButton = slot
					numContainerRows = numContainerRows + 1
				end

				lastButton = slot
				numBagSlots = numBagSlots + 1
			end
		end
	end

	if not isBank then
		local currencies = f.currencyButton
		if B.numTrackedTokens == 0 then
			if f.bottomOffset > 8 then
				f.bottomOffset = 8
			end
		else
			local currentRow = 1

			if E.Retail then
				local rowWidth = 0
				for i = 1, B.numTrackedTokens do
					local token = currencies[i]
					if not token then return end

					local tokenWidth = token.text:GetWidth() + 28
					rowWidth = rowWidth + tokenWidth
					if rowWidth > (B.db.bagWidth - (B.db.bagButtonSpacing * 4)) then
						currentRow = currentRow + 1
						rowWidth = tokenWidth
					end

					token:ClearAllPoints()

					if i == 1 then
						token:Point('TOPLEFT', currencies, 1, -3)
					elseif rowWidth == tokenWidth then
						token:Point('TOPLEFT', currencies, 1 , -3 -(24 * (currentRow - 1)))
					else
						token:Point('TOPLEFT', currencies, rowWidth - tokenWidth , -3 - (24 * (currentRow - 1)))
					end
				end
			else
				local c1, c2, c3 = unpack(currencies)
				if B.numTrackedTokens == 1 then
					c1:Point('BOTTOM', currencies, -c1.text:GetWidth() * 0.5, 3)
				elseif B.numTrackedTokens == 2 then
					c1:Point('BOTTOM', currencies, -c1.text:GetWidth() - (c1:GetWidth() * 3), 3)
					c2:Point('BOTTOMLEFT', currencies, 'BOTTOM', c2:GetWidth() * 3, 3)
				else
					c1:Point('BOTTOMLEFT', currencies, 3, 3)
					c2:Point('BOTTOM', currencies, -c2.text:GetWidth() / 3, 3)
					c3:Point('BOTTOMRIGHT', currencies, -c3.text:GetWidth() - (c3:GetWidth() * 0.5), 3)
				end
			end

			local height = 24 * currentRow
			currencies:Height(height)

			local offset = height + 8
			if f.bottomOffset ~= offset then
				f.bottomOffset = offset
			end
		end
	end

	if E.Retail and isBank and f.reagentFrame:IsShown() then
		if not IsReagentBankUnlocked() then
			f.reagentFrame.cover:Show()
			B:RegisterEvent('REAGENTBANK_PURCHASED')
		else
			f.reagentFrame.cover:Hide()
		end

		numContainerRows = 1

		local totalSlots, lastReagentRowButton = 0
		local bag = f.Bags[REAGENTBANK_CONTAINER]
		for slotID, slot in ipairs(bag) do
			totalSlots = totalSlots + 1

			slot:ClearAllPoints()
			slot:SetSize(buttonSize, buttonSize)

			local prevSlot = bag[slotID - 1]
			if prevSlot then
				if (totalSlots - 1) % numContainerColumns == 0 then
					slot:Point('TOP', lastReagentRowButton, 'BOTTOM', 0, -buttonSpacing)
					lastReagentRowButton = slot
					numContainerRows = numContainerRows + 1
				else
					slot:Point('LEFT', prevSlot, 'RIGHT', buttonSpacing, 0)
				end
			else
				slot:Point('TOPLEFT', f.reagentFrame, 'TOPLEFT')
				lastReagentRowButton = slot
			end
		end
	end

	local buttonsHeight = (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing)
	f:SetSize(containerWidth, buttonsHeight + f.topOffset + f.bottomOffset + (isSplit and (numBags * bagSpacing) or 0))
	f:SetFrameStrata(B.db.strata or 'HIGH')
end

function B:TotalSlotsChanged(bagFrame)
	local total = 0
	for _, bagID in next, bagFrame.BagIDs do
		total = total + B:GetContainerNumSlots(bagID)
	end

	return bagFrame.totalSlots ~= total
end

function B:PLAYER_AVG_ITEM_LEVEL_UPDATE()
	for slot in next, B.ItemLevelSlots do
		B:UpdateItemLevel(slot)
	end
end

function B:PLAYER_ENTERING_WORLD(event)
	B:UpdateLayout(B.BagFrame)
	B:UnregisterEvent(event)
end

function B:UpdateLayouts()
	B:Layout()
	B:Layout(true)
end

function B:UpdateLayout(frame)
	for index in next, frame.BagIDs do
		if B:SetBagAssignments(frame.ContainerHolder[index]) then
			break
		end
	end
end

function B:SetBagAssignments(holder, skip)
	if not holder then return true end

	local frame, bag = holder.frame, holder.bag
	holder:Size(frame.isBank and B.db.bankSize or B.db.bagSize)

	if holder.BagID == KEYRING_CONTAINER then
		bag.type = B.BagIndice.keyring
	elseif holder.BagID == REAGENT_CONTAINER then
		bag.type = B.BagIndice.reagent
	else
		bag.type = select(2, GetContainerNumFreeSlots(holder.BagID))
		bag.assigned = B:GetBagAssignedInfo(holder, frame.isBank)
	end

	if not skip and B:TotalSlotsChanged(frame) then
		B:Layout(frame.isBank)
	end

	if frame.isBank and frame:IsShown() then
		if holder.BagID ~= BANK_CONTAINER then
			BankFrameItemButton_Update(holder)
		end

		local containerID = holder.index - 1
		if containerID > GetNumBankSlots() then
			SetItemButtonTextureVertexColor(holder, 1, .1, .1)
			holder.tooltipText = _G.BANK_BAG_PURCHASE

			if not frame.notPurchased[containerID] then
				frame.notPurchased[containerID] = holder
			end
		else
			SetItemButtonTextureVertexColor(holder, 1, 1, 1)
			holder.tooltipText = ''
		end
	end
end

function B:UpdateDelayedContainer(frame)
	for bagID, container in next, frame.DelayedContainers do
		if bagID ~= BACKPACK_CONTAINER then
			B:SetBagAssignments(container)
		end

		local bag = frame.Bags[bagID]
		if bag and bag.needsUpdate then
			B:UpdateBagSlots(frame, bagID)
			bag.needsUpdate = nil
		end

		frame.DelayedContainers[bagID] = nil
	end
end

function B:DelayedContainer(bagFrame, event, bagID)
	local container = bagID and bagFrame.ContainerHolderByBagID[bagID]
	if container then
		bagFrame.DelayedContainers[bagID] = container

		if event == 'BAG_CLOSED' then -- let it call layout
			bagFrame.totalSlots = 0
		else
			bagFrame.Bags[bagID].needsUpdate = true
		end
	end
end

function B:OnEvent(event, ...)
	if event == 'PLAYERBANKBAGSLOTS_CHANGED' then
		local containerID, holder = next(self.notPurchased)
		if containerID then
			B:SetBagAssignments(holder, true)
			self.notPurchased[containerID] = nil
		end
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		local slotID = ...
		local index = (slotID <= NUM_BANKGENERIC_SLOTS) and BANK_CONTAINER or (slotID - NUM_BANKGENERIC_SLOTS)
		local default = index == BANK_CONTAINER
		local bagID = self.BagIDs[default and 1 or index+1]
		if not bagID then return end

		if self:IsShown() then -- when its shown we only want to update the default bank bags slot
			if default then -- the other bags are handled by BAG_UPDATE
				B:UpdateSlot(B.BankFrame, bagID, slotID)
			end
		else
			local bag = self.Bags[bagID]
			self.staleBags[bagID] = bag

			if default then
				bag.staleSlots[slotID] = true
			end
		end
	elseif event == 'BAG_CONTAINER_UPDATE' then
		B:UpdateContainerIcons()
	elseif event == 'BAG_UPDATE' or event == 'BAG_CLOSED' then
		if not self.isBank or self:IsShown() then
			local bagID = ...
			B:DelayedContainer(self, event, bagID)
		end
	elseif event == 'BAG_UPDATE_DELAYED' then
		B:UpdateDelayedContainer(self)
	elseif event == 'BANK_BAG_SLOT_FLAGS_UPDATED' or event == 'BAG_SLOT_FLAGS_UPDATED' then
		local id = ...+1 -- yes
		B:SetBagAssignments(self.ContainerHolder[id], true)
		B:UpdateBagSlots(self, self.BagIDs[id])
	elseif event == 'PLAYERREAGENTBANKSLOTS_CHANGED' then
		if self:IsShown() then
			B:UpdateSlot(self, REAGENTBANK_CONTAINER, ...)
		else
			local bag = self.Bags[REAGENTBANK_CONTAINER]
			self.staleBags[REAGENTBANK_CONTAINER] = bag
			bag.staleSlots[...] = true
		end
	elseif (event == 'QUEST_ACCEPTED' or event == 'QUEST_REMOVED') and self:IsShown() then
		for slot in next, B.QuestSlots do
			B:UpdateSlot(self, slot.BagID, slot.SlotID)
		end
	elseif event == 'ITEM_LOCK_CHANGED' then
		B:UpdateSlot(self, ...)
	end
end

function B:UpdateTokensIfVisible()
	if B.BagFrame:IsVisible() then
		B:UpdateTokens()
	end
end

function B:UpdateTokens()
	local bagFrame = B.BagFrame
	local currencies = bagFrame.currencyButton
	for _, button in ipairs(currencies) do
		button:Hide()
	end

	local numTokens = 0
	for i = 1, MAX_WATCHED_TOKENS do
		local info = B:GetBackpackCurrencyInfo(i)
		if not (info and info.name) then break end

		local button = currencies[i]
		button.currencyID = info.currencyTypesID
		button:Show()

		local icon = button.icon or button.Icon
		icon:SetTexture(info.iconFileID)

		if B.db.currencyFormat == 'ICON_TEXT' then
			button.text:SetText(info.name..': '..BreakUpLargeNumbers(info.quantity))
		elseif B.db.currencyFormat == 'ICON_TEXT_ABBR' then
			button.text:SetText(E:AbbreviateString(info.name)..': '..BreakUpLargeNumbers(info.quantity))
		elseif B.db.currencyFormat == 'ICON' then
			button.text:SetText(BreakUpLargeNumbers(info.quantity))
		end

		numTokens = numTokens + 1
	end

	if numTokens ~= B.numTrackedTokens then
		B.numTrackedTokens = numTokens
		B:Layout()
	end
end

function B:UpdateGoldText()
	B.BagFrame.goldText:SetShown(B.db.moneyFormat ~= 'HIDE')
	B.BagFrame.goldText:SetText(E:FormatMoney(GetMoney(), B.db.moneyFormat, not B.db.moneyCoins))
end

-- These items should not be destroyed/sold automatically
B.ExcludeGrays = E.Retail and {
	[3300] = "Rabbit's Foot",
	[3670] = "Large Slimy Bone",
	[6150] = "A Frayed Knot",
	[11406] = "Rotting Bear Carcass",
	[11944] = "Dark Iron Baby Booties",
	[25402] = "The Stoppable Force",
	[36812] = "Ground Gear",
	[62072] = "Robble's Wobbly Staff",
	[67410] = "Very Unlucky Rock",
	[190382] = "Warped Pocket Dimension",
} or { -- TBC and Classic
	[32888] = "The Relics of Terokk",
	[28664] = "Nitrin's Instructions",
}

-- Vendors to avoid selling to
B.ExcludeVendors = {
	['113831'] = "Auto-Hammer",
	['100995'] = "Auto-Hammer"
}

function B:GetGrays(vendor)
	local value = 0

	for bagID = 0, 4 do
		for slotID = 1, B:GetContainerNumSlots(bagID) do
			local info = B:GetContainerItemInfo(bagID, slotID)
			local itemLink = info.hyperlink
			if itemLink and not info.hasNoValue and not B.ExcludeGrays[info.itemID] then
				local _, _, rarity, _, _, _, _, _, _, _, itemPrice, classID, _, bindType = GetItemInfo(itemLink)

				if rarity and rarity == 0 -- grays :o
				and (classID ~= 12 or bindType ~= 4) -- Quest can be classID:12 or bindType:4
				and (not E.Retail or not C_TransmogCollection_GetItemInfo(itemLink) or C_TransmogCollection_PlayerHasTransmogByItemInfo(itemLink)) then -- skip transmogable items
					local stackCount = info.stackCount or 1
					local stackPrice = itemPrice * stackCount

					if vendor then
						tinsert(B.SellFrame.Info.itemList, {bagID, slotID, itemLink, stackCount, stackPrice})
					elseif stackPrice > 0 then
						value = value + stackPrice
					end
				end
			end
		end
	end

	return value
end

function B:GetGraysValue()
	return B:GetGrays()
end

function B:VendorGrays(delete)
	if B.SellFrame:IsShown() then return end

	if not delete and (not _G.MerchantFrame or not _G.MerchantFrame:IsShown()) then
		E:Print(L["You must be at a vendor."])
		return
	end

	local npcID = not delete and NP:UnitNPCID('npc')
	if B.ExcludeVendors[npcID] then return end

	B:GetGrays(true)

	local numItems = #B.SellFrame.Info.itemList
	if numItems < 1 then return end

	-- Resetting stuff
	B.SellFrame.Info.delete = delete or false
	B.SellFrame.Info.ProgressTimer = 0
	B.SellFrame.Info.SellInterval = 0.2
	B.SellFrame.Info.ProgressMax = numItems
	B.SellFrame.Info.goldGained = 0
	B.SellFrame.Info.itemsSold = 0

	B.SellFrame.statusbar:SetValue(0)
	B.SellFrame.statusbar:SetMinMaxValues(0, B.SellFrame.Info.ProgressMax)
	B.SellFrame.statusbar.ValueText:SetText('0 / '..B.SellFrame.Info.ProgressMax)

	if not delete then -- Time to sell
		B.SellFrame:Show()
	end
end

function B:VendorGrayCheck()
	local value = B:GetGraysValue()

	if value == 0 then
		E:Print(L["No gray items to delete."])
	elseif not _G.MerchantFrame:IsShown() and not E.Retail then
		E.PopupDialogs.DELETE_GRAYS.Money = value
		E:StaticPopup_Show('DELETE_GRAYS')
	else
		B:VendorGrays()
	end
end

function B:SetButtonTexture(button, texture)
	button:SetNormalTexture(texture)
	button:SetPushedTexture(texture)
	button:SetDisabledTexture(texture)

	local Normal, Pushed, Disabled = button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture()

	local left, right, top, bottom = unpack(E.TexCoords)
	Normal:SetTexCoord(left, right, top, bottom)
	Normal:SetInside()

	Pushed:SetTexCoord(left, right, top, bottom)
	Pushed:SetInside()

	Disabled:SetTexCoord(left, right, top, bottom)
	Disabled:SetInside()
	Disabled:SetDesaturated(true)
end

function B:BagItemAction(button, holder, func, id)
	local allowed = holder.BagID and (E.Retail or (holder.BagID ~= BANK_CONTAINER and holder.BagID ~= BACKPACK_CONTAINER and holder.BagID ~= KEYRING_CONTAINER))
	if allowed and button == 'RightButton' then
		B.AssignBagDropdown.holder = holder
		_G.ToggleDropDownMenu(1, nil, B.AssignBagDropdown, 'cursor')
	elseif CursorHasItem() then
		if func then func(id) end
	elseif IsShiftKeyDown() then
		B:ToggleBag(holder)
	end
end

function B:ToggleBag(holder)
	if not holder then return end

	local slotID = 'bag'..holder.BagID
	B.db.shownBags[slotID] = not B.db.shownBags[slotID]

	holder.shownIcon:SetTexture(B.db.shownBags[slotID] and _G.READY_CHECK_READY_TEXTURE or _G.READY_CHECK_NOT_READY_TEXTURE)

	B:Layout(holder.isBank)
end

function B:UpdateContainerIcons()
	if not B.BagFrame then return end

	-- this only executes for the main bag, the bank bag doesn't use this
	for bagID, holder in next, B.BagFrame.ContainerHolderByBagID do
		B:UpdateContainerIcon(holder, bagID)
	end
end

function B:UpdateContainerIcon(holder, bagID)
	if not holder or not bagID or bagID == BACKPACK_CONTAINER or bagID == KEYRING_CONTAINER then return end

	holder.icon:SetTexture(GetInventoryItemTexture('player', holder:GetID()) or 136511)
end

function B:UnregisterBagEvents(bagFrame)
	bagFrame:UnregisterAllEvents() -- Unregister to prevent unnecessary updates during sorting
end

function B:ConstructContainerFrame(name, isBank)
	local strata = B.db.strata or 'HIGH'

	local f = CreateFrame('Button', name, E.UIParent)
	f:SetTemplate('Transparent')
	f:SetFrameStrata(strata)
	B:SetupItemGlow(f)

	f.events = (isBank and bankEvents) or bagEvents
	f.DelayedContainers = {}
	f.firstOpen = true
	f:Hide()

	f.isBank = isBank
	f.topOffset = 50
	f.bottomOffset = 8
	f.BagIDs = (isBank and bankIDs) or bagIDs
	f.staleBags = {} -- used to keep track of bank items that need update on next open
	f.Bags = {}

	local mover = (isBank and _G.ElvUIBankMover) or _G.ElvUIBagMover
	if mover then
		f:Point(mover.POINT, mover)
		f.mover = mover
	end

	--Allow dragging the frame around
	f:SetMovable(true)
	f:RegisterForDrag('LeftButton', 'RightButton')
	f:RegisterForClicks('AnyUp')
	f:SetScript('OnEvent', B.OnEvent)
	f:SetScript('OnShow', B.ContainerOnShow)
	f:SetScript('OnHide', B.ContainerOnHide)
	f:SetScript('OnDragStart', function(frame) if IsShiftKeyDown() then frame:StartMoving() end end)
	f:SetScript('OnDragStop', function(frame) frame:StopMovingOrSizing() end)
	f:SetScript('OnClick', function(frame) if IsControlKeyDown() then B.PostBagMove(frame.mover) end end)

	f.closeButton = CreateFrame('Button', name..'CloseButton', f, 'UIPanelCloseButton')
	f.closeButton:Point('TOPRIGHT', 5, 5)

	f.helpButton = CreateFrame('Button', name..'HelpButton', f)
	f.helpButton:Point('RIGHT', f.closeButton, 'LEFT', 0, 0)
	f.helpButton:Size(16)
	B:SetButtonTexture(f.helpButton, E.Media.Textures.Help)
	f.helpButton:SetScript('OnLeave', GameTooltip_Hide)
	f.helpButton:SetScript('OnEnter', function(frame)
		if GameTooltip:IsForbidden() then return end

		GameTooltip:SetOwner(frame, 'ANCHOR_TOPLEFT', 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Hold Control + Right Click:"], L["Reset Position"], 1, 1, 1)
		GameTooltip:Show()
	end)

	Skins:HandleCloseButton(f.closeButton)

	f.holderFrame = CreateFrame('Frame', nil, f)
	f.holderFrame:Point('TOP', f, 'TOP', 0, -f.topOffset)
	f.holderFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8)

	f.ContainerHolder = CreateFrame('Button', name..'ContainerHolder', f)
	f.ContainerHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1)
	f.ContainerHolder:SetTemplate('Transparent')
	f.ContainerHolder:Hide()
	f.ContainerHolder.totalBags = #f.BagIDs
	f.ContainerHolderByBagID = {}

	for i, bagID in next, f.BagIDs do
		local bagNum = isBank and (bagID == BANK_CONTAINER and 0 or (bagID - bankOffset)) or (bagID - (E.Retail and 0 or 1))
		local holderName = bagID == BACKPACK_CONTAINER and 'ElvUIMainBagBackpack' or bagID == KEYRING_CONTAINER and 'ElvUIKeyRing' or format('ElvUI%sBag%d%s', isBank and 'Bank' or 'Main', bagNum, E.Retail and '' or 'Slot')
		local inherit = (E.Retail and not isBank and '') or isBank and 'BankItemButtonBagTemplate' or (bagID == BACKPACK_CONTAINER or bagID == KEYRING_CONTAINER) and (not E.Retail and 'ItemButtonTemplate,' or '')..'ItemAnimTemplate' or 'BagSlotButtonTemplate'

		local holder = CreateFrame((E.Retail and 'ItemButton' or 'CheckButton'), holderName, f.ContainerHolder, inherit)
		f.ContainerHolderByBagID[bagID] = holder
		f.ContainerHolder[i] = holder
		holder.name = holderName
		holder.isBank = isBank
		holder.bagFrame = f
		holder.UpdateTooltip = nil -- This is needed to stop constant updates. It will still get updated by OnEnter.

		holder:SetTemplate(B.db.transparent and 'Transparent', true)
		holder:StyleButton()

		holder:SetNormalTexture(E.ClearTexture)
		holder:SetPushedTexture(E.ClearTexture)
		if holder.SetCheckedTexture then
			holder:SetCheckedTexture(E.ClearTexture)
		end

		holder:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		holder:SetScript('OnEnter', B.Holder_OnEnter)
		holder:SetScript('OnLeave', B.Holder_OnLeave)
		holder:SetScript('OnClick', B.Holder_OnClick)

		if holder.animIcon then
			holder.animIcon:SetTexCoord(unpack(E.TexCoords))
		end

		holder.icon:SetTexCoord(unpack(E.TexCoords))
		holder.icon:SetTexture(bagID == KEYRING_CONTAINER and 134237 or E.Media.Textures.Backpack) -- Interface\ICONS\INV_Misc_Key_03
		holder.icon:SetInside()
		holder.IconBorder:SetAlpha(0)

		holder.shownIcon = holder:CreateTexture(nil, 'OVERLAY', nil, 1)
		holder.shownIcon:Size(16)
		holder.shownIcon:Point('BOTTOMLEFT', 1, 1)
		holder.shownIcon:SetTexture(B.db.shownBags['bag'..bagID] and _G.READY_CHECK_READY_TEXTURE or _G.READY_CHECK_NOT_READY_TEXTURE)

		B:CreateFilterIcon(holder)

		if bagID == BACKPACK_CONTAINER then
			holder:SetScript('OnReceiveDrag', PutItemInBackpack)
		elseif bagID == KEYRING_CONTAINER then
			holder:SetScript('OnReceiveDrag', PutKeyInKeyRing)
		else
			holder:RegisterForDrag('LeftButton')
			holder:SetScript('OnDragStart', B.Holder_OnDragStart)
			holder:SetScript('OnReceiveDrag', B.Holder_OnReceiveDrag)

			if isBank then
				holder:SetID(i == 1 and BANK_CONTAINER or (bagID - bankOffset))
				holder:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
				holder:SetScript('OnEvent', BankFrameItemButton_UpdateLocked)
			else
				holder:SetID(ContainerIDToInventoryID(bagID))

				B:UpdateContainerIcon(holder, bagID)
			end
		end

		if i == 1 then
			holder:Point('BOTTOMLEFT', f, 'TOPLEFT', 4, 5)
		else
			holder:Point('LEFT', f.ContainerHolder[i - 1], 'RIGHT', 4, 0)
		end

		if i == f.ContainerHolder.totalBags then
			f.ContainerHolder:Point('TOPRIGHT', holder, 4, 4)
		end

		local bagName = format('%sBag%d', name, bagNum)
		local bag = CreateFrame('Frame', bagName, f.holderFrame)
		bag.holder = holder
		bag.name = bagName
		bag:SetID(bagID)

		holder.BagID = bagID
		holder.bag = bag
		holder.frame = f
		holder.index = i

		f.Bags[bagID] = bag

		if bagID == BANK_CONTAINER then
			bag.staleSlots = {}
		end

		for slotID = 1, MAX_CONTAINER_ITEMS do
			bag[slotID] = B:ConstructContainerButton(f, bagID, slotID)
		end
	end

	f.stackButton = CreateFrame('Button', name..'StackButton', f.holderFrame)
	f.stackButton:Size(18)
	f.stackButton:SetTemplate()
	B:SetButtonTexture(f.stackButton, E.Media.Textures.Planks)
	f.stackButton:StyleButton(nil, true)
	f.stackButton:SetScript('OnEnter', B.Tooltip_Show)
	f.stackButton:SetScript('OnLeave', GameTooltip_Hide)

	--Sort Button
	f.sortButton = CreateFrame('Button', name..'SortButton', f)
	f.sortButton:Point('RIGHT', f.stackButton, 'LEFT', -5, 0)
	f.sortButton:Size(18)
	f.sortButton:SetTemplate()
	B:SetButtonTexture(f.sortButton, E.Media.Textures.PetBroom)
	f.sortButton:StyleButton(nil, true)
	f.sortButton.ttText = L["Sort Bags"]
	f.sortButton:SetScript('OnEnter', B.Tooltip_Show)
	f.sortButton:SetScript('OnLeave', GameTooltip_Hide)

	if isBank and B.db.disableBankSort or (not isBank and B.db.disableBagSort) then
		f.sortButton:Disable()
	end

	--Toggle Bags Button
	f.bagsButton = CreateFrame('Button', name..'BagsButton', f.holderFrame)
	f.bagsButton:Size(18)
	f.bagsButton:Point('RIGHT', f.sortButton, 'LEFT', -5, 0)
	f.bagsButton:SetTemplate()
	B:SetButtonTexture(f.bagsButton, E.Media.Textures.Backpack)
	f.bagsButton:StyleButton(nil, true)
	f.bagsButton.ttText = L["Toggle Bags"]
	f.bagsButton:SetScript('OnEnter', B.Tooltip_Show)
	f.bagsButton:SetScript('OnLeave', GameTooltip_Hide)

	--Search
	f.editBox = CreateFrame('EditBox', name..'EditBox', f, 'SearchBoxTemplate')
	f.editBox:CreateBackdrop()
	f.editBox:FontTemplate()
	f.editBox:Height(16)
	f.editBox.Left:SetTexture()
	f.editBox.Middle:SetTexture()
	f.editBox.Right:SetTexture()
	f.editBox:SetAutoFocus(false)
	f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2)
	f.editBox:SetScript('OnEditFocusGained', EditBox_HighlightText)
	f.editBox:HookScript('OnTextChanged', B.SearchUpdate)
	f.editBox:SetScript('OnEscapePressed', B.SearchClear)
	f.editBox.clearButton:HookScript('OnClick', B.SearchClear)

	if isBank then
		f.notPurchased = {}
		f.fullBank = select(2, GetNumBankSlots())

		--Bank Text
		f.bankText = f:CreateFontString(nil, 'OVERLAY')
		f.bankText:FontTemplate()
		f.bankText:Point('RIGHT', f.helpButton, 'LEFT', -5, -2)
		f.bankText:SetJustifyH('RIGHT')
		f.bankText:SetText(L["Bank"])

		if E.Retail then
			f.reagentFrame = CreateFrame('Frame', 'ElvUIReagentBankFrame', f)
			f.reagentFrame:Point('TOP', f, 'TOP', 0, -f.topOffset)
			f.reagentFrame:Point('BOTTOM', f, 'BOTTOM', 0, 8)
			f.reagentFrame:SetID(REAGENTBANK_CONTAINER)
			f.reagentFrame:Hide()

			local bag = {}
			for slotID = 1, B.REAGENTBANK_SIZE do
				bag[slotID] = B:ConstructContainerButton(f, REAGENTBANK_CONTAINER, slotID)
			end

			bag.numSlots = B.REAGENTBANK_SIZE
			bag.staleSlots = {}

			f.Bags[REAGENTBANK_CONTAINER] = bag
			f.reagentFrame.slots = bag

			f.reagentFrame.cover = CreateFrame('Button', nil, f.reagentFrame)
			f.reagentFrame.cover:SetAllPoints(f.reagentFrame)
			f.reagentFrame.cover:SetTemplate(nil, true)
			f.reagentFrame.cover:SetFrameLevel(f.reagentFrame:GetFrameLevel() + 10)

			f.reagentFrame.cover.purchaseButton = CreateFrame('Button', nil, f.reagentFrame.cover)
			f.reagentFrame.cover.purchaseButton:Height(20)
			f.reagentFrame.cover.purchaseButton:Width(150)
			f.reagentFrame.cover.purchaseButton:Point('CENTER', f.reagentFrame.cover, 'CENTER')
			Skins:HandleButton(f.reagentFrame.cover.purchaseButton)
			f.reagentFrame.cover.purchaseButton:SetFrameLevel(f.reagentFrame.cover.purchaseButton:GetFrameLevel() + 2)
			f.reagentFrame.cover.purchaseButton.text = f.reagentFrame.cover.purchaseButton:CreateFontString(nil, 'OVERLAY')
			f.reagentFrame.cover.purchaseButton.text:FontTemplate()
			f.reagentFrame.cover.purchaseButton.text:Point('CENTER')
			f.reagentFrame.cover.purchaseButton.text:SetJustifyH('CENTER')
			f.reagentFrame.cover.purchaseButton.text:SetText(L["Purchase"])
			f.reagentFrame.cover.purchaseButton:SetScript('OnClick', function()
				PlaySound(852) --IG_MAINMENU_OPTION
				StaticPopup_Show('CONFIRM_BUY_REAGENTBANK_TAB')
			end)

			f.reagentFrame.cover.purchaseText = f.reagentFrame.cover:CreateFontString(nil, 'OVERLAY')
			f.reagentFrame.cover.purchaseText:FontTemplate()
			f.reagentFrame.cover.purchaseText:Point('BOTTOM', f.reagentFrame.cover.purchaseButton, 'TOP', 0, 10)
			f.reagentFrame.cover.purchaseText:SetText(REAGENTBANK_PURCHASE_TEXT)

			f.reagentToggle = CreateFrame('Button', name..'ReagentButton', f)
			f.reagentToggle:Size(18)
			f.reagentToggle:SetTemplate()
			f.reagentToggle:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', 0, 3)
			B:SetButtonTexture(f.reagentToggle, 132854) -- Interface\ICONS\INV_Enchant_DustArcane
			f.reagentToggle:StyleButton(nil, true)
			f.reagentToggle.ttText = L["Show/Hide Reagents"]
			f.reagentToggle:SetScript('OnEnter', B.Tooltip_Show)
			f.reagentToggle:SetScript('OnLeave', GameTooltip_Hide)
			f.reagentToggle:SetScript('OnClick', function()
				PlaySound(841) --IG_CHARACTER_INFO_TAB
				B:ShowBankTab(f, f.holderFrame:IsShown())
			end)

			--Deposite Reagents Button
			f.depositButton = CreateFrame('Button', name..'DepositButton', f)
			f.depositButton:Size(18)
			f.depositButton:SetTemplate()
			f.depositButton:Point('RIGHT', f.reagentToggle, 'LEFT', -5, 0)
			B:SetButtonTexture(f.depositButton, 450905) -- Interface\ICONS\misc_arrowdown
			f.depositButton:StyleButton(nil, true)
			f.depositButton.ttText = L["Deposit Reagents"]
			f.depositButton:SetScript('OnEnter', B.Tooltip_Show)
			f.depositButton:SetScript('OnLeave', GameTooltip_Hide)
			f.depositButton:SetScript('OnClick', function()
				PlaySound(852) --IG_MAINMENU_OPTION
				DepositReagentBank()
			end)
		end

		-- Stack
		if E.Retail then
			f.stackButton:Point('RIGHT', f.depositButton, 'LEFT', -5, 0)
		else
			f.stackButton:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', -2, 4)
		end

		f.stackButton.ttText = L["Stack Items In Bank"]
		f.stackButton.ttText2 = L["Hold Shift:"]
		f.stackButton.ttText2desc = L["Stack Items To Bags"]
		f.stackButton:SetScript('OnEnter', B.Tooltip_Show)
		f.stackButton:SetScript('OnLeave', GameTooltip_Hide)
		f.stackButton:SetScript('OnClick', function()
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bank bags')()
			else
				B:CommandDecorator(B.Compress, 'bank')()
			end
		end)

		--Sort Button
		f.sortButton:SetScript('OnClick', function()
			if f.holderFrame:IsShown() then
				if E.Retail and B.db.useBlizzardCleanup then
					SortBankBags()
				else
					B:UnregisterBagEvents(f)

					if not f.sortingSlots then B:SortingFadeBags(f, true) end
					B:CommandDecorator(B.SortBags, 'bank')()
				end
			elseif E.Retail then
				SortReagentBankBags()
			end
		end)

		--Toggle Bags Button
		f.bagsButton:SetScript('OnClick', function()
			ToggleFrame(f.ContainerHolder)
			PlaySound(852) --IG_MAINMENU_OPTION
		end)

		f.purchaseBagButton = CreateFrame('Button', nil, f.holderFrame)
		f.purchaseBagButton:SetShown(not f.fullBank)
		f.purchaseBagButton:Size(18)
		f.purchaseBagButton:SetTemplate()
		f.purchaseBagButton:Point('RIGHT', f.bagsButton, 'LEFT', -5, 0)
		B:SetButtonTexture(f.purchaseBagButton, 133784) -- Interface\ICONS\INV_Misc_Coin_01
		f.purchaseBagButton:StyleButton(nil, true)
		f.purchaseBagButton.ttText = L["Purchase Bags"]
		f.purchaseBagButton:SetScript('OnEnter', B.Tooltip_Show)
		f.purchaseBagButton:SetScript('OnLeave', GameTooltip_Hide)
		f.purchaseBagButton:SetScript('OnClick', function()
			local _, full = GetNumBankSlots()
			if full then
				E:StaticPopup_Show('CANNOT_BUY_BANK_SLOT')
			else
				E:StaticPopup_Show('BUY_BANK_SLOT')
			end
		end)

		--Search
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', E.Border, 4)
	else
		--Gold Text
		f.goldText = f:CreateFontString(nil, 'OVERLAY')
		f.goldText:FontTemplate()
		f.goldText:Point('RIGHT', f.helpButton, 'LEFT', -10, -2)
		f.goldText:SetJustifyH('RIGHT')

		-- Stack/Transfer Button
		f.stackButton.ttText = L["Stack Items In Bags"]
		f.stackButton.ttText2 = L["Hold Shift:"]
		f.stackButton.ttText2desc = L["Stack Items To Bank"]
		f.stackButton:Point('BOTTOMRIGHT', f.holderFrame, 'TOPRIGHT', 0, 3)
		f.stackButton:SetScript('OnClick', function()
			B:UnregisterBagEvents(f)

			if not f.sortingSlots then f.sortingSlots = true end
			if IsShiftKeyDown() then
				B:CommandDecorator(B.Stack, 'bags bank')()
			else
				B:CommandDecorator(B.Compress, 'bags')()
			end
		end)

		--Sort Button
		f.sortButton:SetScript('OnClick', function()
			if E.Retail and B.db.useBlizzardCleanup then
				SortBags()
			else
				B:UnregisterBagEvents(f)

				if not f.sortingSlots then B:SortingFadeBags(f, true) end
				B:CommandDecorator(B.SortBags, 'bags')()
			end
		end)

		--Bags Button
		f.bagsButton:SetScript('OnClick', function() ToggleFrame(f.ContainerHolder) end)

		--Keyring Button
		if not E.Retail then
			f.keyButton = CreateFrame('Button', name..'KeyButton', f.holderFrame)
			f.keyButton:Size(18)
			f.keyButton:SetTemplate()
			f.keyButton:Point('RIGHT', f.bagsButton, 'LEFT', -5, 0)
			B:SetButtonTexture(f.keyButton, 134237) -- Interface\ICONS\INV_Misc_Key_03
			f.keyButton:StyleButton(nil, true)
			f.keyButton.ttText = BINDING_NAME_TOGGLEKEYRING
			f.keyButton:SetScript('OnEnter', B.Tooltip_Show)
			f.keyButton:SetScript('OnLeave', GameTooltip_Hide)
			f.keyButton:SetScript('OnClick', function() B:ToggleBag(f.ContainerHolderByBagID[KEYRING_CONTAINER]) end)
		end

		--Vendor Grays
		f.vendorGraysButton = CreateFrame('Button', nil, f.holderFrame)
		f.vendorGraysButton:Size(18)
		f.vendorGraysButton:SetTemplate()
		f.vendorGraysButton:Point('RIGHT', not E.Retail and f.keyButton or f.bagsButton, 'LEFT', -5, 0)
		B:SetButtonTexture(f.vendorGraysButton, 133784) -- Interface\ICONS\INV_Misc_Coin_01
		f.vendorGraysButton:StyleButton(nil, true)
		f.vendorGraysButton.ttText = not E.Retail and L["Vendor / Delete Grays"] or L["Vendor Grays"]
		f.vendorGraysButton.ttValue = B.GetGraysValue
		f.vendorGraysButton:SetScript('OnEnter', B.Tooltip_Show)
		f.vendorGraysButton:SetScript('OnLeave', GameTooltip_Hide)
		f.vendorGraysButton:SetScript('OnClick', B.VendorGrayCheck)

		--Search
		f.editBox:Point('BOTTOMLEFT', f.holderFrame, 'TOPLEFT', E.Border, 4)
		f.editBox:Point('RIGHT', f.vendorGraysButton, 'LEFT', -5, 0)

		if E.Retail or E.Wrath then
			--Currency
			f.currencyButton = CreateFrame('Frame', nil, f)
			f.currencyButton:Point('BOTTOM', 0, -6)
			f.currencyButton:Point('BOTTOMLEFT', f.holderFrame, 'BOTTOMLEFT', 0, -6)
			f.currencyButton:Point('BOTTOMRIGHT', f.holderFrame, 'BOTTOMRIGHT', 0, -6)
			f.currencyButton:Height(22)

			for i = 1, MAX_WATCHED_TOKENS do
				local currency = CreateFrame('Button', format('%sCurrencyButton%d', name, i), f.currencyButton, 'BackpackTokenTemplate')
				currency:Size(18)
				currency:SetTemplate()
				currency:SetID(i)

				local icon = (currency.icon or currency.Icon)
				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer('ARTWORK', 7)

				currency.text = currency:CreateFontString(nil, 'OVERLAY')
				currency.text:Point('LEFT', currency, 'RIGHT', 2, 0)
				currency.text:FontTemplate()
				currency:Hide()

				f.currencyButton[i] = currency
			end
		end
	end

	tinsert(_G.UISpecialFrames, name)
	tinsert(B.BagFrames, f)

	return f
end

function B:ConstructContainerButton(f, bagID, slotID)
	local bag = f.Bags[bagID]
	local isReagent = bagID == REAGENTBANK_CONTAINER
	local slotName = isReagent and ('ElvUIReagentBankFrameItem'..slotID) or (bag.name..'Slot'..slotID)
	local parent = isReagent and f.reagentFrame or bag
	local inherit = (bagID == BANK_CONTAINER or isReagent) and 'BankItemButtonGenericTemplate' or 'ContainerFrameItemButtonTemplate'

	local slot = CreateFrame(E.Retail and 'ItemButton' or 'CheckButton', slotName, parent, inherit)
	slot:StyleButton()
	slot:SetTemplate(B.db.transparent and 'Transparent', true)
	slot:SetScript('OnEvent', B.Slot_OnEvent)
	slot:HookScript('OnEnter', B.Slot_OnEnter)
	slot:HookScript('OnLeave', B.Slot_OnLeave)
	slot:SetID(slotID)

	slot:SetNormalTexture(E.ClearTexture)
	if slot.SetCheckedTexture then
		slot:SetCheckedTexture(E.ClearTexture)
	end

	slot.bagFrame = f
	slot.BagID = bagID
	slot.SlotID = slotID -- dont use `slotID` it taints since DF prepatch in ContainerFrameItemButtonMixin:GetBagID()
	slot.name = slotName

	local newItemTexture = _G[slotName..'NewItemTexture']
	if newItemTexture then
		newItemTexture:Hide()
	end

	slot.Count:ClearAllPoints()
	slot.Count:Point(B.db.countPosition, B.db.countxOffset, B.db.countyOffset)
	slot.Count:FontTemplate(LSM:Fetch('font', B.db.countFont), B.db.countFontSize, B.db.countFontOutline)

	if not slot.questIcon then
		slot.questIcon = _G[slotName..'IconQuestTexture'] or _G[slotName].IconQuestTexture
		slot.questIcon:SetTexture(E.Media.Textures.BagQuestIcon)
		slot.questIcon:SetTexCoord(0, 1, 0, 1)
		slot.questIcon:SetInside()
		slot.questIcon:Hide()
	end

	if slot.UpgradeIcon then
		slot.UpgradeIcon:SetTexture(E.Media.Textures.BagUpgradeIcon)
		slot.UpgradeIcon:SetTexCoord(0, 1, 0, 1)
		slot.UpgradeIcon:SetInside()
		slot.UpgradeIcon:Hide()
	end

	if not slot.JunkIcon then
		slot.JunkIcon = slot:CreateTexture(nil, 'OVERLAY', nil, 2)
		slot.JunkIcon:SetAtlas('bags-junkcoin', true)
		slot.JunkIcon:Point('TOPRIGHT', -1, -1)
		slot.JunkIcon:Hide()
	end

	if not slot.ScrapIcon then
		slot.ScrapIcon = slot:CreateTexture(nil, 'OVERLAY', nil, 2)
		slot.ScrapIcon:SetAtlas('bags-icon-scrappable')
		slot.ScrapIcon:Size(14, 12)
		slot.ScrapIcon:Point('TOPRIGHT', -1, -1)
		slot.ScrapIcon:Hide()
	end

	if bagID == KEYRING_CONTAINER then
		slot.keyringTexture = slot:CreateTexture(nil, 'BORDER')
		slot.keyringTexture:SetAlpha(0.5)
		slot.keyringTexture:SetInside(slot)
		slot.keyringTexture:SetTexture(130980) -- Interface\ContainerFrame\KeyRing-Bag-Icon
		slot.keyringTexture:SetTexCoord(unpack(E.TexCoords))
		slot.keyringTexture:SetDesaturated(true)
	end

	if isReagent then -- mimic ReagentBankItemButtonGenericTemplate
		slot.GetInventorySlot = ReagentButtonInventorySlot
		slot.SplitStack = B.ReagentSplitStack
		slot.isReagent = true
	end

	slot.searchOverlay:SetColorTexture(0, 0, 0, 0.8)

	slot.IconBorder:SetAlpha(0)
	slot.IconOverlay:SetInside()

	if slot.IconOverlay2 then
		slot.IconOverlay2:SetInside()
	end

	slot.Cooldown = _G[slotName..'Cooldown']
	slot.Cooldown:HookScript('OnHide', B.Cooldown_OnHide)
	E:RegisterCooldown(slot.Cooldown, 'bags')

	slot.icon:SetInside()
	slot.icon:SetTexCoord(unpack(E.TexCoords))

	slot.itemLevel = slot:CreateFontString(nil, 'ARTWORK', nil, 1)
	slot.itemLevel:Point(B.db.itemLevelPosition, B.db.itemLevelxOffset, B.db.itemLevelyOffset)
	slot.itemLevel:FontTemplate(LSM:Fetch('font', B.db.itemLevelFont), B.db.itemLevelFontSize, B.db.itemLevelFontOutline)

	slot.bindType = slot:CreateFontString(nil, 'ARTWORK', nil, 1)
	slot.bindType:Point('TOP', 0, -2)
	slot.bindType:FontTemplate(LSM:Fetch('font', B.db.itemLevelFont), B.db.itemLevelFontSize, B.db.itemLevelFontOutline)

	slot.centerText = slot:CreateFontString(nil, 'ARTWORK', nil, 1)
	slot.centerText:Point('CENTER', 0, 0)
	slot.centerText:FontTemplate(LSM:Fetch('font', B.db.itemInfoFont), B.db.itemInfoFontSize, B.db.itemInfoFontOutline)
	slot.centerText:SetTextColor(B.db.itemInfoColor.r, B.db.itemInfoColor.g, B.db.itemInfoColor.b)

	if slot.BattlepayItemTexture then
		slot.BattlepayItemTexture:Hide()
	end

	if not slot.itemLocation then
		slot.itemLocation = _G.ItemLocation:CreateFromBagAndSlot(bagID, slotID)
	end

	if not slot.newItemGlow then
		slot.newItemGlow = slot:CreateTexture(nil, 'OVERLAY')
		slot.newItemGlow:SetInside()
		slot.newItemGlow:SetTexture(E.Media.Textures.BagNewItemGlow)
		slot.newItemGlow:Hide()
		f.NewItemGlow.Fade:AddChild(slot.newItemGlow)
	end

	return slot
end

function B:ReagentSplitStack(split)
	SplitContainerItem(REAGENTBANK_CONTAINER, self.SlotID, split)
end

function B:ToggleBags(bagID)
	if E.private.bags.bagBar and bagID == KEYRING_CONTAINER then
		local closed = not B.BagFrame:IsShown()
		B.ShowKeyRing = closed or not B.ShowKeyRing

		B:Layout()

		if closed then
			B:OpenBags()
		end
	elseif bagID and B:GetContainerNumSlots(bagID) ~= 0 then
		if B.BagFrame:IsShown() then
			B:CloseBags()
		else
			B:OpenBags()
		end
	end
end

function B:ToggleBackpack()
	if IsOptionFrameOpen() then return end

	if IsBagOpen(0) then
		B:OpenBags()
	else
		B:CloseBags()
	end
end

function B:OpenAllBags(frame)
	local mail = frame == _G.MailFrame and frame:IsShown()
	local vendor = frame == _G.MerchantFrame and frame:IsShown()

	if (not mail and not vendor) or (mail and B.db.autoToggle.mail) or (vendor and B.db.autoToggle.vendor) then
		B:OpenBags()
	else
		B:CloseBags()
	end
end

function B:ToggleSortButtonState(isBank)
	local button = (isBank and B.BankFrame.sortButton) or B.BagFrame.sortButton
	button:SetEnabled(not B.db[isBank and 'disableBankSort' or 'disableBagSort'])
end

function B:ContainerOnShow()
	B:SetListeners(self)
end

function B:ContainerOnHide()
	B:ClearListeners(self)
	B:BagFrameHidden(self)
	B:HideItemGlow(self)

	if self.isBank then
		CloseBankFrame()
	else
		CloseBackpack()

		for i = 1, NUM_BAG_FRAMES do
			CloseBag(i)
		end
	end

	if B.db.clearSearchOnClose and (B.BankFrame.editBox:GetText() ~= '' or B.BagFrame.editBox:GetText() ~= '') then
		B:SearchClear()
	end
end

function B:SetListeners(frame)
	for _, event in next, frame.events do
		frame:RegisterEvent(event)
	end
end

function B:ClearListeners(frame)
	for _, event in next, frame.events do
		if not presistentEvents[event] then
			frame:UnregisterEvent(event)
		end
	end
end

function B:OpenBags()
	if B.BagFrame:IsShown() then return end

	if B.BagFrame.firstOpen then
		B:UpdateAllSlots(B.BagFrame)
		B.BagFrame.firstOpen = nil
	end

	B.BagFrame:Show()
	if E.Retail then B:UpdateTokensIfVisible() end

	PlaySound(IG_BACKPACK_OPEN)

	TT:GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:CloseBags()
	local bag, bank = B.BagFrame:IsShown(), B.BankFrame:IsShown()
	if bag or bank then
		if bag then B.BagFrame:Hide() end
		if bank then B.BankFrame:Hide() end

		PlaySound(IG_BACKPACK_CLOSE)
	end

	TT:GameTooltip_SetDefaultAnchor(GameTooltip)
end

function B:ShowBankTab(f, showReagent)
	local previousTab = _G.BankFrame.selectedTab

	if showReagent then
		_G.BankFrame.selectedTab = 2

		if E.Retail then
			f.reagentFrame:Show()
			f.sortButton:Point('RIGHT', f.depositButton, 'LEFT', -5, 0)
			f.bankText:SetText(L["Reagent Bank"])
		end

		f.holderFrame:Hide()
		f.editBox:Point('RIGHT', f.sortButton, 'LEFT', -5, 0)
	else
		_G.BankFrame.selectedTab = 1

		if E.Retail then
			f.reagentFrame:Hide()
			f.sortButton:Point('RIGHT', f.stackButton, 'LEFT', -5, 0)
			f.bankText:SetText(L["Bank"])
		end

		f.holderFrame:Show()
		f.editBox:Point('RIGHT', f.fullBank and f.bagsButton or f.purchaseBagButton, 'LEFT', -5, 0)
	end

	if previousTab ~= _G.BankFrame.selectedTab then
		B:Layout(true)
	else
		B:UpdateLayout(f)
	end
end

function B:ItemGlowOnFinished()
	if self:GetChange() == 1 then
		self:SetChange(0)
	else
		self:SetChange(1)
	end
end

function B:ShowItemGlow(bag, newItemGlow)
	if newItemGlow then
		newItemGlow:SetAlpha(1)
	end

	if not bag.NewItemGlow:IsPlaying() then
		bag.NewItemGlow:Play()
	end
end

function B:HideItemGlow(bag)
	if bag.NewItemGlow:IsPlaying() then
		bag.NewItemGlow:Stop()

		for _, itemGlow in next, bag.NewItemGlow.Fade.children do
			itemGlow:SetAlpha(0)
		end
	end
end

function B:SetupItemGlow(frame)
	frame.NewItemGlow = _G.CreateAnimationGroup(frame)
	frame.NewItemGlow:SetLooping(true)

	frame.NewItemGlow.Fade = frame.NewItemGlow:CreateAnimation('fade')
	frame.NewItemGlow.Fade:SetDuration(0.7)
	frame.NewItemGlow.Fade:SetChange(0)
	frame.NewItemGlow.Fade:SetEasing('in')
	frame.NewItemGlow.Fade:SetScript('OnFinished', B.ItemGlowOnFinished)
end

function B:OpenBank()
	B.BankFrame:Show()
	_G.BankFrame:Show()

	-- allow opening reagent tab directly by holding Shift
	-- keep this over update slots for bank slot assignments
	B:ShowBankTab(B.BankFrame, IsShiftKeyDown())

	if B.BankFrame.firstOpen then
		B:UpdateAllSlots(B.BankFrame)

		if E.Retail then
			B:UpdateBagSlots(B.BankFrame, REAGENTBANK_CONTAINER)
		end

		B.BankFrame.firstOpen = nil
	elseif next(B.BankFrame.staleBags) then
		for bagID, bag in next, B.BankFrame.staleBags do
			if bagID == REAGENTBANK_CONTAINER or bagID == BANK_CONTAINER then
				for slotID in next, bag.staleSlots do
					B:UpdateSlot(B.BankFrame, bagID, slotID)
					bag.staleSlots[slotID] = nil
				end
			else
				B:UpdateBagSlots(B.BankFrame, bagID)
			end

			B.BankFrame.staleBags[bagID] = nil
		end
	end

	if B.db.autoToggle.bank then
		B:OpenBags()
	end
end

function B:CloseBank()
	_G.BankFrame:Hide()

	B:CloseBags()
end

if C_Container then
	local function GetInitialContainerFrameOffsetX()
		if _G.EditModeUtil then
			return _G.EditModeUtil:GetRightActionBarWidth() + 10
		else
			return CONTAINER_OFFSET_X
		end
	end

	local function GetBags()
		if _G.ContainerFrameSettingsManager then
			return _G.ContainerFrameSettingsManager:GetBagsShown()
		else
			return _G.ContainerFrame1.bags
		end
	end

	local function GetContainerScale()
		local containerFrameOffsetX = GetInitialContainerFrameOffsetX()
		local xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
		local screenWidth = E.screenWidth
		local containerScale = 1
		local leftLimit = 0
		if _G.BankFrame:IsShown() then
			leftLimit = _G.BankFrame:GetRight() - 25
		end

		while containerScale > CONTAINER_SCALE do
			screenHeight = E.screenHeight / containerScale
			-- Adjust the start anchor for bags depending on the multibars
			xOffset = containerFrameOffsetX / containerScale
			yOffset = CONTAINER_OFFSET_Y / containerScale
			-- freeScreenHeight determines when to start a new column of bags
			freeScreenHeight = screenHeight - yOffset
			leftMostPoint = screenWidth - xOffset
			column = 1

			local frameHeight
			local framesInColumn = 0
			local forceScaleDecrease = false
			for _, frame in ipairs(GetBags()) do
				if type(frame) == 'string' then
					frame = _G[frame]
				end

				framesInColumn = framesInColumn + 1
				frameHeight = frame:GetHeight(true)
				if freeScreenHeight < frameHeight then
					if framesInColumn == 1 then -- If this is the only frame in the column and it doesn't fit, then scale must be reduced and the iteration restarted
						forceScaleDecrease = true
						break
					else -- Start a new column
						column = column + 1
						framesInColumn = 0 -- kind of a lie, at this point there's actually a single frame in the new column, but this simplifies where to increment.
						leftMostPoint = screenWidth - ( column * frame:GetWidth(true) * containerScale ) - xOffset
						freeScreenHeight = screenHeight - yOffset
					end
				end

				freeScreenHeight = freeScreenHeight - frameHeight
			end

			if forceScaleDecrease or (leftMostPoint < leftLimit) then
				containerScale = containerScale - 0.01
			else
				break
			end
		end

		return max(containerScale, CONTAINER_SCALE)
	end

	function B:UpdateContainerFrameAnchors()
		local containerScale = GetContainerScale()
		local screenHeight = E.screenHeight / containerScale

		-- Adjust the start anchor for bags depending on the multibars
		--local xOffset = GetInitialContainerFrameOffsetX() / containerScale
		local yOffset = CONTAINER_OFFSET_Y / containerScale
		-- freeScreenHeight determines when to start a new column of bags
		local freeScreenHeight = screenHeight - yOffset
		local previousBag, recentBagColumn

		for index, frame in ipairs(GetBags()) do
			if type(frame) == 'string' then
				frame = _G[frame]
			end

			frame:SetScale(containerScale)

			if index == 1 then -- First bag
				frame:SetPoint('BOTTOMRIGHT', _G.ElvUIBagMover, 'BOTTOMRIGHT', E.Spacing, -E.Border)
				recentBagColumn = frame
			elseif (freeScreenHeight < frame:GetHeight()) or (E.Retail and previousBag:IsCombinedBagContainer()) then -- Start a new column
				freeScreenHeight = screenHeight - yOffset
				frame:SetPoint('BOTTOMRIGHT', recentBagColumn, 'BOTTOMLEFT', -11, 0)
				recentBagColumn = frame
			else -- Anchor to the previous bag
				frame:SetPoint('BOTTOMRIGHT', previousBag, 'TOPRIGHT', 0, CONTAINER_SPACING)
			end

			previousBag = frame
			freeScreenHeight = freeScreenHeight - frame:GetHeight()
		end
	end
else
	function B:UpdateContainerFrameAnchors()
		local xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
		local screenWidth = E.screenWidth
		local bags = _G.ContainerFrame1.bags
		local containerScale = 1
		local leftLimit = 0

		if _G.BankFrame:IsShown() then
			leftLimit = _G.BankFrame:GetRight() - 25
		end

		while containerScale > CONTAINER_SCALE do
			screenHeight = E.screenHeight / containerScale
			-- Adjust the start anchor for bags depending on the multibars
			xOffset = CONTAINER_OFFSET_X / containerScale
			yOffset = CONTAINER_OFFSET_Y / containerScale
			-- freeScreenHeight determines when to start a new column of bags
			freeScreenHeight = screenHeight - yOffset
			leftMostPoint = screenWidth - xOffset
			column = 1

			for _, name in ipairs(bags) do
				local frame = _G[name]
				local frameHeight = frame:GetHeight()
				if freeScreenHeight < frameHeight then
					column = column + 1 -- Start a new column
					leftMostPoint = screenWidth - (column * CONTAINER_WIDTH * containerScale) - xOffset
					freeScreenHeight = screenHeight - yOffset
				end

				freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
			end

			if leftMostPoint < leftLimit then
				containerScale = containerScale - 0.01
			else
				break
			end
		end

		if containerScale < CONTAINER_SCALE then
			containerScale = CONTAINER_SCALE
		end

		screenHeight = E.screenHeight / containerScale
		-- Adjust the start anchor for bags depending on the multibars
		yOffset = CONTAINER_OFFSET_Y / containerScale
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset
		column = 0

		local bagsPerColumn = 0
		for index, name in ipairs(bags) do
			local frame = _G[name]
			local frameHeight = frame:GetHeight()

			frame:SetScale(1)

			if index == 1 then -- First bag
				frame:Point('BOTTOMRIGHT', _G.ElvUIBagMover, 'BOTTOMRIGHT', E.Spacing, -E.Border)
				bagsPerColumn = bagsPerColumn + 1
			elseif freeScreenHeight < frameHeight then -- Start a new column
				column = column + 1
				freeScreenHeight = screenHeight - yOffset
				frame:Point('BOTTOMRIGHT', bags[(index - bagsPerColumn) - (column > 1 and 1 or 0)], 'BOTTOMLEFT', -CONTAINER_SPACING, 0 )
				bagsPerColumn = 0
			else -- Anchor to the previous bag
				frame:Point('BOTTOMRIGHT', bags[index - 1], 'TOPRIGHT', 0, CONTAINER_SPACING)
				bagsPerColumn = bagsPerColumn + 1
			end

			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
		end
	end
end

function B:PostBagMove()
	if not E.private.bags.enable then return end

	local x, y = self:GetCenter() -- self refers to the mover (bag or bank)
	if not x or not y then return end

	if y > (E.screenHeight * 0.5) then
		self:SetText(self.textGrowDown)
		self.POINT = x > (E.screenWidth * 0.5) and 'TOPRIGHT' or 'TOPLEFT'
	else
		self:SetText(self.textGrowUp)
		self.POINT = x > (E.screenWidth * 0.5) and 'BOTTOMRIGHT' or 'BOTTOMLEFT'
	end

	local bagFrame = (self.name == 'ElvUIBankMover' and B.BankFrame) or B.BagFrame
	bagFrame:ClearAllPoints()
	bagFrame:Point(self.POINT, self)
end

function B:MERCHANT_CLOSED()
	B.SellFrame:Hide()

	wipe(B.SellFrame.Info.itemList)

	B.SellFrame.Info.delete = false
	B.SellFrame.Info.ProgressTimer = 0
	B.SellFrame.Info.SellInterval = B.db.vendorGrays.interval
	B.SellFrame.Info.ProgressMax = 0
	B.SellFrame.Info.goldGained = 0
	B.SellFrame.Info.itemsSold = 0
end

function B:ProgressQuickVendor()
	local item = B.SellFrame.Info.itemList[1]
	if not item then return nil, true end -- No more to sell

	local bagID, slotID, itemLink, stackCount, stackPrice = unpack(item)
	if B.db.vendorGrays.details and itemLink then
		E:Print(format('%s|cFF00DDDDx%d|r %s', itemLink, stackCount, E:FormatMoney(stackPrice, B.db.moneyFormat, not B.db.moneyCoins)))
	end

	UseContainerItem(bagID, slotID)
	tremove(B.SellFrame.Info.itemList, 1)

	return stackPrice
end

function B:VendorGrays_OnUpdate(elapsed)
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.ProgressTimer - elapsed
	if B.SellFrame.Info.ProgressTimer > 0 then return end
	B.SellFrame.Info.ProgressTimer = B.SellFrame.Info.SellInterval

	local goldGained, lastItem = B:ProgressQuickVendor()
	if goldGained then
		B.SellFrame.Info.goldGained = B.SellFrame.Info.goldGained + goldGained
		B.SellFrame.Info.itemsSold = B.SellFrame.Info.itemsSold + 1
		B.SellFrame.statusbar:SetValue(B.SellFrame.Info.itemsSold)
		B.SellFrame.statusbar.ValueText:SetText(B.SellFrame.Info.itemsSold..' / '..B.SellFrame.Info.ProgressMax)
	elseif lastItem then
		B.SellFrame:Hide()

		if not E.Retail and B.SellFrame.Info.goldGained > 0 then
			E:Print((L["Vendored gray items for: %s"]):format(E:FormatMoney(B.SellFrame.Info.goldGained, B.db.moneyFormat, not B.db.moneyCoins)))
		end
	end
end

function B:CreateSellFrame()
	B.SellFrame = CreateFrame('Frame', 'ElvUIVendorGraysFrame', E.UIParent)
	B.SellFrame:Size(200,40)
	B.SellFrame:Point('CENTER', E.UIParent)
	B.SellFrame:CreateBackdrop('Transparent')
	B.SellFrame:SetAlpha(B.db.vendorGrays.progressBar and 1 or 0)

	B.SellFrame.title = B.SellFrame:CreateFontString(nil, 'OVERLAY')
	B.SellFrame.title:FontTemplate(nil, 12, 'OUTLINE')
	B.SellFrame.title:Point('TOP', B.SellFrame, 'TOP', 0, -2)
	B.SellFrame.title:SetText(L["Vendoring Grays"])

	B.SellFrame.statusbar = CreateFrame('StatusBar', 'ElvUIVendorGraysFrameStatusbar', B.SellFrame)
	B.SellFrame.statusbar:Size(180, 16)
	B.SellFrame.statusbar:Point('BOTTOM', B.SellFrame, 'BOTTOM', 0, 4)
	B.SellFrame.statusbar:SetStatusBarTexture(E.media.normTex)
	B.SellFrame.statusbar:SetStatusBarColor(1, 0, 0)
	B.SellFrame.statusbar:CreateBackdrop('Transparent')

	B.SellFrame.statusbar.anim = _G.CreateAnimationGroup(B.SellFrame.statusbar)
	B.SellFrame.statusbar.anim.progress = B.SellFrame.statusbar.anim:CreateAnimation('Progress')
	B.SellFrame.statusbar.anim.progress:SetEasing('Out')
	B.SellFrame.statusbar.anim.progress:SetDuration(.3)

	B.SellFrame.statusbar.ValueText = B.SellFrame.statusbar:CreateFontString(nil, 'OVERLAY')
	B.SellFrame.statusbar.ValueText:FontTemplate(nil, 12, 'OUTLINE')
	B.SellFrame.statusbar.ValueText:Point('CENTER', B.SellFrame.statusbar)
	B.SellFrame.statusbar.ValueText:SetText('0 / 0 ( 0s )')

	B.SellFrame.Info = {
		delete = false,
		ProgressTimer = 0,
		SellInterval = B.db.vendorGrays.interval,
		ProgressMax = 0,
		goldGained = 0,
		itemsSold = 0,
		itemList = {},
	}

	B.SellFrame:SetScript('OnUpdate', B.VendorGrays_OnUpdate)
	B.SellFrame:Hide()
end

function B:UpdateSellFrameSettings()
	if not B.SellFrame or not B.SellFrame.Info then return end

	B.SellFrame.Info.SellInterval = B.db.vendorGrays.interval
	B.SellFrame:SetAlpha(B.db.vendorGrays.progressBar and 1 or 0)
end

B.BagIndice = {
	quiver = 0x1,
	ammoPouch = 0x2,
	soulBag = 0x4,
	leatherworking = 0x8,
	inscription = 0x10,
	herbs = 0x20,
	enchanting = 0x40,
	engineering = 0x80,
	keyring = 0x100,
	gems = 0x200,
	mining = 0x400,
	fishing = 0x8000,
	cooking = 0x10000,
	equipment = FILTER_FLAG_EQUIPMENT,
	consumables = FILTER_FLAG_CONSUMABLES,
	tradegoods = FILTER_FLAG_TRADE_GOODS,
	quest = FILTER_FLAG_QUEST,
	junk = FILTER_FLAG_JUNK,
	reagent = 5, -- should be safe, keep this static
}

B.QuestKeys = {
	questStarter = 'questStarter',
	questItem = 'questItem',
}

B.AutoToggleEvents = {
	guildBank = { GUILDBANKFRAME_OPENED = 'OpenBags', GUILDBANKFRAME_CLOSED = 'CloseBags' },
	auctionHouse = { AUCTION_HOUSE_SHOW = 'OpenBags', AUCTION_HOUSE_CLOSED = 'CloseBags' },
	professions = { TRADE_SKILL_SHOW = 'OpenBags', TRADE_SKILL_CLOSE = 'CloseBags' },
	trade = { TRADE_SHOW = 'OpenBags', TRADE_CLOSED = 'CloseBags' },
}

if E.Retail then
	B.AutoToggleEvents.soulBind = { SOULBIND_FORGE_INTERACTION_STARTED = 'OpenBags', SOULBIND_FORGE_INTERACTION_ENDED = 'CloseBags' }
end

function B:AutoToggle()
	for option, eventTable in next, B.AutoToggleEvents do
		for event, func in next, eventTable do
			if B.db.autoToggle[option] then
				B:RegisterEvent(event, func)
			else
				B:UnregisterEvent(event)
			end
		end
	end
end

function B:UpdateBagColors(table, indice, r, g, b)
	local colorTable
	if table == 'items' then
		colorTable = B.QuestColors[B.QuestKeys[indice]]
	else
		if table == 'profession' then table = 'ProfessionColors' end
		if table == 'assignment' then table = 'AssignmentColors' end
		colorTable = B[table][B.BagIndice[indice]]
	end

	colorTable.r, colorTable.g, colorTable.b = r, g, b
end

function B:GetBindLines()
	local c = GetCVarBool('colorblindmode')
	return c and 3 or 2, c and 5 or 4
end

function B:UpdateBindLines(_, cvar)
	if cvar == 'USE_COLORBLIND_MODE' then
		BIND_START, BIND_END = B:GetBindLines()
	end
end

function B:Initialize()
	B.db = E.db.bags

	BIND_START, BIND_END = B:GetBindLines()

	--Bag Assignment Dropdown Menu (also used by BagBar)
	B.AssignBagDropdown = CreateFrame('Frame', 'ElvUIAssignBagDropdown', E.UIParent, 'UIDropDownMenuTemplate')
	B.AssignBagDropdown:SetClampedToScreen(true)
	B.AssignBagDropdown:SetID(1)
	B.AssignBagDropdown:Hide()

	_G.UIDropDownMenu_Initialize(B.AssignBagDropdown, B.AssignBagFlagMenu, 'MENU')

	B.AssignmentColors = {
		[0] = { r = .99, g = .23, b = .21 }, -- fallback
		[FILTER_FLAG_EQUIPMENT] = E:GetColorTable(B.db.colors.assignment.equipment),
		[FILTER_FLAG_CONSUMABLES] = E:GetColorTable(B.db.colors.assignment.consumables),
		[FILTER_FLAG_TRADE_GOODS] = E:GetColorTable(B.db.colors.assignment.tradegoods),
		[FILTER_FLAG_QUEST] = E:GetColorTable(B.db.colors.items.questItem),
		[FILTER_FLAG_JUNK] = E:GetColorTable(B.db.colors.assignment.junk),
	}

	local FILTER_ASSIGN = { text = BAG_FILTER_ASSIGN_TO, isTitle = true, notCheckable = true }
	local FILTER_CLEANUP = { text = BAG_FILTER_CLEANUP, isTitle = true, notCheckable = true }
	local FILTER_IGNORE = { text = BAG_FILTER_IGNORE,
		checked = function()
			local holder = B.AssignBagDropdown.holder
			if holder then
				return B:IsSortIgnored(holder.BagID)
			end
		end,
		func = function(_, _, _, value)
			local holder = B.AssignBagDropdown.holder
			if holder then
				if holder.BagID == BANK_CONTAINER then
					SetBankAutosortDisabled(not value)
				elseif holder.BagID == BACKPACK_CONTAINER then
					SetBackpackAutosortDisabled(not value)
				elseif holder.BagID > NUM_BAG_SLOTS and E.Classic then
					SetBankBagSlotFlag(holder.BagID - NUM_BAG_SLOTS, FILTER_FLAG_IGNORE, not value)
				else
					SetBagSlotFlag(holder.BagID, FILTER_FLAG_IGNORE, not value)
				end

				B.AssignBagDropdown.holder = nil
			end
		end
	}

	B.AssignMain = { FILTER_CLEANUP, FILTER_IGNORE }
	B.AssignMenu = { FILTER_ASSIGN, FILTER_CLEANUP, FILTER_IGNORE }

	for i, flag in next, B.GearFilters do
		if i ~= FILTER_FLAG_IGNORE then
			tinsert(B.AssignMenu, i, {
				text = BAG_FILTER_LABELS[flag],
				checked = function()
					local holder = B.AssignBagDropdown.holder
					if holder then
						return B:GetFilterFlagInfo(holder.BagID, holder.isBank) == flag
					end
				end,
				func = function(_, _, _, value)
					local holder = B.AssignBagDropdown.holder
					if holder then
						return B:SetFilterFlag(holder.BagID, flag, not value)
					end
				end
			})
		end
	end

	B.ProfessionColors = {
		[0x1]		= E:GetColorTable(B.db.colors.profession.quiver),
		[0x2]		= E:GetColorTable(B.db.colors.profession.ammoPouch),
		[0x4]		= E:GetColorTable(B.db.colors.profession.soulBag),
		[0x8]		= E:GetColorTable(B.db.colors.profession.leatherworking),
		[0x10]		= E:GetColorTable(B.db.colors.profession.inscription),
		[0x20]		= E:GetColorTable(B.db.colors.profession.herbs),
		[0x40]		= E:GetColorTable(B.db.colors.profession.enchanting),
		[0x80]		= E:GetColorTable(B.db.colors.profession.engineering),
		[0x100]		= E:GetColorTable(B.db.colors.profession.keyring),
		[0x200]		= E:GetColorTable(B.db.colors.profession.gems),
		[0x400]		= E:GetColorTable(B.db.colors.profession.mining),
		[0x8000]	= E:GetColorTable(B.db.colors.profession.fishing),
		[0x10000]	= E:GetColorTable(B.db.colors.profession.cooking),
	}

	if E.Retail then
		B.ProfessionColors[B.BagIndice.reagent] = E:GetColorTable(B.db.colors.profession.reagent)
	end

	B.QuestColors = {
		questStarter = E:GetColorTable(B.db.colors.items.questStarter),
		questItem = E:GetColorTable(B.db.colors.items.questItem),
	}

	B:LoadBagBar()

	--Creating vendor grays frame
	B:CreateSellFrame()
	B:RegisterEvent('MERCHANT_CLOSED')

	--Bag Mover (We want it created even if Bags module is disabled, so we can use it for default bags too)
	local BagFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	BagFrameHolder:Width(200)
	BagFrameHolder:Height(22)
	BagFrameHolder:SetFrameLevel(BagFrameHolder:GetFrameLevel() + 400)

	if not E.private.bags.enable then
		-- Set a different default anchor
		BagFrameHolder:Point('BOTTOMRIGHT', _G.RightChatPanel, 'BOTTOMRIGHT', -(E.Border*2), 22 + E.Border*4 - E.Spacing*2)
		E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bags"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')
		CONTAINER_SPACING = E.private.skins.blizzard.enable and E.private.skins.blizzard.bags and (E.Border*2) or 0
		B:SecureHook('UpdateContainerFrameAnchors')
		return
	end

	B.Initialized = true
	B.BagFrames = {}
	B.REAGENTBANK_SIZE = 98 -- numRow (7) * numColumn (7) * numSubColumn (2) = size = 98

	--Bag Mover: Set default anchor point and create mover
	BagFrameHolder:Point('BOTTOMRIGHT', _G.RightChatPanel, 'BOTTOMRIGHT', 0, 22 + E.Border*4 - E.Spacing*2)
	E:CreateMover(BagFrameHolder, 'ElvUIBagMover', L["Bags (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Bank Mover
	local BankFrameHolder = CreateFrame('Frame', nil, E.UIParent)
	BankFrameHolder:Width(200)
	BankFrameHolder:Height(22)
	BankFrameHolder:Point('BOTTOMLEFT', _G.LeftChatPanel, 'BOTTOMLEFT', 0, 22 + E.Border*4 - E.Spacing*2)
	BankFrameHolder:SetFrameLevel(BankFrameHolder:GetFrameLevel() + 400)
	E:CreateMover(BankFrameHolder, 'ElvUIBankMover', L["Bank (Grow Up)"], nil, nil, B.PostBagMove, nil, nil, 'bags,general')

	--Set some variables on movers
	_G.ElvUIBagMover.textGrowUp = L["Bags (Grow Up)"]
	_G.ElvUIBagMover.textGrowDown = L["Bags (Grow Down)"]
	_G.ElvUIBagMover.POINT = 'BOTTOM'
	_G.ElvUIBankMover.textGrowUp = L["Bank (Grow Up)"]
	_G.ElvUIBankMover.textGrowDown = L["Bank (Grow Down)"]
	_G.ElvUIBankMover.POINT = 'BOTTOM'

	--Create Containers
	B.BagFrame = B:ConstructContainerFrame('ElvUI_ContainerFrame')
	B.BankFrame = B:ConstructContainerFrame('ElvUI_BankContainerFrame', true)

	if E.Wrath then
		B:SecureHook('BackpackTokenFrame_Update', 'UpdateTokens')
	elseif E.Retail then
		B:SecureHook(_G.BackpackTokenFrame, 'Update', 'UpdateTokensIfVisible')
		B:SecureHook(_G.BackpackTokenFrame, 'UpdateIfVisible', 'UpdateTokensIfVisible')
		B:SecureHook(_G.TokenFramePopup.BackpackCheckBox, 'OnClick', 'UpdateTokensIfVisible')
	end

	if E.Retail then
		B:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
		B.BankFrame:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED') -- let reagent collect data for next open
	end

	B:SecureHook('OpenAllBags')
	B:SecureHook('CloseAllBags', 'CloseBags')
	B:SecureHook('ToggleBag', 'ToggleBags')
	B:SecureHook('ToggleAllBags', 'ToggleBackpack')
	B:SecureHook('ToggleBackpack')

	B:DisableBlizzard()
	B:UpdateGoldText()

	B:RegisterEvent('PLAYER_ENTERING_WORLD')
	B:RegisterEvent('PLAYER_MONEY', 'UpdateGoldText')
	B:RegisterEvent('PLAYER_TRADE_MONEY', 'UpdateGoldText')
	B:RegisterEvent('TRADE_MONEY_CHANGED', 'UpdateGoldText')
	B:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateBagButtons')
	B:RegisterEvent('PLAYER_REGEN_DISABLED', 'UpdateBagButtons')
	B:RegisterEvent('BANKFRAME_OPENED', 'OpenBank')
	B:RegisterEvent('BANKFRAME_CLOSED', 'CloseBank')
	B:RegisterEvent('CVAR_UPDATE', 'UpdateBindLines')

	B:AutoToggle()

	--Enable/Disable 'Loot to Leftmost Bag'
	SetInsertItemsLeftToRight(B.db.reverseLoot)
end

E:RegisterModule(B:GetName())
