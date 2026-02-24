local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule('NamePlates')
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local format, strlower, strfind = format, strlower, strfind
local tinsert, strsplit, strmatch = tinsert, strsplit, strmatch
local sort, wipe, next, unpack, floor = sort, wipe, next, unpack, floor
local utf8sub = string.utf8sub

local CreateFrame = CreateFrame
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit

local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor

local UNKNOWN = UNKNOWN
local PRIEST_COLOR = RAID_CLASS_COLORS.PRIEST

local DebuffColors = E.Libs.Dispel:GetDebuffTypeColor()
local DispelTypes = E.Libs.Dispel:GetMyDispelTypes()
local BadDispels = E.Libs.Dispel:GetBadList()

UF.SideAnchor = { TOP = true, BOTTOM = true, LEFT = true, RIGHT = true }
UF.GrowthPoints = { UP = 'BOTTOM', DOWN = 'TOP', RIGHT = 'LEFT', LEFT = 'RIGHT' }
UF.MatchGrowthY = { TOP = 'TOP', BOTTOM = 'BOTTOM' }
UF.MatchGrowthX = { LEFT = 'LEFT', RIGHT = 'RIGHT' }
UF.SourceStacks = { -- stack any source
	[370898] = 'Permeating Chill',	-- Evoker
	[395152] = 'Ebon Might'			-- Evoker (others)
}

UF.ExcludeStacks = {
	[110960] = 'Greater Invisibility',	-- Mage
	[295378] = 'Concentrated Flame',	-- Heart of Azeroth
	[324631] = 'Fleshcraft',			-- Necrolord

	-- Rogue Animacharges
	[323560] = 'Echoing Reprimand',	-- 2 Stack
	[354838] = 'Echoing Reprimand',	-- 3 Stack
	[323558] = 'Echoing Reprimand',	-- 4 Stack
	[323559] = 'Echoing Reprimand',	-- 5 Stack
}

UF.SmartPosition = {
	BUFFS_ON_DEBUFFS = {
		from = 'BUFFS', to = 'Debuffs',
		warning = format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]),
		func = function(db, buffs, debuffs)
			db.buffs.attachTo = 'DEBUFFS'
			buffs.attachTo = debuffs

			buffs.PostUpdate = nil
			debuffs.PostUpdate = UF.UpdateAuraSmartPosition
		end
	},
	DEBUFFS_ON_BUFFS = {
		from = 'DEBUFFS', to = 'Buffs',
		warning = format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]),
		func = function(db, buffs, debuffs)
			db.debuffs.attachTo = 'BUFFS'
			debuffs.attachTo = buffs

			debuffs.PostUpdate = nil
			buffs.PostUpdate = UF.UpdateAuraSmartPosition
		end
	}
}

UF.SmartPosition.FLUID_BUFFS_ON_DEBUFFS = E:CopyTable({fluid = true}, UF.SmartPosition.BUFFS_ON_DEBUFFS)
UF.SmartPosition.FLUID_DEBUFFS_ON_BUFFS = E:CopyTable({fluid = true}, UF.SmartPosition.DEBUFFS_ON_BUFFS)

function UF:Construct_Auras(frame)
	local auras = CreateFrame('Frame', '$parentAuras', frame)
	auras.PreSetPosition = UF.SortAuras
	auras.PostCreateButton = UF.Construct_AuraIcon
	auras.PostUpdateButton = UF.PostUpdateAura
	auras.SetPosition = UF.SetPosition
	auras.PreUpdate = UF.PreUpdateAura
	auras.CustomFilter = UF.AuraFilter
	auras.stacks = {}
	auras.rows = {}
	auras.type = 'auras'

	auras:SetFrameLevel(frame.RaisedElementParent.AuraLevel)
	auras:SetSize(1, 1)

	return auras
