local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:Construct_PetTargetFrame(frame)	
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	
	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT', false)
	
	frame.Name = self:Construct_NameText(frame)
	
	frame.Buffs = self:Construct_Buffs(frame)
	frame.Threat = self:Construct_Threat(frame)
	frame.Debuffs = self:Construct_Debuffs(frame)
	frame.Range = UF:Construct_Range(frame)
	frame:Point('BOTTOM', ElvUF_Pet, 'TOP', 0, 7) --Set to default position
	E:CreateMover(frame, frame:GetName()..'Mover', L['PetTarget Frame'], nil, -7, nil, 'ALL,SOLO')
end

function UF:Update_PetTargetFrame(frame, db)
	frame.db = db
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height
	local SHADOW_SPACING = E.PixelMode and 3 or 4
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width == 'spaced' and USE_POWERBAR
	local USE_INSET_POWERBAR = db.power.width == 'inset' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local POWERBAR_WIDTH = db.width - (BORDER*2)
	
	local unit = self.unit
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	frame.colors = ElvUF.colors
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	_G[frame:GetName()..'Mover']:Size(frame:GetSize())
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
		local x, y = self:GetPositionOffset(db.health.position)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position, health, db.health.position, x + db.health.xOffset, y + db.health.yOffset)
		frame:Tag(health.value, db.health.text_format)
		
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
			health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER+POWERBAR_OFFSET, BORDER+POWERBAR_OFFSET)
		elseif USE_MINI_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		elseif USE_INSET_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER)			
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
	end
	
	--Name
	UF:UpdateNameSettings(frame)
	
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
			local x, y = self:GetPositionOffset(db.power.position)
			power.value:ClearAllPoints()
			power.value:Point(db.power.position, frame.Health, db.power.position, x + db.power.xOffset, y + db.power.yOffset)		
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
				power:Point("TOPLEFT", frame, "TOPLEFT", BORDER, -POWERBAR_OFFSET)
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BORDER, BORDER)
				power:SetFrameStrata("LOW")
				power:SetFrameLevel(2)
			elseif USE_MINI_POWERBAR then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("LEFT", frame, "BOTTOMLEFT", (BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			elseif USE_INSET_POWERBAR then
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", BORDER + (BORDER*2), BORDER + (BORDER*2))
				power:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -(BORDER + (BORDER*2)), BORDER + (BORDER*2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)			
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(E.PixelMode and 0 or (BORDER + SPACING)))
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BORDER, BORDER)
			end
		elseif frame:IsElementEnabled('Power') then
			frame:DisableElement('Power')
			power:Hide()	
		end
	end
	
	--Threat
	do
		local threat = frame.Threat

		if db.threatStyle ~= 'NONE' and db.threatStyle ~= nil then
			if not frame:IsElementEnabled('Threat') then
				frame:EnableElement('Threat')
			end

			if db.threatStyle == "GLOW" then
				threat:SetFrameStrata('BACKGROUND')
				threat.glow:ClearAllPoints()
				threat.glow:SetBackdropBorderColor(0, 0, 0, 0)
				threat.glow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING)
				threat.glow:Point("TOPRIGHT", frame.Health.backdrop, "TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
				threat.glow:Point("BOTTOMLEFT", frame.Power.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
				threat.glow:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)	
				
				if USE_MINI_POWERBAR or USE_POWERBAR_OFFSET or USE_INSET_POWERBAR then
					threat.glow:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
					threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)	
				end
			elseif db.threatStyle == "ICONTOPLEFT" or db.threatStyle == "ICONTOPRIGHT" or db.threatStyle == "ICONBOTTOMLEFT" or db.threatStyle == "ICONBOTTOMRIGHT" or db.threatStyle == "ICONTOP" or db.threatStyle == "ICONBOTTOM" or db.threatStyle == "ICONLEFT" or db.threatStyle == "ICONRIGHT" then
				threat:SetFrameStrata('HIGH')
				local point = db.threatStyle
				point = point:gsub("ICON", "")
				
				threat.texIcon:ClearAllPoints()
				threat.texIcon:SetPoint(point, frame.Health, point)
			end
		elseif frame:IsElementEnabled('Threat') then
			frame:DisableElement('Threat')
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
			UF:UpdateAuraIconSettings(buffs)
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
			UF:UpdateAuraIconSettings(debuffs)
		else
			debuffs:Hide()
		end
	end	
	
	--Range
	do
		local range = frame.Range
		if db.rangeCheck then
			if not frame:IsElementEnabled('Range') then
				frame:EnableElement('Range')
			end

			range.outsideAlpha = E.db.unitframe.OORAlpha
		else
			if frame:IsElementEnabled('Range') then
				frame:DisableElement('Range')
			end				
		end
	end		
	
	if db.customTexts then
		local customFont = UF.LSM:Fetch("font", UF.db.font)
		for objectName, _ in pairs(db.customTexts) do
			if not frame[objectName] then
				frame[objectName] = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
			end
			
			local objectDB = db.customTexts[objectName]

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
	
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg)
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg)		
		
	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'pettarget')