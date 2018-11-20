local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local unpack = unpack
local find = string.find
local format = string.format
local tinsert = table.insert
local strsplit = strsplit
local tsort = table.sort
local ceil = math.ceil
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DebuffTypeColor

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

function UF:Construct_AuraIcon(button)
	local offset = UF.thinBorders and E.mult or E.Border

	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:Point('CENTER', 1, 1)
	button.text:SetJustifyH('CENTER')

	button:SetTemplate('Default', nil, nil, UF.thinBorders, true)

	-- cooldown override settings
	if not button.timerOptions then
		button.timerOptions = {}
	end

	button.timerOptions.reverseToggle = UF.db.cooldown.reverse
	button.timerOptions.hideBlizzard = UF.db.cooldown.hideBlizzard

	if UF.db.cooldown.override and E.TimeColors.unitframe then
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = E.TimeColors.unitframe, UF.db.cooldown.threshold
	else
		button.timerOptions.timeColors, button.timerOptions.timeThreshold = nil, nil
	end

	if UF.db.cooldown.checkSeconds then
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = UF.db.cooldown.hhmmThreshold, UF.db.cooldown.mmssThreshold
	else
		button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = nil, nil
	end

	if UF.db.cooldown.fonts and UF.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = UF.db.cooldown.fonts
	elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
		button.timerOptions.fontOptions = E.db.cooldown.fonts
	else
		button.timerOptions.fontOptions = nil
	end
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

	button:RegisterForClicks('RightButtonUp')
	button:SetScript('OnClick', function(self)
		if E.db.unitframe.auraBlacklistModifier == "NONE" or not ((E.db.unitframe.auraBlacklistModifier == "SHIFT" and IsShiftKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "ALT" and IsAltKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "CTRL" and IsControlKeyDown())) then return; end
		local auraName = self.name

		if auraName then
			E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
			E.global.unitframe.aurafilters.Blacklist.spells[auraName] = {
				['enable'] = true,
				['priority'] = 0,
			}

			UF:Update_AllFrames()
		end
	end)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = 'unitframe'
		button.isRegisteredCooldown = true

		if not E.RegisteredCooldowns.unitframe then E.RegisteredCooldowns.unitframe = {} end
		tinsert(E.RegisteredCooldowns.unitframe, button)
	end

	UF:UpdateAuraIconSettings(button, true)
end

function UF:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable then
		if not frame:IsElementEnabled('Aura') then
			frame:EnableElement('Aura')
		end
	else
		if frame:IsElementEnabled('Aura') then
			frame:DisableElement('Aura')
		end
	end
end

local function ReverseUpdate(frame)
	UF:Configure_Auras(frame, "Debuffs")
	UF:Configure_Auras(frame, "Buffs")
end

