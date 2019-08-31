local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

--Lua functions
local _G = _G
local pairs, tonumber = pairs, tonumber
local ceil, floor = ceil, floor
local strmatch = strmatch
--WoW API / Variables
local GetLocale = GetLocale
local GetQuestLogIndexByID = GetQuestLogIndexByID
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestLogTitle = GetQuestLogTitle
local IsInInstance = IsInInstance
local UnitName = UnitName
local C_TaskQuest_GetQuestProgressBarInfo = C_TaskQuest.GetQuestProgressBarInfo

local ActiveQuests = {
	-- [questName] = questID ?
}

local UsedLocale = GetLocale()
local QuestTypesLocalized = {
	["enUS"] = {
		["slain"] = "KILL",
		["destroy"] = "KILL",
		['eleminate'] = 'KILL',
		['repel'] = 'KILL',
		["kill"] = "KILL",
		["defeat"] = "KILL",
		["speak"] = "CHAT",
		["ask"] = "CHAT",
	},
	["deDE"] = {
		["besiegen"] = "KILL",
		["besiegt"] = "KILL",
		["getötet"] = "KILL",
		["töten"] = "KILL",
		["tötet"] = "KILL",
		["zerstört"] = "KILL",
		["befragt"] = "CHAT",
		["sprecht"] = "CHAT",
		["genährt"] = "KILL",

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
		["уничтож"] = "KILL",
		["разбомблен"] = "KILL",
		["разбит"] = "KILL",
		["сразит"] = "KILL",
		["поговорит"] = "CHAT",
	},
	["zhCN"] = {
		["消灭"] = "KILL",
		["摧毁"] = "KILL",
		["获得"] = "KILL",
		["击败"] = "KILL",
		["交谈"] = "CHAT",
	},
	["zhTW"] = {
		["slain"] = "KILL",
		["destroyed"] = "KILL",
		["speak"] = "CHAT",
	},
}

local QuestTypes = QuestTypesLocalized[UsedLocale] or QuestTypesLocalized.enUS

local function QUEST_ACCEPTED(self, event, questLogIndex, questID)
	if questLogIndex and questLogIndex > 0 then
		local questName = GetQuestLogTitle(questLogIndex)

		if questName and (questID and questID > 0) then
			ActiveQuests[questName] = questID
		end
	end
end

local function QUEST_REMOVED(self, event, questID)
	if not questID then return end
	for questName, __questID in pairs(ActiveQuests) do
		if __questID == questID then
			ActiveQuests[questName] = nil
			break
		end
	end
end

local function GetQuests(unitID)
	if IsInInstance() then return end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unitID)
	E.ScanTooltip:Show()

	local QuestList, questID = {}
	for i = 3, E.ScanTooltip:NumLines() do
		local str = _G['ElvUI_ScanTooltipTextLeft' .. i]
		local text = str and str:GetText()
		if not text then return end
		if not questID then
			questID = ActiveQuests[text]
		end

		local playerName, progressText = strmatch(text, '^ ([^ ]-) ?%- (.+)$') -- nil or '' if 1 is missing but 2 is there
		if (not playerName or playerName == '' or playerName == UnitName('player')) and progressText then
			local index = #QuestList + 1
			QuestList[index] = {}
			progressText = progressText:lower()

			local x, y = strmatch(progressText, '(%d+)/(%d+)')
			if x and y then
				QuestList[index].objectiveCount = floor(y - x)
			else
				local progress = tonumber(strmatch(progressText, '([%d%.]+)%%')) -- contains % in the progressText
				if progress and progress <= 100 then
					QuestList[index].objectiveCount = ceil(100 - progress)
				end
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

	E.ScanTooltip:Hide()
	return QuestList
end

local function Update(self, event, unit)
	if (event ~= "UNIT_NAME_UPDATE") then
		unit = self.unit
	end

	if (unit ~= self.unit) then return end

	local element = self.QuestIcons

	if (element.PreUpdate) then
		element:PreUpdate()
	end

	local QuestList = GetQuests(unit)

	element:Hide()
	for i = 1, #element do
		element[i]:Hide()
	end

	if not QuestList then return end

	local objectiveCount, questType, itemTexture
	for i = 1, #QuestList do
		objectiveCount = QuestList[i].objectiveCount
		questType = QuestList[i].questType
		itemTexture = QuestList[i].itemTexture

		if objectiveCount and (objectiveCount > 0 or QuestList[i].isPerc) then
			element.Text:SetText((QuestList[i].isPerc and objectiveCount.."%") or objectiveCount)

			element.Skull:Hide()
			element.Loot:Hide()
			element.Item:Hide()
			element.Chat:Hide()

			if questType == "KILL" or QuestList[i].isPerc == true then
				element.Skull:Show()
			elseif questType == "LOOT" then
				element.Loot:Show()
			elseif questType == "CHAT" then
				element.Chat:Show()
				element.Text:SetText('')
			elseif questType == "QUEST_ITEM" then
				element.Item:Show()
				element.Item:SetTexture(itemTexture)
			end

			element:Show()
		else
			element:Hide()
		end
	end

	if (element.PostUpdate) then
		return element:PostUpdate()
	end
end

local function Path(self, ...)
	return (self.QuestIcons.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestIcons
	if (element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if (element.Loot) then
			if(element.Loot:IsObjectType('Texture') and not element.Loot:GetAtlas()) then
				element.Loot:SetAtlas('Banker')
			end
		end

		if (element.Skull) then
			if (element.Skull:IsObjectType('Texture') and not element.Skull:GetTexture()) then
				element.Skull:SetTexture(E.Media.Textures.SkullIcon)
			end
		end

		if(element.Chat) then
			if(element.Chat:IsObjectType('StatusBar') and not element.Chat:GetTexture()) then
				element.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
			end
		end

		self:RegisterEvent('QUEST_ACCEPTED', QUEST_ACCEPTED, true)
		self:RegisterEvent('QUEST_REMOVED', QUEST_REMOVED, true)
		self:RegisterEvent('QUEST_LOG_UPDATE', Path, true)
		self:RegisterEvent('UNIT_NAME_UPDATE', Path, true)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.QuestIcons
	if (element) then
		element:Hide()

		self:UnregisterEvent('QUEST_ACCEPTED', QUEST_ACCEPTED)
		self:UnregisterEvent('QUEST_REMOVED', QUEST_REMOVED)
		self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
	end
end

oUF:AddElement('QuestIcons', Path, Enable, Disable)
