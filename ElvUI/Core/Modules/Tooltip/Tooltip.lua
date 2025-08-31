local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')
local B = E:GetModule('Bags')
local LSM = E.Libs.LSM
local ElvUF = E.oUF
local AuraInfo = ElvUF.AuraInfo
local AuraFiltered = ElvUF.AuraFiltered

local _G = _G
local unpack, ipairs = unpack, ipairs
local wipe, next, tinsert, tconcat = wipe, next, tinsert, table.concat
local floor, tonumber, strlower = floor, tonumber, strlower
local strfind, format, strmatch, gmatch, gsub = strfind, format, strmatch, gmatch, gsub

local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
local GameTooltip_ClearProgressBars = GameTooltip_ClearProgressBars
local GameTooltip_ClearStatusBars = GameTooltip_ClearStatusBars
local GameTooltip_ClearWidgetSet = GameTooltip_ClearWidgetSet
local GetCraftReagentItemLink = GetCraftReagentItemLink
local GetCraftSelectionIndex = GetCraftSelectionIndex
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local CheckInteractDistance = CheckInteractDistance
local GetGuildInfo = GetGuildInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetRelativeDifficultyColor = GetRelativeDifficultyColor
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
local UIParent = UIParent
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitBattlePetType = UnitBattlePetType
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
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

local TooltipDataType = Enum.TooltipDataType
local AddTooltipPostCall = TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem
local UnpackAuraData = AuraUtil.UnpackAuraData

local GetItemQualityByID = C_Item.GetItemQualityByID
local GetItemCount = C_Item.GetItemCount
local GetItemInfo = C_Item.GetItemInfo

local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor
local C_CurrencyInfo_GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_PetJournal_GetPetTeamAverageLevel = C_PetJournal and C_PetJournal.GetPetTeamAverageLevel
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST
local UNKNOWN = UNKNOWN

-- Custom to find LEVEL string on tooltip
local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?',''))
local LEVEL2 = strlower((_G.TOOLTIP_UNIT_LEVEL_RACE or _G.TOOLTIP_UNIT_LEVEL_CLASS):gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?',''))
local IDLine = '|cFFCA3C3C%s:|r %d'
local targetList, TAPPED_COLOR = {}, { r=0.6, g=0.6, b=0.6 }
local AFK_LABEL = ' |cffFFFFFF[|r|cffFF9900'..L["AFK"]..'|r|cffFFFFFF]|r'
local DND_LABEL = ' |cffFFFFFF[|r|cffFF3333'..L["DND"]..'|r|cffFFFFFF]|r'
local genderTable = { _G.UNKNOWN..' ', _G.MALE..' ', _G.FEMALE..' ' }
local blanchyFix = '|n%s*|n' -- thanks blizz -x- lol
local whiteRGB = { r = 1, g = 1, b = 1 }

function TT:IsModKeyDown(db)
	local k = db or TT.db.modifierID -- defaulted to 'HIDE' unless otherwise specified
	return k == 'SHOW' or ((k == 'SHIFT' and IsShiftKeyDown()) or (k == 'CTRL' and IsControlKeyDown()) or (k == 'ALT' and IsAltKeyDown()))
end

function TT:SetCompareItems(tt, value)
	if E.Retail and tt == GameTooltip then
		tt.supportsItemComparison = value
	end
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if not E.private.tooltip.enable or not TT.db.visibility or tt:IsForbidden() or tt:GetAnchorType() ~= 'ANCHOR_NONE' then
		return
	elseif (InCombatLockdown() and not TT:IsModKeyDown(TT.db.visibility.combatOverride)) or (not AB.KeyBinder.active and not TT:IsModKeyDown(TT.db.visibility.actionbars) and AB.handledbuttons[tt:GetOwner()]) then
		TT:SetCompareItems(tt, false)
		tt:Hide() -- during kb mode this will trigger AB.ShowBinds
		return
	end

	TT:SetCompareItems(tt, true)

	local statusBar = tt.StatusBar
	if statusBar then
		local spacing = E.Spacing * 3
		local position = TT.db.healthBar.statusPosition
		statusBar:SetAlpha(position == 'DISABLED' and 0 or 1)

		if position == 'BOTTOM' and statusBar.anchoredToTop then
			statusBar:ClearAllPoints()
			statusBar:Point('TOPLEFT', tt, 'BOTTOMLEFT', E.Border, -spacing)
			statusBar:Point('TOPRIGHT', tt, 'BOTTOMRIGHT', -E.Border, -spacing)
			statusBar.anchoredToTop = nil
		elseif position == 'TOP' and not statusBar.anchoredToTop then
			statusBar:ClearAllPoints()
			statusBar:Point('BOTTOMLEFT', tt, 'TOPLEFT', E.Border, spacing)
			statusBar:Point('BOTTOMRIGHT', tt, 'TOPRIGHT', -E.Border, spacing)
			statusBar.anchoredToTop = true
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

	if anchor == nil or anchor == B.BagFrame or anchor == RightChatPanel or anchor == TooltipMover or anchor == _G.GameTooltipDefaultContainer or anchor == UIParent or anchor == E.UIParent then
		tt:ClearAllPoints()

		if not E:HasMoverBeenMoved('TooltipMover') then
			if B.BagFrame and B.BagFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', B.BagFrame, 'TOPRIGHT', 0, 18)
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

	local info = tt:GetTooltipData()
	if not (info and info.lines[3]) then return end

	for i, line in next, info.lines, 3 do
		local text = line and line.leftText
		if not text or text == '' then
			break
		elseif text == _G.PVP or text == _G.FACTION_ALLIANCE or text == _G.FACTION_HORDE then
			local left = _G['GameTooltipTextLeft'..i]
			left:SetText('')
			left:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset, raw)
	if tt:IsForbidden() then return end

	local info = tt:GetTooltipData()
	if not (info and info.lines[offset]) then return end

	for i, line in next, info.lines, offset do
		local text = line and line.leftText
		if not text or text == '' then return end

		local lower = strlower(text)
		if lower and (strfind(lower, LEVEL1) or strfind(lower, LEVEL2)) then
			if raw then
				return line, info.lines[i+1]
			else
				return _G['GameTooltipTextLeft'..i], _G['GameTooltipTextLeft'..i+1]
			end
		end
	end
