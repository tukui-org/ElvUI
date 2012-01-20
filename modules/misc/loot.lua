local E, L, DF = unpack(select(2, ...)); --Engine
local M = E:GetModule('Misc');

--Credit Haste
local lootFrame, lootFrameHolder
local iconSize = 30;

local sq, ss, sn
local OnEnter = function(self)
	local slot = self:GetID()
	if(LootSlotIsItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	
	LootFrame.selectedSlot = self:GetID()
	self.drop:Show()
	self.drop:SetVertexColor(1, 1, 0)
end

local OnLeave = function(self)
	if self.quality and (self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	else
		self.drop:Hide()
	end
	
	GameTooltip:Hide()
	ResetCursor()
end

local OnClick = function(self)
	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		ss = self:GetID()
		sq = self.quality
		sn = self.name:GetText()
		LootSlot(ss)
	end
end

local OnUpdate = function(self)
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function anchorSlots(self)
	local iconsize = iconSize
	local shownSlots = 0
	for i=1, #self.slots do
		local frame = self.slots[i]
		if(frame:IsShown()) then
			shownSlots = shownSlots + 1

			frame:Point("TOP", lootFrame, 4, (-8 + iconsize) - (shownSlots * iconsize))
		end
	end

	self:Height(math.max(shownSlots * iconsize + 16, 20))
end

local function createSlot(id)
	local iconsize = iconSize-2
	local frame = CreateFrame("Button", 'ElvLootSlot'..id, lootFrame)
	frame:Point("LEFT", 8, 0)
	frame:Point("RIGHT", -8, 0)
	frame:Height(iconsize)
	frame:SetID(id)

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnUpdate", OnUpdate)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:Height(iconsize)
	iconFrame:Width(iconsize)
	iconFrame:SetPoint("RIGHT", frame)
	
	iconFrame:SetTemplate("Default")
	E["frames"][iconFrame] = nil;

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAlpha(.8)
	icon:SetTexCoord(.07, .93, .07, .93)
	icon:Point("TOPLEFT", 2, -2)
	icon:Point("BOTTOMRIGHT", -2, 2)
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH"RIGHT"
	count:Point("BOTTOMRIGHT", iconFrame, -2, 2)
	count:FontTemplate(nil, nil, 'OUTLINE')
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", frame)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:FontTemplate(nil, nil, 'OUTLINE')
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop

	lootFrame.slots[id] = frame
	return frame
end

function M:LOOT_SLOT_CLEARED(event, slot)
	if(not lootFrame:IsShown()) then return end

	lootFrame.slots[slot]:Hide()
	anchorSlots(lootFrame)
end

function M:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, v in pairs(lootFrame.slots) do
		v:Hide()
	end
end

function M:OPEN_MASTER_LOOT_LIST()
	ToggleDropDownMenu(1, nil, GroupLootDropDown, lootFrame.slots[ss], 0, 0)
end

function M:UPDATE_MASTER_LOOT_LIST()
	UIDropDownMenu_Refresh(GroupLootDropDown)
end

function M:LOOT_OPENED(event, autoloot)
	lootFrame:Show()

	if(not lootFrame:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local items = GetNumLootItems()

	if(IsFishingLoot()) then
		lootFrame.title:SetText(L['Fishy Loot'])
	elseif(not UnitIsFriend("player", "target") and UnitIsDead"target") then
		lootFrame.title:SetText(UnitName("target"))
	else
		lootFrame.title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / lootFrame:GetEffectiveScale()
		y = y / lootFrame:GetEffectiveScale()

		lootFrame:ClearAllPoints()
		lootFrame:Point("TOPLEFT", nil, "BOTTOMLEFT", x - 40, y + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
	else
		lootFrame:ClearAllPoints()
		lootFrame:SetPoint("TOPLEFT", lootFrameHolder, "TOPLEFT")	
	end

	local m, w, t = 0, 0, lootFrame.title:GetStringWidth()
	if(items > 0) then
		for i=1, items do
			local slot = lootFrame.slots[i] or createSlot(i)
			local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			if(LootSlotIsCoin(i)) then
				item = item:gsub("\n", ", ")
			end

			if quantity and (quantity > 1) then
				slot.count:SetText(quantity)
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
			if color then
				slot.name:SetTextColor(color.r, color.g, color.b)
			end
			slot.icon:SetTexture(texture)
			
			if quality then
				m = math.max(m, quality)
			end
			w = math.max(w, slot.name:GetStringWidth())

			slot:Enable()
			slot:Show()
		end
	else
		local slot = lootFrame.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L['Empty Slot'])
		if color then
			slot.name:SetTextColor(color.r, color.g, color.b)
		end
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		items = 1
		w = math.max(w, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	anchorSlots(lootFrame)

	w = w + 60
	t = t + 5

	local color = ITEM_QUALITY_COLORS[m]
	lootFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	lootFrame:Width(math.max(w, t))
end

function M:LoadLoot()
	if not E.db.core.loot then return end
	lootFrameHolder = CreateFrame("Frame", "ElvLootFrameHolder", E.UIParent)
	lootFrameHolder:Point("TOPLEFT", 36, -195)
	lootFrameHolder:Width(150)
	lootFrameHolder:Height(22)
	
	lootFrame = CreateFrame('Button', 'ElvLootFrame', lootFrameHolder)
	lootFrame:SetPoint('TOPLEFT')
	lootFrame:Size(256, 64)
	lootFrame:SetTemplate('Default')
	lootFrame:SetFrameStrata"FULLSCREEN"
	lootFrame:SetToplevel(true)	
	lootFrame.title = lootFrame:CreateFontString(nil, 'OVERLAY')
	lootFrame.title:FontTemplate(nil, nil, 'OUTLINE')
	lootFrame.title:Point('BOTTOMLEFT', lootFrame, 'TOPLEFT', 0,  1)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", function(self)
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		CloseLoot()
	end)
	E["frames"][lootFrame] = nil;

	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
	
	E:CreateMover(lootFrameHolder, "LootFrameMover", "Loot Frame")
	
	-- Fuzz
	LootFrame:UnregisterAllEvents()
	table.insert(UISpecialFrames, 'ElvLootFrame')

	function _G.GroupLootDropDown_GiveLoot(self)
		if ( sq >= MASTER_LOOT_THREHOLD ) then
			local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[sq].hex..sn..FONT_COLOR_CODE_CLOSE, self:GetText())
			if (dialog) then
				dialog.data = self.value
			end
		else
			GiveMasterLoot(ss, self.value)
		end
		CloseDropDownMenus()
	end

	StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
		GiveMasterLoot(ss, data)
	end	
end