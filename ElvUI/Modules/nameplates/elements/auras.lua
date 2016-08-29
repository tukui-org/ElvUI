local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local select, unpack = select, unpack
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local BUFF_STACKS_OVERFLOW = BUFF_STACKS_OVERFLOW

local auraCache = {}

function mod:SetAura(aura, index, name, filter, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, spellId, isBossAura)
	aura.icon:SetTexture(icon);
	aura.name = name
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 10 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		aura.count:Show();
		aura.count:SetText(countText);
	else
		aura.count:Hide();
	end
	aura:SetID(index);
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		aura.cooldown:SetCooldown(startTime, duration);
		aura.cooldown:Show();
	else
		aura.cooldown:Hide();
	end
	aura:Show();
end

function mod:HideAuraIcons(auras)
	for i=1, #auras.icons do
		auras.icons[i]:Hide()
	end
end

--Allow certain auras with a duration of 0
local durationOverride = {
	[146739] = true, --Absolute Corruption (Warlock)
	[203981] = true, --Soul fragments (Demon Hunter)
}

function mod:UpdateElement_Auras(frame)
	local hasBuffs = false
	local hasDebuffs = false

	--Debuffs
	local index = 1;
	local frameNum = 1;
	local filter = nil;
	local maxDebuffs = #frame.Debuffs.icons;
	--Show both Boss buffs & debuffs in the debuff location
	--First, we go through all the debuffs looking for any boss flagged ones.

	self:HideAuraIcons(frame.Debuffs)
	if(self.db.units[frame.UnitType].debuffs.enable) then
		frame.Debuffs.shownIDs = {}
		if(self.db.units[frame.UnitType].debuffs.filters.boss) then
			while ( frameNum <= maxDebuffs ) do
				local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, _, isBossAura = UnitDebuff(frame.displayedUnit, index, filter);
				if ( name ) then
					if ( isBossAura ) then
						local debuffFrame = frame.Debuffs.icons[frameNum];
						mod:SetAura(debuffFrame, index, name, filter, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, spellId, isBossAura)
						frameNum = frameNum + 1;
						frame.Debuffs.shownIDs[spellId] = true
						hasDebuffs = true
					end
				else
					break;
				end
				index = index + 1;
			end
		end

		if(self.db.units[frame.UnitType].debuffs.filters.personal) then
			index = 1
			--Now look for personal debuffs
			while ( frameNum <= maxDebuffs ) do
				local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, _, isBossAura = UnitDebuff(frame.displayedUnit, index, filter);
				if ( name ) then
					if (unitCaster == mod.playerUnitToken and not frame.Debuffs.shownIDs[spellId] and (duration > 0 or (duration == 0 and durationOverride[spellId])) and duration <= self.db.units[frame.UnitType].debuffs.filters.maxDuration) then
						local debuffFrame = frame.Debuffs.icons[frameNum];
						mod:SetAura(debuffFrame, index, name, filter, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, spellId, isBossAura)
						frameNum = frameNum + 1;
						frame.Debuffs.shownIDs[spellId] = true
						hasDebuffs = true
					end
				else
					break;
				end
				index = index + 1;
			end
		end
	end

	--Buffs
	index = 1
	local maxBuffs = #frame.Buffs.icons
	frameNum = 1
	self:HideAuraIcons(frame.Buffs)
	frame.Buffs.shownIDs = {}
	--Now look for boss buffs
	if(self.db.units[frame.UnitType].buffs.enable) then
		if(self.db.units[frame.UnitType].buffs.filters.boss) then
			while ( frameNum <= maxBuffs ) do
				local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, _, isBossAura = UnitBuff(frame.displayedUnit, index, filter);
				if ( name ) then
					if ( isBossAura ) then
						local buffFrame = frame.Buffs.icons[frameNum];
						mod:SetAura(buffFrame, index, name, filter, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, spellId, isBossAura)
						frameNum = frameNum + 1;
						frame.Buffs.shownIDs[spellId] = true
						hasBuffs = true
					end
				else
					break;
				end
				index = index + 1;
			end
		end

		if(self.db.units[frame.UnitType].buffs.filters.personal) then
			index = 1
			--Now look the rest of buffs
			while ( frameNum <= maxBuffs ) do
				local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, _, isBossAura = UnitBuff(frame.displayedUnit, index, filter);
				if ( name ) then
					if ( unitCaster == mod.playerUnitToken and not frame.Buffs.shownIDs[spellId] and (duration > 0 or (duration == 0 and durationOverride[spellId])) and duration <= self.db.units[frame.UnitType].buffs.filters.maxDuration ) then
						local buffFrame = frame.Buffs.icons[frameNum];
						mod:SetAura(buffFrame, index, name, filter, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, spellId, isBossAura)
						frameNum = frameNum + 1;
						frame.Buffs.shownIDs[spellId] = true
						hasBuffs = true
					end
				else
					break;
				end
				index = index + 1;
			end
		end
	end

	local TopLevel = frame.HealthBar
	local TopOffset = self.db.units[frame.UnitType].showName and select(2, frame.Name:GetFont()) + 5 or 0
	if(hasDebuffs) then
		TopOffset = TopOffset + 3
		frame.Debuffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset)
		frame.Debuffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset)
		TopLevel = frame.Debuffs
		TopOffset = 3
	end

	if(hasBuffs) then
		if(not hasDebuffs) then
			TopOffset = TopOffset + 3
		end
		frame.Buffs:SetPoint("BOTTOMLEFT", TopLevel, "TOPLEFT", 0, TopOffset)
		frame.Buffs:SetPoint("BOTTOMRIGHT", TopLevel, "TOPRIGHT", 0, TopOffset)
		TopLevel = frame.Buffs
		TopOffset = 3
	end

	if(frame.TopLevelFrame ~= TopLevel and self.db.classbar.enable and self.db.classbar.position ~= "BELOW") then
		frame.TopLevelFrame = TopLevel
		frame.TopOffset = TopOffset
		mod:ClassBar_Update(frame)
	end
