local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local CreateFrame = CreateFrame
local MAX_BOSS_FRAMES = 8

-- GLOBALS: BossHeaderMover

local BossHeader = CreateFrame('Frame', 'BossHeader', E.UIParent)
function UF:Construct_BossFrames(frame)
	frame.RaisedElementParent = UF:CreateRaisedElement(frame)
	frame.Health = UF:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Power = UF:Construct_PowerBar(frame, true, true, 'LEFT')
	frame.Power.displayAltPower = true
	frame.PowerPrediction = UF:Construct_PowerPrediction(frame)
	frame.Name = UF:Construct_NameText(frame)
	frame.AuraWatch = UF:Construct_AuraWatch(frame)
	frame.Portrait3D = UF:Construct_Portrait(frame, 'model')
	frame.Portrait2D = UF:Construct_Portrait(frame, 'texture')
	frame.InfoPanel = UF:Construct_InfoPanel(frame)
	frame.Buffs = UF:Construct_Buffs(frame)
	frame.Debuffs = UF:Construct_Debuffs(frame)
	frame.AuraHighlight = UF:Construct_AuraHighlight(frame)
	frame.Castbar = UF:Construct_Castbar(frame)
	frame.RaidTargetIndicator = UF:Construct_RaidIcon(frame)
	frame.Fader = UF:Construct_Fader()
	frame.Cutaway = UF:Construct_Cutaway(frame)
	frame.MouseGlow = UF:Construct_MouseGlow(frame)
	frame.TargetGlow = UF:Construct_TargetGlow(frame)
	frame.FocusGlow = UF:Construct_FocusGlow(frame)
	frame.HealthPrediction = UF:Construct_HealComm(frame)
	frame.customTexts = {}

	BossHeader:Point('BOTTOMRIGHT', E.UIParent, 'RIGHT', -105, -165)
	E:CreateMover(BossHeader, 'BossHeaderMover', L["Boss Frames"], nil, nil, nil, 'ALL,PARTY,RAID', nil, 'unitframe,groupUnits,boss,generalGroup')
	frame.mover = BossHeader.mover

	frame.unitframeType = 'boss'
end

function UF:Update_BossFrames(frame, db)
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

	UF:Configure_InfoPanel(frame)
	UF:Configure_HealthBar(frame)
	UF:UpdateNameSettings(frame)
	UF:Configure_Power(frame)
	UF:Configure_PowerPrediction(frame)
	UF:Configure_Portrait(frame)
	UF:EnableDisable_Auras(frame)
	UF:Configure_AllAuras(frame)
	UF:Configure_Castbar(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_AuraHighlight(frame)
	UF:Configure_CustomTexts(frame)
	UF:Configure_Fader(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_HealComm(frame)
	UF:Configure_AuraWatch(frame)

	frame:ClearAllPoints()

	if frame.index == 1 then
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', BossHeader.mover, 'BOTTOMRIGHT')
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', BossHeader.mover, 'LEFT')
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', BossHeader.mover, 'RIGHT')
		else --Down
			frame:Point('TOPRIGHT', BossHeader.mover, 'TOPRIGHT')
		end
	else
		if db.growthDirection == 'UP' then
			frame:Point('BOTTOMRIGHT', UF['boss'..frame.index-1], 'TOPRIGHT', 0, db.spacing)
		elseif db.growthDirection == 'RIGHT' then
			frame:Point('LEFT', UF['boss'..frame.index-1], 'RIGHT', db.spacing, 0)
		elseif db.growthDirection == 'LEFT' then
			frame:Point('RIGHT', UF['boss'..frame.index-1], 'LEFT', -db.spacing, 0)
		else --Down
			frame:Point('TOPRIGHT', UF['boss'..frame.index-1], 'BOTTOMRIGHT', 0, -db.spacing)
		end
	end

	if db.growthDirection == 'UP' or db.growthDirection == 'DOWN' then
		BossHeader:Width(frame.UNIT_WIDTH)
		BossHeader:Height(frame.UNIT_HEIGHT + ((frame.UNIT_HEIGHT + db.spacing) * (MAX_BOSS_FRAMES -1)))
	elseif db.growthDirection == 'LEFT' or db.growthDirection == 'RIGHT' then
		BossHeader:Width(frame.UNIT_WIDTH + ((frame.UNIT_WIDTH + db.spacing) * (MAX_BOSS_FRAMES -1)))
		BossHeader:Height(frame.UNIT_HEIGHT)
	end

	UF:HandleRegisterClicks(frame)

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

UF.unitgroupstoload.boss = {MAX_BOSS_FRAMES}
