local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local tonumber, pairs, select, tostring, unpack = tonumber, pairs, select, tostring, unpack
local twipe, tsort, tinsert, wipe = table.wipe, table.sort, table.insert, wipe
local band = bit.band
local floor = math.floor
local gsub, format, strsplit = string.gsub, format, strsplit
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitHealthMax = UnitHealthMax
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldScore = GetBattlefieldScore
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local UnitName = UnitName
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetSpecializationInfoByID = GetSpecializationInfoByID
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local IsInInstance = IsInInstance
local SetCVar = SetCVar
local IsAddOnLoaded = IsAddOnLoaded
local GetComboPoints = GetComboPoints
local UnitHasVehicleUI = UnitHasVehicleUI
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff
local UnitPlayerControlled = UnitPlayerControlled
local GetRaidTargetIndex = GetRaidTargetIndex
local WorldFrame = WorldFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local UNKNOWN = UNKNOWN
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, AURA_TYPE_BUFF, AURA_TYPE_DEBUFF

local numChildren = -1
local targetIndicator
local targetAlpha = 1

--Pattern to remove cross realm label added to the end of plate names
--Taken from http://www.wowace.com/addons/libnameplateregistry-1-0/
local FSPAT = "%s*"..((_G.FOREIGN_SERVER_LABEL:gsub("^%s", "")):gsub("[%*()]", "%%%1")).."$"

NP.NumTargetChecks = -1
NP.CreatedPlates = {};
NP.Healers = {};
NP.ComboPoints = {};
NP.ByRaidIcon = {}			-- Raid Icon to GUID 		-- ex.  ByRaidIcon["SKULL"] = GUID
NP.ByName = {}				-- Name to GUID (PVP)
NP.AuraList = {}	-- Two Dimensional
NP.AuraSpellID = {}
NP.AuraExpiration = {}
NP.AuraStacks = {}
NP.AuraCaster = {}
NP.AuraDuration = {}
NP.AuraTexture = {}
NP.AuraType = {}
NP.AuraTarget = {}
NP.CachedAuraDurations = {}
NP.BuffCache = {}
NP.DebuffCache = {}

NP.HealerSpecs = {
	[L["Restoration"]] = true,
	[L["Holy"]] = true,
	[L["Discipline"]] = true,
	[L["Mistweaver"]] = true,
}

NP.RaidTargetReference = {
	["STAR"] = 0x00000001,
	["CIRCLE"] = 0x00000002,
	["DIAMOND"] = 0x00000004,
	["TRIANGLE"] = 0x00000008,
	["MOON"] = 0x00000010,
	["SQUARE"] = 0x00000020,
	["CROSS"] = 0x00000040,
	["SKULL"] = 0x00000080,
}

NP.RaidIconCoordinate = {
	[0]		= { [0]		= "STAR", [0.25]	= "MOON", },
	[0.25]	= { [0]		= "CIRCLE", [0.25]	= "SQUARE",	},
	[0.5]	= { [0]		= "DIAMOND", [0.25]	= "CROSS", },
	[0.75]	= { [0]		= "TRIANGLE", [0.25]	= "SKULL", },
}

NP.ComboColors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.65, 0.63, 0.35},
	[4] = {0.65, 0.63, 0.35},
	[5] = {0.33, 0.59, 0.33}
}

NP.RaidMarkColors = {
	["STAR"] = {r = 0.85, g = 0.81, b = 0.27},
	["MOON"] = {r = 0.60,g = 0.75,b = 0.85},
	["CIRCLE"] = {r = 0.93,g = 0.51,b = 0.06},
	["SQUARE"] = {r = 0,g = 0.64,b = 1},
	["DIAMOND"] = {r = 0.7,g = 0.06,b = 0.84},
	["CROSS"] = {r = 0.82,g = 0.18,b = 0.18},
	["TRIANGLE"] = {r = 0.14,g = 0.66,b = 0.14},
	["SKULL"] = {r = 0.89,g = 0.83,b = 0.74},
}

local AURA_UPDATE_INTERVAL = 0.1
local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2
local AuraList, AuraGUID = {}, {}

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL",
}
local TimeColors = {
	[0] = '|cffeeeeee',
	[1] = '|cffeeeeee',
	[2] = '|cffeeeeee',
	[3] = '|cffFFEE00',
	[4] = '|cfffe0000',
}

function NP:SetTargetIndicatorDimensions()
	if(self.db.targetIndicator.style == 'arrow') then
		targetIndicator.arrow:SetHeight(self.db.targetIndicator.height)
		targetIndicator.arrow:SetWidth(self.db.targetIndicator.width)
	elseif(self.db.targetIndicator.style == 'doubleArrow' or self.db.targetIndicator.style == 'doubleArrowInverted') then
		targetIndicator.left:SetHeight(self.db.targetIndicator.height)
		targetIndicator.left:SetWidth(self.db.targetIndicator.width)
		targetIndicator.right:SetWidth(self.db.targetIndicator.width)
		targetIndicator.right:SetHeight(self.db.targetIndicator.height)
	end
end

function NP:PositionTargetIndicator(myPlate)
	targetIndicator:SetParent(myPlate)
	if(self.db.targetIndicator.style == 'arrow') then
		targetIndicator.arrow:ClearAllPoints()
		targetIndicator.arrow:SetPoint("BOTTOM", myPlate.healthBar, "TOP", 0, 30 + self.db.targetIndicator.yOffset)
	elseif(self.db.targetIndicator.style == 'doubleArrow') then
		targetIndicator.left:SetPoint("RIGHT", myPlate.healthBar, "LEFT", -self.db.targetIndicator.xOffset, 0)
		targetIndicator.right:SetPoint("LEFT", myPlate.healthBar, "RIGHT", self.db.targetIndicator.xOffset, 0)
		targetIndicator:SetFrameLevel(0)
		targetIndicator:SetFrameStrata("BACKGROUND")
	elseif(self.db.targetIndicator.style == 'doubleArrowInverted') then
		targetIndicator.right:SetPoint("RIGHT", myPlate.healthBar, "LEFT", -self.db.targetIndicator.xOffset, 0)
		targetIndicator.left:SetPoint("LEFT", myPlate.healthBar, "RIGHT", self.db.targetIndicator.xOffset, 0)
		targetIndicator:SetFrameLevel(0)
		targetIndicator:SetFrameStrata("BACKGROUND")
	elseif(self.db.targetIndicator.style == 'glow') then
		targetIndicator:SetOutside(myPlate.healthBar, 3, 3)
		targetIndicator:SetFrameLevel(0)
		targetIndicator:SetFrameStrata("BACKGROUND")
	end

	targetIndicator:Show()
end

function NP:ColorTargetIndicator(r, g, b)
	if(self.db.targetIndicator.style == 'arrow') then
		targetIndicator.arrow:SetVertexColor(r, g, b)
	elseif(self.db.targetIndicator.style == 'doubleArrow' or self.db.targetIndicator.style == 'doubleArrowInverted') then
		targetIndicator.left:SetVertexColor(r, g, b)
		targetIndicator.right:SetVertexColor(r, g, b)
	elseif(self.db.targetIndicator.style == 'glow') then
		targetIndicator:SetBackdropBorderColor(r, g, b)
	end
end

function NP:SetTargetIndicator()
	if(self.db.targetIndicator.style == 'arrow') then
		targetIndicator = self.arrowIndicator
		self.glowIndicator:Hide()
		self.doubleArrowIndicator:Hide()
	elseif(self.db.targetIndicator.style == 'doubleArrow' or self.db.targetIndicator.style == 'doubleArrowInverted') then
		targetIndicator = self.doubleArrowIndicator
		targetIndicator.left:ClearAllPoints()
		targetIndicator.right:ClearAllPoints()
		self.arrowIndicator:Hide()
		self.glowIndicator:Hide()
	elseif(self.db.targetIndicator.style == 'glow') then
		targetIndicator = self.glowIndicator
		self.arrowIndicator:Hide()
		self.doubleArrowIndicator:Hide()
	end

	self:SetTargetIndicatorDimensions()
end

