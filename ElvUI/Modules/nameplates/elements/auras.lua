local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local select, unpack = select, unpack
local tinsert, tremove = table.insert, table.remove
local strlower, strsplit = string.lower, strsplit
local match = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitAura = UnitAura
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit

local auraCache = {}

function mod:SetAura(aura, index, name, icon, count, duration, expirationTime, spellID, buffType, isStealable, isFriend)
	aura.icon:SetTexture(icon);
	aura.name = name
	aura.spellID = spellID
	aura.expirationTime = expirationTime
	if ( count > 1 ) then
		aura.count:Show();
		aura.count:SetText(count);
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

	if buffType == "Buffs" then
		if isStealable and not isFriend then
			aura.backdrop:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			aura.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	aura:Show();
end

function mod:HideAuraIcons(auras)
	for i=1, #auras.icons do
		auras.icons[i]:Hide()

		-- cancel any StyleFilterAuraWaitTimer timers
		if auras.icons[i].hasMinTimer then
			auras.icons[i].hasMinTimer:Cancel()
			auras.icons[i].hasMinTimer = nil
		end
		if auras.icons[i].hasMaxTimer then
			auras.icons[i].hasMaxTimer:Cancel()
			auras.icons[i].hasMaxTimer = nil
		end
	end
end

function mod:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, ...)
	local friendCheck, filterName, filter, filterType, spellList, spell
	for i=1, select('#', ...) do
		filterName = select(i, ...)
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

				if filterType and (filterType == 'Whitelist') and (spell and spell.enable) and allowDuration then
					return true
				elseif filterType and (filterType == 'Blacklist') and (spell and spell.enable) then
					return false
				end
			elseif filterName == 'Personal' and isPlayer and allowDuration then
				return true
			elseif filterName == 'nonPersonal' and (not isPlayer) and allowDuration then
				return true
			elseif filterName == 'Boss' and isBossDebuff and allowDuration then
				return true
			elseif filterName == 'CastByUnit' and (caster and isUnit) and allowDuration then
				return true
			elseif filterName == 'notCastByUnit' and (caster and not isUnit) and allowDuration then
				return true
			elseif filterName == 'Dispellable' and canDispell and allowDuration then
				return true
			elseif filterName == 'notDispellable' and (not canDispell) and allowDuration then
				return true
			elseif filterName == 'CastByNPC' and (not casterIsPlayer) and allowDuration then
				return true
			elseif filterName == 'CastByPlayers' and casterIsPlayer and allowDuration then
				return true
			elseif filterName == 'blockCastByPlayers' and casterIsPlayer then
				return false
			elseif filterName == 'blockNoDuration' and noDuration then
				return false
			elseif filterName == 'blockNonPersonal' and (not isPlayer) then
				return false
			elseif filterName == 'blockDispellable' and canDispell then
				return false
			elseif filterName == 'blockNotDispellable' and (not canDispell) then
				return false
			end
		end
	end
end

