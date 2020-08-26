local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local _G = _G
local sort, ceil, huge = sort, ceil, math.huge
local select, unpack, next, format = select, unpack, next, format
local strfind, strsplit, strmatch = strfind, strsplit, strmatch

local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', '$parentBuffs', frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = (not frame:GetScript('OnUpdate')) and self.SortAuras or nil
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	buffs.type = 'buffs'
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	buffs:SetWidth(100)

	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', '$parentDebuffs', frame)
	debuffs.spacing = E.Spacing
	debuffs.PreSetPosition = (not frame:GetScript('OnUpdate')) and self.SortAuras or nil
	debuffs.PostCreateIcon = self.Construct_AuraIcon
	debuffs.PostUpdateIcon = self.PostUpdateAura
	debuffs.CustomFilter = self.AuraFilter
	debuffs.type = 'debuffs'
	debuffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	debuffs:SetWidth(100)

	return debuffs
end

function UF:Aura_OnClick()
	local keyDown = IsShiftKeyDown() and 'SHIFT' or IsAltKeyDown() and 'ALT' or IsControlKeyDown() and 'CTRL'
	if not keyDown then return end

	local spellName, spellID = self.name, self.spellID
	local listName = UF.db.modifiers[keyDown]
	if spellName and spellID and listName ~= 'NONE' then
		if not E.global.unitframe.aurafilters[listName].spells[spellID] then
			E:Print(format(L["The spell '%s' has been added to the '%s' unitframe aura filter."], spellName, listName))
			E.global.unitframe.aurafilters[listName].spells[spellID] = { enable = true, priority = 0 }
		else
			E.global.unitframe.aurafilters[listName].spells[spellID].enable = true
		end

		UF:Update_AllFrames()
	end
end