function NP:OnUpdate(elapsed)
	local count = WorldFrame:GetNumChildren()
	if(count ~= numChildren) then
		numChildren = count
		NP:ScanFrames(WorldFrame:GetChildren())
	end

	NP.PlateParent:Hide()
	for blizzPlate, plate in pairs(NP.CreatedPlates) do
		if(blizzPlate:IsShown()) then
			if(not self.viewPort) then
				plate:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", blizzPlate:GetCenter())
			end
			NP.SetAlpha(blizzPlate, plate)
		else
			plate:Hide()
		end
	end
	NP.PlateParent:Show()

	if(self.elapsed and self.elapsed > 0.2) then
		for blizzPlate, plate in pairs(NP.CreatedPlates) do
			if(blizzPlate:IsShown() and plate:IsShown()) then
				NP.SetUnitInfo(blizzPlate, plate)
				NP.ColorizeAndScale(blizzPlate, plate)
				NP.UpdateLevelAndName(blizzPlate, plate)
				plate:SetDepth(25) --See http://git.tukui.org/Elv/elvui/issues/7#note_288
			end
		end

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

function NP:CheckFilterAndHealers(myPlate)
	local name = gsub(self.name:GetText(), FSPAT,'')
	local db = E.global.nameplate["filter"][name]

	if db and db.enable then
		if db.hide then
			myPlate:Hide()
			return
		else
			if(not myPlate:IsShown()) then
				myPlate:Show()
			end

			if db.customColor then
				self.customColor = db.color
				myPlate.healthBar:SetStatusBarColor(db.color.r, db.color.g, db.color.b)
			else
				self.customColor = nil
			end

			if db.customScale and db.customScale ~= 1 then
				myPlate.healthBar:Height(NP.db.healthBar.height * db.customScale)
				myPlate.healthBar:Width(NP.db.healthBar.width * db.customScale)
				self.customScale = true
			else
				self.customScale = nil
			end
		end
	elseif(not myPlate:IsShown()) then
		myPlate:Show()
	end

	if NP.Healers[name] then
		myPlate.healerIcon:Show()
	else
		myPlate.healerIcon:Hide()
	end

	return true
end

function NP:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
		if name then
			name = name:match("(.+)%-.+") or name
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil;
			end
		end
	end
end

function NP:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then return end

	for i=1, 5 do
		local name = UnitName(format('arena%d', i))
		if name and name ~= UNKNOWN then
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

function NP:UpdateLevelAndName(myPlate)
	if not NP.db.showLevel then
		myPlate.level:SetText("")
		myPlate.level:Hide()
	else
		local level, elite, boss = self.level:GetObjectType() == 'FontString' and tonumber(self.level:GetText()) or nil, self.eliteIcon:IsShown(), self.bossIcon:IsShown()
		if boss then
			myPlate.level:SetText("??")
			myPlate.level:SetTextColor(0.8, 0.05, 0)
		elseif level then
			myPlate.level:SetText(level..(elite and "+" or ""))
			myPlate.level:SetTextColor(self.level:GetTextColor())
		end

		if self.isSmall then
			myPlate.level:SetText("")
			myPlate.level:Hide()
		elseif not myPlate.level:IsShown() then
			myPlate.level:Show()
		end
	end

	if not NP.db.showName then
		myPlate.name:SetText("")
		myPlate.name:Hide()
	else
		myPlate.name:SetText(self.name:GetText())
		myPlate.name.stringHeight = myPlate.name:GetStringHeight()
		if not myPlate.name:IsShown() then myPlate.name:Show() end
	end

	if self.raidIcon:IsShown() then
		myPlate.raidIcon:Show()
		myPlate.raidIcon:SetTexCoord(self.raidIcon:GetTexCoord())
	else
		myPlate.raidIcon:Hide()
	end
end

function NP:GetReaction(frame)
	local r, g, b = NP:RoundColors(frame.healthBar:GetStatusBarColor())

	for class, _ in pairs(RAID_CLASS_COLORS) do
		local bb = b
		if class == 'MONK' then
			bb = bb - 0.01
		end

		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == bb then
			return class
		end
	end

	if (r + b + b) == 1.59 then
		return 'TAPPED_NPC'
	elseif g + b == 0 then
		return 'HOSTILE_NPC'
	elseif r + b == 0 then
		return 'FRIENDLY_NPC'
	elseif r + g > 1.95 then
		return 'NEUTRAL_NPC'
	elseif r + g == 0 then
		return 'FRIENDLY_PLAYER'
	else
		return 'HOSTILE_PLAYER'
	end
end

function NP:GetThreatReaction(frame)
	if frame.threat:IsShown() then
		local r, g, b = frame.threat:GetVertexColor()
		if g + b == 0 then
			return "FULL_THREAT", r, g
		else
			if (r == frame.prevRedValue and g == frame.prevGreenValue) then
				return frame.threatReaction, r, g
			elseif (r > frame.prevRedValue) or (r > 0.99 and (g < frame.prevGreenValue)) then
				return "GAINING_THREAT", r, g
			else
				return "LOSING_THREAT", r, g
			end
		end
	else
		return "NO_THREAT", 0, 0
	end
end

local color, scale
function NP:ColorizeAndScale(myPlate)
	local unitType = NP:GetReaction(self)
	local scale = 1
	local canAttack = false

	self.unitType = unitType
	if CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[unitType] then
		color = CUSTOM_CLASS_COLORS[unitType]
	elseif RAID_CLASS_COLORS[unitType] then
		color = RAID_CLASS_COLORS[unitType]
	elseif unitType == "TAPPED_NPC" then
		color = NP.db.reactions.tapped
	elseif unitType == "HOSTILE_NPC" or unitType == "NEUTRAL_NPC" then
		local classRole = E.role
		local threatReaction, redValue, greenValue = NP:GetThreatReaction(self)
		canAttack = true
		if(not NP.db.threat.enable) then
			if unitType == "NEUTRAL_NPC" then
				color = NP.db.reactions.neutral
			else
				color = NP.db.reactions.enemy
			end
		elseif threatReaction == 'FULL_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.goodColor
				scale = NP.db.threat.goodScale
			else
				color = NP.db.threat.badColor
				scale = NP.db.threat.badScale
			end
		elseif threatReaction == 'GAINING_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.goodTransitionColor
			else
				color = NP.db.threat.badTransitionColor
			end
		elseif threatReaction == 'LOSING_THREAT' then
			if classRole == 'Tank' then
				color = NP.db.threat.badTransitionColor
			else
				color = NP.db.threat.goodTransitionColor
			end
		elseif InCombatLockdown() then
			if classRole == 'Tank' then
				color = NP.db.threat.badColor
				scale = NP.db.threat.badScale
			else
				color = NP.db.threat.goodColor
				scale = NP.db.threat.goodScale
			end
		else
			if unitType == "NEUTRAL_NPC" then
				color = NP.db.reactions.neutral
			else
				color = NP.db.reactions.enemy
			end
		end

		self.threatReaction = threatReaction
		self.prevRedValue = redValue
		self.prevGreenValue = greenValue
	elseif unitType == "FRIENDLY_NPC" then
		color = NP.db.reactions.friendlyNPC
	elseif unitType == "FRIENDLY_PLAYER" then
		color = NP.db.reactions.friendlyPlayer
	else
		color = NP.db.reactions.enemy
	end

	if self.raidIcon:IsShown() and NP.db.healthBar.colorByRaidIcon then
		NP:CheckRaidIcon(self)
		local raidColor = NP.RaidMarkColors[self.raidIconType]
		color = raidColor or color
	end

	if (NP.db.healthBar.lowHPScale.enable and NP.db.healthBar.lowHPScale.changeColor and myPlate.lowHealth:IsShown() and canAttack) then
		color = NP.db.healthBar.lowHPScale.color
	end

	if(not self.customColor) then
		myPlate.healthBar:SetStatusBarColor(color.r, color.g, color.b)

		if(NP.db.targetIndicator.enable and NP.db.targetIndicator.colorMatchHealthBar and self.unit == "target") then
			NP:ColorTargetIndicator(color.r, color.g, color.b)
		end
	elseif(self.unit == "target" and NP.db.targetIndicator.colorMatchHealthBar and NP.db.targetIndicator.enable) then
		NP:ColorTargetIndicator(self.customColor.r, self.customColor.g, self.customColor.b)
	end

	local w = NP.db.healthBar.width * scale
	local h = NP.db.healthBar.height * scale
	if NP.db.healthBar.lowHPScale.enable then
		if myPlate.lowHealth:IsShown() then
			w = NP.db.healthBar.lowHPScale.width * scale
			h = NP.db.healthBar.lowHPScale.height * scale
			if NP.db.healthBar.lowHPScale.toFront then
				myPlate:SetFrameStrata("MEDIUM")
			end
		else
			if NP.db.healthBar.lowHPScale.toFront then
				myPlate:SetFrameStrata("BACKGROUND")
			end
		end
	end
	if(not self.customScale and not self.isSmall and (not myPlate.healthBar.prevWidth or (myPlate.healthBar.prevWidth ~= w or myPlate.healthBar.prevHeight ~= h))) then
		myPlate.healthBar.prevWidth, myPlate.healthBar.prevHeight = w, h
		myPlate.healthBar:SetSize(w, h)
		myPlate.castBar.icon:SetSize(NP.db.castBar.height + h + 5, NP.db.castBar.height + h + 5)
	end