end

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', '$parentBuffs', frame)
	buffs.PreSetPosition = UF.SortAuras
	buffs.PostCreateButton = UF.Construct_AuraIcon
	buffs.PostUpdateButton = UF.PostUpdateAura
	buffs.SetPosition = UF.SetPosition
	buffs.PreUpdate = UF.PreUpdateAura
	buffs.CustomFilter = UF.AuraFilter
	buffs.stacks = {}
	buffs.rows = {}
	buffs.type = 'buffs'

	buffs:SetFrameLevel(frame.RaisedElementParent.AuraLevel)
	buffs:SetSize(1, 1)

	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', '$parentDebuffs', frame)
	debuffs.PreSetPosition = UF.SortAuras
	debuffs.PostCreateButton = UF.Construct_AuraIcon
	debuffs.PostUpdateButton = UF.PostUpdateAura
	debuffs.SetPosition = UF.SetPosition
	debuffs.PreUpdate = UF.PreUpdateAura
	debuffs.CustomFilter = UF.AuraFilter
	debuffs.stacks = {}
	debuffs.rows = {}
	debuffs.type = 'debuffs'

	debuffs:SetFrameLevel(frame.RaisedElementParent.AuraLevel)
	debuffs:SetSize(1, 1)

	return debuffs
end

function UF:GetAuraRow(element, row, col, width, height, spacing, anchor, inversed, middle)
	local holder = element.rows[row]
	if not holder then
		holder = CreateFrame('Frame', '$parentRow'..row, element)
		element.rows[row] = holder
	end

	holder:SetSize(col * width, height)

	-- update the holder only when the amount of rows changes
	if element.currentRow ~= row then
		element.currentRow = row

		holder:ClearAllPoints()
		element:Height((row + 1) * height - spacing)

		local last = element.rows[row - 1]
		if last and holder ~= last then
			if middle then
				holder:SetPoint(middle..anchor, last, E.InversePoints[middle]..anchor)
			else
				holder:SetPoint(anchor, last, inversed)
			end
		elseif middle then
			holder:SetPoint(middle..anchor, element)
		else
			holder:SetPoint(anchor, element)
		end
	elseif element.resetRowHeight then
		element:Height(height - spacing)

		element.resetRowHeight = nil
	end

	return holder
end

function UF:GetAuraPosition(element, onlyHeight)
	local size = element.size or 16
	local height = element.height or size
	if onlyHeight then return height end

	local growthX = element.growthX == 'LEFT' and -1 or 1
	local growthY = element.growthY == 'DOWN' and -1 or 1
	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	local inversed = E.InversePoints[anchor]
	local spacing = element.spacing or 0
	local width = size + spacing

	local y = growthY == 1 and 'BOTTOM' or 'TOP'
	local x = growthX == 1 and 'LEFT' or 'RIGHT'

	local center = anchor == 'TOP' or anchor == 'BOTTOM'
	local side = anchor == 'LEFT' or anchor == 'RIGHT'
	local point = (center or side) and (y..x) or anchor

	local cols = element.maxCols or floor(element:GetWidth() / width + 0.5)

	return anchor, inversed, growthX, growthY, width, height + spacing, spacing, cols, point, side and y
end

function UF:SetAuraPosition(element, button, index, anchor, inversed, growthX, growthY, width, height, spacing, cols, point, middle)
	local z, col, row = index - 1, 0, 0
	if cols > 0 then col, row = z % cols, floor(z / cols) end

	local holder = UF:GetAuraRow(element, row, col + 1, width, height, spacing, anchor, inversed, middle)
	button:ClearAllPoints()
	button:SetPoint(point, holder, point, col * width * growthX, growthY)
end

function UF:SetPosition(from, to)
	if to < from then
		if self.smartFluid then
			self:SetHeight(0.00001) -- dont scale this
			self.resetRowHeight = true
		else
			self:Height(UF:GetAuraPosition(self, true))
		end
	else
		local anchor, inversed, growthX, growthY, width, height, spacing, cols, point, middle = UF:GetAuraPosition(self)
		for index = from, to do
			local button = self.active[index]
			if not button then break end

			UF:SetAuraPosition(self, button, index, anchor, inversed, growthX, growthY, width, height, spacing, cols, point, middle)
		end
	end
