local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local pairs = pairs
local type = type
local gsub = gsub
local twipe = table.wipe
local format = string.format
local match = string.match
local strjoin = strjoin
local tonumber = tonumber

--WoW API / Variables
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CompactUnitFrame_UnregisterEvents = CompactUnitFrame_UnregisterEvents
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateSelfClickThrough = C_NamePlate.SetNamePlateSelfClickThrough
local C_NamePlate_SetNamePlateSelfSize = C_NamePlate.SetNamePlateSelfSize
local C_Timer_NewTimer = C_Timer.NewTimer
local CreateFrame = CreateFrame
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetBattlefieldScore = GetBattlefieldScore
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetSpecializationInfoByID = GetSpecializationInfoByID
local hooksecurefunc = hooksecurefunc
local IsInInstance = IsInInstance
local RegisterUnitWatch = RegisterUnitWatch
local SetCVar = SetCVar
local UnitAffectingCombat = UnitAffectingCombat
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitPowerType = UnitPowerType
local UnregisterUnitWatch = UnregisterUnitWatch
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local GetCVar = GetCVar
local UnitGUID = UnitGUID
local Lerp = Lerp
local UNKNOWN = UNKNOWN
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local PLAYER_REALM = gsub(E.myrealm,'[%s%-]','')
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: NamePlateDriverFrame, UIParent, WorldFrame
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplates
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesAggroFlash
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesEnemies
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesPersonalResource
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesShowAll
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesMakeLarger
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesFriends
-- GLOBALS: CUSTOM_CLASS_COLORS

mod.PlateGUIDs = {}

--Taken from Blizzard_TalentUI.lua
local healerSpecIDs = {
	105,	--Druid Restoration
	270,	--Monk Mistweaver
	65,		--Paladin Holy
	256,	--Priest Discipline
	257,	--Priest Holy
	264,	--Shaman Restoration
}

mod.HealerSpecs = {}
mod.Healers = {}

--Get localized healing spec names
for _, specID in pairs(healerSpecIDs) do
	local _, name = GetSpecializationInfoByID(specID)
	if name and not mod.HealerSpecs[name] then
		mod.HealerSpecs[name] = true
	end
end

function mod:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
		if name then
			name = gsub(name,'%-'..PLAYER_REALM,'') --[[ name = match(name,"([^%-]+).*") ]]
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil;
			end
		end
	end
end

function mod:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then return end

	for i=1, 5 do
		local name, realm = UnitName(format('arena%d', i))
		if name and name ~= UNKNOWN then
			realm = (realm and realm ~= '') and gsub(realm,'[%s%-]','')
			if realm then name = name.."-"..realm end
			local s = GetArenaOpponentSpec(i)
			local _, talentSpec = nil, UNKNOWN
			if s and s > 0 then
				_, talentSpec = GetSpecializationInfoByID(s)
			end

			if talentSpec and talentSpec ~= UNKNOWN and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			end
		end
	end
end

function mod:LockdownInstancePlateCVars(lockedInstance)
	if lockedInstance then
		E:LockCVar("nameplateShowDebuffsOnFriendly", false)
	else
		E.LockedCVars.nameplateShowDebuffsOnFriendly = nil;
		SetCVar("nameplateShowDebuffsOnFriendly", true)
	end
end

function mod:NamePlateDriverFrame_UpdateNamePlateOptions()
	local _, instanceType = IsInInstance()
	local lockedInstance = instanceType and not (instanceType == "none" or instanceType == "pvp" or instanceType == "arena")
	mod:SetBaseNamePlateSize(lockedInstance) -- workaround for #206
end

function mod:PLAYER_ENTERING_WORLD()
	twipe(self.Healers)

	local inInstance, instanceType = IsInInstance()
	local lockedInstance = instanceType and not (instanceType == "none" or instanceType == "pvp" or instanceType == "arena")

	if not self.db.hideBlizzardPlates then
		self:LockdownInstancePlateCVars(lockedInstance)
	end

	if inInstance and (instanceType == 'pvp') and self.db.units.ENEMY_PLAYER.markHealers then
		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", 'CheckBGHealers')
	elseif inInstance and (instanceType == 'arena') and self.db.units.ENEMY_PLAYER.markHealers then
		self:RegisterEvent("UNIT_NAME_UPDATE", 'CheckArenaHealers')
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", 'CheckArenaHealers')
		self:CheckArenaHealers()
	else
		self:UnregisterEvent("UNIT_NAME_UPDATE")
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
	end

	if self.db.units.PLAYER.useStaticPosition then
		mod:UpdateVisibility()
	end

	-- workaround for #206
	mod:SetBaseNamePlateSize(lockedInstance)
end

function mod:ClassBar_Update()
	if(not self.ClassBar) then return end
	local frame

	if(self.db.classbar.enable) then
		local targetFrame = self:GetNamePlateForUnit("target")

		if(self.PlayerFrame and self.db.classbar.attachTo == "PLAYER" and not UnitHasVehicleUI("player")) then
			frame = self.PlayerFrame.unitFrame
			self.ClassBar:SetParent(frame)
			self.ClassBar:ClearAllPoints()

			if(self.db.classbar.position == "ABOVE") then
				self.ClassBar:SetPoint("BOTTOM", frame.TopLevelFrame or frame.HealthBar, "TOP", 0, frame.TopOffset or 15)
			else
				if(frame.CastBar:IsShown()) then
					frame.BottomOffset = -8
					frame.BottomLevelFrame = frame.CastBar
				elseif(frame.PowerBar:IsShown()) then
					frame.BottomOffset = nil
					frame.BottomLevelFrame = frame.PowerBar
				else
					frame.BottomOffset = nil
					frame.BottomLevelFrame = frame.HealthBar
				end
				self.ClassBar:SetPoint("TOP", frame.BottomLevelFrame or frame.CastBar, "BOTTOM", 3, frame.BottomOffset or -2)
			end
			self.ClassBar:Show()
		elseif(targetFrame and self.db.classbar.attachTo == "TARGET" and not UnitHasVehicleUI("player")) then
			frame = targetFrame.unitFrame
			if(frame.UnitType == "FRIENDLY_NPC" or frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "HEALER") then
				self.ClassBar:Hide()
			else
				self.ClassBar:SetParent(frame)
				self.ClassBar:ClearAllPoints()

				if(self.db.classbar.position == "ABOVE") then
					self.ClassBar:SetPoint("BOTTOM", frame.TopLevelFrame or frame.HealthBar, "TOP", 0, frame.TopOffset or 15)
				else
					if(frame.CastBar:IsShown()) then
						frame.BottomOffset = -8
						frame.BottomLevelFrame = frame.CastBar
					elseif(frame.PowerBar:IsShown()) then
						frame.BottomOffset = nil
						frame.BottomLevelFrame = frame.PowerBar
					else
						frame.BottomOffset = nil
						frame.BottomLevelFrame = frame.HealthBar
					end
					self.ClassBar:SetPoint("TOP", frame.BottomLevelFrame or frame.CastBar, "BOTTOM", 3, frame.BottomOffset or -2)
				end
				self.ClassBar:Show()
			end
		else
			self.ClassBar:Hide()
		end
	else
		self.ClassBar:Hide()
	end
