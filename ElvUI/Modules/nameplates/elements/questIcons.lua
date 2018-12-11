local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local unpack = unpack
local floor = math.floor
local match = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogIndexByID = GetQuestLogIndexByID
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local C_TaskQuest_GetQuestProgressBarInfo = C_TaskQuest.GetQuestProgressBarInfo

mod.ActiveQuests = {
	-- [questName] = questID ?
}

local UsedLocale = GetLocale()
local QuestTypesLocalized = {
	["enUS"] = {
		["slain"] = "KILL",
		["destroy"] = "KILL",
		["kill"] = "KILL",
		["defeat"] = "KILL",
		["speak"] = "CHAT",
	},
	["deDE"] = {
		["getötet"] = "KILL",
		["zerstört"] = "KILL",
		["töten"] = "KILL",
		["besiegen"] = "KILL",
		["sprecht"] = "CHAT",
	},
	["esMX"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
	["frFR"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
	["koKR"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
	["ptBR"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
	["ruRU"] = {
		["убит"] = "KILL",
		["уничтожен"] = "KILL",
		["разбомблен"] = "KILL",
		["разбит"] = "KILL",
		["поговорит"] = "CHAT",
	},
	["zhCN"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
	["zhTW"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
}

local QuestTypes = QuestTypesLocalized[UsedLocale] or QuestTypesLocalized["enUS"]

function mod:QUEST_ACCEPTED(_, questLogIndex, questID)
	if questLogIndex and questLogIndex > 0 then
		local questName = GetQuestLogTitle(questLogIndex)

		if questName and (questID and questID > 0) then
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
	local inInstance = IsInInstance()
	if inInstance then return end

	self.Tooltip:SetUnit(unitID)

	local QuestList, questID = {}
	for i = 3, self.Tooltip:NumLines() do
		local str = _G['ElvUIQuestTooltipTextLeft' .. i]
		local text = str and str:GetText()
		if not text then return end
		if not questID then
			questID = self.ActiveQuests[text]
		end

		local playerName, progressText = match(text, '^ ([^ ]-) ?%- (.+)$') -- nil or '' if 1 is missing but 2 is there
		if (not playerName or playerName == '' or playerName == E.myname) and progressText then
			local index = #QuestList + 1
			QuestList[index] = {}
			progressText = progressText:lower()

			local x, y = match(progressText, '(%d+)/(%d+)')
			if x and y then
				QuestList[index].objectiveCount = floor(y - x)
			end

			local QuestLogIndex, itemTexture, _
			if questID then
				QuestLogIndex = GetQuestLogIndexByID(questID)
				_, itemTexture = GetQuestLogSpecialItemInfo(QuestLogIndex)

				QuestList[index].isPerc = false
				local progress = C_TaskQuest_GetQuestProgressBarInfo(questID)
				if progress then
					QuestList[index].objectiveCount = floor(progress)
					QuestList[index].isPerc = true
				end

				QuestList[index].itemTexture = itemTexture
				QuestList[index].questID = questID
			end

			if itemTexture then
				QuestList[index].questType = "QUEST_ITEM"
			else
				QuestList[index].questType = "LOOT"

				for questString in pairs(QuestTypes) do
					if progressText:find(questString) then
						QuestList[index].questType = QuestTypes[questString]
						break
					end
				end
			end

			questID = nil
			QuestList[index].questLogIndex = QuestLogIndex
		end
	end

	return QuestList
end

function mod:Get_QuestIcon(frame, index)
	if frame.QuestIcon[index] then return frame.QuestIcon[index] end

	local iconSize = self.db.questIconSize
	local icon = CreateFrame("Frame", nil, frame.QuestIcon)
	icon:SetSize(iconSize, iconSize)

	if index == 1 then
		icon:SetPoint("LEFT", frame.QuestIcon, "LEFT")
	else
		icon:SetPoint("LEFT", frame.QuestIcon[index - 1], "RIGHT", 2, 0)
	end

	local itemTexture = icon:CreateTexture(nil, 'BORDER', nil, 1)
	itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
	itemTexture:SetSize(iconSize, iconSize)
	itemTexture:SetTexCoord(unpack(E.TexCoords))
	itemTexture:Hide()
	icon.ItemTexture = itemTexture

	-- Loot icon, display if mob needs to be looted for quest item
	local lootIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	lootIcon:SetAtlas('Banker')
	lootIcon:SetSize(iconSize, iconSize)
	lootIcon:SetPoint('TOPLEFT', icon, 'TOPLEFT')
	lootIcon:Hide()
	icon.LootIcon = lootIcon

	-- Skull icon, display if mob needs to be slain
	local skullIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	skullIcon:SetSize(iconSize + 4, iconSize + 4)
	skullIcon:SetPoint('TOPLEFT', icon, 'TOPLEFT', -3, 2)
	skullIcon:SetTexture([[Interface\AddOns\ElvUI\media\textures\skull_icon]])
	skullIcon:Hide()
	icon.SkullIcon = skullIcon

	-- Chat Icon, display if need to talk to NPC
	local chatIcon = icon:CreateTexture(nil, 'BORDER', nil, 1)
	chatIcon:SetSize(iconSize + 4, iconSize + 4)
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

	for i = 1, #questIcon do
		questIcon[i]:Hide()
	end

	if not QuestList then return end

	local icon, objectiveCount, questType, itemTexture
	for i = 1, #QuestList do
		icon = self:Get_QuestIcon(frame, i)
		objectiveCount = QuestList[i].objectiveCount
		questType = QuestList[i].questType
		itemTexture = QuestList[i].itemTexture

		if objectiveCount and (objectiveCount > 0 or QuestList[i].isPerc) then
			icon.Text:SetText((QuestList[i].isPerc and objectiveCount.."%") or objectiveCount)

			icon.SkullIcon:Hide()
			icon.LootIcon:Hide()
			icon.ItemTexture:Hide()
			icon.ChatIcon:Hide()

			if questType == "KILL" or QuestList[i].isPerc == true then
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

function mod:QuestIcon_RelativePosition(frame, element)
	if not frame.QuestIcon then return end

	local unit, isCastbarLeft, isCastbarRight, isEliteLeft, isEliteRight = frame.UnitType, false, false, false, false
	if unit then
		if self.db.units[unit].castbar.enable and element == "Castbar" and self.db.units[unit].castbar.iconPosition == "RIGHT" then
			if frame.CastBar:IsShown() then isCastbarLeft = true end
		end

		if self.db.units[unit].eliteIcon and self.db.units[unit].eliteIcon.enable and self.db.units[unit].eliteIcon.position == "RIGHT" then
			if frame.Elite:IsShown() then isEliteLeft = true end
		end

		if self.db.units[unit].castbar.enable and element == "Castbar" and self.db.units[unit].castbar.iconPosition == "LEFT" then
			if frame.CastBar:IsShown() then isCastbarRight = true end
		end

		if self.db.units[unit].eliteIcon and self.db.units[unit].eliteIcon.enable and self.db.units[unit].eliteIcon.position == "LEFT" then
			if frame.Elite:IsShown() then isEliteRight = true end
		end
	end

	frame.QuestIcon:ClearAllPoints()
	if self.db.questIconPosition == "RIGHT" then
		if isCastbarLeft then
			frame.QuestIcon:SetPoint("LEFT", frame.CastBar.Icon, "RIGHT", 4, 0)
		elseif not isCastbarLeft and isEliteLeft then
			frame.QuestIcon:SetPoint("LEFT", frame.Elite, "RIGHT", 4, 0)
		else
			frame.QuestIcon:SetPoint("LEFT", frame.HealthBar, "RIGHT", 4, 0)
		end
	elseif self.db.questIconPosition == "LEFT" then
		if isCastbarRight then
			frame.QuestIcon:SetPoint("RIGHT", frame.CastBar.Icon, "LEFT", -4, 0)
		elseif not isCastbarRight and isEliteRight then
			frame.QuestIcon:SetPoint("RIGHT", frame.Elite, "LEFT", -4, 0)
		else
			frame.QuestIcon:SetPoint("RIGHT", frame.HealthBar, "LEFT", -4, 0)
		end
	end
end

function mod:ConfigureElement_QuestIcon(frame)
	local QuestList = self:GetQuests(frame.unit)
	if not QuestList then return end

	local iconSize = self.db.questIconSize
	local biggerIcon = iconSize + 4

	local icon
	for i = 1, #QuestList do
		icon = self:Get_QuestIcon(frame, i)
		icon:SetSize(iconSize,iconSize)
		icon.ItemTexture:SetSize(iconSize,iconSize)
		icon.LootIcon:SetSize(iconSize,iconSize)
		icon.SkullIcon:SetSize(biggerIcon,biggerIcon)
		icon.ChatIcon:SetSize(biggerIcon,biggerIcon)
	end
end

function mod:ConstructElement_QuestIcons(frame)
	local questIcons = CreateFrame("frame", nil, frame)
	questIcons:SetPoint("LEFT", frame.HealthBar, "RIGHT", 4, 0)
	questIcons:SetSize(16, 16)
	return questIcons
end
