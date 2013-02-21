local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

local tsort = table.sort
local sub = string.sub
local abs, random, floor, ceil = math.abs, math.random, math.floor, math.ceil
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function UF:PortraitUpdate(unit)
	local db = self:GetParent().db
	
	if not db then return end
	
	local portrait = db.portrait
	if portrait.enable and portrait.overlay then
		self:SetAlpha(0); 
		self:SetAlpha(0.35);
	else
		self:SetAlpha(1)
	end
	
	if self:GetObjectType() ~= 'Texture' then
		local model = self:GetModel()
		if model and model.find and model:find("worgenmale") then
			self:SetCamera(1)
		end	

		self:SetCamDistanceScale(portrait.camDistanceScale - 0.01 >= 0.01 and portrait.camDistanceScale - 0.01 or 0.01) --Blizzard bug fix
		self:SetCamDistanceScale(portrait.camDistanceScale)
	end
end

local function UpdateFillBar(frame, previousTexture, bar, amount)
	if ( amount == 0 ) then
		bar:Hide();
		return previousTexture;
	end
	
	local orientation = frame.Health:GetOrientation()
	bar:ClearAllPoints()
	if orientation == 'HORIZONTAL' then
		bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
	else
		bar:SetPoint("BOTTOMRIGHT", previousTexture, "TOPRIGHT");
		bar:SetPoint("BOTTOMLEFT", previousTexture, "TOPLEFT");	
	end

	local totalWidth, totalHeight = frame.Health:GetSize();
	if orientation == 'HORIZONTAL' then
		bar:SetWidth(totalWidth);
	else
		bar:SetHeight(totalHeight);
	end

	return bar:GetStatusBarTexture();
end

function UF:UpdateHealComm(unit, myIncomingHeal, allIncomingHeal, totalAbsorb)
	local frame = self.parent
	local previousTexture = frame.Health:GetStatusBarTexture();

	previousTexture = UpdateFillBar(frame, previousTexture, self.myBar, myIncomingHeal);
	previousTexture = UpdateFillBar(frame, previousTexture, self.otherBar, allIncomingHeal);
	previousTexture = UpdateFillBar(frame, previousTexture, self.absorbBar, totalAbsorb);
end

function UF:UpdateHoly(event, unit, powerType)
	if (self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
	local db = self.db
	if not db then return; end
	local BORDER = E.Border
	local numHolyPower = UnitPower('player', SPELL_POWER_HOLY_POWER);
	local maxHolyPower = UnitPowerMax('player', SPELL_POWER_HOLY_POWER);	
	local MAX_HOLY_POWER = UF['classMaxResourceBar'][E.myclass]
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and db.power.enable
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0		
	end	
	
	local CLASSBAR_WIDTH = db.width - (E.Border * 2)
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((db.width - (BORDER*2)) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - db.power.offset
	end
		
	if USE_MINI_CLASSBAR then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxHolyPower - 1) / maxHolyPower
	end
	
	self.HolyPower:Width(CLASSBAR_WIDTH)
	
	for i = 1, MAX_HOLY_POWER do
		if(i <= numHolyPower) then
			self.HolyPower[i]:SetAlpha(1)
		else
			self.HolyPower[i]:SetAlpha(.2)
		end
		
		self.HolyPower[i]:SetWidth(E:Scale(self.HolyPower:GetWidth() - (E.PixelMode and 4 or 2))/maxHolyPower)	
		self.HolyPower[i]:ClearAllPoints()
		if i == 1 then
			self.HolyPower[i]:SetPoint("LEFT", self.HolyPower)
		else
			if USE_MINI_CLASSBAR then
				self.HolyPower[i]:Point("LEFT", self.HolyPower[i-1], "RIGHT", maxHolyPower == 5 and 7 or 13, 0)
			else
				self.HolyPower[i]:Point("LEFT", self.HolyPower[i-1], "RIGHT", 1, 0)
			end
		end

		if i > maxHolyPower then
			self.HolyPower[i]:Hide()
			self.HolyPower[i].backdrop:SetAlpha(0)
		else
			self.HolyPower[i]:Show()
			self.HolyPower[i].backdrop:SetAlpha(1)
		end		
	end

end	

function UF:UpdateShadowOrbs(event, unit, powerType)
	local frame = self:GetParent()
	local db = frame.db
		
	local point, _, anchorPoint, x, y = frame.Health:GetPoint()
	if self:IsShown() and point then
		if db.classbar.fill == 'spaced' then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7)
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13)
		end
	elseif point then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2)
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end	

