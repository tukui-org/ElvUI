local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local unpack, type = unpack, type
local next, ipairs = next, ipairs
local match = string.match
local strsplit = strsplit
local tsort = table.sort
local format = format
local ceil = math.ceil
local select = select
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitAura = UnitAura
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

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)
	button.cd:SetHideCountdownNumbers(true)

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
			E.global['unitframe']['aurafilters']['Blacklist']['spells'][auraName] = {
				['enable'] = true,
				['priority'] = 0,
			}

			UF:Update_AllFrames()
		end
	end)

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
	auras["growth-y"] = db[auraType].anchorPoint:find('TOP') and 'UP' or 'DOWN'
	auras["growth-x"] = db[auraType].anchorPoint == 'LEFT' and 'LEFT' or  db[auraType].anchorPoint == 'RIGHT' and 'RIGHT' or (db[auraType].anchorPoint:find('LEFT') and 'RIGHT' or 'LEFT')
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
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = UF.UpdateBuffsHeaderPosition
	elseif position == "DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		frame.Buffs.PostUpdate = UF.UpdateDebuffsHeaderPosition
		frame.Debuffs.PostUpdate = nil
	elseif position == "FLUID_BUFFS_ON_DEBUFFS" then
		if db.debuffs.attachTo == "BUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Buffs"], L["Debuffs"], L["Frame"]))
			db.debuffs.attachTo = "FRAME"
			frame.Debuffs.attachTo = frame
		end
		frame.Buffs.PostUpdate = UF.UpdateBuffsHeight
		frame.Debuffs.PostUpdate = UF.UpdateBuffsPositionAndDebuffHeight
	elseif position == "FLUID_DEBUFFS_ON_BUFFS" then
		if db.buffs.attachTo == "DEBUFFS" then
			E:Print(format(L["This setting caused a conflicting anchor point, where '%s' would be attached to itself. Please check your anchor points. Setting '%s' to be attached to '%s'."], L["Debuffs"], L["Buffs"], L["Frame"]))
			db.buffs.attachTo = "FRAME"
			frame.Buffs.attachTo = frame
		end
		frame.Buffs.PostUpdate = UF.UpdateDebuffsPositionAndBuffHeight
		frame.Debuffs.PostUpdate = UF.UpdateDebuffsHeight
	else
		frame.Buffs.PostUpdate = nil
		frame.Debuffs.PostUpdate = nil
	end
end

local function SortAurasByPriority(a, b)
	if (a and b) then
		if a.isPlayer and not b.isPlayer then
			return true
		elseif not a.isPlayer and b.isPlayer then
			return false
		end

		if (a.priority and b.priority) then
			return a.priority > b.priority
		end
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

function UF:UpdateAuraIconSettings(auras, noCycle)
	local frame = auras:GetParent()
	local type = auras.type
	if(noCycle) then
		frame = auras:GetParent():GetParent()
		type = auras:GetParent().type
	end
	if(not frame.db) then return end

	local db = frame.db[type]
	local unitframeFont = LSM:Fetch("font", E.db['unitframe'].font)
	local unitframeFontOutline = E.db['unitframe'].fontOutline
	local index = 1
	auras.db = db
	if(db) then
		if(not noCycle) then
			while(auras[index]) do
				local button = auras[index]
				button.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline)
				button.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline)

				if db.clickThrough and button:IsMouseEnabled() then
					button:EnableMouse(false)
				elseif not db.clickThrough and not button:IsMouseEnabled() then
					button:EnableMouse(true)
				end
				index = index + 1
			end
		else
			auras.text:FontTemplate(unitframeFont, db.fontSize, unitframeFontOutline)
			auras.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, unitframeFontOutline)

			if db.clickThrough and auras:IsMouseEnabled() then
				auras:EnableMouse(false)
			elseif not db.clickThrough and not auras:IsMouseEnabled() then
				auras:EnableMouse(true)
			end
		end
	end
end

