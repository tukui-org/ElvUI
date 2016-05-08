local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

--Get Data For All Group Members Threat on Each Nameplate
function mod:Update_ThreatList(frame)
	local unit = frame.unit
	local isTanking, status, percent = UnitDetailedThreatSituation('player', unit)
	local isInGroup, isInRaid = IsInGroup(), IsInRaid()
	frame.ThreatData = {}
	frame.ThreatData.player = {isTanking, status, percent}
	frame.isBeingTanked = false
	if(isTanking and E:GetPlayerRole() == "TANK") then
		frame.isBeingTanked = true
	end
	
	if(status and (isInRaid or isInGroup)) then --We don't care about units we have no threat on at all
		if isInRaid then
			frame.ThreatData = {}
			frame.ThreatData.player = {UnitDetailedThreatSituation('player', unit)}
			for i=1, 40 do
				if UnitExists('raid'..i) and not UnitIsUnit('raid'..i, 'player') then
					frame.ThreatData['raid'..i] = frame.ThreatData['raid'..i] or {}
					isTanking, status, percent = UnitDetailedThreatSituation('raid'..i, unit)
					frame.ThreatData['raid'..i] = {isTanking, status, percent}
					
					if(frame.isBeingTanked ~= true and isTanking and UnitGroupRolesAssigned('raid'..i) == "TANK") then
						frame.isBeingTanked = true
					end
				end
			end
		else
			frame.ThreatData = {}
			frame.ThreatData.player = {UnitDetailedThreatSituation('player', unit)}
			for i=1, 4 do
				if UnitExists('party'..i) --[[and not UnitIsUnit('party'..i, 'player')]] then
					frame.ThreatData['party'..i] = frame.ThreatData['party'..i] or {}
					isTanking, status, percent = UnitDetailedThreatSituation('party'..i, unit)
					frame.ThreatData['party'..i] = {isTanking, status, percent}
					
					if(frame.isBeingTanked ~= true and isTanking and UnitGroupRolesAssigned('party'..i) == "TANK") then
						frame.isBeingTanked = true
					end					
				end
			end
		end	
	end
end

function mod:UpdateElement_CastBarOnUpdate(elapsed)
	if ( self.casting ) then
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			self:Hide()
			return;
		end
		self:SetValue(self.value);
		self.Time:SetFormattedText("%.1f ", self.value)
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			self:Hide()
			return;
		end
		self:SetValue(self.value);
		self.Time:SetFormattedText("%.1f ", self.value)
	end
end

