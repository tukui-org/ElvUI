local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

--Lua functions
local _G = _G
local pairs, tonumber = pairs, tonumber
local strmatch, strfind = strmatch, strfind
local ceil, floor = ceil, floor
--WoW API / Variables
local GetLocale = GetLocale
local GetQuestLogIndexByID = GetQuestLogIndexByID
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestLogTitle = GetQuestLogTitle
local IsInInstance = IsInInstance
local UnitIsPlayer = UnitIsPlayer
local C_TaskQuest_GetQuestProgressBarInfo = C_TaskQuest.GetQuestProgressBarInfo
local ThreatTooltip = THREAT_TOOLTIP:gsub('%%d', '%%d-')

local ActiveQuests = {
	--[questName] = questID
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
	for questName, id in pairs(ActiveQuests) do
		if id == questID then
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

	local QuestList, notMyQuest
	for i = 3, E.ScanTooltip:NumLines() do
		local str = _G['ElvUI_ScanTooltipTextLeft' .. i]
		local text = str and str:GetText()
		if not text or text == '' then return end

		if UnitIsPlayer(text) then
			notMyQuest = text ~= E.myname
		elseif text and not notMyQuest then
			local objCount, QuestType, IsPerc, logIndex, itemTex, _

			-- active quest
			local QuestID = ActiveQuests[text]
			if QuestID then
				logIndex = GetQuestLogIndexByID(QuestID)
				_, itemTex = GetQuestLogSpecialItemInfo(logIndex)

				local progress = C_TaskQuest_GetQuestProgressBarInfo(QuestID)
				if progress then
					objCount = floor(progress)
					IsPerc = true
				end
			end

			-- text check, only if active quest doesnt find the objective
			if not objCount then
				local x, y = strmatch(text, '(%d+)/(%d+)')
				if x and y then
					objCount = floor(y - x)
				elseif not strmatch(text, ThreatTooltip) then
					local progress = tonumber(strmatch(text, '([%d%.]+)%%')) -- contains % in the text
					if progress and progress <= 100 then
						objCount = ceil(100 - progress)
					end
				end
			end

			if itemTex then
				QuestType = "QUEST_ITEM"
			elseif objCount then
				QuestType = "LOOT"

				local lowerText = text:lower()
				for questString in pairs(QuestTypes) do
					if strfind(lowerText, questString) then
						QuestType = QuestTypes[questString]
						break
					end
				end
			end

			if QuestType then
				if not QuestList then QuestList = {} end
				QuestList[#QuestList + 1] = {
					isPerc = IsPerc,
					itemTexture = itemTex,
					objectiveCount = objCount,
					questType = QuestType,
					-- below keys are currently unused
					questLogIndex = logIndex,
					questID = QuestID
				}
			end
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

	element:Hide()
	for i = 1, #element do
		element[i]:Hide()
	end

	local QuestList = GetQuests(unit)
	if not QuestList then return end

	for i = 1, #QuestList do
		local quest = QuestList[i]
		local objectiveCount = quest.objectiveCount
		local itemTexture = quest.itemTexture
		local questType = quest.questType
		local isPerc = quest.isPerc

		if objectiveCount and (objectiveCount > 0 or isPerc) then
			element.Text:SetText((isPerc and objectiveCount.."%") or objectiveCount)

			element.Skull:Hide()
			element.Loot:Hide()
			element.Item:Hide()
			element.Chat:Hide()

			if questType == "KILL" or isPerc then
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