end

function mod:SetFrameScale(frame, scale)
	if(frame.HealthBar.currentScale ~= scale) then
		if(frame.HealthBar.scale:IsPlaying()) then
			frame.HealthBar.scale:Stop()
		end
		frame.HealthBar.scale.width:SetChange(self.db.units[frame.UnitType].healthbar.width  * scale)
		frame.HealthBar.scale.height:SetChange(self.db.units[frame.UnitType].healthbar.height * scale)
		frame.HealthBar.scale:Play()
		frame.HealthBar.currentScale = scale
	end
end

function mod:GetNamePlateForUnit(unit)
	if(unit == "player" and self.db.units.PLAYER.useStaticPosition and self.db.units.PLAYER.enable) then
		return self.PlayerFrame__
	else
		return C_NamePlate_GetNamePlateForUnit(unit)
	end
end

function mod:GetPlateFrameLevel(frame)
	local plateLevel
	if frame.UnitType and frame.UnitType == "PLAYER" then
		plateLevel = 0 -- deadend return; we force this in mod:SetPlateFrameLevel
	elseif frame.plateID then
		plateLevel = frame.plateID*mod.levelStep
	elseif frame.unit then
		--this is a fall back to the old method but nothing should end up here
		local parent = self:GetNamePlateForUnit(frame.unit)
		plateLevel = parent and parent.GetFrameLevel and parent:GetFrameLevel()
	end
	return plateLevel
end

function mod:SetPlateFrameLevel(frame, level, isTarget)
	if frame and level then
		if frame.UnitType and frame.UnitType == "PLAYER" then
			level = 895 --5 higher than target
		elseif isTarget then
			level = 890 --10 higher than the max calculated level of 880
		elseif frame.FrameLevelChanged then
			--calculate Style Filter FrameLevelChanged leveling
			--level method: (10*(40*2)) max 800 + max 80 (40*2) = max 880
			--highest possible should be level 880 and we add 1 to all so 881
			local leveledCount = mod.CollectedFrameLevelCount or 1
			level = (frame.FrameLevelChanged*(40*mod.levelStep)) + (leveledCount*mod.levelStep)
		end

		frame:SetFrameLevel(level+1)
		frame.Glow:SetFrameLevel(level)
		frame.Buffs:SetFrameLevel(level+1)
		frame.Debuffs:SetFrameLevel(level+1)
	end
end

function mod:ResetNameplateFrameLevel(frame)
	local isTarget = UnitIsUnit(frame.unit, "target") --frame.isTarget is not the same here so keep this.
	local plateLevel = mod:GetPlateFrameLevel(frame)
	if plateLevel then
		if frame.FrameLevelChanged then --keep how many plates we change, this is reset to 1 post-ResetNameplateFrameLevel
			mod.CollectedFrameLevelCount = (mod.CollectedFrameLevelCount and mod.CollectedFrameLevelCount + 1) or 1
		end
		self:SetPlateFrameLevel(frame, plateLevel, isTarget)
	end
end

function mod:SetTargetFrame(frame)
	--Match parent's frame level for targetting purposes. Best time to do it is here.
	local plateLevel = mod:GetPlateFrameLevel(frame)
	local targetExists = UnitExists("target")
	local unitIsTarget = UnitIsUnit(frame.unit, "target")

	if unitIsTarget and not frame.isTarget then
		frame.isTarget = true

		if plateLevel then
			self:SetPlateFrameLevel(frame, plateLevel, true)
		end

		if self.db.useTargetScale then
			self:SetFrameScale(frame, self.db.targetScale)
		end

		if self.db.units[frame.UnitType].healthbar.enable ~= true and self.db.alwaysShowTargetHealth then
			frame.Name:ClearAllPoints()
			frame.NPCTitle:ClearAllPoints()
			frame.Level:ClearAllPoints()
			frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = nil, nil, nil
			frame.CastBar:Hide()
			self:ConfigureElement_HealthBar(frame)
			self:ConfigureElement_CutawayHealth(frame)
			self:ConfigureElement_PowerBar(frame)
			self:ConfigureElement_CastBar(frame)
			self:ConfigureElement_Glow(frame)
			self:ConfigureElement_Elite(frame)
			self:ConfigureElement_Detection(frame)
			self:ConfigureElement_Highlight(frame)
			self:ConfigureElement_Level(frame)
			self:ConfigureElement_Name(frame)
			self:ConfigureElement_NPCTitle(frame)
			self:RegisterEvents(frame, frame.unit)
			self:UpdateElement_All(frame, frame.unit, true, true)
		end

		if targetExists then
			frame:SetAlpha(1)
		end
	else
		if frame.isTarget and not unitIsTarget then
			frame.isTarget = nil
			if self.db.useTargetScale then
				self:SetFrameScale(frame, frame.ThreatScale or 1)
			end
			if self.db.units[frame.UnitType].healthbar.enable ~= true then
				self:UpdateAllFrame(frame)
			end
		end

		if targetExists and not UnitIsUnit(frame.unit, "player") then
			frame:SetAlpha(1 - self.db.nonTargetTransparency)
		else
			frame:SetAlpha(1)
		end

		if plateLevel then
			self:SetPlateFrameLevel(frame, plateLevel)
		end
	end

	mod:ClassBar_Update()

	if self.db.displayStyle == "TARGET" and not frame.isTarget and frame.UnitType ~= "PLAYER" then
		--Hide if we only allow our target to be displayed and the frame is not our current target and the frame is not the player nameplate
		frame:Hide()
	elseif frame.UnitType ~= "PLAYER" or not self.db.units.PLAYER.useStaticPosition then --Visibility for static nameplate is handled in UpdateVisibility
		frame:Show()
	end
end

function mod:StyleFrame(frame, useMainFrame)
	local parent = frame

	if(parent:GetObjectType() == "Texture") then
		parent = frame:GetParent()
	end

	if useMainFrame then
		parent:SetTemplate("Transparent")
		return
	end

	parent:CreateBackdrop("Transparent")
end

function mod:DISPLAY_SIZE_CHANGED()
	self.mult = E.mult --[[* UIParent:GetScale()]]
end

