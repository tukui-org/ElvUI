local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = ElvUI.oUF

local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')

--Cache global variables
--Lua functions
local pairs = pairs
local type = type
local gsub = gsub
local wipe = table.wipe
local format = string.format
local strmatch = string.match
local strjoin = strjoin
local tonumber = tonumber
local unpack = unpack

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local SetCVar, GetCVarDefault = SetCVar, GetCVarDefault
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local Lerp = Lerp
local C_NamePlate = C_NamePlate

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: NamePlateDriverFrame, UIParent, WorldFrame
-- GLOBALS: CUSTOM_CLASS_COLORS, ADDITIONAL_POWER_BAR_NAME

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

function NP:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function NP:CopySettings(from, to)
	if (from == to) then return end

	CopySettings(self.db.units[from], self.db.units[to])
end

function NP:StyleFrame(frame, useMainFrame)
	local parent = frame

	if (parent:IsObjectType('Texture')) then
		parent = frame:GetParent()
	end

	if useMainFrame then
		parent:SetTemplate("Transparent")
		return
	end

	parent:CreateBackdrop("Transparent")
end

function NP:Style(frame, unit)
	if (not unit) then
		return
	end

	NP:StylePlate(frame, unit)

	return frame
end

function NP:StylePlate(nameplate)
	nameplate:SetPoint('CENTER')
	nameplate:SetSize(self.db.clickableWidth, self.db.clickableHeight)
	nameplate:SetScale(UIParent:GetEffectiveScale())

	nameplate.Health = NP:Construct_HealthBar(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate)
	nameplate.Health.Text:SetPoint('CENTER', nameplate.Health, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Health.Text, '[perhp]%') -- need option

	nameplate.HealthPrediction = NP:Construct_HealthPrediction(nameplate)

	nameplate.Power = NP:Construct_PowerBar(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate)
	nameplate.Power.Text:SetPoint('CENTER', nameplate.Power, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Power.Text, '[perpp]%') -- need option

	nameplate.PowerPrediction = NP:Construct_PowerPrediction(nameplate)

	nameplate.Name = NP:Construct_TagText(nameplate)
	nameplate.Name:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, E.Border*2) -- need option
	nameplate.Name:SetJustifyH('LEFT')
	nameplate.Name:SetJustifyV('BOTTOM')
	nameplate.Name:SetWordWrap(false)
	nameplate:Tag(nameplate.Name, '[namecolor][name:abbrev] [npctitle]')

	nameplate.Level = NP:Construct_TagText(nameplate)
	nameplate.Level:SetPoint('BOTTOMRIGHT', nameplate.Health, 'TOPRIGHT', 0, E.Border*2) -- need option
	nameplate.Level:SetJustifyH('RIGHT')
	nameplate:Tag(nameplate.Level, '[difficultycolor][level]')

	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate)
	nameplate.ClassificationIndicator:SetPoint('TOPLEFT', nameplate, 'TOPLEFT')

	nameplate.Castbar = NP:Construct_Castbar(nameplate)

	nameplate.QuestIcons = NP:Construct_QuestIcons(nameplate)

	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate)

	nameplate.TargetIndicator = NP:Construct_TargetIndicator(nameplate)

	nameplate.ThreatIndicator = NP:Construct_ThreatIndicator(nameplate)

	nameplate.Highlight = NP:Construct_Highlight(nameplate)

	nameplate.Auras = NP:Construct_Auras(nameplate)

	--nameplate.Buffs = NP:Construct_Buffs(nameplate)
	--nameplate.Debuffs = NP:Construct_Debuffs(nameplate)

	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)
	nameplate:DisableElement('ClassPower')

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
		nameplate:DisableElement('Runes')
	end
end

