local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format

local function OnEnter()
	DT.tooltip:ClearLines()

	local playerName = UnitName('player')
	local className, classFileName = UnitClass('player')
	local classColor = C_ClassColor.GetClassColor(classFileName)
	local dungeonScore = C_ChallengeMode.GetOverallDungeonScore()
	local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary('player')

	DT.tooltip:AddLine(classColor:WrapTextInColorCode(playerName), className, nil, nil, nil, true)
	DT.tooltip:AddLine(className, 1, 1, 1, true)
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) or HIGHLIGHT_FONT_COLOR
	DT.tooltip:AddLine(DUNGEON_SCORE_LINK_RATING:format(color:WrapTextInColorCode(dungeonScore)))

	DT.tooltip:AddLine(' ')

	for _, v in ipairs(summary.runs) do
		local mapName = C_ChallengeMode.GetMapUIInfo(v.challengeModeID)
		local finishedSuccess = v.finishedSuccess
		local mapScore = v.mapScore
		local bestRunLevel = v.bestRunLevel
		DT.tooltip:AddDoubleLine(mapName, format("%d (%s%d)", mapScore, finishedSuccess and '+' or '-', bestRunLevel), 1, 1, 1, C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(mapScore):GetRGB())
	end

	DT.tooltip:Show()
end

local function OnEvent(self)
	local score = C_ChallengeMode.GetOverallDungeonScore()
	self.text:SetText(C_ChallengeMode.GetDungeonScoreRarityColor(score):WrapTextInColorCode(score))
end

DT:RegisterDatatext('DungeonScore', nil, {'CHALLENGE_MODE_COMPLETED'}, OnEvent, nil, nil, OnEnter, nil, DUNGEON_SCORE)
