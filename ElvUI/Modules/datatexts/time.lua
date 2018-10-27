local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local next, unpack = next, unpack
local format, join = string.format, string.join
local tsort, tinsert = table.sort, table.insert
local date, utf8sub = date, string.utf8sub

--WoW API / Variables
local GetGameTime = GetGameTime
local RequestRaidInfo = RequestRaidInfo
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local SecondsToTime = SecondsToTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetDifficultyInfo = GetDifficultyInfo
local GetNumSavedWorldBosses = GetNumSavedWorldBosses
local GetSavedWorldBossInfo = GetSavedWorldBossInfo
local VOICE_CHAT_BATTLEGROUND = VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = WINTERGRASP_IN_PROGRESS
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local TIMEMANAGER_TOOLTIP_REALMTIME = TIMEMANAGER_TOOLTIP_REALMTIME
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME
local EJ_GetInstanceByIndex = EJ_GetInstanceByIndex
local EJ_SelectTier = EJ_SelectTier
local EJ_GetNumTiers = EJ_GetNumTiers
local EJ_GetCurrentTier = EJ_GetCurrentTier
local GetAchievementInfo = GetAchievementInfo

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTimeFrame

local WORLD_BOSSES_TEXT = RAID_INFO_WORLD_BOSS.."(s)"
local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }
local europeDisplayFormat = '';
local ukDisplayFormat = '';
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = join("", "", "%d", ":|r%02d", " %s|r")
local lockoutInfoFormat = "%s%s %s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s%s %s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local curHr, curMin, curAmPm
local enteredFrame = false;

local Update, lastPanel; -- UpValue

local function ValueColorUpdate(hex)
	europeDisplayFormat = join("", "%02d", hex, ":|r%02d")
	ukDisplayFormat = join("", "", "%d", hex, ":|r%02d", hex, " %s|r")

	if lastPanel ~= nil then
		Update(lastPanel, 20000)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

local function ConvertTime(h, m)
	local AmPm
	if E.db.datatexts.time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and E.db.datatexts.localtime) or (not tooltip and not E.db.datatexts.localtime) then
		return ConvertTime(GetGameTime())
	else
		local dateTable = date("*t")
		return ConvertTime(dateTable.hour, dateTable.min)
	end
end

local function Click()
	GameTimeFrame:Click();
end

local function OnLeave()
	DT.tooltip:Hide();
	enteredFrame = false;
end

-- use these to convert "The Eye" into "Tempest Keep"
local DUNGEON_FLOOR_TEMPESTKEEP1 = DUNGEON_FLOOR_TEMPESTKEEP1
local TempestKeep = select(2, GetAchievementInfo(1088)):match('%((.-)%)$')

local instanceIconByName = {}
local function GetInstanceImages(index, raid)
	local instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid);
	while instanceID do
		if name == DUNGEON_FLOOR_TEMPESTKEEP1 then
			instanceIconByName[TempestKeep] = buttonImage
		else
			instanceIconByName[name] = buttonImage
		end
		index = index + 1
		instanceID, name, _, _, buttonImage = EJ_GetInstanceByIndex(index, raid);
	end
end

local locale = GetLocale()
local krcntw = locale == "koKR" or locale == "zhCN" or locale == "zhTW"
local difficultyTag = { -- Raid Finder, Normal, Heroic, Mythic
	(krcntw and PLAYER_DIFFICULTY3) or utf8sub(PLAYER_DIFFICULTY3, 1, 1), -- R
	(krcntw and PLAYER_DIFFICULTY1) or utf8sub(PLAYER_DIFFICULTY1, 1, 1), -- N
	(krcntw and PLAYER_DIFFICULTY2) or utf8sub(PLAYER_DIFFICULTY2, 1, 1), -- H
	(krcntw and PLAYER_DIFFICULTY6) or utf8sub(PLAYER_DIFFICULTY6, 1, 1)  -- M
}