end

function NP:SetAlpha(myPlate)
	if self:GetAlpha() < 1 then
		myPlate:SetAlpha(NP.db.nonTargetAlpha)
	else
		myPlate:SetAlpha(targetAlpha)
	end
end

function NP:SetUnitInfo(myPlate)
	local plateName = gsub(self.name:GetText(), FSPAT,'')
	if self:GetAlpha() == 1 and NP.targetName and (NP.targetName == plateName) then
		self.guid = UnitGUID("target")
		self.unit = "target"
		self.maxHP = UnitHealthMax("target")
		myPlate:SetFrameLevel(2)
		myPlate.overlay:Hide()

		if(NP.db.targetIndicator.enable) then
			targetIndicator:Show()
			NP:PositionTargetIndicator(myPlate)
			targetIndicator:SetDepth(myPlate:GetDepth())
		end

		NP:UpdateComboPointsByUnitID('target')
		NP:UpdateAurasByUnitID('target')
	elseif self.highlight:IsShown() and UnitExists("mouseover") and (UnitName("mouseover") == plateName) then
		if(self.unit ~= "mouseover") then
			myPlate:SetFrameLevel(1)
			myPlate.overlay:Show()
			NP:UpdateAurasByUnitID('mouseover')
			NP:UpdateComboPointsByUnitID('mouseover')
		end
		self.guid = UnitGUID("mouseover")
		self.unit = "mouseover"
		self.maxHP = UnitHealthMax("mouseover")
		NP:UpdateAurasByUnitID('mouseover')
	else
		myPlate:SetFrameLevel(0)
		myPlate.overlay:Hide()
		self.unit = nil
	end
end

function NP:PLAYER_ENTERING_WORLD()
	twipe(self.Healers)
	twipe(self.ComboPoints)
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' and self.db.raidHealIcon.markHealers then
		self.CheckHealerTimer = self:ScheduleRepeatingTimer("CheckBGHealers", 3)
		self:CheckBGHealers()
	elseif inInstance and instanceType == 'arena' and self.db.raidHealIcon.markHealers then
		self:RegisterEvent('UNIT_NAME_UPDATE', 'CheckArenaHealers')
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", 'CheckArenaHealers');
		self:CheckArenaHealers()
	else
		self:UnregisterEvent('UNIT_NAME_UPDATE')
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		if self.CheckHealerTimer then
			self:CancelTimer(self.CheckHealerTimer)
			self.CheckHealerTimer = nil;
		end
	end
end

function NP:UPDATE_MOUSEOVER_UNIT()
	WorldFrame.elapsed = 0.1
end


function NP:PLAYER_TARGET_CHANGED()
	targetIndicator:Hide()
	if(UnitExists("target")) then
		self.targetName = UnitName("target")
		WorldFrame.elapsed = 0.1
		NP.NumTargetChecks = 0
		targetAlpha = E.db.nameplate.targetAlpha
	else
		targetIndicator:Hide()
		self.targetName = nil
		targetAlpha = 1
	end
end

function NP:PLAYER_REGEN_DISABLED()
	SetCVar("nameplateShowEnemies", 1)
end

function NP:PLAYER_REGEN_ENABLED()
	SetCVar("nameplateShowEnemies", 0)
end

function NP:CombatToggle(noToggle)
	if(self.db.combatHide) then
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		if(not noToggle) then
			SetCVar("nameplateShowEnemies", 0)
		end
	else
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if(not noToggle) then
			SetCVar("nameplateShowEnemies", 1)
		end
	end
end

function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP

	self.PlateParent = CreateFrame("Frame", nil, WorldFrame)
	self.PlateParent:SetFrameStrata("BACKGROUND")
	self.PlateParent:SetFrameLevel(0)
	WorldFrame:HookScript('OnUpdate', NP.OnUpdate)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("UNIT_COMBO_POINTS")

	self.arrowIndicator = CreateFrame("Frame", nil, WorldFrame)
	self.arrowIndicator.arrow = self.arrowIndicator:CreateTexture(nil, 'BORDER', -1)
	self.arrowIndicator.arrow:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator.tga]])
	self.arrowIndicator:Hide()

	self.doubleArrowIndicator = CreateFrame("Frame", nil, WorldFrame)
	self.doubleArrowIndicator.left = self.doubleArrowIndicator:CreateTexture(nil, 'BORDER', -1)
	self.doubleArrowIndicator.left:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft.tga]])
	self.doubleArrowIndicator.right = self.doubleArrowIndicator:CreateTexture(nil, 'BORDER', -1)
	self.doubleArrowIndicator.right:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight.tga]])
	self.doubleArrowIndicator:Hide()

	self.glowIndicator = CreateFrame("Frame", nil, WorldFrame)
	self.glowIndicator:SetFrameLevel(0)
	self.glowIndicator:SetFrameStrata("BACKGROUND")
	self.glowIndicator:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = 3,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	self.glowIndicator:SetBackdropColor(0, 0, 0, 0)
	self.glowIndicator:SetScale(E.PixelMode and 2.5 or 3)
	self.glowIndicator:Hide()

	self:SetTargetIndicator()
	self.viewPort = IsAddOnLoaded("SunnArt") or IsAddOnLoaded("CT_Viewport") or IsAddOnLoaded("Btex") or IsAddOnLoaded("LightViewPorter");
	self:CombatToggle(true)
end

function NP:UpdateAllPlates()
	if E.private["nameplate"].enable ~= true then return end
	NP:ForEachPlate("UpdateSettings")
end

function NP:ForEachPlate(functionToRun, ...)
	for blizzPlate, plate in pairs(self.CreatedPlates) do
		if(blizzPlate) then
			self[functionToRun](blizzPlate, plate, ...)
		end
	end
end

function NP:RoundColors(r, g, b)
	return floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
end

function NP:OnSizeChanged(width, height)
	local myPlate = NP.CreatedPlates[self]
	myPlate:SetSize(width, height)
end

function NP:OnShow()
	local myPlate = NP.CreatedPlates[self]
	local objectType
	for object in pairs(self.queue) do
		objectType = object:GetObjectType()
		if objectType == "Texture" then
			object.OldTexture = object:GetTexture()
			object:SetTexture("")
			object:SetTexCoord(0, 0, 0, 0)
		elseif objectType == 'FontString' then
			object:SetWidth(0.001)
		elseif objectType == 'StatusBar' then
			object:SetStatusBarTexture("")
		end
		if object ~= self.bossIcon and object ~= self.eliteIcon then
			object:Hide() -- HIDE EVERYTHING or SUFFER FROM LOW FPS, THIS IS BIGGEST ISSUE
		end
	end

	if(not NP.CheckFilterAndHealers(self, myPlate)) then return end
	self.isSmall = (self.healthBar:GetEffectiveScale() < 1 and NP.db.smallPlates)
	myPlate:SetSize(self:GetSize())

	myPlate.name:ClearAllPoints()
	if(self.isSmall) then
		myPlate.healthBar:SetSize(self.healthBar:GetWidth() * (self.healthBar:GetEffectiveScale() * 1.25), NP.db.healthBar.height)
		myPlate.name:SetPoint("BOTTOM", myPlate.healthBar, "TOP", 0, 3)
	else
		myPlate.name:SetPoint("BOTTOMLEFT", myPlate.healthBar, "TOPLEFT", 0, 3)
		myPlate.name:SetPoint("BOTTOMRIGHT", myPlate.level, "BOTTOMLEFT", -2, 0)
	end

	NP.UpdateLevelAndName(self, myPlate)
	NP.ColorizeAndScale(self, myPlate)

	NP.HealthBar_OnValueChanged(self.healthBar, self.healthBar:GetValue())
	myPlate.nameText = gsub(self.name:GetText(), FSPAT,'')

	--Check to see if its possible to update auras/comboPoints via raid icon or class color when a plate is shown.
	if(not self.isSmall) then
		NP:CheckRaidIcon(self)
		NP:UpdateAuras(self)
		NP:UpdateComboPoints(self)
	end

	if(not NP.db.targetIndicator.colorMatchHealthBar) then
		NP:ColorTargetIndicator(NP.db.targetIndicator.color.r, NP.db.targetIndicator.color.g, NP.db.targetIndicator.color.b)
	end
