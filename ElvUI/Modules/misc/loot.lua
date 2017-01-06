local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');
local LBG = LibStub("LibButtonGlow-1.0", true)

--Cache global variables
--Lua functions
local unpack, pairs = unpack, pairs
local tinsert = table.insert
local max = math.max
--WoW API / Variables
local CloseLoot = CloseLoot
local CreateFrame = CreateFrame
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local DoMasterLootRoll = DoMasterLootRoll
local GetCursorPosition = GetCursorPosition
local GetCVar = GetCVar
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetNumLootItems = GetNumLootItems
local GiveMasterLoot = GiveMasterLoot
local HandleModifiedItemClick = HandleModifiedItemClick
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local Lib_ToggleDropDownMenu = Lib_ToggleDropDownMenu
local Lib_UIDropDownMenu_AddButton = Lib_UIDropDownMenu_AddButton
local Lib_UIDropDownMenu_CreateInfo = Lib_UIDropDownMenu_CreateInfo
local LootSlotHasItem = LootSlotHasItem
local MasterLooterFrame_UpdatePlayers = MasterLooterFrame_UpdatePlayers
local ResetCursor = ResetCursor
local StaticPopup_Hide = StaticPopup_Hide
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LOOT = LOOT
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, LootFrame, LootSlot, GroupLootDropDown, UISpecialFrames
-- GLOBALS: UIParent, GameFontNormalLeft, MasterLooterFrame_Show, MASTER_LOOTER
-- GLOBALS: ASSIGN_LOOT, REQUEST_ROLL

--This function is copied from FrameXML and modified to use DropDownMenu library function calls
--Using the regular DropDownMenu code causes taints in various places.
local function GroupLootDropDown_Initialize()
	local info = Lib_UIDropDownMenu_CreateInfo();
	info.isTitle = 1;
	info.text = MASTER_LOOTER;
	info.fontObject = GameFontNormalLeft;
	info.notCheckable = 1;
	Lib_UIDropDownMenu_AddButton(info);

	info = Lib_UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.text = ASSIGN_LOOT;
	info.func = MasterLooterFrame_Show;
	Lib_UIDropDownMenu_AddButton(info);
	info.text = REQUEST_ROLL;
	info.func = function() DoMasterLootRoll(LootFrame.selectedSlot); end;
	Lib_UIDropDownMenu_AddButton(info);
end

--Create the new group loot dropdown frame and initialize it
local ElvUIGroupLootDropDown = CreateFrame("Frame", "ElvUIGroupLootDropDown", UIParent, "Lib_UIDropDownMenuTemplate")
ElvUIGroupLootDropDown:SetID(1)
ElvUIGroupLootDropDown:Hide()
Lib_UIDropDownMenu_Initialize(ElvUIGroupLootDropDown, nil, "MENU");
ElvUIGroupLootDropDown.initialize = GroupLootDropDown_Initialize;

local coinTextureIDs = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true,
}

--Credit Haste
local lootFrame, lootFrameHolder
local iconSize = 30;

