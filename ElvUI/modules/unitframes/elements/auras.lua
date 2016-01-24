local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");

--Cache global variables
--Lua functions
local unpack, type = unpack, type
local tsort = table.sort
local format = format
--WoW API / Variables
local GetTime = GetTime
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitAura = UnitAura
local UnitIsFriend = UnitIsFriend

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DebuffTypeColor

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', frame:GetName().."Buffs", frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(10)
	buffs.type = 'buffs'

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
	debuffs:SetFrameLevel(10)

	return debuffs
end

function UF:Construct_AuraIcon(button)
	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:Point('CENTER', 1, 1)
	button.text:SetJustifyH('CENTER')

	button:SetTemplate('Default')

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetInside()
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetInside()
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
    end
end

local function SortAurasByName(a, b)
    if (a and b and a:GetParent().db) then
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
    end
end

local function SortAurasByDuration(a, b)
    if (a and b and a:GetParent().db) then
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
	end

	--Look into possibly applying filter priorities for auras here. 
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
	local index = 1
	auras.db = db
	if(db) then
		if(not noCycle) then
			while(auras[index]) do
				local button = auras[index]
				button.text:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE')
				button.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, 'OUTLINE')

				if db.clickThrough and button:IsMouseEnabled() then
					button:EnableMouse(false)
				elseif not db.clickThrough and not button:IsMouseEnabled() then
					button:EnableMouse(true)
				end
				index = index + 1
			end
		else
			auras.text:FontTemplate(unitframeFont, db.fontSize, 'OUTLINE')
			auras.count:FontTemplate(unitframeFont, db.countFontSize or db.fontSize, 'OUTLINE')

			if db.clickThrough and auras:IsMouseEnabled() then
				auras:EnableMouse(false)
			elseif not db.clickThrough and not auras:IsMouseEnabled() then
				auras:EnableMouse(true)
			end
		end
	end
end

function UF:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)


	local isFriend = UnitIsFriend('player', unit)
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
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end
	end

	local size = button:GetParent().size
	if size then
		button:Size(size)
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
		self.text:FontTemplate(LSM:Fetch("font", E.db['unitframe'].font), self:GetParent():GetParent().db[self:GetParent().type].fontSize, 'OUTLINE')
		self.text:SetFormattedText(("%s%s|r"):format(E.TimeColors[formatid], E.TimeFormats[formatid][2]), timervalue)
	end
end

function UF:CheckFilter(filterType, isFriend)
	local FRIENDLY_CHECK, ENEMY_CHECK = false, false
	if type(filterType) == 'boolean' then
		FRIENDLY_CHECK = filterType
		ENEMY_CHECK = filterType
	elseif filterType then
		FRIENDLY_CHECK = filterType.friendly
		ENEMY_CHECK = filterType.enemy
	end

	if (FRIENDLY_CHECK and isFriend) or (ENEMY_CHECK and not isFriend) then
		return true
	end

	return false
end

function UF:AuraFilter(unit, icon, name, rank, texture, count, dtype, duration, timeLeft, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura)
	if E.global.unitframe.InvalidSpells[spellID] then
		return false;
	end

	local isPlayer, isFriend
	local db = self:GetParent().db
	if not db or not db[self.type] then return true; end

	db = db[self.type]

	local returnValue = true
	local passPlayerOnlyCheck = true
	local anotherFilterExists = false
	local playerOnlyFilter = false
	local isPlayer = unitCaster == 'player' or unitCaster == 'vehicle'
	local isFriend = UnitIsFriend('player', unit)
	local auraType = isFriend and db.friendlyAuraType or db.enemyAuraType

	icon.isPlayer = isPlayer
	icon.owner = unitCaster
	icon.name = name
	icon.priority = 0

	local turtleBuff = E.global['unitframe']['aurafilters']['TurtleBuffs'].spells[name]
	if turtleBuff and turtleBuff.enable then
		icon.priority = turtleBuff.priority
	end

	if UF:CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		else
			returnValue = false;
		end

		passPlayerOnlyCheck = returnValue
		playerOnlyFilter = true
	end

	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and not isStealable) or (self.type == 'debuffs' and dtype and  not E:IsDispellableByMe(dtype)) or dtype == nil then
			returnValue = false;
		end
		anotherFilterExists = true
	end


	if UF:CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == true then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	--[[if UF:CheckFilter(db.bossAuras, isFriend) then
		if(isBossAura) then
			returnValue = true
		elseif(not anotherFilterExists) then
			returnValue = false
		end
	end]]

	if UF:CheckFilter(db.useBlacklist, isFriend) then
		local blackList = E.global['unitframe']['aurafilters']['Blacklist'].spells[name]
		if blackList and blackList.enable then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = E.global['unitframe']['aurafilters']['Whitelist'].spells[name]
		if whiteList and whiteList.enable then
			returnValue = true;
			icon.priority = whiteList.priority
		elseif not anotherFilterExists and not playerOnlyFilter then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = E.global['unitframe']['aurafilters']['Whitelist (Strict)'].spells[name]
		if whiteList and whiteList.enable then
			if whiteList.spellID and whiteList.spellID == spellID then
				returnValue = true;
			else
				returnValue = false;
			end
			icon.priority = whiteList.priority
		elseif not anotherFilterExists and not playerOnlyFilter then
			returnValue = false
		end
	end

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable and passPlayerOnlyCheck then
				returnValue = true
				icon.priority = spellList[name].priority

				--bit hackish fix to this
				if db.useFilter == 'TurtleBuffs' and (spellID == 86698 or spellID == 86669) then
					returnValue = false
				end

				if db.useFilter == 'Whitelist (Strict)' and spellList[name].spellID and not spellList[name].spellID == spellID then
					returnValue = false
				end
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false
		end
	end

	return returnValue
end

function UF:UpdateBuffsHeaderPosition()
	local parent = self:GetParent()
	local buffs = parent.Buffs
	local debuffs = parent.Debuffs
	local numDebuffs = self.visibleDebuffs

	if numDebuffs == 0 then
		buffs:ClearAllPoints()
		buffs:SetPoint(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	else
		buffs:ClearAllPoints()
		buffs:SetPoint(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	end
end

function UF:UpdateDebuffsHeaderPosition()
	local parent = self:GetParent()
	local debuffs = parent.Debuffs
	local buffs = parent.Buffs
	local numBuffs = self.visibleBuffs

	if numBuffs == 0 then
		debuffs:ClearAllPoints()
		debuffs:SetPoint(buffs.point, buffs.attachTo, buffs.anchorPoint, buffs.xOffset, buffs.yOffset)
	else
		debuffs:ClearAllPoints()
		debuffs:SetPoint(debuffs.point, debuffs.attachTo, debuffs.anchorPoint, debuffs.xOffset, debuffs.yOffset)
	end
end