function UF:PostUpdateAura(unit, button, index)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)
	local isFriend = UnitIsFriend('player', unit)

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
		if(not isFriend and button.owner ~= "player" and button.owner ~= "vehicle") --[[and (not E.isDebuffWhiteList[name])]] then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not unit:find('arena%d')) and true or false)
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not isFriend then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			button:SetBackdropBorderColor(unpack(E["media"].unitframeBorderColor))
		end
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	button.spell = name
	button.isStealable = isStealable
	button.duration = duration

	if expiration and duration ~= 0 then
		if not button:GetScript('OnUpdate') then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
			button:SetScript('OnUpdate', UF.UpdateAuraTimer)
		end
		if (button.expirationTime ~= expiration) or (button.expiration ~= (expiration - GetTime()))  then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
		end
	end
	if duration == 0 or expiration == 0 then
		button.expirationTime = nil
		button.expiration = nil
		button.priority = nil
		button.duration = nil
		button:SetScript('OnUpdate', nil)
		if(button.text:GetFont()) then
			button.text:SetText('')
		end
	end
end

function UF:UpdateAuraTimer(elapsed)
	self.expiration = self.expiration - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	if(self.expiration <= 0) then
		self:SetScript('OnUpdate', nil)

		if(self.text:GetFont()) then
			self.text:SetText('')
		end

		return
	end

	local timervalue, formatid
	timervalue, formatid, self.nextupdate = E:GetTimeInfo(self.expiration, 4)
	if self.text:GetFont() then
		self.text:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue)
	elseif self:GetParent():GetParent().db then
		self.text:FontTemplate(LSM:Fetch("font", E.db['unitframe'].font), self:GetParent():GetParent().db[self:GetParent().type].fontSize, E.db['unitframe'].fontOutline)
		self.text:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue)
	end
end

function UF:AuraFilter(unit, button, name, rank, texture, count, dispelType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
	local db = self:GetParent().db
	if not db or not db[self.type] then return true; end

	db = db[self.type]

	local filterCheck, isUnit, isFriend, isPlayer, canDispell, allowDuration, noDuration, friendCheck, filterName = false, false, false, false, false, false, false, false, false

	if name then
		noDuration = (not duration or duration == 0)
		isFriend = unit and UnitIsFriend('player', unit)
		isPlayer = (caster == 'player' or caster == 'vehicle')
		isUnit = unit and caster and UnitIsUnit(unit, caster)
		canDispell = (self.type == 'buffs' and isStealable) or (self.type == 'debuffs' and dispelType and E:IsDispellableByMe(dispelType))
		allowDuration = noDuration or (duration and (duration > 0) and (db.maxDuration == 0 or duration <= db.maxDuration) and (db.minDuration == 0 or duration >= db.minDuration))
	else
		return nil
	end

	button.isPlayer = isPlayer
	button.owner = caster
	button.name = name
	button.priority = 0

	local filter, filterType, spellList, spell
	if db.priority ~= '' then
		for i=1, select('#',strsplit(",",db.priority)) do
			filterName = select(i, strsplit(",",db.priority))
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

					if filterType and filterType == 'Whitelist' and spell and spell.enable and allowDuration then
						filterCheck = true
						button.priority = spell.priority -- this is the only difference from auarbars code
						break -- STOP: allowing whistlisted spell
					elseif filterType and filterType == 'Blacklist' and spell and spell.enable then
						filterCheck = false
						break -- STOP: blocking blacklisted spell
					end
				elseif filterName == 'Personal' and isPlayer and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'nonPersonal' and not isPlayer and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'Boss' and isBossDebuff and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'CastByUnit' and (caster and isUnit) and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'notCastByUnit' and (caster and not isUnit) and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'Dispellable' and canDispell and allowDuration then
					filterCheck = true
					break -- STOP
				elseif filterName == 'CastByPlayers' and casterIsPlayer then
					filterCheck = true
					break -- STOP
				elseif filterName == 'blockCastByPlayers' and casterIsPlayer then
					filterCheck = false
					break -- STOP
				elseif filterName == 'blockNoDuration' and noDuration then
					filterCheck = false
					break -- STOP
				elseif filterName == 'blockNonPersonal' and not isPlayer then
					filterCheck = false
					break -- STOP
				end
			end
		end
	else
		filterCheck = true -- Allow all auras to be shown when the filter list is empty
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