function mod:CheckUnitType(frame)
	local role = UnitGroupRolesAssigned(frame.unit)
	local CanAttack = UnitCanAttack(self.playerUnitToken, frame.displayedUnit)

	if(role == "HEALER" and frame.UnitType ~= "HEALER") then
		self:UpdateAllFrame(frame)
		return true
	elseif(role ~= "HEALER" and frame.UnitType == "HEALER") then
		self:UpdateAllFrame(frame)
		return true
	elseif frame.UnitType == "FRIENDLY_PLAYER" then
		--This line right here is likely the cause of the fps drop when entering world
		--CheckUnitType is being called about 1000 times because the "UNIT_FACTION" event is being triggered this amount of times for some insane reason
		self:UpdateAllFrame(frame)
		return true
	elseif(frame.UnitType == "FRIENDLY_NPC" or frame.UnitType == "HEALER") then
		if(CanAttack) then
			self:UpdateAllFrame(frame)
			return true
		end
	elseif(frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "ENEMY_NPC") then
		if(not CanAttack) then
			self:UpdateAllFrame(frame)
			return true
		end
	end
end

function mod:NAME_PLATE_UNIT_ADDED(_, unit, frame)
	frame = frame or self:GetNamePlateForUnit(unit)

	frame.unitFrame.mainFrame = frame

	-- we dont actually use `frame.unitFrame.namePlateUnitToken` but some other addons might try to
	frame.unitFrame.namePlateUnitToken = frame.namePlateUnitToken

	local plateID, plateGUID = self:GetNameplateID(frame)
	if plateID then
		frame.unitFrame.plateID = plateID
	end
	if plateGUID then
		frame.unitFrame.plateGUID = plateGUID
		self.PlateGUIDs[plateGUID] = frame
	end

	frame.unitFrame.unit = unit
	frame.unitFrame.displayedUnit = unit
	self:UpdateInVehicle(frame, true)

	local CanAttack = UnitCanAttack(unit, self.playerUnitToken)
	local isPlayer = UnitIsPlayer(unit)
	frame.unitFrame.isTargetingMe = UnitIsUnit(unit..'target', 'player')

	if(UnitIsUnit(unit, "player")) then
		frame.unitFrame.UnitType = "PLAYER"
	elseif(not CanAttack and isPlayer) then
		local role = UnitGroupRolesAssigned(unit)
		if(role == "HEALER") then
			frame.unitFrame.UnitType = role
		else
			frame.unitFrame.UnitType = "FRIENDLY_PLAYER"
		end
	elseif(not CanAttack and not isPlayer) then
		frame.unitFrame.UnitType = "FRIENDLY_NPC"
	elseif(CanAttack and isPlayer) then
		frame.unitFrame.UnitType = "ENEMY_PLAYER"
		self:UpdateElement_HealerIcon(frame.unitFrame)
	else
		frame.unitFrame.UnitType = "ENEMY_NPC"
	end

	if(frame.unitFrame.UnitType == "PLAYER") then
		self.PlayerFrame = frame
		self.PlayerNamePlateAnchor:SetParent(frame)
		self.PlayerNamePlateAnchor:SetAllPoints(frame.unitFrame)
		self.PlayerNamePlateAnchor:Show()
		frame.unitFrame.IsPlayerFrame = true
	else
		frame.unitFrame.IsPlayerFrame = nil
	end

	if(self.db.units[frame.unitFrame.UnitType] and self.db.units[frame.unitFrame.UnitType].healthbar and self.db.units[frame.unitFrame.UnitType].healthbar.enable or self.db.displayStyle ~= "ALL") then
		self:ConfigureElement_HealthBar(frame.unitFrame)
		self:ConfigureElement_CutawayHealth(frame.unitFrame)
		self:ConfigureElement_PowerBar(frame.unitFrame)
		self:ConfigureElement_CastBar(frame.unitFrame)
		self:ConfigureElement_Glow(frame.unitFrame)

		if(self.db.units[frame.unitFrame.UnitType].buffs.enable) then
			frame.unitFrame.Buffs.db = self.db.units[frame.unitFrame.UnitType].buffs
			self:UpdateAuraIcons(frame.unitFrame.Buffs)
		end

		if(self.db.units[frame.unitFrame.UnitType].debuffs.enable) then
			frame.unitFrame.Debuffs.db = self.db.units[frame.unitFrame.UnitType].debuffs
			self:UpdateAuraIcons(frame.unitFrame.Debuffs)
		end
	end

	self:ConfigureElement_Level(frame.unitFrame)
	self:ConfigureElement_Name(frame.unitFrame)
	self:ConfigureElement_Portrait(frame.unitFrame)
	self:ConfigureElement_NPCTitle(frame.unitFrame)
	self:ConfigureElement_Elite(frame.unitFrame)
	self:ConfigureElement_Detection(frame.unitFrame)
	self:ConfigureElement_Highlight(frame.unitFrame)
	self:ConfigureElement_QuestIcon(frame.unitFrame)
	self:RegisterEvents(frame.unitFrame, unit)
	self:UpdateElement_All(frame.unitFrame, unit, nil, true)

	if (self.db.displayStyle == "TARGET" and not frame.unitFrame.isTarget and frame.unitFrame.UnitType ~= "PLAYER") then
		--Hide if we only allow our target to be displayed and the frame is not our current target and the frame is not the player nameplate
		frame.unitFrame:Hide()
	elseif (frame.UnitType ~= "PLAYER" or not self.db.units.PLAYER.useStaticPosition) then --Visibility for static nameplate is handled in UpdateVisibility
		frame.unitFrame:Show()
	end

	self:UpdateElement_Filters(frame.unitFrame, "NAME_PLATE_UNIT_ADDED")
	mod:ForEachPlate("ResetNameplateFrameLevel") --keep this after `UpdateElement_Filters`
end

