local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local tsort = table.sort
local LSM = LibStub("LibSharedMedia-3.0");

function UF:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', nil, frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = self.SortAuras
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(10)
	buffs.type = 'buffs'
	
	return buffs
end

function UF:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', nil, frame)
	debuffs.spacing = E.Spacing
	debuffs.PreSetPosition = self.SortAuras
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
	button.cd:SetReverse()
	button.cd:SetInside()
	
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
		if not IsShiftKeyDown() then return; end
		local auraName = self.name
		
		if auraName then
			E:Print(format(L['The spell "%s" has been added to the Blacklist unitframe aura filter.'], auraName))
			E.global['unitframe']['aurafilters']['Blacklist']['spells'][auraName] = {
				['enable'] = true,
				['priority'] = 0,			
			}
			
			UF:Update_AllFrames()
		end
	end)	
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

function UF:SortAuras()
	tsort(self, SortAurasByPriority)
end

function UF:PostUpdateAura(unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)
	local db = self:GetParent().db
	
	if db and db[self.type] then
		local unitframeFont = LSM:Fetch("font", E.db['unitframe'].font)
	
		button.text:FontTemplate(unitframeFont, db[self.type].fontSize, 'OUTLINE')
		button.count:FontTemplate(unitframeFont, db[self.type].countFontSize or db[self.type].fontSize, 'OUTLINE')
		
		if db[self.type].clickThrough and button:IsMouseEnabled() then
			button:EnableMouse(false)
		elseif not db[self.type].clickThrough and not button:IsMouseEnabled() then
			button:EnableMouse(true)
		end
	end
	
	local isFriend = UnitIsFriend('player', unit) == 1 and true or false
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
	if expiration and duration ~= 0 then
		if not button:GetScript('OnUpdate') then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
			button:SetScript('OnUpdate', UF.UpdateAuraTimer)
		end
		if button.expirationTime ~= expiration  then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
		end
	end	
	if duration == 0 or expiration == 0 then
		button:SetScript('OnUpdate', nil)
		if button.text:GetFont() then
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
		self.text:SetText('')
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
	if type(filterType) == 'string' then
		error('Database conversion failed! Report to Elv.')
	elseif type(filterType) == 'boolean' then
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

function UF:AuraFilter(unit, icon, name, rank, texture, count, dtype, duration, timeLeft, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)	
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
	local isPlayer = unitCaster == 'player' or unitCaster == 'vehicle'
	local isFriend = UnitIsFriend('player', unit) == 1 and true or false
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
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and not isStealable) or (self.type == 'debuffs' and dtype and  not E:IsDispellableByMe(dtype)) or dtype == nil then
			returnValue = false;
		end
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == 1 then
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
		elseif not anotherFilterExists then
			returnValue = false
		end
		
		anotherFilterExists = true
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
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false				
		end
	end		
	
	return returnValue	
end

function UF:SmartAuraDisplay()
	local db = self.db
	local unit = self.unit
	if not db or not db.smartAuraDisplay or db.smartAuraDisplay == 'DISABLED' or not UnitExists(unit) then return; end
	local buffs = self.Buffs
	local debuffs = self.Debuffs
	local auraBars = self.AuraBars

	local isFriend = UnitIsFriend('player', unit) == 1 and true or false
	
	if isFriend then
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Hide()
			debuffs:Show()
		else
			buffs:Show()
			debuffs:Hide()		
		end
	else
		if db.smartAuraDisplay == 'SHOW_DEBUFFS_ON_FRIENDLIES' then
			buffs:Show()
			debuffs:Hide()
		else
			buffs:Hide()
			debuffs:Show()		
		end
	end
	
	local yOffset = E.PixelMode and (db.aurabar.anchorPoint == 'BELOW' and 1 or -1) or 0;
	if buffs:IsShown() then
		local x, y = E:GetXYOffset(db.buffs.anchorPoint)
		
		buffs:ClearAllPoints()
		buffs:Point(E.InversePoints[db.buffs.anchorPoint], self, db.buffs.anchorPoint, x + db.buffs.xOffset, y + db.buffs.yOffset + (E.PixelMode and (db.buffs.anchorPoint:find('TOP') and -1 or 1) or 0))
		
		if db.aurabar.attachTo ~= 'FRAME' then
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end		
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', buffs, anchorTo..'LEFT', 0, yOffset)
			auraBars:SetPoint(anchorPoint..'RIGHT', buffs, anchorTo..'RIGHT', 0, yOffset)
		end
	end
	
	if debuffs:IsShown() then
		local x, y = E:GetXYOffset(db.debuffs.anchorPoint)
		
		debuffs:ClearAllPoints()
		debuffs:Point(E.InversePoints[db.debuffs.anchorPoint], self, db.debuffs.anchorPoint, x + db.debuffs.xOffset, y + db.debuffs.yOffset)	
		
		if db.aurabar.attachTo ~= 'FRAME' then
			local anchorPoint, anchorTo = 'BOTTOM', 'TOP'
			if db.aurabar.anchorPoint == 'BELOW' then
				anchorPoint, anchorTo = 'TOP', 'BOTTOM'
			end		
			auraBars:ClearAllPoints()
			auraBars:SetPoint(anchorPoint..'LEFT', debuffs, anchorTo..'LEFT', 0, yOffset)
			auraBars:SetPoint(anchorPoint..'RIGHT', debuffs, anchorTo..'RIGHT', 0, yOffset)		
		end
	end
end