end

function NP:OnHide()
	local myPlate = NP.CreatedPlates[self]
	self.threatReaction = nil
	self.unitType = nil
	self.guid = nil
	self.unit = nil
	self.maxHP = nil
	self.raidIconType = nil
	self.customColor = nil
	self.customScale = nil
	self.isSmall = nil

	if(targetIndicator:GetParent() == myPlate) then
		targetIndicator:Hide()
	end

	myPlate:SetAlpha(0)
	myPlate.lowHealth:Hide()
	myPlate.healerIcon:Hide()

	myPlate.healthBar:SetSize(NP.db.healthBar.width, NP.db.healthBar.height)
	myPlate.castBar.icon:Size(NP.db.castBar.height + NP.db.healthBar.height + 5)

	if myPlate.BuffWidget then
		for index = 1, #myPlate.BuffWidget.icons do
			NP.PolledHideIn(myPlate.BuffWidget.icons[index], 0)
		end
	end

	if myPlate.DebuffWidget then
		for index = 1, #myPlate.DebuffWidget.icons do
			NP.PolledHideIn(myPlate.DebuffWidget.icons[index], 0)
		end
	end

	for i=1, MAX_COMBO_POINTS do
		myPlate.cPoints[i]:Hide()
	end

	--UIFrameFadeOut(myPlate, 0.1, myPlate:GetAlpha(), 0)
	--myPlate:Hide()
	-- DOING THIS KILLS YOUR FPS
	--myPlate:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT") --Prevent nameplate being in random location on screen when first shown
end

