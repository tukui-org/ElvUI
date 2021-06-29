local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

local _G = _G
local max = max
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterAttributeDriver = RegisterAttributeDriver

function UF:Construct_AssistFrames()
	self:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	self:SetScript('OnLeave', _G.UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, self.RaisedElementParent)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 100)

	self.Health = UF:Construct_HealthBar(self, true)
	self.Name = UF:Construct_NameText(self)
	self.ThreatIndicator = UF:Construct_Threat(self)
	self.RaidTargetIndicator = UF:Construct_RaidIcon(self)
	self.MouseGlow = UF:Construct_MouseGlow(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	self.FocusGlow = UF:Construct_FocusGlow(self)
	self.Fader = UF:Construct_Fader()
	self.Cutaway = UF:Construct_Cutaway(self)

	if not self.isChild then
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
		self.AuraHighlight = UF:Construct_AuraHighlight(self)

		self.unitframeType = 'assist'
	else
		self.unitframeType = 'assisttarget'
	end

	self.originalParent = self:GetParent()

	return self
end

function UF:Update_AssistHeader(header, db)
	header:Hide()
	header.db = db

	UF:ClearChildPoints(header:GetChildren())

	if not header.isForced and db.enable then
		RegisterAttributeDriver(header, 'state-visibility', '[@raid1,exists] show;hide')
	end

	header:SetAttribute('point', 'BOTTOM')
	header:SetAttribute('columnAnchorPoint', 'LEFT')
	header:SetAttribute('yOffset', db.verticalSpacing)

	if not header.positioned then
		header:ClearAllPoints()
		header:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -248)

		local width, height = header:GetSize()
		local minHeight = max(height, 2 * db.height + db.verticalSpacing)
		header:SetAttribute('minHeight', minHeight)
		header:SetAttribute('minWidth', width)

		E:CreateMover(header, header:GetName()..'Mover', L["MA Frames"], nil, nil, nil, 'ALL,RAID', nil, 'unitframe,groupUnits,assist,generalGroup')
		header.mover:SetSize(width, minHeight)

		header.positioned = true
	end
end

function UF:Update_AssistFrames(frame, db)
	frame.db = db
	frame.colors = ElvUF.colors
	frame:RegisterForClicks(UF.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	do
		frame.ORIENTATION = db.orientation --allow this value to change when unitframes position changes on screen?
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

	if frame.isChild then
		local childDB = db.targetsGroup
		frame.db = db.targetsGroup

		frame:Size(childDB.width, childDB.height)

		if not InCombatLockdown() then
			if childDB.enable then
				frame:Enable()
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset)
			else
				frame:Disable()
			end
		end
	else
		frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
	end

	UF:Configure_HealthBar(frame)
	UF:Configure_Threat(frame)
	UF:UpdateNameSettings(frame)
	UF:Configure_Fader(frame)
	UF:Configure_RaidIcon(frame)
	UF:Configure_Cutaway(frame)

	if not frame.isChild then
		if not E:IsAddOnEnabled('Clique') then
			if db.middleClickFocus then
				frame:SetAttribute('type3', 'focus')
			elseif frame:GetAttribute('type3') == 'focus' then
				frame:SetAttribute('type3', nil)
			end
		end

		UF:EnableDisable_Auras(frame)
		UF:Configure_AllAuras(frame)
		UF:Configure_RaidDebuffs(frame)
		UF:Configure_AuraHighlight(frame)
		UF:Configure_AuraWatch(frame)
	end

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

UF.headerstoload.assist = {'MAINASSIST', 'ELVUI_UNITTARGET'}
