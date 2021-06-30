local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule('Tooltip')
local AB = E:GetModule('ActionBars')
local Skins = E:GetModule('Skins')
local LSM = E.Libs.LSM

local _G = _G
local unpack, select, ipairs = unpack, select, ipairs
local wipe, tinsert, tconcat = wipe, tinsert, table.concat
local floor, tonumber, strlower = floor, tonumber, strlower
local strfind, format, strmatch, gmatch, gsub = strfind, format, strmatch, gmatch, gsub

local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GameTooltip_ClearStatusBars = GameTooltip_ClearStatusBars
local GameTooltip_ClearProgressBars = GameTooltip_ClearProgressBars
local GameTooltip_ClearWidgetSet = GameTooltip_ClearWidgetSet
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local GetGuildInfo = GetGuildInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetItemCount = GetItemCount
local GetMouseFocus = GetMouseFocus
local GetNumGroupMembers = GetNumGroupMembers
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local NotifyInspect = NotifyInspect
local SetTooltipMoney = SetTooltipMoney
local UnitAura = UnitAura
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitBattlePetType = UnitBattlePetType
local UnitBuff = UnitBuff
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsAFK = UnitIsAFK
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsDND = UnitIsDND
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPVPName = UnitPVPName
local UnitRace = UnitRace
local UnitReaction = UnitReaction
local UnitRealmRelationship = UnitRealmRelationship
local UnitSex = UnitSex

local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_MountJournal_GetMountIDs = C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID
local C_PetJournalGetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local UNKNOWN = UNKNOWN

-- GLOBALS: ElvUF, ElvUI_KeyBinder, ElvUI_ContainerFrame

