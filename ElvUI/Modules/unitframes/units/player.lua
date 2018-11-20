local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Cache global variables
--Lua functions
local _G = _G
local tinsert = tinsert
local max = math.max
--WoW API / Variables
local CreateFrame = CreateFrame
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Target

function UF:Construct_PlayerFrame(frame)
	frame.ThreatIndicator = self:Construct_Threat(frame)

	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Power.frequentUpdates = true;

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)

	frame.Debuffs = self:Construct_Debuffs(frame)

	frame.Castbar = self:Construct_Castbar(frame, L["Player Castbar"])

	--Create a holder frame all "classbars" can be positioned into
	frame.ClassBarHolder = CreateFrame("Frame", nil, frame)
	frame.ClassBarHolder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)

	--Combo points was moved to the ClassPower element, so all classes need to have a ClassBar now.
	frame.ClassPower = self:Construct_ClassBar(frame)
	frame.ClassBar = 'ClassPower'

	--Some classes need another set of different classbars.
	if E.myclass == "DEATHKNIGHT" then
		frame.Runes = self:Construct_DeathKnightResourceBar(frame)
		frame.ClassBar = 'Runes'
	elseif E.myclass == "DRUID" then
		frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
	elseif E.myclass == "MONK" then
		frame.Stagger = self:Construct_Stagger(frame)
	elseif E.myclass == 'PRIEST' then
		frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
	elseif E.myclass == 'SHAMAN' then
		frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
	end

	frame.PowerPrediction = self:Construct_PowerPrediction(frame) -- must be AFTER Power & AdditionalPower

	frame.MouseGlow = self:Construct_MouseGlow(frame)
	frame.TargetGlow = self:Construct_TargetGlow(frame)
	frame.RaidTargetIndicator = self:Construct_RaidIcon(frame)
	frame.RaidRoleFramesAnchor = self:Construct_RaidRoleFrames(frame)
	frame.RestingIndicator = self:Construct_RestingIndicator(frame)
	frame.CombatIndicator = self:Construct_CombatIndicator(frame)
	frame.PvPText = self:Construct_PvPIndicator(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	frame.HealthPrediction = self:Construct_HealComm(frame)
	frame.AuraBars = self:Construct_AuraBarHeader(frame)
	frame.InfoPanel = self:Construct_InfoPanel(frame)
	frame.PvPIndicator = self:Construct_PvPIcon(frame)
	frame.CombatFade = true
	frame.customTexts = {}

	frame:Point('BOTTOMLEFT', E.UIParent, 'BOTTOM', -413, 68) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["Player Frame"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,player,generalGroup')

	frame.unitframeType = "player"
end

function UF:Update_PlayerFrame(frame, db)
	frame.db = db

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?

		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height

		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0

		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.CAN_HAVE_CLASSBAR = true --Combo points are in ClassPower now, so all classes need access to ClassBar
		frame.MAX_CLASS_BAR = frame.MAX_CLASS_BAR or max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS) --only set this initially
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = db.classbar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2) - frame.PORTRAIT_WIDTH  -(frame.ORIENTATION == "MIDDLE" and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
		--If formula for frame.CLASSBAR_YOFFSET changes, then remember to update it in classbars.lua too
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING+(frame.CLASSBAR_HEIGHT/2)) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

		frame.VARIABLES_SET = true
	end

	frame.colors = ElvUF.colors
	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	UF:Configure_InfoPanel(frame)

	--Threat
	UF:Configure_Threat(frame)

	--Rest Icon
	UF:Configure_RestingIndicator(frame)

	--Combat Icon
	UF:Configure_CombatIndicator(frame)

	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--PvP
	UF:Configure_PVPIndicator(frame)

	--Power
	UF:Configure_Power(frame)

	-- Power Predicition
	UF:Configure_PowerPrediction(frame)

	--Portrait
	UF:Configure_Portrait(frame)

	--Auras
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')

	--Castbar
	UF:Configure_Castbar(frame)

	--Resource Bars
	UF:Configure_ClassBar(frame)

	--Combat Fade
	if db.combatfade and not frame:IsElementEnabled('CombatFade') then
		frame:EnableElement('CombatFade')
	elseif not db.combatfade and frame:IsElementEnabled('CombatFade') then
		frame:DisableElement('CombatFade')
	end

	--Debuff Highlight
	UF:Configure_DebuffHighlight(frame)

	--Raid Icon
	UF:Configure_RaidIcon(frame)

	--OverHealing
	UF:Configure_HealComm(frame)

	--AuraBars
	UF:Configure_AuraBars(frame)
	--We need to update Target AuraBars if attached to Player AuraBars
	--mainly because of issues when using power offset on player and switching to/from middle orientation
	if E.db.unitframe.units.target.aurabar.attachTo == "PLAYER_AURABARS" and ElvUF_Target then
		UF:Configure_AuraBars(ElvUF_Target)
	end

	--PvP & Prestige Icon
	UF:Configure_PVPIcon(frame)

	UF:Configure_RaidRoleIcons(frame)

	--CustomTexts
	UF:Configure_CustomTexts(frame)

	E:SetMoverSnapOffset(frame:GetName()..'Mover', -(12 + db.castbar.height))
	frame:UpdateAllElements("ElvUI_UpdateAllElements")
end

tinsert(UF.unitstoload, 'player')

--Bugfix: Classbar is not updated correctly on initial login ( http://git.tukui.org/Elv/elvui/issues/987 )
--ToggleResourceBar(bars) is called before the classbar has been updated, so we call it manually once.
local function UpdateClassBar()
	local frame = _G["ElvUF_Player"]
	if frame and frame.ClassBar then
		frame:UpdateElement(frame.ClassBar)
		UF.ToggleResourceBar(frame[frame.ClassBar])
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	if not E.db.unitframe.units.player.enable then return end
	UpdateClassBar()
end)
