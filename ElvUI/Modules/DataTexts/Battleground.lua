local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local _G = _G
local select = select
local strjoin = strjoin
--WoW API / Variables
local C_PvP_GetMatchPVPStatIDs = C_PvP.GetMatchPVPStatIDs
local C_PvP_GetMatchPVPStatColumn = C_PvP.GetMatchPVPStatColumn
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatData = GetBattlefieldStatData

local displayString, lastPanel = ''
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
	[10] = _G.DAMAGE,
	[5] = _G.HONOR,
	[2] = _G.KILLING_BLOWS,
	[4] = _G.DEATHS,
	[3] = _G.KILLS,
	[11] = _G.SHOW_COMBAT_HEALING,
}

function DT:UPDATE_BATTLEFIELD_SCORE()
	lastPanel = self
	local pointIndex = dataLayout[self:GetParent():GetName()][self.pointIndex]
	for i=1, GetNumBattlefieldScores() do
		local name = GetBattlefieldScore(i)
		if name == E.myname then
			self.text:SetFormattedText(displayString, dataStrings[pointIndex], E:ShortValue(select(pointIndex, GetBattlefieldScore(i))))
			break
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self)

	local classColor = (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass]) or _G.RAID_CLASS_COLORS[E.myclass]
	local pvpStatIDs = C_PvP_GetMatchPVPStatIDs()
	if pvpStatIDs then
		for index = 1, GetNumBattlefieldScores() do
			local name = GetBattlefieldScore(index)
			if name and name == E.myname then
				DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1,1,1, classColor.r, classColor.g, classColor.b)
				DT.tooltip:AddLine(" ")

				-- Add extra statistics to watch based on what BG you are in.
				for x = 1, #pvpStatIDs do
					DT.tooltip:AddDoubleLine(C_PvP_GetMatchPVPStatColumn(pvpStatIDs[x]), GetBattlefieldStatData(index, x), 1,1,1)
				end

				break
			end
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
	displayString = strjoin("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true
