local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local _G = _G
local pairs, ipairs, ceil, floor, tonumber = pairs, ipairs, ceil, floor, tonumber
local strmatch, strlower, strfind = strmatch, strlower, strfind

local GetLocale = GetLocale
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestLogTitle = GetQuestLogTitle
local IsInInstance = IsInInstance
local UnitIsPlayer = UnitIsPlayer
local ThreatTooltip = THREAT_TOOLTIP:gsub('%%d', '%%d-')

local iconTypes = {'Default', 'Item', 'Skull', 'Chat'}
local questIndexByID = {
	--[questID] = questIndex
}
local activeQuests = {
	--[questName] = questID
}

local typesLocalized = {
	enUS = {
		KILL = {'slain', 'destroy', 'eliminate', 'repel', 'kill', 'defeat'},
		CHAT = {'speak', 'ask', 'talk', 'build'}
	},
	deDE = {
		KILL = {'besiegen', 'besiegt', 'getötet', 'töten', 'tötet', 'zerstört', 'genährt'},
		CHAT = {'befragt', 'sprecht'}
	},
	ruRU = {
		KILL = {'убит', 'уничтож', 'разбомблен', 'разбит', 'сразит'},
		CHAT = {'поговорит', 'спрашивать', 'строить'}
	},
	esMX = {
		KILL = {'matar', 'destruir', 'eliminar', 'repeler', 'derrotar'},
		CHAT = {'hablar', 'preguntar', 'construir'}
	},
	ptBR = {
		KILL = {'matar', 'destruir', 'eliminar', 'repelir', 'derrotar'},
		CHAT = {'falar', 'perguntar', 'construir'}
	},
	frFR = {
		KILL = {'tuer', 'détruire', 'éliminer', 'repousser', 'tuer', 'vaincre'},
		CHAT = {'parler', 'demander', 'construire'}
	},
	koKR = {
		KILL = {'살인', '멸하다', '제거', '죽이다', '격퇴하다', '죽임', '패배'},
		CHAT = {'말하다', '질문하다', '구축하다'}
	},
	zhCN = {
		KILL = {'消灭', '摧毁', '获得', '击败', '被杀', '毁灭', '击退', '杀死'},
		CHAT = {'交谈', '说话', '询问', '建立'}
	},
	zhTW = {
		KILL = {'被殺', '毀滅', '消除', '擊退', '殺死', '打败'},
		CHAT = {'說話', '詢問', '交談', '建立', '建设'}
	},
}

local questTypes = typesLocalized[GetLocale()] or typesLocalized.enUS

local function QUEST_ACCEPTED(_, _, questLogIndex, questID)
	if questLogIndex and questLogIndex > 0 then
		local questName = GetQuestLogTitle(questLogIndex)
		if questName and (questID and questID > 0) then
			activeQuests[questName] = questID
			questIndexByID[questID] = questLogIndex
		end
	end
end

local function QUEST_REMOVED(_, _, questID)
	if not questID then return end
	questIndexByID[questID] = nil

	for questName, id in pairs(activeQuests) do
		if id == questID then
			activeQuests[questName] = nil
			break
		end
	end
end

local function CheckTextForQuest(text)
	local x, y = strmatch(text, '(%d+)/(%d+)')
	if x and y then
		return floor(y - x)
	elseif not strmatch(text, ThreatTooltip) then
		local progress = tonumber(strmatch(text, '([%d%.]+)%%'))
		if progress and progress <= 100 then
			return ceil(100 - progress), true
		end
	end
end

