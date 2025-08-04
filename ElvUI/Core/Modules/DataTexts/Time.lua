local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next, unpack = next, unpack
local format, strjoin = format, strjoin
local wipe, sort, tinsert = wipe, sort, tinsert
local utf8sub = string.utf8sub

local ToggleFrame = ToggleFrame
local EJ_GetCurrentTier = EJ_GetCurrentTier
local EJ_GetInstanceByIndex = EJ_GetInstanceByIndex
local EJ_GetNumTiers = EJ_GetNumTiers
local EJ_SelectTier = EJ_SelectTier
local GetDifficultyInfo = GetDifficultyInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetNumSavedWorldBosses = GetNumSavedWorldBosses
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetSavedWorldBossInfo = GetSavedWorldBossInfo
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime

local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local VOICE_CHAT_BATTLEGROUND = VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS
local WORLD_BOSSES_TEXT = RAID_INFO_WORLD_BOSS
local WEEKLY_RESET = format('%s %s', WEEKLY, RESET)

local C_Map_GetAreaInfo = C_Map.GetAreaInfo
local C_DateAndTime_GetSecondsUntilDailyReset = C_DateAndTime.GetSecondsUntilDailyReset
local C_DateAndTime_GetSecondsUntilWeeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset

local APM = { _G.TIMEMANAGER_PM, _G.TIMEMANAGER_AM }
local lockoutColorExtended = { r = 0.3, g = 1, b = 0.3 }
local lockoutColorNormal = { r = .8, g = .8, b = .8 }
local lockoutInfoFormat = '%s%s %s |cffaaaaaa(%s, %s/%s)'
local lockoutInfoFormatNoEnc = '%s%s %s |cffaaaaaa(%s)'
local formatBattleGroundInfo = '%s: '
local enteredFrame = false
local updateTime = 5
local displayFormats = {
	na_nocolor = '',
	eu_nocolor = '',
	na_color = '',
	eu_color = ''
}

local allowID = { -- also has IDs maintained in Nameplate StyleFilters
	[2] = true,		-- heroic
	[23] = true,	-- mythic
	[148] = true,	-- ZG/AQ40
	[174] = true,	-- heroic (dungeon)
	[185] = true,	-- normal (legacy)
	[198] = true,	-- Classic: Season of Discovery
	[201] = true,	-- Classic: Hardcore
	[215] = true,	-- Classic: Sunken Temple
}

local lfrID = {
	[7] = true,
	[17] = true
}

local db

local function ToTime(start, seconds)
	return SecondsToTime(start, not seconds, nil, 3)
end

local function ConvertTime(h, m, s)
	local secs = db.seconds and s or ''
	if db.time24 then
		return h, m, secs, -1
	elseif h >= 12 then
		if h > 12 then h = h - 12 end
		return h, m, secs, 1
	else
		if h == 0 then h = 12 end
		return h, m, secs, 2
	end
end

local function GetTimeValues(tooltip)
	local dateTable = E:GetDateTime((tooltip and not db.localTime) or (not tooltip and db.localTime))
	return ConvertTime(dateTable.hour, dateTable.min, dateTable.sec)
end

local function OnClick(_, btn)
	if E:AlertCombat() then return end

	if btn == 'RightButton' then
		ToggleFrame(_G.TimeManagerFrame)
	elseif E.Retail or E.Mists then
		_G.GameTimeFrame:Click()
	end
end

local function OnLeave()
	enteredFrame = false
end

local InstanceNameByID = {
	-- NOTE: for some reason the instanceID from EJ_GetInstanceByIndex doesn't match,
	-- the instanceID from GetInstanceInfo, so use the collectIDs to find the ID to add.
	[749] = C_Map_GetAreaInfo(3845) -- 'The Eye' -> 'Tempest Keep'
}