end

function TT:SetUnitText(tt, unit, isPlayerUnit)
	local name, realm = UnitName(unit)

	if isPlayerUnit then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local nameRealm = (realm and realm ~= '' and format('%s-%s', name, realm)) or name
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName, gender = UnitPVPName(unit), UnitSex(unit)
		local level, realLevel = (E.Retail and UnitEffectiveLevel or UnitLevel)(unit), UnitLevel(unit)
		local relationship = UnitRealmRelationship(unit)
		local isShiftKeyDown = IsShiftKeyDown()

		local nameColor = E:ClassColor(class) or PRIEST_COLOR

		if TT.db.playerTitles and pvpName and pvpName ~= '' then
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

		local levelLine, specLine = TT:GetLevelLine(tt, (guildName and not E.Classic and 2) or 1)
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName..'-'..guildRealm
			end

			local text = TT.db.guildRanks and format('<|cff00ff10%s|r> [|cff00ff10%s|r]', guildName, guildRankName) or format('<|cff00ff10%s|r>', guildName)
			if levelLine == _G.GameTooltipTextLeft2 then
				tt:AddLine(text, 1, 1, 1)
			else
				_G.GameTooltipTextLeft2:SetText(text)
			end
		end

		if levelLine then
			local diffColor = GetCreatureDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, localizedFaction = E:GetUnitBattlefieldFaction(unit)
			if localizedFaction and (englishRace == 'Pandaren' or englishRace == 'Dracthyr') then race = localizedFaction..' '..race end
			local hexColor = E:RGBToHex(diffColor.r, diffColor.g, diffColor.b)
			local unitGender = TT.db.gender and genderTable[gender]

			local levelText
			if level < realLevel then
				levelText = format('%s%s|r |cffFFFFFF(%s)|r %s%s', hexColor, level > 0 and level or '??', realLevel, unitGender or '', race or '')
			else
				levelText = format('%s%s|r %s%s', hexColor, level > 0 and level or '??', unitGender or '', race or '')
			end

			if E.Retail then
				local specText = specLine and specLine:GetText()
				if specText then
					specLine:SetFormattedText('|c%s%s|r', nameColor.colorStr, specText)
				end
			else -- put the class in classic
				levelText = format('%s |c%s%s|r', levelText, nameColor.colorStr, localeClass)
			end

			levelLine:SetFormattedText(levelText)
		end

		if TT.db.showElvUIUsers then
			local addonUser = E.UserList[nameRealm]
			if addonUser then
				local same = addonUser == E.version
				tt:AddDoubleLine(L["ElvUI Version:"], format('%.2f', addonUser), nil, nil, nil, same and 0.2 or 1, same and 1 or 0.2, 0.2)
			end
		end

		return nameColor
	else
		local isPetCompanion = not E.Classic and UnitIsBattlePetCompanion(unit)
		local levelLine, classLine = TT:GetLevelLine(tt, 1)
		if levelLine then
			local pvpFlag, classificationString, diffColor, level = '', ''
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)

			if isPetCompanion or (not E.Classic and UnitIsWildBattlePet(unit)) then
				level = UnitBattlePetLevel(unit)

				local petType = UnitBattlePetType(unit)
				local petClass = _G['BATTLE_PET_NAME_'..petType]
				if creatureType then
					creatureType = format('%s %s', creatureType, petClass)
				else
					creatureType = petClass
				end

				local teamLevel = C_PetJournal_GetPetTeamAverageLevel()
				if teamLevel then
					diffColor = GetRelativeDifficultyColor(teamLevel, level)
				else
					diffColor = GetCreatureDifficultyColor(level)
				end
			else
				level = (E.Retail and UnitEffectiveLevel or UnitLevel)(unit)
				diffColor = GetCreatureDifficultyColor(level)
			end

			if UnitIsPVP(unit) then
				pvpFlag = format(' (%s)', _G.PVP)
			end

			if creatureClassification == 'rare' or creatureClassification == 'elite' or creatureClassification == 'rareelite' or creatureClassification == 'worldboss' then
				classificationString = format('%s %s|r', E:CallTag('classificationcolor', unit), E:CallTag('classification', unit))
			end

			levelLine:SetFormattedText('|cff%02x%02x%02x%s|r%s %s%s', diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or '??', classificationString, creatureType or '', pvpFlag)

			local classText = creatureType and classLine and classLine:GetText()
			if creatureType == classText then -- we dont want to show creatureType two times
				classLine:SetText('') -- so just hide this one, we put it on the level line
				classLine:Hide()
			end
		end

		local unitReaction = UnitReaction(unit, 'player')
		local nameColor = unitReaction and ((TT.db.useCustomFactionColors and TT.db.factionColors[unitReaction]) or _G.FACTION_BAR_COLORS[unitReaction]) or PRIEST_COLOR

		if not isPetCompanion then
			_G.GameTooltipTextLeft1:SetFormattedText('|c%s%s|r', nameColor.colorStr or E:RGBToHex(nameColor.r, nameColor.g, nameColor.b, 'ff'), name or UNKNOWN)
		end

		return (UnitIsTapDenied(unit) and TAPPED_COLOR) or nameColor
	end