function UF:Construct_AuraIcon(button)
	local offset = UF.thinBorders and E.mult or E.Border
	button:SetTemplate(nil, nil, nil, UF.thinBorders, true)

	button.cd:SetReverse(true)
	button.cd:SetDrawEdge(false)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetInside(button, offset, offset)
	button.icon:SetDrawLayer('ARTWORK')

	button.count:ClearAllPoints()
	button.count:SetPoint('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture()
	button.stealable:SetTexture()

	button:RegisterForClicks('RightButtonUp')
	button:SetScript('OnClick', UF.Aura_OnClick)

	button.cd.CooldownOverride = 'unitframe'
	E:RegisterCooldown(button.cd)

	local auras = button:GetParent()
	local frame = auras:GetParent()
	button.db = frame.db and frame.db[auras.type]

	UF:UpdateAuraSettings(auras, button)
end

function UF:UpdateAuraSettings(auras, button)
	if button.db then
		button.count:FontTemplate(LSM:Fetch('font', button.db.countFont), button.db.countFontSize, button.db.countFontOutline)
	end
	if button.icon then
		button.icon:SetTexCoord(unpack(E.TexCoords))
	end

	local size = (auras and auras.size) or 30
	button:SetSize(size, size)

	button.needsUpdateCooldownPosition = true
end

function UF:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable then
		if not frame:IsElementEnabled('Auras') then
			frame:EnableElement('Auras')
		end

		frame:SetAuraUpdateMethod(E.global.unitframe.effectiveAura)
		frame:SetAuraUpdateSpeed(E.global.unitframe.effectiveAuraSpeed)
	else
		if frame:IsElementEnabled('Auras') then
			frame:DisableElement('Auras')
		end
	end
end

function UF:UpdateAuraCooldownPosition(button)
	button.cd.timer.text:ClearAllPoints()
	local point = (button.db and button.db.durationPosition) or 'CENTER'
	if point == 'CENTER' then
		button.cd.timer.text:SetPoint(point, 1, 0)
	else
		local bottom, right = point:find('BOTTOM'), point:find('RIGHT')
		button.cd.timer.text:SetPoint(point, right and -1 or 1, bottom and 1 or -1)
	end

	button.needsUpdateCooldownPosition = nil
end

function UF:Configure_AllAuras(frame)
	if frame.Buffs then frame.Buffs:ClearAllPoints() end
	if frame.Debuffs then frame.Debuffs:ClearAllPoints() end

	UF:Configure_Auras(frame, 'Buffs')
	UF:Configure_Auras(frame, 'Debuffs')
end

function UF:Configure_Auras(frame, which)
	local db = frame.db
	local auras = frame[which]
	local auraType = which:lower()
	auras.db = db[auraType]

	local position = db.smartAuraPosition
	if position == 'BUFFS_ON_DEBUFFS' then
		if db.debuffs.attachTo == 'BUFFS' then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = 'FRAME'
			frame.Debuffs.attachTo = frame
			frame.Debuffs:ClearAllPoints()
			frame.Debuffs:SetPoint(frame.Debuffs.initialAnchor, frame.Debuffs.attachTo, frame.Debuffs.anchorPoint, frame.Debuffs.xOffset, frame.Debuffs.yOffset)
		end
		db.buffs.attachTo = 'DEBUFFS'
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition
	elseif position == 'DEBUFFS_ON_BUFFS' then
		if db.buffs.attachTo == 'DEBUFFS' then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = 'FRAME'
			frame.Buffs.attachTo = frame
			frame.Buffs:ClearAllPoints()
			frame.Buffs:SetPoint(frame.Buffs.initialAnchor, frame.Buffs.attachTo, frame.Buffs.anchorPoint, frame.Buffs.xOffset, frame.Buffs.yOffset)
		end
		db.debuffs.attachTo = 'BUFFS'
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition
		frame.Debuffs.PostUpdate = nil
	elseif position == 'FLUID_BUFFS_ON_DEBUFFS' then
		if db.debuffs.attachTo == 'BUFFS' then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = 'FRAME'
			frame.Debuffs.attachTo = frame
			frame.Debuffs:ClearAllPoints()
			frame.Debuffs:SetPoint(frame.Debuffs.initialAnchor, frame.Debuffs.attachTo, frame.Debuffs.anchorPoint, frame.Debuffs.xOffset, frame.Debuffs.yOffset)
		end
		db.buffs.attachTo = 'DEBUFFS'
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = UF.UpdateBuffsHeight
		frame.Debuffs.PostUpdate = UF.UpdateBuffsPositionAndDebuffHeight
	elseif position == 'FLUID_DEBUFFS_ON_BUFFS' then
		if db.buffs.attachTo == 'DEBUFFS' then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = 'FRAME'
			frame.Buffs.attachTo = frame
			frame.Buffs:ClearAllPoints()
			frame.Buffs:SetPoint(frame.Buffs.initialAnchor, frame.Buffs.attachTo, frame.Buffs.anchorPoint, frame.Buffs.xOffset, frame.Buffs.yOffset)
		end
		db.debuffs.attachTo = 'BUFFS'
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsPositionAndBuffHeight
		frame.Debuffs.PostUpdate = UF.UpdateDebuffsHeight
	else
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = nil
	end

	if db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS' then
		E:Print(format(L["%s frame has a conflicting anchor point. Forcing the Buffs to be attached to the main unitframe."], E:StringTitle(frame:GetName())))
		db.buffs.attachTo = 'FRAME'
	end

	local rows = auras.db.numrows
	auras.spacing = auras.db.spacing
	auras.attachTo = self:GetAuraAnchorFrame(frame, auras.db.attachTo)

	if auras.db.sizeOverride and auras.db.sizeOverride > 0 then
		auras:SetWidth(auras.db.perrow * auras.db.sizeOverride + ((auras.db.perrow - 1) * auras.spacing))
	else
		local totalWidth = frame.UNIT_WIDTH - frame.SPACING*2
		if frame.USE_POWERBAR_OFFSET and not (auras.attachTo == 'POWER' and frame.ORIENTATION == 'MIDDLE') then
			local powerOffset = ((frame.ORIENTATION == 'MIDDLE' and 2 or 1) * frame.POWERBAR_OFFSET)
			totalWidth = totalWidth - powerOffset
		end
		auras:SetWidth(totalWidth)
	end

	auras.num = auras.db.perrow * rows
	auras.size = auras.db.sizeOverride ~= 0 and auras.db.sizeOverride or ((((auras:GetWidth() - (auras.spacing*(auras.num/rows - 1))) / auras.num)) * rows)
	auras.forceShow = frame.forceShowAuras
	auras.disableMouse = auras.db.clickThrough
	auras.anchorPoint = auras.db.anchorPoint
	auras.initialAnchor = E.InversePoints[auras.anchorPoint]
	auras['growth-y'] = strfind(auras.anchorPoint, 'TOP') and 'UP' or 'DOWN'
	auras['growth-x'] = auras.anchorPoint == 'LEFT' and 'LEFT' or  auras.anchorPoint == 'RIGHT' and 'RIGHT' or (strfind(auras.anchorPoint, 'LEFT') and 'RIGHT' or 'LEFT')

	local x, y = E:GetXYOffset(auras.anchorPoint, frame.SPACING) --Use frame.SPACING override since it may be different from E.Spacing due to forced thin borders
	if auras.attachTo == 'FRAME' then
		y = 0
	elseif auras.attachTo == 'HEALTH' or auras.attachTo == 'POWER' then
		x = E:GetXYOffset(auras.anchorPoint, -frame.BORDER)
		y = select(2, E:GetXYOffset(auras.anchorPoint, (frame.BORDER + frame.SPACING)))
	else
		x = 0
	end
	auras.xOffset = x + auras.db.xOffset
	auras.yOffset = y + auras.db.yOffset

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = auras.db
			UF:UpdateAuraSettings(auras, button)
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end

		index = index + 1
	end

	auras:ClearAllPoints()
	auras:SetPoint(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)
	auras:SetHeight(auras.size * rows)

	if auras.db.enable then
		auras:Show()
	else
		auras:Hide()
	end
end

local function SortAurasByTime(a, b)
	if (a and b and a:GetParent().db) then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aTime = a.noTime and huge or a.expiration or -1
			local bTime = b.noTime and huge or b.expiration or -1
			if (aTime and bTime) then
				if(sortDirection == 'DESCENDING') then
					return aTime < bTime
				else
					return aTime > bTime
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortAurasByName(a, b)
	if (a and b and a:GetParent().db) then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aName = a.spell or ''
			local bName = b.spell or ''
			if (aName and bName) then
				if(sortDirection == 'DESCENDING') then
					return aName < bName
				else
					return aName > bName
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortAurasByDuration(a, b)
	if (a and b and a:GetParent().db) then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aTime = a.noTime and huge or a.duration or -1
			local bTime = b.noTime and huge or b.duration or -1
			if (aTime and bTime) then
				if(sortDirection == 'DESCENDING') then
					return aTime < bTime
				else
					return aTime > bTime
				end
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function SortAurasByCaster(a, b)
	if (a and b and a:GetParent().db) then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aPlayer = a.isPlayer or false
			local bPlayer = b.isPlayer or false
			if(sortDirection == 'DESCENDING') then
				return (aPlayer and not bPlayer)
			else
				return (not aPlayer and bPlayer)
			end
		elseif a:IsShown() then
			return true
		end
	end
end

function UF:SortAuras()
	if not self.db then return end

	--Sorting by Index is Default
	if self.db.sortMethod == 'TIME_REMAINING' then
		sort(self, SortAurasByTime)
	elseif self.db.sortMethod == 'NAME' then
		sort(self, SortAurasByName)
	elseif self.db.sortMethod == 'DURATION' then
		sort(self, SortAurasByDuration)
	elseif self.db.sortMethod == 'PLAYER' then
		sort(self, SortAurasByCaster)
	end

	--Look into possibly applying filter priorities for auras here.

	return 1, #self --from/to range needed for the :SetPosition call in oUF aura element. Without this aura icon position gets all whacky when not sorted by index
end

function UF:PostUpdateAura(_, button)
	if button.isDebuff then
		if(not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
			if UF.db.colors.auraByType then
				button:SetBackdropBorderColor(.9, .1, .1)
			end
			button.icon:SetDesaturated(button.canDesaturate)
		else
			if UF.db.colors.auraByType then
				if E.BadDispels[button.spellID] and button.dtype and E:IsDispellableByMe(button.dtype) then
					button:SetBackdropBorderColor(.05, .85, .94)
				else
					local color = (button.dtype and _G.DebuffTypeColor[button.dtype]) or _G.DebuffTypeColor.none
					button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
				end
			end
			button.icon:SetDesaturated(false)
		end
	else
		if UF.db.colors.auraByType and button.isStealable and not button.isFriend then
			button:SetBackdropBorderColor(.93, .91, .55)
		else
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end

	if button.needsUpdateCooldownPosition and (button.cd and button.cd.timer and button.cd.timer.text) then
		UF:UpdateAuraCooldownPosition(button)
	end
end

function UF:CheckFilter(caster, spellName, spellID, canDispell, isFriend, isPlayer, unitIsCaster, myPet, otherPet, isBossDebuff, allowDuration, noDuration, casterIsPlayer, nameplateShowSelf, nameplateShowAll, ...)
	local special, filters = G.unitframe.specialFilters, E.global.unitframe.aurafilters

	for i = 1, select('#', ...) do
		local name = select(i, ...)
		local check = (isFriend and strmatch(name, '^Friendly:([^,]*)')) or (not isFriend and strmatch(name, '^Enemy:([^,]*)')) or nil
		if check ~= false then
			if check ~= nil and (special[check] or filters[check]) then
				name = check -- this is for our filters to handle Friendly and Enemy
			end

			-- Custom Filters
			local filter = filters[name]
			if filter then
				local which, list = filter.type, filter.spells
				if which and list and next(list) then
					local spell = list[spellID] or list[spellName]
					if spell and spell.enable then
						if which == 'Blacklist' then
							return false
						elseif allowDuration then
							return true, spell.priority
						end
					end
				end
			-- Special Filters
			else
				-- Whitelists
				local found = (allowDuration and ((name == 'Personal' and isPlayer)
					or (name == 'nonPersonal' and not isPlayer)
					or (name == 'Boss' and isBossDebuff)
					or (name == 'MyPet' and myPet)
					or (name == 'OtherPet' and otherPet)
					or (name == 'CastByUnit' and caster and unitIsCaster)
					or (name == 'notCastByUnit' and caster and not unitIsCaster)
					or (name == 'Dispellable' and canDispell)
					or (name == 'notDispellable' and not canDispell)
					or (name == 'CastByNPC' and not casterIsPlayer)
					or (name == 'CastByPlayers' and casterIsPlayer)
					or (name == 'BlizzardNameplate' and (nameplateShowAll or (nameplateShowSelf and (isPlayer or myPet))))))
				-- Blacklists
				or ((name == 'blockCastByPlayers' and casterIsPlayer)
				or (name == 'blockNoDuration' and noDuration)
				or (name == 'blockNonPersonal' and not isPlayer)
				or (name == 'blockDispellable' and canDispell)
				or (name == 'blockNotDispellable' and not canDispell)) and 0

				if found then
					return found ~= 0
				end
			end
		end
	end
end

function UF:AuraFilter(unit, button, name, _, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, _, isBossDebuff, casterIsPlayer, nameplateShowAll)
	if not name then return end -- checking for an aura that is not there, pass nil to break while loop

	local db = button.db or self.db
	if not db then return true end

	button.canDesaturate = db.desaturate
	button.myPet = caster == 'pet'
	button.isPlayer = caster == 'player' or caster == 'vehicle'
	button.otherPet = caster and not UnitIsUnit('pet', caster) and strmatch(caster, 'pet%d+')
	button.isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)
	button.unitIsCaster = unit and caster and UnitIsUnit(unit, caster)
	button.canDispell = (self.type == 'buffs' and isStealable) or (self.type == 'debuffs' and debuffType and E:IsDispellableByMe(debuffType))
	button.isStealable = isStealable
	button.dtype = debuffType
	button.duration = duration
	button.expiration = expiration
	button.noTime = duration == 0 and expiration == 0
	button.stackCount = count
	button.name = name
	button.spellID = spellID
	button.owner = caster
	button.spell = name
	button.priority = 0

	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and duration > 0 and (not db.maxDuration or db.maxDuration == 0 or duration <= db.maxDuration) and (not db.minDuration or db.minDuration == 0 or duration >= db.minDuration))

	if db.priority and db.priority ~= '' then
		local filterCheck, spellPriority = UF:CheckFilter(caster, name, spellID, button.canDispell, button.isFriend, button.isPlayer, button.unitIsCaster, button.myPet, button.otherPet, isBossDebuff, allowDuration, noDuration, casterIsPlayer, nameplateShowSelf, nameplateShowAll, strsplit(',', db.priority))
		if spellPriority then button.priority = spellPriority end -- this is the only difference from auarbars code
		return filterCheck
	else
		return allowDuration -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end