function mod:UpdateElement_Cast(frame, event, ...)
	local arg1 = ...;
	local unit = frame.unit
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel = UnitChannelInfo(unit);
		local nameSpell = UnitCastingInfo(unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = unit;
		else
		    frame.CastBar:Hide()
		end
	end
	
	if ( arg1 ~= unit ) then
		return;
	end		
	
	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
		if ( not name) then
			frame.CastBar:Hide();
			return;
		end

		frame.CastBar.canInterrupt = not notInterruptible
		
		if ( frame.CastBar.Spark ) then
			frame.CastBar.Spark:Show();
		end
		frame.CastBar.Name:SetText(text)
		frame.CastBar.value = (GetTime() - (startTime / 1000));
		frame.CastBar.maxValue = (endTime - startTime) / 1000;
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
		frame.CastBar:SetValue(frame.CastBar.value);
		if ( frame.CastBar.Text ) then
			frame.CastBar.Text:SetText(text);
		end
		if ( frame.CastBar.Icon ) then
			frame.CastBar.Icon:SetTexture(texture);
		end

		frame.CastBar.casting = true;
		frame.CastBar.castID = castID;
		frame.CastBar.channeling = nil;

		frame.CastBar:Show()
	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		if ( not frame.CastBar:IsVisible() ) then
			frame.CastBar:Hide();
		end
		if ( (frame.CastBar.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == frame.CastBar.castID) or
		     (frame.CastBar.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			if ( frame.CastBar.Spark ) then
				frame.CastBar.Spark:Hide();
			end

			frame.CastBar:SetValue(frame.CastBar.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				frame.CastBar.casting = nil;
			else
				frame.CastBar.channeling = nil;
			end
			frame.CastBar.canInterrupt = nil
			frame.CastBar:Hide()
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( frame.CastBar:IsShown() and (frame.CastBar.casting and select(4, ...) == frame.CastBar.castID) ) then
			frame.CastBar:SetValue(frame.CastBar.maxValue);
			if ( frame.CastBar.Spark ) then
				frame.CastBar.Spark:Hide();
			end
			if ( frame.CastBar.Text ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					frame.CastBar.Text:SetText(FAILED);
				else
					frame.CastBar.Text:SetText(INTERRUPTED);
				end
			end
			frame.CastBar.casting = nil;
			frame.CastBar.channeling = nil;
			frame.CastBar.canInterrupt = nil
			frame.CastBar:Hide()
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( frame:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
			if ( not name ) then
				-- if there is no name, there is no bar
				frame.CastBar:Hide();
				return;
			end
			frame.canInterrupt = not notInterruptible
			frame.CastBar.Name:SetText(text)
			frame.CastBar.value = (GetTime() - (startTime / 1000));
			frame.CastBar.maxValue = (endTime - startTime) / 1000;
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
			frame.CastBar.canInterrupt = not notInterruptible
			if ( not frame.CastBar.casting ) then
				if ( frame.CastBar.Spark ) then
					frame.CastBar.Spark:Show();
				end			
				
				frame.CastBar.casting = true;
				frame.CastBar.channeling = nil;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
		if ( not name) then
			frame.CastBar:Hide();
			return;
		end

		frame.CastBar.Name:SetText(text)
		frame.CastBar.value = (endTime / 1000) - GetTime();
		frame.CastBar.maxValue = (endTime - startTime) / 1000;
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
		frame.CastBar:SetValue(frame.CastBar.value);
		
		if ( frame.CastBar.Text ) then
			frame.CastBar.Text:SetText(text);
		end
		if ( frame.CastBar.Icon ) then
			frame.CastBar.Icon:SetTexture(texture);
		end
		if ( frame.CastBar.Spark ) then
			frame.CastBar.Spark:Hide();
		end
		frame.CastBar.canInterrupt = not notInterruptible
		frame.CastBar.casting = nil;
		frame.CastBar.channeling = true;

		frame.CastBar:Show();
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if ( frame.CastBar:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name ) then
				frame.CastBar:Hide();
				return;
			end
			frame.CastBar.Name:SetText(text)
			frame.CastBar.value = ((endTime / 1000) - GetTime());
			frame.CastBar.maxValue = (endTime - startTime) / 1000;
			frame:SetMinMaxValues(0, frame.CastBar.maxValue);
			frame:SetValue(frame.CastBar.value);
		end
	elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then
		frame.CastBar.canInterrupt = true
	elseif ( event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		frame.CastBar.canInterrupt = nil
	end
	
	if(frame.CastBar.canInterrupt) then
		frame.CastBar:SetStatusBarColor(self.db.castbar.color.r, self.db.castbar.color.g, self.db.castbar.color.b)
	else
		frame.CastBar:SetStatusBarColor(self.db.castbar.noInterrupt.r, self.db.castbar.noInterrupt.g, self.db.castbar.noInterrupt.b)
	end
	frame.CastBar.canInterrupt = nil
end

function mod:ConfigureElement_CastBar(frame)
	local castBar = frame.CastBar

	--Position
	castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -3)
	castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -3)
	castBar:SetHeight(self.db.castbar.height)

	castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", 3, 0)
	castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", 3, 0)
	castBar.Icon:SetWidth(self.db.castbar.height + self.db.healthbar.height + 3)
	castBar.Icon:SetTexCoord(unpack(E.TexCoords))
	
	castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -2)
	castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -2)
	castBar.Name:SetPoint("TOPRIGHT", castBar.Time, "TOPLEFT")
	
	castBar.Name:SetJustifyH("LEFT")
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)	
	castBar.Time:SetJustifyH("RIGHT")
	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)	
		
	--Texture
	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	self:StyleFrame(frame, true)
	frame:SetScript("OnUpdate", mod.UpdateElement_CastBarOnUpdate)
	
	frame.Icon = frame:CreateTexture(nil, "BORDER")
	self:StyleFrame(frame.Icon, false)
	
	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)
	
	return frame	
