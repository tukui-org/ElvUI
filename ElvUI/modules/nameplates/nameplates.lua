local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

function mod:ClassBar_Update(frame)
	if(not self.ClassBar) then return end
	local targetFrame = C_NamePlate.GetNamePlateForUnit("target")
	
	if(UnitIsUnit(frame.unit, "target") or self.PlayerFrame) then
		if(frame.IsFriendly and not self.PlayerFrame) then
			self.ClassBar:Hide()
		else
			if(self.PlayerFrame) then
				frame = self.PlayerFrame.UnitFrame
			end

			self.ClassBar:SetParent(frame)
			self.ClassBar:ClearAllPoints()
			if(frame.hasAnAura) then
				self.ClassBar:SetPoint("BOTTOM", frame.HealthBar, "TOP", 0, 30)
			else
				self.ClassBar:SetPoint("BOTTOM", frame.HealthBar, "TOP", 0, 13)
			end
			self.ClassBar:Show()
		end
	elseif(not targetFrame) then
		self.ClassBar:Hide()
	end	
end

function mod:SetTargetFrame(frame)
	--Match parent's frame level for targetting purposes. Best time to do it is here.
	local parent = C_NamePlate.GetNamePlateForUnit(frame.unit);
	frame:SetFrameLevel(parent:GetFrameLevel())
	
	
	if(UnitIsUnit(frame.unit, "target") and not frame.isTarget) then
		if(frame.HealthBar.grow:IsPlaying()) then
			frame.HealthBar.grow:Stop()
		end	
		frame.HealthBar.grow.width:SetChange(self.db.healthbar.width  * self.db.targetScale)
		frame.HealthBar.grow.height:SetChange(self.db.healthbar.height * self.db.targetScale)	
		frame.HealthBar.grow:Play()
		frame.HealthBar.scale = self.db.targetScale
		frame.isTarget = true
	elseif (frame.isTarget) then
		if(frame.HealthBar.grow:IsPlaying()) then
			frame.HealthBar.grow:Stop()
		end	
		frame.HealthBar.grow.width:SetChange(self.db.healthbar.width)
		frame.HealthBar.grow.height:SetChange(self.db.healthbar.height)			
		frame.HealthBar.grow:Play()
		frame.HealthBar.scale = 1
		frame.isTarget = nil
	end
	
	mod:ClassBar_Update(frame)
end

function mod:StyleFrame(frame, useBackdrop)
	local parent = frame
	if(parent:GetObjectType() == "Texture") then
		parent = frame:GetParent()
	end
	if(useBackdrop) then
		frame.backdropTex = parent:CreateTexture(nil, "BACKGROUND")
		frame.backdropTex:SetAllPoints()
		frame.backdropTex:SetColorTexture(0.1, 0.1, 0.1, 0.85)
	end
	
	frame.top = parent:CreateTexture(nil, "BORDER")
	frame.top:SetPoint("TOPLEFT", frame, "TOPLEFT", -self.mult, self.mult)
	frame.top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", self.mult, self.mult)
	frame.top:SetHeight(self.mult)
	frame.top:SetColorTexture(0, 0, 0, 1)
	frame.top:SetDrawLayer("BORDER", 1)

	frame.bottom = parent:CreateTexture(nil, "BORDER")
	frame.bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -self.mult, -self.mult)
	frame.bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", self.mult, -self.mult)
	frame.bottom:SetHeight(self.mult)
	frame.bottom:SetColorTexture(0, 0, 0, 1)
	frame.bottom:SetDrawLayer("BORDER", 1)

	frame.left = parent:CreateTexture(nil, "BORDER")
	frame.left:SetPoint("TOPLEFT", frame, "TOPLEFT", -self.mult, self.mult)
	frame.left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.mult, -self.mult)
	frame.left:SetWidth(self.mult)
	frame.left:SetColorTexture(0, 0, 0, 1)
	frame.left:SetDrawLayer("BORDER", 1)

	frame.right = parent:CreateTexture(nil, "BORDER")
	frame.right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", self.mult, self.mult)
	frame.right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -self.mult, -self.mult)
	frame.right:SetWidth(self.mult)
	frame.right:SetColorTexture(0, 0, 0, 1)
	frame.right:SetDrawLayer("BORDER", 1)
end


function mod:DISPLAY_SIZE_CHANGED()
	self.mult = E.mult --[[* UIParent:GetScale()]]	
end

