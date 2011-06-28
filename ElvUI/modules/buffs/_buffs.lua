local E, C, L, DB = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales
if C["others"].minimapauras ~= true then return end

--Holder frame for mover
local holder = CreateFrame("Frame", "AurasHolder", E.UIParent)
holder:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", E.Scale(-8), E.Scale(2))
holder:SetWidth(E.Scale(456)) --(30 + 8) * 12)
holder:SetHeight(ElvuiMinimap:GetHeight() + E.Scale(3 + 19))

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("|cffeeeeee%d d|r", ceil(s / day))
	elseif s >= hour then
		return format("|cffeeeeee%d h|r", ceil(s / hour))
	elseif s >= minute then
		return format("|cffeeeeee%d m|r", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	return format("%.1f", s)
end

local function UpdateTime(self, elapsed)
	if(self.expiration) then	
		self.expiration = math.max(self.expiration - elapsed, 0)
		if(self.expiration <= 0) then
			self.time:SetText("")
		else
			local time = FormatTime(self.expiration)
			if self.expiration <= 86400.5 and self.expiration > 3600.5 then
				self.time:SetText("|cffcccccc"..time.."|r")
				E.StopFlash(self)
			elseif self.expiration <= 3600.5 and self.expiration > 60.5 then
				self.time:SetText("|cffcccccc"..time.."|r")
				E.StopFlash(self)
			elseif self.expiration <= 60.5 and self.expiration > 10.5 then
				self.time:SetText("|cffE8D911"..time.."|r")
				E.StopFlash(self)
			elseif self.expiration <= 10.5 then
				self.time:SetText("|cffff0000"..time.."|r")
				E.Flash(self, 1)
			end
		end
	end
end

local function UpdateWeapons(button, slot, active, expiration)
	if not button.texture then
		button.texture = button:CreateTexture(nil, "BORDER")
		button.texture:SetAllPoints()
		
		button.time = button:CreateFontString(nil, "ARTWORK")
		button.time:SetPoint("BOTTOM", 0, -17)
		button.time:SetFont(C["media"].font, 12, "THINOUTLINE")
		button.time:SetShadowColor(0, 0, 0, 0.4)
		button.time:SetShadowOffset(E.mult, -E.mult)
				
		button.bg = CreateFrame("Frame", nil, button)
		button.bg:CreatePanel("Default", 30, 30, "CENTER", button, "CENTER", 0, 0)
		button.bg:SetFrameLevel(button:GetFrameLevel() - 1)
		button.bg:SetFrameStrata(button:GetFrameStrata())
	end
	
	if active then
		button.id = GetInventorySlotInfo(slot)
		button.icon = GetInventoryItemTexture("player", button.id)
		button.texture:SetTexture(button.icon)
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)		
		button.expiration = (expiration/1000)
		button:SetScript("OnUpdate", UpdateTime)		
	elseif not active then
		button.texture:SetTexture(nil)
		button.time:SetText("")
		button:SetScript("OnUpdate", nil)
	end
end

local function UpdateAuras(header, button)
	if(not button.texture) then
		button.texture = button:CreateTexture(nil, "BORDER")
		button.texture:SetAllPoints()

		button.count = button:CreateFontString(nil, "ARTWORK")
		button.count:SetPoint("BOTTOMRIGHT", -1, 1)
		button.count:SetFont(C["media"].font, 12, "OUTLINE")

		button.time = button:CreateFontString(nil, "ARTWORK")
		button.time:SetPoint("BOTTOM", 0, -17)
		button.time:SetFont(C["media"].font, 12, "OUTLINE")

		button:SetScript("OnUpdate", UpdateTime)
		
		button.bg = CreateFrame("Frame", nil, button)
		button.bg:CreatePanel("Default", 30, 30, "CENTER", button, "CENTER", 0, 0)
		button.bg:SetFrameLevel(button:GetFrameLevel() - 1)
		button.bg:SetFrameStrata(button:GetFrameStrata())
		
		E.SetUpAnimGroup(button)
	end
	
	local name, _, texture, count, dtype, duration, expiration = UnitAura(header:GetAttribute("unit"), button:GetID(), header:GetAttribute("filter"))
	
	if(name) then
		button.texture:SetTexture(texture)
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.count:SetText(count > 1 and count or "")
		button.expiration = expiration - GetTime()
		
		if(header:GetAttribute("filter") == "HARMFUL") then
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			button.bg:SetBackdropBorderColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		end
	end
