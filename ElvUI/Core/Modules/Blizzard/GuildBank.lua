local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')
local Bags = E:GetModule('Bags')
local LSM = E.Libs.LSM

local _G = _G
local hooksecurefunc = hooksecurefunc
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local GetGuildBankItemLink = GetGuildBankItemLink
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local NUM_GUILDBANK_COLUMNS = 7

function B:GuildBank_ItemLevel(button)
	local db = E.db.general.guildBank
	if not db then return end

	if not button.itemLevel then
		button.itemLevel = button:CreateFontString(nil, 'ARTWORK', nil, 1)
	end

	button.itemLevel:ClearAllPoints()
	button.itemLevel:Point(db.itemLevelPosition, db.itemLevelxOffset, db.itemLevelyOffset)
	button.itemLevel:FontTemplate(LSM:Fetch('font', db.itemLevelFont), db.itemLevelFontSize, db.itemLevelFontOutline)

	local r, g, b, ilvl
	local tab = db.itemLevel and GetCurrentGuildBankTab()
	local itemlink = tab and GetGuildBankItemLink(tab, button:GetID())
	if itemlink then
		local _, _, rarity, _, _, _, _, _, itemEquipLoc, _, _, classID, subclassID = GetItemInfo(itemlink)

		local canShowItemLevel = Bags:IsItemEligibleForItemLevelDisplay(classID, subclassID, itemEquipLoc, rarity)
		if canShowItemLevel then
			local color = db.itemLevelCustomColorEnable and db.itemLevelCustomColor
			if color then
				r, g, b = color.r, color.g, color.b
			else
				r, g, b = GetItemQualityColor(rarity)
			end

			ilvl = GetDetailedItemLevelInfo(itemlink)
		end
	end

	button.itemLevel:SetText(ilvl and ilvl >= db.itemLevelThreshold and ilvl or '')
	button.itemLevel:SetTextColor(r or 1, g or 1, b or 1)
end

function B:GuildBank_CountText(button)
	local db = E.db.general.guildBank
	if not db then return end

	button.Count:ClearAllPoints()
	button.Count:Point(db.countPosition, db.countxOffset, db.countyOffset)
	button.Count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
	button.Count:SetTextColor(db.countFontColor.r, db.countFontColor.g, db.countFontColor.b)
end

function B:GuildBank_Update()
	local frame = _G.GuildBankFrame
	if not frame or not frame:IsShown() then return end

	for i = 1, NUM_GUILDBANK_COLUMNS do
		local column = frame['Column'..i]

		for x = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = column['Button'..x]

			B:GuildBank_ItemLevel(button)
			B:GuildBank_CountText(button)
		end
	end
end

function B:ImproveGuildBank()
	hooksecurefunc(_G.GuildBankFrame, 'Update', B.GuildBank_Update)

	-- blizzard bug fix when trying to search after having the guild bank open
	if E.Wrath then -- they copy pasted too much
		for i = 1, _G.MAX_GUILDBANK_TABS do
			local tab = _G['GuildBankTab'..i]
			local button = tab and tab.Button
			if button then
				button:UnregisterEvent('INVENTORY_SEARCH_UPDATE')
			end
		end
	end
end