end

local inspectGUIDCache = {}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
	if itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
		end

		GameTooltip.ItemLevelShown = true
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

local lastGUID
function TT:AddInspectInfo(tt, unit, numTries, r, g, b)
	if tt.ItemLevelShown or (not unit) or (numTries > 3) or not UnitIsPlayer(unit) or not CanInspect(unit) or (E.Mists and not CheckInteractDistance(unit, 4)) then return end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then return end
	local cache = inspectGUIDCache[unitGUID]

	if unitGUID == E.myguid then
		tt.ItemLevelShown = true
		tt:AddDoubleLine(L["Item Level:"], E:GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
	elseif cache and cache.time then
		local itemLevel = cache.itemLevel
		if not itemLevel or (GetTime() - cache.time > 120) then
			cache.time, cache.itemLevel = nil, nil
			return E:Delay(0.33, TT.AddInspectInfo, TT, tt, unit, numTries + 1, r, g, b)
		end

		tt.ItemLevelShown = true
		tt:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = { unitColor = {r, g, b} }
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

function TT:AddMountInfo(tt, unit)
	if ElvUF:ShouldSkipAuraUpdate(tt, 'ADD_MOUNT_INFO', unit) then return end

	local unitAuraFiltered = AuraFiltered.HELPFUL[unit]
	local auraInstanceID, aura = next(unitAuraFiltered)
	while aura do
		local mountID = E.MountIDs[aura.spellId]
		if mountID then
			tt:AddDoubleLine(format('%s:', _G.MOUNT), aura.name, nil, nil, nil, 1, 1, 1)

			local sourceText = E.MountText[mountID]
			local mountText = sourceText and IsControlKeyDown() and gsub(sourceText, blanchyFix, '|n')
			if mountText then
				local sourceModified = gsub(mountText, '|n', '\10')
				for x in gmatch(sourceModified, '[^\10]+\10?') do
					local left, right = strmatch(x, '(.-|r)%s?([^\10]+)\10?')
					if left and right then
						tt:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)
					else
						tt:AddDoubleLine(_G.FROM, gsub(mountText, '|c%x%x%x%x%x%x%x%x',''), nil, nil, nil, 1, 1, 1)
					end
				end
			end

			break
		end

		auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
	end
end