function mod:NAME_PLATE_UNIT_REMOVED(_, unit, frame)
	frame = frame or self:GetNamePlateForUnit(unit);

	local unitType = frame.unitFrame.UnitType
	if unitType == "PLAYER" then
		self.PlayerFrame = nil
		self.PlayerNamePlateAnchor:Hide()
	end

	self:HideAuraIcons(frame.unitFrame.Buffs)
	self:HideAuraIcons(frame.unitFrame.Debuffs)
	self:ClearStyledPlate(frame.unitFrame)
	frame.unitFrame:UnregisterAllEvents()
	frame.unitFrame.HealthBar.r, frame.unitFrame.HealthBar.g, frame.unitFrame.HealthBar.b = nil, nil, nil
	frame.unitFrame.HealthBar:Hide()
	frame.unitFrame.Glow.r, frame.unitFrame.Glow.g, frame.unitFrame.Glow.b = nil, nil, nil
	frame.unitFrame.Glow:Hide()
	frame.unitFrame.Glow2:Hide()
	frame.unitFrame.TopArrow:Hide()
	frame.unitFrame.LeftArrow:Hide()
	frame.unitFrame.RightArrow:Hide()
	frame.unitFrame.Name.r, frame.unitFrame.Name.g, frame.unitFrame.Name.b = nil, nil, nil
	frame.unitFrame.Name:ClearAllPoints()
	frame.unitFrame.Name:SetText("")
	frame.unitFrame.Name.NameOnlyGlow:Hide()
	frame.unitFrame.Highlight:Hide()
	frame.unitFrame.Portrait:Hide()
	frame.unitFrame.PowerBar:Hide()
	frame.unitFrame.CastBar:Hide()
	frame.unitFrame.AbsorbBar:Hide()
	frame.unitFrame.HealPrediction:Hide()
	frame.unitFrame.PersonalHealPrediction:Hide()
	frame.unitFrame.Level:ClearAllPoints()
	frame.unitFrame.Level:SetText("")
	frame.unitFrame.NPCTitle:ClearAllPoints()
	frame.unitFrame.NPCTitle:SetText("")
	frame.unitFrame.DetectionModel:Hide()
	frame.unitFrame.Elite:Hide()
	frame.unitFrame:Hide()
	frame.unitFrame.unit = nil
	frame.unitFrame.mainFrame = nil
	frame.unitFrame.UnitType = nil
	frame.unitFrame.isTarget = nil
	frame.unitFrame.isTargetingMe = nil
	frame.unitFrame.displayedUnit = nil
	frame.unitFrame.TopLevelFrame = nil
	frame.unitFrame.TopOffset = nil
	frame.unitFrame.isBeingTanked = nil
	frame.unitFrame.ThreatScale = nil
	frame.unitFrame.ThreatData = nil
	frame.unitFrame.namePlateUnitToken = nil
	frame.unitFrame.StyleFilterWaitTime = nil
	frame.unitFrame.CastBar.interruptedBy = nil
	frame.unitFrame.CastBar.curTarget = nil

	local numIcons = #frame.unitFrame.QuestIcon
	for i = 1, numIcons do
		frame.unitFrame.QuestIcon[i]:Hide()
	end

	frame.unitFrame.plateID = nil
	if frame.unitFrame.plateGUID then
		self.PlateGUIDs[frame.unitFrame.plateGUID] = nil
		frame.unitFrame.plateGUID = nil
	end

	if self.ClassBar and (unitType == "PLAYER") then
		mod:ClassBar_Update()
	end
end

function mod:UpdateAllFrame(frame)
	if(frame == self.PlayerFrame__) then return end

	local unit = frame.unit
	mod:NAME_PLATE_UNIT_REMOVED("NAME_PLATE_UNIT_REMOVED", unit)
	mod:NAME_PLATE_UNIT_ADDED("NAME_PLATE_UNIT_ADDED", unit)
end

function mod:ConfigureAll()
	if E.private.nameplates.enable ~= true then return; end

	--We don't allow player nameplate health to be disabled
	self.db.units.PLAYER.healthbar.enable = true

	self:StyleFilterConfigureEvents()
	self:ForEachPlate("UpdateAllFrame")
	self:UpdateCVars()
	self:TogglePlayerDisplayType()
	self:SetNamePlateClickThrough()
end

function mod:SetNamePlateClickThrough()
	self:SetNamePlateSelfClickThrough()
	self:SetNamePlateFriendlyClickThrough()
	self:SetNamePlateEnemyClickThrough()
end

function mod:SetNamePlateSelfClickThrough()
	C_NamePlate_SetNamePlateSelfClickThrough(self.db.clickThrough.personal)
	self.PlayerFrame__:EnableMouse(not self.db.clickThrough.personal)
end

function mod:SetNamePlateFriendlyClickThrough()
	C_NamePlate_SetNamePlateFriendlyClickThrough(self.db.clickThrough.friendly)
end

function mod:SetNamePlateEnemyClickThrough()
	C_NamePlate_SetNamePlateEnemyClickThrough(self.db.clickThrough.enemy)
end

function mod:ForEachPlate(functionToRun, ...)
	for _, frame in pairs(C_NamePlate_GetNamePlates()) do
		if(frame and frame.unitFrame) then
			self[functionToRun](self, frame.unitFrame, ...)
		end
	end
	if functionToRun == "ResetNameplateFrameLevel" then
		mod.CollectedFrameLevelCount = 1
	end
end

function mod:SetBaseNamePlateSize(lockedInstance)
	local clickWidth = self.db.clickableWidth + ((E.PixelMode and 2) or 6)
	local clickHeight = self.db.clickableHeight

	self.PlayerFrame__:SetSize(clickWidth, clickHeight)
	C_NamePlate_SetNamePlateSelfSize(clickWidth, clickHeight)
	C_NamePlate_SetNamePlateEnemySize(clickWidth, clickHeight)

	-- workaround for #206
	local friendlyWidth, friendlyHeight
	if lockedInstance then
		-- handle it just like blizzard does when using blizzard friendly plates
		local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
		local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
		local zeroBasedScale = namePlateVerticalScale - 1.0

		friendlyWidth = NamePlateDriverFrame.baseNamePlateWidth * horizontalScale
		friendlyHeight = NamePlateDriverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale)
	end

	C_NamePlate_SetNamePlateFriendlySize(friendlyWidth or clickWidth, friendlyHeight or clickHeight)
end

function mod:UpdateInVehicle(frame, noEvents)
	if ( UnitHasVehicleUI(frame.unit) ) then
		if ( not frame.inVehicle ) then
			frame.inVehicle = true;
			if(UnitIsUnit(frame.unit, "player")) then
				frame.displayedUnit = "vehicle"
			else
				local prefix, id, suffix = match(frame.unit, "(%D+)(%d*)(.*)")
				frame.displayedUnit = prefix.."pet"..id..suffix;
			end
			if(not noEvents) then
				self:RegisterEvents(frame, frame.unit)
				self:UpdateElement_All(frame)
			end
		end
	else
		if ( frame.inVehicle ) then
			frame.inVehicle = false;
			frame.displayedUnit = frame.unit;
			if(not noEvents) then
				self:RegisterEvents(frame, frame.unit)
				self:UpdateElement_All(frame)
			end
		end
	end
end

local function HidePlayerNamePlate()
	mod.PlayerFrame__.unitFrame:Hide()
	mod.PlayerNamePlateAnchor:Hide()
end

