local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

function NP:Construct_Buffs(nameplate)
	local Buffs = CreateFrame('Frame', nameplate:GetDebugName()..'Buffs', nameplate)
	Buffs:SetFrameStrata(nameplate:GetFrameStrata())
	Buffs:SetFrameLevel(5)

	Buffs.disableMouse = true

	Buffs.type = 'buffs'

	function Buffs:PostCreateIcon(button)
		NP:Construct_AuraIcon(button)
	end

	function Buffs:PostUpdateIcon(unit, button)
		NP:PostUpdateAura(unit, button)
	end

	function Buffs:CustomFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
		button.name, button.spellID, button.expiration = name, spellID, expiration
		return NP:AuraFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	end

	return Buffs
end

function NP:Construct_Debuffs(nameplate)
	local Debuffs = CreateFrame('Frame', nameplate:GetDebugName()..'Debuffs', nameplate)
	Debuffs:SetFrameStrata(nameplate:GetFrameStrata())
	Debuffs:SetFrameLevel(5)

	Debuffs.disableMouse = true

	Debuffs.type = 'debuffs'

	function Debuffs:PostCreateIcon(button)
		NP:Construct_AuraIcon(button)
	end

	function Debuffs:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
		NP:PostUpdateAura(unit, button, index, position, duration, expiration, debuffType, isStealable)
	end

	function Debuffs:CustomFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
		button.name, button.spellID, button.expiration = name, spellID, expiration
		return NP:AuraFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	end

	return Debuffs
end

function NP:Construct_Auras(nameplate)
	local Auras = CreateFrame('Frame', nameplate:GetDebugName()..'Auras', nameplate)
	Auras:SetFrameStrata(nameplate:GetFrameStrata())
	Auras:SetFrameLevel(5)
	Auras:SetSize(300, 27)

	Auras.disableMouse = true
	Auras.gap = true
	Auras.size = 27
	Auras.numDebuffs = 4
	Auras.numBuffs = 4
	Auras.spacing = E.Border * 2
	Auras.onlyShowPlayer = false
	Auras.initialAnchor = 'BOTTOMLEFT'
	Auras['growth-x'] = 'RIGHT'
	Auras['growth-y'] = 'UP'
	Auras.type = 'auras'

	function Auras:PostCreateIcon(button)
		NP:Construct_AuraIcon(button)
	end

	function Auras:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
		NP:PostUpdateAura(unit, button, index, position, duration, expiration, debuffType, isStealable)
	end

	function Auras:CustomFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
		button.name, button.spellID, button.expiration = name, spellID, expiration
		return NP:AuraFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	end

	return Auras
end

