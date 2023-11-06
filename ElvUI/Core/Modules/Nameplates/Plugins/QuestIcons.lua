local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local oUF = E.oUF

local time, pairs, ipairs, ceil, floor, tonumber = time, pairs, ipairs, ceil, floor, tonumber
local wipe, strmatch, strlower, strfind, next = wipe, strmatch, strlower, strfind, next

local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID

local C_QuestLog_GetTitleForLogIndex = C_QuestLog.GetTitleForLogIndex
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local ThreatTooltip = THREAT_TOOLTIP:gsub('%%d', '%%d-')

local questIcons = {
	iconTypes = { 'Default', 'Item', 'Skull', 'Chat' },
	indexByID = {}, --[questID] = questIndex
	activeQuests = {} --[questTitle] = questID
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

local function CheckTextForQuest(text, lineType)
	if lineType and lineType ~= 8 then
		return -- 8 is QuestObjective
	end

	local x, y = strmatch(text, '(%d+)/(%d+)')
	if x and y then
		local diff = floor(y - x)
		if diff > 0 then
			return diff
		end
	elseif not strmatch(text, ThreatTooltip) then
		local progress = tonumber(strmatch(text, '([%d%.]+)%%'))
		if progress and progress <= 100 then
			return ceil(100 - progress), true
		end
	end
end
NP.QuestIcons.CheckTextForQuest = CheckTextForQuest

local function GetQuests(unitID)
	local QuestList, notMyQuest, activeID
	local info = E.ScanTooltip:GetUnitInfo(unitID)
	if info and info.lines[3] then
		for _, line in next, info.lines, 3 do
			local text = line and line.leftText
			if not text or text == '' then return end

			local lineType = line.type
			if lineType == 18 or UnitIsPlayer(text) then -- 18 is QuestPlayer
				notMyQuest = text ~= E.myname
			elseif text and not notMyQuest then
				local count, percent = CheckTextForQuest(text, lineType)

				-- this line comes from one line up in the tooltip
				local tryTitle = not lineType or lineType == 17 -- 17 is QuestTitle
				local activeTitle = tryTitle and questIcons.activeQuests[text]
				if activeTitle then activeID = activeTitle end

				if count then
					local type, index, texture, _
					if activeID then
						index = questIcons.indexByID[activeID]
						_, texture = GetQuestLogSpecialItemInfo(index)
					end

					if texture then
						type = 'QUEST_ITEM'
					else
						local lowerText = strlower(text)

						-- check kill type first
						for _, listText in ipairs(questTypes.KILL) do
							if strfind(lowerText, listText, nil, true) then
								type = 'KILL'
								break
							end
						end

						-- check chat type if kill type doesn't exist
						if not type then
							for _, listText in ipairs(questTypes.CHAT) do
								if strfind(lowerText, listText, nil, true) then
									type = 'CHAT'
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
	for _, object in pairs(questIcons.iconTypes) do
		hideIcon(element[object])
	end
end

local function Update(self, event)
	local element = self.QuestIcons
	if not element then return end

	local unit = self.unit
	if not unit then return end

	-- this only runs on npc units anyways
	if NP.InstanceType ~= 'none' then
		return
	end

	local guid = UnitGUID(unit)
	if element.guid ~= guid then
		element.guid = guid
	elseif event == 'UNIT_NAME_UPDATE' or event == 'NAME_PLATE_UNIT_ADDED' or event == 'ForceUpdate' then
		return -- new guid was the same
	end

	local now = time()
	if element.lastTime ~= now or event ~= 'NAME_PLATE_UNIT_ADDED' then
		element.lastTime = now
	else
		return -- same second
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	local QuestList = GetQuests(unit)
	if QuestList then
		element:Show()

		hideIcons(element)
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

		self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
		self:UnregisterEvent('UNIT_NAME_UPDATE', Path)
	end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('QUEST_ACCEPTED')
frame:RegisterEvent('QUEST_REMOVED')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(self, event)
	wipe(questIcons.indexByID)
	wipe(questIcons.activeQuests)

	if E.Retail then
		for i = 1, C_QuestLog_GetNumQuestLogEntries() do
			local id = C_QuestLog_GetQuestIDForLogIndex(i)
			if id and id > 0 then
				questIcons.indexByID[id] = i

				local title = C_QuestLog_GetTitleForLogIndex(i)
				if title then questIcons.activeQuests[title] = id end
			end
		end
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		self:UnregisterEvent(event)
	end
end)

oUF:AddElement('QuestIcons', Path, Enable, Disable)