function mod:NAME_PLATE_UNIT_ADDED(event, unit)
	local frame = C_NamePlate.GetNamePlateForUnit(unit);
	frame.UnitFrame.unit = unit
	frame.UnitFrame.IsFriendly = UnitIsFriend(unit, "player")
	frame.UnitFrame.IsEnemy = not frame.UnitFrame.IsFriendly
	frame.UnitFrame.IsPlayer = UnitIsPlayer(unit)
	frame.UnitFrame.IsFriendlyPlayer = frame.UnitFrame.IsFriendly and frame.UnitFrame.IsPlayer
	frame.UnitFrame.IsEnemyPlayer = not frame.UnitFrame.IsFriendly and frame.UnitFrame.IsPlayer
	frame.UnitFrame.IsFriendlyNPC = frame.UnitFrame.IsFriendly and not frame.UnitFrame.IsPlayer
	frame.UnitFrame.IsEnemyNPC = not frame.UnitFrame.IsFriendly and not frame.UnitFrame.IsPlayer
	frame.UnitFrame.IsPlayerFrame = UnitIsUnit(unit, "player")
	if(frame.UnitFrame.IsPlayerFrame) then
		mod.PlayerFrame = frame
	end
	self:RegisterEvents(frame.UnitFrame, unit)
	self:UpdateElement_All(frame.UnitFrame, unit)
	frame.UnitFrame:Show()
end

function mod:NAME_PLATE_UNIT_REMOVED(event, unit)
	local frame = C_NamePlate.GetNamePlateForUnit(unit);
	frame.UnitFrame.unit = nil
	
	if(frame.UnitFrame.IsPlayerFrame) then
		mod.PlayerFrame = nil
	end
	
	frame.UnitFrame.PowerBar:Hide()
	frame.UnitFrame:UnregisterAllEvents()
	frame.UnitFrame:Hide()
	frame.UnitFrame.isTarget = nil
	frame.ThreatData = nil
	frame.UnitFrame.IsFriendly = nil
	frame.UnitFrame.IsEnemy = nil
	frame.UnitFrame.IsPlayer = nil
	frame.UnitFrame.IsFriendlyPlayer = nil
	frame.UnitFrame.IsEnemyPlayer = nil
	frame.UnitFrame.IsFriendlyNPC = nil
	frame.UnitFrame.IsEnemyNPC = nil
	frame.UnitFrame.IsPlayerFrame = nil	
end

function mod:ForEachPlate(functionToRun, ...)
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if(frame) then
			self[functionToRun](frame.UnitFrame, ...)
		end
	end
end

function mod:SetBaseNamePlateSize()
	local self = mod
	local baseWidth = self.db.healthbar.width
	local baseHeight = self.db.castbar.height + self.db.healthbar.height + 30
	NamePlateDriverFrame:SetBaseNamePlateSize(baseWidth, baseHeight)
end

function mod:UpdateElement_All(frame, unit)
	mod:UpdateElement_MaxHealth(frame)
	mod:UpdateElement_Health(frame)
	mod:UpdateElement_HealthColor(frame)
	mod:UpdateElement_Name(frame)
	mod:UpdateElement_Level(frame)
	mod:UpdateElement_Glow(frame)
	mod:UpdateElement_Cast(frame)
	mod:UpdateElement_Auras(frame)
	mod:UpdateElement_RaidIcon(frame)
	
	if(frame.IsPlayerFrame) then
		frame.PowerBar:Show()
		mod.OnEvent(frame, "UNIT_DISPLAYPOWER", "player")
	end
	
	mod:SetTargetFrame(frame)
end