if E.locale == 'deDE' then -- O.O
	InstanceNameByID[1023] = 'Belagerung von Boralus'	-- 'Die Belagerung von Boralus'
	InstanceNameByID[1041] = 'Königsruh'				-- 'Die Königsruh'
	InstanceNameByID[1021] = 'Kronsteiganwesen'			-- 'Das Kronsteiganwesen'
	InstanceNameByID[1186] = 'Spitzen des Aufstiegs'	-- 'Die Spitzen des Aufstiegs'
	InstanceNameByID[1198] = 'Angriff der Nokhud'		-- 'Der Angriff der Nokhud'
	InstanceNameByID[1203] = 'Azurblaues Gewölbe'		-- 'Das Azurblaue Gewölbe'
end

local instanceIconByName = {}
local instanceIconSuffixes = {
	["Molten Core"] = "moltencore",
	["Blackwing Lair"] = "blackwinglair",
	["Onyxia's Lair"] = "onyxia",
	["Ruins of Ahn'Qiraj"] = "ruinsofahnqiraj",
	["Ahn'Qiraj Temple"] = "templeofahnqiraj",
	["Karazhan"] = "karazhan",
	["Magtheridon's Lair"] = "magtheridonslair",
	["Gruul's Lair"] = "gruulslair",
	["Coilfang: Serpentshrine Cavern"] = "coilfangreservoir",
	["Tempest Keep"] = "tempestkeep",
	["The Battle for Mount Hyjal"] = "cavernsoftime",
	["Black Temple"] = "blacktemple",
	["Naxxramas"] = "naxxramas",
	["The Sunwell"] = "sunwellplateau",
	["Ulduar"] = "ulduar",
	["The Obsidian Sanctum"] = "obsidiansanctum",
	["The Eye of Eternity"] = "eyeofeternity",
	["Trial of the Crusader"] = "trialofthecrusader",
	["Icecrown Citadel"] = "icecrowncitadel",
	["The Ruby Sanctum"] = "rubysanctum"
}

for name, suffix in pairs(instanceIconSuffixes) do
	instanceIconByName[name] = "Interface\\EncounterJournal\\ui-ej-dungeonbutton-" .. suffix
end

local collectIDs, collectedIDs = false -- for testing; mouse over the dt to show the tinspect table (@Merathilis :x)
local function GetInstanceImages(index, raid)
	local instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
	while instanceID do
		if collectIDs then
			if not collectedIDs then
				collectedIDs = {}
			end

			collectedIDs[instanceID] = name
		end

		instanceIconByName[InstanceNameByID[instanceID] or name] = buttonImage
		index = index + 1
		instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid)
	end
end

local krcntw = E.locale == 'koKR' or E.locale == 'zhCN' or E.locale == 'zhTW'
local difficultyTag = { -- Raid Finder, Normal, Heroic, Mythic
	(krcntw and _G.PLAYER_DIFFICULTY3) or utf8sub(_G.PLAYER_DIFFICULTY3, 1, 1),	-- R
	(krcntw and _G.PLAYER_DIFFICULTY1) or utf8sub(_G.PLAYER_DIFFICULTY1, 1, 1),	-- N
	(krcntw and _G.PLAYER_DIFFICULTY2) or utf8sub(_G.PLAYER_DIFFICULTY2, 1, 1),	-- H
	(krcntw and _G.PLAYER_DIFFICULTY6) or utf8sub(_G.PLAYER_DIFFICULTY6, 1, 1)	-- M
}

local function sortFunc(a,b) return a[1] < b[1] end

local collectedImages = false
local function CollectImages()
	local numTiers = (EJ_GetNumTiers() or 0)
	if numTiers > 0 then
		-- Loop through the expansions to collect the textures
		for i=1, numTiers do
			EJ_SelectTier(i)
			GetInstanceImages(1, false) -- Populate for dungeon icons
			GetInstanceImages(1, true) -- Populate for raid icons
		end

		if collectIDs then
			E:Dump(collectedIDs, true)
		end

		-- Set it back to the previous tier
		local currentTier = EJ_GetCurrentTier()
		if currentTier then
			EJ_SelectTier(currentTier)
		end

		collectedImages = true
	end
