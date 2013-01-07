local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local A = E:NewModule('Auras', 'AceHook-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0")

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local ceil = math.ceil
local max = math.max
local find = string.find
local format = string.format
local join = string.join

-- aura time colors for days, hours, minutes, seconds, fadetimer
A.TimeColors = {
	[0] = '|cfffefefe',
	[1] = '|cfffefefe',
	[2] = '|cfffefefe',
	[3] = '|cfffefefe',
	[4] = '|cfffe0000',
}

-- short and long aura time formats
A.TimeFormats = {
	[0] = { '%dd', '%dd' },
	[1] = { '%dh', '%dh' },
	[2] = { '%dm', '%dm' },
	[3] = { '%ds', '%d' },
	[4] = { '%.1fs', '%.1f' },
}

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
function A:AuraTimeGetInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = tonumber(E:Round(s/MINUTE))
		return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = tonumber(E:Round(s/HOUR))
		return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = tonumber(E:Round(s/DAY))
		return ceil(s / DAY), 0,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

function A:UpdateTime(elapsed)
	self.expiration = self.expiration - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end
	
	if(self.expiration <= 0) then
		self.time:SetText("")
		E:StopFlash(self)
		self:SetScript("OnUpdate", nil)
		return
	end

	local timervalue, formatid
	timervalue, formatid, self.nextupdate = A:AuraTimeGetInfo(self.expiration, E.db.auras.fadeThreshold)
	self.time:SetFormattedText(("%s%s|r"):format(A.TimeColors[formatid], A.TimeFormats[formatid][1]), timervalue)	
	if self.expiration > E.db.auras.fadeThreshold then
		E:StopFlash(self)
	else
		E:Flash(self, 1)
	end
end

function A:UpdateWeapon(button)
	if not button.backdrop then
		button:Size(E.private.auras.size + 4)
		button.backdrop = CreateFrame('Frame', nil, button)
		button.backdrop:SetAllPoints()
		button.backdrop:SetTemplate('Default', nil, true)
		button.backdrop:SetBackdropBorderColor(137/255, 0, 191/255)
		button.backdrop:SetFrameLevel(button:GetFrameLevel() - 2)
		
		button.time = _G[('%sDuration'):format(button:GetName())]
		button.icon = _G[('%sIcon'):format(button:GetName())]
		
		_G[('%sBorder'):format(button:GetName())]:Hide()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button.icon:SetInside()
		button.time:ClearAllPoints()
		button.time:Point("BOTTOM",button,'BOTTOM', 0, -10)
		button.time:FontTemplate(nil, nil, 'OUTLINE')	
	end

	local font = LSM:Fetch("font", self.db.font)
	button.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline)	
end

function A:UpdateAuras(header, button)
	if(not button.texture) then
		button.texture = button:CreateTexture(nil, "BORDER")
		button.texture:SetAllPoints()

		button.count = button:CreateFontString(nil, "ARTWORK")
		button.count:SetPoint("BOTTOMRIGHT", -1, 1)
		button.count:FontTemplate()--safty

		button.time = button:CreateFontString(nil, "ARTWORK")
		button.time:SetPoint("TOP", button, 'BOTTOM', 0, -2)
		button.time:FontTemplate()--safty
		
		button:CreateBackdrop('Default')

		button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
		button.highlight:SetTexture(1,1,1,0.45)
		button.highlight:SetAllPoints(button.texture)			
		
		E:SetUpAnimGroup(button)
	end
	local font = LSM:Fetch("font", self.db.font)
	button.count:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	button.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	
	local name, _, texture, count, dtype, duration, expiration = UnitAura(header:GetAttribute("unit"), button:GetID(), header:GetAttribute("filter"))
	
	if(name) then
		button.texture:SetTexture(texture)
		button.texture:SetTexCoord(unpack(E.TexCoords))
		button.count:SetText(count > 1 and count or "")
		button.expiration = expiration - GetTime()
		button.nextupdate = 0
		button:SetScript("OnUpdate", A.UpdateTime)
		
		if(header:GetAttribute("filter") == "HARMFUL") then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			button.backdrop:SetBackdropBorderColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		end
	end