function UF:Configure_Auras(frame, auraType)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	local auras = frame[auraType]
	auraType = auraType:lower()
	local rows = db[auraType].numrows

	local totalWidth = frame.UNIT_WIDTH - frame.SPACING*2
	if frame.USE_POWERBAR_OFFSET then
		local powerOffset = ((frame.ORIENTATION == "MIDDLE" and 2 or 1) * frame.POWERBAR_OFFSET)

		if not (db[auraType].attachTo == "POWER" and frame.ORIENTATION == "MIDDLE") then
			totalWidth = totalWidth - powerOffset
		end
	end
	auras:Width(totalWidth)

	auras.forceShow = frame.forceShowAuras
	auras.num = db[auraType].perrow * rows
	auras.size = db[auraType].sizeOverride ~= 0 and db[auraType].sizeOverride or ((((auras:GetWidth() - (auras.spacing*(auras.num/rows - 1))) / auras.num)) * rows)

	if db[auraType].sizeOverride and db[auraType].sizeOverride > 0 then
		auras:Width(db[auraType].perrow * db[auraType].sizeOverride)
	end

	local attachTo = self:GetAuraAnchorFrame(frame, db[auraType].attachTo, db.debuffs.attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS')
	local x, y = E:GetXYOffset(db[auraType].anchorPoint, frame.SPACING) --Use frame.SPACING override since it may be different from E.Spacing due to forced thin borders

	if db[auraType].attachTo == "FRAME" then
		y = 0
	elseif db[auraType].attachTo == "HEALTH" or db[auraType].attachTo == "POWER" then
		local newX = E:GetXYOffset(db[auraType].anchorPoint, -frame.BORDER)
		local _, newY = E:GetXYOffset(db[auraType].anchorPoint, (frame.BORDER + frame.SPACING))
		x = newX
		y = newY
	else
		x = 0
	end

	if (auraType == "buffs" and frame.Debuffs.attachTo and frame.Debuffs.attachTo == frame.Buffs and db[auraType].attachTo == "DEBUFFS") then
		--Update Debuffs first, as we would otherwise get conflicting anchor points
		--This is usually only an issue on profile change
		ReverseUpdate(frame)
		return
	end

	auras:ClearAllPoints()
	auras:Point(E.InversePoints[db[auraType].anchorPoint], attachTo, db[auraType].anchorPoint, x + db[auraType].xOffset, y + db[auraType].yOffset)
	auras:Height(auras.size * rows)
	auras["growth-y"] = find(db[auraType].anchorPoint, 'TOP') and 'UP' or 'DOWN'
	auras["growth-x"] = db[auraType].anchorPoint == 'LEFT' and 'LEFT' or  db[auraType].anchorPoint == 'RIGHT' and 'RIGHT' or (find(db[auraType].anchorPoint, 'LEFT') and 'RIGHT' or 'LEFT')
	auras.initialAnchor = E.InversePoints[db[auraType].anchorPoint]

	--These are needed for SmartAuraPosition
	auras.attachTo = attachTo
	auras.point = E.InversePoints[db[auraType].anchorPoint]
	auras.anchorPoint = db[auraType].anchorPoint
	auras.xOffset = x + db[auraType].xOffset
	auras.yOffset = y + db[auraType].yOffset

	if db[auraType].enable then
		auras:Show()
		UF:UpdateAuraIconSettings(auras)
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
	if(self.db.sortMethod == "TIME_REMAINING") then
		tsort(self, SortAurasByTime)
	elseif(self.db.sortMethod == "NAME") then
		tsort(self, SortAurasByName)
	elseif(self.db.sortMethod == "DURATION") then
		tsort(self, SortAurasByDuration)
	elseif (self.db.sortMethod == "PLAYER") then
		tsort(self, SortAurasByCaster)
	end

	--Look into possibly applying filter priorities for auras here.

	return 1, #self --from/to range needed for the :SetPosition call in oUF aura element. Without this aura icon position gets all whacky when not sorted by index
end

function UF:AuraIconUpdate(frame, db, button, font, outline, customFont)
	if customFont and (button.timerOptions and button.timerOptions.fontOptions and button.timerOptions.fontOptions.enable) then
		button.text:FontTemplate(customFont, button.timerOptions.fontOptions.fontSize, button.timerOptions.fontOptions.fontOutline)
	else
		button.text:FontTemplate(font, db.fontSize, outline)
	end

	button.count:FontTemplate(font, db.countFontSize or db.fontSize, outline)
	button.unit = frame.unit -- used to update cooldown text

	E:ToggleBlizzardCooldownText(button.cd, button)

	if db.clickThrough and button:IsMouseEnabled() then
		button:EnableMouse(false)
	elseif not db.clickThrough and not button:IsMouseEnabled() then
		button:EnableMouse(true)
	end
end

function UF:UpdateAuraIconSettings(auras, noCycle)
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
		local font = LSM:Fetch("font", E.db.unitframe.font)
		local outline = E.db.unitframe.fontOutline
		local customFont

		if not noCycle then
			while auras[index] do
				if (not customFont) and (auras[index].timerOptions and auras[index].timerOptions.fontOptions) then
					customFont = LSM:Fetch("font", auras[index].timerOptions.fontOptions.font)
				end

				UF:AuraIconUpdate(frame, db, auras[index], font, outline, customFont)

				index = index + 1
			end
		else
			if auras.timerOptions and auras.timerOptions.fontOptions then
				customFont = LSM:Fetch("font", auras.timerOptions.fontOptions.font)
			end

			UF:AuraIconUpdate(frame, db, auras, font, outline, customFont)
		end
	end
end

function UF:PostUpdateAura(unit, button)
	local auras = button:GetParent()
	local frame = auras:GetParent()
	local type = auras.type
	local db = frame.db and frame.db[type]

	if db then
		if db.clickThrough and button:IsMouseEnabled() then
			button:EnableMouse(false)
		elseif not db.clickThrough and not button:IsMouseEnabled() then
			button:EnableMouse(true)
		end
	end

	if button.isDebuff then
		if(not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not find(unit, 'arena%d')) and true or false)
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

	if E:Cooldown_IsEnabled(button) then
		if button.expiration and button.duration and (button.duration ~= 0) then
			local getTime = GetTime()
			if not button:GetScript('OnUpdate') then
				button.expirationTime = button.expiration
				button.expirationSaved = button.expiration - getTime
				button.nextupdate = -1
				button:SetScript('OnUpdate', UF.UpdateAuraTimer)
			end
			if (button.expirationTime ~= button.expiration) or (button.expirationSaved ~= (button.expiration - getTime))  then
				button.expirationTime = button.expiration
				button.expirationSaved = button.expiration - getTime
				button.nextupdate = -1
			end
		end

		if button.expiration and button.duration and (button.duration == 0 or button.expiration <= 0) then
			button.expirationTime = nil
			button.expirationSaved = nil
			button:SetScript('OnUpdate', nil)
			if button.text:GetFont() then
				button.text:SetText('')
			end
		end
	end