function mod:AuraFilter(frame, frameNum, index, buffType, minDuration, maxDuration, priority, name, texture, count, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	if not name then return nil end -- checking for an aura that is not there, pass nil to break while loop
	local isFriend, filterCheck, isUnit, isPlayer, canDispell, allowDuration, noDuration = false

	noDuration = (not duration or duration == 0)
	allowDuration = noDuration or (duration and (duration > 0) and (maxDuration == 0 or duration <= maxDuration) and (minDuration == 0 or duration >= minDuration))

	if priority ~= '' then
		isFriend = frame.unit and UnitIsFriend('player', frame.unit) and not UnitCanAttack('player', frame.unit)
		isPlayer = (caster == 'player' or caster == 'vehicle')
		isUnit = frame.unit and caster and UnitIsUnit(frame.unit, caster)
		canDispell = (buffType == 'Buffs' and isStealable) or (buffType == 'Debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck = mod:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(",", priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	if filterCheck == true then
		mod:SetAura(frame[buffType].icons[frameNum], index, name, texture, count, duration, expiration, spellID, buffType, isStealable, isFriend)
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
				if showAura == nil then
					break -- used to break the while loop when index is over the limit of auras we have (unitaura name will pass nil)
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
			mod:ClassBar_Update()
		end

		if (self.db.units[frame.UnitType].detection and self.db.units[frame.UnitType].detection.enable) then
			mod:ConfigureElement_Detection(frame)
		end
	end
end

function mod:UpdateCooldownTextPosition()
	if self and self.timer and self.timer.text then
		self.timer.text:ClearAllPoints()
		if mod.db.durationPosition == "TOPLEFT" then
			self.timer.text:Point("TOPLEFT", 1, 1)
		elseif mod.db.durationPosition == "BOTTOMLEFT" then
			self.timer.text:Point("BOTTOMLEFT", 1, 1)
		elseif mod.db.durationPosition == "TOPRIGHT" then
			self.timer.text:Point("TOPRIGHT", 1, 1)
		else
			self.timer.text:Point("CENTER", 0, 0)
		end
	end
end

function mod:UpdateCooldownSettings(cd)
	if cd and cd.CooldownSettings then
		cd.CooldownSettings.font = LSM:Fetch("font", self.db.font)
		cd.CooldownSettings.fontSize = self.db.fontSize
		cd.CooldownSettings.fontOutline = self.db.fontOutline
		if cd.timer then
			E:Cooldown_OnSizeChanged(cd.timer, cd, cd:GetSize(), 'override')
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

	aura.cooldown.CooldownFontSize = 12
	aura.cooldown.CooldownOverride = 'nameplates'
	aura.cooldown.CooldownPreHook = self.UpdateCooldownTextPosition
	aura.cooldown.CooldownSettings = {
		['font'] = LSM:Fetch("font", self.db.font),
		['fontSize'] = self.db.fontSize,
		['fontOutline'] = self.db.fontOutline,
	}

	E:RegisterCooldown(aura.cooldown)

	aura.count = aura:CreateFontString(nil, "OVERLAY")
	aura.count:SetFont(LSM:Fetch("font", self.db.stackFont), self.db.stackFontSize, self.db.stackFontOutline)
	aura.count:Point("BOTTOMRIGHT", 1, 1)

	return aura
end

function mod:Auras_SizeChanged(width)
	local numAuras = #self.icons
	if numAuras == 0 then return end
	local overrideWidth = self.db.widthOverride and self.db.widthOverride > 0 and self.db.widthOverride
	local auraWidth = overrideWidth or (((width - mod.mult * numAuras) / numAuras) - (E.private.general.pixelPerfect and 0 or 3))
	local auraHeight = (self.db.baseHeight or 18) * (self:GetParent().HealthBar.currentScale or 1)

	for i=1, numAuras do
		self.icons[i]:SetWidth(auraWidth)
		self.icons[i]:SetHeight(auraHeight)
	end

	self:SetHeight(auraHeight)
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

	local stackFont = LSM:Fetch("font", self.db.stackFont)
	local aurasHeight = auras.db.baseHeight or 18

	for i=1, maxAuras do
		auras.icons[i] = auras.icons[i] or tremove(auraCache) or mod:CreateAuraIcon(auras)
		auras.icons[i]:SetParent(auras)
		auras.icons[i]:ClearAllPoints()
		auras.icons[i]:Hide()
		auras.icons[i]:SetHeight(aurasHeight)

		-- update stacks font on NAME_PLATE_UNIT_ADDED
		if auras.icons[i].count then
			auras.icons[i].count:SetFont(stackFont, self.db.stackFontSize, self.db.stackFontOutline)
		end

		-- update the cooldown text font defaults on NAME_PLATE_UNIT_ADDED
		self:UpdateCooldownSettings(auras.icons[i].cooldown)
		self.UpdateCooldownTextPosition(auras.icons[i].cooldown)

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