end

function A:ScanAuras(event, unit)
	if InCombatLockdown() then 
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
	if(unit) then
		if(unit ~= PlayerFrame.unit) then return end
		if(unit ~= self:GetAttribute("unit")) and not InCombatLockdown() then
			self:SetAttribute("unit", unit)
		end
	end
	
	for index = 1, 32 do		
		local child = self:GetAttribute(format("child%d", index))
		if(child) then
			A:UpdateAuras(self, child)
		end
	end
	
	if event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end
end

function A:UpdateHeader(header)
	local db = self.db.debuffs
	if header:GetAttribute('filter') == 'HELPFUL' then
		db = self.db.buffs
		header:SetAttribute("consolidateTo", self.db.consolidatedBuffs.enable == true and E.private.general.minimap.enable == true and 1 or 0)
		header:SetAttribute("separateOwn", self.db.seperateOwn)
		header:SetAttribute('consolidateDuration', -1)
	end

	header:SetAttribute("sortMethod", db.sortMethod)
	header:SetAttribute("sortDir", db.sortDir)
	header:SetAttribute("maxWraps", db.maxWraps)
	header:SetAttribute("wrapAfter", self.db.wrapAfter)
	
	header:SetAttribute("minWidth", ((10 + E.private.auras.size) * self.db.wrapAfter) - 6)
	header:SetAttribute("minHeight", (10 - E.private.auras.size) * db.maxWraps)
	header:SetAttribute("wrapYOffset", -(18 + E.private.auras.size))
	AurasHolder:Width(header:GetAttribute('minWidth'))
	
	self.ScanAuras(header)
	
	A:PostDrag()
end

function A:UpdateAllHeaders()
	if E.private.auras.enable ~= true then return end
	local headers = {ElvUIPlayerBuffs,ElvUIPlayerDebuffs}
	for _, header in pairs(headers) do
		if header then
			A:UpdateHeader(header)
		end
	end
	
	for i = 1, 2 do
		A:UpdateWeapon(_G[("TempEnchant%d"):format(i)])
	end
end