function NP:Construct_AuraIcon(button)
	if not button then return end

	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:SetJustifyH('CENTER')

	button:SetTemplate()

	button.cd:SetReverse(true)
	button.cd:SetInside(button)

	button.cd.CooldownFontSize = 12
	button.cd.CooldownOverride = 'nameplates'
	button.cd.CooldownPreHook = function(cd) NP:UpdateCooldownTextPosition(cd) end

	button.cd.CooldownSettings = {
		['font'] = LSM:Fetch('font', NP.db.font),
		['fontSize'] = NP.db.fontSize,
		['fontOutline'] = NP.db.fontOutline,
	}

	E:RegisterCooldown(button.cd)

	button.icon:SetInside()
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetDrawLayer('ARTWORK')

	button.count:ClearAllPoints()
	button.count:SetPoint('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)
end

function NP:Update_Auras(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.debuffs.enable or db.buffs.enable then
		if not nameplate:IsElementEnabled('Aura') then
			nameplate:EnableElement('Aura')
		end

		--nameplate.Auras.numDebuffs = db.debuffs.numAuras
		--nameplate.Auras.numBuffs = db.buffs.numAuras

		-- Azil, is this needed??
		--if nameplate.Auras then
			--nameplate.Auras:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, 15)
			--nameplate.Auras:SetPoint('BOTTOMRIGHT', nameplate.Health, 'TOPRIGHT', 0, 15)
		--end

		if nameplate.Debuffs then
			if db.debuffs.enable then
				local x, y = 'TOPRIGHT', 0
				x, y = E:GetXYOffset(db.debuffs.anchorPoint, db.debuffs.spacing)

				nameplate.Debuffs:Show()
				nameplate.Debuffs:SetSize(NP.db.clickableWidth, 27)
				nameplate.Debuffs:ClearAllPoints()
				nameplate.Debuffs:SetPoint(E.InversePoints[db.debuffs.anchorPoint] or 'TOPRIGHT', nameplate, db.debuffs.anchorPoint or 'TOPRIGHT', x + db.debuffs.xOffset, y + db.debuffs.yOffset)

				nameplate.Debuffs.size = db.debuffs.size
				nameplate.Debuffs.num = db.debuffs.numAuras
				nameplate.Debuffs.onlyShowPlayer = false
				nameplate.Debuffs.spacing = db.debuffs.spacing
				nameplate.Debuffs["growth-y"] = db.debuffs.growthY
				nameplate.Debuffs["growth-x"] = db.debuffs.growthX
				nameplate.Debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint]

				nameplate.Debuffs:ForceUpdate()
			else
				nameplate.Debuffs:Hide()
			end
		end

		if nameplate.Buffs then
			if db.buffs.enable then
				local x, y = 'TOPLEFT', 0
				x, y = E:GetXYOffset(db.buffs.anchorPoint or 0, db.buffs.spacing or 0)

				nameplate.Buffs:Show()
				nameplate.Buffs:SetSize(NP.db.clickableWidth, 27)
				nameplate.Buffs:ClearAllPoints()
				nameplate.Buffs:SetPoint(E.InversePoints[db.buffs.anchorPoint] or 'TOPLEFT', nameplate, db.buffs.anchorPoint or 'TOPLEFT', x + db.buffs.xOffset , y + db.buffs.yOffset)

				nameplate.Buffs.size = db.buffs.size
				nameplate.Buffs.num = db.buffs.numAuras
				nameplate.Buffs.onlyShowPlayer = false
				nameplate.Buffs.spacing = db.buffs.spacing
				nameplate.Buffs["growth-y"] = db.buffs.growthY
				nameplate.Buffs["growth-x"] = db.buffs.growthX
				nameplate.Buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint]

				nameplate.Buffs:ForceUpdate()
			else
				nameplate.Buffs:Hide()
			end
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
			if button.name and (button.name == 'Unstable Affliction' or button.name == 'Vampiric Touch') and E.myclass ~= 'WARLOCK' then
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

	local parent = button:GetParent()
	local db = NP.db.units[parent.__owner.frameType]
	local parentType = parent.type

	if db and db[parentType] then
		button:SetSize(db[parentType].size, db[parentType].size)
	end

	if button:IsShown() and button.cd then
		NP:UpdateCooldownTextPosition(button.cd)
		NP:UpdateCooldownSettings(button.cd)
	end
end

function NP:UpdateCooldownTextPosition(cd)
	if cd.timer and cd.timer.text then
		cd.timer.text:ClearAllPoints()
		if NP.db.durationPosition == 'TOPLEFT' then
			cd.timer.text:Point('TOPLEFT', 1, 1)
		elseif NP.db.durationPosition == 'BOTTOMLEFT' then
			cd.timer.text:Point('BOTTOMLEFT', 1, 1)
		elseif NP.db.durationPosition == 'TOPRIGHT' then
			cd.timer.text:Point('TOPRIGHT', 1, 1)
		else
			cd.timer.text:Point('CENTER', 1, 1)
		end
	end
end

function NP:UpdateCooldownSettings(cd)
	if cd and cd.CooldownSettings then
		cd.CooldownSettings.font = LSM:Fetch('font', NP.db.font)
		cd.CooldownSettings.fontSize = NP.db.fontSize
		cd.CooldownSettings.fontOutline = NP.db.fontOutline
		if cd.timer then
			E:Cooldown_OnSizeChanged(cd.timer, cd, cd:GetSize(), 'override')
		end
	end
end

function NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, ...)
	local friendCheck, filterName, filter, filterType, spellList, spell
	for i=1, select('#', ...) do
		filterName = select(i, ...)
		friendCheck = (isFriend and strmatch(filterName, '^Friendly:([^,]*)')) or (not isFriend and strmatch(filterName, '^Enemy:([^,]*)')) or nil
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
	local parent = button:GetParent()
	local db = NP.db.units[parent.__owner.frameType]
	local parentType = parent.type
	if not (db and db[parentType]) then
		return true
	end

	local isPlayer = button.isPlayer
	local isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)

	if not db[parentType].filters then
		return true
	end

	local priority = db[parentType].filters.priority

	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and (duration > 0) and db[parentType].filters.maxDuration == 0 or duration <= db[parentType].filters.maxDuration) and (db[parentType].filters.minDuration == 0 or duration >= db[parentType].filters.minDuration)
	local filterCheck

	if priority ~= '' then
		local isUnit = unit and caster and UnitIsUnit(unit, caster)
		local canDispell = (parentType == 'Buffs' and isStealable) or (parentType == 'Debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck = NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(',', priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	if filterCheck == true then
		return true
	end

	return false
end