function mod:UpdateElement_All(frame, unit, noTargetFrame, filterIgnore)
	local healthShown = (frame.UnitType and self.db.units[frame.UnitType].healthbar.enable) or (self.db.displayStyle ~= "ALL") or (frame.isTarget and self.db.alwaysShowTargetHealth)

	if healthShown then
		mod:UpdateElement_MaxHealth(frame)
		mod:UpdateElement_Health(frame)
		mod:UpdateElement_HealthColor(frame)
		mod:UpdateElement_Cast(frame)
		mod:UpdateElement_Auras(frame)
		mod:UpdateElement_HealPrediction(frame)
		mod:UpdateElement_QuestIcon(frame)
		if(self.db.units[frame.UnitType].powerbar.enable) then
			frame.PowerBar:Show()
			mod.OnEvent(frame, "UNIT_DISPLAYPOWER", unit or frame.unit)
		else
			frame.PowerBar:Hide()
		end
	end

	mod:UpdateElement_RaidIcon(frame)
	mod:UpdateElement_HealerIcon(frame)
	mod:UpdateElement_Name(frame)
	mod:UpdateElement_NPCTitle(frame)
	mod:UpdateElement_Level(frame)
	mod:UpdateElement_Elite(frame)
	mod:UpdateElement_Detection(frame)
	mod:UpdateElement_Highlight(frame)
	mod:UpdateElement_Portrait(frame)

	if healthShown then
		mod:UpdateElement_Glow(frame)
	else
		-- make sure we hide the arrows and/or glow after disabling the healthbar
		if frame.TopArrow and frame.TopArrow:IsShown() then frame.TopArrow:Hide() end
		if frame.LeftArrow and frame.LeftArrow:IsShown() then frame.LeftArrow:Hide() end
		if frame.RightArrow and frame.RightArrow:IsShown() then frame.RightArrow:Hide() end
		if frame.Glow2 and frame.Glow2:IsShown() then frame.Glow2:Hide() end
		if frame.Glow and frame.Glow:IsShown() then frame.Glow:Hide() end
	end

	if(not noTargetFrame) then --infinite loop lol
		mod:SetTargetFrame(frame)
	end

	if(not filterIgnore) then
		mod:UpdateElement_Filters(frame, "UpdateElement_All")
	end
end

function mod:GetNameplateID(frame)
	if frame == mod.PlayerFrame__ then
		return 0, E.myguid
	end

	local plateName = frame:GetName()
	return plateName and tonumber(match(plateName, "%d+$")), frame.namePlateUnitToken and UnitGUID(frame.namePlateUnitToken)
end

function mod:NAME_PLATE_CREATED(_, frame)
	local plateID, plateGUID = self:GetNameplateID(frame)
	frame.unitFrame = CreateFrame("BUTTON", format("ElvUI_NamePlate%d", plateID), UIParent);
	frame.unitFrame:EnableMouse(false);
	frame.unitFrame:SetAllPoints(frame)
	frame.unitFrame:SetFrameStrata("BACKGROUND")
	frame.unitFrame:SetScript("OnEvent", mod.OnEvent)
	frame.unitFrame.mainFrame = frame

	-- we dont actually use `frame.unitFrame.namePlateUnitToken` but some other addons might try to
	frame.unitFrame.namePlateUnitToken = frame.namePlateUnitToken

	if plateID then
		frame.unitFrame.plateID = plateID
	end
	if plateGUID then
		frame.unitFrame.plateGUID = plateGUID
		self.PlateGUIDs[plateGUID] = frame
	end

	frame.unitFrame.HealthBar = self:ConstructElement_HealthBar(frame.unitFrame)
	frame.unitFrame.CutawayHealth = self:ConstructElement_CutawayHealth(frame.unitFrame)
	frame.unitFrame.PowerBar = self:ConstructElement_PowerBar(frame.unitFrame)
	frame.unitFrame.Level = self:ConstructElement_Level(frame.unitFrame)
	frame.unitFrame.Name = self:ConstructElement_Name(frame.unitFrame)
	frame.unitFrame.CastBar = self:ConstructElement_CastBar(frame.unitFrame)
	frame.unitFrame.NPCTitle = self:ConstructElement_NPCTitle(frame.unitFrame)
	frame.unitFrame.Glow = self:ConstructElement_Glow(frame.unitFrame)
	frame.unitFrame.Buffs = self:ConstructElement_Auras(frame.unitFrame, "LEFT")
	frame.unitFrame.Debuffs = self:ConstructElement_Auras(frame.unitFrame, "RIGHT")
	frame.unitFrame.Portrait = self:ConstructElement_Portrait(frame.unitFrame)
	frame.unitFrame.HealerIcon = self:ConstructElement_HealerIcon(frame.unitFrame)
	frame.unitFrame.RaidIcon = self:ConstructElement_RaidIcon(frame.unitFrame)
	frame.unitFrame.Elite = self:ConstructElement_Elite(frame.unitFrame)
	frame.unitFrame.DetectionModel = self:ConstructElement_Detection(frame.unitFrame)
	frame.unitFrame.Highlight = self:ConstructElement_Highlight(frame.unitFrame)
	frame.unitFrame.QuestIcon = self:ConstructElement_QuestIcons(frame.unitFrame)

	if frame.UnitFrame and not frame.unitFrame.onShowHooked then
		self:SecureHookScript(frame.UnitFrame, "OnShow", function(blizzPlate)
			blizzPlate:Hide() --Hide Blizzard's Nameplate
			blizzPlate:UnregisterAllEvents() --Remove any events
			CompactUnitFrame_UnregisterEvents(blizzPlate) --Let Blizzard remove any OnEvent and OnUpdate scripts
		end)
		frame.unitFrame.onShowHooked = true
	end
end