local ss
local OnEnter = function(self)
	local slot = self:GetID()
	if(LootSlotHasItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end

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
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = self.name:GetText()
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedLootButton = self:GetName()
	LootFrame.selectedTexture = self.icon:GetTexture()

	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		ss = self:GetID()
		LootSlot(ss)
	end
end

local OnShow = function(self)
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

	self:Height(max(shownSlots * iconsize + 16, 20))
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
	frame:SetScript("OnShow", OnShow)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:Height(iconsize)
	iconFrame:Width(iconsize)
	iconFrame:Point("RIGHT", frame)
	iconFrame:SetTemplate("Default")
	frame.iconFrame = iconFrame
	E["frames"][iconFrame] = nil;

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(unpack(E.TexCoords))
	icon:SetInside()
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH"RIGHT"
	count:Point("BOTTOMRIGHT", iconFrame, -2, 2)
	count:FontTemplate(nil, nil, 'OUTLINE')
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:Point("LEFT", frame)
	name:Point("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:FontTemplate(nil, nil, 'OUTLINE')
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
	drop:Point("LEFT", icon, "RIGHT", 0, 0)
	drop:Point("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop

	local questTexture = iconFrame:CreateTexture(nil, 'OVERLAY')
	questTexture:SetInside()
	questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
	questTexture:SetTexCoord(unpack(E.TexCoords))
	frame.questTexture = questTexture

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
	Lib_ToggleDropDownMenu(1, nil, ElvUIGroupLootDropDown, lootFrame.slots[ss], 0, 0)
end

function M:UPDATE_MASTER_LOOT_LIST()
	MasterLooterFrame_UpdatePlayers()
end

function M:LOOT_OPENED(event, autoloot)
	lootFrame:Show()

	if(not lootFrame:IsShown()) then
		CloseLoot(not autoloot)
	end

	local items = GetNumLootItems()

	if(IsFishingLoot()) then
		lootFrame.title:SetText(L["Fishy Loot"])
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
		lootFrame:Point("TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
		E:DisableMover("LootFrameMover")
	else
		lootFrame:ClearAllPoints()
		lootFrame:Point("TOPLEFT", lootFrameHolder, "TOPLEFT")
		E:EnableMover("LootFrameMover")
	end

	local m, w, t = 0, 0, lootFrame.title:GetStringWidth()
	if(items > 0) then
		for i=1, items do
			local slot = lootFrame.slots[i] or createSlot(i)
			local textureID, item, quantity, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			if coinTextureIDs[textureID] then
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
			slot.icon:SetTexture(textureID)

			if quality then
				m = max(m, quality)
			end
			w = max(w, slot.name:GetStringWidth())


			local questTexture = slot.questTexture
			if ( questId and not isActive ) then
				questTexture:Show();
				LBG.ShowOverlayGlow(slot.iconFrame)
			elseif ( questId or isQuestItem ) then
				questTexture:Hide();
				LBG.ShowOverlayGlow(slot.iconFrame)
			else
				questTexture:Hide();
				LBG.HideOverlayGlow(slot.iconFrame)
			end

			slot:Enable()
			slot:Show()
		end
	else
		local slot = lootFrame.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L["Empty Slot"])
		if color then
			slot.name:SetTextColor(color.r, color.g, color.b)
		end
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		items = 1
		w = max(w, slot.name:GetStringWidth())

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
	lootFrame:Width(max(w, t))
end

function M:LoadLoot()
	if not E.private.general.loot then return end
	lootFrameHolder = CreateFrame("Frame", "ElvLootFrameHolder", E.UIParent)
	lootFrameHolder:Point("TOPLEFT", 36, -195)
	lootFrameHolder:Width(150)
	lootFrameHolder:Height(22)

	lootFrame = CreateFrame('Button', 'ElvLootFrame', lootFrameHolder)
	lootFrame:SetClampedToScreen(true)
	lootFrame:Point('TOPLEFT')
	lootFrame:Size(256, 64)
	lootFrame:SetTemplate('Transparent')
	lootFrame:SetFrameStrata(LootFrame:GetFrameStrata())
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, 'OVERLAY')
	lootFrame.title:FontTemplate(nil, nil, 'OUTLINE')
	lootFrame.title:Point('BOTTOMLEFT', lootFrame, 'TOPLEFT', 0,  1)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", function()
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		CloseLoot()
	end)
	E["frames"][lootFrame] = nil;

	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

	E:CreateMover(lootFrameHolder, "LootFrameMover", L["Loot Frame"])
	if(GetCVar("lootUnderMouse") == "1") then
		E:DisableMover("LootFrameMover")
	end
	
	-- Fuzz
	LootFrame:UnregisterAllEvents()
	tinsert(UISpecialFrames, 'ElvLootFrame')

	E.PopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
		GiveMasterLoot(ss, data)
	end
end