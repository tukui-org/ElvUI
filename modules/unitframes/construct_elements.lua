local E, L, DF = unpack(select(2, ...)); --Engine
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

function UF:SpawnMenu()
	local unit = E:StringTitle(self.unit)
	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

function UF:Construct_ThreatGlow(frame, glow)
	local threat
	if glow then
		frame:CreateShadow('Default')
		threat = frame.shadow
		frame.shadow = nil
	else
		threat = CreateFrame('Frame')
	end
	threat.Override = self.UpdateThreat
	threat:SetFrameStrata('BACKGROUND')
	return threat
end

function UF:Construct_HealthBar(frame, bg, text, textPos)
	local health = CreateFrame('StatusBar', nil, frame)	
	UF['statusbars'][health] = true
	
	health:SetFrameStrata("LOW")
	--health.frequentUpdates = true
	health.PostUpdate = self.PostUpdateHealth
	
	if bg then
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints()
		health.bg:SetTexture(E["media"].blankTex)
		health.bg.multiplier = 0.25
	end
	
	if text then
		health.value = health:CreateFontString(nil, 'OVERLAY')
		UF['fontstrings'][health.value] = true
		health.value:SetParent(frame)
		
		local x = -2
		if textPos == 'LEFT' then
			x = 2
		end
		
		health.value:Point(textPos, health, textPos, x, 0)		
	end
	
	health.colorTapping = true	
	health.colorDisconnected = true
	health:CreateBackdrop('Default')	
	
	return health
end

function UF:Construct_PowerBar(frame, bg, text, textPos, lowtext)
	local power = CreateFrame('StatusBar', nil, frame)
	UF['statusbars'][power] = true
	
	--power.frequentUpdates = true
	power:SetFrameStrata("LOW")
	power.PostUpdate = self.PostUpdatePower

	if bg then
		power.bg = power:CreateTexture(nil, 'BORDER')
		power.bg:SetAllPoints()
		power.bg:SetTexture(E["media"].blankTex)
		power.bg.multiplier = 0.2
	end
	
	if text then
		power.value = power:CreateFontString(nil, 'OVERLAY')	
		UF['fontstrings'][power.value] = true
		power.value:SetParent(frame)
		
		local x = -2
		if textPos == 'LEFT' then
			x = 2
		end
		
		power.value:Point(textPos, frame.Health, textPos, x, 0)
	end
	
	if lowtext then
		power.LowManaText = power:CreateFontString(nil, 'OVERLAY')
		UF['fontstrings'][power.LowManaText] = true
		power.LowManaText:SetParent(frame)
		power.LowManaText:Point("BOTTOM", frame.Health, "BOTTOM", 0, 7)
		power.LowManaText:SetTextColor(0.69, 0.31, 0.31)
	end
	
	power.colorDisconnected = false
	power.colorTapping = false
	power:CreateBackdrop('Default')

	return power
end	

function UF:Construct_Portrait(frame)
	local portrait = CreateFrame("PlayerModel", nil, frame)
	portrait:SetFrameStrata('LOW')
	portrait:CreateBackdrop('Default')
	portrait.PostUpdate = self.PortraitUpdate

	portrait.overlay = CreateFrame("Frame", nil, frame)
	portrait.overlay:SetFrameLevel(frame:GetFrameLevel() - 5)
	
	return portrait
end

function UF:Construct_AuraIcon(button)
	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:Point('CENTER', 1, 1)
	button.text:SetJustifyH('CENTER')
	
	button:SetTemplate('Default')

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse()
	button.cd:ClearAllPoints()
	button.cd:Point('TOPLEFT', 2, -2)
	button.cd:Point('BOTTOMRIGHT', -2, 2)
	
	button.icon:ClearAllPoints()
	button.icon:Point('TOPLEFT', 2, -2)
	button.icon:Point('BOTTOMRIGHT', -2, 2)
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer('ARTWORK')
	
	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')
	
	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)
end

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', nil, frame)
	buffs.spacing = E:Scale(1)
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs.type = 'buffs'
	
	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', nil, frame)
	debuffs.spacing = E:Scale(1)
	debuffs.PostCreateIcon = self.Construct_AuraIcon
	debuffs.PostUpdateIcon = self.PostUpdateAura
	debuffs.CustomFilter = self.AuraFilter
	debuffs.type = 'debuffs'
	
	return debuffs
end

