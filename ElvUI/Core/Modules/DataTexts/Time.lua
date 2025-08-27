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
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted

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

local db
local OVERRIDE_ICON = [[Interface\EncounterJournal\UI-EJ-Dungeonbutton-%s]]
local BOSSNAME_MIST = [[|TInterface\EncounterJournal\UI-EJ-Dungeonbutton-pandaria:16:16:0:0:96:96:0:64:0:64|t %s]]
local BOSSNAME_TWW = [[|TInterface\EncounterJournal\UI-EJ-Dungeonbutton-khazalgar:16:16:0:0:96:96:0:64:0:64|t %s]]

local WORLD_BOSSES_MIST = {
	[32098] = 'Galleon',
	[32099] = 'Sha of Anger',
	[32519] = 'Oondasta',
	[33117] = 'Celestials', -- ChiJi, Yulon, Niuzao, Xuen
	[33118] = 'Ordos',
	[32518] = 'Nalak'
}

local ALLOW_ID = { -- also has IDs maintained in Nameplate StyleFilters
	[2] = true,		-- heroic
	[23] = true,	-- mythic
	[148] = true,	-- ZG/AQ40
	[174] = true,	-- heroic (dungeon)
	[185] = true,	-- normal (legacy)
	[198] = true,	-- Classic: Season of Discovery
	[201] = true,	-- Classic: Hardcore
	[215] = true,	-- Classic: Sunken Temple
}

local LFR_ID = {
	[7] = true,
	[17] = true
}

