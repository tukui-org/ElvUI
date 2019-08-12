local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:GetModule('Tooltip')
local Skins = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack, select, ipairs = unpack, select, ipairs
local wipe, tinsert, tconcat = wipe, tinsert, table.concat
local floor, tonumber = floor, tonumber
local strfind, format, strsub = strfind, format, strsub
local strmatch, gmatch = strmatch, gmatch
--WoW API / Variables
local CanInspect = CanInspect
local CreateFrame = CreateFrame
local GameTooltip_ClearMoney = GameTooltip_ClearMoney
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

local C_MountJournal_GetMountIDs = C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local C_PetJournalGetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel
-- GLOBALS: ElvUI_KeyBinder, ElvUI_ContainerFrame

-- Custom to find LEVEL string on tooltip
local LEVEL1 = _G.TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?','')
local LEVEL2 = _G.TOOLTIP_UNIT_LEVEL_CLASS:gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?','')

local GameTooltip, GameTooltipStatusBar = _G.GameTooltip, _G.GameTooltipStatusBar
local targetList = {}
local TAPPED_COLOR = { r=.6, g=.6, b=.6 }
local AFK_LABEL = " |cffFFFFFF[|r|cffFF0000"..L["AFK"].."|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFFFF00"..L["DND"].."|r|cffFFFFFF]|r"
local keybindFrame

