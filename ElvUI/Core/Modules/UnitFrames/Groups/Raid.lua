local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

function UF:Construct_RaidFrames()
	self:SetScript('OnEnter', UF.UnitFrame_OnEnter)
	self:SetScript('OnLeave', UF.UnitFrame_OnLeave)

	self.RaisedElementParent = UF:CreateRaisedElement(self)
	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT')
	self.PowerPrediction = UF:Construct_PowerPrediction(self)
	self.Portrait3D = UF:Construct_Portrait(self, 'model')
	self.Portrait2D = UF:Construct_Portrait(self, 'texture')
	self.InfoPanel = UF:Construct_InfoPanel(self)
	self.Name = UF:Construct_NameText(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.AuraHighlight = UF:Construct_AuraHighlight(self)
	self.GroupRoleIndicator = UF:Construct_RoleIcon(self)
	self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.PhaseIndicator = UF:Construct_PhaseIcon(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.FocusGlow = UF:Construct_FocusGlow(self)
	self.ThreatIndicator = UF:Construct_Threat(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self)
	self.ResurrectIndicator = UF:Construct_ResurrectionIcon(self)
	self.SummonIndicator = UF:Construct_SummonIcon(self)
	self.HealthPrediction = UF:Construct_HealComm(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)
	self.customTexts = {}

	if E.Retail then
		self.PvPClassificationIndicator = UF:Construct_PvPClassificationIndicator(self) -- Cart / Flag / Orb / Assassin Bounty
		self.AlternativePower = UF:Construct_AltPowerBar(self)
		self.ClassBar = 'AlternativePower'
	end

	self.unitframeType = 'raid'

	return self
end

function UF:Update_RaidHeader(header, db)
	local parent = header:GetParent()
	parent.db = db

	if not parent.positioned then
		parent:ClearAllPoints()
		parent:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', 4, 248)
		E:CreateMover(parent, parent:GetName()..'Mover', L["Raid Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,groupUnits,raid,generalGroup')
		parent.positioned = true
	end
end

function UF:Update_RaidFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors

	do
		frame.SHADOW_SPACING = 3
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
		frame.USE_POWERBAR = db.power.enable
		frame.POWERBAR_DETACHED = false
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
		frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER*2))*0.5 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER+UF.SPACING)*2)))
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == 'MIDDLE')
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CAN_HAVE_CLASSBAR = not frame.isChild
		frame.MAX_CLASS_BAR = 1
		frame.USE_CLASSBAR = db.classbar.enable and frame.CAN_HAVE_CLASSBAR
		frame.CLASSBAR_SHOWN = frame.CAN_HAVE_CLASSBAR and frame[frame.ClassBar] and frame[frame.ClassBar]:IsShown()
		frame.CLASSBAR_DETACHED = false
		frame.USE_MINI_CLASSBAR = db.classbar.fill == 'spaced' and frame.USE_CLASSBAR
		frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and db.classbar.height or 0
		frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - frame.PORTRAIT_WIDTH - (frame.ORIENTATION == 'MIDDLE' and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
		frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5)) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))
		frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
		frame.INFO_PANEL_HEIGHT = frame.USE_INFO_PANEL and db.infoPanel.height or 0
		frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	end

	if db.enable and not frame:IsEnabled() then
		frame:Enable()
	elseif not db.enable and frame:IsEnabled() then
		frame:Disable()
	end

	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

	UF:EnableDisable_Auras(frame)
	UF:Configure_AllAuras(frame)
	UF:Configure_InfoPanel(frame)
	UF:Configure_HealthBar(frame)
	UF:Configure_Power(frame)
	UF:Configure_PowerPrediction(frame)
	UF:Configure_Portrait(frame)
	UF:Configure_Threat(frame)
	UF:Configure_RaidDebuffs(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_AuraHighlight(frame)
	UF:Configure_RoleIcon(frame)
	UF:Configure_HealComm(frame)
	UF:Configure_RaidRoleIcons(frame)
	UF:Configure_Fader(frame)
	UF:Configure_AuraWatch(frame)
	UF:Configure_ReadyCheckIcon(frame)
	UF:Configure_ResurrectionIcon(frame)
	UF:Configure_SummonIcon(frame)
	UF:Configure_CustomTexts(frame)
	UF:Configure_PhaseIcon(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_ClassBar(frame)
	UF:UpdateNameSettings(frame)

	if E.Retail then
		UF:Configure_AltPowerBar(frame)
		UF:Configure_PvPClassificationIndicator(frame)
	end

	UF:HandleRegisterClicks(frame)

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

UF.headerstoload.raid = true
