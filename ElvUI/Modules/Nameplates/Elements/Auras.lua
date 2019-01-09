local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

function NP:Construct_Buffs(nameplate)
	local Buffs = CreateFrame("Frame", self:GetName()..'Buffs', nameplate)
	Buffs:SetFrameStrata(nameplate:GetFrameStrata())
	Buffs:SetFrameLevel(0)
	Buffs:SetSize(300, 27)

	Buffs.disableMouse = true
	Buffs.size = 27
	Buffs.num = 8
	Buffs.spacing = E.Border
	Buffs.onlyShowPlayer = false
	Buffs.initialAnchor = "BOTTOMLEFT"
	Buffs['growth-x'] = 'RIGHT'
	Buffs['growth-y'] = 'UP'

	Buffs.type = 'buffs'
	Buffs.PostCreateIcon = self.Construct_AuraIcon
	Buffs.PostUpdateIcon = self.PostUpdateAura
	Buffs.CustomFilter = self.AuraFilter

	return Buffs
end

function NP:Construct_Debuffs(nameplate)
	local Debuffs = CreateFrame("Frame", self:GetName()..'Debuffs', nameplate)
	Debuffs:SetFrameStrata(nameplate:GetFrameStrata())
	Debuffs:SetFrameLevel(0)
	Debuffs:SetSize(300, 27)

	Debuffs.disableMouse = true
	Debuffs.size = 27
	Debuffs.num = 8
	Debuffs.spacing = E.Border
	Debuffs.onlyShowPlayer = false
	Debuffs.initialAnchor = "BOTTOMRIGHT"
	Debuffs.onlyShowPlayer = false
	Debuffs['growth-x'] = 'LEFT'
	Debuffs['growth-y'] = 'UP'

	Debuffs.type = 'debuffs'
	Debuffs.PostCreateIcon = self.Construct_AuraIcon
	Debuffs.PostUpdateIcon = self.PostUpdateAura
	Debuffs.CustomFilter = self.AuraFilter

	return Debuffs
end

function NP:Construct_Auras(nameplate)
	local Auras = CreateFrame("Frame", self:GetName()..'Debuffs', nameplate)
	Auras:SetFrameStrata(nameplate:GetFrameStrata())
	Auras:SetFrameLevel(0)
	Auras:SetSize(300, 27)

	Auras.disableMouse = true
	Auras.gap = true
	Auras.size = 27
	Auras.numDebuffs = 4
	Auras.numBuffs = 4
	Auras.spacing = E.Border
	Auras.onlyShowPlayer = false
	Auras.initialAnchor = 'BOTTOMLEFT'
	Auras.onlyShowPlayer = false
	Auras['growth-x'] = 'RIGHT'
	Auras['growth-y'] = 'UP'

	Auras.PostCreateIcon = self.Construct_AuraIcon
	Auras.PostUpdateIcon = self.PostUpdateAura
	Auras.CustomFilter = self.AuraFilter

	return Auras
end

function NP:Update_Auras(nameplate)
	if nameplate.Auras then
		nameplate.Auras:SetPoint("BOTTOMLEFT", nameplate.Health, "TOPLEFT", 0, 15)
		nameplate.Auras:SetPoint("BOTTOMRIGHT", nameplate.Health, "TOPRIGHT", 0, 15)
	end

	if nameplate.Debuffs then
		nameplate.Debuffs:SetPoint("BOTTOMLEFT", nameplate.Health, "TOPLEFT", 0, 15)
		nameplate.Debuffs:SetPoint("BOTTOMRIGHT", nameplate.Health, "TOPRIGHT", 0, 15)
	end

	if nameplate.Buffs then
		nameplate.Buffs:SetPoint("BOTTOMLEFT", nameplate.Debuffs, "TOPLEFT", 0, 1)
		nameplate.Buffs:SetPoint("BOTTOMRIGHT", nameplate.Debuffs, "TOPRIGHT", 0, 1)
	end
end

function NP:Construct_AuraIcon(button)
	local offset = E.Border

	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:Point('CENTER', 1, 1)
	button.text:SetJustifyH('CENTER')

	button:SetTemplate()

	-- cooldown override settings
	--if not button.timerOptions then
	--	button.timerOptions = {}
	--end

	--button.timerOptions.reverseToggle = UF.db.cooldown.reverse
	--button.timerOptions.hideBlizzard = UF.db.cooldown.hideBlizzard

	--if UF.db.cooldown.override and E.TimeColors.unitframe then
	--	button.timerOptions.timeColors, button.timerOptions.timeThreshold = E.TimeColors.unitframe, UF.db.cooldown.threshold
	--else
	--	button.timerOptions.timeColors, button.timerOptions.timeThreshold = nil, nil
	--end

	--if UF.db.cooldown.checkSeconds then
	--	button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = UF.db.cooldown.hhmmThreshold, UF.db.cooldown.mmssThreshold
	--else
	--	button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = nil, nil
	--end

	--if UF.db.cooldown.fonts and UF.db.cooldown.fonts.enable then
	--	button.timerOptions.fontOptions = UF.db.cooldown.fonts
	--elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
	--	button.timerOptions.fontOptions = E.db.cooldown.fonts
	--else
	--	button.timerOptions.fontOptions = nil
	--end
	----------

	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetInside(button, offset, offset)
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetDrawLayer('ARTWORK')

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)

	-- support cooldown override
	--if not button.isRegisteredCooldown then
	--	button.CooldownOverride = 'unitframe'
	--	button.isRegisteredCooldown = true

	--	if not E.RegisteredCooldowns.unitframe then E.RegisteredCooldowns.unitframe = {} end
	--	tinsert(E.RegisteredCooldowns.unitframe, button)
	--end

	NP:UpdateAuraIconSettings(button, true)