function UF:Construct_Castbar(self, direction)
	local castbar = CreateFrame("StatusBar", nil, self)
	UF['statusbars'][castbar] = true
	castbar.CustomDelayText = UF.CustomCastDelayText
	castbar.CustomTimeText = UF.CustomTimeText
	castbar.PostCastStart = UF.PostCastStart
	castbar.PostChannelStart = UF.PostCastStart		
	castbar.PostCastInterruptible = UF.PostCastInterruptible
	castbar.PostCastNotInterruptible = UF.PostCastNotInterruptible
	
	castbar:CreateBackdrop('Default')
	
	castbar.Time = castbar:CreateFontString(nil, 'OVERLAY')	
	UF['fontstrings'][castbar.Time] = true
	castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0)
	castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	castbar.Time:SetJustifyH("RIGHT")
	
	castbar.Text = castbar:CreateFontString(nil, 'OVERLAY')	
	UF['fontstrings'][castbar.Text] = true
	castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
	castbar.Text:SetTextColor(0.84, 0.75, 0.65)

	--Set to castbar.SafeZone
	castbar.LatencyTexture = castbar:CreateTexture(nil, "OVERLAY")
	castbar.LatencyTexture:SetTexture(E['media'].blankTex)
	castbar.LatencyTexture:SetVertexColor(0.69, 0.31, 0.31, 0.75)	

	local button = CreateFrame("Frame", nil, castbar)
	button:SetTemplate("Default")
	
	if direction == "LEFT" then
		button:Point("RIGHT", castbar, "LEFT", -3, 0)
	else
		button:Point("LEFT", castbar, "RIGHT", 3, 0)
	end
	
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:Point("TOPLEFT", button, 2, -2)
	icon:Point("BOTTOMRIGHT", button, -2, 2)
	icon:SetTexCoord(0.08, 0.92, 0.08, .92)
	icon.bg = button
	
	--Set to castbar.Icon
	castbar.ButtonIcon = icon

	return castbar
end

function UF:Construct_PaladinWarlockResourceBar(frame, class)
	local bars = CreateFrame("Frame", nil, frame)
	bars:CreateBackdrop('Default')
	
	for i = 1, 3 do					
		bars[i] = CreateFrame("StatusBar", nil, bars)
		bars[i]:SetStatusBarTexture(E['media'].blankTex) --Dummy really, this needs to be set so we can change the color
		bars[i]:GetStatusBarTexture():SetHorizTile(false)
		UF['statusbars'][bars[i]] = true

		bars[i]:CreateBackdrop('Default')
		bars[i].backdrop:SetParent(bars)
		
		if class == "PALADIN" then
			bars[i]:SetStatusBarColor(228/255,225/255,16/255)
			
			bars[i].backdrop:CreateShadow('Default')
			bars[i].backdrop.shadow:SetBackdropBorderColor(228/255,225/255,16/255)
			bars[i].backdrop.shadow:Point("TOPLEFT", -4, 4)
		else
			bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
		end
				
	end
	
	if class == "PALADIN" then
		bars.Override = UF.UpdateHoly
	else
		bars.Override = UF.UpdateShards
	end	
	
	return bars
end

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame("Frame", nil, frame)
	runes:CreateBackdrop('Default')

	for i = 1, 6 do
		runes[i] = CreateFrame("StatusBar", nil, runes)
		UF['statusbars'][runes[i]] = true
		runes[i]:SetStatusBarTexture(E['media'].blankTex)
		runes[i]:GetStatusBarTexture():SetHorizTile(false)
		
		runes[i]:CreateBackdrop('Default')
		runes[i].backdrop:SetParent(runes)
	end
	
	return runes
end

function UF:Construct_ShamanTotemBar(frame)
	local totems = CreateFrame("Frame", nil, frame)
	totems:CreateBackdrop('Default')
	totems.Destroy = true

	for i = 1, 4 do
		totems[i] = CreateFrame("StatusBar", nil, totems)
		UF['statusbars'][totems[i]] = true
		
		totems[i]:SetFrameStrata(frame:GetFrameStrata())
		totems[i]:SetFrameLevel(frame:GetFrameLevel())
		
		totems[i]:CreateBackdrop('Default')
		totems[i]:SetStatusBarTexture(E['media'].blankTex)
		totems[i]:GetStatusBarTexture():SetHorizTile(false)
		totems[i]:SetMinMaxValues(0, 1)

		
		totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
		totems[i].bg:SetAllPoints()
		totems[i].bg:SetTexture(E['media'].blankTex)
		totems[i].bg.multiplier = 0.3
	end
	
	return totems
end