function TT:AddTargetInfo(tt, unit)
	local unitTarget = unit..'target'
	if unit ~= 'player' and UnitExists(unitTarget) then
		local targetColor
		if UnitIsPlayer(unitTarget) and (not E.Retail or not UnitHasVehicleUI(unitTarget)) then
			local _, class = UnitClass(unitTarget)
			targetColor = E:ClassColor(class) or PRIEST_COLOR
		else
			local reaction = UnitReaction(unitTarget, 'player')
			targetColor = (TT.db.useCustomFactionColors and TT.db.factionColors[reaction]) or _G.FACTION_BAR_COLORS[reaction] or PRIEST_COLOR
		end

		tt:AddDoubleLine(format('%s:', _G.TARGET), format('|cff%02x%02x%02x%s|r', targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
	end

	if IsInGroup() then
		local isInRaid = IsInRaid()
		for i = 1, GetNumGroupMembers() do
			local groupUnit = (isInRaid and 'raid' or 'party')..i
			if UnitIsUnit(groupUnit..'target', unit) and not UnitIsUnit(groupUnit, 'player') then
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

function TT:AddRoleInfo(tt, unit)
	local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
	if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= 'NONE') then
		if role == 'HEALER' then
			role, r, g, b = L["Healer"], 0, 1, .59
		elseif role == 'TANK' then
			role, r, g, b = _G.TANK, .16, .31, .61
		elseif role == 'DAMAGER' then
			role, r, g, b = L["DPS"], .77, .12, .24
		end

		tt:AddDoubleLine(format('%s:', _G.ROLE), role, nil, nil, nil, r, g, b)
	end
end

function TT:AddMythicInfo(tt, unit)
	local info = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
	local score = info and info.currentSeasonScore
	if score and score > 0 then
		local color = (TT.db.dungeonScoreColor and C_ChallengeMode_GetDungeonScoreRarityColor(score)) or whiteRGB

		if TT.db.dungeonScore then
			tt:AddDoubleLine(L["Mythic+ Score:"], score, nil, nil, nil, color.r, color.g, color.b)
		end

		if TT.db.mythicBestRun then
			local bestRun = 0
			for _, run in next, info.runs do
				if run.finishedSuccess and run.bestRunLevel > bestRun then
					bestRun = run.bestRunLevel
				end
			end

			if bestRun > 0 then
				tt:AddDoubleLine(L["Mythic+ Best Run:"], bestRun, nil, nil, nil, color.r, color.g, color.b)
			end
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(data)
	if self ~= GameTooltip or self:IsForbidden() or not TT.db.visibility then return end

	local _, unit = self:GetUnit()
	if self:GetOwner() ~= UIParent and not TT:IsModKeyDown(TT.db.visibility.unitFrames) then
		self:Hide()
		return
	end

	if not unit then
		local GMF = E:GetMouseFocus()
		local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute('unit')
		if focusUnit then unit = focusUnit end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	TT:RemoveTrashLines(self) --keep an eye on this may be buggy

	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local isInCombat = InCombatLockdown()

	local isPlayerUnit = UnitIsPlayer(unit)
	local color = TT:SetUnitText(self, unit, isPlayerUnit)

	if TT.db.targetInfo and not isShiftKeyDown and not isControlKeyDown then
		TT:AddTargetInfo(self, unit)
	end

	if TT.db.role and E.allowRoles then
		TT:AddRoleInfo(self, unit)
	end

	if (E.Retail or E.Mists) and not isInCombat then
		if not isShiftKeyDown and (isPlayerUnit and unit ~= 'player') and TT.db.showMount then
			TT:AddMountInfo(self, unit)
		end
	end

	if E.Retail and not isInCombat then
		if TT.db.mythicDataEnable then
			TT:AddMythicInfo(self, unit)
		end
	end

	if (E.Retail or E.Mists) and not isInCombat and isShiftKeyDown and isPlayerUnit and TT.db.inspectDataEnable and not self.ItemLevelShown then
		if color then
			TT:AddInspectInfo(self, unit, 0, color.r, color.g, color.b)
		else
			TT:AddInspectInfo(self, unit, 0, 0.9, 0.9, 0.9)
		end
	end

	if not isPlayerUnit and TT:IsModKeyDown() and not ((E.Retail or E.Mists) and C_PetBattles_IsInBattle()) then
		local guid = (data and data.guid) or UnitGUID(unit) or ''
		local id = tonumber(strmatch(guid, '%-(%d-)%-%x-$'), 10)
		if id then -- NPC ID's
			self:AddLine(format(IDLine, _G.ID, id))
		end
	end

	local statusBar = self.StatusBar
	if color then
		statusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		statusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	if statusBar.text then
		local textWidth = statusBar.text:GetStringWidth()
		if textWidth then
			self:SetMinimumWidth(textWidth)
		end
	end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if tt:IsForbidden() or not value or not tt.text or not TT.db.healthBar.text then return end

	-- try to get ahold of the unit token
	local _, unit = tt:GetParent():GetUnit()
	if not unit then
		local frame = E:GetMouseFocus()
		if frame and frame.GetAttribute then
			unit = frame:GetAttribute('unit')
		end
	end

	-- check if dead
	if value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
		tt.text:SetText(_G.DEAD)
	else
		local MAX, _
		if unit then -- try to get the real health values if possible
			value, MAX = UnitHealth(unit), UnitHealthMax(unit)
		else
			_, MAX = tt:GetMinMaxValues()
		end

		-- return what we got
		if value > 0 and MAX == 1 then
			tt.text:SetFormattedText('%d%%', floor(value * 100))
		else
			tt.text:SetText(E:ShortValue(value)..' / '..E:ShortValue(MAX))
		end
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	if tt:IsForbidden() then return end

	if tt.qualityChanged then
		tt.qualityChanged = nil

		local r, g, b = 1, 1, 1
		if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
			r, g, b = unpack(E.media.bordercolor)
		end

		if tt.NineSlice then
			tt.NineSlice:SetBorderColor(r, g, b)
		else
			tt:SetBackdropBorderColor(r, g, b)
		end
	end

	tt.ItemLevelShown = nil

	if tt.ItemTooltip then
		tt.ItemTooltip:Hide()
	end

	-- This code is to reset stuck widgets.
	GameTooltip_ClearMoney(tt)
	GameTooltip_ClearStatusBars(tt)
	GameTooltip_ClearProgressBars(tt)
	GameTooltip_ClearWidgetSet(tt)
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

function TT:GameTooltip_OnTooltipSetItem(data)
	if (self ~= GameTooltip and self ~= _G.ShoppingTooltip1 and self ~= _G.ShoppingTooltip2) or self:IsForbidden() or not TT.db.visibility then return end

	local owner = self:GetOwner()
	local ownerName = owner and owner.GetName and owner:GetName()
	if ownerName and (strfind(ownerName, 'ElvUI_Container') or strfind(ownerName, 'ElvUI_BankContainer')) and not TT:IsModKeyDown(TT.db.visibility.bags) then
		self:Hide()
		return
	end

	local itemID, bagCount, bankCount, stackSize
	local modKey = TT:IsModKeyDown()

	local GetItem = GetDisplayedItem or self.GetItem
	if GetItem then
		local name, link = GetItem(self)

		if not E.Retail and name == '' and _G.CraftFrame and _G.CraftFrame:IsShown() then
			local reagentIndex = ownerName and tonumber(strmatch(ownerName, 'Reagent(%d+)'))
			if reagentIndex then link = GetCraftReagentItemLink(GetCraftSelectionIndex(), reagentIndex) end
		end

		if not link then return end

		if TT.db.itemQuality then
			local quality = GetItemQualityByID(link)
			if quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				if self.NineSlice then
					self.NineSlice:SetBorderColor(r, g, b)
				else
					self:SetBackdropBorderColor(r, g, b)
				end

				self.qualityChanged = true
			end
		end

		if modKey then
			itemID = format('|cFFCA3C3C%s|r %s', _G.ID, (data and data.id) or strmatch(link, ':(%w+)'))
		end

		if not TT.db.modifierCount or modKey then
			local count = GetItemCount(link)
			local itemCount = TT.db.itemCount
			if itemCount.bags then
				bagCount = format(IDLine, L["Bags"], count)
			end

			if itemCount.bank then
				local bank = GetItemCount(link, true, nil, TT.db.includeReagents, TT.db.includeWarband)
				local amount = bank and (bank - count)
				if amount and amount > 0 then
					bankCount = format(IDLine, L["Bank"], amount)
				end
			end

			if itemCount.stack then
				local _, _, _, _, _, _, _, stack = GetItemInfo(link)
				if stack and stack > 1 then
					stackSize = format(IDLine, L["Stack Size"], stack)
				end
			end
		end
	elseif modKey then
		local id = data and data.id
		if id then
			itemID = format('|cFFCA3C3C%s|r %s', _G.ID, id)
		end
	end

	if itemID or bagCount or bankCount or stackSize then
		self:AddLine(' ')
		self:AddDoubleLine(itemID or ' ', bagCount or bankCount or stackSize or ' ')
	end

	if (bagCount and bankCount) then
		self:AddDoubleLine(' ', bankCount)
	end

	if (bagCount or bankCount) and stackSize then
		self:AddDoubleLine(' ', stackSize)
	end
end

function TT:GameTooltip_AddQuestRewardsToTooltip(tt, questID)
	if not (tt and questID and tt.progressBar) or tt:IsForbidden() then return end

	local _, max = tt.progressBar:GetMinMaxValues()
	S:StatusBarColorGradient(tt.progressBar, tt.progressBar:GetValue(), max)
end

function TT:GameTooltip_ClearProgressBars(tt)
	tt.progressBar = nil
end

function TT:GameTooltip_ShowProgressBar(tt)
	if not tt or not tt.progressBarPool or tt:IsForbidden() then return end

	local sb = tt.progressBarPool:GetNextActive()
	if not sb or not sb.Bar then return end

	tt.progressBar = sb.Bar

	if not sb.Bar.backdrop then
		sb.Bar:StripTextures()
		sb.Bar:CreateBackdrop('Transparent', nil, true)
		sb.Bar:SetStatusBarTexture(E.media.normTex)
	end
end

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt or not tt.statusBarPool or tt:IsForbidden() then return end

	local sb = tt.statusBarPool:GetNextActive()
	if not sb or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:SetStyle(tt, _, isEmbedded)
	if not tt or (tt == E.ScanTooltip or isEmbedded or tt.IsEmbedded or not tt.NineSlice) or tt:IsForbidden() then return end

	if tt.Delimiter1 then tt.Delimiter1:SetTexture() end
	if tt.Delimiter2 then tt.Delimiter2:SetTexture() end

	tt.NineSlice.customBackdropAlpha = TT.db.colorAlpha
	tt.NineSlice:SetTemplate('Transparent')
end

function TT:MODIFIER_STATE_CHANGED()
	if not GameTooltip:IsForbidden() and GameTooltip:IsShown() then
		local owner = GameTooltip:GetOwner()
		if owner == UIParent and UnitExists('mouseover') then
			if E.Retail then
				GameTooltip:RefreshData()
			else
				GameTooltip:SetUnit('mouseover')
			end
		else
			local parent = owner and owner:GetParent()
			if parent then
				if parent.slotIndex then
					AB.SpellButtonOnEnter(parent, nil, GameTooltip)
				elseif parent == _G.SpellBookSpellIconsFrame then
					AB.SpellButtonOnEnter(owner, nil, GameTooltip)
				end
			end
		end
	end

	if E.SpellBookTooltip:IsShown() then
		AB:UpdateSpellBookTooltip()
	end
end

function TT:ShowAuraInfo(tt, source, spellID)
	local mountID, mountText = E.MountIDs[spellID]
	if mountID then
		local sourceText = E.MountText[mountID]
		mountText = sourceText and gsub(sourceText, blanchyFix, '|n')

		if mountText then
			tt:AddLine(' ')
			tt:AddLine(mountText, 1, 1, 1)
		end
	end

	if TT:IsModKeyDown() then
		if mountText then
			tt:AddLine(' ')
		end

		if source then
			local _, class = UnitClass(source)
			local color = E:ClassColor(class) or PRIEST_COLOR
			tt:AddDoubleLine(format(IDLine, _G.ID, spellID), format('|c%s%s|r', color.colorStr, UnitName(source) or UNKNOWN))
		else
			tt:AddLine(format(IDLine, _G.ID, spellID))
		end
	end

	tt:Show()
end

function TT:SetUnitAuraByAuraInstanceID(tt, unit, auraInstanceID)
	if not tt or tt:IsForbidden() then return end

	local unitAuraInfo = AuraInfo[unit]
	local aura = unitAuraInfo and unitAuraInfo[auraInstanceID]
	if not aura then return end

	local _, _, _, _, _, _, source, _, _, spellID = UnpackAuraData(aura)

	TT:ShowAuraInfo(tt, source, spellID)
end

function TT:SetUnitAura(tt, unit, index, filter)
	if not tt or tt:IsForbidden() then return end

	local name, _, _, _, _, _, source, _, _, spellID = E:GetAuraData(unit, index, filter)
	if not name then return end

	TT:ShowAuraInfo(tt, source, spellID)
end

function TT:GameTooltip_OnTooltipSetSpell(data)
	if (self ~= GameTooltip and self ~= E.SpellBookTooltip) or self:IsForbidden() or not TT:IsModKeyDown() then return end

	local spellID, _
	if E.Retail then
		if data and data.type then
			if data.type == TooltipDataType.Spell then
				spellID = data.id
			elseif data.type == TooltipDataType.Macro then
				local info = self:GetTooltipData()
				local line = info and info.lines[1]
				spellID = line and line.tooltipID
			end
		end
	else
		_, spellID = self:GetSpell()
	end

	if spellID then
		self:AddLine(format(IDLine, _G.ID, spellID))
		self:Show()
	end
end

function TT:SetItemRef(link)
	if IsModifierKeyDown() or not (link and strfind(link, '^spell:')) then return end

	_G.ItemRefTooltip:AddLine(format(IDLine, _G.ID, strmatch(link, ':(%d+)')))
	_G.ItemRefTooltip:Show()
end

function TT:SetToyByItemID(tt, id)
	if tt:IsForbidden() then return end
	if id and TT:IsModKeyDown() then
		tt:AddLine(' ')
		tt:AddLine(format(IDLine, _G.ID, id))
		tt:Show()
	end
end

function TT:SetCurrencyToken(tt, index)
	if tt:IsForbidden() or not TT:IsModKeyDown() then return end

	local link = index and C_CurrencyInfo_GetCurrencyListLink(index)
	local id = E:GetCurrencyIDFromLink(link)
	if not id then return end

	tt:AddLine(' ')
	tt:AddLine(format(IDLine, _G.ID, id))
	tt:Show()
end

function TT:SetCurrencyTokenByID(tt, id)
	if tt:IsForbidden() then return end
	if id and TT:IsModKeyDown() then
		tt:AddLine(' ')
		tt:AddLine(format(IDLine, _G.ID, id))
		tt:Show()
	end
end

function TT:AddBattlePetID()
	local tt = _G.BattlePetTooltip
	if not tt or not tt.speciesID or not TT:IsModKeyDown() then return end

	tt:AddLine(' ')
	tt:AddLine(format(IDLine, _G.ID, tt.speciesID))
	tt:Show()
end

function TT:AddQuestID(frame)
	if GameTooltip:IsForbidden() then return end

	local questID = TT:IsModKeyDown() and (frame.questLogIndex and C_QuestLog_GetQuestIDForLogIndex(frame.questLogIndex) or frame.questID)
	if not questID then return end

	GameTooltip:AddLine(format(IDLine, _G.ID, questID))

	if GameTooltip.ItemTooltip:IsShown() then
		GameTooltip:AddLine(' ')
	end

	GameTooltip:Show()
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

function TT:SetTooltipFonts()
	local font, fontSize, fontOutline = LSM:Fetch('font', TT.db.font), TT.db.textFontSize, TT.db.fontOutline
	_G.GameTooltipText:FontTemplate(font, fontSize, fontOutline)

	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G['GameTooltipMoneyFrame'..i..'PrefixText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SuffixText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'GoldButtonText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'SilverButtonText']:FontTemplate(font, fontSize, fontOutline)
			_G['GameTooltipMoneyFrame'..i..'CopperButtonText']:FontTemplate(font, fontSize, fontOutline)
		end
	end

	-- Header has its own font settings
	_G.GameTooltipHeaderText:FontTemplate(LSM:Fetch('font', TT.db.headerFont), TT.db.headerFontSize, TT.db.headerFontOutline)

	-- Ignore header font size on DatatextTooltip
	if _G.DatatextTooltip then
		_G.DatatextTooltipTextLeft1:FontTemplate(font, fontSize, fontOutline)
		_G.DatatextTooltipTextRight1:FontTemplate(font, fontSize, fontOutline)
	end

	-- Comparison Tooltips has its own size setting
	local smallSize = TT.db.smallTextFontSize
	_G.GameTooltipTextSmall:FontTemplate(font, smallSize, fontOutline)

	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for _, region in next, { tt:GetRegions() } do
			if region:IsObjectType('FontString') then
				region:FontTemplate(font, smallSize, fontOutline)
			end
		end
	end
end

function TT:GameTooltip_Hide()
	if GameTooltip:IsForbidden() then return end

	local statusBar = GameTooltip.StatusBar
	if statusBar and statusBar:IsShown() then
		statusBar:Hide()
	end
end

function TT:WorldCursorTooltipUpdate(_, state)
	if GameTooltip:IsForbidden() or TT.db.cursorAnchor then return end

	-- recall this, something called Show and stopped it (now with refade option)
	-- cursor anchor is always hidden right away regardless
	if state == 0 then
		if TT.db.fadeOut then
			GameTooltip:FadeOut()
		else
			GameTooltip:Hide()
		end
	end
end

function TT:Initialize()
	if not E.private.tooltip.enable then return end
	TT.Initialized = true

	local statusBar = GameTooltipStatusBar
	statusBar:Height(TT.db.healthBar.height)
	statusBar:SetScript('OnValueChanged', nil) -- Do we need to unset this?

	GameTooltip.StatusBar = statusBar

	local statusText = statusBar:CreateFontString(nil, 'OVERLAY')
	statusText:FontTemplate(LSM:Fetch('font', TT.db.healthBar.font), TT.db.healthBar.fontSize, TT.db.healthBar.fontOutline)
	statusText:Point('CENTER', statusBar)
	statusBar.text = statusText

	if not GameTooltip.hasMoney then -- Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		SetTooltipMoney(GameTooltip, 1, nil, '', '')
		GameTooltip_ClearMoney(GameTooltip)
	end

	TT:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', _G.RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:OffsetFrameLevel(400)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L["Tooltip"], nil, nil, nil, nil, nil, 'tooltip')

	TT:RegisterEvent('MODIFIER_STATE_CHANGED')

	TT:SecureHook('SetItemRef')
	TT:SecureHook('GameTooltip_SetDefaultAnchor')
	TT:SecureHook('EmbeddedItemTooltip_SetItemByID', 'EmbeddedItemTooltip_ID')
	TT:SecureHook('EmbeddedItemTooltip_SetCurrencyByID', 'EmbeddedItemTooltip_ID')
	TT:SecureHook('EmbeddedItemTooltip_SetItemByQuestReward', 'EmbeddedItemTooltip_QuestReward')
	TT:SecureHook(GameTooltip, 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitBuff', 'SetUnitAura')
	TT:SecureHook(GameTooltip, 'SetUnitDebuff', 'SetUnitAura')
	TT:SecureHookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	TT:SecureHookScript(GameTooltip.StatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')

	if GameTooltip.SetUnitBuffByAuraInstanceID then -- not yet on Era or Mists
		TT:SecureHook(GameTooltip, 'SetUnitBuffByAuraInstanceID', 'SetUnitAuraByAuraInstanceID')
		TT:SecureHook(GameTooltip, 'SetUnitDebuffByAuraInstanceID', 'SetUnitAuraByAuraInstanceID')
	end

	if AddTooltipPostCall and not E.Mists then -- exists but doesn't work atm on Cata
		AddTooltipPostCall(TooltipDataType.Spell, TT.GameTooltip_OnTooltipSetSpell)
		AddTooltipPostCall(TooltipDataType.Macro, TT.GameTooltip_OnTooltipSetSpell)
		AddTooltipPostCall(TooltipDataType.Item, TT.GameTooltip_OnTooltipSetItem)
		AddTooltipPostCall(TooltipDataType.Unit, TT.GameTooltip_OnTooltipSetUnit)

		TT:SecureHook(GameTooltip, 'Hide', 'GameTooltip_Hide') -- dont use OnHide use Hide directly
	else
		TT:SecureHookScript(GameTooltip, 'OnTooltipSetSpell', TT.GameTooltip_OnTooltipSetSpell)
		TT:SecureHookScript(GameTooltip, 'OnTooltipSetItem', TT.GameTooltip_OnTooltipSetItem)
		TT:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', TT.GameTooltip_OnTooltipSetUnit)
		TT:SecureHookScript(E.SpellBookTooltip, 'OnTooltipSetSpell', TT.GameTooltip_OnTooltipSetSpell)

		if not E.Classic then -- what's the replacement in DF
			TT:SecureHook(GameTooltip, 'SetCurrencyTokenByID')
		end
	end

	if not E.Classic then
		TT:SecureHook('BattlePetToolTip_Show', 'AddBattlePetID')
	end

	if E.Retail then
		TT:RegisterEvent('WORLD_CURSOR_TOOLTIP_UPDATE', 'WorldCursorTooltipUpdate')
		TT:SecureHook('EmbeddedItemTooltip_SetSpellWithTextureByID', 'EmbeddedItemTooltip_ID')
		TT:SecureHook('EmbeddedItemTooltip_SetSpellByQuestReward', 'EmbeddedItemTooltip_QuestReward')
		TT:SecureHook(GameTooltip, 'SetToyByItemID')
		TT:SecureHook(GameTooltip, 'SetCurrencyToken')
		TT:SecureHook(GameTooltip, 'SetBackpackToken')
		TT:SecureHook('QuestMapLogTitleButton_OnEnter', 'AddQuestID')
		TT:SecureHook('TaskPOI_OnEnter', 'AddQuestID')

		_G.GameTooltipDefaultContainer:KillEditMode()
	end
end

E:RegisterModule(TT:GetName())