function A:CreateAuraHeader(filter)
	local name	
	if filter == "HELPFUL" then name = "ElvUIPlayerBuffs" else name = "ElvUIPlayerDebuffs" end

	local header = CreateFrame("Frame", name, E.UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:SetAttribute("template", ("ElvUIAuraTemplate%d"):format(E.private.auras.size))
	header:HookScript("OnEvent", A.ScanAuras)
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
		
	A:UpdateHeader(header)
	header:Show()
	
	return header
end

function A:PostDrag(position)
	if InCombatLockdown() then return; end
	local headers = {ElvUIPlayerBuffs,ElvUIPlayerDebuffs}
	for _, header in pairs(headers) do
		if header then
			if not position then position = E:GetScreenQuadrant(header) end
			if find(position, "LEFT") then
				header:SetAttribute("point", "TOPLEFT")
				header:SetAttribute("xOffset", (E.private.auras.size + (E.PixelMode and 6 or 10)))
			else
				header:SetAttribute("point", "TOPRIGHT")
				header:SetAttribute("xOffset", -(E.private.auras.size + (E.PixelMode and 6 or 10)))		
			end
			
			header:ClearAllPoints()
		end
	end
	
	if find(position, "LEFT") then
		ElvUIPlayerBuffs:Point("TOPLEFT", AurasHolder, "TOPLEFT", 2, -2)
		
		if ElvUIPlayerDebuffs then
			ElvUIPlayerDebuffs:Point("BOTTOMLEFT", AurasHolder, "BOTTOMLEFT", 2, 2)
		end
	else
		ElvUIPlayerBuffs:Point("TOPRIGHT", AurasHolder, "TOPRIGHT", -2, -2)
		
		if ElvUIPlayerDebuffs then
			ElvUIPlayerDebuffs:Point("BOTTOMRIGHT", AurasHolder, "BOTTOMRIGHT", -2, 2)	
		end
	end
end

function A:WeaponPostDrag(point)
	if not point then point = E:GetScreenQuadrant(self) end
	if find(point, "LEFT") then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant1:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		TempEnchant2:SetPoint("LEFT", TempEnchant1, "RIGHT", 4, 0)	
	else
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant1:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", -4, 0)		
	end
end

function A:UpdateWeaponText(auraButton, timeLeft)
	local duration = auraButton.duration;
	if(timeLeft) then	
		if(timeLeft <= 0) then
			duration:SetText("")
			E:StopFlash(auraButton)
		else
			local timervalue, formatid = A:AuraTimeGetInfo(timeLeft, E.db.auras.fadeThreshold)
			duration:SetFormattedText(("%s%s|r"):format(A.TimeColors[formatid], A.TimeFormats[formatid][2]), timervalue)	
			if timeLeft <= E.db.auras.fadeThreshold then
				E:Flash(auraButton, 1)
			else
				E:StopFlash(auraButton)
			end
		end
	end
end

function A:Initialize()
	if self.db then return; end --IDK WHY BUT THIS IS GETTING CALLED TWICE FROM SOMEWHERE...
	
	local color = E.db.actionbar.expiringcolor
	A.TimeColors[4] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that are soon to expire
	
	color = E.db.actionbar.secondscolor
	A.TimeColors[3] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have seconds remaining
	
	color = E.db.actionbar.minutescolor
	A.TimeColors[2] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have minutes remaining
	
	color = E.db.actionbar.hourscolor
	A.TimeColors[1] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have hours remaining
	
	color = E.db.actionbar.dayscolor
	A.TimeColors[0] = E:RGBToHex(color.r, color.g, color.b) -- color for timers that have days remaining	

	self.db = E.db.auras
	
	BuffFrame:Kill()
	ConsolidatedBuffs:Kill()
	InterfaceOptionsFrameCategoriesButton12:SetScale(0.0001)
	
	self:Construct_ConsolidatedBuffs()
	if E.private.auras.enable ~= true then TemporaryEnchantFrame:Kill(); return end
	
	local holder = CreateFrame("Frame", "AurasHolder", E.UIParent)
	holder:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -8, 2)
	holder:Width(456)
	holder:Height(E.MinimapHeight)
	
	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
	
	self.EnchantHeader = CreateFrame('Frame', 'ElvUITemporaryEnchantFrame', E.UIParent, 'SecureHandlerStateTemplate');
	self.EnchantHeader:Size((E.private.auras.size + 6) * 2, E.private.auras.size + 4)
	self.EnchantHeader:Point('TOPRIGHT', MMHolder, 'BOTTOMRIGHT', 0, -4)
	self.EnchantHeader:SetAttribute("_onstate-show", [[		
			if newstate == "hide" then
				self:Hide();
			else
				self:Show();
			end	
		]]);
	
	RegisterStateDriver(self.EnchantHeader, "show", '[petbattle] hide;show');	
	self:SecureHook('AuraButton_UpdateDuration', 'UpdateWeaponText')
	TemporaryEnchantFrame:SetParent(self.EnchantHeader)
	
	for i = 1, 2 do
		A:UpdateWeapon(_G[("TempEnchant%d"):format(i)])
	end

	E:CreateMover(AurasHolder, "AurasMover", L["Auras Frame"], nil, nil, A.PostDrag)
	E:CreateMover(self.EnchantHeader, 'TempEnchantMover', L['Weapons'], nil, nil, A.WeaponPostDrag)
end

E:RegisterModule(A:GetName())