function NP:UnitStyle(nameplate, unit)
	-- ['glowStyle'] = 'TARGET_THREAT',
	local db = NP.db.units[unit]

	if (unit == 'FRIENDLY_NPC') or (unit == 'ENEMY_NPC') then
		nameplate.Health.colorClass = false
		nameplate.Health.colorReaction = true
	else
		nameplate.Health.colorClass = db.healthbar.useClassColor
		nameplate.Health.colorReaction = false
	end

	if db.healthbar.enable then
		nameplate:EnableElement('Health')
		nameplate.Highlight.texture:Show()
	else
		nameplate:DisableElement('Health')
		nameplate.Highlight.texture:Hide()
	end

	if db.healthbar.enable and db.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if db.healthbar.text.enable then
		nameplate.Health.Text:Show()
	else
		nameplate.Health.Text:Hide()
	end

	nameplate.Health.width = db.healthbar.width
	nameplate.Health.height = db.healthbar.height
	nameplate.Health:SetSize(db.healthbar.width, db.healthbar.height)

	if db.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if db.powerbar.enable and db.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if db.powerbar.text.enable then
		nameplate.Power.Text:Show()
	else
		nameplate.Power.Text:Hide()
	end

	nameplate.Power:SetSize(db.healthbar.width, db.powerbar.height)

	if db.showName then
		nameplate.Name:Show()
		nameplate.Name:ClearAllPoints()
		if not db.showLevel then
			nameplate.Name:SetPoint('BOTTOM', nameplate.Health, 'TOP', 0, E.Border*2) -- need option
			nameplate.Name:SetJustifyH('CENTER')
		else
			nameplate.Name:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, E.Border*2) -- need option
			nameplate.Name:SetJustifyH('LEFT')
			nameplate.Name:SetJustifyV('BOTTOM')
		end
	else
		nameplate.Name:Hide()
	end

	if db.showLevel then
		nameplate.Level:Show()
	else
		nameplate.Level:Hide()
	end

	if db.castbar.enable then
		nameplate.Castbar.timeToHold = db.castbar.timeToHold
		if db.castbar.iconPosition then
		end
	end

	nameplate.TargetIndicator.style = NP['db'].targetGlow
	nameplate.TargetIndicator.lowHealthThreshold = NP['db'].lowHealthThreshold

	if NP['db'].targetGlow ~= 'none' then
		local GlowStyle = NP['db'].targetGlow
		local Color = NP['db'].colors.glow
		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == "style3" or GlowStyle == "style5" or GlowStyle == "style6") then
			local topArrowSpace = -3
			if db.showName and (nameplate.Name:GetText() ~= nil and nameplate.Name:GetText() ~= "") then
				topArrowSpace = NP['db'].fontSize + topArrowSpace
			end
			nameplate.TargetIndicator.TopIndicator:Point("BOTTOM", nameplate.HealthBar, "TOP", 0, topArrowSpace)
			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == "style4" or GlowStyle == "style7" or GlowStyle == "style8") then
			nameplate.TargetIndicator.LeftIndicator:Point("LEFT", nameplate.HealthBar, "RIGHT", -3, 0)
			nameplate.TargetIndicator.RightIndicator:Point("RIGHT", nameplate.HealthBar, "LEFT", 3, 0)
			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == "style1" or GlowStyle == "style5" or GlowStyle == "style7") then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == "style2" or GlowStyle == "style6" or GlowStyle == "style8") then
			local scale = 1
			if NP['db'].useTargetScale then
				if NP['db'].targetScale >= 0.75 then
					scale = NP['db'].targetScale
				else
					scale = 0.75
				end
			end

			local size = (E.Border + 14) * scale;

			nameplate.TargetIndicator.Spark:Point("TOPLEFT", nameplate.HealthBar, "TOPLEFT", -(size * 2), size)
			nameplate.TargetIndicator.Spark:Point("BOTTOMRIGHT", nameplate.HealthBar, "BOTTOMRIGHT", size * 2, -size)
			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b)
		end
	end

	if db.eliteIcon and db.eliteIcon.enable then
		nameplate:EnableElement('ClassificationIndicator')
		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:SetSize(db.eliteIcon.size, db.eliteIcon.size)
		if db.healthbar.enable then
			nameplate.ClassificationIndicator:Point(db.eliteIcon.position, nameplate.HealthBar, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
		else
			nameplate.ClassificationIndicator:Point("RIGHT", nameplate.Name, "LEFT", 0, 0)
		end
	else
		nameplate:DisableElement('ClassificationIndicator')
	end

	if unit == 'PLAYER' then
		nameplate:EnableElement('ClassPower')
		if E.myclass == 'DEATHKNIGHT' then
			nameplate:EnableElement('Runes')
		end
	end

	nameplate.Auras:SetPoint("BOTTOMLEFT", nameplate.Health, "TOPLEFT", 0, 15)
	nameplate.Auras:SetPoint("BOTTOMRIGHT", nameplate.Health, "TOPRIGHT", 0, 15)

	--nameplate.Debuffs:SetPoint("BOTTOMLEFT", nameplate.Health, "TOPLEFT", 0, 15)
	--nameplate.Debuffs:SetPoint("BOTTOMRIGHT", nameplate.Health, "TOPRIGHT", 0, 15)

	--nameplate.Buffs:SetPoint("BOTTOMLEFT", nameplate.Debuffs, "TOPLEFT", 0, 1)
	--nameplate.Buffs:SetPoint("BOTTOMRIGHT", nameplate.Debuffs, "TOPRIGHT", 0, 1)

	nameplate:UpdateAllElements('OnShow')
end

function NP:CVarReset()
	SetCVar('nameplateClassResourceTopInset', GetCVarDefault('nameplateClassResourceTopInset'))
	SetCVar('nameplateGlobalScale', GetCVarDefault('nameplateGlobalScale'))
	SetCVar('NamePlateHorizontalScale', GetCVarDefault('NamePlateHorizontalScale'))
	SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'))
	SetCVar('nameplateLargerScale', GetCVarDefault('nameplateLargerScale'))
	SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'))
	SetCVar('nameplateMaxAlpha', GetCVarDefault('nameplateMaxAlpha'))
	SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'))
	SetCVar('nameplateMaxScale', GetCVarDefault('nameplateMaxScale'))
	SetCVar('nameplateMaxScaleDistance', GetCVarDefault('nameplateMaxScaleDistance'))
	SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	SetCVar('nameplateMinScale', GetCVarDefault('nameplateMinScale'))
	SetCVar('nameplateMinScaleDistance', GetCVarDefault('nameplateMinScaleDistance'))
	SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'))
	SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'))
	SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	SetCVar('nameplateSelectedAlpha', GetCVarDefault('nameplateSelectedAlpha'))
	SetCVar('nameplateSelfAlpha', GetCVarDefault('nameplateSelfAlpha'))
	SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'))
	SetCVar('nameplateSelfScale', GetCVarDefault('nameplateSelfScale'))
	SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'))
	SetCVar('nameplateShowEnemies', GetCVarDefault('nameplateShowEnemies'))
	SetCVar('nameplateShowEnemyGuardians', GetCVarDefault('nameplateShowEnemyGuardians'))
	SetCVar('nameplateShowEnemyPets', GetCVarDefault('nameplateShowEnemyPets'))
	SetCVar('nameplateShowEnemyTotems', GetCVarDefault('nameplateShowEnemyTotems'))
	SetCVar('nameplateShowFriendlyGuardians', GetCVarDefault('nameplateShowFriendlyGuardians'))
	SetCVar('nameplateShowFriendlyNPCs', GetCVarDefault('nameplateShowFriendlyNPCs'))
	SetCVar('nameplateShowFriendlyPets', GetCVarDefault('nameplateShowFriendlyPets'))
	SetCVar('nameplateShowFriendlyTotems', GetCVarDefault('nameplateShowFriendlyTotems'))
	SetCVar('nameplateShowFriends', GetCVarDefault('nameplateShowFriends'))
	SetCVar('nameplateTargetBehindMaxDistance', GetCVarDefault('nameplateTargetBehindMaxDistance'))
	SetCVar('nameplateSelectedScale', 1)
end

function NP:PLAYER_REGEN_DISABLED()
	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0);
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end
end

