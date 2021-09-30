local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local ipairs = ipairs
local strjoin = strjoin
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldScore = GetBattlefieldScore

local displayString = ''
local holder = {
	LEFT = { data = {}, _G.KILLS, _G.KILLING_BLOWS, _G.DEATHS },
	RIGHT = { data = {}, _G.DAMAGE, _G.HEALS, _G.HONOR }
}

do -- we need to register the panels to access them for the text
	DT.BattleStats = holder
end

function DT:UpdateBattlePanel(which)
	local info = which and holder[which]

	local panel = info and info.panel
	if not panel then return end

	for i, name in ipairs(info) do
		local dt = panel[i]
		if dt and dt.text then
			dt.text:SetFormattedText(displayString, name, info.data[i] or 0)
		end
	end
end

local myIndex
local LEFT = holder.LEFT.data
local RIGHT = holder.RIGHT.data
function DT:UPDATE_BATTLEFIELD_SCORE()
	myIndex = nil

	for i = 1, GetNumBattlefieldScores() do
		local name, kb, hks, deaths, honor, _, _, _, _, _, dmg, heals = GetBattlefieldScore(i)
		if name == E.myname then
			LEFT[1], LEFT[2], LEFT[3] = E:ShortValue(hks), E:ShortValue(kb), E:ShortValue(deaths)
			RIGHT[1], RIGHT[2], RIGHT[3] = E:ShortValue(dmg), E:ShortValue(heals), E:ShortValue(honor)
			myIndex = i
			break
		end
	end

	if myIndex then
		DT:UpdateBattlePanel('LEFT')
		DT:UpdateBattlePanel('RIGHT')
	end
end

function DT:ToggleBattleStats()
	if DT.ForceHideBGStats then
		DT.ForceHideBGStats = nil
		E:Print(L["Battleground datatexts will now show again if you are inside a battleground."])
	else
		DT.ForceHideBGStats = true
		E:Print(L["Battleground datatexts temporarily hidden, to show type /bgstats"])
	end

	holder.LEFT.panel = _G.LeftChatDataPanel.dataPanels
	holder.RIGHT.panel = _G.RightChatDataPanel.dataPanels

	DT:UpdatePanelInfo('LeftChatDataPanel')
	DT:UpdatePanelInfo('RightChatDataPanel')

	if DT.ShowingBattleStats then
		DT:UpdateBattlePanel('LEFT')
		DT:UpdateBattlePanel('RIGHT')
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%s|r')

	if DT.ShowingBattleStats then
		DT:UpdateBattlePanel('LEFT')
		DT:UpdateBattlePanel('RIGHT')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true