function NP:SizeAuraHeader(myPlate, width, auraHeader, dbTable)
	local db = NP.db[dbTable]
	local baseSpacing = 1
	local numAuras = db.numAuras
	local auraWidth = ((width - (baseSpacing * (numAuras - 1))) / numAuras)
	local auraHeight = (db.stretchTexture and (auraWidth * 0.72) or auraWidth)

	for index = 1, numAuras do
		if not auraHeader.icons[index] then
			auraHeader.icons[index] = NP:CreateAuraIcon(auraHeader, myPlate, dbTable);
		end


		auraHeader.icons[index]:SetWidth(auraWidth)
		auraHeader.icons[index]:SetHeight(auraHeight)
		auraHeader.icons[index]:ClearAllPoints()
		if(dbTable == 'debuffs') then
			if(index == 1) then
				auraHeader.icons[index]:SetPoint("LEFT", auraHeader, 0, 0)
			else
				auraHeader.icons[index]:SetPoint("LEFT", auraHeader.icons[index-1], "RIGHT", baseSpacing, 0)
			end
		else
			if(index == 1) then
				auraHeader.icons[index]:SetPoint("RIGHT", auraHeader, 0, 0)
			else
				auraHeader.icons[index]:SetPoint("RIGHT", auraHeader.icons[index-1], "LEFT", -baseSpacing, 0)
			end
		end
	end

	if(numAuras > #auraHeader.icons) then
		for index = (numAuras + 1), #auraHeader.icons do
			NP.PolledHideIn(auraHeader.icons[index], 0)
		end
	end

	auraHeader.numAuras = numAuras
end

function NP:HealthBar_OnSizeChanged(width, height)
	--Adjust aura width/height ratio based on the healthBar width
	width = floor(width + 0.5)
	NP:SizeAuraHeader(self, width, self:GetParent().BuffWidget, 'buffs')
	NP:SizeAuraHeader(self, width, self:GetParent().DebuffWidget, 'debuffs')
end

function NP:HealthBar_OnValueChanged(value)
	local blizzPlate = self:GetParent():GetParent()
	local myPlate = NP.CreatedPlates[blizzPlate]
	local minValue, maxValue = self:GetMinMaxValues()
	myPlate.healthBar:SetMinMaxValues(minValue, maxValue)
	myPlate.healthBar:SetValue(value)

	--Health Threshold
	local percentValue = (value/maxValue)
	if percentValue < NP.db.healthBar.lowThreshold then
		myPlate.lowHealth:Show()
		if percentValue < (NP.db.healthBar.lowThreshold / 2) then
			myPlate.lowHealth:SetBackdropBorderColor(1, 0, 0, 0.9)
		else
			myPlate.lowHealth:SetBackdropBorderColor(1, 1, 0, 0.9)
		end
	elseif myPlate.lowHealth:IsShown() then
		myPlate.lowHealth:Hide()
	end

	--With patch 6.2.2 the min and max values were changed to 0 and 1. Hopefully this is a bug.
	--Force percentage display for the time being, as we have no other way to reliably get health values
	--Health Text
	-- if NP.db.healthBar.text.enable and value and maxValue and maxValue > 1 and self:GetScale() == 1 then
	if NP.db.healthBar.text.enable and value and maxValue and self:GetScale() == 1 then
		myPlate.healthBar.text:Show()
		if blizzPlate.maxHP then
			myPlate.healthBar.text:SetText(E:GetFormattedText(NP.db.healthBar.text.format, floor(blizzPlate.maxHP * value), blizzPlate.maxHP))
		else
			myPlate.healthBar.text:SetText(E:GetFormattedText("PERCENT", value, maxValue))
		end
	elseif myPlate.healthBar.text:IsShown() then
		myPlate.healthBar.text:Hide()
	end

	if(NP.db.colorNameByValue) then
		myPlate.name:SetTextColor(E:ColorGradient(percentValue, 1,0,0, 1,1,0, 1,1,1))
	end
end

local green =  {r = 0, g = 1, b = 0}
function NP:CastBar_OnValueChanged(value)
	local blizzPlate = self:GetParent():GetParent()
	local myPlate = NP.CreatedPlates[blizzPlate]
	local min, max = self:GetMinMaxValues()
	local isChannel = value < myPlate.castBar:GetValue()
	myPlate.castBar:SetMinMaxValues(min, max)
	myPlate.castBar:SetValue(value)
	myPlate.castBar.time:SetFormattedText("%.1f ", value)

	local color
	if(self.shield:IsShown()) then
		color = NP.db.castBar.noInterrupt
	else
		--Color the castbar green slightly before it ends cast.
		if value > 0 and (isChannel and (value/max) <= 0.02 or (value/max) >= 0.98) then
			color = green
		else
			color = NP.db.castBar.color
		end
	end

	myPlate.castBar.name:SetText(blizzPlate.castBar.name:GetText())
	myPlate.castBar.icon:SetTexture(blizzPlate.castBar.icon:GetTexture())

	myPlate.castBar:SetStatusBarColor(color.r, color.g, color.b)
end

function NP:CastBar_OnShow()
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.castBar:Show()
end

function NP:CastBar_OnHide()
	local myPlate = NP.CreatedPlates[self:GetParent():GetParent()]
	myPlate.castBar:Hide()
end

function NP:UpdateSettings()
	local myPlate = NP.CreatedPlates[self]
	local font = LSM:Fetch("font", NP.db.font)
	local fontSize, fontOutline = NP.db.fontSize, NP.db.fontOutline
	local wrapName = NP.db.wrapName

	--Name
	myPlate.name:FontTemplate(font, fontSize, fontOutline)
	myPlate.name:SetTextColor(1, 1, 1)
	myPlate.name:SetHeight(2.5*fontSize)
	myPlate.name:SetWordWrap(wrapName)

	--Level
	myPlate.level:FontTemplate(font, fontSize, fontOutline)

	--HealthBar
	if not self.customScale and not self.isSmall then
		local width, height = NP.db.healthBar.width, NP.db.healthBar.height
		if NP.db.healthBar.lowHPScale.enable and myPlate.lowHealth:IsShown() then
			width = NP.db.healthBar.lowHPScale.width
			height = NP.db.healthBar.lowHPScale.height
		end
		myPlate.healthBar:SetSize(width, height)
	end

	myPlate.healthBar:SetStatusBarTexture(E.media.normTex)

	myPlate.healthBar.text:FontTemplate(font, fontSize, fontOutline)

	--CastBar
	myPlate.castBar:SetSize(NP.db.healthBar.width, NP.db.castBar.height)
	myPlate.castBar:SetStatusBarTexture(E.media.normTex)
	myPlate.castBar.time:FontTemplate(font, fontSize, fontOutline)
	myPlate.castBar.name:FontTemplate(font, fontSize, fontOutline)
	myPlate.castBar.icon:Size(NP.db.castBar.height + NP.db.healthBar.height + 5)

	--Raid Icon
	myPlate.raidIcon:ClearAllPoints()
	myPlate.raidIcon:SetPoint(E.InversePoints[NP.db.raidHealIcon.attachTo], myPlate.healthBar, NP.db.raidHealIcon.attachTo, NP.db.raidHealIcon.xOffset, NP.db.raidHealIcon.yOffset)
	myPlate.raidIcon:SetSize(NP.db.raidHealIcon.size, NP.db.raidHealIcon.size)

	--Healer Icon
	myPlate.healerIcon:ClearAllPoints()
	myPlate.healerIcon:SetPoint(E.InversePoints[NP.db.raidHealIcon.attachTo], myPlate.healthBar, NP.db.raidHealIcon.attachTo, NP.db.raidHealIcon.xOffset, NP.db.raidHealIcon.yOffset)
	myPlate.healerIcon:SetSize(NP.db.raidHealIcon.size, NP.db.raidHealIcon.size)

	--Buffs
	local auraFont = LSM:Fetch("font", NP.db.buffs.font)
	for index = 1, #myPlate.BuffWidget.icons do
		if myPlate.BuffWidget.icons and myPlate.BuffWidget.icons[index] then
			myPlate.BuffWidget.icons[index].TimeLeft:FontTemplate(auraFont, NP.db.buffs.fontSize, NP.db.buffs.fontOutline)
			myPlate.BuffWidget.icons[index].Stacks:FontTemplate(auraFont, NP.db.buffs.fontSize, NP.db.buffs.fontOutline)

			if NP.db.buffs.stretchTexture then
				myPlate.BuffWidget.icons[index].Icon:SetTexCoord(.07, 0.93, .23, 0.77)
			else
				myPlate.BuffWidget.icons[index].Icon:SetTexCoord(.07, .93, .07, .93)
			end
		end
	end

	local yOffset = NP.db.debuffs.stretchTexture and -8 or -2
	myPlate.BuffWidget:SetPoint('BOTTOMRIGHT', myPlate.DebuffWidget, 'TOPRIGHT', 0, yOffset)
	myPlate.BuffWidget:SetPoint('BOTTOMLEFT', myPlate.DebuffWidget, 'TOPLEFT', 0, yOffset)

	--Debuffs
	auraFont = LSM:Fetch("font", NP.db.debuffs.font)
	for index = 1, #myPlate.DebuffWidget.icons do
		if myPlate.DebuffWidget.icons and myPlate.DebuffWidget.icons[index] then
			myPlate.DebuffWidget.icons[index].TimeLeft:FontTemplate(auraFont, NP.db.debuffs.fontSize, NP.db.debuffs.fontOutline)
			myPlate.DebuffWidget.icons[index].Stacks:FontTemplate(auraFont, NP.db.debuffs.fontSize, NP.db.debuffs.fontOutline)

			if NP.db.debuffs.stretchTexture then
				myPlate.DebuffWidget.icons[index].Icon:SetTexCoord(.07, 0.93, .23, 0.77)
			else
				myPlate.DebuffWidget.icons[index].Icon:SetTexCoord(.07, .93, .07, .93)
			end
		end
	end

	local stringHeight = myPlate.name:GetStringHeight()
	local yOffset = stringHeight > 0 and stringHeight or myPlate.name.stringHeight
	myPlate.DebuffWidget:SetPoint('BOTTOMRIGHT', myPlate.healthBar, 'TOPRIGHT', 0, yOffset)
	myPlate.DebuffWidget:SetPoint('BOTTOMLEFT', myPlate.healthBar, 'TOPLEFT', 0, yOffset)

	--ComboPoints
	if(NP.db.comboPoints and not myPlate.cPoints:IsShown()) then
		myPlate.cPoints:Show()
	elseif(myPlate.cPoints:IsShown()) then
		myPlate.cPoints:Hide()
	end

	NP.OnShow(self)
	NP.HealthBar_OnSizeChanged(myPlate.healthBar, myPlate.healthBar:GetSize())
end

function NP:CreatePlate(frame)
	frame.healthBar = frame.ArtContainer.HealthBar

	-- frame.healthBar.texture = frame.healthBar:GetRegions() --No parentKey, yet?

	-- frame.absorbBar = frame.ArtContainer.AbsorbBar
	frame.border = frame.ArtContainer.Border
	frame.highlight = frame.ArtContainer.Highlight
	frame.level = frame.ArtContainer.LevelText
	frame.raidIcon = frame.ArtContainer.RaidTargetIcon
	frame.eliteIcon = frame.ArtContainer.EliteIcon
	frame.threat = frame.ArtContainer.AggroWarningTexture
	frame.bossIcon = frame.ArtContainer.HighLevelIcon
	frame.name = frame.NameContainer.NameText

	frame.castBar = frame.ArtContainer.CastBar
	-- frame.castBar.texture = frame.castBar:GetRegions() --No parentKey, yet?
	frame.castBar.border = frame.ArtContainer.CastBarBorder
	frame.castBar.icon = frame.ArtContainer.CastBarSpellIcon
	frame.castBar.shield = frame.ArtContainer.CastBarFrameShield
	frame.castBar.name = frame.ArtContainer.CastBarText
	frame.castBar.shadow = frame.ArtContainer.CastBarTextBG

	local myPlate = CreateFrame("Frame", nil, self.PlateParent)
	if(self.viewPort) then
		myPlate:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
	end

	--Hidden Frame (used to hide castbar icon)
	myPlate.hiddenFrame = CreateFrame("Frame", nil, myPlate)
	myPlate.hiddenFrame:Hide()

	--HealthBar
	myPlate.healthBar = CreateFrame("StatusBar", nil, myPlate)
	E:RegisterStatusBar(myPlate.healthBar)
	myPlate.healthBar:SetPoint('BOTTOM', myPlate, 'BOTTOM', 0, 5)
	myPlate.healthBar:SetFrameStrata("BACKGROUND")
	myPlate.healthBar:SetFrameLevel(0)
	myPlate.healthBar:SetScript("OnSizeChanged", NP.HealthBar_OnSizeChanged)
	NP:CreateBackdrop(myPlate.healthBar)

	myPlate.healthBar.text = myPlate.healthBar:CreateFontString(nil, 'OVERLAY')
	myPlate.healthBar.text:SetPoint("CENTER", myPlate.healthBar, NP.db.healthBar.text.attachTo, "CENTER")
	myPlate.healthBar.text:SetJustifyH("CENTER")

	--CastBar
	myPlate.castBar = CreateFrame("StatusBar", nil, myPlate)
	E:RegisterStatusBar(myPlate.castBar)
	myPlate.castBar:SetPoint('TOPLEFT', myPlate.healthBar, 'BOTTOMLEFT', 0, -5)
	myPlate.castBar:SetPoint('TOPRIGHT', myPlate.healthBar, 'BOTTOMRIGHT', 0, -5)
	myPlate.castBar:SetFrameStrata("BACKGROUND")
	myPlate.castBar:SetFrameLevel(0)
	NP:CreateBackdrop(myPlate.castBar)

	myPlate.castBar.time = myPlate.castBar:CreateFontString(nil, 'OVERLAY')
	myPlate.castBar.time:SetPoint("TOPRIGHT", myPlate.castBar, "BOTTOMRIGHT", 6, -2)
	myPlate.castBar.time:SetJustifyH("RIGHT")

	myPlate.castBar.name = myPlate.castBar:CreateFontString(nil, 'OVERLAY')
	myPlate.castBar.name:SetPoint("TOPLEFT", myPlate.castBar, "BOTTOMLEFT", 0, -2)
	myPlate.castBar.name:SetPoint("TOPRIGHT", myPlate.castBar.time, "TOPLEFT", 0, -2)
	myPlate.castBar.name:SetJustifyH("LEFT")

	frame.castBar.icon:SetParent(myPlate.hiddenFrame)
	myPlate.castBar.icon = myPlate.castBar:CreateTexture(nil, 'OVERLAY')
	myPlate.castBar.icon:SetTexCoord(.07, .93, .07, .93)
	myPlate.castBar.icon:SetDrawLayer("OVERLAY")
	myPlate.castBar.icon:SetPoint("TOPLEFT", myPlate.healthBar, "TOPRIGHT", 5, 0)
	NP:CreateBackdrop(myPlate.castBar, myPlate.castBar.icon)

	--Level
	myPlate.level = myPlate:CreateFontString(nil, 'OVERLAY')
	myPlate.level:SetPoint("BOTTOMRIGHT", myPlate.healthBar, "TOPRIGHT", 3, 3)
	myPlate.level:SetJustifyH("RIGHT")

	--Name
	myPlate.name = myPlate:CreateFontString(nil, 'OVERLAY')
	myPlate.name:SetJustifyH("LEFT")
	myPlate.name:SetJustifyV("BOTTOM")
	myPlate.name.stringHeight = frame.name:GetStringHeight()

	--Raid Icon
	frame.raidIcon:SetAlpha(0)
	-- DO NOT REUSE BLIZZARD's, make our own!
	myPlate.raidIcon = myPlate:CreateTexture(nil, 'ARTWORK')
	myPlate.raidIcon:SetSize(frame.raidIcon:GetSize())
	myPlate.raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	myPlate.raidIcon:Hide()

	--Healer Icon
	myPlate.healerIcon = myPlate:CreateTexture(nil, 'ARTWORK')
	myPlate.healerIcon:SetSize(frame.raidIcon:GetSize())
	myPlate.healerIcon:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
	myPlate.healerIcon:Hide()

	--Overlay
	myPlate.overlay = myPlate:CreateTexture(nil, 'OVERLAY')
	myPlate.overlay:SetAllPoints(myPlate.healthBar)
	myPlate.overlay:SetTexture(1, 1, 1, 0.3)
	myPlate.overlay:Hide()

	local debuffHeader = CreateFrame("Frame", nil, myPlate)
	local yOffset = myPlate.name.stringHeight or 10
	debuffHeader:SetHeight(32);
	debuffHeader:Show()
	debuffHeader:SetPoint('BOTTOMRIGHT', myPlate.healthBar, 'TOPRIGHT', 0, yOffset)
	debuffHeader:SetPoint('BOTTOMLEFT', myPlate.healthBar, 'TOPLEFT', 0, yOffset)
	debuffHeader:SetFrameStrata("BACKGROUND")
	debuffHeader:SetFrameLevel(0)
	debuffHeader.PollFunction = NP.UpdateAuraTime
	debuffHeader.icons = {}
	myPlate.DebuffWidget = debuffHeader

	--Buffs
	local buffHeader = CreateFrame("Frame", nil, myPlate)
	buffHeader:SetHeight(32); buffHeader:Show()
	buffHeader:SetFrameStrata("BACKGROUND")
	buffHeader:SetFrameLevel(0)
	buffHeader.PollFunction = NP.UpdateAuraTime
	buffHeader.icons = {}
	myPlate.BuffWidget = buffHeader

	--Low-Health Indicator
	myPlate.lowHealth = CreateFrame("Frame", nil, myPlate)
	myPlate.lowHealth:SetFrameLevel(0)
	myPlate.lowHealth:SetOutside(myPlate.healthBar, 3, 3)
	myPlate.lowHealth:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = 3,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	myPlate.lowHealth:SetBackdropColor(0, 0, 0, 0)
	myPlate.lowHealth:SetBackdropBorderColor(1, 1, 0, 0.9)
	myPlate.lowHealth:SetScale(E.PixelMode and 1.5 or 2)
	myPlate.lowHealth:Hide()

	--Combo Points
	myPlate.cPoints = CreateFrame("Frame", nil, myPlate.healthBar)
	myPlate.cPoints:Point("CENTER", myPlate.healthBar, "BOTTOM")
	myPlate.cPoints:SetSize(68, 1)
	myPlate.cPoints:Hide()

	for i = 1, MAX_COMBO_POINTS do
		myPlate.cPoints[i] = myPlate.cPoints:CreateTexture(nil, 'OVERLAY')
		myPlate.cPoints[i]:SetTexture([[Interface\AddOns\ElvUI\media\textures\bubbleTex.tga]])
		myPlate.cPoints[i]:SetSize(12, 12)
		myPlate.cPoints[i]:SetVertexColor(unpack(NP.ComboColors[i]))

		if(i == 1) then
			myPlate.cPoints[i]:SetPoint("LEFT", myPlate.cPoints, "TOPLEFT")
		else
			myPlate.cPoints[i]:SetPoint("LEFT", myPlate.cPoints[i-1], "RIGHT", 2, 0)
		end

		myPlate.cPoints[i]:Hide()
	end

	--Script Handlers
	frame:HookScript("OnShow", NP.OnShow)
	frame:HookScript("OnHide", NP.OnHide)
	frame:HookScript("OnSizeChanged", NP.OnSizeChanged)
	frame.healthBar:HookScript("OnValueChanged", NP.HealthBar_OnValueChanged)
	frame.castBar:HookScript("OnShow", NP.CastBar_OnShow)
	frame.castBar:HookScript("OnHide", NP.CastBar_OnHide)
	frame.castBar:HookScript("OnValueChanged", NP.CastBar_OnValueChanged)

	--Hide Elements
	NP:QueueObject(frame, frame.healthBar)
	NP:QueueObject(frame, frame.castBar)
	NP:QueueObject(frame, frame.level)
	NP:QueueObject(frame, frame.name)
	NP:QueueObject(frame, frame.threat)
	NP:QueueObject(frame, frame.border)
	NP:QueueObject(frame, frame.castBar.shield)
	NP:QueueObject(frame, frame.castBar.border)
	NP:QueueObject(frame, frame.castBar.shadow)
	NP:QueueObject(frame, frame.bossIcon)
	NP:QueueObject(frame, frame.eliteIcon)
	NP:QueueObject(frame, frame.castBar.name)
	NP:QueueObject(frame, frame.castBar.icon)

	self.CreatedPlates[frame] = myPlate
	NP.UpdateSettings(frame)
	if not frame.castBar:IsShown() then
		myPlate.castBar:Hide()
	else
		NP.CastBar_OnShow(frame.castBar)
	end
end

function NP:QueueObject(frame, object)
	frame.queue = frame.queue or {}
	frame.queue[object] = true

	if object.OldTexture then
		object:SetTexture(object.OldTexture)
	end
end

function NP:ScanFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local name = frame:GetName()

		if(not NP.CreatedPlates[frame] and (name and name:find("^NamePlate%d"))) then
			NP:CreatePlate(frame)
		end
	end
end

function NP:CreateBackdrop(parent, point)
	point = point or parent
	local noscalemult = E.mult * UIParent:GetScale()

	if point.bordertop then return end

	point.backdrop = parent:CreateTexture(nil, "BORDER")
	point.backdrop:SetDrawLayer("BORDER", -4)
	point.backdrop:SetAllPoints(point)
	point.backdrop:SetTexture(unpack(E["media"].backdropfadecolor))

	if E.PixelMode then
		point.bordertop = parent:CreateTexture(nil, "BORDER")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))
		point.bordertop:SetDrawLayer("BORDER", 1)

		point.borderbottom = parent:CreateTexture(nil, "BORDER")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))
		point.borderbottom:SetDrawLayer("BORDER", 1)

		point.borderleft = parent:CreateTexture(nil, "BORDER")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))
		point.borderleft:SetDrawLayer("BORDER", 1)

		point.borderright = parent:CreateTexture(nil, "BORDER")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))
		point.borderright:SetDrawLayer("BORDER", 1)
	else
		point.bordertop = parent:CreateTexture(nil, "ARTWORK")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E.media.bordercolor))
		point.bordertop:SetDrawLayer("ARTWORK", -6)

		point.bordertop.backdrop = parent:CreateTexture(nil, "ARTWORK")
		point.bordertop.backdrop:SetPoint("TOPLEFT", point.bordertop, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop.backdrop:SetPoint("TOPRIGHT", point.bordertop, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop.backdrop:SetHeight(noscalemult * 3)
		point.bordertop.backdrop:SetTexture(0, 0, 0)
		point.bordertop.backdrop:SetDrawLayer("ARTWORK", -7)

		point.borderbottom = parent:CreateTexture(nil, "ARTWORK")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E.media.bordercolor))
		point.borderbottom:SetDrawLayer("ARTWORK", -6)

		point.borderbottom.backdrop = parent:CreateTexture(nil, "ARTWORK")
		point.borderbottom.backdrop:SetPoint("BOTTOMLEFT", point.borderbottom, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", point.borderbottom, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom.backdrop:SetHeight(noscalemult * 3)
		point.borderbottom.backdrop:SetTexture(0, 0, 0)
		point.borderbottom.backdrop:SetDrawLayer("ARTWORK", -7)

		point.borderleft = parent:CreateTexture(nil, "ARTWORK")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E.media.bordercolor))
		point.borderleft:SetDrawLayer("ARTWORK", -6)

		point.borderleft.backdrop = parent:CreateTexture(nil, "ARTWORK")
		point.borderleft.backdrop:SetPoint("TOPLEFT", point.borderleft, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft.backdrop:SetPoint("BOTTOMLEFT", point.borderleft, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderleft.backdrop:SetWidth(noscalemult * 3)
		point.borderleft.backdrop:SetTexture(0, 0, 0)
		point.borderleft.backdrop:SetDrawLayer("ARTWORK", -7)

		point.borderright = parent:CreateTexture(nil, "ARTWORK")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E.media.bordercolor))
		point.borderright:SetDrawLayer("ARTWORK", -6)

		point.borderright.backdrop = parent:CreateTexture(nil, "ARTWORK")
		point.borderright.backdrop:SetPoint("TOPRIGHT", point.borderright, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright.backdrop:SetPoint("BOTTOMRIGHT", point.borderright, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderright.backdrop:SetWidth(noscalemult * 3)
		point.borderright.backdrop:SetTexture(0, 0, 0)
		point.borderright.backdrop:SetDrawLayer("ARTWORK", -7)
	end
end

---------------------------------------------
--Combo Points
---------------------------------------------

function NP:UpdateComboPoints(frame)
	local myPlate = NP.CreatedPlates[frame]
	local numPoints = NP.ComboPoints[frame.guid]
	if(not numPoints) then
		for i=1, MAX_COMBO_POINTS do
			myPlate.cPoints[i]:Hide()
		end
		return
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= numPoints) then
			myPlate.cPoints[i]:Show()
		else
			myPlate.cPoints[i]:Hide()
		end
	end
end

function NP:UpdateComboPointsByUnitID(unitID)
	local guid = UnitGUID(unitID)
	if (not guid) then return end
	NP.ComboPoints[guid] = GetComboPoints(UnitHasVehicleUI('player') and 'vehicle' or 'player', unitID)

	local frame = NP:SearchForFrame(guid)
	if(frame) then
		NP:UpdateComboPoints(frame)
	end
end

function NP:UNIT_COMBO_POINTS(event, unit)
	if(unit == "player" or unit == "vehicle") then
		self:UpdateComboPointsByUnitID("target")
	end
end

---------------------------------------------
--Auras
---------------------------------------------
do
	local PolledHideIn
	local Framelist = {}
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0

	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + AURA_UPDATE_INTERVAL

		for frame, expiration in pairs(Framelist) do
			if expiration < curTime then
				frame:Hide();
				Framelist[frame] = nil
			else
				if frame.Poll then
					frame.Poll(NP, frame, expiration)
				end
				framecount = framecount + 1
			end
		end

		if framecount == 0 then
			Watcherframe:SetScript("OnUpdate", nil);
			WatcherframeActive = false
		end
	end

	function PolledHideIn(frame, expiration)
		if(not frame) then return end
		if expiration == 0 then
			frame:Hide()
			Framelist[frame] = nil
		else
			Framelist[frame] = expiration
			frame:Show()

			if not WatcherframeActive then
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end

	NP.PolledHideIn = PolledHideIn
end

function NP:GetSpellDuration(spellID)
	if spellID then return NP.CachedAuraDurations[spellID] end
end

function NP:SetSpellDuration(spellID, duration)
	if spellID then NP.CachedAuraDurations[spellID] = duration end
end

function NP:CreateAuraIcon(frame, parent, dbTable)
	local noscalemult = E.mult * UIParent:GetScale()
	local button = CreateFrame("Frame",nil,frame)
	button:SetScript('OnHide', function()
		if frame.guid then
			NP:UpdateIconGrid(parent, frame.guid)
		end
	end)
	local db = NP.db[dbTable]
	if E.PixelMode then
		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)

		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)

		if db.stretchTexture then
			button.Icon:SetTexCoord(.07, 0.93, .23, 0.77)
		else
			button.Icon:SetTexCoord(.07, .93, .07, .93)
		end
	else
		button.bg = button:CreateTexture(nil, "BACKGROUND")
		button.bg:SetTexture(0, 0, 0, 1)
		button.bg:SetAllPoints(button)

		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)

		button.bg2 = button:CreateTexture(nil, "BACKGROUND")
		button.bg2:SetDrawLayer('BACKGROUND', 3)
		button.bg2:SetTexture(0, 0, 0, 1)
		button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)

		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
		if db.stretchTexture then
			button.Icon:SetTexCoord(.07, 0.93, .23, 0.77)
		else
			button.Icon:SetTexCoord(.07, .93, .07, .93)
		end
	end

	local font = LSM:Fetch("font", db.font)
	button.TimeLeft = button:CreateFontString(nil, 'OVERLAY')
	button.TimeLeft:SetFont(font, db.fontSize, db.fontOutline)
	button.TimeLeft:Point('TOPLEFT', 2, 2)
	button.TimeLeft:SetJustifyH('CENTER')

	button.Stacks = button:CreateFontString(nil,"OVERLAY")
	button.Stacks:SetFont(font, db.fontSize, db.fontOutline)
	button.Stacks:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

	button.Poll = frame.PollFunction
	button:Hide()

	return button
