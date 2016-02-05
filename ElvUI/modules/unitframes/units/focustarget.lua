local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local format = format

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUF_Focus

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_FocusTargetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')

	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT')

	frame.Name = self:Construct_NameText(frame)

	frame.Portrait3D = self:Construct_Portrait(frame, 'model')
	frame.Portrait2D = self:Construct_Portrait(frame, 'texture')

	frame.Buffs = self:Construct_Buffs(frame)
	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.Range = UF:Construct_Range(frame)
	frame.Threat = UF:Construct_Threat(frame)
	frame.customTexts = {}
	frame:Point('BOTTOM', ElvUF_Focus, 'TOP', 0, 7) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["FocusTarget Frame"], nil, -7, nil, 'ALL,SOLO')
end

function UF:Update_FocusTargetFrame(frame, db)
	frame.db = db

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
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)))

		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE")
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		
		frame.STAGGER_WIDTH = 0
		frame.CLASSBAR_YOFFSET = 0
	end
	
	frame.Portrait = db.portrait.style == '2D' and frame.Portrait2D or frame.Portrait3D
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame.colors = ElvUF.colors
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())

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
		--[[UF:EnableDisable_Auras(frame)
		UF:Configure_Auras(frame, 'Buffs')
		UF:Configure_Auras(frame, 'Debuffs')]]
	end

	--Raid Icon
	do
		UF:Configure_RaidIcon(frame)
	end

	--Range
	do
		UF:Configure_Range(frame)
	end

	UF:Configure_CustomTexts(frame)

	if UF.db.colors.transparentHealth then
		UF:ToggleTransparentStatusBar(true, frame.Health, frame.Health.bg)
	else
		UF:ToggleTransparentStatusBar(false, frame.Health, frame.Health.bg, (frame.USE_PORTRAIT and frame.USE_PORTRAIT_OVERLAY) ~= true)
	end
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg)

	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'focustarget')
