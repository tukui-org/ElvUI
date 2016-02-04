local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local _G = _G
local unpack, pairs = unpack, pairs
local format = format
--WoW API / Variables
local C_TimerAfter = C_Timer.After
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local CAN_HAVE_CLASSBAR = (E.myclass == "PALADIN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK" or E.myclass == "PRIEST" or E.myclass == "MONK" or E.myclass == 'MAGE' or E.myclass == 'ROGUE')

function UF:Construct_PlayerFrame(frame)
	frame.Threat = self:Construct_Threat(frame, true)

	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Power.frequentUpdates = true;

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)

	frame.Debuffs = self:Construct_Debuffs(frame)

	frame.Castbar = self:Construct_Castbar(frame, 'LEFT', L["Player Castbar"])

	if E.myclass == "PALADIN" then
		frame.HolyPower = self:Construct_PaladinResourceBar(frame, nil, UF.UpdateClassBar)
		frame.ClassBar = 'HolyPower'
	elseif E.myclass == "WARLOCK" then
		frame.ShardBar = self:Construct_DeathKnightResourceBar(frame)
		frame.ClassBar = 'ShardBar'
	elseif E.myclass == "DEATHKNIGHT" then
		frame.Runes = self:Construct_RuneBar(frame, true)
		frame.ClassBar = 'Runes'
	elseif E.myclass == "DRUID" then
		frame.EclipseBar = self:Construct_DruidResourceBar(frame)
		frame.DruidAltMana = self:Construct_DruidAltManaBar(frame)
		frame.ClassBar = 'EclipseBar'
	elseif E.myclass == "MONK" then
		frame.Harmony = self:Construct_MonkResourceBar(frame)
		frame.Stagger = self:Construct_Stagger(frame)
		frame.ClassBar = 'Harmony'
	elseif E.myclass == "PRIEST" then
		frame.ShadowOrbs = self:Construct_PriestResourceBar(frame)
		frame.ClassBar = 'ShadowOrbs'
	elseif E.myclass == 'MAGE' then
		frame.ArcaneChargeBar = self:Construct_MageResourceBar(frame)
		frame.ClassBar = 'ArcaneChargeBar'
	elseif E.myclass == 'ROGUE' then
		frame.Anticipation = self:Construct_RogueResourceBar(frame)
		frame.ClassBar = 'Anticipation'
	end

	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.Resting = self:Construct_RestingIndicator(frame)
	frame.Combat = self:Construct_CombatIndicator(frame)
	frame.PvPText = self:Construct_PvPIndicator(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)

	frame.AuraBars = self:Construct_AuraBarHeader(frame)

	frame.CombatFade = true

	frame.customTexts = {}

	frame:Point('BOTTOMLEFT', E.UIParent, 'BOTTOM', -413, 68) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["Player Frame"], nil, nil, nil, 'ALL,SOLO')
end


function UF:UpdatePlayerFrameAnchors(frame, isShown)

	
	
	--Everything below here is going away
	local db = E.db['unitframe']['units'].player
	local health = frame.Health
	local threat = frame.Threat
	local power = frame.Power
	local USE_PORTRAIT = db.portrait.enable
	local PORTRAIT_POSITION = db.portrait.position
	local USE_PORTRAIT_OVERLAY = USE_PORTRAIT and PORTRAIT_POSITION == "OVERLAY"
	local PORTRAIT_WIDTH = (USE_PORTRAIT_OVERLAY or not USE_PORTRAIT) and 0 or db.portrait.width
	local CLASSBAR_HEIGHT = db.classbar.height
	local CLASSBAR_HEIGHT_SPACING
	local CLASSBAR_DETACHED = db.classbar.detachFromFrame
	local USE_CLASSBAR = db.classbar.enable
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and USE_CLASSBAR
	local USE_POWERBAR = db.power.enable
	local USE_INSET_POWERBAR = db.power.width == 'inset' and USE_POWERBAR
	local USE_MINI_POWERBAR = db.power.width == 'spaced' and USE_POWERBAR
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local SPACING = E.Spacing;
	local BORDER = E.Border;
	local SHADOW_SPACING = (BORDER*3 - SPACING*2)

	if not USE_POWERBAR then
		POWERBAR_HEIGHT = 0
	end

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end

	if USE_MINI_CLASSBAR then
		CLASSBAR_HEIGHT = CLASSBAR_HEIGHT / 2
	end

	CLASSBAR_HEIGHT_SPACING = CLASSBAR_HEIGHT + SPACING

	if CLASSBAR_DETACHED then
		CLASSBAR_HEIGHT_SPACING = 0
	end

	if USE_STAGGER then
		
	elseif not USE_POWERBAR_OFFSET and not USE_MINI_POWERBAR and not USE_INSET_POWERBAR and not POWERBAR_DETACHED then
	
	end
