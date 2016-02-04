local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
local tinsert = table.insert
local ceil = math.ceil
local format = format
--WoW API / Variables
local IsAddOnLoaded = IsAddOnLoaded
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Player

function UF:Construct_TargetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Power.frequentUpdates = true;

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)

	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.Threat = self:Construct_Threat(frame)
	frame.Castbar = self:Construct_Castbar(frame, 'RIGHT', L["Target Castbar"])
	frame.Castbar.SafeZone = nil
	frame.Castbar.LatencyTexture:Hide()
	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.CPoints = self:Construct_Combobar(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	frame.GPS = self:Construct_GPS(frame)

	frame.AuraBars = self:Construct_AuraBarHeader(frame)
	frame.Range = UF:Construct_Range(frame)
	frame.customTexts = {}
	frame:Point('BOTTOMRIGHT', E.UIParent, 'BOTTOM', 413, 68)
	E:CreateMover(frame, frame:GetName()..'Mover', L["Target Frame"], nil, nil, nil, 'ALL,SOLO')
end

function UF:Update_TargetFrame(frame, db)
	frame.db = db

	frame.Portrait = db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

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
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width

		frame.CAN_HAVE_CLASSBAR = db.combobar.enable
		frame.MAX_CLASS_BAR = MAX_COMBO_POINTS
		frame.USE_CLASSBAR = db.combobar.enable
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame.CPoints:IsShown()
		frame.CLASSBAR_DETACHED = db.combobar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.combobar.fill == "spaced" and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.combobar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2) - frame.PORTRAIT_WIDTH  - frame.POWERBAR_OFFSET
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (frame.SPACING+(frame.CLASSBAR_HEIGHT/2)) or (frame.CLASSBAR_HEIGHT + frame.SPACING))

		frame.STAGGER_SHOWN = false
		frame.STAGGER_WIDTH = 0
	end

	local unit = self.unit

	frame.colors = ElvUF.colors
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

	if not IsAddOnLoaded("Clique") then
		if db.middleClickFocus then
			frame:SetAttribute("type3", "focus")
		elseif frame:GetAttribute("type3") == "focus" then
			frame:SetAttribute("type3", nil)
		end
	end


	--Health
	do
		UF:Configure_HealthBar(frame)
	end

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	do
		UF:Configure_Power(frame)
	end

	--Portrait
	do
		UF:Configure_Portrait(frame)
	end

	--Threat
	do
		UF:Configure_Threat(frame)
	end

	--Auras
	do
		UF:EnableDisable_Auras(frame)
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')
	end

	--Castbar
	do
		UF:Configure_Castbar(frame)
	end

	--Combo Bar
	do
		UF:Configure_ComboPoints(frame)
	end

	--Debuff Highlight
	do
		UF:Configure_DebuffHighlight(frame)
	end

	--OverHealing
	do
		UF:Configure_HealComm(frame)
	end

	--GPSArrow
	do
		UF:Configure_GPS(frame)
	end

	--Raid Icon
	do
		UF:Configure_RaidIcon(frame)
	end

	--AuraBars
	do
		UF:Configure_AuraBars(frame)
	end

	--Range
	do
		UF:Configure_Range(frame)
	end

	
	--CustomTexts
	do
		UF:Configure_CustomTexts(frame)
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

tinsert(UF['unitstoload'], 'target')
