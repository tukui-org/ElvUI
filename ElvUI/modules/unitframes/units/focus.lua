local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local tinsert = table.insert
local format = format
--WoW API / Variables
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Target

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_FocusFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)

	frame.Castbar = self:Construct_Castbar(frame, 'LEFT', L["Focus Castbar"])
	frame.Castbar.SafeZone = nil
	frame.Castbar.LatencyTexture:Hide()
	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)
	frame.AuraBars = self:Construct_AuraBarHeader(frame)
	frame.Range = UF:Construct_Range(frame)
	frame.Threat = UF:Construct_Threat(frame)
	frame.GPS = self:Construct_GPS(frame)
	frame.InfoPanel = self:Construct_InfoPanel(frame)

	frame.customTexts = {}
	frame:Point('BOTTOMRIGHT', ElvUF_Target, 'TOPRIGHT', 0, 220)
	E:CreateMover(frame, frame:GetName()..'Mover', L["Focus Frame"], nil, nil, nil, 'ALL,SOLO')

	frame.unitframeType = "focus"
end

function UF:Update_FocusFrame(frame, db)
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

		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and (db.infoPanel.enable or E.global.tukuiMode)
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0

		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	end

	frame.Portrait = frame.Portrait or (db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D)
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame.colors = ElvUF.colors
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())
	UF:Configure_InfoPanel(frame)
	--Health
	UF:Configure_HealthBar(frame)

	--Name
	UF:UpdateNameSettings(frame)

	--Power
	UF:Configure_Power(frame)

	--Portrait
	UF:Configure_Portrait(frame)

	--Threat
	UF:Configure_Threat(frame)

	--Auras
	UF:EnableDisable_Auras(frame)
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')

	UF:Configure_Castbar(frame)

	--OverHealing
	UF:Configure_HealComm(frame)

	--GPSArrow
	UF:Configure_GPS(frame)

	--Raid Icon
	UF:Configure_RaidIcon(frame)

	--AuraBars
	UF:Configure_AuraBars(frame)

	--Range
	UF:Configure_Range(frame)

	--CustomTexts
	UF:Configure_CustomTexts(frame)

	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'focus')