function UF:UpdateArcaneCharges(event, unit, arcaneCharges, maxCharges)
	local frame = self:GetParent()
	local db = frame.db
		
	local point, _, anchorPoint, x, y = frame.Health:GetPoint()
	if self:IsShown() and point then
		if db.classbar.fill == 'spaced' then
			frame.Health:SetPoint(point, frame, anchorPoint, x, -7)
		else
			frame.Health:SetPoint(point, frame, anchorPoint, x, -13)
		end
	elseif point then
		frame.Health:SetPoint(point, frame, anchorPoint, x, -2)
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end	

function UF:UpdateHarmony()
	local maxBars = self.numPoints
	local frame = self:GetParent()
	local db = frame.db
	if not db then return; end
	
	local UNIT_WIDTH = db.width
	local BORDER = E.Border
	local CLASSBAR_WIDTH = db.width - (BORDER*2)
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local POWERBAR_OFFSET = db.power.offset
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width ~= 'fill' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and db.classbar.enable
	
	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0	
	end
	
	if USE_PORTRAIT then
		CLASSBAR_WIDTH = ceil((CLASSBAR_WIDTH) - PORTRAIT_WIDTH)
	end
	
	if USE_POWERBAR_OFFSET then
		CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
	end	
	
	if db.classbar.fill == 'spaced' then	
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (maxBars - 1) / maxBars
	end
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end
	
	self:SetWidth(CLASSBAR_WIDTH)
	
	local colors = ElvUF.colors.harmony
	for i = 1, maxBars do		
		self[i]:SetHeight(self:GetHeight())	
		self[i]:SetWidth((self:GetWidth() - (maxBars - 1)) / maxBars)	
		self[i]:ClearAllPoints()
		
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			if USE_MINI_CLASSBAR then
				self[i]:Point("LEFT", self[i-1], "RIGHT", E.PixelMode and (maxBars == 5 and 4 or 7) or (maxBars == 5 and 6 or 9), 0)
			else
				self[i]:Point("LEFT", self[i-1], "RIGHT", 1, 0)
			end
		end	
				
		self[i]:SetStatusBarColor(colors[i][1], colors[i][2], colors[i][3])
	end	
end

function UF:UpdateShardBar(spec)
	local frame = self:GetParent()
	local db = frame.db
	
	if not db then return; end
	local maxBars = self.number
	
	for i=1, UF['classMaxResourceBar'][E.myclass] do
		if self[i]:IsShown() and db.classbar.fill == 'spaced' then
			self[i].backdrop:Show()
		else
			self[i].backdrop:Hide()
		end
	end

	if db.classbar.fill == 'spaced' and maxBars == 1 then
		self:ClearAllPoints()
		self:Point("LEFT", frame.Health.backdrop, "TOPLEFT", 8, 0)
	elseif db.classbar.fill == 'spaced' then
		self:ClearAllPoints()
		self:Point("CENTER", frame.Health.backdrop, "TOP", -12, -2)
	end
	
	local SPACING = db.classbar.fill == 'spaced' and 11 or 1
	for i = 1, maxBars do
		self[i]:SetHeight(self:GetHeight())	
		self[i]:SetWidth((self:GetWidth() - (maxBars - 1)) / maxBars)
		self[i]:ClearAllPoints()
		if i == 1 then
			self[i]:SetPoint("LEFT", self)
		else
			self[i]:Point("LEFT", self[i-1], "RIGHT", SPACING, 0)
		end		
	end
	
	UF:UpdatePlayerFrameAnchors(frame, self:IsShown())
