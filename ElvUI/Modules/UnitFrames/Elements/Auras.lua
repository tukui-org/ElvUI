local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local unpack, strfind, format, strsplit, sort, ceil = unpack, strfind, format, strsplit, sort, ceil
--WoW API / Variables
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', frame:GetName().."Buffs", frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	buffs.type = 'buffs'
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	buffs:Width(100)

	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', frame:GetName().."Debuffs", frame)
	debuffs.spacing = E.Spacing
	debuffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	debuffs.PostCreateIcon = self.Construct_AuraIcon
	debuffs.PostUpdateIcon = self.PostUpdateAura
	debuffs.CustomFilter = self.AuraFilter
	debuffs.type = 'debuffs'
	debuffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	debuffs:Width(100)

	return debuffs
end

local function OnClick(btn)
	local mod = E.db.unitframe.auraBlacklistModifier
	if mod == "NONE" or not ((mod == "SHIFT" and IsShiftKeyDown()) or (mod == "ALT" and IsAltKeyDown()) or (mod == "CTRL" and IsControlKeyDown())) then return end
	local auraName = btn.name

	if auraName then
		E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
		E.global.unitframe.aurafilters.Blacklist.spells[btn.spellID] = { enable = true, priority = 0 }

		UF:Update_AllFrames()
	end
end

function UF:Construct_AuraIcon(button)
	local offset = UF.thinBorders and E.mult or E.Border
	button:SetTemplate(nil, nil, nil, UF.thinBorders, true)

	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetInside(button, offset, offset)
	button.icon:SetDrawLayer('ARTWORK')

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture()
	button.stealable:SetTexture()

	button:RegisterForClicks('RightButtonUp')
	button:SetScript('OnClick', OnClick)

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

	button:Size((auras and auras.size) or 30)

	button.needsUpdateCooldownPosition = true
end

function UF:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable then
		if not frame:IsElementEnabled('Auras') then
			frame:EnableElement('Auras')
		end
	else
		if frame:IsElementEnabled('Auras') then
			frame:DisableElement('Auras')
		end
	end
end

local function ReverseUpdate(frame)
	UF:Configure_Auras(frame, "Debuffs")
	UF:Configure_Auras(frame, "Buffs")
end

function UF:UpdateAuraCooldownPosition(button)
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