function UF:Construct_DruidResourceBar(frame)
	local eclipseBar = CreateFrame('Frame', nil, frame)
	eclipseBar:CreateBackdrop('Default')
	eclipseBar.PostUpdatePower = UF.EclipseDirection
	eclipseBar.PostUpdateVisibility = UF.DruidResourceBarVisibilityUpdate
	
	local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	lunarBar:SetPoint('LEFT', eclipseBar)
	lunarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][lunarBar] = true
	lunarBar:SetStatusBarColor(.30, .52, .90)
	eclipseBar.LunarBar = lunarBar

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT')
	solarBar:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][solarBar] = true
	solarBar:SetStatusBarColor(.80, .82,  .60)
	eclipseBar.SolarBar = solarBar
	
	eclipseBar.Text = lunarBar:CreateFontString(nil, 'OVERLAY')
	UF['fontstrings'][eclipseBar.Text] = true
	eclipseBar.Text:SetPoint("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")
	
	return eclipseBar
end

function UF:Construct_DruidAltManaBar(frame)
	local dpower = CreateFrame('Frame', nil, frame)
	dpower:SetFrameStrata("LOW")
	dpower:SetAllPoints(frame.EclipseBar.backdrop)
	dpower:SetTemplate("Default")
	dpower:SetFrameLevel(dpower:GetFrameLevel() + 1)
	dpower.colorPower = true
	dpower.PostUpdateVisibility = UF.DruidResourceBarVisibilityUpdate
	dpower.PostUpdatePower = UF.DruidPostUpdateAltPower
	
	dpower.ManaBar = CreateFrame('StatusBar', nil, dpower)
	UF['statusbars'][dpower.ManaBar] = true
	dpower.ManaBar:SetStatusBarTexture(E["media"].blankTex)
	dpower.ManaBar:Point("TOPLEFT", dpower, "TOPLEFT", 2, -2)		
	dpower.ManaBar:Point("BOTTOMRIGHT", dpower, "BOTTOMRIGHT", -2, 2)	
	
	dpower.bg = dpower:CreateTexture(nil, "BORDER")
	dpower.bg:SetAllPoints(dpower.ManaBar)
	dpower.bg:SetTexture(E["media"].blankTex)
	dpower.bg.multiplier = 0.3

	dpower.Text = dpower:CreateFontString(nil, 'OVERLAY')
	UF['fontstrings'][dpower.Text] = true
	
	return dpower
end

function UF:Construct_RestingIndicator(frame)
	local resting = frame:CreateTexture(nil, "OVERLAY")
	resting:Size(22)
	resting:Point("CENTER", frame.Health, "TOPLEFT", -3, 6)
	
	return resting
end

function UF:Construct_CombatIndicator(frame)
	local combat = frame:CreateTexture(nil, "OVERLAY")
	combat:Size(19)
	combat:Point("CENTER", frame.Health, "CENTER", 0,6)
	combat:SetVertexColor(0.69, 0.31, 0.31)
	
	return combat
end

function UF:Construct_PvPIndicator(frame)
	local pvp = frame:CreateFontString(nil, 'OVERLAY')
	pvp:Point("BOTTOM", frame.Health, "BOTTOM", 0, 7)
	pvp:SetTextColor(0.69, 0.31, 0.31)
	UF['fontstrings'][pvp] = true
	
	self:ScheduleRepeatingTimer("UpdatePvPText", 0.1, frame)
	
	return pvp
end

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame("StatusBar", nil, frame)
	altpower:SetStatusBarTexture(E['media'].blankTex)
	UF['statusbars'][altpower] = true
	altpower:GetStatusBarTexture():SetHorizTile(false)

	altpower:SetFrameStrata("MEDIUM")
	altpower.PostUpdate = UF.AltPowerBarPostUpdate
	altpower:CreateBackdrop("Default", true)

	altpower.text = altpower:CreateFontString(nil, 'OVERLAY')
	altpower.text:SetPoint("CENTER")
	altpower.text:SetJustifyH("CENTER")		
	UF['fontstrings'][altpower.text] = true
	
	return altpower
end

function UF:Construct_NameText(frame)
	local name = frame:CreateFontString(nil, 'OVERLAY')
	UF['fontstrings'][name] = true
	if frame.unit == 'player' or frame.unit == 'target' then
		frame:Tag(name, '[Elv:getnamecolor][Elv:namelong] [Elv:diffcolor][level] [shortclassification]')
	else
		frame:Tag(name, '[Elv:getnamecolor][Elv:namemedium]')
	end
	name:SetPoint('CENTER', frame.Health)
	
	return name