end

function mod:CreateAuraIcon(parent)
	local aura = CreateFrame("Frame", nil, parent)
	self:StyleFrame(aura)

	aura.icon = aura:CreateTexture(nil, "OVERLAY")
	aura.icon:SetAllPoints()
	aura.icon:SetTexCoord(unpack(E.TexCoords))

	aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
	aura.cooldown:SetAllPoints(aura)
	aura.cooldown:SetReverse(true)
	aura.cooldown.SizeOverride = 10
	E:RegisterCooldown(aura.cooldown)

	aura.count = aura:CreateFontString(nil, "OVERLAY")
	aura.count:SetPoint("BOTTOMRIGHT")
	aura.count:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	return aura
end

function mod:Auras_SizeChanged(width, height)
	local numAuras = #self.icons
	for i=1, numAuras do
		self.icons[i]:SetWidth((width - (mod.mult*numAuras)) / numAuras)
		self.icons[i]:SetHeight((self.db.baseHeight or 18) * self:GetParent().HealthBar.currentScale or 1)
	end
end

function mod:UpdateAuraIcons(auras)
	local maxAuras = auras.db.numAuras
	local numCurrentAuras = #auras.icons
	if numCurrentAuras > maxAuras then
		for i = maxAuras, numCurrentAuras do
			tinsert(auraCache, auras.icons[i])
			auras.icons[i]:Hide()
			auras.icons[i] = nil
		end
	end

	if numCurrentAuras ~= maxAuras then
		self.Auras_SizeChanged(auras, auras:GetWidth(), auras:GetHeight())
	end

	for i=1, maxAuras do
		auras.icons[i] = auras.icons[i] or tremove(auraCache) or mod:CreateAuraIcon(auras)
		auras.icons[i]:SetParent(auras)
		auras.icons[i]:ClearAllPoints()
		auras.icons[i]:Hide()
		auras.icons[i]:SetHeight(auras.db.baseHeight or 18)

		if(auras.side == "LEFT") then
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMLEFT", auras, "BOTTOMLEFT")
			else
				auras.icons[i]:SetPoint("LEFT", auras.icons[i-1], "RIGHT", E.Border + E.Spacing*3, 0)
			end
		else
			if(i == 1) then
				auras.icons[i]:SetPoint("BOTTOMRIGHT", auras, "BOTTOMRIGHT")
			else
				auras.icons[i]:SetPoint("RIGHT", auras.icons[i-1], "LEFT", -(E.Border + E.Spacing*3), 0)
			end
		end
	end
end

function mod:ConstructElement_Auras(frame, maxAuras, side)
	local auras = CreateFrame("FRAME", nil, frame)

	auras:SetScript("OnSizeChanged", mod.Auras_SizeChanged)
	auras:SetHeight(18) -- this really doesn't matter
	auras.side = side
	auras.icons = {}

	return auras
end