function mod:NAME_PLATE_CREATED(event, frame)
	frame.UnitFrame = CreateFrame("BUTTON", frame:GetName().."UnitFrame", UIParent);
	frame.UnitFrame:EnableMouse(false);
	frame.UnitFrame:SetAllPoints(frame)
	frame.UnitFrame:SetFrameStrata("BACKGROUND")
	frame.UnitFrame:SetScript("OnEvent", mod.OnEvent)

	
	frame.UnitFrame.HealthBar = self:ConstructElement_HealthBar(frame.UnitFrame)
	self:ConfigureElement_HealthBar(frame.UnitFrame)
	
	frame.UnitFrame.PowerBar = self:ConstructElement_PowerBar(frame.UnitFrame)
	self:ConfigureElement_PowerBar(frame.UnitFrame)
	
	frame.UnitFrame.CastBar = self:ConstructElement_CastBar(frame.UnitFrame)
	self:ConfigureElement_CastBar(frame.UnitFrame)
	
	frame.UnitFrame.Level = self:ConstructElement_Level(frame.UnitFrame)
	self:ConfigureElement_Level(frame.UnitFrame)
	
	frame.UnitFrame.Name = self:ConstructElement_Name(frame.UnitFrame)
	self:ConfigureElement_Name(frame.UnitFrame)
	
	frame.UnitFrame.Glow = self:ConstructElement_Glow(frame.UnitFrame)
	self:ConfigureElement_Glow(frame.UnitFrame)
	
	frame.UnitFrame.Buffs = self:ConstructElement_Auras(frame.UnitFrame, 3, "LEFT")
	frame.UnitFrame.Debuffs = self:ConstructElement_Auras(frame.UnitFrame, 3, "RIGHT")
	
	frame.UnitFrame.RaidIcon = self:ConstructElement_RaidIcon(frame.UnitFrame)
end

function mod:OnEvent(event, unit, ...)
	if(event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT") then
		mod:UpdateElement_Health(self)
	elseif(event == "UNIT_MAXHEALTH") then
		mod:UpdateElement_MaxHealth(self)
	elseif(event == "UNIT_NAME_UPDATE") then
		mod:UpdateElement_Name(self)
		mod:UpdateElement_HealthColor(self) --Unit class sometimes takes a bit to load
	elseif(event == "UNIT_LEVEL") then
		mod:UpdateElement_Level(self)
	elseif(event == "UNIT_THREAT_LIST_UPDATE") then
		mod:Update_ThreatList(self)
		mod:UpdateElement_HealthColor(self)
		mod:UpdateElement_Glow(self)
	elseif(event == "PLAYER_TARGET_CHANGED") then
		mod:SetTargetFrame(self)
		mod:UpdateElement_Glow(self)
	elseif(event == "UNIT_AURA") then
		mod:UpdateElement_Auras(self)
		if(self.IsPlayerFrame) then
			mod:ClassBar_Update(self)
		end
	elseif(event == "RAID_TARGET_UPDATE") then
		mod:UpdateElement_RaidIcon(self)
	elseif(event == "UNIT_MAXPOWER") then
		mod:UpdateElement_MaxPower(self)
	elseif(event == "UNIT_POWER" or event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER") then
		local powerType, powerToken = UnitPowerType(unit)
		local arg1 = ...
		self.PowerToken = powerToken
		self.PowerType = powerType
		if(event == "UNIT_POWER" or event == "UNIT_POWER_FREQUENT") then
			if mod.ClassBar and arg1 == powerToken then
				mod:ClassBar_Update(self)
			end
		end
		
		if arg1 == powerToken or event == "UNIT_DISPLAYPOWER" then
			mod:UpdateElement_Power(self)
		end
	else --Cast Events
		mod:UpdateElement_Cast(self, event, unit, ...)
	end
end

function mod:RegisterEvents(frame, unit)
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
	frame:RegisterUnitEvent("UNIT_HEALTH", unit);
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit);
	frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit);
	frame:RegisterUnitEvent("UNIT_LEVEL", unit);
	
	if(not frame.IsPlayer and not frame.IsFriendly) then
		frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit);
	end
	
	if(frame.IsPlayerFrame) then
		frame:RegisterUnitEvent("UNIT_POWER", unit)
		frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
		frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
		frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
	else
		frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		frame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
		frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
		frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");	
		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
		frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
		frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);	
	end
	
	frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterUnitEvent("UNIT_AURA", unit)
	frame:RegisterEvent("RAID_TARGET_UPDATE")
	
	mod.OnEvent(frame, "PLAYER_ENTERING_WORLD")
end

function mod:SetClassNameplateBar(frame)
	mod.ClassBar = frame
	if(frame) then
		frame:SetScale(1.35)
	end
end

function mod:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP

	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.ApplyFrameOptions = E.noop
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	
	--Best to just Hijack Blizzard's nameplate classbar
	self.ClassBar = NamePlateDriverFrame.nameplateBar
	if(self.ClassBar) then
		self.ClassBar:SetScale(1.35)
	end
	hooksecurefunc(NamePlateDriverFrame, "SetClassNameplateBar", mod.SetClassNameplateBar)

	self:DISPLAY_SIZE_CHANGED() --Run once for good measure.
	self:SetBaseNamePlateSize()
end


E:RegisterModule(mod:GetName())