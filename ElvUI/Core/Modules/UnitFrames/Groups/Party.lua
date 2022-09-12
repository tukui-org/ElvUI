local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local _G = _G
local InCombatLockdown = InCombatLockdown

function UF:Construct_PartyFrames()
	self:SetScript('OnEnter', UF.UnitFrame_OnEnter)
	self:SetScript('OnLeave', UF.UnitFrame_OnLeave)

	self.RaisedElementParent = UF:CreateRaisedElement(self)

	self.BORDER = UF.BORDER
	self.SPACING = UF.SPACING
	self.SHADOW_SPACING = 3

	if self.isChild then
		self.Health = UF:Construct_HealthBar(self, true)
		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.FocusGlow = UF:Construct_FocusGlow(self)
		self.Name = UF:Construct_NameText(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
		self.AuraHighlight = UF:Construct_AuraHighlight(self)
		self.ThreatIndicator = UF:Construct_Threat(self)

		self.originalParent = self:GetParent()

		self.childType = 'pet'
		if self == _G[self.originalParent:GetName()..'Target'] then
			self.childType = 'target'
		end

		if self.childType == 'pet' then
			self.AuraWatch = UF:Construct_AuraWatch(self)
			self.HealthPrediction = UF:Construct_HealComm(self)
		end

		self.unitframeType = 'party'..self.childType
	else
		self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
		self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT')
		self.PowerPrediction = UF:Construct_PowerPrediction(self)
		self.Portrait3D = UF:Construct_Portrait(self, 'model')
		self.Portrait2D = UF:Construct_Portrait(self, 'texture')
		self.InfoPanel = UF:Construct_InfoPanel(self)
		self.Name = UF:Construct_NameText(self)
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
		self.Castbar = UF:Construct_Castbar(self)
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.AuraHighlight = UF:Construct_AuraHighlight(self)
		self.ResurrectIndicator = UF:Construct_ResurrectionIcon(self)
		self.SummonIndicator = UF:Construct_SummonIcon(self)
		self.CombatIndicator = UF:Construct_CombatIndicator(self)
		self.GroupRoleIndicator = UF:Construct_RoleIcon(self)
		self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
		self.MouseGlow = UF:Construct_MouseGlow(self)
		self.PhaseIndicator = UF:Construct_PhaseIcon(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.FocusGlow = UF:Construct_FocusGlow(self)
		self.ThreatIndicator = UF:Construct_Threat(self)
		self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
		self.ReadyCheckIndicator = UF:Construct_ReadyCheckIcon(self)
		self.HealthPrediction = UF:Construct_HealComm(self)
		self.customTexts = {}

		if E.Retail then
			self.PvPClassificationIndicator = UF:Construct_PvPClassificationIndicator(self) -- Cart / Flag / Orb / Assassin Bounty
			self.AlternativePower = UF:Construct_AltPowerBar(self)
			self.ClassBar = 'AlternativePower'
		end

		self.unitframeType = 'party'
	end

	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	return self
end

function UF:Update_PartyHeader(header, db)
	local parent = header:GetParent()
	parent.db = db

	if not parent.positioned then
		parent:ClearAllPoints()
		parent:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', 4, 248)
		E:CreateMover(parent, parent:GetName()..'Mover', L["Party Frames"], nil, nil, nil, 'ALL,PARTY,ARENA', nil, 'unitframe,groupUnits,party,generalGroup')
		parent.positioned = true
	end
end

function UF:Update_PartyFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors

	do
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

	if frame.isChild then
		frame.USE_PORTAIT = false
		frame.USE_PORTRAIT_OVERLAY = false
		frame.PORTRAIT_WIDTH = 0
		frame.USE_POWERBAR = false
		frame.USE_INSET_POWERBAR = false
		frame.USE_MINI_POWERBAR = false
		frame.USE_POWERBAR_OFFSET = false
		frame.POWERBAR_OFFSET = 0

		frame.POWERBAR_HEIGHT = 0
		frame.POWERBAR_WIDTH = 0

		frame.BOTTOM_OFFSET = 0

		frame.db = frame.childType == 'target' and db.targetsGroup or db.petsGroup

		-- these are just coming in from the main group and will not export
		frame.db.disableMouseoverGlow = db.disableMouseoverGlow
		frame.db.disableTargetGlow = db.disableMouseoverGlow
		frame.db.disableFocusGlow = db.disableMouseoverGlow

		db = frame.db

		frame:Size(db.width, db.height)

		if not InCombatLockdown() then
			if db.enable then
				frame:Enable()
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[db.anchorPoint], frame.originalParent, db.anchorPoint, db.xOffset, db.yOffset)
			else
				frame:Disable()
			end
		end

		if frame.childType == 'pet' then
			frame.Health.colorPetByUnitClass = db.colorPetByUnitClass

			UF:Configure_HealthBar(frame) -- keep over HealComm and after colorPetByUnitClass
			UF:Configure_AuraWatch(frame)
			UF:Configure_HealComm(frame)
		else
			UF:Configure_HealthBar(frame)
		end
	else
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

		UF:EnableDisable_Auras(frame)
		UF:Configure_AllAuras(frame)
		UF:Configure_HealthBar(frame)
		UF:Configure_InfoPanel(frame)
		UF:Configure_PhaseIcon(frame)
		UF:Configure_Power(frame)
		UF:Configure_Portrait(frame)
		UF:Configure_RaidDebuffs(frame)
		UF:Configure_Castbar(frame)
		UF:Configure_RoleIcon(frame)
		UF:Configure_RaidRoleIcons(frame)
		UF:Configure_AuraWatch(frame)
		UF:Configure_HealComm(frame)
		UF:Configure_ReadyCheckIcon(frame)
		UF:Configure_ClassBar(frame)
		UF:Configure_CustomTexts(frame)
		UF:Configure_CombatIndicator(frame)

		if E.Retail then
			UF:Configure_AltPowerBar(frame)
			UF:Configure_ResurrectionIcon(frame)
			UF:Configure_SummonIcon(frame)
			UF:Configure_PvPClassificationIndicator(frame)
		end
	end

	UF:UpdateNameSettings(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Threat(frame)
	UF:Configure_Fader(frame)
	UF:Configure_Cutaway(frame)
	UF:Configure_AuraHighlight(frame)

	UF:HandleRegisterClicks(frame)

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

UF.headerstoload.party = {nil, 'ELVUI_UNITPET, ELVUI_UNITTARGET'}
