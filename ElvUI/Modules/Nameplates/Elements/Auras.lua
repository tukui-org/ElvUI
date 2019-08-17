local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local unpack = unpack
local select = select
local strfind = strfind
local strsplit = strsplit
local strmatch = strmatch
local CreateFrame = CreateFrame
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack
local UnitIsUnit = UnitIsUnit
local DebuffTypeColor = DebuffTypeColor

function NP:Auras_PostCreateIcon(button)
	NP:Construct_AuraIcon(button)
end

function NP:Auras_PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
	NP:PostUpdateAura(unit, button, index, position, duration, expiration, debuffType, isStealable)
end

function NP:Auras_CustomFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
	return NP:AuraFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
end

function NP:Buffs_PostCreateIcon(button)
	NP:Construct_AuraIcon(button)
end

function NP:Buffs_PostUpdateIcon(unit, button)
	NP:PostUpdateAura(unit, button)
end

function NP:Buffs_CustomFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
	return NP:AuraFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
end

function NP:Debuffs_PostCreateIcon(button)
	NP:Construct_AuraIcon(button)
end

function NP:Debuffs_PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
	NP:PostUpdateAura(unit, button, index, position, duration, expiration, debuffType, isStealable)
end

function NP:Debuffs_CustomFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
	return NP:AuraFilter(unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer)
end

function NP:Construct_Auras(nameplate)
	local Auras = CreateFrame('Frame', nameplate:GetDebugName()..'Auras', nameplate)
	Auras:SetFrameStrata(nameplate:GetFrameStrata())
	Auras:SetFrameLevel(5)
	Auras:Size(300, 27)

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

	local Buffs = CreateFrame('Frame', nameplate:GetDebugName()..'Buffs', nameplate)
	Buffs:SetFrameStrata(nameplate:GetFrameStrata())
	Buffs:SetFrameLevel(5)
	Buffs:Size(300, 27)
	Buffs.disableMouse = true
	Buffs.size = 27
	Buffs.num = 4
	Buffs.spacing = E.Border * 2
	Buffs.onlyShowPlayer = false
	Buffs.initialAnchor = 'BOTTOMLEFT'
	Buffs['growth-x'] = 'RIGHT'
	Buffs['growth-y'] = 'UP'
	Buffs.type = 'buffs'
	Buffs.forceShow = nameplate == _G.ElvNP_Test

	local Debuffs = CreateFrame('Frame', nameplate:GetDebugName()..'Debuffs', nameplate)
	Debuffs:SetFrameStrata(nameplate:GetFrameStrata())
	Debuffs:SetFrameLevel(5)
	Debuffs:Size(300, 27)
	Debuffs.disableMouse = true
	Debuffs.size = 27
	Debuffs.num = 4
	Debuffs.spacing = E.Border * 2
	Debuffs.onlyShowPlayer = false
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs['growth-x'] = 'RIGHT'
	Debuffs['growth-y'] = 'UP'
	Debuffs.type = 'debuffs'
	Debuffs.forceShow = nameplate == _G.ElvNP_Test

	Auras.PostCreateIcon = NP.Auras_PostCreateIcon
	Auras.PostUpdateIcon = NP.Auras_PostUpdateIcon
	Auras.CustomFilter = NP.Auras_CustomFilter
	Buffs.PostCreateIcon = NP.Buffs_PostCreateIcon
	Buffs.PostUpdateIcon = NP.Buffs_PostUpdateIcon
	Buffs.CustomFilter = NP.Buffs_CustomFilter
	Debuffs.PostCreateIcon = NP.Debuffs_PostCreateIcon
	Debuffs.PostUpdateIcon = NP.Debuffs_PostUpdateIcon
	Debuffs.CustomFilter = NP.Debuffs_CustomFilter

	nameplate.Auras_, nameplate.Buffs_, nameplate.Debuffs_ = Auras, Buffs, Debuffs
	nameplate.Auras, nameplate.Buffs, nameplate.Debuffs = Auras, Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end
	button:SetTemplate()

	button.cd:SetReverse(true)
	button.cd:SetInside(button)

	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetDrawLayer('ARTWORK')
	button.icon:SetInside()

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture()
	button.stealable:SetTexture()

	button.cd.CooldownOverride = 'nameplates'
	E:RegisterCooldown(button.cd)

	local auras = button:GetParent()
	button.db = auras and NP.db.units and NP.db.units[auras.__owner.frameType] and NP.db.units[auras.__owner.frameType][auras.type]

	NP:UpdateAuraSettings(button)
end

function NP:Configure_Auras(nameplate, auras, db)
	auras.size = db.size
	auras.num = db.numAuras
	auras.onlyShowPlayer = false
	auras.spacing = db.spacing
	auras["growth-y"] = db.growthY
	auras["growth-x"] = db.growthX
	auras.initialAnchor = E.InversePoints[db.anchorPoint]

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = db
			NP:UpdateAuraSettings(button)
		end

		index = index + 1
	end

	local mult = floor((nameplate.width or 150) / db.size) < db.numAuras
	auras:Size((nameplate.width or 150), (mult and 1 or 2) * db.size)
	auras:ClearAllPoints()
	auras:Point(E.InversePoints[db.anchorPoint] or 'TOPRIGHT', db.attachTo == 'BUFFS' and nameplate.Buffs or nameplate, db.anchorPoint or 'TOPRIGHT', db.xOffset, db.yOffset)
end