local classification = {
	worldboss = format("|cffAF5050 %s|r", _G.BOSS),
	rareelite = format("|cffAF5050+ %s|r", _G.ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", _G.ITEM_QUALITY3_DESC)
}

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if tt:IsForbidden() then return end
	if E.private.tooltip.enable ~= true then return end
	if not self.db.visibility then return end
	if tt:GetAnchorType() ~= "ANCHOR_NONE" then return end

	if InCombatLockdown() and self.db.visibility.combat then
		local modifier = self.db.visibility.combatOverride
		if not ((modifier == 'SHIFT' and IsShiftKeyDown()) or (modifier == 'CTRL' and IsControlKeyDown()) or (modifier == 'ALT' and IsAltKeyDown())) then
			tt:Hide()
			return
		end
	end

	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if (self.db.visibility.actionbars ~= 'NONE' and ownerName and (strfind(ownerName, "ElvUI_Bar") or strfind(ownerName, "ElvUI_StanceBar") or strfind(ownerName, "PetAction")) and not keybindFrame.active) then
		local modifier = self.db.visibility.actionbars

		if(modifier == 'ALL' or not ((modifier == 'SHIFT' and IsShiftKeyDown()) or (modifier == 'CTRL' and IsControlKeyDown()) or (modifier == 'ALT' and IsAltKeyDown()))) then
			tt:Hide()
			return
		end
	end

	if tt.StatusBar then
		if self.db.healthBar.statusPosition == "BOTTOM" then
			if tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("TOPLEFT", tt, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
				tt.StatusBar:Point("TOPRIGHT", tt, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = nil
			end
		else
			if not tt.StatusBar.anchoredToTop then
				tt.StatusBar:ClearAllPoints()
				tt.StatusBar:Point("BOTTOMLEFT", tt, "TOPLEFT", E.Border, (E.Spacing * 3))
				tt.StatusBar:Point("BOTTOMRIGHT", tt, "TOPRIGHT", -E.Border, (E.Spacing * 3))
				tt.StatusBar.text:Point("CENTER", tt.StatusBar, 0, 0)
				tt.StatusBar.anchoredToTop = true
			end
		end
	end

	if parent then
		if self.db.cursorAnchor then
			tt:SetOwner(parent, self.db.cursorAnchorType, self.db.cursorAnchorX, self.db.cursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local ElvUI_ContainerFrame = ElvUI_ContainerFrame
	local RightChatPanel = _G.RightChatPanel
	local TooltipMover = _G.TooltipMover
	local _, anchor = tt:GetPoint()

	if (anchor == nil or (ElvUI_ContainerFrame and anchor == ElvUI_ContainerFrame) or anchor == RightChatPanel or anchor == TooltipMover or anchor == _G.UIParent or anchor == E.UIParent) then
		tt:ClearAllPoints()
		if(not E:HasMoverBeenMoved('TooltipMover')) then
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', ElvUI_ContainerFrame, 'TOPRIGHT', 0, 18)
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
		else
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
			else
				tt:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
			end
		end
	end
end

function TT:RemoveTrashLines(tt)
	if tt:IsForbidden() then return end
	for i=3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if(linetext == _G.PVP or linetext == _G.FACTION_ALLIANCE or linetext == _G.FACTION_HORDE) then
			tiptext:SetText('')
			tiptext:Hide()
		end
	end
end

function TT:GetLevelLine(tt, offset)
	if tt:IsForbidden() then return end
	for i=offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft"..i]
		local tipText = tipLine and tipLine.GetText and tipLine:GetText()
		if tipText and (tipText:find(LEVEL1) or tipText:find(LEVEL2)) then
			return tipLine
		end
	end
end

function TT:SetUnitText(tt, unit, level, isShiftKeyDown)
	local color
	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		if not localeClass or not class then return end

		local name, realm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)

		color = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class]

		if not color then
			color = _G.RAID_CLASS_COLORS.PRIEST
		end

		if self.db.playerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if(isShiftKeyDown) or self.db.alwaysShowRealm then
				name = name.."-"..realm
			elseif(relationship == _G.LE_REALM_RELATION_COALESCED) then
				name = name.._G.FOREIGN_SERVER_LABEL
			elseif(relationship == _G.LE_REALM_RELATION_VIRTUAL) then
				name = name.._G.INTERACTIVE_SERVER_LABEL
			end
		end

		if UnitIsAFK(unit) then
			name = name..AFK_LABEL
		elseif UnitIsDND(unit) then
			name = name..DND_LABEL
		end

		_G.GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", color.colorStr, name)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			if self.db.guildRanks then
				_G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName)
			else
				_G.GameTooltipTextLeft2:SetFormattedText("<|cff00ff10%s|r>", guildName)
			end

			lineOffset = 3
		end

		local levelLine = self:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetCreatureDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, localizedFaction = E:GetUnitBattlefieldFaction(unit)
			if localizedFaction and englishRace == "Pandaren" then race = localizedFaction.." "..race end
			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or '', color.colorStr, localeClass)
		end

		if E.db.tooltip.role then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				if role == "HEALER" then
					role, r, g, b = L["Healer"], 0, 1, .59
				elseif role == "TANK" then
					role, r, g, b = _G.TANK, .16, .31, .61
				elseif role == "DAMAGER" then
					role, r, g, b = L["DPS"], .77, .12, .24
				end

				GameTooltip:AddDoubleLine(format("%s:", _G.ROLE), role, nil, nil, nil, r, g, b)
			end
		end
	else
		if UnitIsTapDenied(unit) then
			color = TAPPED_COLOR
		else
			local unitReaction = UnitReaction(unit, "player")
			if E.db.tooltip.useCustomFactionColors then
				if unitReaction then
					color = E.db.tooltip.factionColors[unitReaction]
				end
			else
				color = _G.FACTION_BAR_COLORS[unitReaction]
			end
		end

		if not color then
			color = _G.RAID_CLASS_COLORS.PRIEST
		end

		local levelLine = self:GetLevelLine(tt, 2)
		if levelLine then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit);
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor
			if(isPetWild or isPetCompanion) then
				level = UnitBattlePetLevel(unit)

				local petType = _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)]
				if creatureType then
					creatureType = format("%s %s", creatureType, petType)
				else
					creatureType = petType
				end

				local teamLevel = C_PetJournalGetPetTeamAverageLevel();
				if(teamLevel) then
					diffColor = GetRelativeDifficultyColor(teamLevel, level);
				else
					diffColor = GetCreatureDifficultyColor(level)
				end
			else
				diffColor = GetCreatureDifficultyColor(level)
			end

			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", _G.PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	return color
end