end

function NP:EnableDisable_Auras(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.debuffs.enable or db.buffs.enable then
		if not nameplate:IsElementEnabled('Aura') then
			nameplate:EnableElement('Aura')
		end
	else
		if nameplate:IsElementEnabled('Aura') then
			nameplate:DisableElement('Aura')
		end
	end
end

function NP:PostUpdateAura(unit, button)
	if button.isDebuff then
		if(not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not strfind(unit, 'arena%d')) and true or false)
		else
			local color = (button.dtype and DebuffTypeColor[button.dtype]) or DebuffTypeColor.none
			if button.name and (button.name == "Unstable Affliction" or button.name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if button.isStealable and not button.isFriend then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	--if E:Cooldown_IsEnabled(button) then
	--	if button.expiration and button.duration and (button.duration ~= 0) then
	--		local getTime = GetTime()
	--		if not button:GetScript('OnUpdate') then
	--			button.expirationTime = button.expiration
	--			button.expirationSaved = button.expiration - getTime
	--			button.nextupdate = -1
	--			button:SetScript('OnUpdate', NP.UpdateAuraTimer)
	--		end
	--		if (button.expirationTime ~= button.expiration) or (button.expirationSaved ~= (button.expiration - getTime))  then
	--			button.expirationTime = button.expiration
	--			button.expirationSaved = button.expiration - getTime
	--			button.nextupdate = -1
	--		end
	--	end

	--	if button.expiration and button.duration and (button.duration == 0 or button.expiration <= 0) then
	--		button.expirationTime = nil
	--		button.expirationSaved = nil
	--		button:SetScript('OnUpdate', nil)
	--		if button.text:GetFont() then
	--			button.text:SetText('')
	--		end
	--	end
	--end
end

function NP:UpdateAuraIconSettings(auras, noCycle)
	local frame = auras:GetParent()
	local type = auras.type

	if noCycle then
		frame = auras:GetParent():GetParent()
		type = auras:GetParent().type
	end

	if not frame.db then return end
	local index, db = 1, frame.db[type]
	auras.db = db

	if db then
		local font = LSM:Fetch("font", E.db.nameplates.font)
		local fontSize = E.db.nameplates.fontSize or 11
		local outline = E.db.nameplates.fontOutline or "OUTLINE"
		local customFont

		if not noCycle then
			while auras[index] do
				if (not customFont) and (auras[index].timerOptions and auras[index].timerOptions.fontOptions) then
					customFont = LSM:Fetch("font", auras[index].timerOptions.fontOptions.font)
				end

				NP:AuraIconUpdate(frame, db, auras[index], font, outline, customFont)

				index = index + 1
			end
		else
			if auras.timerOptions and auras.timerOptions.fontOptions then
				customFont = LSM:Fetch("font", auras.timerOptions.fontOptions.font)
			end

			NP:AuraIconUpdate(frame, db, auras, font, outline, customFont)
		end
	end
end

function NP:AuraIconUpdate(frame, db, button, font, outline, customFont)
	if customFont and (button.timerOptions and button.timerOptions.fontOptions and button.timerOptions.fontOptions.enable) then
		button.text:FontTemplate(customFont, button.timerOptions.fontOptions.fontSize, button.timerOptions.fontOptions.fontOutline)
	else
		button.text:FontTemplate(font, db.fontSize, outline)
	end

	button.count:FontTemplate(font, db.countFontSize or db.fontSize, outline)
	button.unit = frame.unit -- used to update cooldown text

--	E:ToggleBlizzardCooldownText(button.cd, button)
end

function NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, ...)
	local friendCheck, filterName, filter, filterType, spellList, spell
	for i=1, select('#', ...) do
		filterName = select(i, ...)
		friendCheck = (isFriend and strmatch(filterName, "^Friendly:([^,]*)")) or (not isFriend and strmatch(filterName, "^Enemy:([^,]*)")) or nil
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

function NP:AuraFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	if not name then return nil end -- checking for an aura that is not there, pass nil to break while loop
	local db = NP.db.units[self.__owner.frameType]

	if not db then return end

	local isPlayer = button.isPlayer
	local isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)
	local priority = db[self.type].filters.priority

	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and (duration > 0) and (db[self.type].filters.maxDuration == 0 or duration <= db[self.type].filters.maxDuration) and (db[self.type].filters.minDuration == 0 or duration >= db[self.type].filters.minDuration))
	local filterCheck

	if priority ~= '' then
		local isUnit = unit and caster and UnitIsUnit(unit, caster)
		local canDispell = (self.type == 'Buffs' and isStealable) or (self.type == 'Debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck = NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(",", priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end


	if filterCheck == true then
		return true
	end

	return false
end
