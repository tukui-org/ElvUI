local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")
local tinsert = table.insert

function UF:Construct_RaidpetFrames(unitGroup)
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.RaisedElementParent = CreateFrame('Frame', nil, self)
	self.RaisedElementParent:SetFrameStrata("MEDIUM")
	self.RaisedElementParent:SetFrameLevel(self:GetFrameLevel() + 10)

	self.Health = UF:Construct_HealthBar(self, true, true, 'RIGHT')
	self.Name = UF:Construct_NameText(self)
	self.Buffs = UF:Construct_Buffs(self)
	self.Debuffs = UF:Construct_Debuffs(self)
	self.AuraWatch = UF:Construct_AuraWatch(self)
	self.RaidDebuffs = UF:Construct_RaidDebuffs(self)
	self.DebuffHighlight = UF:Construct_DebuffHighlight(self)
	self.TargetGlow = UF:Construct_TargetGlow(self)
	tinsert(self.__elements, UF.UpdateTargetGlow)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', UF.UpdateTargetGlow)
	self:RegisterEvent('PLAYER_ENTERING_WORLD', UF.UpdateTargetGlow)

	self.Threat = UF:Construct_Threat(self)
	self.RaidIcon = UF:Construct_RaidIcon(self)
	self.HealPrediction = UF:Construct_HealComm(self)
	self.Range = UF:Construct_Range(self)
	self.customTexts = {}

	UF:Update_StatusBars()
	UF:Update_FontStrings()

	return self
end

--I don't know if this function is needed or not? But the error I pm'ed you about was because of the missing OnEvent so I just added it.
function UF:RaidPetsSmartVisibility(event)
	if not self.db or (self.db and not self.db.enable) or (UF.db and not UF.db.smartRaidFilter) or self.isForced then return; end
	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

	if not InCombatLockdown() then
		local inInstance, instanceType = IsInInstance()
		if inInstance and instanceType == "raid" then
			UnregisterStateDriver(self, "visibility")
			self:Show()
		elseif self.db.visibility then
			RegisterStateDriver(self, "visibility", self.db.visibility)
		end
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
end

