local E, L, DF = unpack(select(2, ...)); --Engine
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_Raid2640Frames(unitGroup)
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)	
	
	self.menu = UF.SpawnMenu

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Health.frequentUpdates = true;
	
	self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT', false)
	self.Name = UF:Construct_NameText(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
	self.ResurrectIcon = UF:Construct_ResurectionIcon(self)
	
	table.insert(self.__elements, UF.UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UF.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UF.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UF.UpdateThreat)	

	self.RaidIcon = UF:Construct_RaidIcon(self)
	self.ReadyCheck = UF:Construct_ReadyCheckIcon(self)	
	self.HealPrediction = UF:Construct_HealComm(self)
	
	UF:Update_Raid2640Frames(self, E.db['unitframe']['layouts'][UF.ActiveLayout]['raid2640'])
	UF:Update_StatusBars()
	UF:Update_FontStrings()	
	
	return self
end

function UF:Raid2640SmartVisibility(event)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if not InCombatLockdown() then		
		if inInstance and instanceType == "raid" and maxPlayers ~= 40 and UF.db and UF.db.smartRaidFilter and self.SetAttribute then
			self:SetAttribute("showRaid", false)
			self:SetAttribute("showParty", false)			
		elseif self.SetAttribute and self.db and self.db.showParty and self.db.enable then
			self:SetAttribute("showParty", self.db.showParty)
			self:SetAttribute("showRaid", self.db.showRaid)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	
	UF:UpdateGroupChildren(self, self.db)
end

function UF:Update_Raid2640Header(header, db)
	header:Hide()
	header.db = db
	header:SetAttribute('oUF-initialConfigFunction', ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.width, db.height))
	
	--User Error Check
	if UF['badHeaderPoints'][db.point] == db.columnAnchorPoint then
		db.columnAnchorPoint = db.point
		E:Print(L['You cannot set the Group Point and Column Point so they are opposite of each other.'])
	end
	
	UF:ClearChildPoints(header:GetChildren())
	
	if not header.mover then
		self:ChangeVisibility(header, 'custom [@raid6,exists] hide;show') --fucking retarded bug fix
	end
	
	self:ChangeVisibility(header, 'custom '..db.visibility)
	
	if db.groupBy == 'CLASS' then
		header:SetAttribute("groupingOrder", "DEATHKNIGHT, DRUID, HUNTER, MAGE, PALADIN, PRIEST, SHAMAN, WARLOCK, WARRIOR")
	elseif db.groupBy == 'ROLE' then
		header:SetAttribute("groupingOrder", "TANK, HEALER, DAMAGE")
	else
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
	end
	
	header:SetAttribute("groupBy", db.groupBy)

	header:SetAttribute("showParty", db.showParty)
	header:SetAttribute("showRaid", db.showRaid)
	header:SetAttribute("showSolo", db.showSolo)
	header:SetAttribute("showPlayer", db.showPlayer)
	
	header:SetAttribute('point', db.point)
	
	header:SetAttribute('columnAnchorPoint', db.columnAnchorPoint)
	header:SetAttribute("maxColumns", db.maxColumns)
	header:SetAttribute("unitsPerColumn", db.unitsPerColumn)

	UF:ClearChildPoints(header:GetChildren())
	header:SetAttribute('columnSpacing', db.columnSpacing)
	header:SetAttribute("xOffset", db.xOffset)	
	header:SetAttribute("yOffset", db.yOffset)
	
	header:SetAttribute('columnAnchorPoint', db.columnAnchorPoint)
	header:SetAttribute('point', db.point)

	if not header.mover then
		header:ClearAllPoints()
		header:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 195)
		
		header:RegisterEvent("PLAYER_ENTERING_WORLD")
		header:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		header:HookScript("OnEvent", UF.Raid2640SmartVisibility)		
	end
	
	UF.Raid2640SmartVisibility(header)
end