end

function NP:UpdateAuraTime(frame, expiration)
	local timeleft = expiration-GetTime()
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4)
	local format = E.TimeFormats[3][2]
	if timervalue < 4 then
		format = E.TimeFormats[4][2]
	end
	frame.TimeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], format), timervalue)
end

function NP:ClearAuraContext(frame)
	AuraList[frame] = nil
end

function NP:RemoveAuraInstance(guid, spellID, caster)
	if guid and spellID and NP.AuraList[guid] then
		local instanceID = tostring(guid)..tostring(spellID)..(tostring(caster or "UNKNOWN_CASTER"))
		local auraID = spellID..(tostring(caster or "UNKNOWN_CASTER"))
		if NP.AuraList[guid][auraID] then
			NP.AuraSpellID[instanceID] = nil
			NP.AuraExpiration[instanceID] = nil
			NP.AuraStacks[instanceID] = nil
			NP.AuraCaster[instanceID] = nil
			NP.AuraDuration[instanceID] = nil
			NP.AuraTexture[instanceID] = nil
			NP.AuraType[instanceID] = nil
			NP.AuraTarget[instanceID] = nil
			NP.AuraList[guid][auraID] = nil
		end
	end
end

function NP:GetAuraList(guid)
	if guid and self.AuraList[guid] then return self.AuraList[guid] end