function NP:ConfigureAll()
	SetCVar('nameplateMaxDistance', NP.db.loadDistance)
	SetCVar('nameplateMotion', NP.db.motionType == 'STACKED' and 1 or 0)
	SetCVar('NameplatePersonalHideDelayAlpha', NP.db.units.PLAYER.visibility.hideDelay)
	SetCVar('NameplatePersonalShowAlways', (NP.db.units.PLAYER.visibility.showAlways == true and 1 or 0))
	SetCVar('NameplatePersonalShowInCombat', (NP.db.units.PLAYER.visibility.showInCombat == true and 1 or 0))
	SetCVar('NameplatePersonalShowWithTarget', (NP.db.units.PLAYER.visibility.showWithTarget == true and 1 or 0))
	SetCVar('nameplateShowAll', NP.db.displayStyle ~= 'ALL' and 0 or 1)
	SetCVar('nameplateShowFriendlyMinions', NP.db.units.FRIENDLY_PLAYER.minions == true and 1 or 0)
	SetCVar('nameplateShowEnemyMinions', NP.db.units.ENEMY_PLAYER.minions == true and 1 or 0)
	SetCVar('nameplateShowEnemyMinus', NP.db.units.ENEMY_NPC.minors == true and 1 or 0)
	SetCVar('nameplateShowSelf', (NP.db.units.PLAYER.useStaticPosition == true or NP.db.units.PLAYER.enable ~= true) and 0 or 1)
	SetCVar('showQuestTrackingTooltips', NP.db.questIcon and 1)
	SetCVar('nameplateMinAlpha', NP.db.nonTargetTransparency)
	SetCVar("nameplateOtherTopInset", NP.db.clampToScreen and 0.08 or -1)
	SetCVar("nameplateOtherBottomInset", NP.db.clampToScreen and 0.1 or -1)

	C_NamePlate.SetNamePlateSelfSize(NP.db.clickableWidth, NP.db.clickableHeight)
	C_NamePlate.SetNamePlateEnemySize(NP.db.clickableWidth, NP.db.clickableHeight)

	-- workaround for #206
	local friendlyWidth, friendlyHeight

	if IsInInstance() then
		-- handle it just like blizzard does when using blizzard friendly plates
		local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
		local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
		local zeroBasedScale = namePlateVerticalScale - 1.0

		friendlyWidth = NamePlateDriverFrame.baseNamePlateWidth * horizontalScale
		friendlyHeight = NamePlateDriverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale)
	end

	C_NamePlate.SetNamePlateFriendlySize(friendlyWidth or NP.db.clickableWidth, friendlyHeight or NP.db.clickableHeight)

	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end

	if NP.db.units['PLAYER'].useStaticPosition then
		ElvNP_Player:Enable()
		ElvNP_Player:UpdateAllElements('OnShow')
	else
		ElvNP_Player:Disable()
	end

	NP:NamePlateCallBack(ElvNP_Player, 'NAME_PLATE_UNIT_ADDED')

	for nameplate in pairs(NP.Plates) do
		NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')
	end
