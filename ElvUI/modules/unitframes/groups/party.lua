local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")
local tinsert = table.insert
function UF:Construct_PartyFrames(unitGroup)
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)	

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 10)
	
	if self.isChild then
		self.Health = UF:Construct_HealthBar(self, true)
		
		self.Name = UF:Construct_NameText(self)
		self.originalParent = self:GetParent()
	else
		self.menu = UF.SpawnMenu
		
		self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')

		self.Power = UF:Construct_PowerBar(self, true, true, 'LEFT', false)
		self.Power.frequentUpdates = false;
		
		self.Name = UF:Construct_NameText(self)
		self.Buffs = UF:Construct_Buffs(self)
		self.Debuffs = UF:Construct_Debuffs(self)
		self.AuraWatch = UF:Construct_AuraWatch(self)
		self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
		self.ResurrectIcon = UF:Construct_ResurectionIcon(self)
		self.LFDRole = UF:Construct_RoleIcon(self)
		self.TargetGlow = UF:Construct_TargetGlow(self)
		self.RaidRoleFramesAnchor = UF:Construct_RaidRoleFrames(self)
		tinsert(self.__elements, UF.UpdateThreat)
		tinsert(self.__elements, UF.UpdateTargetGlow)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', function(...) UF.UpdateThreat(...); UF.UpdateTargetGlow(...) end)
		self:RegisterEvent('PLAYER_ENTERING_WORLD', UF.UpdateTargetGlow)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', UF.UpdateTargetGlow)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UF.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UF.UpdateThreat)	
		
		self.RaidIcon = UF:Construct_RaidIcon(self)
		self.ReadyCheck = UF:Construct_ReadyCheckIcon(self)
		self.HealPrediction = UF:Construct_HealComm(self)
	end
	
	
	UF:Update_PartyFrames(self, E.db['unitframe']['units']['party'])
	UF:Update_StatusBars()
	UF:Update_FontStrings()	

	return self
end

function UF:Update_PartyHeader(header, db)
	if not header.isForced then
		header:Hide()
		header:SetAttribute('oUF-initialConfigFunction', ([[self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)]]):format(db.width, db.height))
		header:SetAttribute('startingIndex', 1)
	end
	
	header.db = db
	
	--User Error Check
	if UF['badHeaderPoints'][db.point] == db.columnAnchorPoint then
		db.columnAnchorPoint = db.point
		E:Print(L['You cannot set the Group Point and Column Point so they are opposite of each other.'])
	end	
	
	
	if not header.isForced then	
		self:ChangeVisibility(header, 'custom '..db.visibility)
	end
	
	UF['headerGroupBy'][db.groupBy](header)
	header:SetAttribute("groupBy", db.groupBy)
	
	if not header.isForced then
		header:SetAttribute("showParty", db.showParty)
		header:SetAttribute("showRaid", db.showRaid)
		header:SetAttribute("showSolo", db.showSolo)
		header:SetAttribute("showPlayer", db.showPlayer)
	end
	
	header:SetAttribute("maxColumns", db.maxColumns)
	header:SetAttribute("unitsPerColumn", db.unitsPerColumn)
	
	if (db.point == "TOP" or db.point == "BOTTOM") and (db.columnAnchorPoint == "LEFT" or db.columnAnchorPoint == "RIGHT") then
		header:SetAttribute('columnSpacing', db.xOffset)
	else
		header:SetAttribute('columnSpacing', db.yOffset)
	end
	header:SetAttribute("xOffset", db.xOffset)	
	header:SetAttribute("yOffset", db.yOffset)

	
	header:SetAttribute('columnAnchorPoint', db.columnAnchorPoint)
	
	UF:ClearChildPoints(header:GetChildren())
	
	header:SetAttribute('point', db.point)
		
	if not header.positioned then
		header:ClearAllPoints()
		header:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 195)
		
		E:CreateMover(header, header:GetName()..'Mover', L['Party Frames'], nil, nil, nil, 'ALL,PARTY,ARENA')
		
		header:SetAttribute('minHeight', header.dirtyHeight)
		header:SetAttribute('minWidth', header.dirtyWidth)
	
		header:RegisterEvent("PLAYER_ENTERING_WORLD")
		header:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		header:HookScript("OnEvent", UF.PartySmartVisibility)		
		header.positioned = true;
	end		
	
	UF.PartySmartVisibility(header)
end