end

function NP:GetAuraInstance(guid, auraID)
	if guid and auraID then
		local instanceID = guid..auraID
		return self.AuraSpellID[instanceID], self.AuraExpiration[instanceID], self.AuraStacks[instanceID], self.AuraCaster[instanceID], self.AuraDuration[instanceID], self.AuraTexture[instanceID], self.AuraType[instanceID], self.AuraTarget[instanceID]
	end
end

function NP:SetAuraInstance(guid, spellID, expiration, stacks, caster, duration, texture, auraType, auraTarget)
	local filter = false
	local db = self.db.buffs
	if(auraType == AURA_TYPE_DEBUFF) then
		db = self.db.debuffs
	end

	if (db.showPersonal and caster == UnitGUID('player')) then
		filter = true;
	end

	local trackFilter = E.global['unitframe']['aurafilters'][db.additionalFilter]
	if db.additionalFilter and trackFilter then
		local name = GetSpellInfo(spellID)
		local spellList = trackFilter.spells
		local type = trackFilter.type
		if type == 'Blacklist' then
			if spellList[name] and spellList[name].enable then
				filter = false;
			end
		else
			if spellList[name] and spellList[name].enable then
				filter = true;
			end
			if trackFilter == 'Whitelist (Strict)' and spellList[name].spellID and not spellList[name].spellID == spellID then
				filter = false;
			end
		end
	end

	if E.global.unitframe.InvalidSpells[spellID] then
		filter = false;
	end

	if filter ~= true then
		return;
	end

	if guid and spellID and caster and texture then
		local auraID = spellID..(tostring(caster or "UNKNOWN_CASTER"))
		local instanceID = guid..auraID
		NP.AuraList[guid] = NP.AuraList[guid] or {}
		NP.AuraList[guid][auraID] = instanceID
		NP.AuraSpellID[instanceID] = spellID
		NP.AuraExpiration[instanceID] = expiration
		NP.AuraStacks[instanceID] = stacks
		NP.AuraCaster[instanceID] = caster
		NP.AuraDuration[instanceID] = duration
		NP.AuraTexture[instanceID] = texture
		NP.AuraType[instanceID] = auraType
		NP.AuraTarget[instanceID] = auraTarget
	end
end

function NP:UNIT_AURA(event, unit)
	if unit == "target" then
		self:UpdateAurasByUnitID("target")
	elseif unit == "focus" then
		self:UpdateAurasByUnitID("focus")
	end