end

local function ScanAuras(self, event, unit)
	if(unit) then
		if(unit ~= PlayerFrame.unit) then return end
		if(unit ~= self:GetAttribute("unit")) then
			self:SetAttribute("unit", unit)
		end
	end
	
	for index = 1, 32 do		
		local child = self:GetAttribute("child" .. index)
		if(child) then
			UpdateAuras(self, child)
		end
	end
end

local TimeSinceLastUpdate = 1
local function CheckWeapons(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	
	if (TimeSinceLastUpdate >= 1) then
		local e1, e1time, _, e2, e2time, _, e3, e3time, _  = GetWeaponEnchantInfo()
		
		local w1 = self:GetAttribute("tempEnchant1")
		local w2 = self:GetAttribute("tempEnchant2")
		local w3 = self:GetAttribute("tempEnchant3")

		if w1 then UpdateWeapons(w1, "MainHandSlot", e1, e1time) end
		if w2 then UpdateWeapons(w2, "SecondaryHandSlot", e2, e2time) end
		if w3 then UpdateWeapons(w3, "RangedSlot", e3, e3time) end

		TimeSinceLastUpdate = 0
	end
end

local function CreateAuraHeader(filter, ...)
	local name	
	if filter == "HELPFUL" then name = "ElvuiPlayerBuffs" else name = "ElvuiPlayerDebuffs" end

	local header = CreateFrame("Frame", name, E.UIParent, "SecureAuraHeaderTemplate")
	header:SetPoint(...)
	header:SetClampedToScreen(true)
	header:HookScript("OnEvent", ScanAuras)
	header:SetAttribute("unit", "player")
	header:SetAttribute("sortMethod", "TIME")
	header:SetAttribute("sortDir", "-")
	header:SetAttribute("template", "ElvuiAuraTemplate")
	header:SetAttribute("filter", filter)
	header:SetAttribute("point", "TOPRIGHT")
	header:SetAttribute("xOffset", -36)
	header:SetAttribute("wrapAfter", 12)
	header:SetAttribute("minWidth", AurasHolder:GetWidth() - 2)
	header:SetAttribute("separateOwn", 1)
	
	-- look for weapons buffs
	if filter == "HELPFUL" then
		header:SetAttribute("includeWeapons", 1)
		header:SetAttribute("weaponTemplate", "ElvuiAuraTemplate")
		header:HookScript("OnUpdate", CheckWeapons)
		header:SetAttribute("minHeight", 94)	
		header:SetAttribute("wrapYOffset", -68)
		header:SetAttribute("maxWraps", 2)
		header:SetAttribute("consolidateTo", 1)
		header:SetAttribute("consolidateProxy", "ElvuiAuraTemplate")
	else
		header:SetAttribute("minHeight", 47)	
		header:SetAttribute("maxWraps", 1)	
	end
	
	header:Show()
	
	return header
end

ScanAuras(CreateAuraHeader("HELPFUL", "TOPRIGHT", AurasHolder, "TOPRIGHT", -2, -2))
ScanAuras(CreateAuraHeader("HARMFUL", "BOTTOMRIGHT", AurasHolder, "BOTTOMRIGHT", -2, -2))


function E.AurasPostDrag(self)
	local frames = {ElvuiPlayerBuffs,ElvuiPlayerDebuffs}
	for i = 1, getn(frames) do
		local frame = frames[i]
		local position, _, _, _, _ = AurasMover:GetPoint()

		if position:match("LEFT") then
			frame:SetAttribute("point", "TOPLEFT")
			frame:SetAttribute("xOffset", 36)
		else
			frame:SetAttribute("point", "TOPRIGHT")
			frame:SetAttribute("xOffset", -36)
		end
		
		if E.lowversion == true then
			frame:SetAttribute("wrapAfter", 9)
		end		
	end
end

E.CreateMover(AurasHolder, "AurasMover", "Auras Frame", false, E.AurasPostDrag)