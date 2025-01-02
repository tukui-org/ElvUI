local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local ipairs = ipairs
local format = format

local UNKNOWN = UNKNOWN
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local DUNGEON_SCORE_LINK_RATING = DUNGEON_SCORE_LINK_RATING:gsub('%%s', '')

local GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local GetOverallDungeonScore = C_ChallengeMode.GetOverallDungeonScore
local GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local GetSpecificDungeonOverallScoreRarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor
local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary

local function OnEnter()
	DT.tooltip:ClearLines()

	local score = GetOverallDungeonScore()
	local color = GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR

	local classColor = E:ClassColor(E.myclass)
	DT.tooltip:AddLine(format('|c%s%s|r', classColor.colorStr, E.myname), 1, 1, 1, true)
	DT.tooltip:AddLine(E.myLocalizedClass, 1, 1, 1, true)
	DT.tooltip:AddLine(format('%s|c%s%s|r', DUNGEON_SCORE_LINK_RATING, E:RGBToHex(color.r, color.g, color.b, 'ff'), score), nil, nil, nil, true)

	local summary = GetPlayerMythicPlusRatingSummary('player')
	if summary and summary.runs then
		for i, v in ipairs(summary.runs) do
			if i == 1 then
				DT.tooltip:AddLine(' ')
			end

			local mapName = GetMapUIInfo(v.challengeModeID) or UNKNOWN
			local scoreColor = GetSpecificDungeonOverallScoreRarityColor(v.mapScore) or HIGHLIGHT_FONT_COLOR
			DT.tooltip:AddDoubleLine(mapName, format('%d (%s%d)', v.mapScore, v.finishedSuccess and '+' or '-', v.bestRunLevel), 1, 1, 1, scoreColor.r, scoreColor.g, scoreColor.b)
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self)
	local score = GetOverallDungeonScore()
	local color = GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR

	self.text:SetFormattedText('|c%s%s|r', E:RGBToHex(color.r, color.g, color.b, 'ff'), score)
end

DT:RegisterDatatext('DungeonScore', nil, {'CHALLENGE_MODE_COMPLETED'}, OnEvent, nil, nil, OnEnter, nil, _G.DUNGEON_SCORE)
