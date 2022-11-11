local _, ns = ...
local oUF = ns.oUF

local VISIBLE = 1
local HIDDEN = 0

local wipe = wipe
local pcall = pcall
local floor = floor
local unpack = unpack
local tinsert = tinsert
local infinity = math.huge

local _G = _G
local GetTime = GetTime
local UnitAura = UnitAura
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitIsEnemy = UnitIsEnemy
local UnitReaction = UnitReaction
local GameTooltip = GameTooltip

local LCD = oUF.isClassic and LibStub('LibClassicDurations', true)

local DAY, HOUR, MINUTE = 86400, 3600, 60
local function FormatTime(s)
	if s == infinity then return end

	if s < MINUTE then
		return '%.1fs', s
	elseif s < HOUR then
		return '%dm %ds', s/60%60, s%60
	elseif s < DAY then
		return '%dh %dm', s/(60*60), s/60%60
	else
		return '%dd %dh', s/DAY, (s / HOUR) - (floor(s/DAY) * 24)
	end
end

local function onEnter(self)
	if GameTooltip:IsForbidden() or not self:IsVisible() then return end

	GameTooltip:SetOwner(self, self.tooltipAnchor)
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
end

local function onLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

local function onUpdate(bar, elapsed)
	bar.elapsed = (bar.elapsed or 0) + elapsed

	if bar.elapsed > 0.01 then
		local remain = (bar.expiration - GetTime()) / (bar.modRate or 1)
		bar:SetValue(remain / bar.duration)
		bar.timeText:SetFormattedText(FormatTime(remain))

		bar.elapsed = 0
	end
end

local function createAuraBar(element, index)
	local bar = CreateFrame('StatusBar', element:GetName() .. 'StatusBar' .. index, element)
	bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	bar:SetMinMaxValues(0, 1)
	bar.tooltipAnchor = element.tooltipAnchor
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', onLeave)
	bar:EnableMouse(false)

	local spark = bar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	spark:SetWidth(12)
	spark:SetBlendMode("ADD")
	spark:SetPoint('CENTER', bar:GetStatusBarTexture(), 'RIGHT')

	local icon = bar:CreateTexture(nil, 'ARTWORK')
	icon:SetPoint('RIGHT', bar, 'LEFT', -element.barSpacing, 0)
	icon:SetSize(element.height, element.height)

	local nameText = bar:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	nameText:SetPoint('LEFT', bar, 'LEFT', 2, 0)

	local timeText = bar:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	timeText:SetPoint('RIGHT', bar, 'RIGHT', -2, 0)

	bar.icon = icon
	bar.spark = spark
	bar.nameText = nameText
	bar.timeText = timeText
	bar.__owner = element

	if(element.PostCreateBar) then element:PostCreateBar(bar) end

	return bar
end

local function customFilter(element, unit, button, name)
	if (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name) then
		return true
	end
end

local function updateBar(element, bar)
	if bar.count > 1 then
		bar.nameText:SetFormattedText('[%d] %s', bar.count, bar.spell)
	else
		bar.nameText:SetText(bar.spell)
	end

	if not bar.noTime and element.sparkEnabled then
		bar.spark:Show()
	else
		bar.spark:Hide()
	end

	local r, g, b = .2, .6, 1
	local debuffType = bar.debuffType
	if element.buffColor then r, g, b = unpack(element.buffColor) end
	if bar.filter == 'HARMFUL' then
		if not debuffType or debuffType == '' then
			debuffType = 'none'
		end

		local color = _G.DebuffTypeColor[debuffType]
		r, g, b = color.r, color.g, color.b
	end

	bar.icon:SetTexture(bar.texture)
	bar.icon:SetSize(element.height, element.height)
	bar:SetStatusBarColor(r, g, b)
	bar:SetSize(element.width, element.height)
	bar:EnableMouse(not element.disableMouse)
	bar:SetID(bar.index)
	bar:Show()

	if element.PostUpdateBar then
		element:PostUpdateBar(bar.unit, bar, bar.index, bar.position, bar.duration, bar.expiration, debuffType, bar.isStealable)
	end
end

