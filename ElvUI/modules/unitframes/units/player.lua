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
		frame.ShardBar = self:Construct_WarlockResourceBar(frame)
		frame.ClassBar = 'ShardBar'
	elseif E.myclass == "DEATHKNIGHT" then
		frame.Runes = self:Construct_DeathKnightResourceBar(frame)
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
	frame.InfoPanel = self:Construct_InfoPanel(frame)
	frame.customTexts = {}

	frame:Point('BOTTOMLEFT', E.UIParent, 'BOTTOM', -413, 68) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["Player Frame"], nil, nil, nil, 'ALL,SOLO')

	frame.unitframeType = "player"
end

function UF:Update_PlayerFrame(frame, db)
	frame.db = db

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?

		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = (E.global.tukuiMode and not db.infoPanel.enable) and db.height + db.infoPanel.height or db.height

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

		frame.CAN_HAVE_CLASSBAR = CAN_HAVE_CLASSBAR
		frame.MAX_CLASS_BAR = frame.MAX_CLASS_BAR or UF.classMaxResourceBar[E.myclass] or 0 --only set this initially
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = db.classbar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2) - frame.PORTRAIT_WIDTH  -(frame.ORIENTATION == "MIDDLE" and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
		--If formula for frame.CLASSBAR_YOFFSET changes, then remember to update it in classbars.lua too
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING+(frame.CLASSBAR_HEIGHT/2)) or (frame.CLASSBAR_HEIGHT - (frame.BORDER-frame.SPACING)))

		frame.STAGGER_SHOWN = frame.Stagger and frame.Stagger:IsShown()
		frame.STAGGER_WIDTH = frame.STAGGER_SHOWN and (db.stagger.width + (frame.BORDER*2)) or 0;

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and (db.infoPanel.enable or E.global.tukuiMode)
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
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

	--Stagger
	if E.myclass == "MONK" then
		UF:Configure_Stagger(frame)
	end

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

	--CustomTexts
	UF:Configure_CustomTexts(frame)

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
	UpdateClassBar()
	C_TimerAfter(5, UpdateAllRunes) --Delay it, since the WoW client updates Death Runes after PEW
end)