end

local lockedInstances = { raids = {}, dungeons = {} }
local function OnEnter()
	DT.tooltip:ClearLines()

	if not enteredFrame then
		enteredFrame = true
	end

	local numAreas = GetNumWorldPVPAreas and GetNumWorldPVPAreas()
	if numAreas then
		local addedHeader = false
		for i = 1, numAreas do
			local _, localizedName, isActive, _, startTime, canEnter = GetWorldPVPAreaInfo(i)

			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif not startTime then
				startTime = QUEUE_TIME_UNAVAILABLE
			elseif startTime ~= 0 then
				startTime = ToTime(startTime)
			end

			if canEnter and startTime ~= 0 then
				if not addedHeader then
					DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND)
					addedHeader = true
				end

				DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
			end
		end
	end

	if db.savedInstances then
		if next(lockedInstances.raids) then
			if DT.tooltip:NumLines() > 0 then
				DT.tooltip:AddLine(' ')
			end

			DT.tooltip:AddLine(L["Saved Raid(s)"])

			sort(lockedInstances.raids, sortFunc)

			for _, info in next, lockedInstances.raids do
				local difficultyLetter, buttonImg = info[2], info[3]
				local name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(info[4])

				local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
				if numEncounters and numEncounters > 0 and (encounterProgress and encounterProgress > 0) then
					DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
				else
					DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
				end
			end
		end

		if next(lockedInstances.dungeons) then
			if DT.tooltip:NumLines() > 0 then
				DT.tooltip:AddLine(' ')
			end

			DT.tooltip:AddLine(L["Saved Dungeon(s)"])

			sort(lockedInstances.dungeons, sortFunc)

			for _, info in next, lockedInstances.dungeons do
				local difficultyLetter, buttonImg = info[2], info[3]
				local name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(info[4])

				local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
				if numEncounters and numEncounters > 0 and (encounterProgress and encounterProgress > 0) then
					DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
				else
					DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), ToTime(reset), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
				end
			end
		end
	end

	if E.Retail then
		local addedLine = false
		local worldbossLockoutList = {}
		for i = 1, GetNumSavedWorldBosses() do
			local name, _, reset = GetSavedWorldBossInfo(i)
			tinsert(worldbossLockoutList, {name, reset})
		end

		sort(worldbossLockoutList, sortFunc)

		for _, info in next, worldbossLockoutList do
			local name, reset = unpack(info)
			if reset then
				if not addedLine then
					if DT.tooltip:NumLines() > 0 then
						DT.tooltip:AddLine(' ')
					end

					DT.tooltip:AddLine(WORLD_BOSSES_TEXT)
					addedLine = true
				end
				DT.tooltip:AddDoubleLine(name, ToTime(reset), 1, 1, 1, 0.8, 0.8, 0.8)
			end
		end
	end

	-- Adds world boss checks for MoP Classic
	local sharedPandariaIcon = "Interface\\EncounterJournal\\ui-ej-dungeonbutton-pandaria"
	local mopWorldBossIDs = {
		["Galleon"] = 32098,
		["Sha of Anger"] = 32099,
		["Oondasta"] = 32519,
		["Nalak"] = 32518
	}
	
	local mopWorldBosses = {}
	local worldBossIconByName = {}
	
	for name, questID in pairs(mopWorldBossIDs) do
		tinsert(mopWorldBosses, { name = name, questID = questID })
		worldBossIconByName[name] = sharedPandariaIcon
	end

	local weeklyReset = C_DateAndTime_GetSecondsUntilWeeklyReset()
	local addedHeader = false
	
	for _, boss in ipairs(mopWorldBosses) do
	    if C_QuestLog.IsQuestFlaggedCompleted(boss.questID) then
	        if not addedHeader then
	            DT.tooltip:AddLine(" ")
	            DT.tooltip:AddLine("World Bosses")
	            addedHeader = true
	        end
	
	        local icon = worldBossIconByName[boss.name] and format('|T%s:16:16:0:0:96:96:0:64:0:64|t ', worldBossIconByName[boss.name]) or ''
	        DT.tooltip:AddDoubleLine(icon .. boss.name, ToTime(weeklyReset), 1, 1, 1, 0.8, 0.8, 0.8)
	    end
	end

	local Hr, Min, Sec, AmPm = GetTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(' ')
	end

	local dailyReset = C_DateAndTime_GetSecondsUntilDailyReset()
	if dailyReset then
		DT.tooltip:AddDoubleLine(L["Daily Reset"], ToTime(dailyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	local weeklyReset = C_DateAndTime_GetSecondsUntilWeeklyReset()
	if weeklyReset then
		DT.tooltip:AddDoubleLine(WEEKLY_RESET, ToTime(weeklyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	DT.tooltip:AddDoubleLine(db.localTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, format(displayFormats[AmPm == -1 and 'eu_nocolor' or 'na_nocolor'], Hr, Min, Sec, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == 'ELVUI_FORCE_UPDATE' or event == 'BOSS_KILL' then
		RequestRaidInfo()

		if not collectedImages then
			CollectImages()
		end
	elseif event == 'LOADING_SCREEN_ENABLED' then
		if enteredFrame then
			OnLeave()
		end
	else
		wipe(lockedInstances.raids)
		wipe(lockedInstances.dungeons)

		for i = 1, GetNumSavedInstances() do
			local info = { GetSavedInstanceInfo(i) } -- we want to send entire info
			local name, _, _, difficulty, locked, extended, _, isRaid = unpack(info)
			if name and (locked or extended) and (isRaid or allowID[difficulty]) then
				local isLFR = lfrID[difficulty]
				local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficulty)
				local sortName = name .. (displayMythic and 4 or (isHeroic or displayHeroic) and 3 or isLFR and 1 or 2)
				local difficultyLetter = (displayMythic and difficultyTag[4]) or ((isHeroic or displayHeroic) and difficultyTag[3]) or (isLFR and difficultyTag[1]) or difficultyTag[2]
				local buttonImg = instanceIconByName[name] and format('|T%s:16:16:0:0:96:96:0:64:0:64|t ', instanceIconByName[name]) or ''

				tinsert(lockedInstances[isRaid and 'raids' or 'dungeons'], { sortName, difficultyLetter, buttonImg, info })
			end
		end

		if enteredFrame then
			OnEnter(self)
		end
	end
end

local function OnUpdate(self, t)
	self.timeElapsed = (self.timeElapsed or updateTime) - t
	if self.timeElapsed > 0 then return end
	self.timeElapsed = updateTime

	if db.flashInvite and _G.GameTimeFrame.flashInvite then
		E:Flash(self, 0.5, true)
	else
		E:StopFlash(self, 1)
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, Sec, AmPm = GetTimeValues()
	self.text:SetFormattedText(displayFormats[AmPm == -1 and 'eu_color' or 'na_color'], Hr, Min, Sec, APM[AmPm])
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	updateTime = db.seconds and 1 or 5

	local sec = db.seconds and ':|r%02d' or '|r%s'
	displayFormats.eu_nocolor = strjoin('', '%02d', ':|r%02d', sec)
	displayFormats.na_nocolor = strjoin('', '', '%d', ':|r%02d', sec, ' %s|r')
	displayFormats.eu_color = strjoin('', '%02d', hex, ':|r%02d', hex, sec)
	displayFormats.na_color = strjoin('', '', '%d', hex, ':|r%02d', hex, sec, hex, ' %s|r')

	OnUpdate(self, 20000)
end

DT:RegisterDatatext('Time', nil, { 'LOADING_SCREEN_ENABLED', 'UPDATE_INSTANCE_INFO', 'BOSS_KILL' }, OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, nil, nil, ApplySettings)
