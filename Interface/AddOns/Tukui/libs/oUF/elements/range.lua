--[[
	Elements handled: .Range

	Settings:
	 - inRangeAlpha - A number for frame alpha when unit is within player range.
	 Required.
	 - outsideRangeAlpha - A number for frame alpha when unit is outside player
	 range. Required.
--]]
local parent, ns = ...
local oUF = ns.oUF

local objects = oUF.objects
local OnRangeFrame

local UnitInRange, UnitIsConnected = UnitInRange, UnitIsConnected

-- updating of range.
local timer = 0
local OnRangeUpdate = function(self, elapsed)
	timer = timer + elapsed

	if(timer >= .25) then
		for _, object in next, objects do
			if(object:IsShown() and object.Range) then
				if(UnitIsConnected(object.unit) and not UnitInRange(object.unit)) then
					if(object:GetAlpha() == object.inRangeAlpha) then
						object:SetAlpha(object.outsideRangeAlpha)
					end
				elseif(object:GetAlpha() ~= object.inRangeAlpha) then
					object:SetAlpha(object.inRangeAlpha)
				end
			end
		end

		timer = 0
	end
end

local Enable = function(self)
	if(self.Range and not OnRangeFrame) then
		OnRangeFrame = CreateFrame"Frame"
		OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
	end
end

oUF:RegisterInitCallback(Enable)