end

function UF:Aura_OnClick()
	local keyDown = IsShiftKeyDown() and 'SHIFT' or IsAltKeyDown() and 'ALT' or IsControlKeyDown() and 'CTRL'
	if not keyDown then return end

	local listName = UF.db.modifiers[keyDown]
	local spellName, spellID = self.name, self.spellID
	if spellName and spellID and listName ~= 'NONE' then
		if not E.global.unitframe.aurafilters[listName].spells[spellID] then
			E:Print(format(L["The spell '%s' has been added to the '%s' unitframe aura filter."], spellName, listName))
			E.global.unitframe.aurafilters[listName].spells[spellID] = { enable = true, priority = 0 }
		else
			E.global.unitframe.aurafilters[listName].spells[spellID].enable = true
		end
	end
end

function UF:Construct_AuraIcon(button)
	button:SetTemplate(nil, nil, nil, nil, true)

	button.Icon:SetInside(button, UF.BORDER, UF.BORDER)
	button.Icon:SetDrawLayer('ARTWORK')

	button.Count:ClearAllPoints()
	button.Count:Point('BOTTOMRIGHT', 1, 1)
	button.Count:SetJustifyH('RIGHT')

	button.Overlay:SetTexture()
	button.Stealable:SetTexture()

	button:RegisterForClicks('RightButtonUp')
	button:SetScript('OnClick', UF.Aura_OnClick)

	button.Cooldown:SetAllPoints(button.Icon)

	E:RegisterCooldown(button.Cooldown, 'unitframe')

	local auras = button:GetParent()
	local frame = auras:GetParent()
	button.db = frame.db and frame.db[auras.type]

	UF:UpdateAuraSettings(button)
end

function UF:UpdateFilters(button)
	local db = button.db

	if not button.auraFilters then
		button.auraFilters = {}
	end

	local patchReady = E.wowtoc > 120000
	local isPlayer = db and db.isAuraPlayer
	local isRaidPlayerDispellable = patchReady and db and db.isAuraRaidPlayerDispellable
	local isImportant = patchReady and db and db.isAuraImportant
	local isImportantPlayer = patchReady and db and db.isAuraImportantPlayer
	local isCrowdControl = patchReady and db and db.isAuraCrowdControl
	local isCrowdControlPlayer = patchReady and db and db.isAuraCrowdControlPlayer
	local isBigDefensive = patchReady and db and db.isAuraBigDefensive
	local isBigDefensivePlayer = patchReady and db and db.isAuraBigDefensivePlayer
	local isRaidInCombat = patchReady and db and db.isAuraRaidInCombat
	local isRaidInCombatPlayer = patchReady and db and db.isAuraRaidInCombatPlayer
	local isExternalDefensive = E.Retail and db and db.isAuraExternalDefensive
	local isExternalDefensivePlayer = E.Retail and db and db.isAuraExternalDefensivePlayer
	local isCancelable = db and db.isAuraCancelable
	local isCancelablePlayer = db and db.isAuraCancelablePlayer
	local notCancelable = db and db.notAuraCancelable
	local notCancelablePlayer = db and db.notAuraCancelablePlayer
	local isRaid = db and db.isAuraRaid
	local isRaidPlayer = db and db.isAuraRaidPlayer

	local filters = button.auraFilters
	filters.isPlayer = isPlayer
	filters.isRaidPlayerDispellable = isRaidPlayerDispellable
	filters.isImportant = isImportant
	filters.isImportantPlayer = isImportantPlayer
	filters.isCrowdControl = isCrowdControl
	filters.isCrowdControlPlayer = isCrowdControlPlayer
	filters.isBigDefensive = isBigDefensive
	filters.isBigDefensivePlayer = isBigDefensivePlayer
	filters.isRaidInCombat = isRaidInCombat
	filters.isRaidInCombatPlayer = isRaidInCombatPlayer
	filters.isExternalDefensive = isExternalDefensive
	filters.isExternalDefensivePlayer = isExternalDefensivePlayer
	filters.isCancelable = isCancelable
	filters.isCancelablePlayer = isCancelablePlayer
	filters.notCancelable = notCancelable
	filters.notCancelablePlayer = notCancelablePlayer
	filters.isRaid = isRaid
	filters.isRaidPlayer = isRaidPlayer

	button.useMidnight = db and db.useMidnight

	local shared = isPlayer or isCancelable or isCancelablePlayer or notCancelable or notCancelablePlayer or isRaid or isRaidPlayer
	if E.Retail then
		button.noFilter = db and not (shared or isRaidPlayerDispellable or isImportant or isImportantPlayer or isCrowdControl or isCrowdControlPlayer or isBigDefensive or isBigDefensivePlayer or isRaidInCombat or isRaidInCombatPlayer or isExternalDefensive or isExternalDefensivePlayer)
	else
		button.noFilter = db and not shared
	end