function UF:Update_Raid2640Frames(frame, db)
	frame.db = db
	local BORDER = E:Scale(2)
	local SPACING = E:Scale(1)
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height
	
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width ~= 'fill' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local POWERBAR_WIDTH = db.width - (BORDER*2)
	
	frame.db = db
	frame.colors = ElvUF.colors
	if not InCombatLockdown() then
		frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	end
	frame.Range = {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}
	
	--Adjust some variables
	do
		if not USE_POWERBAR then
			POWERBAR_HEIGHT = 0
		end	
	
		if USE_MINI_POWERBAR then
			POWERBAR_WIDTH = POWERBAR_WIDTH / 2
		end
	end
	
	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars

		--Text
		if db.health.text then
			health.value:Show()
		else
			health.value:Hide()
		end
		
		--Position this even if disabled because resurrection icon depends on the position
		local x, y = self:GetPositionOffset(db.health.position)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position, health, db.health.position, x, y)
		
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
		if USE_POWERBAR_OFFSET then			
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER+POWERBAR_OFFSET, BORDER+POWERBAR_OFFSET)
		elseif USE_MINI_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		
		health:SetOrientation(db.health.orientation)
	end
	
	--Name
	do
		local name = frame.Name
		if db.name.enable then
			name:Show()
			
			if not db.power.hideonnpc then
				local x, y = self:GetPositionOffset(db.name.position)
				name:ClearAllPoints()
				name:Point(db.name.position, frame.Health, db.name.position, x, y)				
			end
		else
			name:Hide()
		end
	end	
	
	--Power
	do
		local power = frame.Power
		
		if USE_POWERBAR then
			if not frame:IsElementEnabled('Power') then
				frame:EnableElement('Power')
				power:Show()
			end				
			power.Smooth = self.db.smoothbars
			
			--Text
			if db.power.text then
				power.value:Show()
				
				local x, y = self:GetPositionOffset(db.power.position)
				power.value:ClearAllPoints()
				power.value:Point(db.power.position, frame.Health, db.power.position, x, y)			
			else
				power.value:Hide()
			end
			
			--Colors
			power.colorClass = nil
			power.colorReaction = nil	
			power.colorPower = nil
			if self.db['colors'].powerclass then
				power.colorClass = true
				power.colorReaction = true
			else
				power.colorPower = true
			end		
			
			--Position
			power:ClearAllPoints()
			if USE_POWERBAR_OFFSET then
				power:Point("TOPLEFT", frame.Health, "TOPLEFT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:SetFrameStrata("LOW")
				power:SetFrameLevel(2)
			elseif USE_MINI_POWERBAR then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("LEFT", frame, "BOTTOMLEFT", (BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(BORDER), BORDER)
			end
		else
			if frame:IsElementEnabled('Power') then
				frame:DisableElement('Power')
				power:Hide()
				power.value:Hide()
			end
		end
	end

	--Auras Disable/Enable
	--Only do if both debuffs and buffs aren't being used.
	do
		if db.debuffs.enable or db.buffs.enable then
			if not frame:IsElementEnabled('Aura') then
				frame:EnableElement('Aura')
			end	
		else
			if frame:IsElementEnabled('Aura') then
				frame:DisableElement('Aura')
			end			
		end
		
		frame.Buffs:ClearAllPoints()
		frame.Debuffs:ClearAllPoints()
	end
	
	--Buffs
	do
		local buffs = frame.Buffs
		local rows = db.buffs.numrows
		
		if USE_POWERBAR_OFFSET then
			buffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			buffs:SetWidth(UNIT_WIDTH)
		end
		
		if db.buffs.initialAnchor == "RIGHT" or db.buffs.initialAnchor == "LEFT" then
			rows = 1;
			buffs:SetWidth(UNIT_WIDTH / 2)
		end
		
		buffs.num = db.buffs.perrow * rows
		buffs.size = ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows)

		local x, y = self:GetAuraOffset(db.buffs.initialAnchor, db.buffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo, db.debuffs.attachTo)

		buffs:Point(db.buffs.initialAnchor, attachTo, db.buffs.anchorPoint, x, y)
		buffs:Height(buffs.size * rows)
		buffs.initialAnchor = db.buffs.initialAnchor
		buffs["growth-y"] = db.buffs['growth-y']
		buffs["growth-x"] = db.buffs['growth-x']

		if db.buffs.enable then			
			buffs:Show()
		else
			buffs:Hide()
		end
	end
	
	--Debuffs
	do
		local debuffs = frame.Debuffs
		local rows = db.debuffs.numrows
		
		if USE_POWERBAR_OFFSET then
			debuffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			debuffs:SetWidth(UNIT_WIDTH)
		end
		
		if db.debuffs.initialAnchor == "RIGHT" or db.debuffs.initialAnchor == "LEFT" then
			rows = 1;
			debuffs:SetWidth(UNIT_WIDTH / 2)
		end
		
		debuffs.num = db.debuffs.perrow * rows
		debuffs.size = ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows)

		local x, y = self:GetAuraOffset(db.debuffs.initialAnchor, db.debuffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.buffs.attachTo)

		debuffs:Point(db.debuffs.initialAnchor, attachTo, db.debuffs.anchorPoint, x, y)
		debuffs:Height(debuffs.size * rows)
		debuffs.initialAnchor = db.debuffs.initialAnchor
		debuffs["growth-y"] = db.debuffs['growth-y']
		debuffs["growth-x"] = db.debuffs['growth-x']

		if db.debuffs.enable then			
			debuffs:Show()
		else
			debuffs:Hide()
		end
	end	
	
	--Debuff Highlight
	do
		local dbh = frame.DebuffHighlight
		if E.db.unitframe.debuffHighlighting then
			if not frame:IsElementEnabled('DebuffHighlight') then
				frame:EnableElement('DebuffHighlight')
			end
		else
			if frame:IsElementEnabled('DebuffHighlight') then
				frame:DisableElement('DebuffHighlight')
			end		
		end
	end

	--OverHealing
	do
		local healPrediction = frame.HealPrediction
		
		if db.healPrediction then
			if not frame:IsElementEnabled('HealPrediction') then
				frame:EnableElement('HealPrediction')
			end
			
			healPrediction.myBar:ClearAllPoints()
			healPrediction.myBar:SetOrientation(db.health.orientation)
			healPrediction.otherBar:ClearAllPoints()
			healPrediction.otherBar:SetOrientation(db.health.orientation)
			
			if db.health.orientation == 'HORIZONTAL' then
				healPrediction.myBar:Width(db.width - (BORDER*2))
				healPrediction.myBar:SetPoint('BOTTOMLEFT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				healPrediction.myBar:SetPoint('TOPLEFT', frame.Health:GetStatusBarTexture(), 'TOPRIGHT')	

				healPrediction.otherBar:SetPoint('TOPLEFT', healPrediction.myBar:GetStatusBarTexture(), 'TOPRIGHT')	
				healPrediction.otherBar:SetPoint('BOTTOMLEFT', healPrediction.myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')	
				healPrediction.otherBar:Width(db.width - (BORDER*2))
			else
				healPrediction.myBar:Height(db.height - (BORDER*2))
				healPrediction.myBar:SetPoint('BOTTOMLEFT', frame.Health:GetStatusBarTexture(), 'TOPLEFT')
				healPrediction.myBar:SetPoint('BOTTOMRIGHT', frame.Health:GetStatusBarTexture(), 'TOPRIGHT')				

				healPrediction.otherBar:SetPoint('BOTTOMLEFT', healPrediction.myBar:GetStatusBarTexture(), 'TOPLEFT')
				healPrediction.otherBar:SetPoint('BOTTOMRIGHT', healPrediction.myBar:GetStatusBarTexture(), 'TOPRIGHT')				
				healPrediction.otherBar:Height(db.height - (BORDER*2))	
			end
			
		else
			if frame:IsElementEnabled('HealPrediction') then
				frame:DisableElement('HealPrediction')
			end		
		end
	end	
	
	UF:UpdateAuraWatch(frame)
	if not frame:IsElementEnabled('ReadyCheck') then
		frame:EnableElement('ReadyCheck')
	end		
	frame:UpdateAllElements()
end

UF['headerstoload']['raid2640'] = true