end

function NP:SizeScale(size, scale)
	local number = size * scale

	if mod(number, 2) == 1 then
		number = number + (scale >= 1 and 1 or -1)
	end

	return number
end

function NP:NamePlateCallBack(nameplate, event, unit)
	NP:UnitStyle(ElvNP_Player, 'PLAYER')

	if event == 'NAME_PLATE_UNIT_ADDED' then
		unit = unit or nameplate.unit
		local reaction = UnitReaction('player', unit)
		local faction = UnitFactionGroup(unit)

		if (UnitIsUnit(unit, 'player')) then
			NP:UnitStyle(nameplate, 'PLAYER')
			NP:UnitStyle(ElvNP_Player, 'PLAYER')
		elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend('player', unit) and reaction and reaction >= 5)) then
			NP:UnitStyle(nameplate, 'FRIENDLY_PLAYER')
		elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or faction == 'Neutral') then
			NP:UnitStyle(nameplate, 'FRIENDLY_NPC')
		elseif (not UnitIsPlayer(unit) and (reaction and reaction <= 4)) then
			NP:UnitStyle(nameplate, 'ENEMY_NPC')
		else
			NP:UnitStyle(nameplate, 'ENEMY_PLAYER')
		end
		NP.Plates[nameplate] = true
	end
end

function NP:Initialize()
	self.db = E.db.nameplates

	if E.private.nameplates.enable ~= true then return end

	ElvUF:RegisterStyle('ElvNP', function(frame, unit)
		NP:Style(frame, unit)
	end)
	ElvUF:SetActiveStyle('ElvNP')

	NP.Plates = {}
	NP.StatusBars = {}

	local BlizzPlateManaBar = NamePlateDriverFrame.classNamePlatePowerBar
	if BlizzPlateManaBar then
		BlizzPlateManaBar:Hide()
		BlizzPlateManaBar:UnregisterAllEvents()
	end

	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
		if frame.classNamePlateMechanicFrame then
			frame.classNamePlateMechanicFrame:Hide()
		end
		if frame.classNamePlatePowerBar then
			frame.classNamePlatePowerBar:Hide()
			frame.classNamePlatePowerBar:UnregisterAllEvents()
		end
	end)

	self.Tooltip = CreateFrame('GameTooltip', "ElvUIQuestTooltip", nil, 'GameTooltipTemplate')
	self.Tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

	ElvUF:Spawn('player', 'ElvNP_Player')
	ElvNP_Player:SetAttribute("unit", "player")
	ElvNP_Player:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	ElvNP_Player:SetAttribute("*type1", "target")
	ElvNP_Player:SetAttribute("*type2", "togglemenu")
	ElvNP_Player:SetAttribute("toggleForVehicle", true)
	ElvNP_Player:SetPoint("TOP", UIParent, "CENTER", 0, -150)
	ElvNP_Player:SetSize(NP.db.clickableWidth, NP.db.clickableHeight)
	ElvNP_Player:SetScale(1)
	ElvNP_Player:SetScript('OnEnter', UnitFrame_OnEnter)
	ElvNP_Player:SetScript('OnLeave', UnitFrame_OnLeave)
	if not NP.db.units['PLAYER'].useStaticPosition then
		ElvNP_Player:Disable()
	end

	E:CreateMover(ElvNP_Player, 'ElvNP_PlayerMover', L["Player NamePlate"], nil, nil, nil, 'ALL,SOLO', nil, 'player,generalGroup')

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')

	NP:ConfigureAll()

	E.NamePlates = self
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