end

function UF:UpdateAuraSettings(button)
	local db = button.db
	if db then
		if button.Count then
			local point = db.countPosition or 'CENTER'
			button.Count:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
			button.Count:ClearAllPoints()
			button.Count:Point(point, db.countXOffset, db.countYOffset)
		end

		if button.Text then
			local point = db.sourceText.position or 'TOP'
			button.Text:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Text:FontTemplate(LSM:Fetch('font', db.sourceText.font), db.sourceText.fontSize, db.sourceText.fontOutline)
			button.Text:ClearAllPoints()
			button.Text:Point(point, db.sourceText.xOffset, db.sourceText.yOffset)
		end
	end

	button.needsButtonTrim = true

	UF:UpdateFilters(button)
end

function UF:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable or frame.db.auras.enable then
		if not frame:IsElementEnabled('Auras') then
			frame:EnableElement('Auras')
		end
	else
		if frame:IsElementEnabled('Auras') then
			frame:DisableElement('Auras')
		end
	end
end

function UF:Configure_AllAuras(frame)
	if frame.Auras then frame.Auras:ClearAllPoints() end
	if frame.Buffs then frame.Buffs:ClearAllPoints() end
	if frame.Debuffs then frame.Debuffs:ClearAllPoints() end

	UF:Configure_Auras(frame, 'Auras')
	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')
end

function UF:GetAuraElements(frame)
	if frame.isNamePlate then
		return frame.Buffs_, frame.Debuffs_
	else
		return frame.Buffs, frame.Debuffs
	end
end

function UF:SetSmartPosition(frame, db)
	if frame.isNamePlate then db = NP:PlateDB(frame) end

	local position, fluid = db.smartAuraPosition
	local buffs, debuffs = UF:GetAuraElements(frame)
	local info = UF.SmartPosition[position]
	if info then
		local TO = db[strlower(info.to)]
		if TO.attachTo == info.from then
			TO.attachTo = 'FRAME'

			E:Print(info.warning)

			local element = (info.to == 'Debuffs' and debuffs) or buffs
			element.attachTo = frame
			element:ClearAllPoints()
			element:Point(element.initialAnchor, element.attachTo, element.anchorPoint, element.xOffset, element.yOffset)
		end

		fluid = info.fluid
		info.func(db, buffs, debuffs, info.isFuild)
	else
		buffs.PostUpdate = nil
		debuffs.PostUpdate = nil
	end

	if db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS' then
		E:Print(format(L["%s frame has a conflicting anchor point. Forcing the Buffs to be attached to the main unitframe."], E:StringTitle(frame:GetName())))
		db.buffs.attachTo = 'FRAME'
	end

	return position, fluid
end

