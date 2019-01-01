local _, ns = ...
local oUF = ElvUI.oUF

local _G = _G
local format = format

local GetCVarBool = GetCVarBool
local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo
local UnitReaction = UnitReaction
local unpack = unpack
local LEVEL = LEVEL

local Tooltip = CreateFrame("GameTooltip", "oUF_TooltipScanner", UIParent, "GameTooltipTemplate")
Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

oUF.Tags.Events['npctitle'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['npctitle'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Hex(.25, .75, .25)..(GetGuildInfo(unit) or '')..'|r'
	end

	Tooltip:SetUnit(unit)

	local reactionType = UnitReaction(unit, "player")
	local r, g, b = 1, 1, 1
	if reactionType then
		r, g, b = unpack(oUF.colors.reaction[reactionType])
	end

	local Title = _G[format('oUF_TooltipScannerTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]:GetText()

	if (Title and not Title:find('^'..LEVEL)) then
		return format('%s%s|r', Hex(r, g, b), Title)
	end
end

oUF.Tags.Events['name:title'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['name:title'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Hex(.25, .75, .25)..(UnitPVPName(unit) or '')..'|r'
	end
end

oUF.Tags.SharedEvents.COMBAT_LOG_EVENT_UNFILTERED = true

oUF.Tags.Events['interrupt'] = 'COMBAT_LOG_EVENT_UNFILTERED'
oUF.Tags.Methods['interrupt'] = function(unit)
	local _, event, _, _, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()

	if (event == "SPELL_INTERRUPT") and targetGUID and (sourceName and sourceName ~= "") then
		return sourceName
	end
end

oUF.Tags.Events['quest:title'] = 'UNIT_NAME_UPDATE UNIT_HEALTH'
oUF.Tags.Methods['quest:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	local QuestName

	if oUF_TooltipScanner:NumLines() >= 3 then
		for i = 3, oUF_TooltipScanner:NumLines() do
			local QuestLine = _G['oUF_TooltipScannerTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')

			if not ( PlayerName and PlayerName ~= '' and PlayerName ~= UnitName('player') ) then
				if ProgressText then
					QuestName = _G['oUF_TooltipScannerTextLeft' .. i - 1]:GetText()
				end
			end
		end
		for i = 1, GetNumQuestLogEntries() do
			local title, level, _, isHeader = GetQuestLogTitle(i)
			if not isHeader and title == QuestName then
				local colors = GetQuestDifficultyColor(level)
				return Hex(colors.r, colors.g, colors.b)..QuestName..'|r'
			end
		end
    end
end

oUF.Tags.Events['quest:info'] = 'UNIT_NAME_UPDATE UNIT_HEALTH'
oUF.Tags.Methods['quest:info'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	local ObjectiveCount = 0
	local QuestName

	if oUF_TooltipScanner:NumLines() >= 3 then
		for i = 3, oUF_TooltipScanner:NumLines() do
			local QuestLine = _G['oUF_TooltipScannerTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')
			if (not PlayerName or PlayerName == '' or PlayerName == UnitName('player')) and ProgressText then
				local x, y
				if not QuestName and ProgressText then
					QuestName = _G['oUF_TooltipScannerTextLeft' .. i - 1]:GetText()
				end
				if ProgressText then
					x, y = strmatch(ProgressText, '(%d+)/(%d+)')
					if x and y then
						local NumLeft = y - x
						if NumLeft > ObjectiveCount then -- track highest number of objectives
							ObjectiveCount = NumLeft
							if ProgressText then
								return ProgressText
							end
						end
					else
						if ProgressText then
							return QuestName .. ': ' .. ProgressText
						end
					end
				end
			end
		end
    end
end