end

function UF:UpdateBuffsHeaderPosition()
	local parent = self:GetParent()
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:SetPoint(debuffs.initialAnchor, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:SetPoint(buffs.initialAnchor, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end
end

function UF:UpdateDebuffsHeaderPosition()
	local parent = self:GetParent()
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:SetPoint(buffs.initialAnchor, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:SetPoint(debuffs.initialAnchor, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end
end

function UF:UpdateBuffsPositionAndDebuffHeight()
	local parent = self:GetParent()
	local db = parent.db
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:SetPoint(debuffs.initialAnchor, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:SetPoint(buffs.initialAnchor, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:SetHeight(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:SetHeight(debuffs.size)
	end
end

function UF:UpdateDebuffsPositionAndBuffHeight()
	local parent = self:GetParent()
	local db = parent.db
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:SetPoint(buffs.initialAnchor, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:SetPoint(debuffs.initialAnchor, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:SetHeight(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:SetHeight(buffs.size)
	end
end

function UF:UpdateBuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:SetHeight(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:SetHeight(buffs.size)
		-- Any way to get rid of the last row as well?
		-- Using buffs:SetHeight(0) makes frames anchored to this one disappear
	end
end

function UF:UpdateDebuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:SetHeight(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:SetHeight(debuffs.size)
		-- Any way to get rid of the last row as well?
		-- Using debuffs:SetHeight(0) makes frames anchored to this one disappear
	end
end
