local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local oUF = E.oUF

local ipairs, ceil, floor, tonumber = ipairs, ceil, floor, tonumber
local wipe, strmatch, strlower, strfind, next = wipe, strmatch, strlower, strfind, next

local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

local C_QuestLog_GetTitleForLogIndex = C_QuestLog.GetTitleForLogIndex
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetQuestDifficultyLevel = C_QuestLog.GetQuestDifficultyLevel
local C_QuestLog_GetQuestObjectives = C_QuestLog.GetQuestObjectives
local C_QuestLog_GetTitleForQuestID = C_QuestLog.GetTitleForQuestID

local questElements = {
	DEFAULT = 'Default',
	KILL = 'Skull',
	CHAT = 'Chat',
	QUEST_ITEM = 'Item'
}

local questIcons = {
	iconTypes = { 'Default', 'Item', 'Skull', 'Chat' },
	activeQuests = {}, --[questTitle] = quest data
}

NP.QuestIcons = questIcons

local typesLocalized = {
	enUS = {
		--- short matching applies here so,
		-- kill: killed, destory: destoryed, etc ...
		KILL = {'slain', 'destroy', 'eliminate', 'repel', 'kill', 'defeat'},
		CHAT = {'speak', 'talk'}
	},
	deDE = {
		KILL = {'besiegen', 'besiegt', 'getötet', 'töten', 'tötet', 'vernichtet', 'zerstört', 'genährt'},
		CHAT = {'befragt', 'sprecht'}
	},
	ruRU = {
		KILL = {'убит', 'уничтож', 'разбомблен', 'разбит', 'сразит'},
		CHAT = {'поговорит', 'спрашивать'}
	},
	esMX = {
		-- asesinad: asesinado, asesinados, asesinada, asesinadas
		-- derrota: derrotar, derrotado, derrotados, derrotada, derrotadas
		-- destrui: destruir, destruido, destruidos, destruida, destruidas
		-- elimin: eliminar, elimine, eliminadas, eliminada, eliminados, eliminado
		-- repel: repele, repelido, repelidos, repelida, repelidas
		KILL = {'asesinad', 'destrui', 'elimin', 'repel', 'derrota'},
		CHAT = {'habla', 'pídele'}
	},
	ptBR = {
		-- destrui: above but also destruição
		-- repel: repelir, repelido, repelidos, repelida, repelidas
		KILL = {'morto', 'morta', 'matar', 'destrui', 'elimin', 'repel', 'derrota'},
		CHAT = {'falar', 'pedir'}
	},
	frFR = {
		-- tué: tués, tuée, tuées
		-- abattu: abattus, abattue
		-- détrui: détruite, détruire, détruit, détruits, détruites
		-- repouss: repousser, repoussés, repoussée, repoussées
		-- élimin: éliminer, éliminé, éliminés, éliminée, éliminées
		KILL = {'tué', 'tuer', 'attaqué', 'attaque', 'abattre', 'abattu', 'détrui', 'élimin', 'repouss', 'vaincu', 'vaincre'},
		-- demande: demander, demandez
		-- parle: parler, parlez
		CHAT = {'parle', 'demande'}
	},
	koKR = {
		KILL = {'쓰러뜨리기', '물리치기', '공격', '파괴'},
		CHAT = {'대화'}
	},
	zhCN = {
		KILL = {'消灭', '摧毁', '击败', '毁灭', '击退'},
		CHAT = {'交谈', '谈一谈'}
	},
	zhTW = {
		KILL = {'毀滅', '擊退', '殺死'},
		CHAT = {'交談', '說話'}
	},
}

local questTypes = typesLocalized[E.locale] or typesLocalized.enUS

local function GetObjectiveType(text, texture)
	if texture then
		return 'QUEST_ITEM'
	end

	local lowerText = strlower(text)

	-- check kill type first
	for _, listText in ipairs(questTypes.KILL) do
		if strfind(lowerText, listText, nil, true) then
			return 'KILL'
		end
	end

	-- check chat type if kill type doesn't exist
	for _, listText in ipairs(questTypes.CHAT) do
		if strfind(lowerText, listText, nil, true) then
			return 'CHAT'
		end
	end
end