end

function mod:UpdateElement_Glow(frame)
	local r, g, b, shouldShow;
	if ( UnitIsUnit(frame.unit, "target") ) then
		r, g, b = 1, 1, 1
		shouldShow = true
	else
		-- Use color based on the type of unit (neutral, etc.)
		local isTanking, status = UnitDetailedThreatSituation("player", frame.unit)
		if status then
			if(isTanking) then
				if(E:GetPlayerRole() == "TANK") then
					r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
				else
					r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
				end
			else
				if(E:GetPlayerRole() == "TANK") then
					r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
				else
					r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
				end
			end
			shouldShow = true
		end
	end
	
	if(shouldShow) then
		frame.Glow:Show()
		if ( (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b) ) then
			frame.Glow:SetBackdropBorderColor(r, g, b);
			frame.Glow.r, frame.Glow.g, frame.Glow.b = r, g, b;
		end
	elseif(frame.Glow:IsShown()) then
		frame.Glow:Hide()
	end
end

function mod:ConfigureElement_Glow(frame)
	frame.Glow:SetFrameLevel(0)
	frame.Glow:SetFrameStrata("BACKGROUND")
	frame.Glow:SetOutside(frame.HealthBar, 3, 3)
	frame.Glow:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = 3 + mod.mult,
		insets = {left = 6, right = 6, top = 6, bottom = 6},
	})
	frame.Glow:SetBackdropBorderColor(0, 0, 0)
end

function mod:ConstructElement_Glow(frame)
	return CreateFrame("Frame", nil, frame)
end

function mod:UpdateElement_Level(frame)
	local level = UnitLevel(frame.unit)
	
	if(level == -1 or not level) then
		frame.Level:SetText('??')
		frame.Level:SetTextColor(0.9, 0, 0)	
	else
		local color = GetQuestDifficultyColor(level)
		frame.Level:SetText(level)
		frame.Level:SetTextColor(color.r, color.g, color.b)
	end
end

function mod:ConfigureElement_Level(frame)
	local level = frame.Level
	
	level:SetJustifyH("RIGHT")
	level:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 2)
	level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end

function mod:UpdateElement_Name(frame)
	local name = GetUnitName(frame.unit, true)
	frame.Name:SetText(name)
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name
	
	name:SetJustifyH("LEFT")
	name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2)
	name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Name(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end

function mod:UpdateElement_HealthColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = self.db.reactions.offline.r, self.db.reactions.offline.g, self.db.reactions.offline.b
	else
		if ( frame.HealthBar.ColorOverride ) then
			--[[local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;]]
		else
			--Try to color it by class.
			local _, class = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[class];
			if ( UnitIsPlayer(frame.unit) and classColor ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = self.db.reactions.tapped.r, self.db.reactions.tapped.g, self.db.reactions.tapped.b	
			else
				-- Use color based on the type of unit (neutral, etc.)
				local isTanking, status = UnitDetailedThreatSituation("player", frame.unit)
				if status then
					if(isTanking) then
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
						else
							r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
						end
					else
						if(E:GetPlayerRole() == "TANK") then
							--Check if it is being tanked by an offtank.
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked then
								r, g, b = .8, 0.1, 1
							else
								r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
							end
						else
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked then
								r, g, b = .8, 0.1, 1
							else
								r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
							end	
						end
					end
				else
					--By Reaction
					local reactionType = UnitReaction(frame.unit, "player")
					if(reactionType == 4) then
						r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
					elseif(reactionType > 4) then
						r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
					else
						r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
					end
				end
			end
		end
	end
	
	if ( r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b ) then
		frame.HealthBar:SetStatusBarColor(r, g, b);
		frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b;
	end
end

function mod:UpdateElement_MaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.unit);
	frame.HealthBar:SetMinMaxValues(0, maxHealth)
end

function mod:UpdateElement_Health(frame)
	local health = UnitHealth(frame.unit);
	frame.HealthBar:SetValue(health)
end

function mod:ConfigureElement_HealthBar(frame)
	local healthBar = frame.HealthBar

	--Position
	healthBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, self.db.castbar.height + 3)
	healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, self.db.castbar.height + 3)
	healthBar:SetHeight(self.db.healthbar.height)

	--Texture
	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", "$parentHealthBar", parent)
	self:StyleFrame(frame, true)
	
	return frame
