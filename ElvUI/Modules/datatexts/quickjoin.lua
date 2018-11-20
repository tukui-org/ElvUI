local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
local UNKNOWN = UNKNOWN
local QUICK_JOIN = QUICK_JOIN
--Lua functions
local next, pairs, select, type = next, pairs, select, type
local twipe = table.wipe
local format, join = string.format, string.join
--WoW API / Variables
local C_LFGList = C_LFGList
local C_SocialQueue = C_SocialQueue
local SocialQueueUtil_GetRelationshipInfo = SocialQueueUtil_GetRelationshipInfo
local SocialQueueUtil_GetQueueName = SocialQueueUtil_GetQueueName
local SocialQueueUtil_SortGroupMembers = SocialQueueUtil_SortGroupMembers
local ToggleQuickJoinPanel = ToggleQuickJoinPanel

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local displayModifierString = ''
local lastPanel;

local quickJoinGroups, quickJoin = nil, {}

local function OnEnter(self)
	DT:SetupTooltip(self)

	if not next(quickJoin) then return end

	DT.tooltip:AddLine(QUICK_JOIN, nil, nil, nil, true);
	DT.tooltip:AddLine(" ");
	for name, activity in pairs(quickJoin) do
		DT.tooltip:AddDoubleLine(name, activity, nil, nil, nil, 1, 1, 1);
	end

	DT.tooltip:Show()
end

local CHAT
local function OnEvent(self)
	twipe(quickJoin)
	quickJoinGroups = C_SocialQueue.GetAllGroups()

	if not CHAT then CHAT = E:GetModule("Chat") end --load order issue requires this to be here, could probably change load order to fix...

	local coloredName, players, members, playerName, nameColor, firstMember, numMembers, extraCount, isLFGList, firstQueue, queues, numQueues, activityID, activityName, leaderName, isLeader, activityFullName, activity, output, queueCount, queueName, _

	for _, guid in pairs(quickJoinGroups) do
		coloredName, players = UNKNOWN, C_SocialQueue.GetGroupMembers(guid)
		members = players and SocialQueueUtil_SortGroupMembers(players)
		playerName = ""
		if members then
			firstMember, numMembers, extraCount = members[1], #members, ''
			playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
			if numMembers > 1 then
				extraCount = format('[+%s]', numMembers - 1)
			end
			if playerName then
				coloredName = format('%s%s|r%s', nameColor, playerName, extraCount)
			else
				coloredName = format('{%s%s}', UNKNOWN, extraCount)
			end
		end

		queues = C_SocialQueue.GetGroupQueues(guid)
		firstQueue, numQueues = queues and queues[1], queues and #queues or 0
		isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == 'lfglist'

		if isLFGList and firstQueue and firstQueue.eligible then

			if firstQueue.queueData.lfgListID then
				_, activityID, activityName, _, _, _, _, _, _, _, _, _, leaderName = C_LFGList.GetSearchResultInfo(firstQueue.queueData.lfgListID)
				isLeader = CHAT:SocialQueueIsLeader(playerName, leaderName)
			end

			--[[if activityID or firstQueue.queueData.activityID then
				activityFullName = C_LFGList.GetActivityInfo(activityID or firstQueue.queueData.activityID)
			end]]

			if isLeader then
				coloredName = format("|TInterface\\GroupFrame\\UI-Group-LeaderIcon:16:16|t%s", coloredName)
			end

			activity = --[[activityFullName and activityFullName or ]]activityName or UNKNOWN
			if numQueues > 1 then
				activity = format("[+%s]%s", numQueues - 1, activity)
			end
		elseif firstQueue then
			output, queueCount = '', 0
			for _, queue in pairs(queues) do
				if type(queue) == 'table' and queue.eligible then
					queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ''
					if queueName ~= '' then
						if output == '' then
							output = queueName:gsub('\n.+','') -- grab only the first queue name
							queueCount = queueCount + select(2, queueName:gsub('\n','')) -- collect additional on single queue
						else
							queueCount = queueCount + 1 + select(2, queueName:gsub('\n','')) -- collect additional on additional queues
						end
					end
				end
			end
			if output ~= '' then
				if queueCount > 0 then
					activity = format("%s[+%s]", output, queueCount)
				else
					activity = output
				end
			end
		end

		quickJoin[coloredName] = activity
	end

	self.text:SetFormattedText(displayModifierString, QUICK_JOIN, #quickJoinGroups)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayModifierString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Quick Join', {"SOCIAL_QUEUE_UPDATE", "PLAYER_ENTERING_WORLD"}, OnEvent, nil, ToggleQuickJoinPanel, OnEnter, nil, QUICK_JOIN)
