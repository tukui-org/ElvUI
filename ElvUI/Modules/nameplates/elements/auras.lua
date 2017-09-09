local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local select, unpack = select, unpack
local tinsert, tremove = table.insert, table.remove
local strlower, strsplit = string.lower, strsplit
local next, ipairs = next, ipairs
local match = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitAura = UnitAura
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit
local BUFF_STACKS_OVERFLOW = BUFF_STACKS_OVERFLOW

local auraCache = {}

function mod:SetAura(aura, index, name, icon, count, duration, expirationTime, spellID)
	aura.icon:SetTexture(icon);
	aura.name = name
	aura.spellID = spellID
	aura.expirationTime = expirationTime
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

function mod:AuraFilter(frame, frameNum, index, buffType, minDuration, maxDuration, priority, name, rank, texture, count, dispelType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
	local filterCheck, isUnit, isFriend, isPlayer, canDispell, allowDuration, noDuration, friendCheck, filterName = false, false, false, false, false, false, false, false, false

	if name then
		noDuration = (not duration or duration == 0)
		isFriend = frame.unit and UnitIsFriend('player', frame.unit)
		isPlayer = (caster == 'player' or caster == 'vehicle')
		isUnit = frame.unit and caster and UnitIsUnit(frame.unit, caster)
		canDispell = (buffType == 'Buffs' and isStealable) or (buffType == 'Debuffs' and dispelType and E:IsDispellableByMe(dispelType))
		allowDuration = noDuration or (duration and (duration > 0) and (maxDuration == 0 or duration <= maxDuration) and (minDuration == 0 or duration >= minDuration))
	else
		return nil
	end

	local filter, filterType, spellList, spell
	if priority ~= '' then
		for i=1, select('#',strsplit(",",priority)) do
			filterName = select(i, strsplit(",",priority))
			friendCheck = (isFriend and match(filterName, "^Friendly:([^,]*)")) or (not isFriend and match(filterName, "^Enemy:([^,]*)")) or nil
			if friendCheck ~= false then
				if friendCheck ~= nil and (G.unitframe.specialFilters[friendCheck] or E.global.unitframe.aurafilters[friendCheck]) then
					filterName = friendCheck -- this is for our filters to handle Friendly and Enemy
				end
				filter = E.global.unitframe.aurafilters[filterName]
				if filter then
					filterType = filter.type
					spellList = filter.spells
					spell = spellList and (spellList[spellID] or spellList[name])

					if filterType and filterType == 'Whitelist' and spell and spell.enable and allowDuration then
						filterCheck = true
						break -- STOP: allowing whistlisted spell
					elseif filterType and filterType == 'Blacklist' and spell and spell.enable then
						filterCheck = false
						break -- STOP: blocking blacklisted spell
					end
				elseif filterName == 'Personal' and isPlayer and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'nonPersonal' and not isPlayer and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'Boss' and isBossDebuff and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'CastByUnit' and (caster and isUnit) and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'notCastByUnit' and (caster and not isUnit) and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'Dispellable' and canDispell and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'CastByPlayers' and casterIsPlayer then
					filterCheck = true
					break -- STOP
				elseif filterName == 'blockCastByPlayers' and casterIsPlayer then
					filterCheck = false
					break -- STOP
				elseif filterName == 'blockNoDuration' and noDuration then
					filterCheck = false
					break -- STOP
				elseif filterName == 'blockNonPersonal' and not isPlayer then
					filterCheck = false
					break -- STOP
				end
			end
		end
	else
		filterCheck = true -- Allow all auras to be shown when the filter list is empty
	end

	if filterCheck == true then
		mod:SetAura(frame[buffType].icons[frameNum], index, name, texture, count, duration, expiration, spellID)
		return true
	end

	return false
end

function mod:UpdateElement_Auras(frame)
	local hasBuffs, hasDebuffs, showAura = false, false
	local filterType, buffType, buffTypeLower, index, frameNum, maxAuras, minDuration, maxDuration, priority

	--Auras
	for i = 1, 2 do
		filterType = (i == 1 and 'HELPFUL' or 'HARMFUL')
		buffType = (i == 1 and 'Buffs' or 'Debuffs')
		buffTypeLower = strlower(buffType)
		index = 1;
		frameNum = 1;
		maxAuras = #frame[buffType].icons;
		minDuration = self.db.units[frame.UnitType][buffTypeLower].filters.minDuration
		maxDuration = self.db.units[frame.UnitType][buffTypeLower].filters.maxDuration
		priority = self.db.units[frame.UnitType][buffTypeLower].filters.priority

		self:HideAuraIcons(frame[buffType])
		if(self.db.units[frame.UnitType][buffTypeLower].enable) then
			while ( frameNum <= maxAuras ) do
				showAura = mod:AuraFilter(frame, frameNum, index, buffType, minDuration, maxDuration, priority, UnitAura(frame.unit, index, filterType))
				if showAura == nil then -- something went wrong (unitaura name was nil)
					break
				elseif showAura == true then -- has aura and passes checks
					if i == 1 then hasBuffs = true else hasDebuffs = true end
					frameNum = frameNum + 1;
				end
				index = index + 1;
			end
		end
	end

	local TopLevel = frame.HealthBar
	local TopOffset = ((self.db.units[frame.UnitType].showName and select(2, frame.Name:GetFont()) + 5) or 0)
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

	if (frame.TopLevelFrame ~= TopLevel) then
		frame.TopLevelFrame = TopLevel
		frame.TopOffset = TopOffset

		if (self.db.classbar.enable and self.db.classbar.position ~= "BELOW") then
			mod:ClassBar_Update(frame)
		end

		if (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable) then
			mod:ConfigureElement_Detection(frame)
		end
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

function mod:Auras_SizeChanged(width)
	local numAuras = #self.icons
	for i=1, numAuras do
		self.icons[i]:SetWidth(((width - (mod.mult*numAuras)) / numAuras) - (E.private.general.pixelPerfect and 0 or 3))
		self.icons[i]:SetHeight((self.db.baseHeight or 18) * (self:GetParent().HealthBar.currentScale or 1))
	end
	self:SetHeight((self.db.baseHeight or 18) * (self:GetParent().HealthBar.currentScale or 1))
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

function mod:ConstructElement_Auras(frame, side)
	local auras = CreateFrame("FRAME", nil, frame)

	auras:SetScript("OnSizeChanged", mod.Auras_SizeChanged)
	auras:SetHeight(18) -- this really doesn't matter
	auras.side = side
	auras.icons = {}

	return auras
end