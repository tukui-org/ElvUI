local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local tinsert = tinsert

function UF:Construct_TargetTargetFrame(frame)
	UF:PrepareFrame(frame)
	UF:ConstructFrame(frame, 'targettarget')

	frame.Health = UF:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Power = UF:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.PowerPrediction = UF:Construct_PowerPrediction(frame)
	frame.Name = UF:Construct_NameText(frame)
	frame.Portrait3D = UF:Construct_Portrait(frame, 'model')
	frame.Portrait2D = UF:Construct_Portrait(frame, 'texture')
	frame.Auras = UF:Construct_Auras(frame)
	frame.Buffs = UF:Construct_Buffs(frame)
	frame.RaidTargetIndicator = UF:Construct_RaidIcon(frame)
	frame.HealthPrediction = UF:Construct_HealComm(frame)
	frame.Debuffs = UF:Construct_Debuffs(frame)
	frame.ThreatIndicator = UF:Construct_Threat(frame)
	frame.InfoPanel = UF:Construct_InfoPanel(frame)
	frame.MouseGlow = UF:Construct_MouseGlow(frame)
	frame.TargetGlow = UF:Construct_TargetGlow(frame)
	frame.FocusGlow = UF:Construct_FocusGlow(frame)
	frame.Fader = UF:Construct_Fader()
	frame.Cutaway = UF:Construct_Cutaway(frame)

	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', 342, 100) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["TargetTarget Frame"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,targettarget,generalGroup')
end

function UF:Update_TargetTargetFrame(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = db.power.detachFromFrame
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER*2))*0.5 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER+UF.SPACING)*2)))
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == 'MIDDLE')
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	end

	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	frame.mover:Size(frame:GetSize())
	frame:SetFrameStrata(db.strataAndLevel and db.strataAndLevel.useCustomStrata and db.strataAndLevel.frameStrata or 'LOW')
	frame:SetFrameLevel(db.strataAndLevel and db.strataAndLevel.useCustomLevel and db.strataAndLevel.frameLevel or 1)

	UF:ConfigureFrame(frame, 'targettarget', 12 + UF.db.units.player.castbar.height)
end

tinsert(UF.unitstoload, 'targettarget')