local inspectGUIDCache = {}
local inspectColorFallback = {1,1,1}
function TT:PopulateInspectGUIDCache(unitGUID, itemLevel)
	local specName = self:GetSpecializationInfo('mouseover')
	if specName and itemLevel then
		local inspectCache = inspectGUIDCache[unitGUID]
		if inspectCache then
			inspectCache.time = GetTime()
			inspectCache.itemLevel = itemLevel
			inspectCache.specName = specName
		end

		GameTooltip:AddDoubleLine(_G.SPECIALIZATION..":", specName, nil, nil, nil, unpack((inspectCache and inspectCache.unitColor) or inspectColorFallback))
		GameTooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function TT:INSPECT_READY(event, unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		local itemLevel, retryUnit, retryTable, iLevelDB = E:GetUnitItemLevel("mouseover")
		if itemLevel == 'tooSoon' then
			E:Delay(0.05, function()
				local canUpdate = true
				for _, x in ipairs(retryTable) do
					local iLvl = E:GetGearSlotInfo(retryUnit, x)
					if iLvl == 'tooSoon' then
						canUpdate = false
					else
						iLevelDB[x] = iLvl
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
		self:UnregisterEvent(event)
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
		tooltip:AddDoubleLine(_G.SPECIALIZATION..":", self:GetSpecializationInfo(unit, true), nil, nil, nil, r, g, b)
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

		tooltip:AddDoubleLine(_G.SPECIALIZATION..":", specName, nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(L["Item Level:"], itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {unitColor = {r, g, b}}
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			self:RegisterEvent("INSPECT_READY")
		else
			self:INSPECT_READY(nil, unitGUID)
		end
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	if tt:IsForbidden() then return end

	local unit = select(2, tt:GetUnit())
	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local isPlayerUnit = UnitIsPlayer(unit)
	if((tt:GetOwner() ~= _G.UIParent) and (self.db.visibility and self.db.visibility.unitFrames ~= 'NONE')) then
		local modifier = self.db.visibility.unitFrames

		if(modifier == 'ALL' or not ((modifier == 'SHIFT' and isShiftKeyDown) or (modifier == 'CTRL' and isControlKeyDown) or (modifier == 'ALT' and IsAltKeyDown()))) then
			tt:Hide()
			return
		end
	end

	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	self:RemoveTrashLines(tt) --keep an eye on this may be buggy

	local color = self:SetUnitText(tt, unit, UnitLevel(unit), isShiftKeyDown)

	if self.db.showMount and not isShiftKeyDown and unit ~= "player" and isPlayerUnit then
		for i = 1, 40 do
			local name, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
			if not name then break end

			if self.MountIDs[id] then
				local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(self.MountIDs[id])
				tt:AddDoubleLine(format("%s:", _G.MOUNT), name, nil, nil, nil, 1, 1, 1)

				if sourceText and isControlKeyDown then
					local sourceModified = sourceText:gsub("|n", "\10")
					for x in gmatch(sourceModified, '[^\10]+\10?') do
						local left, right = strmatch(x, '(.-|r)%s?([^\10]+)\10?')
						if left and right then
							tt:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)
						else
							tt:AddDoubleLine(_G.FROM, sourceText:gsub('|c%x%x%x%x%x%x%x%x',''), nil, nil, nil, 1, 1, 1)
						end
					end
				end

				break
			end
		end
	end

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit.."target"
		if self.db.targetInfo and unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if(UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget)) then
				local _, class = UnitClass(unitTarget)
				targetColor = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class]
			else
				targetColor = E.db.tooltip.useCustomFactionColors and E.db.tooltip.factionColors[UnitReaction(unitTarget, "player")] or _G.FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end

			tt:AddDoubleLine(format("%s:", _G.TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		if self.db.targetInfo and IsInGroup() then
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (IsInRaid() and "raid"..i or "party"..i);
				if (UnitIsUnit(groupUnit.."target", unit)) and (not UnitIsUnit(groupUnit,"player")) then
					local _, class = UnitClass(groupUnit);
					local classColor = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class]
					if not classColor then classColor = _G.RAID_CLASS_COLORS.PRIEST end
					tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
				end
			end
			local numList = #targetList
			if (numList > 0) then
				tt:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], numList, tconcat(targetList, ", ")), nil, nil, nil, true);
				wipe(targetList);
			end
		end
	end

	if isShiftKeyDown and isPlayerUnit then
		self:AddInspectInfo(tt, unit, 0, color.r, color.g, color.b)
	end

	-- NPC ID's
	if unit and self.db.npcID and not isPlayerUnit then
		if C_PetBattles_IsInBattle() then return end
		local guid = UnitGUID(unit) or ""
		local id = tonumber(guid:match("%-(%d-)%-%x-$"), 10)
		if id then
			tt:AddLine(("|cFFCA3C3C%s|r %d"):format(_G.ID, id))
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
	if not value or not self.db.healthBar.text or not tt.text then return end
	local unit = select(2, tt:GetParent():GetUnit())
	if(not unit) then
		local GMF = GetMouseFocus()
		if(GMF and GMF.GetAttribute and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if(value > 0 and max == 1) then
		tt.text:SetFormattedText("%d%%", floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) --most effeciant?
	elseif(value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		tt.text:SetText(_G.DEAD)
	else
		tt.text:SetText(E:ShortValue(value).." / "..E:ShortValue(max))
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	if tt:IsForbidden() then return end
	tt.itemCleared = nil
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if tt:IsForbidden() then return end
	local ownerName = tt:GetOwner() and tt:GetOwner().GetName and tt:GetOwner():GetName()
	if (self.db.visibility and self.db.visibility.bags ~= 'NONE' and ownerName and (strfind(ownerName, "ElvUI_Container") or strfind(ownerName, "ElvUI_BankContainer"))) then
		local modifier = self.db.visibility.bags

		if(modifier == 'ALL' or not ((modifier == 'SHIFT' and IsShiftKeyDown()) or (modifier == 'CTRL' and IsControlKeyDown()) or (modifier == 'ALT' and IsAltKeyDown()))) then
			tt.itemCleared = true
			tt:Hide()
			return
		end
	end

	if not tt.itemCleared then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link,true)
		local left = " "
		local right = " "
		local bankCount = " "

		if link ~= nil and self.db.spellID then
			left = (("|cFFCA3C3C%s|r %s"):format(_G.ID, link)):match(":(%w+)")
		end

		if self.db.itemCount == "BAGS_ONLY" then
			right = ("|cFFCA3C3C%s|r %d"):format(L["Count"], num)
		elseif self.db.itemCount == "BANK_ONLY" then
			bankCount = ("|cFFCA3C3C%s|r %d"):format(L["Bank"],(numall - num))
		elseif self.db.itemCount == "BOTH" then
			right = ("|cFFCA3C3C%s|r %d"):format(L["Count"], num)
			bankCount = ("|cFFCA3C3C%s|r %d"):format(L["Bank"],(numall - num))
		end

		if left ~= " " or right ~= " " then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end
		if bankCount ~= " " then
			tt:AddDoubleLine(" ", bankCount)
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

function TT:CheckBackdropColor(tt)
	if not tt or tt:IsForbidden() then return end

	local r, g, b = E:GetBackdropColor(tt)
	if r and g and b then
		r, g, b = E:Round(r, 1), E:Round(g, 1), E:Round(b, 1)

		local red, green, blue = unpack(E.media.backdropfadecolor)
		if r ~= red or g ~= green or b ~= blue then
			tt:SetBackdropColor(red, green, blue, self.db.colorAlpha)
		end
	end
end

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip or tt.IsEmbedded) or tt:IsForbidden() then return end
	tt:SetTemplate("Transparent", nil, true) --ignore updates

	local r, g, b = E:GetBackdropColor(tt)
	tt:SetBackdropColor(r, g, b, self.db.colorAlpha)