function mod:OnEvent(event, unit, ...)
	if event == "PLAYER_ENTERING_WORLD" and (not unit or type(unit) == "boolean") then
		if self.unit then unit = self.unit else return end
	end
	if (unit and self.displayedUnit and (not UnitIsUnit(unit, self.displayedUnit) and not ((unit == "vehicle" or unit == "player") and (self.displayedUnit == "vehicle" or self.displayedUnit == "player")))) then
		return
	end

	-- this part doesnt really get called ever but if for some reason we fail to get guid this can pick it up later on
	if self.mainFrame and not self.plateGUID then
		local _, plateGUID = mod:GetNameplateID(self.mainFrame)
		if plateGUID then
			self.plateGUID = plateGUID
			mod.PlateGUIDs[plateGUID] = self.mainFrame
		end
	end

	if(event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT") then
		mod:UpdateElement_Health(self)
		mod:UpdateElement_HealPrediction(self)
		mod:UpdateElement_Glow(self)
		mod:UpdateElement_Filters(self, event)
		if unit == "vehicle" or unit == "player" then
			mod:UpdateVisibility()
		end
	elseif(event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_PREDICTION") then
		mod:UpdateElement_HealPrediction(self)
	elseif(event == "UNIT_MAXHEALTH") then
		mod:UpdateElement_MaxHealth(self)
		mod:UpdateElement_HealPrediction(self)
		mod:UpdateElement_Glow(self)
		mod:UpdateElement_Filters(self, event)
	elseif(event == "UNIT_NAME_UPDATE") then
		mod:UpdateElement_Name(self)
		mod:UpdateElement_NPCTitle(self)
		mod:UpdateElement_HealthColor(self) --Unit class sometimes takes a bit to load
		mod:UpdateElement_Filters(self, event)
	elseif(event == "UNIT_LEVEL") then
		mod:UpdateElement_Level(self)
	elseif(event == "UNIT_THREAT_LIST_UPDATE") then
		mod:Update_ThreatList(self)
		mod:UpdateElement_HealthColor(self)
		mod:UpdateElement_Filters(self, event)
	elseif(event == "PLAYER_TARGET_CHANGED") then
		mod:SetTargetFrame(self)
		mod:UpdateElement_Glow(self)
		mod:UpdateElement_HealthColor(self)
		mod:UpdateElement_Filters(self, event)
		mod:ForEachPlate("ResetNameplateFrameLevel") --keep this after `UpdateElement_Filters`
		mod:UpdateVisibility()
	elseif(event == "UNIT_TARGET") then
		self.isTargetingMe = UnitIsUnit(unit..'target', 'player')
		mod:UpdateElement_Filters(self, event)
		if unit == "player" and not UnitExists("target") then --basically a `PLAYER_TARGET_CLEARED`, though, it's slower than `PLAYER_TARGET_CHANGED`
			mod:ForEachPlate("ResetNameplateFrameLevel") --keep this after `UpdateElement_Filters`
		end
	elseif(event == "UNIT_AURA") then
		mod:UpdateElement_Auras(self)
		if(self.IsPlayerFrame) then
			mod:ClassBar_Update()
		end
		mod:UpdateElement_HealthColor(self)
		mod:UpdateElement_Filters(self, event)
	elseif(event == "PLAYER_ROLES_ASSIGNED" or event == "UNIT_FACTION") then
		local wasUpdated = mod:CheckUnitType(self)
		if not wasUpdated then
			mod:UpdateElement_HealthColor(self)
			mod:UpdateElement_Filters(self, event)
		end
	elseif(event == "RAID_TARGET_UPDATE") then
		mod:UpdateElement_RaidIcon(self)
	elseif(event == "UNIT_MAXPOWER") then
		mod:UpdateElement_MaxPower(self)
	elseif(event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER") then
		local powerType, powerToken = UnitPowerType(self.displayedUnit)
		local arg1 = ...
		self.PowerToken = powerToken
		self.PowerType = powerType
		if(event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT") then
			if mod.ClassBar and arg1 == powerToken then
				mod:ClassBar_Update()
			end
		end

		if arg1 == powerToken or event == "UNIT_DISPLAYPOWER" then
			mod:UpdateElement_Power(self)
		end
		mod:UpdateElement_Filters(self, event)
	elseif(event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_EXITING_VEHICLE" or event == "UNIT_PET")then
		mod:UpdateInVehicle(self)
		mod:UpdateElement_All(self, unit, true)
	elseif(event == "UPDATE_MOUSEOVER_UNIT") then
		mod:UpdateElement_Highlight(self)
	elseif(event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" or event == "UNIT_CONNECTION") then
		mod:UpdateElement_Portrait(self)
	elseif(event == "SPELL_UPDATE_COOLDOWN") then
		mod:UpdateElement_Filters(self, event)
	else
		mod:UpdateElement_Cast(self, event, unit, ...)
	end
end

function mod:RegisterEvents(frame, unit)
	local displayedUnit
	if not unit then unit = frame.unit end
	if unit ~= frame.displayedUnit then
		displayedUnit = frame.displayedUnit
	end

	if(self.db.units[frame.UnitType].healthbar.enable or (frame.isTarget and self.db.alwaysShowTargetHealth)) then
		frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_HEALTH", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit, displayedUnit);
	end

	frame:RegisterEvent("UNIT_NAME_UPDATE");
	frame:RegisterUnitEvent("UNIT_LEVEL", unit, displayedUnit);

	--if(self.db.units[frame.UnitType].portrait.enable) then
		frame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_MODEL_CHANGED", unit, displayedUnit);
		frame:RegisterUnitEvent("UNIT_CONNECTION", unit, displayedUnit);
	--end

	if(self.db.units[frame.UnitType].healthbar.enable or (frame.isTarget and self.db.alwaysShowTargetHealth)) then
		if(frame.UnitType == "ENEMY_NPC") then
			frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit);
		end

		if(self.db.units[frame.UnitType].powerbar.enable) then
			frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit, displayedUnit)
			frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit)
			frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit, displayedUnit)
			frame:RegisterUnitEvent("UNIT_MAXPOWER", unit, displayedUnit)
		end

		if(self.db.units[frame.UnitType].castbar.enable) then
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			frame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
			frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
			frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit, displayedUnit);
			frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit, displayedUnit);
			frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit, displayedUnit);

			if unit == 'player' then
				frame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", unit, displayedUnit);
			end
		end

		frame:RegisterEvent("PLAYER_ENTERING_WORLD");

		if(self.db.units[frame.UnitType].buffs.enable or self.db.units[frame.UnitType].debuffs.enable) then
			frame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit)
		end
		mod.OnEvent(frame, "PLAYER_ENTERING_WORLD", unit)
	end

	frame:RegisterEvent("RAID_TARGET_UPDATE")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITING_VEHICLE")
	frame:RegisterEvent("UNIT_PET")
	frame:RegisterEvent("UNIT_TARGET")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	frame:RegisterEvent("UNIT_FACTION")
	frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
end

function mod:SetClassNameplateBar(frame)
	mod.ClassBar = frame
	if frame then
		frame:SetScale(1.35)
	end
end

function mod:UpdateCVars()
	E:LockCVar("nameplateMotion", self.db.motionType == "STACKED" and "1" or "0")
	E:LockCVar("nameplateShowAll", self.db.displayStyle ~= "ALL" and "0" or "1")
	E:LockCVar("nameplateShowFriendlyMinions", self.db.units.FRIENDLY_PLAYER.minions == true and "1" or "0")
	E:LockCVar("nameplateShowEnemyMinions", self.db.units.ENEMY_PLAYER.minions == true and "1" or "0")
	E:LockCVar("nameplateShowEnemyMinus", self.db.units.ENEMY_NPC.minors == true and "1" or "0")

	E:LockCVar("nameplateMaxDistance", self.db.loadDistance)
	E:LockCVar("nameplateOtherTopInset", self.db.clampToScreen and "0.08" or "-1")
	E:LockCVar("nameplateOtherBottomInset", self.db.clampToScreen and "0.1" or "-1")

	--This one prevents classbar from being shown on friendly blizzard plates
	-- we do this because it will otherwise break enemy nameplates after targeting a friendly one
	E:LockCVar("nameplateResourceOnTarget", 0)

	--Player nameplate
	E:LockCVar("nameplateShowSelf", (self.db.units.PLAYER.useStaticPosition == true or self.db.units.PLAYER.enable ~= true) and "0" or "1")
	E:LockCVar("nameplatePersonalShowAlways", (self.db.units.PLAYER.visibility.showAlways == true and "1" or "0"))
	E:LockCVar("nameplatePersonalShowInCombat", (self.db.units.PLAYER.visibility.showInCombat == true and "1" or "0"))
	E:LockCVar("nameplatePersonalShowWithTarget", (self.db.units.PLAYER.visibility.showWithTarget == true and "1" or "0"))
	E:LockCVar("nameplatePersonalHideDelaySeconds", self.db.units.PLAYER.visibility.hideDelay)