end

function mod:UpdateElement_All(frame, unit)
	mod:UpdateElement_MaxHealth(frame)
	mod:UpdateElement_Health(frame)
	mod:UpdateElement_HealthColor(frame)
	mod:UpdateElement_Name(frame)
	mod:UpdateElement_Level(frame)
	mod:UpdateElement_Glow(frame)
	mod:UpdateElement_Cast(frame)
end

function mod:RegisterEvents(frame, unit)
	frame:RegisterUnitEvent("UNIT_MAXHEALTH", unit);
	frame:RegisterUnitEvent("UNIT_HEALTH", unit);
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit);
	frame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit);
	frame:RegisterUnitEvent("UNIT_LEVEL", unit);
	frame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit);
	frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
	frame:RegisterEvent("UNIT_SPELLCAST_DELAYED");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
	frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
	frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
	frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);	
	
	mod.OnEvent(frame, "PLAYER_ENTERING_WORLD")
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
		mod:UpdateElement_Glow(self)
	else --Cast Events
		mod:UpdateElement_Cast(self, event, unit, ...)
	end
end

function mod:NAME_PLATE_CREATED(event, frame)
	frame.UnitFrame = CreateFrame("BUTTON", "$parentUnitFrame", frame);
	frame.UnitFrame:EnableMouse(false);
	frame.UnitFrame:SetAllPoints(frame)
	frame.UnitFrame:SetScript("OnEvent", mod.OnEvent)
	
	frame.UnitFrame.HealthBar = self:ConstructElement_HealthBar(frame.UnitFrame)
	self:ConfigureElement_HealthBar(frame.UnitFrame)
	
	frame.UnitFrame.CastBar = self:ConstructElement_CastBar(frame.UnitFrame)
	self:ConfigureElement_CastBar(frame.UnitFrame)
	
	frame.UnitFrame.Level = self:ConstructElement_Level(frame.UnitFrame)
	self:ConfigureElement_Level(frame.UnitFrame)
	
	frame.UnitFrame.Name = self:ConstructElement_Name(frame.UnitFrame)
	self:ConfigureElement_Name(frame.UnitFrame)
	
	frame.UnitFrame.Glow = self:ConstructElement_Glow(frame.UnitFrame)
	self:ConfigureElement_Glow(frame.UnitFrame)
end

function mod:DISPLAY_SIZE_CHANGED()
	self.mult = E.mult * UIParent:GetScale()	
end

function mod:NAME_PLATE_UNIT_ADDED(event, unit)
	local frame = C_NamePlate.GetNamePlateForUnit(unit);
	frame.UnitFrame.unit = unit

	self:RegisterEvents(frame.UnitFrame, unit)
	self:UpdateElement_All(frame.UnitFrame, unit)
end

function mod:NAME_PLATE_UNIT_REMOVED(event, unit)
	local frame = C_NamePlate.GetNamePlateForUnit(unit);
	frame.UnitFrame.unit = nil
	
	frame.UnitFrame:UnregisterAllEvents()
	
	frame.ThreatData = nil
end

function mod:ForEachPlate(functionToRun, ...)
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if(frame) then
			self[functionToRun](frame.UnitFrame, ...)
		end
	end
end

function mod:SetBaseNamePlateSize()
	local baseWidth = self.db.healthbar.width
	local baseHeight = self.db.castbar.height + self.db.healthbar.height + 30
	NamePlateDriverFrame:SetBaseNamePlateSize(baseWidth, baseHeight)
end

function mod:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP

	NamePlateDriverFrame:UnregisterAllEvents()
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	self:DISPLAY_SIZE_CHANGED() --Run once for good measure.
	self:SetBaseNamePlateSize()
end

E:RegisterModule(mod:GetName())