end

function TT:MODIFIER_STATE_CHANGED(_, key)
	if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then
		local owner = GameTooltip:GetOwner()
		local notOnAuras = not (owner and owner.UpdateTooltip)
		if notOnAuras and UnitExists("mouseover") then
			GameTooltip:SetUnit('mouseover')
		end
	end
end

function TT:SetUnitAura(tt, unit, index, filter)
	if not tt or tt:IsForbidden() then return end
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	if id then
		if self.MountIDs[id] then
			local _, descriptionText, sourceText = C_MountJournal_GetMountInfoExtraByID(self.MountIDs[id])
			--tt:AddLine(descriptionText)
			tt:AddLine(" ")
			tt:AddLine(sourceText, 1, 1, 1)
			tt:AddLine(" ")
		end

		if self.db.spellID then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class]
				if not color then color = _G.RAID_CLASS_COLORS.PRIEST end
				tt:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(_G.ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				tt:AddLine(("|cFFCA3C3C%s|r %d"):format(_G.ID, id))
			end
		end

		tt:Show()
	end
end

function TT:GameTooltip_OnTooltipSetSpell(tt)
	if tt:IsForbidden() then return end
	local id = select(2, tt:GetSpell())
	if not id or not self.db.spellID then return end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(_G.ID, id)
	local lines = tt:NumLines()
	local isFound
	for i= 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true;
			break
		end
	end

	if not isFound then
		tt:AddLine(displayString)
		tt:Show()
	end
end

function TT:SetItemRef(link)
	if strfind(link,"^spell:") and self.db.spellID then
		local id = strsub(link,7)
		_G.ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(_G.ID, id))
		_G.ItemRefTooltip:Show()
	end
end

function TT:RepositionBNET(frame, _, anchor)
	if anchor ~= _G.BNETMover then
		frame:ClearAllPoints()
		frame:Point(_G.BNETMover.anchorPoint or 'TOPLEFT', _G.BNETMover, _G.BNETMover.anchorPoint or 'TOPLEFT');
	end
end