end

function UF:Update_PlayerFrame(frame, db)
	frame.db = db
	frame.Portrait = db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D
	
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	local BORDER = E.Border
	local SPACING = E.Spacing
	local SHADOW_SPACING = (BORDER*3 - SPACING*2)
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height

	local USE_POWERBAR = db.power.enable
	local POWERBAR_DETACHED = db.power.detachFromFrame
	local USE_INSET_POWERBAR = not POWERBAR_DETACHED and db.power.width == 'inset' and USE_POWERBAR
	local USE_MINI_POWERBAR = not POWERBAR_DETACHED and db.power.width == 'spaced' and USE_POWERBAR
	
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR and not POWERBAR_DETACHED
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = not USE_POWERBAR and 0 or db.power.height
	local POWERBAR_WIDTH = USE_MINI_POWERBAR and (db.width - (BORDER*2))/2 or (POWERBAR_DETACHED and db.power.detachedWidth or (db.width - (BORDER*2)))

	local USE_PORTRAIT = db.portrait.enable
	local PORTRAIT_POSITION = db.portrait.position
	local USE_PORTRAIT_OVERLAY = USE_PORTRAIT and PORTRAIT_POSITION == "OVERLAY"
	local PORTRAIT_WIDTH = (USE_PORTRAIT_OVERLAY or not USE_PORTRAIT) and 0 or db.portrait.width
	
	local USE_CLASSBAR = db.classbar.enable and CAN_HAVE_CLASSBAR
	local CLASSBAR_DETACHED = db.classbar.detachFromFrame
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and USE_CLASSBAR and CLASSBAR_DETACHED ~= true
	local CLASSBAR_HEIGHT = db.classbar.height
	local CLASSBAR_WIDTH = UNIT_WIDTH - (BORDER*2) - PORTRAIT_WIDTH - POWERBAR_OFFSET
	local MAX_CLASS_BAR = UF.classMaxResourceBar[E.myclass]
	
	local unit = self.unit
	
	--new method for storing frame variables, will remove other variables when done
	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.BORDER = E.Border
		frame.SPACING = E.Spacing
		frame.SHADOW_SPACING = (frame.BORDER*7 - frame.SPACING*6)
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET_DIRECTION = db.power.offsetDirection
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - (frame.BORDER*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.PORTRAIT_POSITION = db.portrait.position
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		
		frame.CAN_HAVE_CLASSBAR = CAN_HAVE_CLASSBAR
		frame.MAX_CLASS_BAR = frame.MAX_CLASS_BAR or UF.classMaxResourceBar[E.myclass] or 0 --only set this initially
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = db.classbar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and frame.USE_CLASSBAR and frame.CLASSBAR_DETACHED ~= true
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - (frame.BORDER*2) - frame.PORTRAIT_WIDTH  - frame.POWERBAR_OFFSET	
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING+(frame.CLASSBAR_HEIGHT/2)) or frame.CLASSBAR_HEIGHT)

		frame.STAGGER_SHOWN = frame.Stagger and frame.Stagger:IsShown()
		frame.STAGGER_WIDTH = frame.STAGGER_SHOWN and (db.stagger.width + (frame.BORDER*2)) or 0;
	end
	
	
	frame.colors = ElvUF.colors
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	--Adjust some variables
	do
		if not USE_POWERBAR_OFFSET then
			POWERBAR_OFFSET = 0
		end
	end

	local mini_classbarY = 0
	if USE_MINI_CLASSBAR then
		mini_classbarY = -(SPACING+(CLASSBAR_HEIGHT/2))
	end

	--Threat
	do
		UF:SizeAndPosition_Threat(frame)
	end

	--Rest Icon
	do
		UF:SizeAndPosition_RestingIndicator(frame)
	end

	--Combat Icon
	do
		UF:SizeAndPosition_CombatIndicator(frame)
	end

	--Health
	do
		UF:SizeAndPosition_HealthBar(frame)
	end

	--Name
	UF:UpdateNameSettings(frame)

	--PvP
	do
		UF:SizeAndPosition_PVPIndicator(frame)
	end

	--Power
	do
		UF:SizeAndPosition_Power(frame)
	end

	--Portrait
	do
		UF:SizeAndPosition_Portrait(frame)
	end

	--Auras
	do
		UF:EnableDisable_Auras(frame)
		UF:SizeAndPosition_Auras(frame, 'Buffs')
		UF:SizeAndPosition_Auras(frame, 'Debuffs')
	end

	--Castbar
	do
		UF:SizeAndPosition_Castbar(frame)
	end

	--Resource Bars
	do
		UF:SizeAndPosition_ClassBar(frame)
	end

	--Stagger
	do
		if E.myclass == "MONK" then
			UF:SizeAndPosition_Stagger(frame)
		end
	end

	--Combat Fade
	do
		if db.combatfade and not frame:IsElementEnabled('CombatFade') then
			frame:EnableElement('CombatFade')
		elseif not db.combatfade and frame:IsElementEnabled('CombatFade') then
			frame:DisableElement('CombatFade')
		end
	end

	--Debuff Highlight
	do
		UF:SizeAndPosition_DebuffHighlight(frame)
	end

	--Raid Icon
	do
		UF:SizeAndPosition_RaidIcon(frame)
	end

	--OverHealing
	do
		UF:SizeAndPosition_HealComm(frame)
	end

	--AuraBars
	do
		UF:SizeAndPosition_AuraBars(frame)
	end

	for objectName, object in pairs(frame.customTexts) do
		if (not db.customTexts) or (db.customTexts and not db.customTexts[objectName]) then
			object:Hide()
			frame.customTexts[objectName] = nil
		end
	end

	if db.customTexts then
		local customFont = UF.LSM:Fetch("font", UF.db.font)
		for objectName, _ in pairs(db.customTexts) do
			if not frame.customTexts[objectName] then
				frame.customTexts[objectName] = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
			end

			local objectDB = db.customTexts[objectName]

			if objectDB.font then
				customFont = UF.LSM:Fetch("font", objectDB.font)
			end

			frame.customTexts[objectName]:FontTemplate(customFont, objectDB.size or UF.db.fontSize, objectDB.fontOutline or UF.db.fontOutline)
			frame:Tag(frame.customTexts[objectName], objectDB.text_format or '')
			frame.customTexts[objectName]:SetJustifyH(objectDB.justifyH or 'CENTER')
			frame.customTexts[objectName]:ClearAllPoints()
			frame.customTexts[objectName]:Point(objectDB.justifyH or 'CENTER', frame, objectDB.justifyH or 'CENTER', objectDB.xOffset, objectDB.yOffset)
		end
	end

	if UF.db.colors.transparentHealth then
		UF:ToggleTransparentStatusBar(true, frame.Health, frame.Health.bg)
	else
		UF:ToggleTransparentStatusBar(false, frame.Health, frame.Health.bg, (USE_PORTRAIT and USE_PORTRAIT_OVERLAY) ~= true)
	end

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg)

	E:SetMoverSnapOffset(frame:GetName()..'Mover', -(12 + db.castbar.height))
	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'player')

--Bugfix: Death Runes show as Blood Runes on first login ( http://git.tukui.org/Elv/elvui/issues/411 )
--For some reason the registered "PLAYER_ENTERING_WORLD" in runebar.lua doesn't trigger on first login.
local function UpdateAllRunes()
	local frame = _G["ElvUF_Player"]
	if frame and frame.Runes and frame.Runes.UpdateAllRuneTypes then
		frame.Runes.UpdateAllRuneTypes(frame)
	end
end
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)

	C_TimerAfter(5, UpdateAllRunes) --Delay it, since the WoW client updates Death Runes after PEW
end)