end

function NP:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, ...)
	local _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, _, auraType, stackCount  = ...

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then
		if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
			local duration = NP:GetSpellDuration(spellID)
			local texture = GetSpellTexture(spellID)
			NP:SetAuraInstance(destGUID, spellID, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, auraType, AURA_TARGET_HOSTILE)
		elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
			local duration = NP:GetSpellDuration(spellID)
			local texture = GetSpellTexture(spellID)
			NP:SetAuraInstance(destGUID, spellID, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, auraType, AURA_TARGET_HOSTILE)
		elseif event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then
			NP:RemoveAuraInstance(destGUID, spellID, sourceGUID)
		end

		local name, raidIcon
		if band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and destName then
			local rawName = strsplit("-", destName)			-- Strip server name from players
			NP.ByName[rawName] = destGUID
			name = rawName
		end

		for iconName, bitmask in pairs(NP.RaidTargetReference) do
			if band(destRaidFlags, bitmask) > 0  then
				NP.ByRaidIcon[iconName] = destGUID
				raidIcon = iconName
				break
			end
		end

		local frame = self:SearchForFrame(destGUID, raidIcon, name)
		if(frame and not frame.isSmall) then
			NP:UpdateAuras(frame)
		end
	end
end

function NP:WipeAuraList(guid)
	if guid and self.AuraList[guid] then
		local unitAuraList = self.AuraList[guid]
		for auraID, instanceID in pairs(unitAuraList) do
			self.AuraSpellID[instanceID] = nil
			self.AuraExpiration[instanceID] = nil
			self.AuraStacks[instanceID] = nil
			self.AuraCaster[instanceID] = nil
			self.AuraDuration[instanceID] = nil
			self.AuraTexture[instanceID] = nil
			self.AuraType[instanceID] = nil
			self.AuraTarget[instanceID] = nil
			unitAuraList[auraID] = nil
		end
	end
end

function NP:UpdateAurasByUnitID(unit)
	local guid = UnitGUID(unit)
	self:WipeAuraList(guid)


	local index = 1
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID, _, isBossDebuff = UnitDebuff(unit, index)
	while name do
		NP:SetSpellDuration(spellID, duration)
		NP:SetAuraInstance(guid, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_DEBUFF)
		index = index + 1
		name , _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID, _, isBossDebuff = UnitDebuff(unit, index)
	end

	index = 1
	local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitBuff(unit, index);
	while name do
		NP:SetSpellDuration(spellID, duration)
		NP:SetAuraInstance(guid, spellID, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE_BUFF)
		index = index + 1
		name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitBuff(unit, index);
	end

	local raidIcon, name
	if UnitPlayerControlled(unit) then name = UnitName(unit) end
	raidIcon = RaidIconIndex[GetRaidTargetIndex(unit) or ""]
	if raidIcon then self.ByRaidIcon[raidIcon] = guid end

	local frame = self:SearchForFrame(guid, raidIcon, name)
	if frame and not frame.isSmall then
		NP:UpdateAuras(frame)
	end
end

function NP:UpdateIcon(frame, texture, expiration, stacks)
	if frame and texture and expiration then
		-- Icon
		frame.Icon:SetTexture(texture)

		-- Stacks
		if stacks > 1 then
			frame.Stacks:SetText(stacks)
		else
			frame.Stacks:SetText("")
		end

		-- Expiration
		frame:Show()
		NP.PolledHideIn(frame, expiration)
	else
		NP.PolledHideIn(frame, 0)
	end
end

local function sortByExpiration(a, b)
	return a.expiration < b.expiration
end

function NP:UpdateIconGrid(frame, guid)
	local myPlate = NP.CreatedPlates[frame]
	local buffs = myPlate.BuffWidget
	local debuffs = myPlate.DebuffWidget
	local AurasOnUnit = self:GetAuraList(guid)
	local BuffSlotIndex = 1
	local DebuffSlotIndex = 1
	local instanceid

	-- Cache displayable auras
	if AurasOnUnit then
		buffs:Show()
		debuffs:Show()
		for instanceid in pairs(AurasOnUnit) do
			local aura = {} --THIS IS BAD, FIX IT
			aura.spellID, aura.expiration, aura.stacks, aura.caster, aura.duration, aura.texture, aura.type, aura.target = self:GetAuraInstance(guid, instanceid)
			if tonumber(aura.spellID) then
				aura.name = GetSpellInfo(tonumber(aura.spellID))
				aura.unit = frame.unit
				-- Get Order/Priority
				if aura.expiration > GetTime() then
					if(aura.type == "BUFF") then
						tinsert(self.BuffCache, aura)
					else
						tinsert(self.DebuffCache, aura)
					end
				end
			end
		end
	end

	tsort(self.BuffCache, sortByExpiration)
	tsort(self.DebuffCache, sortByExpiration)

	for index = 1,  #self.BuffCache do
		local cachedaura = self.BuffCache[index]
		if cachedaura.spellID and cachedaura.expiration then
			self:UpdateIcon(buffs.icons[BuffSlotIndex], cachedaura.texture, cachedaura.expiration, cachedaura.stacks)
			BuffSlotIndex = BuffSlotIndex + 1
		end

		if(BuffSlotIndex > NP.db.buffs.numAuras) then
			break
		end
	end

	for index = 1,  #self.DebuffCache do
		local cachedaura = self.DebuffCache[index]
		if cachedaura.spellID and cachedaura.expiration then
			self:UpdateIcon(debuffs.icons[DebuffSlotIndex], cachedaura.texture, cachedaura.expiration, cachedaura.stacks)
			DebuffSlotIndex = DebuffSlotIndex + 1
		end

		if(DebuffSlotIndex > NP.db.debuffs.numAuras) then
			break
		end
	end

	-- Clear Extra Slots
	if buffs.icons[BuffSlotIndex] then
		NP.PolledHideIn(buffs.icons[BuffSlotIndex], 0)
	end

	if debuffs.icons[DebuffSlotIndex] then
		NP.PolledHideIn(debuffs.icons[DebuffSlotIndex], 0)
	end

	self.BuffCache = wipe(self.BuffCache)
	self.DebuffCache = wipe(self.DebuffCache)
end

function NP:UpdateAuras(frame)
	-- Check for ID
	local guid = frame.guid
	local myPlate = NP.CreatedPlates[frame]

	if not guid then
		-- Attempt to ID widget via Name or Raid Icon
		if RAID_CLASS_COLORS[frame.unitType] then
			local name = gsub(frame.name:GetText(), FSPAT,'')
			guid = NP.ByName[name]
		elseif frame.raidIcon:IsShown() then
			guid = NP.ByRaidIcon[frame.raidIconType]
		end

		if guid then
			frame.guid = guid
		else
			myPlate.DebuffWidget:Hide()
			myPlate.BuffWidget:Hide()
			return
		end
	end

	self:UpdateIconGrid(frame, guid)
end

function NP:UpdateAuraByLookup(guid)
	if guid == UnitGUID("target") then
		NP:UpdateAurasByUnitID("target")
	elseif guid == UnitGUID("mouseover") then
		NP:UpdateAurasByUnitID("mouseover")
	end
end

function NP:CheckRaidIcon(frame)
	if frame.raidIcon:IsShown() then
		local ux, uy = frame.raidIcon:GetTexCoord()
		frame.raidIconType = NP.RaidIconCoordinate[ux][uy]
	else
		frame.raidIconType = nil;
	end
end

function NP:SearchNameplateByGUID(guid)
	for frame, _ in pairs(NP.CreatedPlates) do
		if frame and frame:IsShown() and frame.guid == guid then
			return frame
		end
	end
end

function NP:SearchNameplateByName(sourceName)
	if not sourceName then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame, myPlate in pairs(NP.CreatedPlates) do
		if frame and frame:IsShown() and myPlate.nameText == SearchFor and RAID_CLASS_COLORS[frame.unitType] then
			return frame
		end
	end
end

function NP:SearchNameplateByIconName(raidIcon)
	for frame, _ in pairs(NP.CreatedPlates) do
		NP:CheckRaidIcon(frame)
		if frame and frame:IsShown() and frame.raidIcon:IsShown() and (frame.raidIconType == raidIcon) then
			return frame
		end
	end
end

function NP:SearchForFrame(guid, raidIcon, name)
	local frame

	if guid then frame = self:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = self:SearchNameplateByName(name) end
	if (not frame) and raidIcon then frame = self:SearchNameplateByIconName(raidIcon) end

	return frame
end


E:RegisterModule(NP:GetName())