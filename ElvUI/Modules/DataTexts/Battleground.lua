local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin

local C_PvP_GetMatchPVPStatIDs = C_PvP.GetMatchPVPStatIDs
local C_PvP_GetMatchPVPStatColumn = C_PvP.GetMatchPVPStatColumn
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldStatData = GetBattlefieldStatData
local BATTLEGROUND = BATTLEGROUND

local displayString = ''

function DT:UPDATE_BATTLEFIELD_SCORE()
	for i = 1, GetNumBattlefieldScores() do
		local name, killingBlows, honorableKills, deaths, honorGained, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
		if name == E.myname then
			_G.LeftChatDataPanel.dataPanels[1].text:SetFormattedText(displayString, _G.KILLS, E:ShortValue(honorableKills))
			_G.LeftChatDataPanel.dataPanels[2].text:SetFormattedText(displayString, _G.KILLING_BLOWS, E:ShortValue(killingBlows))
			_G.LeftChatDataPanel.dataPanels[3].text:SetFormattedText(displayString, _G.DEATHS, E:ShortValue(deaths))

			_G.RightChatDataPanel.dataPanels[1].text:SetFormattedText(displayString, _G.DAMAGE, E:ShortValue(damageDone))
			_G.RightChatDataPanel.dataPanels[2].text:SetFormattedText(displayString, _G.SHOW_COMBAT_HEALING, E:ShortValue(healingDone))
			_G.RightChatDataPanel.dataPanels[3].text:SetFormattedText(displayString, _G.HONOR, E:ShortValue(honorGained))

			break
		end
	end
end

function DT:BattlegroundStats()
	DT:SetupTooltip(self)

	local firstLine
	local classColor = E:ClassColor(E.myclass)
	local pvpStatIDs = C_PvP_GetMatchPVPStatIDs()
	if pvpStatIDs then
		for index = 1, GetNumBattlefieldScores() do
			local name = GetBattlefieldScore(index)
			if name and name == E.myname then
				DT.tooltip:AddDoubleLine(BATTLEGROUND, E.MapInfo.name, 1,1,1, classColor.r, classColor.g, classColor.b)

				-- Add extra statistics to watch based on what BG you are in.
				for x = 1, #pvpStatIDs do
					local stat = C_PvP_GetMatchPVPStatColumn(pvpStatIDs[x])
					if stat and stat.name then
						if not firstLine then
							DT.tooltip:AddLine(" ")
							firstLine = true
						end

						DT.tooltip:AddDoubleLine(stat.name, GetBattlefieldStatData(index, x), 1,1,1)
					end
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

	DT.UPDATE_BATTLEFIELD_SCORE()
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true
