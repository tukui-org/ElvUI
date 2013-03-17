local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

--Credit: Omega1970

local cos, sin, sqrt2 = math.cos, math.sin, math.sqrt(2)


local function CalculateCorner(r)
	return 0.5 + cos(r) / sqrt2, 0.5 + sin(r) / sqrt2;
end

local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163);
	local LLx, LLy = CalculateCorner(angle + 2.35619449);
	local ULx, ULy = CalculateCorner(angle + 3.92699082);
	local URx, URy = CalculateCorner(angle - 0.785398163);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local inRange
local Update = function(self, elapsed)
	if self.elapsed and self.elapsed > 0.02 then
		local GPS = self.parent
		local frame = self.parent:GetParent()
		local unit = frame.unit
		
		if(GPS.PreUpdate) then GPS:PreUpdate(frame) end
		
		if unit and GPS.outOfRange then
			inRange = UnitInRange(unit)
		end

		if not unit or not (UnitInParty(unit) or UnitInRaid(unit)) or UnitIsUnit(unit, "player") or not UnitIsConnected(unit) or (GPS.onMouseOver and (GetMouseFocus() ~= frame)) or (GPS.outOfRange and inRange) then
			GPS:Hide()
			return
		end

		local _, angle = ElvUI[1]:GetDistance("player", unit)
		if not angle then
			GPS:Hide()
			return
		end

		GPS:Show()
		
		if GPS.Texture then
			RotateTexture(GPS.Texture, angle)
		end
		
		if(GPS.PostUpdate) then GPS:PostUpdate(frame) end
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

local Enable = function(self)
	local GPS = self.GPS
	if GPS then
		if not GPS.UpdateFrame then
			GPS.UpdateFrame = CreateFrame("Frame")
			GPS.UpdateFrame.parent = GPS
		end

		GPS.UpdateFrame:SetScript("OnUpdate", Update)
		GPS:Show()
		return true
	end
end
 
local Disable = function(self)
	local GPS = self.GPS
	if GPS then
		GPS.UpdateFrame:SetScript("OnUpdate", nil)
		GPS:Hide()
	end
end
 
oUF:AddElement('GPS', nil, Enable, Disable)