end

function UF:EclipseDirection()
	local direction = GetEclipseDirection()
	if direction == "sun" then
		self.Text:SetText(">")
		self.Text:SetTextColor(.2,.2,1,1)
	elseif direction == "moon" then
		self.Text:SetText("<")
		self.Text:SetTextColor(1,1,.3, 1)
	else
		self.Text:SetText("")
	end
end

function UF:DruidResourceBarVisibilityUpdate(unit)
	local parent = self:GetParent()
	local eclipseBar = parent.EclipseBar
	local druidAltMana = parent.DruidAltMana
	
	UF:UpdatePlayerFrameAnchors(parent, eclipseBar:IsShown() or druidAltMana:IsShown())
end

function UF:DruidPostUpdateAltPower(unit, min, max)
	local powerText = self:GetParent().Power.value
	
	if min ~= max then
		local color = ElvUF['colors'].power['MANA']
		color = E:RGBToHex(color[1], color[2], color[3])
		
		self.Text:ClearAllPoints()
		if powerText:GetText() then
			if select(4, powerText:GetPoint()) < 0 then
				self.Text:SetPoint("RIGHT", powerText, "LEFT", 3, 0)
				self.Text:SetFormattedText(color.."%d%%|r |cffD7BEA5- |r", floor(min / max * 100))			
			else
				self.Text:SetPoint("LEFT", powerText, "RIGHT", -3, 0)
				self.Text:SetFormattedText("|cffD7BEA5-|r"..color.." %d%%|r", floor(min / max * 100))
			end
		else
			self.Text:SetPoint(powerText:GetPoint())
			self.Text:SetFormattedText(color.."%d%%|r", floor(min / max * 100))
		end	
	else
		self.Text:SetText()
	end
end

function UF:UpdateThreat(unit, status, r, g, b)
	local parent = self:GetParent()

	if (parent.unit ~= unit) or not unit then return end
	
	local db = parent.db
	if not db then return end
	
	if status and status > 1 then
		if db.threatStyle == 'GLOW' then
			self.glow:Show()
			self.glow:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
			
			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end
			
			if parent.ClassBar and parent.ClassBar.backdrop then
				parent.ClassBar.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Show()
			self.texIcon:SetVertexColor(r, g, b)
		end
	else
		r, g, b = unpack(E.media.bordercolor)
		if db.threatStyle == 'GLOW' then
			self.glow:Hide()
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
			
			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end
			
			if parent.ClassBar and parent.ClassBar.backdrop then
				parent.ClassBar.backdrop:SetBackdropBorderColor(r, g, b)
			end	
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Hide()
		end
	end
end

function UF:UpdateTargetGlow(event)
	if not self.unit then return; end
	local unit = self.unit
	
	if UnitIsUnit(unit, 'target') then
		self.TargetGlow:Show()
		local reaction = UnitReaction(unit, 'player')
		
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = RAID_CLASS_COLORS[class]
				self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			self.TargetGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.TargetGlow:SetBackdropBorderColor(1, 1, 1)
		end
	else
		self.TargetGlow:Hide()
	end
end

