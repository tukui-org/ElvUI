local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local unpack, select, assert, pairs = unpack, select, assert, pairs
local tinsert = tinsert
local random, floor, ceil = math.random, math.floor, math.ceil
local format = string.format
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPower = UnitPower
local GetComboPoints = GetComboPoints
local GetSpellInfo = GetSpellInfo
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetBattlefieldScore = GetBattlefieldScore
local IsInInstance = IsInInstance
local GetUnitName = GetUnitName
local GetBattlefieldScore = GetBattlefieldScore
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsConnected = UnitIsConnected
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local LSM = LibStub("LibSharedMedia-3.0");
function UF:Construct_TargetGlow(frame)
	frame:CreateShadow('Default')
	local x = frame.shadow
	frame.shadow = nil
	--x:SetFrameStrata('BACKGROUND')
	x:Hide();

	return x
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
	local pvp = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(pvp)

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
	UF:Configure_FontString(altpower.text)

	return altpower
end

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame)
	CPoints:CreateBackdrop('Default')
	CPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", frame:GetName().."ComboBarButton"..i, CPoints)
		UF['statusbars'][CPoints[i]] = true
		CPoints[i]:SetStatusBarTexture(E['media'].blankTex)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		CPoints[i]:SetAlpha(0.15)
		CPoints[i]:CreateBackdrop('Default')
		CPoints[i].backdrop:SetParent(CPoints)
	end

	return CPoints
end

function UF:Construct_AuraWatch(frame)
	local auras = CreateFrame("Frame", nil, frame)
	auras:SetFrameLevel(frame:GetFrameLevel() + 25)
	auras:SetInside(frame.Health)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.strictMatching = true;
	auras.icons = {}

	return auras
end

function UF:Construct_RaidDebuffs(frame)
	local rdebuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	rdebuff:SetTemplate("Default")

	if E.PixelMode then
		rdebuff.border = rdebuff:CreateTexture(nil, "BACKGROUND");
		rdebuff.border:Point("TOPLEFT", -E.mult, E.mult);
		rdebuff.border:Point("BOTTOMRIGHT", E.mult, -E.mult);
		rdebuff.border:SetTexture(E["media"].blankTex);
		rdebuff.border:SetVertexColor(0, 0, 0);
	end

	rdebuff.icon = rdebuff:CreateTexture(nil, 'OVERLAY')
	rdebuff.icon:SetTexCoord(unpack(E.TexCoords))
	rdebuff.icon:SetInside()

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
	dbh:SetInside(frame.Health.backdrop)
	dbh:SetTexture(E['media'].blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode("ADD")
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0.45
	frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors

	frame:CreateShadow('Default')
	local x = frame.shadow
	frame.shadow = nil
	x:Hide();

	frame.DBHGlow = x
	
	if frame.Health then
		dbh:SetParent(frame.Health)
		frame.DBHGlow:SetParent(frame.Health)
	end

	return dbh
end

function UF:Construct_ResurectionIcon(frame)
	local tex = frame.RaisedElementParent:CreateTexture(nil, "OVERLAY")
	tex:Point('CENTER', frame.Health.value, 'CENTER')
	tex:Size(30, 25)
	tex:SetDrawLayer('OVERLAY', 7)

	return tex
end


function UF:Construct_ReadyCheckIcon(frame)
	local f = CreateFrame("FRAME", nil, frame)
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(100)

	local tex = f:CreateTexture(nil, "OVERLAY", nil, 7)
	tex:Size(12)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)

	return tex
end


function UF:Construct_Trinket(frame)
	local trinket = CreateFrame("Frame", nil, frame)
	trinket.bg = CreateFrame("Frame", nil, trinket)
	trinket.bg:SetTemplate("Default")
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket:SetInside(trinket.bg)

	return trinket
end

function UF:Construct_PVPSpecIcon(frame)
	local specIcon = CreateFrame("Frame", nil, frame)
	specIcon.bg = CreateFrame("Frame", nil, specIcon)
	specIcon.bg:SetTemplate("Default")
	specIcon.bg:SetFrameLevel(specIcon:GetFrameLevel() - 1)
	specIcon:SetInside(specIcon.bg)

	return specIcon
end

