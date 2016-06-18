local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, 'oUF_AuraBars was unable to locate oUF install.')

local format = string.format
local floor, huge, min = math.floor, math.huge, math.min
local tsort = table.sort
local tremove = table.remove
local random = math.random

local function Round(number, decimalPlaces)
	if decimalPlaces and decimalPlaces > 0 then
		local mult = 10^decimalPlaces
		return floor(number * mult + .5) / mult
	end
	return floor(num + .5)
end

local DAY, HOUR, MINUTE = 86400, 3600, 60
local function FormatTime(s)
	if s < MINUTE then
		return ("%.1fs"):format(s)
	elseif s < HOUR then
		return ("%dm %ds"):format(s/60%60, s%60)
	elseif s < DAY then
		return ("%dh %dm"):format(s/(60*60), s/60%60)
	else
		return ("%dd %dh"):format(s/DAY, (s / HOUR) - (floor(s/DAY) * 24))
	end
end

local function UpdateTooltip(self)
	GameTooltip:SetUnitAura(self.__unit, self:GetParent().aura.name, self:GetParent().aura.rank, self:GetParent().aura.filter)
end

local function OnEnter(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function SetAnchors(self)
	local bars = self.bars

	for index = 1, #bars do
		local frame = bars[index]
		local anchor = frame.anchor
		frame:Height(self.auraBarHeight or 20)
		frame.statusBar.iconHolder:Size(frame:GetHeight())			
		frame:Width((self.auraBarWidth or self:GetWidth()) - (frame:GetHeight() + (self.gap or 0)))	
		frame:ClearAllPoints()
		if self.down == true then
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', (frame:GetHeight() + (self.gap or 0) ), -1)
			else
				frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-self.spacing or 0))
			end
		else
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', (frame:GetHeight() + (self.gap or 0)), 1)
			else
				frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, (self.spacing or 0))
			end
		end
	end
end

local function CreateAuraBar(oUF, anchor)
	local auraBarParent = oUF.AuraBars
	
	local frame = CreateFrame("Frame", nil, auraBarParent)
	frame:Height(auraBarParent.auraBarHeight or 20)
	frame:Width((auraBarParent.auraBarWidth or auraBarParent:GetWidth()) - (frame:GetHeight() + (auraBarParent.gap or 0)))
	frame.anchor = anchor
	
	-- the main bar
	local statusBar = CreateFrame("StatusBar", nil, frame)
	statusBar:SetStatusBarTexture(auraBarParent.auraBarTexture or [[Interface\TargetingFrame\UI-StatusBar]])
	statusBar:SetAlpha(auraBarParent.fgalpha or 1)
	statusBar:SetAllPoints(frame)
	
	frame.statusBar = statusBar
	
	if auraBarParent.down == true then
		if auraBarParent == anchor then -- Root frame so indent for icon
			frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', (frame:GetHeight() + (auraBarParent.gap or 0) ), -1)
		else
			frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-auraBarParent.spacing or 0))
		end
	else
		if auraBarParent == anchor then -- Root frame so indent for icon
			frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', (frame:GetHeight() + (auraBarParent.gap or 0)), 1)
		else
			frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, (auraBarParent.spacing or 0))
		end
	end
	
	local spark = statusBar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:Width(12);
	spark:SetBlendMode("ADD");
	spark:SetPoint('CENTER', statusBar:GetStatusBarTexture(), 'RIGHT')		
	statusBar.spark = spark
	
	statusBar.iconHolder = CreateFrame('Button', nil, statusBar)
	statusBar.iconHolder:Height(frame:GetHeight())
	statusBar.iconHolder:Width(frame:GetHeight())
	statusBar.iconHolder:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -auraBarParent.gap, 0)
	statusBar.iconHolder.__unit = oUF.unit
	statusBar.iconHolder:SetScript('OnEnter', OnEnter)
	statusBar.iconHolder:SetScript('OnLeave', OnLeave)
	statusBar.iconHolder.UpdateTooltip = UpdateTooltip
	
	statusBar.icon = statusBar.iconHolder:CreateTexture(nil, 'BACKGROUND')
	statusBar.icon:SetTexCoord(.07, .93, .07, .93)
	statusBar.icon:SetAllPoints()

	statusBar.spelltime = statusBar:CreateFontString(nil, 'ARTWORK')
	if auraBarParent.spellTimeObject then
		statusBar.spelltime:SetFontObject(auraBarParent.spellTimeObject)
	else
		statusBar.spelltime:SetFont(auraBarParent.spellTimeFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.spellTimeSize or 10)
	end
	statusBar.spelltime:SetTextColor(1 ,1, 1)
	statusBar.spelltime:SetJustifyH'RIGHT'
	statusBar.spelltime:SetJustifyV'CENTER'
	statusBar.spelltime:SetPoint'RIGHT'

	statusBar.spellname = statusBar:CreateFontString(nil, 'ARTWORK')
	if auraBarParent.spellNameObject then
		statusBar.spellname:SetFontObject(auraBarParent.spellNameObject)
	else
		statusBar.spellname:SetFont(auraBarParent.spellNameFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.spellNameSize or 10)
	end
	statusBar.spellname:SetTextColor(1, 1, 1)
	statusBar.spellname:SetJustifyH'LEFT'
	statusBar.spellname:SetJustifyV'CENTER'
	statusBar.spellname:SetPoint'LEFT'
	statusBar.spellname:SetPoint('RIGHT', statusBar.spelltime, 'LEFT')

	if auraBarParent.PostCreateBar then
		auraBarParent.PostCreateBar(frame)
	end
	
	return frame