function UF:AltPowerBarPostUpdate(min, cur, max)
	local perc = floor((cur/max)*100)
	local parent = self:GetParent()
	
	if perc < 35 then
		self:SetStatusBarColor(0, 1, 0)
	elseif perc < 70 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end
	
	local unit = parent.unit
	
	if unit == "player" and self.text then 
		local type = select(10, UnitAlternatePowerInfo(unit))
				
		if perc > 0 then
			self.text:SetText(type..": "..format("%d%%", perc))
		else
			self.text:SetText(type..": 0%")
		end
	elseif unit and unit:find("boss%d") and self.text then
		self.text:SetTextColor(self:GetStatusBarColor())
		if not parent.Power.value:GetText() or parent.Power.value:GetText() == "" then
			self.text:Point("BOTTOMRIGHT", parent.Health, "BOTTOMRIGHT")
		else
			self.text:Point("RIGHT", parent.Power.value.value, "LEFT", 2, E.mult)	
		end
		if perc > 0 then
			self.text:SetText("|cffD7BEA5[|r"..format("%d%%", perc).."|cffD7BEA5]|r")
		else
			self.text:SetText(nil)
		end
	end
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local db = UF.player.db
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')


	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(.15)	
		end	
	end
	
	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local db = E.db['unitframe']['units'].target
	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR
	local COMBOBAR_HEIGHT = db.combobar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end
	
	if cpoints[1]:GetAlpha() == 1 then
		cpoints:Show()
		if USE_MINI_COMBOBAR then
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -((COMBOBAR_HEIGHT/2) + SPACING - BORDER))
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(SPACING + (COMBOBAR_HEIGHT/2)))
		else
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + SPACING + COMBOBAR_HEIGHT))
		end		

	else
		cpoints:Hide()
		self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER)
	end
end

local counterOffsets = {
	['TOPLEFT'] = {6, 1},
	['TOPRIGHT'] = {-6, 1},
	['BOTTOMLEFT'] = {6, 1},
	['BOTTOMRIGHT'] = {-6, 1},
	['LEFT'] = {6, 1},
	['RIGHT'] = {-6, 1},
	['TOP'] = {0, 0},
	['BOTTOM'] = {0, 0},
}

