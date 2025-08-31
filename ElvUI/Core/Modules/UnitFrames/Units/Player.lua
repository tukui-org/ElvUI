local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local max = max
local tinsert = tinsert

local CreateFrame = CreateFrame
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function UF:Construct_PlayerFrame(frame)
	UF:PrepareFrame(frame)
	UF:ConstructFrame(frame, 'player')

	frame.ThreatIndicator = UF:Construct_Threat(frame)
	frame.Health = UF:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Power = UF:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Name = UF:Construct_NameText(frame)
	frame.Portrait3D = UF:Construct_Portrait(frame, 'model')
	frame.Portrait2D = UF:Construct_Portrait(frame, 'texture')
	frame.Auras = UF:Construct_Auras(frame)
	frame.Buffs = UF:Construct_Buffs(frame)
	frame.Debuffs = UF:Construct_Debuffs(frame)
	frame.Castbar = UF:Construct_Castbar(frame, L["Player Castbar"])

	-- Create a holder frame all 'classbars' can be positioned into
	frame.ClassBarHolder = CreateFrame('Frame', nil, frame)
	frame.ClassBarHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)

	-- Druid, Priest, Shaman, Monk
	frame.ClassAdditionalHolder = CreateFrame('Frame', nil, frame)
	frame.ClassAdditionalHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)

	UF:GetClassPower_Construct(frame)

	frame.PowerPrediction = UF:Construct_PowerPrediction(frame) -- must be AFTER Power & AdditionalPower
	frame.MouseGlow = UF:Construct_MouseGlow(frame)
	frame.TargetGlow = UF:Construct_TargetGlow(frame)
	frame.FocusGlow = UF:Construct_FocusGlow(frame)
	frame.RaidTargetIndicator = UF:Construct_RaidIcon(frame)
	frame.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(frame)
	frame.RestingIndicator = UF:Construct_RestingIndicator(frame)
	frame.ResurrectIndicator = UF:Construct_ResurrectionIcon(frame)
	frame.CombatIndicator = UF:Construct_CombatIndicator(frame)
	frame.PartyIndicator = UF:Construct_PartyIndicator(frame)
	frame.PvPText = UF:Construct_PvPText(frame)
	frame.AuraHighlight = UF:Construct_AuraHighlight(frame)
	frame.HealthPrediction = UF:Construct_HealComm(frame)
	frame.AuraBars = UF:Construct_AuraBarHeader(frame)
	frame.InfoPanel = UF:Construct_InfoPanel(frame)
	frame.PvPIndicator = UF:Construct_PvPIcon(frame)
	frame.AuraWatch = UF:Construct_AuraWatch(frame)
	frame.Fader = UF:Construct_Fader()
	frame.Cutaway = UF:Construct_Cutaway(frame)
	frame.PrivateAuras = UF:Construct_PrivateAuras(frame)

	frame:Point('BOTTOM', E.UIParent, 'BOTTOM', -342, 139) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L["Player Frame"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,generalGroup')
end

function UF:Update_PlayerFrame(frame, db)
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
		frame.CAN_HAVE_CLASSBAR = true --Combo points are in ClassPower now, so all classes need access to ClassBar
		frame.MAX_CLASS_BAR = frame.MAX_CLASS_BAR or max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS) --only set this initially
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = db.classbar.detachFromFrame
		frame.USE_MINI_CLASSBAR = db.classbar.fill == 'spaced' and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - frame.PORTRAIT_WIDTH - (frame.ORIENTATION == 'MIDDLE' and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
		--If formula for frame.CLASSBAR_YOFFSET changes, then remember to update it in classbars.lua too
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5)) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	end

	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	frame.mover:Size(frame:GetSize())
	frame:SetFrameStrata(db.strataAndLevel and db.strataAndLevel.useCustomStrata and db.strataAndLevel.frameStrata or 'LOW')
	frame:SetFrameLevel(db.strataAndLevel and db.strataAndLevel.useCustomLevel and db.strataAndLevel.frameLevel or 1)

	UF:ConfigureFrame(frame, 'player', 12 + db.castbar.height)
end

tinsert(UF.unitstoload, 'player')