end

function UF:UpdateAuraTimer(elapsed)
	self.expirationSaved = self.expirationSaved - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	local textHasFont = self.text and self.text:GetFont()
	if (not E:Cooldown_IsEnabled(self)) or (self.expirationSaved <= 0) then
		self:SetScript('OnUpdate', nil)

		if textHasFont then
			self.text:SetText('')
		end

		return
	end

	local timeColors, timeThreshold = (self.timerOptions and self.timerOptions.timeColors) or E.TimeColors, (self.timerOptions and self.timerOptions.timeThreshold) or E.db.cooldown.threshold
	if not timeThreshold then timeThreshold = E.TimeThreshold end

	local hhmmThreshold = (self.timerOptions and self.timerOptions.hhmmThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.hhmmThreshold)
	local mmssThreshold = (self.timerOptions and self.timerOptions.mmssThreshold) or (E.db.cooldown.checkSeconds and E.db.cooldown.mmssThreshold)

	local value1, formatid, nextupdate, value2 = E:GetTimeInfo(self.expirationSaved, timeThreshold, hhmmThreshold, mmssThreshold)
	self.nextupdate = nextupdate

	if textHasFont then
		self.text:SetFormattedText(format("%s%s|r", timeColors[formatid], E.TimeFormats[formatid][2]), value1, value2)
	end
end

function UF:AuraFilter(unit, button, name, _, _, debuffType, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer)
	local db = self:GetParent().db
	if not db or not db[self.type] then return true; end

	db = db[self.type]

	if not name then return nil end
	local filterCheck, isUnit, isFriend, isPlayer, canDispell, allowDuration, noDuration, spellPriority

	isPlayer = (caster == 'player' or caster == 'vehicle')
	isFriend = unit and UnitIsFriend('player', unit) and not UnitCanAttack('player', unit)

	button.isPlayer = isPlayer
	button.isFriend = isFriend
	button.isStealable = isStealable
	button.dtype = debuffType
	button.duration = duration
	button.expiration = expiration
	button.name = name
	button.owner = caster --what uses this?
	button.spell = name --what uses this? (SortAurasByName?)
	button.priority = 0

	noDuration = (not duration or duration == 0)
	allowDuration = noDuration or (duration and (duration > 0) and (db.maxDuration == 0 or duration <= db.maxDuration) and (db.minDuration == 0 or duration >= db.minDuration))

	if db.priority ~= '' then
		isUnit = unit and caster and UnitIsUnit(unit, caster)
		canDispell = (self.type == 'buffs' and isStealable) or (self.type == 'debuffs' and debuffType and E:IsDispellableByMe(debuffType))
		filterCheck, spellPriority = UF:CheckFilter(name, caster, spellID, isFriend, isPlayer, isUnit, isBossDebuff, allowDuration, noDuration, canDispell, casterIsPlayer, strsplit(",", db.priority))
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
		debuffs:Height(debuffs.size * (numRows > db.debuffs.numrows and db.debuffs.numrows or numRows))
	else
		debuffs:Height(debuffs.size)
		-- Any way to get rid of the last row as well?
		-- Using debuffs:SetHeight(0) makes frames anchored to this one disappear
	end
end