end

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if(type(value) == "table" and to[setting] ~= nil) then
			CopySettings(from[setting], to[setting])
		else
			if(to[setting] ~= nil) then
				to[setting] = from[setting]
			end
		end
	end
end

function mod:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function mod:CopySettings(from, to)
	if(from == to) then return end

	CopySettings(self.db.units[from], self.db.units[to])
end

function mod:TogglePlayerDisplayType()
	if(self.db.units.PLAYER.enable and self.db.units.PLAYER.useStaticPosition) then
		self.PlayerFrame__:Show()
		RegisterUnitWatch(self.PlayerFrame__)
		E:EnableMover("PlayerNameplate")
		self:NAME_PLATE_UNIT_ADDED("NAME_PLATE_UNIT_ADDED", "player", self.PlayerFrame__)
		self.PlayerNamePlateAnchor:SetParent(self.PlayerFrame__)
		self.PlayerNamePlateAnchor:SetAllPoints(self.PlayerFrame__.unitFrame)
		self:UpdateVisibility()
	else
		UnregisterUnitWatch(self.PlayerFrame__)
		E:DisableMover("PlayerNameplate")
		if(self.PlayerFrame__:IsShown()) then
			self:NAME_PLATE_UNIT_REMOVED("NAME_PLATE_UNIT_REMOVED", "player", self.PlayerFrame__)
			self.PlayerFrame__:Hide()
			self.PlayerNamePlateAnchor:Hide()
		end
	end
end

function mod:UpdateVehicleStatus()
	if ( UnitHasVehicleUI("player") ) then
		self.playerUnitToken = "vehicle"
	else
		self.playerUnitToken = "player"
	end
end

function mod:PLAYER_REGEN_DISABLED()
	if(self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1);
	elseif(self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0);
	end

	if(self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1);
	elseif(self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0);
	end

	if self.db.units.PLAYER.useStaticPosition then
		self:UpdateVisibility()
	end
end