function UF:Configure_Auras(frame, which)
	local db = frame.db
	local auras = frame[which]
	local auraType = which:lower()
	local settings = db[auraType]
	auras.db = settings
	auras.auraSort = UF.SortAuraFuncs[E.Retail and 'PLAYER' or settings.sortMethod]
	auras.smartPosition, auras.smartFluid = UF:SetSmartPosition(frame, db)
	auras.attachTo = UF:GetAuraAnchorFrame(frame, settings.attachTo) -- keep below SetSmartPosition
	auras.tooltipAnchor = settings.tooltipAnchorType
	auras.tooltipAnchorX = settings.tooltipAnchorX
	auras.tooltipAnchorY = settings.tooltipAnchorY

	if settings.sizeOverride and settings.sizeOverride > 0 then
		auras:Width(settings.perrow * settings.sizeOverride + ((settings.perrow - 1) * settings.spacing))
	else
		local xOffset = 0
		if frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == 'MIDDLE' then
				if settings.attachTo ~= 'POWER' then
					xOffset = frame.POWERBAR_OFFSET * 2
				end -- if its middle and power we dont want an offset.
			else
				xOffset = frame.POWERBAR_OFFSET
			end
		end

		auras:Width((frame.UNIT_WIDTH - UF.SPACING*2) - xOffset)
	end

	auras.spacing = settings.spacing
	auras.num = settings.perrow * settings.numrows
	auras.size = settings.sizeOverride ~= 0 and settings.sizeOverride or (((frame.UNIT_WIDTH - (settings.spacing * (auras.num / settings.numrows - 1)) - ((UF.thinBorders or E.twoPixelsPlease) and 0 or 2)) / auras.num) * settings.numrows)
	auras.height = not settings.keepSizeRatio and settings.height
	auras.forceShow = frame.forceShowAuras
	auras.disableMouse = settings.clickThrough
	auras.anchorPoint = settings.anchorPoint
	auras.growthX = UF.MatchGrowthX[settings.anchorPoint] or settings.growthX
	auras.growthY = UF.MatchGrowthY[settings.anchorPoint] or settings.growthY
	auras.initialAnchor = UF.SideAnchor[settings.anchorPoint] and E.InversePoints[settings.anchorPoint] or (UF.GrowthPoints[settings.growthY]..UF.GrowthPoints[settings.growthX])
	auras.filterList = UF:ConvertFilters(auras, settings.priority)
	auras.numAuras = settings.perrow
	auras.numRows = settings.numrows

	if which == 'Auras' then -- only use this for custom
		auras.filter = settings.filter or 'HARMFUL'
	end

	local x, y
	if settings.attachTo == 'HEALTH' or settings.attachTo == 'POWER' then
		x, y = E:GetXYOffset(auras.anchorPoint, -UF.BORDER, UF.BORDER)
	elseif settings.attachTo == 'FRAME' then
		x, y = E:GetXYOffset(auras.anchorPoint, UF.SPACING, 0)
	else
		x, y = E:GetXYOffset(auras.anchorPoint, 0, UF.SPACING)
	end

	auras.xOffset = x + settings.xOffset + (settings.attachTo == 'FRAME' and frame.ORIENTATION ~= 'LEFT' and frame.POWERBAR_OFFSET or 0)
	auras.yOffset = y + settings.yOffset

	auras:ClearAllPoints()
	auras:Point(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)

	auras:SetFrameStrata(settings.strataAndLevel and settings.strataAndLevel.useCustomStrata and settings.strataAndLevel.frameStrata or 'LOW')
	auras:SetFrameLevel((settings.strataAndLevel and settings.strataAndLevel.useCustomLevel and settings.strataAndLevel.frameLevel) or (frame.RaisedElementParent and frame.RaisedElementParent.AuraLevel) or 1)

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = settings
			UF:UpdateAuraSettings(button)
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end

		index = index + 1
	end

	if settings.enable then
		auras:Show()
	else
		auras:Hide()
	end
end

function UF.SortAuraFunc(a, b)
	if not a or not b or not a:IsShown() then return end
	if not b:IsShown() then return true end

	local frame = a:GetParent()
	if frame and frame.db then
		return frame.auraSort(a, b, frame.db.sortDirection)
	end
end

function UF:SortAuras()
	if self.auraSort and #self.active > 1 then sort(self.active, UF.SortAuraFunc) end
	return 1, self.visibleAuras or self.visibleBuffs or self.visibleDebuffs
end

function UF:PreUpdateAura()
	wipe(self.stacks)

	self.currentRow = nil
