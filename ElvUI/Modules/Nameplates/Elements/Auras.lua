local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

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

	nameplate.Auras = Auras
	nameplate.Buffs = Buffs
	nameplate.Debuffs = Debuffs
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
	button.icon:SetSnapToPixelGrid(false)
	button.icon:SetTexelSnappingBias(0)

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)
end

function NP:Update_Auras(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.auras.enable or db.debuffs.enable or db.buffs.enable then
		if not nameplate:IsElementEnabled('Aura') then
			nameplate:EnableElement('Aura')
		end

		if db.auras.enable then
			--nameplate.Auras.numDebuffs = db.debuffs.numAuras
			--nameplate.Auras.numBuffs = db.buffs.numAuras

			--if nameplate.Auras then
				--nameplate.Auras:Point('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, 15)
				--nameplate.Auras:Point('BOTTOMRIGHT', nameplate.Health, 'TOPRIGHT', 0, 15)
			--end

			nameplate.Debuffs:Hide()
			nameplate.Buffs:Hide()
			nameplate.Auras:Show()
		else
			nameplate.Auras:Hide()

			if db.debuffs.enable then
				nameplate.Debuffs.size = db.debuffs.size
				nameplate.Debuffs.num = db.debuffs.numAuras
				nameplate.Debuffs.onlyShowPlayer = false
				nameplate.Debuffs.spacing = db.debuffs.spacing
				nameplate.Debuffs["growth-y"] = db.debuffs.growthY
				nameplate.Debuffs["growth-x"] = db.debuffs.growthX
				nameplate.Debuffs.initialAnchor = E.InversePoints[db.debuffs.anchorPoint]

				local mult = floor(NP.db.clickableWidth / db.debuffs.size) < db.debuffs.numAuras
				nameplate.Debuffs:Size(NP.db.clickableWidth, (mult and 1 or 2) * db.debuffs.size)
				nameplate.Debuffs:ClearAllPoints()
				nameplate.Debuffs:Point(E.InversePoints[db.debuffs.anchorPoint] or 'TOPRIGHT', db.debuffs.attachTo == 'BUFFS' and nameplate.Buffs or nameplate, db.debuffs.anchorPoint or 'TOPRIGHT', 0, db.debuffs.yOffset)
				nameplate.Debuffs:Show()

				nameplate.Debuffs:ForceUpdate()
			else
				nameplate.Debuffs:Hide()
			end

			if db.buffs.enable then
				nameplate.Buffs.size = db.buffs.size
				nameplate.Buffs.num = db.buffs.numAuras
				nameplate.Buffs.onlyShowPlayer = false
				nameplate.Buffs.spacing = db.buffs.spacing
				nameplate.Buffs["growth-y"] = db.buffs.growthY
				nameplate.Buffs["growth-x"] = db.buffs.growthX
				nameplate.Buffs.initialAnchor = E.InversePoints[db.buffs.anchorPoint]

				local mult = floor(NP.db.clickableWidth / db.buffs.size) < db.buffs.numAuras
				nameplate.Buffs:Size(NP.db.clickableWidth, (mult and 1 or 2) * db.buffs.size)
				nameplate.Buffs:ClearAllPoints()
				nameplate.Buffs:Point(E.InversePoints[db.buffs.anchorPoint] or 'TOPLEFT', db.buffs.attachTo == 'DEBUFFS' and nameplate.Debuffs or nameplate, db.buffs.anchorPoint or 'TOPLEFT', 0, db.buffs.yOffset)
				nameplate.Buffs:Show()

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
			button:SetBackdropBorderColor(0.93, 0.91, 0.55, 1.0)
		else
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end

	local parent = button:GetParent()
	local db = NP.db.units[parent.__owner.frameType]
	local parentType = parent.type

	if db and db[parentType] then
		button:Size(db[parentType].size, db[parentType].size)
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
		if not filterName then return true end
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
	if not name then return end -- checking for an aura that is not there, pass nil to break while loop

	local parent = button:GetParent()
	local parentType = parent.type
	local db = NP.db.units[parent.__owner.frameType] and NP.db.units[parent.__owner.frameType][parentType]
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