function UF:Construct_RaidRoleFrames(frame)
	local anchor = CreateFrame('Frame', nil, frame)
	frame.Leader = anchor:CreateTexture(nil, 'OVERLAY')
	frame.Assistant = anchor:CreateTexture(nil, 'OVERLAY')
	frame.MasterLooter = anchor:CreateTexture(nil, 'OVERLAY')

	anchor:Size(24, 12)
	frame.Leader:Size(12)
	frame.Assistant:Size(12)
	frame.MasterLooter:Size(11)

	frame.Leader.PostUpdate = UF.RaidRoleUpdate
	frame.Assistant.PostUpdate = UF.RaidRoleUpdate
	frame.MasterLooter.PostUpdate = UF.RaidRoleUpdate

	return anchor
end

function UF:Construct_GPS(frame)
	local gps = CreateFrame("Frame", nil, frame)
	gps:SetFrameLevel(frame:GetFrameLevel() + 50)
	gps:Hide()

	gps.Texture = gps:CreateTexture("OVERLAY")
	gps.Texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrow.tga]])
	gps.Texture:SetBlendMode("BLEND")
	gps.Texture:SetVertexColor(214/255, 41/255, 41/255)
	gps.Texture:SetAllPoints()

	return gps
end

function UF:Construct_Range(frame)
	return {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}
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
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
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
			self.text:SetFormattedText("%s: %d%%", type, perc)
		else
			self.text:SetFormattedText("%s: 0%%", type)
		end
	elseif unit and unit:find("boss%d") and self.text then
		self.text:SetTextColor(self:GetStatusBarColor())
		if not parent.Power.value:GetText() or parent.Power.value:GetText() == "" then
			self.text:Point("BOTTOMRIGHT", parent.Health, "BOTTOMRIGHT")
		else
			self.text:Point("RIGHT", parent.Power.value.value, "LEFT", 2, E.mult)
		end
		if perc > 0 then
			self.text:SetFormattedText("|cffD7BEA5[|r%d%%|cffD7BEA5]|r", perc)
		else
			self.text:SetText(nil)
		end
	end
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and UnitPower('vehicle', 4) or UnitPower('player', 4)
	--Some bosses require the old API and return 0 constantly with the new API (Malygos is one example)
	local cpOldApi = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')
	if cpOldApi and cp and (cpOldApi > cp) then cp = cpOldApi end

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
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR and not db.combobar.detachFromFrame
	local COMBOBAR_HEIGHT = db.combobar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local PORTRAIT_OFFSET_Y = ((COMBOBAR_HEIGHT/2) + SPACING - BORDER)
	local HEALTH_OFFSET_Y
	local DETACHED = db.combobar.detachFromFrame

	if not self.Portrait then
		self.Portrait = db.portrait.style == '2D' and self.Portrait2D or self.Portrait3D
	end

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end

	if DETACHED then
		PORTRAIT_OFFSET_Y = 0
	end

	if cpoints[1]:GetAlpha() == 1 or not db.combobar.autoHide then
		cpoints:Show()
		if USE_MINI_COMBOBAR then
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + (COMBOBAR_HEIGHT/2))
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -PORTRAIT_OFFSET_Y)
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -HEALTH_OFFSET_Y)
		else
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + COMBOBAR_HEIGHT)
			self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT")
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + HEALTH_OFFSET_Y))
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

function UF:UpdateAuraWatchFromHeader(group, petOverride)
	assert(self[group], "Invalid group specified.")
	local group = self[group]
	for i=1, group:GetNumChildren() do
		local frame = select(i, group:GetChildren())
		if frame and frame.Health then
			UF:UpdateAuraWatch(frame, petOverride, group.db)
		elseif frame then
			for n = 1, frame:GetNumChildren() do
				local child = select(n, frame:GetChildren())
				if child and child.Health then
					UF:UpdateAuraWatch(child, petOverride, group.db)
				end
			end
		end
	end
end

function UF:UpdateAuraWatch(frame, petOverride, db)
	local buffs = {};
	local auras = frame.AuraWatch;
	local db = db and db.buffIndicator or frame.db.buffIndicator

	if not db.enable then
		auras:Hide()
		return;
	else
		auras:Show()
	end

	if frame.unit == 'pet' and not petOverride then
		local petWatch = E.global['unitframe'].buffwatch.PET or {}
		for _, value in pairs(petWatch) do
			if value.style == 'text' then value.style = 'NONE' end --depreciated
			tinsert(buffs, value);
		end
	else
		local buffWatch = not db.profileSpecific and (E.global['unitframe'].buffwatch[E.myclass] or {}) or (E.db['unitframe']['filters'].buffwatch or {})
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

	local unitframeFont = LSM:Fetch("font", E.db['unitframe'].font)

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
				icon.textThreshold = buffs[i].textThreshold or -1
				icon.displayText = buffs[i].displayText
				icon.decimalThreshold = buffs[i].decimalThreshold

				icon:Width(db.size);
				icon:Height(db.size);
				icon:ClearAllPoints()
				icon:SetPoint(buffs[i].point, frame.Health, buffs[i].point, buffs[i].xOffset, buffs[i].yOffset);


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
					icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
					icon.cd:SetAllPoints(icon)
					icon.cd:SetReverse(true)
					icon.cd:SetHideCountdownNumbers(true)
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