end

function UF:GetAuraCurve(unit, button, allow)
	if not unit or not allow then return end

	local which = GetAuraDispelTypeColor and button.filter == 'HARMFUL' and 'debuffs'
	if not which then return end

	return GetAuraDispelTypeColor(unit, button.auraInstanceID, E.Curves.Color.Auras[which])
end

function UF:PostUpdateAura(unit, button)
	local db, r, g, b = (self.isNameplate and NP.db.colors) or UF.db.colors
	local steal = DebuffColors.Stealable

	if E.Retail then
		local color = not self.forceShow and UF:GetAuraCurve(unit, button, db.auraByType)
		if color then
			r, g, b = color:GetRGB()
		end
	elseif button.isDebuff then
		local bad = DebuffColors.BadDispel
		if bad and db.auraByDispels and (BadDispels[button.spellID] and DispelTypes[button.debuffType]) then
			r, g, b = bad.r, bad.g, bad.b
		elseif db.auraByType then
			local debuffColor = DebuffColors[button.debuffType or 'None']
			r, g, b = debuffColor.r * 0.6, debuffColor.g * 0.6, debuffColor.b * 0.6
		end
	elseif steal and db.auraByDispels and button.isStealable and not button.isFriend then
		r, g, b = steal.r, steal.g, steal.b
	end

	if not r then
		r, g, b = unpack((self.isNameplate and E.media.bordercolor) or E.media.unitframeBorderColor)
	end

	button:SetBackdropBorderColor(r, g, b)
	button.Icon:SetDesaturated(button.canDesaturate and button.isDebuff and not button.isFriend and not button.isPlayer)

	if button.Text then
		local bdb = button.db
		local aura = bdb and bdb.sourceText and bdb.sourceText.enable and button.aura
		if aura then
			local text = aura.unitName or UNKNOWN
			local length = bdb.sourceText.length
			local shortText = length and length > 0 and utf8sub(text, 1, length)
			local classColor = E:ClassColor(aura.unitClassFilename) or PRIEST_COLOR
			button.Text:SetTextColor(classColor.r, classColor.g, classColor.b)
			button.Text:SetText(shortText or text)
		else
			button.Text:SetText('')
		end
	end

	if button.needsButtonTrim then
		AB:TrimIcon(button)
		button.needsButtonTrim = nil
	end
end

function UF:GetSmartAuraElements(auras)
	local Buffs, Debuffs = UF:GetAuraElements(auras:GetParent())
	if auras == Buffs then
		return Debuffs, Buffs, auras.visibleBuffs
	else
		return Buffs, Debuffs, auras.visibleDebuffs
	end
end

function UF:UpdateAuraSmartPosition()
	local element, other, visible = UF:GetSmartAuraElements(self)

	if visible == 0 then
		if self.smartFluid then
			element:ClearAllPoints()
			element:Point(other.initialAnchor, other.attachTo, other.anchorPoint, other.xOffset, other.yOffset)
		else
			other:Height(UF:GetAuraPosition(other, true))
		end
	else
		element:ClearAllPoints()
		element:Point(element.initialAnchor, element.attachTo, element.anchorPoint, element.xOffset, element.yOffset)
	end
end

function UF:GetFilterNameInfo(name)
	local block = strmatch(name, '^block([^,]*)')
	local allow = strmatch(name, '^allow([^,]*)')

	if block or allow then
		name = block or allow
	end

	local friend = strmatch(name, '^Friendly:([^,]*)')
	local enemy = strmatch(name, '^Enemy:([^,]*)')

	return friend or enemy or name, friend, enemy, block, allow
end