local function updateAura(element, unit, index, offset, filter, isDebuff, visible)
	local name, texture, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3

	if LCD and not UnitIsUnit('player', unit) then
		local durationNew, expirationTimeNew
		name, texture, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3 = LCD:UnitAura(unit, index, filter)

		if spellID then
			durationNew, expirationTimeNew = LCD:GetAuraDurationByUnit(unit, spellID, source, name)
		end

		if durationNew and durationNew > 0 then
			duration, expiration = durationNew, expirationTimeNew
		end
	else
		name, texture, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3 = UnitAura(unit, index, filter)
	end

	if not name then return end

	local position = visible + offset + 1
	local bar = element[position]
	if not bar then
		bar = (element.CreateBar or createAuraBar) (element, position)
		tinsert(element, bar)
		element.createdBars = element.createdBars + 1
	end

	element.active[position] = bar

	bar.unit = unit
	bar.count = count
	bar.index = index
	bar.caster = source
	bar.filter = filter
	bar.texture = texture
	bar.isDebuff = isDebuff
	bar.debuffType = debuffType
	bar.isStealable = isStealable
	bar.isPlayer = source == 'player' or source == 'vehicle'
	bar.position = position
	bar.duration = duration
	bar.expiration = expiration
	bar.modRate = modRate
	bar.spellID = spellID
	bar.spell = name
	bar.noTime = (duration == 0 and expiration == 0)

	local show = (element.CustomFilter or customFilter) (element, unit, bar, name, texture,
		count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID,
		canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3)

	updateBar(element, bar)
	bar:SetScript('OnUpdate', not bar.noTime and onUpdate or nil)

	return show and VISIBLE or HIDDEN
end

local function SetPosition(element, from, to)
	local height = element.height
	local spacing = element.spacing
	local anchor = element.initialAnchor
	local barSpacing = element.barSpacing
	local growth = element.growth == 'DOWN' and -1 or 1

	for i = from, to do
		local bar = element.active[i]
		if not bar then break end

		bar:ClearAllPoints()
		bar:SetPoint(anchor, element, anchor, barSpacing, (i == 1 and 0) or (growth * ((i - 1) * (height + spacing))))

		if bar.noTime then
			bar:SetValue(1)
			bar.timeText:SetText()
		end
	end
end

local function filterBars(element, unit, filter, limit, isDebuff, offset, dontHide)
	if(not offset) then offset = 0 end
	local index = 1
	local visible = 0
	local hidden = 0
	while(visible < limit) do
		local result = updateAura(element, unit, index, offset, filter, isDebuff, visible)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		elseif(result == HIDDEN) then
			hidden = hidden + 1
		end

		index = index + 1
	end

	if(not dontHide) then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit, isFullUpdate, updatedAuras)
	if not unit or self.unit ~= unit then return end

	local element = self.AuraBars
	if(element) then
		if(element.PreUpdate) then element:PreUpdate(unit) end

		wipe(element.active)

		local isEnemy = UnitIsEnemy(unit, 'player')
		local reaction = UnitReaction(unit, 'player')
		local filter = (not isEnemy and (not reaction or reaction > 4) and (element.friendlyAuraType or 'HELPFUL')) or element.enemyAuraType or 'HARMFUL'
		local visibleAuras = filterBars(element, unit, filter, element.maxBars, filter == 'HARMFUL', 0)

		element.visibleAuras = visibleAuras

		local fromRange, toRange
		if(element.PreSetPosition) then
			fromRange, toRange = element:PreSetPosition(element.maxBars)
		end

		if(fromRange or element.createdBars > element.anchoredBars) then
			(element.SetPosition or SetPosition) (element, fromRange or element.anchoredBars + 1, toRange or element.createdBars)
			element.anchoredBars = element.createdBars
		end

		if(element.PostUpdate) then element:PostUpdate(unit) end
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	UpdateAuras(self, event, unit)

	-- Assume no event means someone wants to re-anchor things. This is usually
	-- done by UpdateAllElements and :ForceUpdate.
	if(event == 'ForceUpdate' or not event) then
		local element = self.AuraBars
		if(element) then
			(element.SetPosition or SetPosition) (element, 1, element.createdBars)
		end
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.AuraBars

	if(element) then
		oUF:RegisterEvent(self, 'UNIT_AURA', UpdateAuras)

		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.active = {}

		element.anchoredBars = 0
		element.createdBars = element.createdBars or 0
		element.width = element.width or 240
		element.height = element.height or 12
		element.sparkEnabled = element.sparkEnabled or true
		element.spacing = element.spacing or 2
		element.initialAnchor = element.initialAnchor or 'BOTTOMLEFT'
		element.growth = element.growth or 'UP'
		element.maxBars = element.maxBars or 32
		element.barSpacing = element.barSpacing or 2

		-- Avoid parenting GameTooltip to frames with anchoring restrictions,
		-- otherwise it'll inherit said restrictions which will cause issues
		-- with its further positioning, clamping, etc

		if(not pcall(self.GetCenter, self)) then
			element.tooltipAnchor = 'ANCHOR_CURSOR'
		else
			element.tooltipAnchor = element.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.AuraBars

	if(element) then
		oUF:UnregisterEvent(self, 'UNIT_AURA', UpdateAuras)

		element:Hide()
	end
end

oUF:AddElement('AuraBars', Update, Enable, Disable)
