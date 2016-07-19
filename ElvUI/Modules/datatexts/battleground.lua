local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldScore = GetBattlefieldScore
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetBattlefieldStatInfo = GetBattlefieldStatInfo
local GetBattlefieldStatData = GetBattlefieldStatData

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
	[3] = HONORABLE_KILLS,
	[11] = SHOW_COMBAT_HEALING,
}

local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local TBFG = 736
local AB = 461
local TOK = 856
local SSM = 860
local DG = 935
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
	local CurrentMapID = GetCurrentMapAreaID()
	for index=1, GetNumBattlefieldScores() do
		name = GetBattlefieldScore(index)
		if name and name == E.myname then
			DT.tooltip:AddDoubleLine(L["Stats For:"], name, 1,1,1, classColor.r, classColor.g, classColor.b)
			DT.tooltip:AddLine(" ")

			--Add extra statistics to watch based on what BG you are in.
			if CurrentMapID == WSG or CurrentMapID == TP then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
			elseif CurrentMapID == EOTS then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
			elseif CurrentMapID == AV then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(3), GetBattlefieldStatData(index, 3),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(4), GetBattlefieldStatData(index, 4),1,1,1)
			elseif CurrentMapID == SOTA then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
			elseif CurrentMapID == IOC or CurrentMapID == TBFG or CurrentMapID == AB then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
			elseif CurrentMapID == TOK then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
			elseif CurrentMapID == SSM then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
			elseif CurrentMapID == DG then
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(1), GetBattlefieldStatData(index, 1),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(2), GetBattlefieldStatData(index, 2),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(3), GetBattlefieldStatData(index, 3),1,1,1)
				DT.tooltip:AddDoubleLine(GetBattlefieldStatInfo(4), GetBattlefieldStatData(index, 4),1,1,1)
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

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s: ", hex, "%s|r")

	if lastPanel ~= nil then
		DT.UPDATE_BATTLEFIELD_SCORE(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true