local function GetQuestObjectives(id, texture)
	local list = {}

	for _, objective in next, C_QuestLog_GetQuestObjectives(id) do
		local text = not objective.finished and objective.text
		if text then
			if objective.type == 'progressbar' then
				local progress = tonumber(strmatch(text, '([%d%.]+)%%'))
				if progress and progress <= 100 then
					list[text] = { value = ceil(100 - progress), type = GetObjectiveType(text, texture), isPercent = true }
				end
			else
				local need = objective.numRequired
				local have = objective.numFulfilled
				if need and have then
					local diff = floor(need - have)
					if diff > 0 then
						list[text] = { value = diff, type = GetObjectiveType(text, texture), isPercent = false }
					end
				end
			end
		end
	end

	return next(list) and list
end

local function GetQuests(unitID)
	local QuestList, notMyQuest, lastTitle
	local info = E.ScanTooltip:GetUnitInfo(unitID)
	if info and info.lines[2] then
		for _, line in next, info.lines, 2 do
			local text = line and line.leftText
			if not text or text == '' then return end

			if line.type == 18 or (not E.Retail and UnitIsPlayer(text)) then -- 18 is QuestPlayer
				notMyQuest = text ~= E.myname
			elseif text and not notMyQuest then
				if line.type == 17 or not E.Retail then
					lastTitle = questIcons.activeQuests[text]
				end -- this line comes from one line up in the tooltip

				local objectives = (line.type == 8 or not E.Retail) and lastTitle and lastTitle.objectives
				if objectives then
					local quest = objectives[text]
					if quest then
						if not QuestList then QuestList = {} end
						QuestList[#QuestList + 1] = {
							itemTexture = lastTitle.texture,
							isPercent = quest.isPercent,
							objectiveCount = quest.value,
							questType = quest.type or 'DEFAULT',
						}
					end
				end
			end
		end
	end

	E.ScanTooltip:Hide()

	return QuestList
end

local function hideIcon(icon)
	icon:Hide()

	if icon.Text then
		icon.Text:SetText('')
	end
end

local function hideIcons(element)
	for _, object in next, questIcons.iconTypes do
		hideIcon(element[object])
	end
end

local function Update(self, event)
	local element = self.QuestIcons
	if not element then return end

	local unit = self.unit
	if not unit then return end

	-- this only runs on npc units anyways
	if NP.InstanceType ~= 'none' then return end

	local list -- quests
	local guid = UnitGUID(unit)
	if element.guid ~= guid then
		element.guid = guid -- if its the same guid on these events reuse the quest data
	elseif event == 'UNIT_NAME_UPDATE' or event == 'NAME_PLATE_UNIT_ADDED' then
		list = element.lastQuests
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	if not list then
		list = GetQuests(unit)
		element.lastQuests = list
	end

	element:SetShown(list)

	if list then
		hideIcons(element)

		local shown = -1
		for _, quest in next, list do
			local objectiveCount = quest.objectiveCount
			local questType = quest.questType
			local isPercent = quest.isPercent

			local icon = (isPercent or objectiveCount > 0) and element[questElements[questType]]
			if icon and not icon:IsShown() then
				shown = shown + 1

				local setPosition = icon.position or 'TOPLEFT'
				local newPosition = E.InversePoints[setPosition]
				local offset = shown * (5 + (icon.size or 25))

				icon:Show()
				icon:ClearAllPoints()
				icon:Point(newPosition, element, newPosition, (strmatch(setPosition, 'LEFT') and -offset) or offset, 0)

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

		self:RegisterEvent('QUEST_LOG_UPDATE', Path, true)
		self:RegisterEvent('UNIT_NAME_UPDATE', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.QuestIcons
	if element then
		element:Hide()
		hideIcons(element)

		element.lastQuests = nil

		self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
		self:UnregisterEvent('UNIT_NAME_UPDATE', Path)
	end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('QUEST_ACCEPTED')
frame:RegisterEvent('QUEST_REMOVED')
frame:RegisterEvent('QUEST_LOG_UPDATE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(self, event)
	wipe(questIcons.activeQuests)

	if E.Retail then
		for i = 1, C_QuestLog_GetNumQuestLogEntries() do
			local id = C_QuestLog_GetQuestIDForLogIndex(i)
			if id and id > 0 then
				local title = C_QuestLog_GetTitleForLogIndex(i)
				if title then
					local _, texture = GetQuestLogSpecialItemInfo(i)
					local level = C_QuestLog_GetQuestDifficultyLevel(id)
					questIcons.activeQuests[title] = {
						id = id,
						texture = texture,
						difficulty = level,
						title = C_QuestLog_GetTitleForQuestID(id),
						color = GetQuestDifficultyColor(level),
						objectives = GetQuestObjectives(id, texture)
					}
				end
			end
		end
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		self:UnregisterEvent(event)
	end
end)

oUF:AddElement('QuestIcons', Path, Enable, Disable)