function NP:Update_Auras(nameplate, forceUpdate)
	local db = NP.db.units[nameplate.frameType]

	if db.auras.enable or db.debuffs.enable or db.buffs.enable then
		local wasDisabled = not nameplate:IsElementEnabled('Auras')
		if wasDisabled then
			nameplate:EnableElement('Auras')
		end

		if db.auras.enable then
			if nameplate.Debuffs then
				nameplate.Debuffs:Hide()
				nameplate.Debuffs = nil
			end

			if nameplate.Buffs then
				nameplate.Buffs:Hide()
				nameplate.Buffs = nil
			end

			nameplate.Auras = nameplate.Auras_
			nameplate.Auras:Show()

			if wasDisabled and forceUpdate then
				nameplate.Auras:ForceUpdate()
			end
		else
			if nameplate.Auras then
				nameplate.Auras:Hide()
				nameplate.Auras = nil
			end

			if db.debuffs.enable then
				nameplate.Debuffs = nameplate.Debuffs_
				NP:Configure_Auras(nameplate, nameplate.Debuffs, db.debuffs)
				nameplate.Debuffs:Show()

				if wasDisabled and forceUpdate then
					nameplate.Debuffs:ForceUpdate()
				end
			elseif nameplate.Debuffs then
				nameplate.Debuffs:Hide()
				nameplate.Debuffs = nil
			end

			if db.buffs.enable then
				nameplate.Buffs = nameplate.Buffs_
				NP:Configure_Auras(nameplate, nameplate.Buffs, db.buffs)
				nameplate.Buffs:Show()

				if wasDisabled and forceUpdate then
					nameplate.Buffs:ForceUpdate()
				end
			elseif nameplate.Buffs then
				nameplate.Buffs:Hide()
				nameplate.Buffs = nil
			end
		end
	else
		if nameplate:IsElementEnabled('Auras') then
			nameplate:DisableElement('Auras')
		end
	end
end

function NP:PostUpdateAura(unit, button)
	if button.isDebuff then
		if (not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
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
			button:SetBackdropBorderColor(0.93, 0.91, 0.55, 1.0)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	if button.needsUpdateCooldownPosition and (button.cd and button.cd.timer and button.cd.timer.text) then
		NP:UpdateAuraCooldownPosition(button)
	end
end

function NP:UpdateAuraSettings(button)
	if button.db then
		button.count:FontTemplate(LSM:Fetch('font', button.db.countFont), button.db.countFontSize, button.db.countFontOutline)
		button.count:ClearAllPoints()

		local point = (button.db and button.db.countPosition) or 'CENTER'
		if point == 'CENTER' then
			button.count:Point(point, 1, 0)
		else
			local bottom, right = point:find('BOTTOM'), point:find('RIGHT')
			button.count:SetJustifyH(right and 'RIGHT' or 'LEFT')
			button.count:Point(point, right and -1 or 1, bottom and 1 or -1)
		end
	end

	button:Size((button.db and button.db.size) or 26)

	button.needsUpdateCooldownPosition = true
end

function NP:UpdateAuraCooldownPosition(button)
	button.cd.timer.text:ClearAllPoints()
	local point = (button.db and button.db.durationPosition) or 'CENTER'
	if point == 'CENTER' then
		button.cd.timer.text:Point(point, 1, 0)
	else
		local bottom, right = point:find('BOTTOM'), point:find('RIGHT')
		button.cd.timer.text:Point(point, right and -1 or 1, bottom and 1 or -1)
	end

	button.needsUpdateCooldownPosition = nil
end

function NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, ...)
	for i=1, select('#', ...) do
		local filterName = select(i, ...)
		if not filterName then return true end
		local friendCheck = (isFriend and strmatch(filterName, '^Friendly:([^,]*)')) or (not isFriend and strmatch(filterName, '^Enemy:([^,]*)')) or nil
		if friendCheck ~= false then
			if friendCheck ~= nil and (G.unitframe.specialFilters[friendCheck] or E.global.unitframe.aurafilters[friendCheck]) then
				filterName = friendCheck -- this is for our filters to handle Friendly and Enemy
			end
			local filter = E.global.unitframe.aurafilters[filterName]
			if filter then
				local filterType = filter.type
				local spellList = filter.spells
				local spell = spellList and (spellList[spellID] or spellList[name])

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

function NP:AuraFilter(unit, button, name, _, count, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	if not name then return end -- checking for an aura that is not there, pass nil to break while loop

	local parent = button:GetParent()
	local parentType = parent.type
	local db = NP.db and NP.db.units and NP.db.units[parent.__owner.frameType] and NP.db.units[parent.__owner.frameType][parentType]
	if not db then return true end

	local isPlayer = (caster == 'player' or caster == 'vehicle')
	local isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)

	-- keep these same as in `UF:AuraFilter`
	button.isPlayer = isPlayer
	button.isFriend = isFriend
	button.isStealable = isStealable
	button.dtype = debuffType
	button.duration = duration
	button.expiration = expiration
	button.stackCount = count
	button.name = name
	button.spellID = spellID
	button.owner = caster
	button.spell = name
	button.priority = 0

	if not db.filters then return true end

	local priority = db.filters.priority
	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and (duration > 0) and db.filters.maxDuration == 0 or duration <= db.filters.maxDuration) and (db.filters.minDuration == 0 or duration >= db.filters.minDuration)
	local filterCheck

	if priority ~= '' then
		local isUnit = unit and caster and UnitIsUnit(unit, caster)
		local canDispell = (parentType == 'buffs' and isStealable) or (parentType == 'debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck = NP:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(',', priority))
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	return filterCheck
end
