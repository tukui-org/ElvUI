--[[
	ItemSearch
		An item text search engine of some sort
--]]

local Search = LibStub('CustomSearch-1.0')
local Unfit = LibStub('Unfit-1.0')
local Lib = LibStub:NewLibrary('LibItemSearch-1.2-ElvUI', 9)
if Lib then
	Lib.Scanner = LibItemSearchTooltipScanner or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')
	Lib.Filters = {}
else
	return
end


--[[ User API ]]--

function Lib:Matches(link, search)
	return Search(link, search, self.Filters)
end

function Lib:Tooltip(link, search)
	return link and self.Filters.tip:match(link, nil, search)
end

function Lib:TooltipPhrase(link, search)
	return link and self.Filters.tipPhrases:match(link, nil, search)
end

function Lib:InSet(link, search)
	if IsEquippableItem(link) then
		local id = tonumber(link:match('item:(%-?%d+)'))
		return self:BelongsToSet(id, (search or ''):lower())
	end
end



--[[ Internal API ]]--

function Lib:TooltipLine(link, line)
	self.Scanner:SetOwner(UIParent, 'ANCHOR_NONE')
	self.Scanner:SetHyperlink(link)
	return _G[self.Scanner:GetName() .. 'TextLeft' .. line]:GetText()
end


if IsAddOnLoaded('ItemRack') then
	local sameID = ItemRack.SameID

	function Lib:BelongsToSet(id, search)
		for name, set in pairs(ItemRackUser.Sets) do
			if name:sub(1,1) ~= '' and Search:Find(search, name) then
				for _, item in pairs(set.equip) do
					if sameID(id, item) then
						return true
					end
				end
			end
		end
	end

elseif IsAddOnLoaded('Wardrobe') then
	function Lib:BelongsToSet(id, search)
		for _, outfit in ipairs(Wardrobe.CurrentConfig.Outfit) do
			local name = outfit.OutfitName
			if Search:Find(search, name) then
				for _, item in pairs(outfit.Item) do
					if item.IsSlotUsed == 1 and item.ItemID == id then
						return true
					end
				end
			end
		end
	end

elseif C_EquipmentSet then
	function Lib:BelongsToSet(id, search)
		for i, setID in pairs(C_EquipmentSet.GetEquipmentSetIDs()) do
			local name = C_EquipmentSet.GetEquipmentSetInfo(setID)
			if Search:Find(search, name) then
				local items = C_EquipmentSet.GetItemIDs(setID)
				for _, item in pairs(items) do
					if id == item then
						return true
					end
				end
			end
		end
	end
else
	function Lib:BelongsToSet() end
end


--[[ General Filters]]--

Lib.Filters.name = {
	tags = {'n', 'name'},

	canSearch = function(self, operator, search)
		return not operator and search
	end,

	match = function(self, item, _, search)
	-- Modified: C_Item.GetItemNameByID returns nil for M+ keystones, a fallback is needed
		return Search:Find(search, C_Item.GetItemNameByID(item) or item:match('%[(.-)%]'))
	end
}

Lib.Filters.type = {
	tags = {'t', 'type', 's', 'slot'},

	canSearch = function(self, operator, search)
		return not operator and search
	end,

	match = function(self, item, _, search)
		local type, subType, _, equipSlot = select(6, GetItemInfo(item))
		return Search:Find(search, type, subType, _G[equipSlot])
	end
}

Lib.Filters.level = {
	tags = {'l', 'level', 'lvl', 'ilvl'},

	canSearch = function(self, _, search)
		return tonumber(search)
	end,

	match = function(self, link, operator, num)
		local lvl = select(4, GetItemInfo(link))
		if lvl then
			return Search:Compare(operator, lvl, num)
		end
	end
}

Lib.Filters.requiredlevel = {
	tags = {'r', 'req', 'rl', 'reql', 'reqlvl'},

	canSearch = function(self, _, search)
		return tonumber(search)
	end,

	match = function(self, link, operator, num)
		local lvl = select(5, GetItemInfo(link))
		if lvl then
			return Search:Compare(operator, lvl, num)
		end
	end
}

Lib.Filters.sets = {
	tags = {'s', 'set'},

	canSearch = function(self, operator, search)
		return not operator and search
	end,

	match = function(self, link, _, search)
		return Lib:InSet(link, search)
	end,
}

Lib.Filters.quality = {
	tags = {'q', 'quality'},
	keywords = {},

	canSearch = function(self, _, search)
		for quality, name in pairs(self.keywords) do
			if name:find(search) then
				return quality
			end
		end
	end,

	match = function(self, link, operator, num)
		local quality = link:sub(1, 9) == 'battlepet' and tonumber(link:match('%d+:%d+:(%d+)')) or C_Item.GetItemQualityByID(link)
		return Search:Compare(operator, quality, num)
	end,
}

for i = 0, #ITEM_QUALITY_COLORS do
	Lib.Filters.quality.keywords[i] = _G['ITEM_QUALITY' .. i .. '_DESC']:lower()
end


--[[ Classic Keywords ]]--

Lib.Filters.items = {
	keyword = ITEMS:lower(),

	canSearch = function(self, operator, search)
		return not operator and self.keyword:find(search)
	end,

	match = function(self, link)
		return true
	end
}

