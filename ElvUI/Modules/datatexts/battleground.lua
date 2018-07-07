local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatInfo = GetBattlefieldStatInfo
local GetBattlefieldStatData = GetBattlefieldStatData
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit

local lastPanel
local displayString = ''
local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]
local dataLayout = {
	['LeftChatDataPanel'] = {
		['left'] = 10,
		['middle'] = 5,
		['right'] = 2,
	},
	['RightChatDataPanel'] = {
		['left'] = 4,
		['middle'] = 3,
		['right'] = 11,
	},
}

local dataStrings = {
	[10] = DAMAGE,
	[5] = HONOR,
	[2] = KILLING_BLOWS,
	[4] = DEATHS,
	[3] = KILLS,
	[11] = SHOW_COMBAT_HEALING,
}

local mapObjectives = {
	[112] = 1, -- EOTS
	[423] = 1, -- SSM
	[907] = 1, -- SS
	[623] = 1, -- SSvsTM -- needs to confirm only 1 objective??

	 [92] = 2, -- WSG
	 [93] = 2, -- AB
	[128] = 2, -- SOTA -- still listed and in game, so leaving it here
	[169] = 2, -- IOC
	[206] = 2, -- TP
	[275] = 2, -- TBFG
	[417] = 2, -- TOK
	[837] = 2, -- WAB

	 [91] = 4, -- AV
	[519] = 4, -- DG
}

local name
local select = select

function DT:UPDATE_BATTLEFIELD_SCORE()
	lastPanel = self
	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex]
	for i=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(i)
		if name == E.myname then
			self.text:SetFormattedText(displayString, dataStrings[pointIndex], E:ShortValue(select(pointIndex, GetBattlefieldScore(i))))
			break
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self)

	local CurrentMapID = C_Map_GetBestMapForUnit("player")

	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name and name == E.myname then
			DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1,1,1, classColor.r, classColor.g, classColor.b)
			DT.tooltip:AddLine(" ")

			--Add extra statistics to watch based on what BG you are in.
			if mapObjectives[CurrentMapID] then
				for x=1, mapObjectives[CurrentMapID] do
					DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(x), GetBattlefieldStatData(index, x), 1,1,1)
				end
			end

			break
		end
	end

	DT.tooltip:Show()
end

function DT:HideBattlegroundTexts()
	DT.ForceHideBGStats = true
	DT:LoadDataTexts()
	E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats or right click the 'C' icon near the minimap."])
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true