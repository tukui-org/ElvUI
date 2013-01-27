local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_AssistFrames(unitGroup)
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)	
	
	self.menu = UF.SpawnMenu

	self.Health = UF:Construct_HealthBar(self, true)
	self.Name = UF:Construct_NameText(self)

	self.__elements["Threat"] = UF.UpdateThreat
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UF.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UF.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UF.UpdateThreat)		
	
	self.RaidIcon = UF:Construct_RaidIcon(self)
	
	UF:Update_AssistFrames(self, E.db['unitframe']['units']['assist'])
	UF:Update_StatusBars()
	UF:Update_FontStrings()	
	
	self.originalParent = self:GetParent()
	
	return self
end

function UF:Update_AssistHeader(header, db)
	header:Hide()
	header:SetAttribute('oUF-initialConfigFunction', ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.width, db.height))
	header.db = db
	
	UF:ClearChildPoints(header:GetChildren())
	
	if not header.mover then
		self:ChangeVisibility(header, 'custom show') --fucking retarded bug fix
	end
	
	self:ChangeVisibility(header, 'raid')

	header:SetAttribute("showRaid", true)
	header:SetAttribute('groupFilter', 'MAINASSIST')
	header:SetAttribute('point', 'BOTTOM')
	
	header:SetAttribute('columnAnchorPoint', 'TOP')

	UF:ClearChildPoints(header:GetChildren())
	header:SetAttribute("yOffset", 7)

	header:SetAttribute('columnAnchorPoint', 'TOP')
	header:SetAttribute('point', 'BOTTOM')

	if not header.positioned then
		header:ClearAllPoints()
		header:Point("LEFT", E.UIParent, "LEFT", 6, 100)
		E:CreateMover(header, header:GetName()..'Mover', L['MA Frames'], nil, nil, nil, 'ALL,RAID10,RAID25,RAID40')
		
		header:SetAttribute('minHeight', header.dirtyHeight)
		header:SetAttribute('minWidth', header.dirtyWidth)

		header.positioned = true;
	end	
end

function UF:Update_AssistFrames(frame, db)
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	
	frame.colors = ElvUF.colors
	frame.Range = {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}

	if frame.isChild and frame.originalParent then
		local childDB = db.targetsGroup
		frame.db = db.targetsGroup
		if not frame.originalParent.childList then
			frame.originalParent.childList = {}
		end	
		frame.originalParent.childList[frame] = true;
		
		if not InCombatLockdown() then
			if childDB.enable then
				frame:SetParent(frame.originalParent)
				frame:Size(childDB.width, childDB.height)
				frame:ClearAllPoints()
				frame:Point(E.InversePoints[childDB.anchorPoint], frame.originalParent, childDB.anchorPoint, childDB.xOffset, childDB.yOffset)
			else
				frame:SetParent(E.HiddenFrame)
			end
		end	
	elseif not InCombatLockdown() then
		frame.db = db
		frame:Size(db.width, db.height)
	end
	
	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars
		
		--Colors
		health.colorSmooth = nil
		health.colorHealth = nil
		health.colorClass = nil
		health.colorReaction = nil
		if self.db['colors'].healthclass ~= true then
			if self.db['colors'].colorhealthbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end		
		else
			health.colorClass = true
			health.colorReaction = true
		end	
		
		--Position
		health:ClearAllPoints()
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER)
	end
	
	--Name
	do
		local name = frame.Name
		name:Point('CENTER', frame.Health, 'CENTER')
		if UF.db.colors.healthclass then
			frame:Tag(name, '[name:medium]')
		else
			frame:Tag(name, '[namecolor][name:medium]')
		end
	end	
	
	frame:UpdateAllElements()
end

UF['headerstoload']['assist'] = {'MAINASSIST', 'ELVUI_UNITTARGET'}