local function GetQuests(unitID)
	if IsInInstance() then return end

	E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
	E.ScanTooltip:SetUnit(unitID)
	E.ScanTooltip:Show()

	local QuestList, notMyQuest, activeID
	for i = 3, E.ScanTooltip:NumLines() do
		local str = _G['ElvUI_ScanTooltipTextLeft' .. i]
		local text = str and str:GetText()
		if not text or text == '' then return end

		if UnitIsPlayer(text) then
			notMyQuest = text ~= E.myname
		elseif text and not notMyQuest then
			local count, percent = CheckTextForQuest(text)

			if activeQuests[text] then -- this line comes from one line up in the tooltip
				activeID = activeQuests[text]
			end

			if count then
				local type, index, texture, _
				if activeID then
					index = questIndexByID[activeID]
					_, texture = GetQuestLogSpecialItemInfo(index)
				end

				if texture then
					type = 'QUEST_ITEM'
				else
					local lowerText = strlower(text)

					-- check chat type first
					for _, listText in ipairs(questTypes.CHAT) do
						if strfind(lowerText, listText, nil, true) then
							type = 'CHAT'
							break
						end
					end

					-- check kill type if chat type doesn't exist
					if not type then
						for _, listText in ipairs(questTypes.KILL) do
							if strfind(lowerText, listText, nil, true) then
								type = 'KILL'
								break
							end
						end
					end
				end

				if not QuestList then QuestList = {} end
				QuestList[#QuestList + 1] = {
					isPercent = percent,
					itemTexture = texture,
					objectiveCount = count,
					questType = type or 'DEFAULT',
					-- below keys are currently unused
					questLogIndex = index,
					questID = activeID
				}
			end
		end
	end

	E.ScanTooltip:Hide()
	return QuestList
end

local function hideIcons(element)
	for _, object in pairs(iconTypes) do
		local icon = element[object]
		icon:Hide()

		if icon.Text then
			icon.Text:SetText('')
		end
	end
end

local function Update(self, event, unit)
	local element = self.QuestIcons
	if not element then return end

	if event ~= 'UNIT_NAME_UPDATE' then
		unit = self.unit
	end

	if unit ~= self.unit then return end

	if element.PreUpdate then
		element:PreUpdate()
	end

	hideIcons(element)

	local QuestList = GetQuests(unit)
	if QuestList then
		element:Show()
	else
		element:Hide()
		return
	end

	local shownCount
	for i = 1, #QuestList do
		local quest = QuestList[i]
		local objectiveCount = quest.objectiveCount
		local questType = quest.questType
		local isPercent = quest.isPercent

		if isPercent or objectiveCount > 0 then
			local icon
			if questType == 'DEFAULT' then
				icon = element.Default
			elseif questType == 'KILL' then
				icon = element.Skull
			elseif questType == 'CHAT' then
				icon = element.Chat
			elseif questType == 'QUEST_ITEM' then
				icon = element.Item
			end

			if icon and not icon:IsShown() then
				shownCount = (shownCount and shownCount + 1) or 0

				local size = icon.size or 25
				local setPosition = icon.position or 'TOPLEFT'
				local newPosition = E.InversePoints[setPosition]
				local offset = shownCount * (5 + size)

				icon:Show()
				icon:ClearAllPoints()
				icon:SetPoint(newPosition, element, newPosition, (strmatch(setPosition, 'LEFT') and -offset) or offset, 0)

				if questType ~= 'CHAT' and icon.Text and (isPercent or objectiveCount > 1) then
					icon.Text:SetText((isPercent and objectiveCount..'%') or objectiveCount)
				end

				if questType == 'QUEST_ITEM' then
					element.Item:SetTexture(quest.itemTexture)
				end
			end
		end
	end

	if element.PostUpdate then
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
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if element.Default:IsObjectType('Texture') and not element.Default:GetAtlas() then
			element.Default:SetAtlas('SmallQuestBang')
		end
		if element.Skull:IsObjectType('Texture') and not element.Skull:GetTexture() then
			element.Skull:SetTexture(E.Media.Textures.SkullIcon)
		end
		if element.Chat:IsObjectType('StatusBar') and not element.Chat:GetTexture() then
			element.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
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
	if element then
		element:Hide()
		hideIcons(element)

		self:UnregisterEvent('QUEST_ACCEPTED', QUEST_ACCEPTED)
		self:UnregisterEvent('QUEST_REMOVED', QUEST_REMOVED)
		self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
		self:UnregisterEvent('UNIT_NAME_UPDATE', Path)
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)
	end
end

--initial quest scan
for i = 1, GetNumQuestLogEntries() do
	local questName, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
	if questName and (questID and questID > 0) then
		activeQuests[questName] = questID
		questIndexByID[questID] = i
	end
end

oUF:AddElement('QuestIcons', Path, Enable, Disable)
