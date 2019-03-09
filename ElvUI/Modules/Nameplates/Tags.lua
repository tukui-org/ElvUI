local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local oUF = E.oUF

local _G = _G
local unpack = unpack
local format = format
local select = select
local strmatch = strmatch

local GetCVarBool = GetCVarBool
local GetGuildInfo = GetGuildInfo
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local IsInInstance = IsInInstance
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitReaction = UnitReaction
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local LEVEL = LEVEL

--GLOBALS: Hex, CUSTOM_CLASS_COLORS

oUF.Tags.Events['cast:name'] = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_CHANNEL_START'
oUF.Tags.Methods['cast:name'] = function(unit)
	local name = UnitCastingInfo(unit) or UnitChannelInfo(unit)
	return name or ''
end

oUF.Tags.Events['cast:time'] = 'UNIT_SPELLCAST_START UNIT_SPELLCAST_CHANNEL_START'
oUF.Tags.Methods['cast:time'] = function(unit)
	local name = UnitCastingInfo(unit) or UnitChannelInfo(unit)
	return name or ''
end

oUF.Tags.Events['npctitle'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['npctitle'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return
	end

	E.ScanTooltip:SetUnit(unit)

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

oUF.Tags.Events['guild'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['guild'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Hex(.25, .75, .25)..(GetGuildInfo(unit) or '')..'|r'
	end
end

oUF.Tags.Events['guild:rank'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['guild:rank'] = function(unit)
	if (UnitIsPlayer(unit)) then
		return Hex(.25, .75, .25)..(select(2, GetGuildInfo(unit)) or '')..'|r'
	end
end

oUF.Tags.Events['arena:number'] = 'UNIT_NAME_UPDATE'
oUF.Tags.Methods['arena:number'] = function(unit)
	if select(2, IsInInstance()) == 'arena' then
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

oUF.Tags.Events['interrupt:classcolor'] = 'COMBAT_LOG_EVENT_UNFILTERED'
oUF.Tags.Methods['interrupt:classcolor'] = function(unit)
	local _, event, _, _, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()

	if (event == "SPELL_INTERRUPT") and targetGUID and (sourceName and sourceName ~= "") then
		local class = select(2, UnitClass(sourceName)) or 'PRIEST'
		return (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]):GenerateHexColorMarkup()..sourceName..'|r'
	end
end

oUF.Tags.Events['quest:title'] = 'UNIT_NAME_UPDATE UNIT_HEALTH'
oUF.Tags.Methods['quest:title'] = function(unit)
	if UnitIsPlayer(unit) then
		return
	end

	local QuestName

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
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

	if E.ScanTooltip:NumLines() >= 3 then
		for i = 3, E.ScanTooltip:NumLines() do
			local QuestLine = _G['ElvUI_ScanTooltipTextLeft' .. i]
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