function UF:PartySmartVisibility(event)
	if not self.db or not self.SetAttribute or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced then return; end
	local inInstance, instanceType = IsInInstance()
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
	if not InCombatLockdown() then		
		if inInstance and instanceType == "raid" then
			RegisterAttributeDriver(self, 'state-visibility', 'hide')
		elseif self.db.visibility then
			UF:ChangeVisibility(self, 'custom '..self.db.visibility)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function UF:Update_PartyFrames(frame, db)
	frame.db = db
	local SPACING = E.Spacing;
	local BORDER = E.Border;
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

	if frame.isChild then
		local childDB = db.petsGroup
		if frame == _G[frame.originalParent:GetName()..'Target'] then
			childDB = db.targetsGroup
		end
		
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
	
		--Health
		do
			local health = frame.Health
			health.Smooth = self.db.smoothbars
			health.frequentUpdates = db.health.frequentUpdates
			
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
			name:ClearAllPoints()
			name:SetPoint('CENTER', frame.Health, 'CENTER')
			frame:Tag(name, '[namecolor][name:short]')
		end			
	else
		if not InCombatLockdown() then
			frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
		end	
	
		--Health
		do
			local health = frame.Health
			health.Smooth = self.db.smoothbars
	
			--Position this even if disabled because resurrection icon depends on the position
			local x, y = self:GetPositionOffset(db.health.position)
			health.value:ClearAllPoints()
			health.value:Point(db.health.position, health, db.health.position, x, y)
			frame:Tag(health.value, db.health.text_format)
			
			health.frequentUpdates = db.health.frequentUpdates
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
			if not db.power.hideonnpc then
				local x, y = self:GetPositionOffset(db.name.position)
				name:ClearAllPoints()
				name:Point(db.name.position, frame.Health, db.name.position, x, y)				
			end
			
			frame:Tag(name, db.name.text_format)
		end	
		
		--Power
		do
			local power = frame.Power
			
			if USE_POWERBAR then
				frame:EnableElement('Power')
				power:Show()		
				power.Smooth = self.db.smoothbars
				
				--Text
				local x, y = self:GetPositionOffset(db.power.position)
				power.value:ClearAllPoints()
				power.value:Point(db.power.position, frame.Health, db.power.position, x, y)		
				frame:Tag(power.value, db.power.text_format)
				
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
					power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(E.PixelMode and 0 or (BORDER + SPACING)))
					power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(BORDER), BORDER)
				end
			else
				frame:DisableElement('Power')
				power:Hide()
				power.value:Hide()
			end
		end
		
		--Target Glow
		do
			local tGlow = frame.TargetGlow
			local SHADOW_SPACING = E.PixelMode and 3 or 4
			tGlow:ClearAllPoints()
			
			tGlow:Point("TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING)
			tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
			
			if USE_MINI_POWERBAR then
				tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING + (POWERBAR_HEIGHT/2))
				tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING + (POWERBAR_HEIGHT/2))		
			else
				tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
				tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
			end
			
			if USE_POWERBAR_OFFSET then
				tGlow:Point("TOPLEFT", -SHADOW_SPACING+POWERBAR_OFFSET, SHADOW_SPACING)
				tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
				tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING+POWERBAR_OFFSET, -SHADOW_SPACING+POWERBAR_OFFSET)
				tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING+POWERBAR_OFFSET)				
			end				
		end		

		--Auras Disable/Enable
		--Only do if both debuffs and buffs aren't being used.
		do
			if db.debuffs.enable or db.buffs.enable then
				frame:EnableElement('Aura')
			else
				frame:DisableElement('Aura')		
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
			
			buffs.forceShow = frame.forceShowAuras
			buffs.num = db.buffs.perrow * rows
			buffs.size = db.buffs.sizeOverride ~= 0 and db.buffs.sizeOverride or ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows)
			
			if db.buffs.sizeOverride and db.buffs.sizeOverride > 0 then
				buffs:SetWidth(db.buffs.perrow * db.buffs.sizeOverride)
			end
			
			local x, y = E:GetXYOffset(db.buffs.anchorPoint)
			local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo)
			
			buffs:Point(E.InversePoints[db.buffs.anchorPoint], attachTo, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find('TOP') and -1 or 1) or 0))
			buffs:Height(buffs.size * rows)
			buffs["growth-y"] = db.buffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
			buffs["growth-x"] = db.buffs.anchorPoint == 'LEFT' and 'LEFT' or  db.buffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.buffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
			buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint]

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
			
			debuffs.forceShow = frame.forceShowAuras
			debuffs.num = db.debuffs.perrow * rows
			debuffs.size = db.debuffs.sizeOverride ~= 0 and db.debuffs.sizeOverride or ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows)
			
			if db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0 then
				debuffs:SetWidth(db.debuffs.perrow * db.debuffs.sizeOverride)
			end
			
			local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
			local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS')
			
			debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], attachTo, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset)
			debuffs:Height(debuffs.size * rows)
			debuffs["growth-y"] = db.debuffs.anchorPoint:find('TOP') and 'UP' or 'DOWN'
			debuffs["growth-x"] = db.debuffs.anchorPoint == 'LEFT' and 'LEFT' or  db.debuffs.anchorPoint == 'RIGHT' and 'RIGHT' or (db.debuffs.anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
			debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint]

			if db.debuffs.enable then			
				debuffs:Show()
			else
				debuffs:Hide()
			end
		end	
		
		--Raid Icon
		do
			local RI = frame.RaidIcon
			if db.raidicon.enable then
				frame:EnableElement('RaidIcon')
				RI:Show()
				RI:Size(db.raidicon.size)
				
				local x, y = self:GetPositionOffset(db.raidicon.attachTo)
				RI:ClearAllPoints()
				RI:Point(db.raidicon.attachTo, frame, db.raidicon.attachTo, x + db.raidicon.xOffset, y + db.raidicon.yOffset)	
			else
				frame:DisableElement('RaidIcon')	
				RI:Hide()
			end
		end			

		--Debuff Highlight
		do
			local dbh = frame.DebuffHighlight
			if E.db.unitframe.debuffHighlighting then
				frame:EnableElement('DebuffHighlight')
			else
				frame:DisableElement('DebuffHighlight')	
			end
		end
		
		--Role Icon
		do
			local role = frame.LFDRole
			if db.roleIcon.enable then
				frame:EnableElement('LFDRole')				
				
				local x, y = self:GetPositionOffset(db.roleIcon.position, 1)
				role:ClearAllPoints()
				role:Point(db.roleIcon.position, frame.Health, db.roleIcon.position, x, y)
			else
				frame:DisableElement('LFDRole')	
				role:Hide()
			end
		end
		
		--OverHealing
		do
			local healPrediction = frame.HealPrediction
			
			if db.healPrediction then
				frame:EnableElement('HealPrediction')
				
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
				frame:DisableElement('HealPrediction')	
			end
		end	
		
		--Raid Roles
		do
			local raidRoleFrameAnchor = frame.RaidRoleFramesAnchor

			if db.raidRoleIcons.enable then
				raidRoleFrameAnchor:Show()
				frame:EnableElement('Leader')
				frame:EnableElement('MasterLooter')
				
				raidRoleFrameAnchor:ClearAllPoints()
				if db.raidRoleIcons.position == 'TOPLEFT' then
					raidRoleFrameAnchor:Point('LEFT', frame, 'TOPLEFT', 2, 0)
				else
					raidRoleFrameAnchor:Point('RIGHT', frame, 'TOPRIGHT', -2, 0)
				end
			else
				raidRoleFrameAnchor:Hide()
				frame:DisableElement('Leader')
				frame:DisableElement('MasterLooter')
			end
		end
		
		UF:UpdateAuraWatch(frame)
	end
	
	frame:EnableElement('ReadyCheck')		
	
	if db.customTexts then
		local customFont = UF.LSM:Fetch("font", UF.db.font)
		for objectName, _ in pairs(db.customTexts) do
			if not frame[objectName] then
				frame[objectName] = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
			end
			
			local objectDB = db.customTexts[objectName]
			UF:CreateCustomTextGroup('party', objectName)
			
			if objectDB.font then
				customFont = UF.LSM:Fetch("font", objectDB.font)
			end
						
			frame[objectName]:FontTemplate(customFont, objectDB.size or UF.db.fontSize, objectDB.fontOutline or UF.db.fontOutline)
			frame:Tag(frame[objectName], objectDB.text_format or '')
			frame[objectName]:SetJustifyH(objectDB.justifyH or 'CENTER')
			frame[objectName]:ClearAllPoints()
			frame[objectName]:SetPoint(objectDB.justifyH or 'CENTER', frame, 'CENTER', objectDB.xOffset, objectDB.yOffset)
		end
	end	
	
	frame:UpdateAllElements()
end

UF['headerstoload']['party'] = {nil, 'ELVUI_UNITPET, ELVUI_UNITTARGET'}