--From http://forums.wowace.com/showpost.php?p=325677&postcount=5
local specNameToRole = {}
for i = 1, GetNumClasses() do
	local _, class, classID = GetClassInfo(i)
	specNameToRole[class] = {}
	for j = 1, GetNumSpecializationsForClassID(classID) do
		local _, spec, _, _, _, role = GetSpecializationInfoForClassID(classID, j)
		specNameToRole[class][spec] = role
	end
end

local function GetBattleFieldIndexFromUnitName(name)
	local nameFromIndex
	for index = 1, GetNumBattlefieldScores() do
		nameFromIndex = GetBattlefieldScore(index)
		if nameFromIndex == name then
			return index
		end
	end
	return nil
end

function UF:UpdateRoleIcon()
	local lfdrole = self.LFDRole
	if not self.db then return; end
	local db = self.db.roleIcon;

	if (not db) or (db and not db.enable) then
		lfdrole:Hide()
		return
	end
	
	local isInstance, instanceType = IsInInstance()
	local role

	if isInstance and instanceType == "pvp" then
		local name = GetUnitName(self.unit, true)
		local index = GetBattleFieldIndexFromUnitName(name)
		if index then
			local _, _, _, _, _, _, _, _, classToken, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(index)
			if classToken and talentSpec then
				role = specNameToRole[classToken][talentSpec]
			else
				role = UnitGroupRolesAssigned(self.unit) --Fallback
			end
		else
			role = UnitGroupRolesAssigned(self.unit) --Fallback
		end
	else
		role = UnitGroupRolesAssigned(self.unit)
		if self.isForced and role == 'NONE' then
			local rnd = random(1, 3)
			role = rnd == 1 and "TANK" or (rnd == 2 and "HEALER" or (rnd == 3 and "DAMAGER"))
		end
	end

	if (self.isForced or UnitIsConnected(self.unit)) and ((role == "DAMAGER" and db.damager) or (role == "HEALER" and db.healer) or (role == "TANK" and db.tank)) then
		lfdrole:SetTexture(roleIconTextures[role])
		lfdrole:Show()
	else
		lfdrole:Hide()
	end
end

function UF:RaidRoleUpdate()
	local anchor = self:GetParent()
	local leader = anchor:GetParent().Leader
	local assistant = anchor:GetParent().Assistant
	local masterLooter = anchor:GetParent().MasterLooter

	if not leader or not masterLooter or not assistant then return; end

	local unit = anchor:GetParent().unit
	local db = anchor:GetParent().db
	local isLeader = leader:IsShown()
	local isMasterLooter = masterLooter:IsShown()
	local isAssist = assistant:IsShown()

	leader:ClearAllPoints()
	assistant:ClearAllPoints()
	masterLooter:ClearAllPoints()

	if db and db.raidRoleIcons then
		if isLeader and db.raidRoleIcons.position == 'TOPLEFT' then
			leader:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isLeader and db.raidRoleIcons.position == 'TOPRIGHT' then
			leader:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPLEFT' then
			assistant:Point('LEFT', anchor, 'LEFT')
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		elseif isAssist and db.raidRoleIcons.position == 'TOPRIGHT' then
			assistant:Point('RIGHT', anchor, 'RIGHT')
			masterLooter:Point('LEFT', anchor, 'LEFT')
		elseif isMasterLooter and db.raidRoleIcons.position == 'TOPLEFT' then
			masterLooter:Point('LEFT', anchor, 'LEFT')
		else
			masterLooter:Point('RIGHT', anchor, 'RIGHT')
		end
	end
end

function UF:Construct_RoleIcon(frame)
	local f = CreateFrame('Frame', nil, frame)

	local tex = f:CreateTexture(nil, "ARTWORK")
	tex:Size(17)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)
	tex.Override = UF.UpdateRoleIcon
	frame:RegisterEvent("UNIT_CONNECTION", UF.UpdateRoleIcon)

	return tex
end

