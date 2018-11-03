local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

local twipe = table.wipe
local format = string.format
local match = string.match
local strjoin = strjoin

mod.ActiveQuests = {
	-- [questName] = questID ?
}

local DaLang = GetLocale()
local QuestTypesLocalized = {
	["enUS"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	}
}


function mod:QUEST_ACCEPTED(_, questLogIndex, questID, ...)
	if questLogIndex and questLogIndex > 0 then
		local questName = GetQuestLogTitle(questLogIndex)

		if questName and questID and questID > 0 then
			self.ActiveQuests[questName] = questID
		end

		mod:ForEachPlate("UpdateElement_QuestIcon")
	end
end

function mod:QUEST_REMOVED(_, questID)
	if not questID then return end
	for questName, __questID in pairs(self.ActiveQuests) do
		if __questID == questID then
			self.ActiveQuests[questName] = nil
			mod:ForEachPlate("UpdateElement_QuestIcon")
			break
		end
	end
end

mod.QuestObjectiveStrings = {}
function mod:QUEST_LOG_UPDATE()
	mod:ForEachPlate("UpdateElement_QuestIcon")
end

function mod:GetQuests(unitID)
	self.Tooltip:SetUnit(unitID)

	local QuestList = {}

	local questID
	for i = 3, self.Tooltip:NumLines() do
		local str = _G['ElvUIQuestTooltipTextLeft' .. i]
		local text = str and str:GetText()
		if not text then return end
		questID = questID or self.ActiveQuests[text]
		local playerName, progressText = match(text, '^ ([^ ]-) ?%- (.+)$') -- nil or '' if 1 is missing but 2 is there
		if (not playerName or playerName == '' or playerName == E.myname) and progressText then
			local index = #QuestList + 1
			QuestList[index] = {}

			progressText = progressText:lower()
			local x, y
			x, y = match(progressText, '(%d+)/(%d+)')
			if x and y then
				QuestList[index].objectiveCount = y - x
			end

			if questID then
				local QuestLogIndex = GetQuestLogIndexByID(questID)
				local _, itemTexture = GetQuestLogSpecialItemInfo(QuestLogIndex)
				QuestList[index].itemTexture = itemTexture
				QuestList[index].questID = questID
			end

			if itemTexture then
				QuestList[index].questType = "QUEST_ITEM"
			else
				QuestList[index].questType = "LOOT"

				for string in pairs(QuestTypesLocalized[DaLang]) do
					if progressText:find(string) then
						QuestList[index].questType = QuestTypesLocalized[DaLang][string]
						break
					end
				end
			end

			QuestList[index].questLogIndex = QuestLogIndex
		end
	end

	return QuestList
end

function mod:Get_QuestIcon(frame, index)
	if frame.QuestIcon[index] then return frame.QuestIcon[index] end

	local icon = CreateFrame("Frame", nil, frame.QuestIcon)
	icon:SetSize(16, 16)

	if index == 1 then
		icon:SetPoint("LEFT", frame.QuestIcon, "LEFT")
	else
		icon:SetPoint("LEFT", frame.QuestIcon[index - 1], "RIGHT", 2, 0)
	end

	local itemTexture = icon:CreateTexture(nil, 'BORDER', nil, 1)
	itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
	itemTexture:SetSize(16, 16)
	itemTexture:SetTexCoord(unpack(E.TexCoords))
	itemTexture:Hide()
	icon.ItemTexture = itemTexture

	-- Loot icon, display if mob needs to be looted for quest item
	local lootIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	lootIcon:SetAtlas('Banker')
	lootIcon:SetSize(16, 16)
	lootIcon:SetPoint('TOPLEFT', icon, 'TOPLEFT')
	lootIcon:Hide()
	icon.LootIcon = lootIcon

	-- Skull icon, display if mob needs to be slain
	local skullIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	skullIcon:SetSize(20, 20)
	skullIcon:SetPoint('TOPLEFT', icon, 'TOPLEFT', -3, 2)
	skullIcon:SetTexture([[Interface\WorldMap\Skull_64Grey.PNG]])
	skullIcon:Hide()
	icon.SkullIcon = skullIcon

	-- Chat Icon, display if need to talk to NPC
	local chatIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	chatIcon:SetSize(20, 20)
	chatIcon:SetPoint('TOPLEFT', icon, 'TOPLEFT', -3, 2)
	chatIcon:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	chatIcon:SetTexCoord(0, 0.5, 0.5, 1)
	chatIcon:Hide()
	icon.ChatIcon = chatIcon	

	local iconText = icon:CreateFontString(nil, 'OVERLAY')
	iconText:SetPoint('BOTTOMRIGHT', icon, 2, -0.8)
	iconText:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	icon.Text = iconText

	frame.QuestIcon[index] = icon
	return icon
end

function mod:UpdateElement_QuestIcon(frame)
	if self.db.questIcon ~= true then return end

	local questIcon = frame.QuestIcon
	local QuestList = self:GetQuests(frame.unit)

	for i=1, #questIcon do
		questIcon[i]:Hide()
	end

	for i=1, #QuestList do
		local icon = self:Get_QuestIcon(frame, i)
		local objectiveCount = QuestList[i].objectiveCount
		local questType = QuestList[i].questType
		local itemTexture = QuestList[i].itemTexture

		if objectiveCount and objectiveCount > 0 then
			icon.Text:SetText(objectiveCount)

			icon.SkullIcon:Hide()
			icon.LootIcon:Hide()
			icon.ItemTexture:Hide()
			icon.ChatIcon:Hide()
			if questType == "KILL" then
				icon.SkullIcon:Show()
			elseif questType == "LOOT" then
				icon.LootIcon:Show()
			elseif questType == "CHAT" then
				icon.ChatIcon:Show()
				icon.Text:SetText('')
			elseif questType == "QUEST_ITEM" then
				icon.ItemTexture:Show()
				icon.ItemTexture:SetTexture(itemTexture)
			end			
			icon:Show()
		else
			icon:Hide()
		end
	end
end

function mod:ConstructElement_QuestIcons(frame)
	local questIcons = CreateFrame("frame", nil, frame)
	questIcons:SetPoint("LEFT", frame.HealthBar, "RIGHT", 4, 0)
	questIcons:SetSize(16, 16)
	return questIcons
end