end

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame)
	CPoints:CreateBackdrop('Default')
	CPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", nil, CPoints)
		UF['statusbars'][CPoints[i]] = true
		CPoints[i]:SetStatusBarTexture(E['media'].blankTex)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		
		CPoints[i]:CreateBackdrop('Default')
		CPoints[i].backdrop:SetParent(CPoints)
	end
	
	CPoints[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
	CPoints[2]:SetStatusBarColor(0.69, 0.31, 0.31)
	CPoints[3]:SetStatusBarColor(0.65, 0.63, 0.35)
	CPoints[4]:SetStatusBarColor(0.65, 0.63, 0.35)
	CPoints[5]:SetStatusBarColor(0.33, 0.59, 0.33)	
	
	return CPoints
end

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:Point("TOPLEFT", frame.Health, 2, -2)
	auras:Point("BOTTOMRIGHT", frame.Health, -2, 2)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.icons = {}
		
	return auras
end

function UF:Construct_RaidDebuffs(frame)
	local rdebuff = CreateFrame('Frame', nil, frame)
	rdebuff:Point('BOTTOM', frame, 'BOTTOM', 0, 2)
	rdebuff:SetTemplate("Default")
	
	rdebuff.icon = rdebuff:CreateTexture(nil, 'OVERLAY')
	rdebuff.icon:SetTexCoord(unpack(E.TexCoords))
	rdebuff.icon:Point("TOPLEFT", 2, -2)
	rdebuff.icon:Point("BOTTOMRIGHT", -2, 2)
	
	rdebuff.count = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.count:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.count:SetPoint('BOTTOMRIGHT', 0, 2)
	rdebuff.count:SetTextColor(1, .9, 0)
	
	rdebuff.time = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.time:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.time:SetPoint('CENTER')
	rdebuff.time:SetTextColor(1, .9, 0)
	
	return rdebuff
end

function UF:Construct_DebuffHighlight(frame)
	local dbh = frame:CreateTexture(nil, "OVERLAY")
	dbh:Point('TOPLEFT', frame.Health.backdrop, 'TOPLEFT', 2, -2)
	dbh:Point('BOTTOMRIGHT', frame.Health.backdrop, 'BOTTOMRIGHT', -2, 2)
	dbh:SetTexture(E['media'].blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode("ADD")
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0.45
			
	return dbh
end

function UF:Construct_ResurectionIcon(frame)
	local f = CreateFrame('Frame', nil, frame)
	f:SetFrameLevel(20)

	local tex = f:CreateTexture(nil, "OVERLAY")
	tex:Point('CENTER', frame.Health.value, 'CENTER')
	tex:Size(30, 25)
	tex:SetDrawLayer('OVERLAY', 7)
	
	return tex
end

function UF:Construct_RaidIcon(frame)
	local f = CreateFrame('Frame', nil, frame)
	f:SetFrameLevel(20)
	
	local tex = f:CreateTexture(nil, "OVERLAY")
	tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp") 
	tex:Size(18)
	tex:Point("CENTER", frame.Health, "TOP", 0, 2)
	
	return tex
end

function UF:Construct_ReadyCheckIcon(frame)
	local f = CreateFrame('Frame', nil, frame)
	f:SetFrameLevel(20)
	
	local tex = f:CreateTexture(nil, "OVERLAY")
	tex:Size(12)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	
	return tex
end

function UF:Construct_RoleIcon(frame)
	local f = CreateFrame('Frame', nil, frame)
	f:SetFrameLevel(20)
	
	local tex = f:CreateTexture(nil, "OVERLAY")
	tex:Size(17)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	tex.Override = UF.UpdateRoleIcon
	frame:RegisterEvent("UNIT_CONNECTION", UF.UpdateRoleIcon)
	
	return tex
end

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame("Frame", nil, frame)
	trinket.bg = CreateFrame("Frame", nil, trinket)
	trinket.bg:Point("TOPRIGHT", frame, "TOPRIGHT")
	trinket.bg:SetTemplate("Default")
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket:Point("TOPLEFT", trinket.bg, 2, -2)
	trinket:Point("BOTTOMRIGHT", trinket.bg, -2, 2)	
	
	return trinket
end

function UF:Construct_HealComm(frame)
	local mhpb = CreateFrame('StatusBar', nil, frame)
	mhpb:SetStatusBarTexture(E["media"].blankTex)
	mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
	mhpb:SetFrameLevel(frame.Health:GetFrameLevel() - 2)
	
	local ohpb = CreateFrame('StatusBar', nil, frame)
	ohpb:SetStatusBarTexture(E["media"].blankTex)
	ohpb:SetStatusBarColor(0, 1, 0, 0.25)
	mhpb:SetFrameLevel(mhpb:GetFrameLevel())	
	
	return {
		myBar = mhpb,
		otherBar = ohpb,
		maxOverflow = 1,
		PostUpdate = function(self)
			if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
			if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
		end
	}
end