do
	local specialOldNames = { -- also in Options Core
		nonPersonal = 'NonPersonal',
		notCastByUnit = 'NotCastByUnit',
		notDispellable = 'NotDispellable'
	}

	function UF:ConvertFilters(auras, priority)
		if not priority or priority == '' then return end

		local list = auras.filterList or {}
		if #list > 0 then wipe(list) end

		local special, filters = G.unitframe.specialFilters, E.global.unitframe.aurafilters
		for _, filter in next, { strsplit(',', priority) } do
			local real, friend, enemy, block, allow = UF:GetFilterNameInfo(filter)
			local name = specialOldNames[real] or real
			local custom = filters[real]

			if special[name] or custom then
				tinsert(list, { name = name, block = block, allow = allow, enemy = enemy, friend = friend, custom = custom })
			end
		end

		if #list > 0 then
			return list
		end
	end
end

function UF:CheckFilter(source, spellName, spellID, canDispel, isFriend, isPlayer, unitIsCaster, myPet, otherPet, isBossAura, noDuration, castByPlayer, blizzardNameplate, isMount, filterList)
	for i = 1, #filterList do
		local data = filterList[i]
		local skip = (data.friend and not isFriend) or (data.enemy and isFriend)
		if not skip then -- skip when the friend check doesnt pass
			local custom = data.custom
			if custom then -- Custom Filters
				local list = custom.spells
				if list and next(list) then
					local spell = list[spellID] or list[spellName]
					if spell and spell.enable then
						if not data.allow and not data.block then
							return custom.type ~= 'Blacklist', spell.priority
						else
							return not data.block, spell.priority
						end
					end
				end
			else -- Special Filters
				local name = data.name
				if (name == 'Personal' and isPlayer)
				or (name == 'NonPersonal' and not isPlayer)
				or (name == 'Mount' and isMount)
				or (name == 'Boss' and isBossAura)
				or (name == 'MyPet' and myPet)
				or (name == 'OtherPet' and otherPet)
				or (name == 'CastByUnit' and source and unitIsCaster)
				or (name == 'NotCastByUnit' and source and not unitIsCaster)
				or (name == 'Dispellable' and canDispel)
				or (name == 'NoDuration' and noDuration)
				or (name == 'NotDispellable' and not canDispel)
				or (name == 'CastByNPC' and not castByPlayer)
				or (name == 'CastByPlayers' and castByPlayer)
				or (name == 'BlizzardNameplate' and blizzardNameplate) then
					return not data.block
				end
			end
		end
	end
end

function UF:AuraDispellable(debuffType, spellID)
	return DispelTypes[debuffType]
end

function UF:AuraDuration(db, duration)
	local dno, dmax, dmin = not duration or duration == 0, db.maxDuration, db.minDuration
	return dno, dno or (duration and duration > 0 and (not dmax or dmax == 0 or duration <= dmax) and (not dmin or dmin == 0 or duration >= dmin))
end

function UF:AuraStacks(auras, db, button, name, icon, count, spellID, source, castByPlayer)
	if db.stackAuras and not UF.ExcludeStacks[spellID] then
		local matching = source and castByPlayer and format('%s:%s', UF.SourceStacks[spellID] or source, name) or name
		local amount = (count and count > 0 and count) or 1
		local stack = auras.stacks[matching]
		if not stack then
			auras.stacks[matching] = button
			button.matches = amount
		elseif stack.texture == icon then
			stack.matches = (stack.matches or 1) + amount
			stack.Count:SetText(stack.matches)

			return true -- its stacking
		end
	elseif button.matches then
		button.matches = nil -- stackAuras
	end
end

function UF:AuraPopulate(auras, db, unit, button, name, icon, count, debuffType, duration, expiration, source, isStealable, spellID)
	-- already set by oUF:
	--- button.aura = aura
	--- button.filter = filter
	--- button.isDebuff = isDebuff
	--- button.debuffType = debuffType
	--- button.auraInstanceID = auraInstanceID
	--- button.isPlayer = source == 'player' or source == 'vehicle'

	local myPet = source == 'pet'
	local otherPet = source and source ~= 'pet' and strfind(source, 'pet')
	local dispellable = UF:AuraDispellable(debuffType, spellID)
	local canDispel = (auras.type == 'auras' and (isStealable or dispellable)) or (auras.type == 'buffs' and isStealable) or (auras.type == 'debuffs' and dispellable)
	local unitIsCaster = source and ((unit == source) or UnitIsUnit(unit, source))

	-- straight from the args
	button.duration = duration
	button.expiration = expiration
	button.isStealable = isStealable
	button.stackCount = count
	button.spellID = spellID
	button.texture = icon
	button.name = name

	-- from locals
	button.myPet = myPet
	button.otherPet = otherPet
	button.canDispel = canDispel
	button.unitIsCaster = unitIsCaster

	-- used by GetAuraSortTime
	button.noTime = duration == 0 and expiration == 0

	return myPet, otherPet, canDispel, unitIsCaster