function TT:SetTooltipFonts()
	local font = E.Libs.LSM:Fetch("font", E.db.tooltip.font)
	local fontOutline = E.db.tooltip.fontOutline
	local headerSize = E.db.tooltip.headerFontSize
	local textSize = E.db.tooltip.textFontSize
	local smallTextSize = E.db.tooltip.smallTextFontSize

	_G.GameTooltipHeaderText:FontTemplate(font, headerSize, fontOutline)
	_G.GameTooltipText:FontTemplate(font, textSize, fontOutline)
	_G.GameTooltipTextSmall:FontTemplate(font, smallTextSize, fontOutline)
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame"..i.."PrefixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SuffixText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."GoldButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."SilverButtonText"]:FontTemplate(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame"..i.."CopperButtonText"]:FontTemplate(font, textSize, fontOutline)
		end
	end

	-- Ignore header font size on DatatextTooltip
	if _G.DatatextTooltip then
		_G.DatatextTooltipTextLeft1:FontTemplate(font, textSize, fontOutline)
		_G.DatatextTooltipTextRight1:FontTemplate(font, textSize, fontOutline)
	end

	--These show when you compare items ("Currently Equipped", name of item, item level)
	--Since they appear at the top of the tooltip, we set it to use the header font size.
	_G.ShoppingTooltip1TextLeft1:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextLeft2:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextLeft3:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextLeft4:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextRight1:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextRight2:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextRight3:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip1TextRight4:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextLeft1:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextLeft2:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextLeft3:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextLeft4:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextRight1:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextRight2:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextRight3:FontTemplate(font, headerSize, fontOutline)
	_G.ShoppingTooltip2TextRight4:FontTemplate(font, headerSize, fontOutline)
end

--This changes the growth direction of the toast frame depending on position of the mover
local function PostBNToastMove(mover)
	local x, y = mover:GetCenter();
	local screenHeight = E.UIParent:GetTop();
	local screenWidth = E.UIParent:GetRight()

	local anchorPoint
	if (y > (screenHeight / 2)) then
		anchorPoint = (x > (screenWidth/2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth/2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	mover.anchorPoint = anchorPoint

	_G.BNToastFrame:ClearAllPoints()
	_G.BNToastFrame:Point(anchorPoint, mover)
end

function TT:Initialize()
	self.db = E.db.tooltip

	self.MountIDs = {}
	local mountIDs = C_MountJournal_GetMountIDs();
	for _, mountID in ipairs(mountIDs) do
		self.MountIDs[select(2, C_MountJournal_GetMountInfoByID(mountID))] = mountID
	end

	_G.BNToastFrame:Point('TOPRIGHT', _G.MMHolder, 'BOTTOMRIGHT', 0, -10);
	E:CreateMover(_G.BNToastFrame, 'BNETMover', L["BNet Frame"], nil, nil, PostBNToastMove)
	self:SecureHook(_G.BNToastFrame, "SetPoint", "RepositionBNET")

	if E.private.tooltip.enable ~= true then return end
	self.Initialized = true

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip.StatusBar:Height(self.db.healthBar.height)
	GameTooltip.StatusBar:SetScript("OnValueChanged", nil) -- Do we need to unset this?
	GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltip.StatusBar.text:Point("CENTER", GameTooltip.StatusBar, 0, 0)
	GameTooltip.StatusBar.text:FontTemplate(E.Libs.LSM:Fetch("font", self.db.healthBar.font), self.db.healthBar.fontSize, self.db.healthBar.fontOutline)

	--Tooltip Fonts
	if not GameTooltip.hasMoney then
		--Force creation of the money lines, so we can set font for it
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	self:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', _G.RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 400)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L["Tooltip"], nil, nil, nil, nil, nil, 'tooltip,general')

	self:SecureHook('SetItemRef')
	self:SecureHook('GameTooltip_SetDefaultAnchor')
	self:SecureHook(GameTooltip, 'SetUnitAura')
	self:SecureHook(GameTooltip, 'SetUnitBuff', 'SetUnitAura')
	self:SecureHook(GameTooltip, 'SetUnitDebuff', 'SetUnitAura')
	self:SecureHookScript(GameTooltip, 'OnTooltipSetSpell', 'GameTooltip_OnTooltipSetSpell')
	self:SecureHookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	self:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	self:SecureHookScript(GameTooltip.StatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	--Variable is localized at top of file, then set here when we're sure the frame has been created
	--Used to check if keybinding is active, if so then don't hide tooltips on actionbars
	keybindFrame = ElvUI_KeyBinder
end

E:RegisterModule(TT:GetName())