local ICON_EJ = {
	[521746] = 'default',
	[522349] = 'baradinhold',
	[522350] = 'blackrockcaverns',
	[522351] = 'blackwingdescent',
	[522352] = 'deadmines',
	[522353] = 'firelands1',
	[522354] = 'grimbatol',
	[522355] = 'grimbatolraid',
	[522356] = 'hallsoforigination',
	[522357] = 'lostcityoftolvir',
	[522358] = 'shadowfangkeep',
	[522359] = 'skywallraid',
	[522360] = 'thestonecore',
	[522361] = 'thevortexpinnacle',
	[522362] = 'throneofthetides',
	[522363] = 'zulaman',
	[522364] = 'zulgurub',
	[571753] = 'dragonsoul',
	[571754] = 'endtime',
	[571755] = 'houroftwilight',
	[571756] = 'wellofeternity',
	[608192] = 'ahnkahettheoldkingdom',
	[608193] = 'auchindoun',
	[608194] = 'azjolnerub',
	[608195] = 'blackfathomdeeps',
	[608196] = 'blackrockdepths',
	[608197] = 'blackrockspire',
	[608198] = 'cavernsoftime',
	[608199] = 'coilfangreservoir',
	[608200] = 'diremaul',
	[608201] = 'draktharonkeep',
	[608202] = 'gnomeregan',
	[608203] = 'gundrak',
	[608204] = 'hallsoflightning',
	[608205] = 'hallsofreflection',
	[608206] = 'hallsofstone',
	[608207] = 'hellfirecitadel',
	[608208] = 'magistersterrace',
	[608209] = 'maraudon',
	[608210] = 'pitofsaron',
	[608211] = 'ragefirechasm',
	[608212] = 'razorfendowns',
	[608213] = 'razorfenkraul',
	[608214] = 'scarletmonastery',
	[608215] = 'scholomance',
	[608216] = 'stratholme',
	[608217] = 'sunkentemple',
	[608218] = 'tempestkeep',
	[608219] = 'thecullingofstratholme',
	[608220] = 'theforgeofsouls',
	[608221] = 'thenexus',
	[608222] = 'theoculus',
	[608223] = 'thestockade',
	[608224] = 'trialofthechampion',
	[608225] = 'uldaman',
	[608226] = 'utgardekeep',
	[608227] = 'utgardepinnacle',
	[608228] = 'violethold',
	[608229] = 'wailingcaverns',
	[608230] = 'zulfarrak',
	[632270] = 'gateofthesettingsun',
	[632271] = 'heartoffear',
	[632272] = 'mogushanpalace',
	[632273] = 'mogushanvaults',
	[632274] = 'shadowpanmonastery',
	[632275] = 'stormstoutbrewery',
	[632276] = 'templeofthejadeserpent',
	[643262] = 'scarlethalls',
	[643263] = 'siegeofnizaotemple',
	[643264] = 'terraceoftheendlessspring',
	[652218] = 'pandaria',
	[828453] = 'thunderkingraid',
	[904981] = 'siegeoforgrimmar',
	[1041992] = 'auchindounwod',
	[1041993] = 'blackrockfoundry',
	[1041994] = 'bloodmaulslagmines',
	[1041995] = 'draenor',
	[1041996] = 'grimraildepot',
	[1041997] = 'highmaul',
	[1041998] = 'shadowmoonburialgrounds',
	[1041999] = 'skyreach',
	[1042000] = 'upperblackrockspire',
	[1060547] = 'everbloom',
	[1060548] = 'irondocks',
	[1135118] = 'hellfireraid',
	[1396579] = 'blacktemple',
	[1396580] = 'blackwinglair',
	[1396581] = 'eyeofeternity',
	[1396582] = 'gruulslair',
	[1396583] = 'icecrowncitadel',
	[1396584] = 'karazhan',
	[1396585] = 'magtheridonslair',
	[1396586] = 'moltencore',
	[1396587] = 'naxxramas',
	[1396588] = 'obsidiansanctum',
	[1396589] = 'onyxia',
	[1396590] = 'rubysanctum',
	[1396591] = 'ruinsofahnqiraj',
	[1396592] = 'sunwellplateau',
	[1396593] = 'templeofahnqiraj',
	[1396594] = 'trialofthecrusader',
	[1396595] = 'ulduar',
	[1396596] = 'vaultofarchavon',
	[1411853] = 'blackrookhold',
	[1411854] = 'brokenisles',
	[1411855] = 'darkheartthicket',
	[1411856] = 'mawofsouls',
	[1411857] = 'thearcway',
	[1411858] = 'vaultofthewardens',
	[1450574] = 'neltharionslair',
	[1450575] = 'thenighthold',
	[1452687] = 'theemeraldnightmare',
	[1498155] = 'assaultonviolethold',
	[1498156] = 'courtofstars',
	[1498157] = 'eyeofazshara',
	[1498158] = 'hallsofvalor',
	[1537283] = 'returntokarazhan',
	[1537284] = 'trialofvalor',
	[1616106] = 'tombofsargeras',
	[1616922] = 'cathedralofeternalnight',
	[1718211] = 'antorus',
	[1718212] = 'argus',
	[1718213] = 'seatofthetriumvirate',
	[1778892] = 'ataldazar',
	[1778893] = 'freehold',
	[2178269] = 'kingsrest',
	[2178270] = 'kultiras',
	[2178271] = 'shrineofthestorm',
	[2178272] = 'siegeofboralus',
	[2178273] = 'templeofsethraliss',
	[2178274] = 'themotherlode',
	[2178275] = 'theunderrot',
	[2178276] = 'toldagor',
	[2178277] = 'uldir',
	[2178278] = 'waycrestmanor',
	[2178279] = 'zandalar',
	[2482729] = 'battleofdazaralor',
	[2498193] = 'crucibleofstorms',
	[3025320] = 'eternalpalace',
	[3025325] = 'mechagon',
	[3221463] = 'nyalotha',
	[3759906] = 'castlenathria',
	[3759907] = 'darkmaulcitadel',
	[3759908] = 'hallsofatonement',
	[3759909] = 'mistsoftirnascithe',
	[3759910] = 'necroticwake',
	[3759911] = 'plaguefall',
	[3759912] = 'sanguinedepths',
	[3759913] = 'spiresofascension',
	[3759914] = 'theaterofpain',
	[3759915] = 'theotherside',
	[3850569] = 'shadowlands',
	[4182020] = 'sanctumofdomination',
	[4182022] = 'tazaveshtheveiledmarket',
	[4423752] = 'sepulcherofthefirstones',
	[4742829] = 'arcanevaults',
	[4742923] = 'brackenhidehollow',
	[4742924] = 'centaurplains',
	[4742925] = 'dragonislescontinent',
	[4742926] = 'hallsofinfusion',
	[4742927] = 'lifepools',
	[4742928] = 'neltharius',
	[4742929] = 'theacademy',
	[4742930] = 'uldamanlegacyoftyr',
	[4742931] = 'vaultoftheincarnates',
	[5149418] = 'aberrus',
	[5221768] = 'dawnoftheinfinite',
	[5409261] = 'emeralddream',
	[5912546] = 'arakaracityofechoes',
	[5912547] = 'cinderbrewmeadery',
	[5912548] = 'cityofthreads',
	[5912549] = 'darkflamecleft',
	[5912550] = 'nerubarpalace',
	[5912551] = 'prioryofthesacredflames',
	[5912552] = 'thedawnbreaker',
	[5912553] = 'therookery',
	[5912554] = 'thestonevault',
	[5917063] = 'khazalgar',
	[6422411] = 'casino',
	[6422412] = 'waterworks',
	[7050019] = 'manaforge',
	[7074042] = 'ecodome'
}

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

		local overrideImage = not E.Retail and ICON_EJ[buttonImage]
		local overrideName = InstanceNameByID[instanceID] or name
		instanceIconByName[overrideName] = overrideImage and format(OVERRIDE_ICON, overrideImage) or buttonImage

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

local function SortFunc(a,b) return a[1] < b[1] end

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

			sort(lockedInstances.raids, SortFunc)

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

			sort(lockedInstances.dungeons, SortFunc)

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

	local dailyReset = C_DateAndTime_GetSecondsUntilDailyReset()
	local weeklyReset = C_DateAndTime_GetSecondsUntilWeeklyReset()

	if not E.Classic then
		local addedLine = false
		local worldbossLockoutList = {}

		if E.Retail then
			for i = 1, GetNumSavedWorldBosses() do
				local name, _, reset = GetSavedWorldBossInfo(i)
				tinsert(worldbossLockoutList, { format(BOSSNAME_TWW, name), reset })
			end

			sort(worldbossLockoutList, SortFunc)
		elseif E.Mists then
			for questID, name in next, WORLD_BOSSES_MIST do
				if C_QuestLog_IsQuestFlaggedCompleted(questID) then
					tinsert(worldbossLockoutList, { format(BOSSNAME_MIST, name), weeklyReset })
				end
			end
		end

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

	local Hr, Min, Sec, AmPm = GetTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(' ')
	end

	if dailyReset then
		DT.tooltip:AddDoubleLine(L["Daily Reset"], ToTime(dailyReset), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

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
			if name and (locked or extended) and (isRaid or ALLOW_ID[difficulty]) then
				local isLFR = LFR_ID[difficulty]
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