function UF:Update_RaidpetHeader(header, db)
	header.db = db

	local headerHolder = header:GetParent()
	headerHolder.db = db

	if not headerHolder.positioned then
		headerHolder:ClearAllPoints()
		headerHolder:Point("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 4, 574)

		E:CreateMover(headerHolder, headerHolder:GetName()..'Mover', L["Raid Pet Frames"], nil, nil, nil, 'ALL,RAID')
		headerHolder.positioned = true;

		headerHolder:RegisterEvent("PLAYER_ENTERING_WORLD")
		headerHolder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		headerHolder:SetScript("OnEvent", UF['RaidPetsSmartVisibility'])
	end

	UF.RaidPetsSmartVisibility(headerHolder)
end

function UF:Update_RaidpetFrames(frame, db)
	frame.db = db
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local SHADOW_SPACING = E.PixelMode and 3 or 4
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height

	frame.colors = ElvUF.colors
	frame:RegisterForClicks(self.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')

	if not InCombatLockdown() then
		frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	end
	frame.Range = {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}
	if not frame:IsElementEnabled('Range') then
		frame:EnableElement('Range')
	end

	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars
		health.frequentUpdates = db.health.frequentUpdates

		--Position this even if disabled because resurrection icon depends on the position
		local x, y = self:GetPositionOffset(db.health.position)
		health.value:ClearAllPoints()
		health.value:Point(db.health.position, health, db.health.position, x + db.health.xOffset, y + db.health.yOffset)
		frame:Tag(health.value, db.health.text_format)

		--Colors
		health.colorSmooth = nil
		health.colorHealth = nil
		health.colorClass = nil
		health.colorReaction = nil

		if db.colorOverride == "FORCE_ON" then
			health.colorClass = true
			health.colorReaction = true
		elseif db.colorOverride == "FORCE_OFF" then
			if self.db['colors'].colorhealthbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
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

			if self.db['colors'].forcehealthreaction == true then
				health.colorClass = false
				health.colorReaction = true
			end
		end

		--Position
		health:ClearAllPoints()
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)
		health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER)

		health:SetOrientation(db.health.orientation)
	end

	--Name
	UF:UpdateNameSettings(frame)

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
				threat.glow:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
				threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
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

	--Target Glow
	do
		local tGlow = frame.TargetGlow
		tGlow:ClearAllPoints()
		tGlow:Point("TOPLEFT", -SHADOW_SPACING, SHADOW_SPACING)
		tGlow:Point("TOPRIGHT", SHADOW_SPACING, SHADOW_SPACING)
		tGlow:Point("BOTTOMLEFT", -SHADOW_SPACING, -SHADOW_SPACING)
		tGlow:Point("BOTTOMRIGHT", SHADOW_SPACING, -SHADOW_SPACING)
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

		buffs:SetWidth(UNIT_WIDTH)

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

		debuffs:SetWidth(UNIT_WIDTH)

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

	--RaidDebuffs
	do
		local rdebuffs = frame.RaidDebuffs
		local stackColor = db.rdebuffs.stack.color
		local durationColor = db.rdebuffs.duration.color
		if db.rdebuffs.enable then
			local rdebuffsFont = UF.LSM:Fetch("font", db.rdebuffs.font)
			frame:EnableElement('RaidDebuffs')

			rdebuffs:Size(db.rdebuffs.size)
			rdebuffs:Point('BOTTOM', frame, 'BOTTOM', db.rdebuffs.xOffset, db.rdebuffs.yOffset)
			
			rdebuffs.count:FontTemplate(rdebuffsFont, db.rdebuffs.fontSize, db.rdebuffs.fontOutline)
			rdebuffs.count:ClearAllPoints()
			rdebuffs.count:Point(db.rdebuffs.stack.position, db.rdebuffs.stack.xOffset, db.rdebuffs.stack.yOffset)
			rdebuffs.count:SetTextColor(stackColor.r, stackColor.g, stackColor.b)
			
			rdebuffs.time:FontTemplate(rdebuffsFont, db.rdebuffs.fontSize, db.rdebuffs.fontOutline)
			rdebuffs.time:ClearAllPoints()
			rdebuffs.time:Point(db.rdebuffs.duration.position, db.rdebuffs.duration.xOffset, db.rdebuffs.duration.yOffset)
			rdebuffs.time:SetTextColor(durationColor.r, durationColor.g, durationColor.b)
		else
			frame:DisableElement('RaidDebuffs')
			rdebuffs:Hide()
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
		if E.db.unitframe.debuffHighlighting ~= 'NONE' then
			frame:EnableElement('DebuffHighlight')
			frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors

			if E.db.unitframe.debuffHighlighting == 'GLOW' then
				frame.DebuffHighlightBackdrop = true
				frame.DBHGlow:SetAllPoints(frame.Threat.glow)
			else
				frame.DebuffHighlightBackdrop = false
			end					
		else
			frame:DisableElement('DebuffHighlight')
		end
	end

	--OverHealing
	do
		local healPrediction = frame.HealPrediction
		local c = UF.db.colors.healPrediction
		if db.healPrediction then
			if not frame:IsElementEnabled('HealPrediction') then
				frame:EnableElement('HealPrediction')
			end

			healPrediction.myBar:SetOrientation(db.health.orientation)
			healPrediction.otherBar:SetOrientation(db.health.orientation)
			healPrediction.absorbBar:SetOrientation(db.health.orientation)

			healPrediction.myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
			healPrediction.otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
			healPrediction.absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		else
			if frame:IsElementEnabled('HealPrediction') then
				frame:DisableElement('HealPrediction')
			end
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

	--BuffIndicator
	UF:UpdateAuraWatch(frame, true) --2nd argument is the petOverride

	--CustomTexts
	for objectName, object in pairs(frame.customTexts) do
		if (not db.customTexts) or (db.customTexts and not db.customTexts[objectName]) then
			object:Hide()
			frame.customTexts[objectName] = nil
		end
	end

	if db.customTexts then
		local customFont = UF.LSM:Fetch("font", UF.db.font)
		for objectName, _ in pairs(db.customTexts) do
			if not frame.customTexts[objectName] then
				frame.customTexts[objectName] = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
			end

			local objectDB = db.customTexts[objectName]

			if objectDB.font then
				customFont = UF.LSM:Fetch("font", objectDB.font)
			end

			frame.customTexts[objectName]:FontTemplate(customFont, objectDB.size or UF.db.fontSize, objectDB.fontOutline or UF.db.fontOutline)
			frame:Tag(frame.customTexts[objectName], objectDB.text_format or '')
			frame.customTexts[objectName]:SetJustifyH(objectDB.justifyH or 'CENTER')
			frame.customTexts[objectName]:ClearAllPoints()
			frame.customTexts[objectName]:SetPoint(objectDB.justifyH or 'CENTER', frame, objectDB.justifyH or 'CENTER', objectDB.xOffset, objectDB.yOffset)
		end
	end

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentHealth, frame.Health, frame.Health.bg, true)

	frame:UpdateAllElements()
end

--Added an additional argument at the end, specifying the header Template we want to use
UF['headerstoload']['raidpet'] = {nil, 'ELVUI_UNITPET', 'SecureGroupPetHeaderTemplate'}