end

function UF:VerifyFilter(button, aura)
	local filters = button.auraFilters
	if not filters or button.noFilter then
		return true
	end

	local player, cancel = aura.auraIsPlayer, aura.auraIsCancelable
	local other, perma = not player, not cancel

	if E.Retail then
		return (filters.isPlayer and player)
		or (filters.isRaidPlayerDispellable and aura.auraIsRaidPlayerDispellable)
		or (filters.isImportant and aura.auraIsImportant and other)
		or (filters.isImportantPlayer and aura.auraIsImportant and player)
		or (filters.isCrowdControl and aura.auraIsCrowdControl and other)
		or (filters.isCrowdControlPlayer and aura.auraIsCrowdControl and player)
		or (filters.isBigDefensive and aura.auraIsBigDefensive and other)
		or (filters.isBigDefensivePlayer and aura.auraIsBigDefensive and player)
		or (filters.isRaidInCombat and aura.auraIsRaidInCombat and other)
		or (filters.isRaidInCombatPlayer and aura.auraIsRaidInCombat and player)
		or (filters.isExternalDefensive and aura.auraIsExternalDefensive and other)
		or (filters.isExternalDefensivePlayer and aura.auraIsExternalDefensive and player)
		or (filters.isCancelable and cancel and other)
		or (filters.isCancelablePlayer and cancel and player)
		or (filters.notCancelable and perma and other)
		or (filters.notCancelablePlayer and perma and player)
		or (filters.isRaid and aura.auraIsRaid and other)
		or (filters.isRaidPlayer and aura.auraIsRaid and player)
	else
		return (filters.isPlayer and player)
		or (filters.isCancelable and cancel and other)
		or (filters.isCancelablePlayer and cancel and player)
		or (filters.notCancelable and perma and other)
		or (filters.notCancelablePlayer and perma and player)
		or (filters.isRaid and aura.auraIsRaid and other)
		or (filters.isRaidPlayer and aura.auraIsRaid and player)
	end
end

function UF:AuraFilter(unit, button, aura, name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, nameplateShowAll)
	if not name then return end -- checking for an aura that is not there, pass nil to break while loop
	local db = self.db

	-- this should be secret safe, rest are populated in oUF or AuraPopulate
	button.isFriend = UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)
	button.canDesaturate = (db and db.desaturate) or false

	if not db or not aura then
		button.priority = 0

		return true
	elseif E.Retail or button.useMidnight then
		button.priority = 0

		return UF:VerifyFilter(button, aura)
	elseif UF:AuraStacks(self, db, button, name, icon, count, spellID, source, castByPlayer) then
		return false -- stacking so dont allow it
	end

	local noDuration, allowDuration = UF:AuraDuration(db, duration)
	if not allowDuration or not self.filterList then
		button.priority = 0

		return allowDuration -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	else
		local myPet, otherPet, canDispel, unitIsCaster = UF:AuraPopulate(self, db, unit, button, name, icon, count, debuffType, duration, expiration, source, isStealable, spellID)
		local pass, priority = UF:CheckFilter(source, name, spellID, canDispel, button.isFriend, button.isPlayer, unitIsCaster, myPet, otherPet, isBossAura, noDuration, castByPlayer, nameplateShowAll or (nameplateShowPersonal and (button.isPlayer or myPet)), E.MountIDs[spellID], self.filterList)

		button.priority = priority or 0 -- This is the only difference from auarbars code

		return pass
	end
end
