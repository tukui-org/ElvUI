local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

function UF:Construct_RaidpetFrames()
	UF:PrepareFrame(self, 'raidpet')
	UF:ConstructFrame(self, 'raidpet')

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Name = UF:Construct_NameText(self)
	self.Portrait3D = UF:Construct_Portrait(self, 'model')
	self.Portrait2D = UF:Construct_Portrait(self, 'texture')
	self.Auras = UF:Construct_Auras(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.AuraHighlight = UF:Construct_AuraHighlight(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.FocusGlow = UF:Construct_FocusGlow(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.ThreatIndicator = UF:Construct_Threat(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.HealthPrediction = UF:Construct_HealComm(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)
	self.PrivateAuras = UF:Construct_PrivateAuras(self)

	return self
end

function UF:Update_RaidpetHeader(header, db)
	local parent = header:GetParent()
	parent.db = db

	if not parent.positioned then
		parent:ClearAllPoints()
		parent:Point('TOPLEFT', E.UIParent, 'BOTTOMLEFT', 4, 737)
		E:CreateMover(parent, parent:GetName()..'Mover', L["Raid Pet Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,groupUnits,raidpet,generalGroup')
		parent.positioned = true
	end
end

function UF:Update_RaidpetFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors

	do
		frame.SHADOW_SPACING = 3
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
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
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == 'MIDDLE')
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width
		frame.CLASSBAR_YOFFSET = 0
		frame.BOTTOM_OFFSET = 0
	end

	frame.Health.colorPetByUnitClass = db.health.colorPetByUnitClass
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	frame:SetFrameStrata(db.strataAndLevel and db.strataAndLevel.useCustomStrata and db.strataAndLevel.frameStrata or 'LOW')
	frame:SetFrameLevel(db.strataAndLevel and db.strataAndLevel.useCustomLevel and db.strataAndLevel.frameLevel or 1)

	UF:ConfigureFrame(frame, 'raidpet')
end

--Added an additional argument at the end, specifying the header Template we want to use
UF.headerstoload.raidpet = {nil, nil, 'SecureGroupPetHeaderTemplate'}