Lib.Filters.usable = {
	keyword = USABLE_ITEMS:lower(),

	canSearch = function(self, operator, search)
		return not operator and self.keyword:find(search)
	end,

	match = function(self, link)
		if not Unfit:IsItemUnusable(link) then
			local lvl = select(5, GetItemInfo(link))
			return lvl and (lvl == 0 or lvl > UnitLevel('player'))
		end
	end
}


--[[ Retail Keywords ]]--

if C_ArtifactUI then
	Lib.Filters.artifact = {
		keyword1 = ITEM_QUALITY6_DESC:lower(),
		keyword2 = RELICSLOT:lower(),

		canSearch = function(self, operator, search)
			return not operator and self.keyword1:find(search) or self.keyword2:find(search)
		end,

		match = function(self, link)
			local id = link:match('item:(%d+)')
			return id and C_ArtifactUI.GetRelicInfoByItemID(id)
		end
	}
end

if C_AzeriteItem then
	Lib.Filters.azerite = {
		keyword = C_CurrencyInfo.GetBasicCurrencyInfo(C_CurrencyInfo.GetAzeriteCurrencyID()).name:lower(),

		canSearch = function(self, operator, search)
			return not operator and self.keyword:find(search)
		end,

		match = function(self, link)
			return C_AzeriteItem.IsAzeriteItemByID(link) or C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link)
		end
	}
end

Lib.Filters.keystone = {
	keyword1 = CHALLENGES:lower(), --English: "mythic keystone" (localized)
	keyword2 = "mythic keystone", --unlocalized

	canSearch = function(self, operator, search)
		return not operator and self.keyword1:find(search) or self.keyword2:find(search)
	end,

	match = function(self, link)
		local id = link:match('item:(%d+)')
		return id and (select(12, GetItemInfo(id)) == 5 and select(13, GetItemInfo(id)) == 1) --itemClassID 5 and itemSubClassID 1 which translates to "Keystone"
	end
}

--[[ Tooltips ]]--

Lib.Filters.tip = {
	tags = {'tt', 'tip', 'tooltip'},
	onlyTags = true,

	canSearch = function(self, _, search)
		return search
	end,

	match = function(self, link, _, search)
		if link:find('item:') then
			Lib.Scanner:SetOwner(UIParent, 'ANCHOR_NONE')
			Lib.Scanner:SetHyperlink(link)

			for i = 1, Lib.Scanner:NumLines() do
				if Search:Find(search, _G[Lib.Scanner:GetName() .. 'TextLeft' .. i]:GetText()) then
					return true
				end
			end
		end
	end
}

local escapes = {
	["|c%x%x%x%x%x%x%x%x"] = "", -- color start
	["|r"] = "", -- color end
}
local function CleanString(str)
    for k, v in pairs(escapes) do
        str = str:gsub(k, v)
    end
    return str
end

Lib.Filters.tipPhrases = {
	canSearch = function(self, _, search)
		if #search >= 3 then
			for key, query in pairs(self.keywords) do
				if key:find(search) then
					return query
				end
			end
		end
	end,

	match = function(self, link, _, search)
		local id = link:match('item:(%d+)')
		if not id then
			return
		end

		local cached = self.cache[search][id]
		if cached ~= nil then
			return cached
		end

		Lib.Scanner:SetOwner(UIParent, 'ANCHOR_NONE')
		Lib.Scanner:SetHyperlink(link)

		local matches = false
		for i = 1, Lib.Scanner:NumLines() do
			local text = _G[Lib.Scanner:GetName() .. 'TextLeft' .. i]:GetText()
			text = CleanString(text)
			if search == text then
				matches = true
				break
			end
		end

		self.cache[search][id] = matches
		return matches
	end,

	cache = setmetatable({}, {__index = function(t, k) local v = {} t[k] = v return v end}),
	keywords = {
		[ITEM_SOULBOUND:lower()] = ITEM_BIND_ON_PICKUP,
		[QUESTS_LABEL:lower()] = ITEM_BIND_QUEST,
		[GetItemClassInfo(LE_ITEM_CLASS_QUESTITEM):lower()] = ITEM_BIND_QUEST,
		[PROFESSIONS_USED_IN_COOKING:lower()] = PROFESSIONS_USED_IN_COOKING,
		[TOY:lower()] = TOY,

		[FOLLOWERLIST_LABEL_CHAMPIONS:lower()] = Lib:TooltipLine('item:147556', 2),
		[GARRISON_FOLLOWERS:lower()] = Lib:TooltipLine('item:147556', 2),

		['soulbound'] = ITEM_BIND_ON_PICKUP,
    	['bound'] = ITEM_BIND_ON_PICKUP,
    	['bop'] = ITEM_BIND_ON_PICKUP,
		['boe'] = ITEM_BIND_ON_EQUIP,
		['bou'] = ITEM_BIND_ON_USE,
		['boa'] = ITEM_BIND_TO_BNETACCOUNT,
		['quests'] = ITEM_BIND_QUEST,
		['crafting reagent'] = PROFESSIONS_USED_IN_COOKING,
		['toy'] = TOY,
		['champions'] = Lib:TooltipLine('item:147556', 2),
		['followers'] = Lib:TooltipLine('item:147556', 2),
	}
}