function UF:Configure_Auras(frame, auraType)
	if not frame.VARIABLES_SET then return end

	local db = frame.db
	local auras = frame[auraType]
	auraType = auraType:lower()
	auras.db = db[auraType]

	local rows = auras.db.numrows
	auras.forceShow = frame.forceShowAuras
	auras.num = auras.db.perrow * rows
	auras.size = auras.db.sizeOverride ~= 0 and auras.db.sizeOverride or ((((auras:GetWidth() - (auras.spacing*(auras.num/rows - 1))) / auras.num)) * rows)
	auras.disableMouse = auras.db.clickThrough

	if auras.db.sizeOverride and auras.db.sizeOverride > 0 then
		auras:Width(auras.db.perrow * auras.db.sizeOverride)
	else
		local totalWidth = frame.UNIT_WIDTH - frame.SPACING*2
		if frame.USE_POWERBAR_OFFSET then
			if not (auras.db.attachTo == "POWER" and frame.ORIENTATION == "MIDDLE") then
				local powerOffset = ((frame.ORIENTATION == "MIDDLE" and 2 or 1) * frame.POWERBAR_OFFSET)
				totalWidth = totalWidth - powerOffset
			end
		end
		auras:Width(totalWidth)
	end

	local index = 1
	while auras[index] do
		local button = auras[index]
		if button then
			button.db = auras.db
			UF:UpdateAuraSettings(auras, button)
		end

		index = index + 1
	end

	local attachTo = self:GetAuraAnchorFrame(frame, auras.db.attachTo, db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS')
	local x, y = E:GetXYOffset(auras.db.anchorPoint, frame.SPACING) --Use frame.SPACING override since it may be different from E.Spacing due to forced thin borders

	if auras.db.attachTo == "FRAME" then
		y = 0
	elseif auras.db.attachTo == "HEALTH" or auras.db.attachTo == "POWER" then
		local newX = E:GetXYOffset(auras.db.anchorPoint, -frame.BORDER)
		local _, newY = E:GetXYOffset(auras.db.anchorPoint, (frame.BORDER + frame.SPACING))
		x = newX
		y = newY
	else
		x = 0
	end

	if (auraType == "buffs" and frame.Debuffs.attachTo and frame.Debuffs.attachTo == frame.Buffs and auras.db.attachTo == "DEBUFFS") then
		--Update Debuffs first, as we would otherwise get conflicting anchor points
		--This is usually only an issue on profile change
		ReverseUpdate(frame)
		return
	end

	auras:ClearAllPoints()
	auras:Point(E.InversePoints[auras.db.anchorPoint], attachTo, auras.db.anchorPoint, x + auras.db.xOffset, y + auras.db.yOffset)
	auras:Height(auras.size * rows)
	auras["growth-y"] = strfind(auras.db.anchorPoint, 'TOP') and 'UP' or 'DOWN'
	auras["growth-x"] = auras.db.anchorPoint == 'LEFT' and 'LEFT' or  auras.db.anchorPoint == 'RIGHT' and 'RIGHT' or (strfind(auras.db.anchorPoint, 'LEFT') and 'RIGHT' or 'LEFT')
	auras.initialAnchor = E.InversePoints[auras.db.anchorPoint]

	--These are needed for SmartAuraPosition
	auras.attachTo = attachTo
	auras.point = E.InversePoints[auras.db.anchorPoint]
	auras.anchorPoint = auras.db.anchorPoint
	auras.xOffset = x + auras.db.xOffset
	auras.yOffset = y + auras.db.yOffset

	if auras.db.enable then
		auras:Show()
	else
		auras:Hide()
	end

	local position = db.smartAuraPosition
	if position == "BUFFS_ON_DEBUFFS" then
		if db.debuffs.attachTo == "BUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = "FRAME"
			frame.Debuffs.attachTo = frame
		end
		db.buffs.attachTo = "DEBUFFS"
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition
	elseif position == "DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		db.debuffs.attachTo = "BUFFS"
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition
		frame.Debuffs.PostUpdate = nil
	elseif position == "FLUID_BUFFS_ON_DEBUFFS" then
		if db.debuffs.attachTo == "BUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = "FRAME"
			frame.Debuffs.attachTo = frame
		end
		db.buffs.attachTo = "DEBUFFS"
		frame.Buffs.attachTo = frame.Debuffs
		frame.Buffs.PostUpdate = UF.UpdateBuffsHeight
		frame.Debuffs.PostUpdate = UF.UpdateBuffsPositionAndDebuffHeight
	elseif position == "FLUID_DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		db.debuffs.attachTo = "BUFFS"
		frame.Debuffs.attachTo = frame.Buffs
		frame.Buffs.PostUpdate = UF.UpdateDebuffsPositionAndBuffHeight
		frame.Debuffs.PostUpdate = UF.UpdateDebuffsHeight
	else
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = nil
	end
end

local function SortAurasByTime(a, b)
	if (a and b and a:GetParent().db) then
		if a:IsShown() and b:IsShown() then
			local sortDirection = a:GetParent().db.sortDirection
			local aTime = a.expiration or -1
			local bTime = b.expiration or -1
			if (aTime and bTime) then
				if(sortDirection == "DESCENDING") then
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
			local aName = a.spell or ""
			local bName = b.spell or ""
			if (aName and bName) then
				if(sortDirection == "DESCENDING") then
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
			local aTime = a.duration or -1
			local bTime = b.duration or -1
			if (aTime and bTime) then
				if(sortDirection == "DESCENDING") then
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
			if(sortDirection == "DESCENDING") then
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
	if self.db.sortMethod == "TIME_REMAINING" then
		sort(self, SortAurasByTime)
	elseif self.db.sortMethod == "NAME" then
		sort(self, SortAurasByName)
	elseif self.db.sortMethod == "DURATION" then
		sort(self, SortAurasByDuration)
	elseif self.db.sortMethod == "PLAYER" then
		sort(self, SortAurasByCaster)
	end

	--Look into possibly applying filter priorities for auras here.

	return 1, #self --from/to range needed for the :SetPosition call in oUF aura element. Without this aura icon position gets all whacky when not sorted by index
end

function UF:PostUpdateAura(unit, button)
	if button.isDebuff then
		if(not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not strfind(unit, 'arena%d')) and true or false)
		else
			local color = (button.dtype and _G.DebuffTypeColor[button.dtype]) or _G.DebuffTypeColor.none
			if button.name and (button.name == "Unstable Affliction" or button.name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
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

	if button.needsUpdateCooldownPosition and (button.cd and button.cd.timer and button.cd.timer.text) then
		UF:UpdateAuraCooldownPosition(button)
	end
end

function UF:AuraFilter(unit, button, name, _, count, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	if not name then return end -- checking for an aura that is not there, pass nil to break while loop

	local parent = self:GetParent()
	local db = parent.db and parent.db[self.type]
	if not db then return true end

	local isPlayer = (caster == 'player' or caster == 'vehicle')
	local isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)

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

	local noDuration = (not duration or duration == 0)
	local allowDuration = noDuration or (duration and (duration > 0) and (db.maxDuration == 0 or duration <= db.maxDuration) and (db.minDuration == 0 or duration >= db.minDuration))
	local filterCheck, spellPriority

	if db.priority ~= '' then
		local isUnit = unit and caster and UnitIsUnit(unit, caster)
		local canDispell = (self.type == 'buffs' and isStealable) or (self.type == 'debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck, spellPriority = UF:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(',', db.priority))
		if spellPriority then button.priority = spellPriority end -- this is the only difference from auarbars code
	else
		filterCheck = allowDuration and true -- Allow all auras to be shown when the filter list is empty, while obeying duration sliders
	end

	return filterCheck
end

function UF:UpdateBuffsHeaderPosition()
	local parent = self:GetParent()
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end
end

function UF:UpdateDebuffsHeaderPosition()
	local parent = self:GetParent()
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
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
		buffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:Height(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:Height(debuffs.size)
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
		debuffs:Point(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:Point(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:Height(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:Height(buffs.size)
	end
end

function UF:UpdateBuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs > 0 then
		local numRows = ceil(numBuffs/db.buffs.perrow)
		buffs:Height(buffs.size * (numRows > db.buffs.numrows and db.buffs.numrows or numRows))
	else
		buffs:Height(buffs.size)
		-- Any way to get rid of the last row as well?
		-- Using buffs:Height(0) makes frames anchored to this one disappear
	end
end

function UF:UpdateDebuffsHeight()
	local parent = self:GetParent()
	local db = parent.db
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs > 0 then
		local numRows = ceil(numDebuffs/db.debuffs.perrow)
		debuffs:Height(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:Height(debuffs.size)
		-- Any way to get rid of the last row as well?
		-- Using debuffs:Height(0) makes frames anchored to this one disappear
	end
end