function mod:PLAYER_REGEN_ENABLED()
	if(self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif(self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if(self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif(self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end

	if self.db.units.PLAYER.useStaticPosition then
		self:UpdateVisibility()
	end
end

local playerNamePlateHideTimer
function mod:UpdateVisibility()
	local frame = self.PlayerFrame__
	if self.db.units.PLAYER.useStaticPosition then
		if frame.unitFrame.VisibilityChanged then
			return
		end
		if playerNamePlateHideTimer then
			playerNamePlateHideTimer:Cancel()
		end
		if (self.db.units.PLAYER.visibility.showAlways) then
			frame.unitFrame:Show()
			self.PlayerNamePlateAnchor:Show()
		else
			local curHP, maxHP = UnitHealth("player"), UnitHealthMax("player")
			local inCombat = UnitAffectingCombat("player")
			local hasTarget = UnitExists("target")
			local canAttack = UnitCanAttack("player", "target")

			if (curHP ~= maxHP) or (self.db.units.PLAYER.visibility.showInCombat and inCombat) or (self.db.units.PLAYER.visibility.showWithTarget and hasTarget and canAttack) then
				frame.unitFrame:Show()
				self.PlayerNamePlateAnchor:Show()
			elseif frame.unitFrame:IsShown() then
				if (self.db.units.PLAYER.visibility.hideDelay > 0) then
					playerNamePlateHideTimer = C_Timer_NewTimer(self.db.units.PLAYER.visibility.hideDelay, HidePlayerNamePlate)
				else
					HidePlayerNamePlate()
				end
			end
		end
	else
		frame.unitFrame:Hide()
	end
end

function mod:UpdateFonts(plate)
	-- used by the gui to update the aura icon text like duration/stacks
	if not plate then return end

	--buff fonts
	if plate.Buffs and plate.Buffs.db and plate.Buffs.db.numAuras then
		for i=1, plate.Buffs.db.numAuras do
			if plate.Buffs.icons[i] and plate.Buffs.icons[i].count then
				plate.Buffs.icons[i].count:SetFont(LSM:Fetch("font", self.db.stackFont), self.db.stackFontSize, self.db.stackFontOutline)
			end

			self:UpdateCooldownSettings(plate.Buffs.icons[i].cooldown)
		end
	end

	--debuff fonts
	if plate.Debuffs and plate.Debuffs.db and plate.Debuffs.db.numAuras then
		for i=1, plate.Debuffs.db.numAuras do
			if plate.Debuffs.icons[i] and plate.Debuffs.icons[i].count then
				plate.Debuffs.icons[i].count:SetFont(LSM:Fetch("font", self.db.stackFont), self.db.stackFontSize, self.db.stackFontOutline)
			end

			self:UpdateCooldownSettings(plate.Debuffs.icons[i].cooldown)
		end
	end

	--misc element fonts
	if plate.Name then
		plate.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	if plate.CastBar and plate.CastBar.Name then
		plate.CastBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	if plate.CastBar and plate.CastBar.Time then
		plate.CastBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	if plate.HealthBar and plate.HealthBar.text then
		plate.HealthBar.text:SetFont(LSM:Fetch("font", self.db.healthFont), self.db.healthFontSize, self.db.healthFontOutline)
	end
	if plate.PowerBar and plate.PowerBar.text then
		plate.PowerBar.text:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	if plate.Level then
		plate.Level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end
	if plate.NPCTitle then
		plate.NPCTitle:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	end

	--update glow incase name font changes
	local healthShown = (plate.UnitType and self.db.units[plate.UnitType].healthbar.enable) or (self.db.displayStyle ~= "ALL") or (plate.isTarget and self.db.alwaysShowTargetHealth)
	if healthShown then
		self:UpdateElement_Glow(plate)
	end
end

function mod:UpdatePlateFonts()
	self:ForEachPlate("UpdateFonts")
	if self.PlayerFrame__ then
		self:UpdateFonts(self.PlayerFrame__.unitFrame)
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, sourceGUID, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()

	if (event == "SPELL_INTERRUPT") and targetGUID and (sourceName and sourceName ~= "") then
		local plate = self.PlateGUIDs[targetGUID]
		if plate and (plate.unitFrame and plate.unitFrame.CastBar) then
			local db = plate.unitFrame.UnitType and self.db and self.db.units and self.db.units[plate.unitFrame.UnitType]
			local healthBar = (db and db.healthbar and db.healthbar.enable) or (plate.unitFrame.isTarget and self.db.alwaysShowTargetHealth)
			if healthBar and (db and db.castbar and db.castbar.enable) and db.castbar.sourceInterrupt then
				local holdTime = db.castbar.timeToHold
				if holdTime > 0 then
					if db.castbar.sourceInterruptClassColor then
						local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
						if sourceClass then
							local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[sourceClass]) or RAID_CLASS_COLORS[sourceClass];
							sourceClass = classColor and classColor.colorStr
						end

						plate.unitFrame.CastBar.interruptedBy = (sourceClass and strjoin('', '|c', sourceClass, sourceName)) or sourceName
					else
						plate.unitFrame.CastBar.interruptedBy = sourceName
					end
				end
			end
		end
	end
end

function mod:Initialize()
	self.db = E.db.nameplates
	if E.private.nameplates.enable ~= true then return end

	--Add metatable to all our StyleFilters so they can grab default values if missing
	self:StyleFilterInitializeAllFilters()

	--Populate `mod.StyleFilterEvents` with events Style Filters will be using and sort the filters based on priority.
	self:StyleFilterConfigureEvents()

	--Nameplate Leveling Step (glow, frame) (2)
	-- range is from 3 [(1*2)+1] to 81 [(40*2)+1] ~ [(nameplateID * step) + frame layer]
	-- 40 is the max amount of nameplate tokens
	self.levelStep = 2

	--We don't allow player nameplate health to be disabled
	self.db.units.PLAYER.healthbar.enable = true

	self:UpdateVehicleStatus()

	--Hacked Nameplate
	self.PlayerFrame__ = CreateFrame("BUTTON", "ElvUI_NamePlate_Player", E.UIParent, "SecureUnitButtonTemplate")
	self.PlayerFrame__:SetAttribute("unit", "player")
	self.PlayerFrame__:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self.PlayerFrame__:SetAttribute("*type1", "target")
	self.PlayerFrame__:SetAttribute("*type2", "togglemenu")
	self.PlayerFrame__:SetAttribute("toggleForVehicle", true)
	self.PlayerFrame__:SetPoint("TOP", UIParent, "CENTER", 0, -150)
	self.PlayerFrame__:Hide()

	--Create anchor frame for the default player resource bar, the one that moves around
	--Other addons can anchor stuff to this frame to make sure it follows the movement of the resource bar
	--Request: http://git.tukui.org/Elv/elvui/issues/1708
	self.PlayerNamePlateAnchor = CreateFrame("Frame", "ElvUIPlayerNamePlateAnchor", E.UIParent)
	self.PlayerNamePlateAnchor:Hide()

	self:UpdateCVars()

	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_LOGOUT"); -- used in the StyleFilter
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateVehicleStatus")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateVehicleStatus")
	self:RegisterEvent("UNIT_EXITING_VEHICLE", "UpdateVehicleStatus")
	self:RegisterEvent("UNIT_PET", "UpdateVehicleStatus")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_REMOVED")
	self:RegisterEvent("QUEST_LOG_UPDATE")

	self.Tooltip = CreateFrame('GameTooltip', "ElvUIQuestTooltip", nil, 'GameTooltipTemplate')
	self.Tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

	local numEntries = GetNumQuestLogEntries();
	for questLogIndex = 1, numEntries do
		local title, _, _, _, _, _, _, questID = GetQuestLogTitle(questLogIndex);
		if title and questID and questID > 0 then
			self.ActiveQuests[title] = questID
		end
	end

	if self.db.hideBlizzardPlates then
		InterfaceOptionsNamesPanelUnitNameplates:Kill()
		NamePlateDriverFrame:UnregisterAllEvents()
		--This taints and prevents default nameplates in dungeons and raids
		NamePlateDriverFrame.ApplyFrameOptions = E.noop
		NamePlateDriverFrame.SetupClassNameplateBars = E.noop
	else
		InterfaceOptionsNamesPanelUnitNameplatesAggroFlash:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesShowAll:Kill()
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Point("TOPLEFT", InterfaceOptionsNamesPanelUnitNameplates, "TOPLEFT", 0, -20)
		InterfaceOptionsNamesPanelUnitNameplatesFriends:Point("TOPLEFT", InterfaceOptionsNamesPanelUnitNameplates, "TOPLEFT", 0, -50)
		InterfaceOptionsNamesPanelUnitNameplatesEnemies:Point("TOPLEFT", InterfaceOptionsNamesPanelUnitNameplates, "TOPLEFT", 0, -80)
	end

	-- Update NamePlate clickable range when the blizzard CVars change (workaround for #206)
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", mod.NamePlateDriverFrame_UpdateNamePlateOptions)

	--Best to just Hijack Blizzard's nameplate classbar
	self.ClassBar = NamePlateDriverFrame.nameplateBar
	if(self.ClassBar) then
		self.ClassBar:SetScale(1.35)
		self.ClassBar:EnableMouse(false)
	end
	hooksecurefunc(NamePlateDriverFrame, "SetClassNameplateBar", mod.SetClassNameplateBar)

	if not self.db.hideBlizzardPlates then
		--This takes care of showing the nameplate and setting parent back after Blizzard changes during updates
		hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", function(self, _, bar)
			if bar and bar == self.nameplateBar then
				if mod.ClassBar ~= bar then
					mod:SetClassNameplateBar(bar) --update our ClassBar link
				end
				mod:ClassBar_Update() --update the visibility
			end
		end)
	end

	self:DISPLAY_SIZE_CHANGED() --Run once for good measure.
	self:SetBaseNamePlateSize()

	self:NAME_PLATE_CREATED("NAME_PLATE_CREATED", self.PlayerFrame__)
	self:NAME_PLATE_UNIT_ADDED("NAME_PLATE_UNIT_ADDED", "player", self.PlayerFrame__)
	self:NAME_PLATE_UNIT_REMOVED("NAME_PLATE_UNIT_REMOVED", "player", self.PlayerFrame__)
	E:CreateMover(self.PlayerFrame__, "PlayerNameplate", L["Player Nameplate"], nil, nil, nil, nil, nil, 'nameplate,playerGroup,general')
	self:TogglePlayerDisplayType()
	self:SetNamePlateClickThrough()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	E.NamePlates = self
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)
