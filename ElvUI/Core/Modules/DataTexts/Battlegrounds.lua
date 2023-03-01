local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local sort = sort
local ipairs = ipairs
local strjoin = strjoin
local tonumber = tonumber

local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatData = GetBattlefieldStatData
local GetBattlefieldScore = GetBattlefieldScore

local C_PvP_GetMatchPVPStatColumns = C_PvP.GetMatchPVPStatColumns

local displayString = ''
local data = { killingBlows = 0, honorableKills = 0, healingDone = 0, deaths = 0, damageDone = 0, honorGained = 0 }

local function GetBattleStats(name)
	if name == 'PvP: Kills' then
		return _G.KILLING_BLOWS, data.killingBlows
	elseif name == 'PvP: Honorable Kills' then
		return _G.HONORABLE_KILLS, data.honorableKills
	elseif name == 'PvP: Heals' then
		return (E.Retail and _G.SHOW_COMBAT_HEALING) or _G.HEALS, data.healingDone
	elseif name == 'PvP: Deaths' then
		return _G.DEATHS, data.deaths
	elseif name == 'PvP: Damage Done' then
		return _G.DAMAGE, data.damageDone
	elseif name == 'PvP: Honor Gained' then
		return _G.HONOR, data.honorGained
	elseif name == 'PvP: Objectives' then
		return _G.OBJECTIVES_LABEL
	end
end

function DT:UPDATE_BATTLEFIELD_SCORE()
	data.myIndex = nil

	for i = 1, GetNumBattlefieldScores() do
		local name, _
		if E.Classic or E.Wrath then
			name, data.killingBlows, data.honorableKills, data.deaths, data.honorGained, _, _, _, _, _, data.damageDone, data.healingDone = GetBattlefieldScore(i)
		else
			name, data.killingBlows, data.honorableKills, data.deaths, data.honorGained, _, _, _, _, data.damageDone, data.healingDone = GetBattlefieldScore(i)
		end

		if name == E.myname then
			data.myIndex = i
			break
		end
	end
end

local function columnSort(lhs, rhs)
	return lhs.orderIndex < rhs.orderIndex
end

function DT:HoverBattleStats() -- Objectives OnEnter -- Idea is to store this in a table and probably rotate it on the text field.
	DT.tooltip:ClearLines()

	if data.myIndex and DT.ShowingBattleStats == 'pvp' then
		local columns = C_PvP_GetMatchPVPStatColumns()
		if columns then
			sort(columns, columnSort)

			-- Add extra statistics to watch based on what BG you are in.
			for i, stat in ipairs(columns) do
				if stat.name then
					DT.tooltip:AddDoubleLine(stat.name, GetBattlefieldStatData(data.myIndex, i), 1,1,1)
				end
			end

			DT.tooltip:Show()
		end
	end
end

DT.ForceHideBGStats = false
function DT:ToggleBattleStats()
	DT.ForceHideBGStats = not DT.ForceHideBGStats

	if DT.ForceHideBGStats then
		E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats"])
	else
		E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
	end

	DT:LoadDataTexts()
end

local function OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.needsUpdate and self.timeSinceUpdate > 0.3 then -- this will allow the main event to update the dt
		local locale, value = GetBattleStats(self.name)
		if value then
			self.text:SetFormattedText(displayString, locale, E:ShortValue(tonumber(value) or 0))
		else
			self.text:SetFormattedText('%s', locale)
		end

		self.needsUpdate = false
	end
end

local function OnEvent(self)
	self.timeSinceUpdate = 0
	self.needsUpdate = true
end

local function ValueColorUpdate(_, hex)
	displayString = strjoin('', '%s: ', hex, '%s|r')
end

E.valueColorUpdateFuncs.Battlegrounds = ValueColorUpdate

DT:RegisterDatatext('PvP: Kills', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)
DT:RegisterDatatext('PvP: Honorable Kills', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)
DT:RegisterDatatext('PvP: Heals', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)
DT:RegisterDatatext('PvP: Deaths', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)
DT:RegisterDatatext('PvP: Damage Done', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)
DT:RegisterDatatext('PvP: Honor Gained', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats)

if E.Retail then
	DT:RegisterDatatext('PvP: Objectives', 'PvP', { 'UPDATE_BATTLEFIELD_SCORE' }, OnEvent, OnUpdate, DT.ToggleBattleStats, DT.HoverBattleStats)
end