local textCounterOffsets = {
	['TOPLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['TOPRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOMLEFT'] = {"LEFT", "RIGHT", -2, 0},
	['BOTTOMRIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['LEFT'] = {"LEFT", "RIGHT", -2, 0},
	['RIGHT'] = {"RIGHT", "LEFT", 2, 0},
	['TOP'] = {"RIGHT", "LEFT", 2, 0},
	['BOTTOM'] = {"RIGHT", "LEFT", 2, 0},
}

function UF:UpdateAuraWatch(frame)
	local buffs = {};
	local auras = frame.AuraWatch;
	local db = frame.db.buffIndicator;

	if not db.enable then
		auras:Hide()
		return;
	else
		auras:Show()
	end
	
	if frame.unit == 'pet' then
		local petWatch = E.global['unitframe'].buffwatch.PET or {}
		for _, value in pairs(petWatch) do
			if value.style == 'text' then value.style = 'NONE' end --depreciated
			tinsert(buffs, value);
		end	
	else
		local buffWatch = E.global['unitframe'].buffwatch[E.myclass] or {}
		for _, value in pairs(buffWatch) do
			if value.style == 'text' then value.style = 'NONE' end --depreciated
			tinsert(buffs, value);
		end	
	end
	
	--CLEAR CACHE
	if auras.icons then
		for i=1, #auras.icons do
			local matchFound = false;
			for j=1, #buffs do
				if #buffs[j].id and #buffs[j].id == auras.icons[i] then
					matchFound = true;
					break;
				end
			end
			
			if not matchFound then
				auras.icons[i]:Hide()
				auras.icons[i] = nil;
			end
		end
	end
	
	unitframeFont = unitframeFont or LSM:Fetch("font", E.db['unitframe'].font)
	
	for i=1, #buffs do
		if buffs[i].id then
			local name, _, image = GetSpellInfo(buffs[i].id);
			if name then
				local icon
				if not auras.icons[buffs[i].id] then
					icon = CreateFrame("Frame", nil, auras);
				else
					icon = auras.icons[buffs[i].id];
				end
				icon.name = name
				icon.image = image
				icon.spellID = buffs[i].id;
				icon.anyUnit = buffs[i].anyUnit;
				icon.style = buffs[i].style;
				icon.onlyShowMissing = buffs[i].onlyShowMissing;
				icon.presentAlpha = icon.onlyShowMissing and 0 or 1;
				icon.missingAlpha = icon.onlyShowMissing and 1 or 0;
				icon.textThreshold = buffs[i].textThreshold
				icon.displayText = buffs[i].displayText
				
				icon:Width(db.size);
				icon:Height(db.size);
				icon:ClearAllPoints()
				icon:SetPoint(buffs[i].point, frame.Health, buffs[i].point, E.PixelMode and 0, E.PixelMode and 0);

				if not icon.icon then
					icon.icon = icon:CreateTexture(nil, "BORDER");
					icon.icon:SetAllPoints(icon);
				end
				
				if not icon.text then
					local f = CreateFrame('Frame', nil, icon)
					f:SetFrameLevel(icon:GetFrameLevel() + 50)
					icon.text = f:CreateFontString(nil, 'BORDER');
				end
				
				if not icon.border then
					icon.border = icon:CreateTexture(nil, "BACKGROUND");
					icon.border:Point("TOPLEFT", -E.mult, E.mult);
					icon.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
					icon.border:SetTexture(E["media"].blankTex);
					icon.border:SetVertexColor(0, 0, 0);
				end
				
				if not icon.cd then
					icon.cd = CreateFrame("Cooldown", nil, icon)
					icon.cd:SetAllPoints(icon)
					icon.cd:SetReverse(true)
					icon.cd:SetFrameLevel(icon:GetFrameLevel())
				end			

				if icon.style == 'coloredIcon' then
					icon.icon:SetTexture(E["media"].blankTex);
					
					if (buffs[i]["color"]) then
						icon.icon:SetVertexColor(buffs[i]["color"].r, buffs[i]["color"].g, buffs[i]["color"].b);
					else
						icon.icon:SetVertexColor(0.8, 0.8, 0.8);
					end		
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				elseif icon.style == 'texturedIcon' then
					icon.icon:SetVertexColor(1, 1, 1)
					icon.icon:SetTexCoord(.18, .82, .18, .82);
					icon.icon:SetTexture(icon.image);
					icon.icon:Show()
					icon.border:Show()
					icon.cd:SetAlpha(1)
				else
					icon.border:Hide()
					icon.icon:Hide()
					icon.cd:SetAlpha(0)
				end
				
				if icon.displayText then
					icon.text:Show()
					local r, g, b = 1, 1, 1
					if buffs[i].textColor then
						r, g, b = buffs[i].textColor.r, buffs[i].textColor.g, buffs[i].textColor.b
					end
					
					icon.text:SetTextColor(r, g, b)
				else
					icon.text:Hide()
				end
	
				if not icon.count then
					icon.count = icon:CreateFontString(nil, "OVERLAY");
				end
				
				icon.count:ClearAllPoints()
				if icon.displayText then
					local point, anchorPoint, x, y = unpack(textCounterOffsets[buffs[i].point])
					icon.count:SetPoint(point, icon.text, anchorPoint, x, y)
				else
					icon.count:SetPoint("CENTER", unpack(counterOffsets[buffs[i].point]));
				end
				
				icon.count:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE');
				icon.text:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE');
				icon.text:ClearAllPoints()
				icon.text:SetPoint(buffs[i].point, icon, buffs[i].point)
				
				if buffs[i].enabled then
					auras.icons[buffs[i].id] = icon;
					if auras.watched then
						auras.watched[buffs[i].id] = icon;
					end
				else	
					auras.icons[buffs[i].id] = nil;
					if auras.watched then
						auras.watched[buffs[i].id] = nil;
					end
					icon:Hide();
					icon = nil;
				end
			end
		end
	end
	
	if frame.AuraWatch.Update then
		frame.AuraWatch.Update(frame)
	end
		
	buffs = nil;
end


local roleIconTextures = {
	TANK = [[Interface\AddOns\ElvUI\media\textures\tank.tga]],
	HEALER = [[Interface\AddOns\ElvUI\media\textures\healer.tga]],
	DAMAGER = [[Interface\AddOns\ElvUI\media\textures\dps.tga]]
}

function UF:UpdateRoleIcon()
	local lfdrole = self.LFDRole
	if not self.db then return; end
	local db = self.db.roleIcon;
	
	if (not db) or (db and not db.enable) then 
		lfdrole:Hide()
		return
	end
	
	local role = UnitGroupRolesAssigned(self.unit)
	if self.isForced and role == 'NONE' then
		local rnd = random(1, 3)
		role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
	end
	
	if role ~= 'NONE' and (self.isForced or UnitIsConnected(self.unit)) then
		lfdrole:SetTexture(roleIconTextures[role])
		lfdrole:Show()
	else
		lfdrole:Hide()
	end	
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local leader = anchor:GetParent().Leader
	local masterLooter = anchor:GetParent().MasterLooter

	if not leader or not masterLooter then return; end

	local unit = anchor:GetParent().unit
	local db = anchor:GetParent().db
	local isLeader = leader:IsShown()
	local isMasterLooter = masterLooter:IsShown()
	
	leader:ClearAllPoints()
	masterLooter:ClearAllPoints()
	
	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')	
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT' then
			masterLooter:Point('LEFT', anchor, 'LEFT')	
		else
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		end
	end
end

local huge = math.huge
function UF.SortAuraBarReverse(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa < compb
end

function UF.SortAuraBarDuration(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarDurationReverse(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarName(a, b)
	return a.name > b.name
end

function UF:AuraBarFilter(unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID)
	if not self.db then return; end
	if E.global.unitframe.InvalidSpells[spellID] then
		return false;
	end
	
	local db = self.db.aurabar

	local returnValue = true
	local passPlayerOnlyCheck = true
	local anotherFilterExists = false
	local isPlayer = unitCaster == 'player' or unitCaster == 'vehicle'
	local isFriend = UnitIsFriend('player', unit) == 1 and true or false
	local auraType = isFriend and db.friendlyAuraType or db.enemyAuraType
	
	if UF:CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		else
			returnValue = false;
		end
		
		passPlayerOnlyCheck = returnValue
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and not isStealable) or (self.type == 'debuffs' and dtype and  not E:IsDispellableByMe(dtype)) then
			returnValue = false;
		end
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == 1 then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useBlacklist, isFriend) then
		local blackList = E.global['unitframe']['aurafilters']['Blacklist'].spells[name]
		if blackList and blackList.enable then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = E.global['unitframe']['aurafilters']['Whitelist'].spells[name]
		if whiteList and whiteList.enable then
			returnValue = true;
		elseif not anotherFilterExists then
			returnValue = false
		end
		
		anotherFilterExists = true
	end	

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable and passPlayerOnlyCheck then
				returnValue = true
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false				
		end
	end		
	
	return returnValue	
end

function UF:ColorizeAuraBars(event, unit)
	local bars = self.bars
	for index = 1, #bars do
		local frame = bars[index]
		if not frame:IsVisible() then break end

		local colors = E.global.unitframe.AuraBarColors[frame.statusBar.aura.name]
		if colors then
			frame.statusBar:SetStatusBarColor(colors.r, colors.g, colors.b)
			frame.statusBar.bg:SetTexture(colors.r * 0.25, colors.g * 0.25, colors.b * 0.25)
		else
			local r, g, b = frame.statusBar:GetStatusBarColor()
			frame.statusBar.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25)			
		end

		if UF.db.colors.transparentAurabars then
			UF:ToggleTransparentStatusBar(true, frame.statusBar, frame.statusBar.bg, nil, true)
			local _, _, _, alpha = frame:GetBackdropColor()
			if colors then
				frame:SetBackdropColor(colors.r * 0.58, colors.g * 0.58, colors.b * 0.58, alpha)
			else
				local r, g, b = frame.statusBar:GetStatusBarColor()
				frame:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha)
			end			
		else
			UF:ToggleTransparentStatusBar(false, frame.statusBar, frame.statusBar.bg, nil, true)
		end	
	end
end

function UF:PostUpdateStagger()
	local frame = self:GetParent()
	UF:UpdatePlayerFrameAnchors(frame, (frame.ClassBar and frame.ClassBar:IsShown()))
end