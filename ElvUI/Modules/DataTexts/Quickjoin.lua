local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')
local CH = E:GetModule('Chat')

local next, pairs, select, type = next, pairs, select, type
local format, strjoin, wipe, gsub = format, strjoin, wipe, gsub
local ToggleQuickJoinPanel = ToggleQuickJoinPanel
local SocialQueueUtil_GetQueueName = SocialQueueUtil_GetQueueName
local SocialQueueUtil_GetRelationshipInfo = SocialQueueUtil_GetRelationshipInfo
local C_SocialQueue_GetAllGroups = C_SocialQueue.GetAllGroups
local C_SocialQueue_GetGroupMembers = C_SocialQueue.GetGroupMembers
local C_SocialQueue_GetGroupQueues = C_SocialQueue.GetGroupQueues
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local UNKNOWN, QUICK_JOIN = UNKNOWN, QUICK_JOIN

local displayString = ''
local quickJoin = {}

local function OnEnter()
	if not next(quickJoin) then return end
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(QUICK_JOIN, nil, nil, nil, true)
	DT.tooltip:AddLine(' ')

	for name, activity in pairs(quickJoin) do
		DT.tooltip:AddDoubleLine(name, activity, nil, nil, nil, 1, 1, 1)
	end

	DT.tooltip:Show()
end

local function Update(self)
	wipe(quickJoin)

	if not self then return end

	local quickJoinGroups = C_SocialQueue_GetAllGroups()
	for _, guid in pairs(quickJoinGroups) do
		local players = C_SocialQueue_GetGroupMembers(guid)
		if players then
			local firstMember, numMembers, extraCount = players[1], #players, ''
			local playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
			if numMembers > 1 then extraCount = format(' +%s', numMembers - 1) end

			local queues = C_SocialQueue_GetGroupQueues(guid)
			local firstQueue, numQueues = queues and queues[1], queues and #queues or 0
			local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == 'lfglist'
			local coloredName = (playerName and playerName ~= '' and format('%s%s|r%s', nameColor, playerName, extraCount)) or format('{%s%s}', UNKNOWN, extraCount)

			local activity
			if isLFGList and firstQueue and firstQueue.eligible then
				local activityName, isLeader, leaderName
				if firstQueue.queueData.lfgListID then
					local searchResultInfo = C_LFGList_GetSearchResultInfo(firstQueue.queueData.lfgListID)
					if searchResultInfo then
						activityName, leaderName = searchResultInfo.name, searchResultInfo.leaderName
						isLeader = CH:SocialQueueIsLeader(playerName, leaderName)
					end
				end

				if isLeader then
					coloredName = format([[|TInterface\GroupFrame\UI-Group-LeaderIcon:16:16|t%s]], coloredName)
				end

				activity = activityName or UNKNOWN
				if numQueues > 1 then
					activity = format('[+%s]%s', numQueues - 1, activity)
				end
			elseif firstQueue then
				local output, queueCount = '', 0
				for _, queue in pairs(queues) do
					if type(queue) == 'table' and queue.eligible then
						local queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ''
						if queueName ~= '' then
							if output == '' then
								output = gsub(queueName,'\n.+','') -- grab only the first queue name
								queueCount = queueCount + select(2, gsub(queueName,'\n','')) -- collect additional on single queue
							else
								queueCount = queueCount + 1 + select(2, gsub(queueName,'\n','')) -- collect additional on additional queues
							end
						end
					end
				end
				if output ~= '' then
					if queueCount > 0 then
						activity = format('%s[+%s]', output, queueCount)
					else
						activity = output
					end
				end
			end

			quickJoin[coloredName] = activity
		end
	end

	if E.global.datatexts.settings.QuickJoin.NoLabel then
		self.text:SetFormattedText(displayString, #quickJoinGroups)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.QuickJoin.Label ~= '' and E.global.datatexts.settings.QuickJoin.Label or QUICK_JOIN..': ', #quickJoinGroups)
	end
end

local delayed, lastPanel
local function throttle()
	if lastPanel then Update(lastPanel) end
	delayed = nil
end

local function OnEvent(self, event)
	if lastPanel ~= self then lastPanel = self end
	if delayed then return end

	-- use a nonarg passing function, so that it goes through c_timer instead of the waitframe
	delayed = E:Delay(event == 'ELVUI_FORCE_UPDATE' and 0 or 1, throttle)
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.QuickJoin.NoLabel and '' or '%s', hex, '%d|r')
	if lastPanel then OnEvent(lastPanel) end
end

E.valueColorUpdateFuncs[ValueColorUpdate] = true
DT:RegisterDatatext('QuickJoin', _G.SOCIAL_LABEL, {"SOCIAL_QUEUE_UPDATE"}, OnEvent, nil, ToggleQuickJoinPanel, OnEnter, nil, QUICK_JOIN, nil, ValueColorUpdate)