local collectedInstanceImages = false
local function OnEnter(self)
	DT:SetupTooltip(self)

	if(not enteredFrame) then
		enteredFrame = true;
		RequestRaidInfo()
	end

	if not collectedInstanceImages then
		local numTiers = (EJ_GetNumTiers() or 0)
		if numTiers > 0 then
			local currentTier = EJ_GetCurrentTier()

			-- Loop through the expansions to collect the textures
			for i=1, numTiers do
				EJ_SelectTier(i);
				GetInstanceImages(1, false); -- Populate for dungeon icons
				GetInstanceImages(1, true); -- Populate for raid icons
			end

			-- Set it back to the previous tier
			if currentTier then
				EJ_SelectTier(currentTier);
			end

			collectedInstanceImages = true
		end
	end

	local addedHeader = false
	local localizedName, isActive, startTime, canEnter, _

	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, _, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if not addedHeader then
				DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND)
				addedHeader = true
			end
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
		end
	end

	local lockedInstances = {raids = {}, dungeons = {}}
	local name, difficulty, locked, extended, isRaid
	local isLFR, isHeroicOrMythicDungeon, isHeroic, displayHeroic, displayMythic, sortName, difficultyLetter, buttonImg

	for i = 1, GetNumSavedInstances() do
		name, _, _, difficulty, locked, extended, _, isRaid = GetSavedInstanceInfo(i);
		if (locked or extended) and name then
			isLFR, isHeroicOrMythicDungeon = (difficulty == 7 or difficulty == 17), (difficulty == 2 or difficulty == 23)
			_, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficulty)
			sortName = name .. (displayMythic and 4 or (isHeroic or displayHeroic) and 3 or isLFR and 1 or 2)
			difficultyLetter = (displayMythic and difficultyTag[4] or (isHeroic or displayHeroic) and difficultyTag[3] or isLFR and difficultyTag[1] or difficultyTag[2])
			buttonImg = instanceIconByName[name] and format("|T%s:16:16:0:0:96:96:0:64:0:64|t ", instanceIconByName[name]) or ""

			if isRaid then
				tinsert(lockedInstances.raids, {sortName, difficultyLetter, buttonImg, {GetSavedInstanceInfo(i)}})
			elseif isHeroicOrMythicDungeon then
				tinsert(lockedInstances.dungeons, {sortName, difficultyLetter, buttonImg, {GetSavedInstanceInfo(i)}})
			end
		end
	end

	local reset, maxPlayers, numEncounters, encounterProgress, lockoutColor
	if next(lockedInstances.raids) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(" ")
		end
		DT.tooltip:AddLine(L["Saved Raid(s)"])

		tsort(lockedInstances.raids, function( a,b ) return a[1] < b[1] end)

		for i = 1, #lockedInstances.raids do
			difficultyLetter = lockedInstances.raids[i][2]
			buttonImg = lockedInstances.raids[i][3]
			name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(lockedInstances.raids[i][4])

			lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	if next(lockedInstances.dungeons) then
		if DT.tooltip:NumLines() > 0 then
			DT.tooltip:AddLine(" ")
		end
		DT.tooltip:AddLine(L["Saved Dungeon(s)"])

		tsort(lockedInstances.dungeons, function( a,b ) return a[1] < b[1] end)

		for i = 1,#lockedInstances.dungeons do
			difficultyLetter = lockedInstances.dungeons[i][2]
			buttonImg = lockedInstances.dungeons[i][3]
			name, _, reset, _, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(lockedInstances.dungeons[i][4])

			lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, buttonImg, maxPlayers, difficultyLetter, name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, buttonImg, maxPlayers, difficultyLetter, name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end
		end
	end

	local addedLine = false
	local worldbossLockoutList = {}
	for i = 1, GetNumSavedWorldBosses() do
		name, _, reset = GetSavedWorldBossInfo(i)
		tinsert(worldbossLockoutList, {name, reset})
	end
	tsort(worldbossLockoutList, function( a,b ) return a[1] < b[1] end)
	for i = 1,#worldbossLockoutList do
		name, reset = unpack(worldbossLockoutList[i])
		if(reset) then
			if(not addedLine) then
				if DT.tooltip:NumLines() > 0 then
					DT.tooltip:AddLine(" ")
				end
				DT.tooltip:AddLine(WORLD_BOSSES_TEXT)
				addedLine = true
			end
			DT.tooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)
		end
	end

	local Hr, Min, AmPm = CalculateTimeValues(true)
	if DT.tooltip:NumLines() > 0 then
		DT.tooltip:AddLine(" ")
	end
	if AmPm == -1 then
		DT.tooltip:AddDoubleLine(E.db.datatexts.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		DT.tooltip:AddDoubleLine(E.db.datatexts.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	DT.tooltip:Show()
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		OnEnter(self)
	end
end

local int = 3
function Update(self, t)
	int = int - t

	if int > 0 then return end

	if GameTimeFrame.flashInvite then
		E:Flash(self, 0.53, true)
	else
		E:StopFlash(self)
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end

	curHr = Hr
	curMin = Min
	curAmPm = AmPm

	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
	lastPanel = self
	int = 5
end

DT:RegisterDatatext('Time', {"UPDATE_INSTANCE_INFO"}, OnEvent, Update, Click, OnEnter, OnLeave)