-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?',''))
local LEVEL2 = strlower(_G.TOOLTIP_UNIT_LEVEL_CLASS:gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?',''))
local IDLine = '|cFFCA3C3C%s|r %d'
local GameTooltip, GameTooltipStatusBar = _G.GameTooltip, _G.GameTooltipStatusBar
local targetList, TAPPED_COLOR, keybindFrame = {}, { r=0.6, g=0.6, b=0.6 }
local AFK_LABEL = ' |cffFFFFFF[|r|cffFF0000'..L["AFK"]..'|r|cffFFFFFF]|r'
local DND_LABEL = ' |cffFFFFFF[|r|cffFFFF00'..L["DND"]..'|r|cffFFFFFF]|r'
local genderTable = { _G.UNKNOWN..' ', _G.MALE..' ', _G.FEMALE..' ' }

function TT:IsModKeyDown(db)
	local k = db or TT.db.modifierID -- defaulted to 'HIDE' unless otherwise specified
	return k == 'SHOW' or ((k == 'SHIFT' and IsShiftKeyDown()) or (k == 'CTRL' and IsControlKeyDown()) or (k == 'ALT' and IsAltKeyDown()))
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private.tooltip.enable ~= true then return end
	if tt:IsForbidden() then return end
	if not TT.db.visibility then return end
	if tt:GetAnchorType() ~= 'ANCHOR_NONE' then return end

	if InCombatLockdown() and not TT:IsModKeyDown(TT.db.visibility.combatOverride) then
		tt:Hide()
		return
	end

	local owner = tt:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Bar') or strfind(ownerName, 'ElvUI_StanceBar') or strfind(ownerName, 'PetAction')) and not keybindFrame.active and not TT:IsModKeyDown(TT.db.visibility.actionbars) then
		tt:Hide()
		return
	end

	if tt.StatusBar then
		tt.StatusBar:SetAlpha(TT.db.healthBar.statusPosition == 'DISABLED' and 0 or 1)
		if TT.db.healthBar.statusPosition == 'BOTTOM' then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point('TOPLEFT', tt, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point('TOPRIGHT', tt, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point('CENTER', tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		elseif TT.db.healthBar.statusPosition == 'TOP' then
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point('BOTTOMLEFT', tt, 'TOPLEFT', E.Border, (E.Spacing * 3))
				tt.StatusBar:Point('BOTTOMRIGHT', tt, 'TOPRIGHT', -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point('CENTER', tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if TT.db.cursorAnchor then
			tt:SetOwner(parent, TT.db.cursorAnchorType, TT.db.cursorAnchorX, TT.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, 'ANCHOR_NONE')
		end
	end

	local RightChatPanel = _G.RightChatPanel
	local TooltipMover = _G.TooltipMover
	local _, anchor = tt:GetPoint()

	if anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == TooltipMover or anchor == _G.UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()
		if not E:HasMoverBeenMoved('TooltipMover') then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', ElvUI_ContainerFrame, 'TOPRIGHT', 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == 'TOPLEFT' then
				tt:Point('TOPLEFT', TooltipMover, 'BOTTOMLEFT', 1, -4)
			elseif point == 'TOPRIGHT' then
				tt:Point('TOPRIGHT', TooltipMover, 'BOTTOMRIGHT', -1, -4)
			elseif point == 'BOTTOMLEFT' or point == 'LEFT' then
				tt:Point('BOTTOMLEFT', TooltipMover, 'TOPLEFT', 1, 18)
			else
				tt:Point('BOTTOMRIGHT', TooltipMover, 'TOPRIGHT', -1, 18)
			end
		end
	end
end

function TT:RemoveTrashLines(tt)
	if tt:IsForbidden() then return end
	for i = 3, tt:NumLines() do
		local tiptext = _G['GameTooltipTextLeft'..i]
		local linetext = tiptext:GetText()

		if linetext == _G.PVP or linetext == _G.FACTION_ALLIANCE or linetext == _G.FACTION_HORDE then
			tiptext:SetText('')
			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	if tt:IsForbidden() then return end
	for i = offset, tt:NumLines() do
		local tipLine = _G['GameTooltipTextLeft'..i]
		local tipText = tipLine and tipLine:GetText() and strlower(tipLine:GetText())
		if tipText and (strfind(tipText, LEVEL1) or strfind(tipText, LEVEL2)) then
			return tipLine
		end
	end
end

function TT:SetUnitText(tt, unit)
	local name, realm = UnitName(unit)

	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local nameRealm = (realm and realm ~= '' and format('%s-%s', name, realm)) or name
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName, gender = UnitPVPName(unit), UnitSex(unit)
		local level, realLevel = UnitEffectiveLevel(unit), UnitLevel(unit)
		local relationship = UnitRealmRelationship(unit)
		local isShiftKeyDown = IsShiftKeyDown()

		local nameColor = E:ClassColor(class) or PRIEST_COLOR

		if TT.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= '' then
			if isShiftKeyDown or TT.db.alwaysShowRealm then
				name = name..'-'..realm
			elseif relationship == _G.LE_REALM_RELATION_COALESCED then
				name = name.._G.FOREIGN_SERVER_LABEL
			elseif relationship == _G.LE_REALM_RELATION_VIRTUAL then
				name = name.._G.INTERACTIVE_SERVER_LABEL
			end
		end

		local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ''
		_G.GameTooltipTextLeft1:SetFormattedText('|c%s%s%s|r', nameColor.colorStr, name or UNKNOWN, awayText)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName..'-'..guildRealm
			end

			if TT.db.guildRanks then
				_G.GameTooltipTextLeft2:SetFormattedText('<|cff00ff10%s|r> [|cff00ff10%s|r]', guildName, guildRankName)
			else
				_G.GameTooltipTextLeft2:SetFormattedText('<|cff00ff10%s|r>', guildName)
			end

			lineOffset = 3
		end

		local levelLine = TT:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetCreatureDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, localizedFaction = E:GetUnitBattlefieldFaction(unit)
			if localizedFaction and englishRace == 'Pandaren' then race = localizedFaction..' '..race end
			local hexColor = E:RGBToHex(diffColor.r, diffColor.g, diffColor.b)
			local unitGender = TT.db.gender and genderTable[gender]
			if level < realLevel then
				levelLine:SetFormattedText('%s%s|r |cffFFFFFF(%s)|r %s%s |c%s%s|r', hexColor, level > 0 and level or '??', realLevel, unitGender or '', race or '', nameColor.colorStr, localeClass)
			else
				levelLine:SetFormattedText('%s%s|r %s%s |c%s%s|r', hexColor, level > 0 and level or '??', unitGender or '', race or '', nameColor.colorStr, localeClass)
			end
		end

		if TT.db.role then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= 'NONE') then
				if role == 'HEALER' then
					role, r, g, b = L["Healer"], 0, 1, .59
				elseif role == 'TANK' then
					role, r, g, b = _G.TANK, .16, .31, .61
				elseif role == 'DAMAGER' then
					role, r, g, b = L["DPS"], .77, .12, .24
				end

				GameTooltip:AddDoubleLine(format('%s:', _G.ROLE), role, nil, nil, nil, r, g, b)
			end
		end

		if TT.db.mythicDataEnable then
			if TT.db.dungeonScore then
				local data = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
				local seasonScore = data and data.currentSeasonScore

				if seasonScore and seasonScore > 0 then
					local color = TT.db.dungeonScoreColor and C_ChallengeMode_GetDungeonScoreRarityColor(seasonScore)
					GameTooltip:AddDoubleLine(L["Mythic+ Score:"], seasonScore, nil, nil, nil, color and color.r or 1, color and color.g or 1, color and color.b or 1)
				end
			end
		end

		if TT.db.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local same = addonUser == E.version
				GameTooltip:AddDoubleLine(L["ElvUI Version:"], format('%.2f', addonUser), nil, nil, nil, same and 0.2 or 1, same and 1 or 0.2, 0.2)
			end
		end

		return nameColor
	else
		local levelLine = TT:GetLevelLine(tt, 2)
		if levelLine then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit)
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit) or ''
			local pvpFlag, classificationString, diffColor = '', ''

			local level = UnitEffectiveLevel(unit)
			if isPetWild or isPetCompanion then
				level = UnitBattlePetLevel(unit)

				local petType = _G['BATTLE_PET_NAME_'..UnitBattlePetType(unit)]
				if creatureType then
					creatureType = format('%s %s', creatureType, petType)
				else
					creatureType = petType
				end

				local teamLevel = C_PetJournalGetPetTeamAverageLevel()
				if teamLevel then
					diffColor = GetRelativeDifficultyColor(teamLevel, level)
				else
					diffColor = GetCreatureDifficultyColor(level)
				end
			else
				diffColor = GetCreatureDifficultyColor(level)
			end

			if UnitIsPVP(unit) then
				pvpFlag = format(' (%s)', _G.PVP)
			end

			if creatureClassification == 'rare' or creatureClassification == 'elite' or creatureClassification == 'rareelite' or creatureClassification == 'worldboss' then
				classificationString = format('%s %s|r', ElvUF.Tags.Methods['classificationcolor'](unit), ElvUF.Tags.Methods['classification'](unit))
			end

			levelLine:SetFormattedText('|cff%02x%02x%02x%s|r%s %s%s', diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or '??', classificationString, creatureType, pvpFlag)
		end

		local unitReaction = UnitReaction(unit, 'player')
		local nameColor = unitReaction and ((TT.db.useCustomFactionColors and TT.db.factionColors[unitReaction]) or _G.FACTION_BAR_COLORS[unitReaction]) or PRIEST_COLOR
		local nameColorStr = nameColor.colorStr or E:RGBToHex(nameColor.r, nameColor.g, nameColor.b, 'ff')

		_G.GameTooltipTextLeft1:SetFormattedText('|c%s%s|r', nameColorStr, name or UNKNOWN)

		return (UnitIsTapDenied(unit) and TAPPED_COLOR) or nameColor
	end
end

local inspectGUIDCache = {}
local inspectColorFallback = {1,1,1}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
	local specName = TT:GetSpecializationInfo('mouseover')
	if specName and itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
			inspectCache.specName = specName
		end

		GameTooltip:AddDoubleLine(_G.SPECIALIZATION..':', specName, nil, nil, nil, unpack((inspectCache and inspectCache.unitColor) or inspectColorFallback))
		GameTooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function TT:INSPECT_READY(event, unitGUID)
	if UnitExists('mouseover') and UnitGUID('mouseover') == unitGUID then
		local itemLevel, retryUnit, retryTable, iLevelDB = E:GetUnitItemLevel('mouseover')
		if itemLevel == 'tooSoon' then
			E:Delay(0.05, function()
				local canUpdate = true
				for _, x in ipairs(retryTable) do
					local slotInfo = E:GetGearSlotInfo(retryUnit, x)
					if slotInfo == 'tooSoon' then
						canUpdate = false
					else
						iLevelDB[x] = slotInfo.iLvl
					end
				end

				if canUpdate then
					local calculateItemLevel = E:CalculateAverageItemLevel(iLevelDB, retryUnit)
					TT:PopulateInspectGUIDCache(unitGUID, calculateItemLevel)
				end
			end)
		else
			TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
		end
	end

	if event then
		TT:UnregisterEvent(event)
	end
end

function TT:GetSpecializationInfo(unit, isPlayer)
	local spec = (isPlayer and GetSpecialization()) or (unit and GetInspectSpecialization(unit))
	if spec and spec > 0 then
		if isPlayer then
			return select(2, GetSpecializationInfo(spec))
		else
			return select(2, GetSpecializationInfoByID(spec))
		end
	end
end

local lastGUID
function TT:AddInspectInfo(tooltip, unit, numTries, r, g, b)
	if (not unit) or (numTries > 3) or not CanInspect(unit) then return end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then return end

	if unitGUID == E.myguid then
		tooltip:AddDoubleLine(_G.SPECIALIZATION..':', TT:GetSpecializationInfo(unit, true), nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], E:GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel
		if not (specName and itemLevel) or (GetTime() - inspectGUIDCache[unitGUID].time > 120) then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].specName = nil
			inspectGUIDCache[unitGUID].itemLevel = nil
			return E:Delay(0.33, TT.AddInspectInfo, TT, tooltip, unit, numTries + 1, r, g, b)
		end

		tooltip:AddDoubleLine(_G.SPECIALIZATION..':', specName, nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {unitColor = {r, g, b}}
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			TT:RegisterEvent('INSPECT_READY')
		else
			TT:INSPECT_READY(nil, unitGUID)
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	if tt:IsForbidden() or not TT.db.visibility then return end

	local unit = select(2, tt:GetUnit())
	local isPlayerUnit = UnitIsPlayer(unit)
	if tt:GetOwner() ~= _G.UIParent and not TT:IsModKeyDown(TT.db.visibility.unitFrames) then
		tt:Hide()
		return
	end

	if not unit then
		local GMF = GetMouseFocus()
		local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute('unit')
		if focusUnit then unit = focusUnit end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	TT:RemoveTrashLines(tt) --keep an eye on this may be buggy

	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local color = TT:SetUnitText(tt, unit)
	if TT.db.showMount and isPlayerUnit and unit ~= 'player' and not isShiftKeyDown then
		for i = 1, 40 do
			local name, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
			if not name then break end

			if TT.MountIDs[id] then
				local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(TT.MountIDs[id])
				tt:AddDoubleLine(format('%s:', _G.MOUNT), name, nil, nil, nil, 1, 1, 1)

				if sourceText and isControlKeyDown then
					local sourceModified = gsub(sourceText, '|n', '\10')
					for x in gmatch(sourceModified, '[^\10]+\10?') do
						local left, right = strmatch(x, '(.-|r)%s?([^\10]+)\10?')
						if left and right then
							tt:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)
						else
							tt:AddDoubleLine(_G.FROM, gsub(sourceText, '|c%x%x%x%x%x%x%x%x',''), nil, nil, nil, 1, 1, 1)
						end
					end
				end

				break
			end
		end
	end

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit..'target'
		if TT.db.targetInfo and unit ~= 'player' and UnitExists(unitTarget) then
			local targetColor
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
				local _, class = UnitClass(unitTarget)
				targetColor = E:ClassColor(class) or PRIEST_COLOR
			else
				local reaction = UnitReaction(unitTarget, 'player')
				targetColor = (TT.db.useCustomFactionColors and TT.db.factionColors[reaction]) or _G.FACTION_BAR_COLORS[reaction] or PRIEST_COLOR
			end

			tt:AddDoubleLine(format('%s:', _G.TARGET), format('|cff%02x%02x%02x%s|r', targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		if TT.db.targetInfo and IsInGroup() then
			local isInRaid = IsInRaid()
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (isInRaid and 'raid' or 'party')..i
				if UnitIsUnit(groupUnit..'target', unit) and not UnitIsUnit(groupUnit,'player') then
					local _, class = UnitClass(groupUnit)
					local classColor = E:ClassColor(class) or PRIEST_COLOR
					tinsert(targetList, format('|c%s%s|r', classColor.colorStr, UnitName(groupUnit)))
				end
			end

			local numList = #targetList
			if numList > 0 then
				tt:AddLine(format('%s (|cffffffff%d|r): %s', L["Targeted By:"], numList, tconcat(targetList, ', ')), nil, nil, nil, true)
				wipe(targetList)
			end
		end
	end

	if isShiftKeyDown and isPlayerUnit then
		TT:AddInspectInfo(tt, unit, 0, color.r, color.g, color.b)
	end

	-- NPC ID's
	if unit and not isPlayerUnit and TT:IsModKeyDown() then
		if not C_PetBattles_IsInBattle() then
			local guid = UnitGUID(unit) or ''
			local id = tonumber(strmatch(guid, '%-(%d-)%-%x-$'), 10)
			if id then
				tt:AddLine(format(IDLine, _G.ID, id))
			end
		end
	end

	if color then
		tt.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		tt.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = tt.StatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if tt:IsForbidden() then return end
	if not value or not TT.db.healthBar.text or not tt.text then return end
	local unit = select(2, tt:GetParent():GetUnit())
	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute('unit') then
			unit = GMF:GetAttribute('unit')
		end
	end

	local _, max = tt:GetMinMaxValues()
	if value > 0 and max == 1 then
		tt.text:SetFormattedText('%d%%', floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(_G.DEAD)
	else
		tt.text:SetText(E:ShortValue(value)..' / '..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	if tt:IsForbidden() then return end
	tt.itemCleared = nil

	-- This code is to reset stuck widgets.
	GameTooltip_ClearMoney(tt)
	GameTooltip_ClearStatusBars(tt)
	GameTooltip_ClearProgressBars(tt)
	GameTooltip_ClearWidgetSet(tt)

	if tt.ItemTooltip then
		tt.ItemTooltip:Hide()
	end
end

function TT:EmbeddedItemTooltip_ID(tt, id)
	if tt:IsForbidden() then return end
	if tt.Tooltip:IsShown() and TT:IsModKeyDown() then
		tt.Tooltip:AddLine(format(IDLine, _G.ID, id))
		tt.Tooltip:Show()
	end
end

function TT:EmbeddedItemTooltip_QuestReward(tt)
	if tt:IsForbidden() then return end
	if tt.Tooltip:IsShown() and TT:IsModKeyDown() then
		tt.Tooltip:AddLine(format(IDLine, _G.ID, tt.itemID or tt.spellID))
		tt.Tooltip:Show()
	end
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if tt:IsForbidden() or not TT.db.visibility then return end

	local owner = tt:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Container') or strfind(ownerName, 'ElvUI_BankContainer')) and not TT:IsModKeyDown(TT.db.visibility.bags) then
		tt.itemCleared = true
		tt:Hide()
		return
	end

	if not tt.itemCleared then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link,true)
		local left, right, bankCount = ' ', ' ', ' '

		if link and TT:IsModKeyDown() then
			left = format('|cFFCA3C3C%s|r %s', _G.ID, strmatch(link, ':(%w+)'))
		end

		if TT.db.itemCount == 'BAGS_ONLY' then
			right = format(IDLine, L["Count"], num)
		elseif TT.db.itemCount == 'BANK_ONLY' then
			bankCount = format(IDLine, L["Bank"], numall - num)
		elseif TT.db.itemCount == 'BOTH' then
			right = format(IDLine, L["Count"], num)
			bankCount = format(IDLine, L["Bank"], numall - num)
		end

		if left ~= ' ' or right ~= ' ' then
			tt:AddLine(' ')
			tt:AddDoubleLine(left, right)
		end
		if bankCount ~= ' ' then
			tt:AddDoubleLine(' ', bankCount)
		end

		tt.itemCleared = true
	end
end

function TT:GameTooltip_AddQuestRewardsToTooltip(tt, questID)
	if not (tt and questID and tt.pbBar and tt.pbBar.GetValue) or tt:IsForbidden() then return end
	local cur = tt.pbBar:GetValue()
	if cur then
		local max, _
		if tt.pbBar.GetMinMaxValues then
			_, max = tt.pbBar:GetMinMaxValues()
		end

		Skins:StatusBarColorGradient(tt.pbBar, cur, max)
	end
end

function TT:GameTooltip_ShowProgressBar(tt)
	if not tt or tt:IsForbidden() or not tt.progressBarPool then return end

	local sb = tt.progressBarPool:GetNextActive()
	if (not sb or not sb.Bar) or sb.Bar.backdrop then return end

	sb.Bar:StripTextures()
	sb.Bar:CreateBackdrop('Transparent', nil, true)
	sb.Bar:SetStatusBarTexture(E.media.normTex)

	tt.pbBar = sb.Bar
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt or tt:IsForbidden() or not tt.statusBarPool then return end

	local sb = tt.statusBarPool:GetNextActive()
	if (not sb or not sb.Text) or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip or tt.IsEmbedded or not tt.SetTemplate or not tt.SetBackdrop) or tt:IsForbidden() then return end
	tt.customBackdropAlpha = TT.db.colorAlpha
	tt:SetTemplate('Transparent')
end

function TT:MODIFIER_STATE_CHANGED()
	if not GameTooltip:IsForbidden() and GameTooltip:IsShown() then
		local owner = GameTooltip:GetOwner()
		if owner == _G.UIParent and UnitExists('mouseover') then
			GameTooltip:SetUnit('mouseover')
		elseif owner and owner:GetParent() == _G.SpellBookSpellIconsFrame then
			AB.SpellButtonOnEnter(owner, nil, GameTooltip)
		end
	end

	if _G.ElvUISpellBookTooltip:IsShown() then
		AB:UpdateSpellBookTooltip()
	end
end

function TT:SetUnitAura(tt, unit, index, filter)
	if not tt or tt:IsForbidden() then return end
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	if id then
		local sourceText
		if TT.MountIDs[id] then
			_, _, sourceText = C_MountJournal_GetMountInfoExtraByID(TT.MountIDs[id])
			tt:AddLine(' ')
			tt:AddLine(sourceText, 1, 1, 1)
		end

		if TT:IsModKeyDown() then
			if sourceText then
				tt:AddLine(' ')
			end
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = E:ClassColor(class) or PRIEST_COLOR
				tt:AddDoubleLine(format(IDLine, _G.ID, id), format('|c%s%s|r', color.colorStr, name))
			else
				tt:AddLine(format(IDLine, _G.ID, id))
			end
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	if tt:IsForbidden() or not TT:IsModKeyDown() then return end

	local _, id = tt:GetSpell()
	if not id then return end

	local ID = format(IDLine, _G.ID, id)
	for i = 3, tt:NumLines() do
		local line = _G[format('GameTooltipTextLeft%d', i)]
		local text = line and line:GetText()
		if text and strfind(text, ID) then
			return -- this is called twice on talents for some reason?
		end
	end

	tt:AddLine(ID)
	tt:Show()
end

function TT:SetItemRef(link)
	if IsModifierKeyDown() or not (link and strfind(link, '^spell:')) then return end

	_G.ItemRefTooltip:AddLine(format(IDLine, _G.ID, strmatch(link, ':(%d+)')))
	_G.ItemRefTooltip:Show()
end

function TT:SetToyByItemID(tt, id)
	if tt:IsForbidden() then return end
	if id and TT:IsModKeyDown() then
		tt:AddLine(format(IDLine, _G.ID, id))
		tt:Show()
	end
end

function TT:SetCurrencyToken(tt, index)
	if tt:IsForbidden() then return end

	local id = TT:IsModKeyDown() and tonumber(strmatch(C_CurrencyInfo_GetCurrencyListLink(index),'currency:(%d+)'))
	if not id then return end

	tt:AddLine(format(IDLine, _G.ID, id))
	tt:Show()
end

function TT:SetCurrencyTokenByID(tt, id)
	if tt:IsForbidden() then return end
	if id and TT:IsModKeyDown() then
		tt:AddLine(format(IDLine, _G.ID, id))
		tt:Show()
	end
end

function TT:QuestID(tt)
	if not tt or tt:IsForbidden() then return end
	local id = tt.questLogIndex and C_QuestLog_GetQuestIDForLogIndex(tt.questLogIndex) or tt.questID
	if id and TT:IsModKeyDown() then
		GameTooltip:AddLine(format(IDLine, _G.ID, id))
		if GameTooltip.ItemTooltip:IsShown() then GameTooltip:AddLine(' ') end
		GameTooltip:Show()
	end
end

function TT:SetBackpackToken(tt, id)
	if tt:IsForbidden() then return end
	if id and TT:IsModKeyDown() then
		local info = C_CurrencyInfo_GetBackpackCurrencyInfo(id)
		if info and info.currencyTypesID then
			tt:AddLine(format(IDLine, _G.ID, info.currencyTypesID))
			tt:Show()
		end
	end
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= _G.BNETMover then
		frame:ClearAllPoints()
		frame:Point(_G.BNETMover.anchorPoint or 'TOPLEFT', _G.BNETMover, _G.BNETMover.anchorPoint or 'TOPLEFT')
	end
end

function TT:SetTooltipFonts()
	local font = LSM:Fetch('font', TT.db.font)
	local fontOutline = TT.db.fontOutline
	local headerSize = TT.db.headerFontSize
	local smallTextSize = TT.db.smallTextFontSize
	local textSize = TT.db.textFontSize

	_G.GameTooltipHeaderText:FontTemplate(font, headerSize, fontOutline)
	_G.GameTooltipTextSmall:FontTemplate(font, smallTextSize, fontOutline)
	_G.GameTooltipText:FontTemplate(font, textSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G['GameTooltipMoneyFrame'..i..'PrefixText']:FontTemplate(font, textSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SuffixText']:FontTemplate(font, textSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'GoldButtonText']:FontTemplate(font, textSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SilverButtonText']:FontTemplate(font, textSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'CopperButtonText']:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if _G.DatatextTooltip then
		_G.DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		_G.DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	-- Comparison Tooltips should use smallTextSize
	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i=1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())
			if region:IsObjectType('FontString') then
				region:FontTemplate(font, smallTextSize, fontOutline)
			end
		end
	end
end

function TT:Initialize()
	TT.db = E.db.tooltip

	TT.MountIDs = {}
	local mountIDs = C_MountJournal_GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		TT.MountIDs[select(2, C_MountJournal_GetMountInfoByID(mountID))] = mountID
	end

	if E.private.tooltip.enable ~= true then return end
	TT.Initialized = true

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(TT.db.healthBar.height)
	GameTooltip.StatusBar:SetScript('OnValueChanged', nil) -- Do we need to unset this?
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, 'OVERLAY')
	GameTooltip.StatusBar.text:Point('CENTER', GameTooltip.StatusBar, 0, 0)
	GameTooltip.StatusBar.text:FontTemplate(LSM:Fetch('font', TT.db.healthBar.font), TT.db.healthBar.fontSize, TT.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		GameTooltip_ClearMoney(GameTooltip)
	end
	TT:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', _G.RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 400)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L["Tooltip"], nil, nil, nil, nil, nil, 'tooltip')

	TT:SecureHook('SetItemRef')
	TT:SecureHook('GameTooltip_SetDefaultAnchor')
	TT:SecureHook('EmbeddedItemTooltip_SetItemByID', 'EmbeddedItemTooltip_ID')
	TT:SecureHook('EmbeddedItemTooltip_SetSpellWithTextureByID', 'EmbeddedItemTooltip_ID')
	TT:SecureHook('EmbeddedItemTooltip_SetCurrencyByID', 'EmbeddedItemTooltip_ID')
	TT:SecureHook('EmbeddedItemTooltip_SetItemByQuestReward', 'EmbeddedItemTooltip_QuestReward')
	TT:SecureHook('EmbeddedItemTooltip_SetSpellByQuestReward', 'EmbeddedItemTooltip_QuestReward')
	TT:SecureHook(GameTooltip, 'SetToyByItemID')
	TT:SecureHook(GameTooltip, 'SetCurrencyToken')
	TT:SecureHook(GameTooltip, 'SetCurrencyTokenByID')
	TT:SecureHook(GameTooltip, 'SetBackpackToken')
	TT:SecureHook(GameTooltip, 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitBuff', 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitDebuff', 'SetUnitAura')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetSpell', 'GameTooltip_OnTooltipSetSpell')
	TT:SecureHookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	TT:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	TT:SecureHookScript(GameTooltip.StatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	TT:SecureHookScript(_G.ElvUISpellBookTooltip, 'OnTooltipSetSpell', 'GameTooltip_OnTooltipSetSpell')
	TT:RegisterEvent('MODIFIER_STATE_CHANGED')

	TT:SecureHook('QuestMapLogTitleButton_OnEnter', 'QuestID')
	TT:SecureHook('TaskPOI_OnEnter', 'QuestID')

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don't hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder
end

E:RegisterModule(TT:GetName())
