local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local max = max
local InCombatLockdown = InCombatLockdown
local RegisterAttributeDriver = RegisterAttributeDriver

function UF:Construct_AssistFrames()
	local isChild = self.isChild

	UF:PrepareFrame(self, 'assist')
	UF:ConstructFrame(self, isChild and 'assisttarget' or 'assist')

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Name = UF:Construct_NameText(self)
	self.ThreatIndicator = UF:Construct_Threat(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.FocusGlow = UF:Construct_FocusGlow(self)
	self.HealthPrediction = UF:Construct_HealComm(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	if not isChild then
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.AuraHighlight = UF:Construct_AuraHighlight(self)
		self.Auras = UF:Construct_Auras(self)
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
	end

	return self
end

function UF:Update_AssistHeader(header, db)
	header:Hide()
	header.db = db

	if not header.isForced and db.enable then
		RegisterAttributeDriver(header, 'state-visibility', '[@raid1,exists] show;hide')
	end

	local up = db.growthY == 'UP'
	local spacing = db.verticalSpacing
	header:SetAttribute('_ignore', true) -- hold the header update
	header:SetAttribute('yOffset', up and spacing or -spacing)

	if not header.positioned then
		local width, height = header:GetSize()
		local minHeight = max(height, 2 * db.height + spacing)
		header:SetAttribute('columnAnchorPoint', 'LEFT')
		header:SetAttribute('minHeight', minHeight)
		header:SetAttribute('minWidth', width)
		header:ClearAllPoints()
		header:Point('TOPLEFT', E.UIParent, 4, -250)

		E:CreateMover(header, header:GetName()..'Mover', L["MA Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,groupUnits,assist,generalGroup')
		header.mover:SetSize(width, minHeight)

		header.positioned = true
	end

	header:SetAttribute('_ignore', nil) -- allow updates
	header:SetAttribute('point', up and 'BOTTOM' or 'TOP')
end

function UF:Update_AssistFrames(frame, db)
	frame.colors = ElvUF.colors

	do
		frame.ORIENTATION = db.orientation -- allow this value to change when unitframes position changes on screen?
		frame.SHADOW_SPACING = 3
		frame.UNIT_WIDTH = db.width
		frame.UNIT_HEIGHT = db.height
		frame.USE_POWERBAR = false
		frame.POWERBAR_DETACHED = false
		frame.USE_INSET_POWERBAR = false
		frame.USE_MINI_POWERBAR = false
		frame.USE_POWERBAR_OFFSET = false
		frame.POWERBAR_OFFSET = 0
		frame.POWERBAR_HEIGHT = 0
		frame.POWERBAR_WIDTH = 0
		frame.USE_PORTRAIT = false
		frame.USE_PORTRAIT_OVERLAY = false
		frame.PORTRAIT_WIDTH = 0
		frame.CLASSBAR_YOFFSET = 0
		frame.BOTTOM_OFFSET = 0
	end

	local opt = db.strataAndLevel
	frame:SetFrameStrata(opt and opt.useCustomStrata and opt.frameStrata or 'LOW')
	frame:SetFrameLevel(opt and opt.useCustomLevel and opt.frameLevel or 1)

	local noCombat = not InCombatLockdown()
	if frame.isChild then
		local childDB = db.targetsGroup
		frame.db = db.targetsGroup
		frame:Size(childDB.width, childDB.height)

		if noCombat then
			local enabled = childDB.enable
			frame:SetEnabled(enabled)

			if enabled then
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset)
			end
		end
	else
		frame.db = db
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)

		if noCombat then
			frame:ClearAllPoints()
		end
	end

	UF:ConfigureFrame(frame, frame.isChild and 'assisttarget' or 'assist')
end

UF.headerstoload.assist = {'MAINASSIST', E.Modern and 'ELVUI_UNITTARGET_PINGABLE' or 'ELVUI_UNITTARGET'}
