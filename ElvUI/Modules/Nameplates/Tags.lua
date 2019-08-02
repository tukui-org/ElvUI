local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local _G = _G
local format = format
local select = select
local strmatch = strmatch

local GetCVarBool = GetCVarBool
local GetGuildInfo = GetGuildInfo
local GetInstanceInfo = GetInstanceInfo
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local LEVEL = LEVEL
--GLOBALS: Hex

oUF.Tags.Events['npctitle'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['npctitle'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local Title = _G[format('ElvUI_ScanTooltipTextLeft%d', GetCVarBool('colorblindmode') and 3 or 2)]:GetText()

	if (Title and not Title:find('^'..LEVEL)) then
		return Title
	end
end

oUF.Tags.Events['guild:rank'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['guild:rank'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return select(2, GetGuildInfo(unit)) or ''
	end
end

oUF.Tags.Events['arena:number'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['arena:number'] = function(unit)
	local _, instanceType = GetInstanceInfo()
	if instanceType == 'arena' then
		for i = 1, 5 do
			if UnitIsUnit(unit, "arena"..i) then
				return i
			end
		end
	end
end

oUF.Tags.Events['class'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['class'] = function(unit)
	return UnitClass(unit)
end

oUF.Tags.Events['name:title'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['name:title'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return UnitPVPName(unit)
	end
end

oUF.Tags.SharedEvents.QUEST_LOG_UPDATE = true

oUF.Tags.Events['quest:title'] = 'QUEST_LOG_UPDATE'
oUF.Tags.Methods['quest:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local QuestName

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')

			if not ( PlayerName and PlayerName ~= '' and PlayerName ~= UnitName('player') ) then
				if ProgressText then
					QuestName = _G['ElvUI_ScanTooltipTextLeft' .. i - 1]:GetText()
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

oUF.Tags.Events['quest:info'] = 'QUEST_LOG_UPDATE'
oUF.Tags.Methods['quest:info'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	E.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	E.ScanTooltip:SetUnit(unit)
	E.ScanTooltip:Show()

	local ObjectiveCount = 0
	local QuestName

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
			local QuestLineText = QuestLine and QuestLine:GetText()

			local PlayerName, ProgressText = strmatch(QuestLineText, '^ ([^ ]-) ?%- (.+)$')
			if (not PlayerName or PlayerName == '' or PlayerName == UnitName('player')) and ProgressText then
				local x, y
				if not QuestName and ProgressText then
					QuestName = _G['ElvUI_ScanTooltipTextLeft' .. i - 1]:GetText()
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