end

local function UpdateBars(auraBars)
	local bars = auraBars.bars
	local timenow = GetTime()

	for index = 1, #bars do
		local frame = bars[index]
		local bar = frame.statusBar
		if not frame:IsVisible() then
			break
		end
		if bar.aura.noTime then
			bar.spelltime:SetText()
			bar.spark:Hide()
		else
			local timeleft = bar.aura.expirationTime - timenow
			bar:SetValue(timeleft)
			bar.spelltime:SetText(FormatTime(timeleft))
			if auraBars.spark == true then
				if (auraBars.scaleTime and ((auraBars.scaleTime <= 0) or (auraBars.scaleTime > 0 and timeleft < auraBars.scaleTime))) then
					bar.spark:Show()
				else
					bar.spark:Hide()
				end
			end
		end
	end
end

local function DefaultFilter(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate)
	if unitCaster == 'player' and not shouldConsolidate then
		return true
	end
end

local sort = function(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa > compb
end


local function Update(self, event, unit)
	if self.unit ~= unit then return end
	local auraBars = self.AuraBars
	local helpOrHarm
	local isFriend = UnitIsFriend('player', unit)
	
	if auraBars.friendlyAuraType and auraBars.enemyAuraType then
		if isFriend then
			helpOrHarm = auraBars.friendlyAuraType
		else
			helpOrHarm = auraBars.enemyAuraType
		end
	else
		helpOrHarm = isFriend and 'HELPFUL' or 'HARMFUL'
	end

	-- Create a table of auras to display
	local auras = {}
	local lastAuraIndex = 0
	local counter = 0
	if(auraBars.forceShow) then
		for index = 1, auraBars.maxBars do
			local spellID = 47540
			local name, rank, icon = GetSpellInfo(spellID)
			local count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 0, 'player', nil, nil, nil, nil
			lastAuraIndex = lastAuraIndex + 1
			auras[lastAuraIndex] = {}
			auras[lastAuraIndex].spellID = spellID
			auras[lastAuraIndex].name = name
			auras[lastAuraIndex].rank = rank
			auras[lastAuraIndex].icon = icon
			auras[lastAuraIndex].count = count
			auras[lastAuraIndex].debuffType = debuffType
			auras[lastAuraIndex].duration = duration
			auras[lastAuraIndex].expirationTime = expirationTime
			auras[lastAuraIndex].unitCaster = unitCaster
			auras[lastAuraIndex].isStealable = isStealable
			auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
			auras[lastAuraIndex].filter = helpOrHarm
			auras[lastAuraIndex].shouldConsolidate = shouldConsolidate
		end
	else
		for index = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, helpOrHarm)
			if not name then break end
			
			if (auraBars.filter or DefaultFilter)(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID) then
				lastAuraIndex = lastAuraIndex + 1
				auras[lastAuraIndex] = {}
				auras[lastAuraIndex].spellID = spellID
				auras[lastAuraIndex].name = name
				auras[lastAuraIndex].rank = rank
				auras[lastAuraIndex].icon = icon
				auras[lastAuraIndex].count = count
				auras[lastAuraIndex].debuffType = debuffType
				auras[lastAuraIndex].duration = duration
				auras[lastAuraIndex].expirationTime = expirationTime
				auras[lastAuraIndex].unitCaster = unitCaster
				auras[lastAuraIndex].isStealable = isStealable
				auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
				auras[lastAuraIndex].filter = helpOrHarm
				auras[lastAuraIndex].shouldConsolidate = shouldConsolidate
			end
		end
	end


	if(auraBars.sort and not auraBars.forceShow) then
		tsort(auras, type(auraBars.sort) == 'function' and auraBars.sort or sort)
	end

	for i=1, #auras do
		if(i > auraBars.maxBars) then
			tremove(auras, i)
		else
			lastAuraIndex = i
		end
	end

	-- Show and configure bars for buffs/debuffs.
	local bars = auraBars.bars
	if lastAuraIndex == 0 then
		self.AuraBars:Height(1)
	end
	
	for index = 1 , lastAuraIndex do
		if (auraBars:GetWidth() == 0) then break; end
		local aura = auras[index]
		local frame = bars[index]
		
		if not frame then
			frame = CreateAuraBar(self, index == 1 and auraBars or bars[index - 1])
			bars[index] = frame
		end

		if index == lastAuraIndex then
			if self.AuraBars.down then
				self.AuraBars:Height(self.AuraBars:GetTop() - frame:GetBottom())
			elseif frame:GetTop() and self.AuraBars:GetBottom() then
				self.AuraBars:Height(frame:GetTop() - self.AuraBars:GetBottom())
			else
				self.AuraBars:Height(20)
			end
		end
		
		local bar = frame.statusBar
		frame.index = index
		
		-- Backup the details of the aura onto the bar, so the OnUpdate function can use it
		bar.aura = aura

		-- Configure
		if bar.aura.noTime then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		else
			if auraBars.scaleTime and auraBars.scaleTime > 0 then
				local maxvalue = min(auraBars.scaleTime, bar.aura.duration)
				bar:SetMinMaxValues(0, auraBars.scaleTime)
				bar:Width(
					( maxvalue / auraBars.scaleTime ) *
					(	( auraBars.auraBarWidth or auraBars:GetWidth() ) -
						( bar:GetHeight() + (auraBars.gap or 0) ) ) ) 				-- icon size + gap
			else
				bar:SetMinMaxValues(0, bar.aura.duration)
			end
			bar:SetValue(bar.aura.expirationTime - GetTime())
		end

		bar.icon:SetTexture(bar.aura.icon)

		bar.spellname:SetText(bar.aura.count > 1 and format("%s [%d]", bar.aura.name, bar.aura.count) or bar.aura.name)
		bar.spelltime:SetText(not bar.noTime and FormatTime(bar.aura.expirationTime-GetTime()))

		-- Colour bars
		local r, g, b = .2, .6, 1 -- Colour for buffs
		if auraBars.buffColor then
			r, g, b = unpack(auraBars.buffColor)
		end		
		
		if helpOrHarm == 'HARMFUL' then
			local debuffType = bar.aura.debuffType and bar.aura.debuffType or 'none'
			
			r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
			if auraBars.debuffColor then
				r, g, b = unpack(auraBars.debuffColor)
			else
				if debuffType == 'none' and auraBars.defaultDebuffColor then
					r, g, b = unpack(auraBars.defaultDebuffColor)
				end
			end			
		end
		bar:SetStatusBarColor(r, g, b)
		frame:Show()
	end

	-- Hide unused bars.
	for index = lastAuraIndex + 1, #bars do
		bars[index]:Hide()
	end
	
	if auraBars.PostUpdate then
		auraBars:PostUpdate(event, unit)
	end
end

local function Enable(self)
	if self.AuraBars then
		self:RegisterEvent('UNIT_AURA', Update)
		self.AuraBars:Height(1)
		self.AuraBars.bars = self.AuraBars.bars or {}
		self.AuraBars.SetAnchors = SetAnchors
		self.AuraBars:SetScript('OnUpdate', UpdateBars)
		self.AuraBars.maxBars = self.AuraBars.maxBars or 40
		return true
	end
end

local function Disable(self)
	local auraFrame = self.AuraBars
	if auraFrame then
		self:UnregisterEvent('UNIT_AURA', Update)
		auraFrame:SetScript('OnUpdate', nil)
	end
end

oUF:AddElement('AuraBars', Update, Enable, Disable)