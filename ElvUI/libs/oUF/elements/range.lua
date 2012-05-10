local parent, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local UnitInRange, UnitIsConnected = UnitInRange, UnitIsConnected

-- updating of range.
local timer = 0
local OnRangeUpdate = function(self, elapsed)
	timer = timer + elapsed

	if(timer >= .20) then
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				local range = object.Range
				local connected = UnitIsConnected(object.unit)
				if(object.unit and connected) then
					local inRange, checkedRange = UnitInRange(object.unit)
					if(checkedRange and not inRange) then
						if(range.Override) then
							range.Override(object, 'outside')
						else
							object:SetAlpha(range.outsideAlpha)
						end
					else
						if(range.Override) then
							range.Override(object, 'inside')
						elseif(object:GetAlpha() ~= range.insideAlpha) then
							object:SetAlpha(range.insideAlpha)
						end
					end
				elseif not connected then
					object:SetAlpha(range.outsideAlpha)
				else
					object:SetAlpha(range.insideAlpha)	
				end
			end
		end

		timer = 0
	end
end

local Enable = function(self)
	local range = self.Range
	if(range and range.insideAlpha and range.outsideAlpha) then
		table.insert(_FRAMES, self)

		if(not OnRangeFrame) then
			OnRangeFrame = CreateFrame"Frame"
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
		end

		OnRangeFrame:Show()

		return true
	end
end

local Disable = function(self)
	local range = self.Range
	if(range) then
		for k, frame in next, _FRAMES do
			if(frame == self) then
				table.remove(_FRAMES, k)
				break
			end
		end

		if(#_FRAMES == 0) then
			OnRangeFrame:Hide()
		end
	end
end

oUF:AddElement('Range', nil, Enable, Disable)
