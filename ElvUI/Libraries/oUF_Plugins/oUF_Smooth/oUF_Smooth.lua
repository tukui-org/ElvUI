local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local abs, next, Lerp = abs, next, Lerp
do -- Credit: ls- (lightspark)
	local objects = {}
	local TARGET_FPS = 60

	local function clamp(v, min, max)
		min = min or 0
		max = max or 1

		if v > max then
			return max
		elseif v < min then
			return min
		end

		return v
	end

	local function isCloseEnough(new, target, range)
		if range > 0 then
			return abs((new - target) / range) <= 0.001
		end

		return true
	end

	local frame = CreateFrame("Frame", "LSBarSmoother")
	frame:SetScript("OnUpdate", function(_, elapsed)
		for object, target in next, objects do
			local new = Lerp(object._value, target, clamp(0.33 * elapsed * TARGET_FPS))
			if isCloseEnough(new, target, object._max - object._min) then
				new = target
				objects[object] = nil
			end

			object:SetValue_(new)
			object._value = new
		end
	end)

	local function bar_SetSmoothedValue(self, value)
		self._value = self:GetValue()
		objects[self] = clamp(value, self._min, self._max)
	end

	local function bar_SetSmoothedMinMaxValues(self, min, max)
		self:SetMinMaxValues_(min, max)

		if self._max and self._max ~= max then
			local ratio = 1
			if max ~= 0 and self._max and self._max ~= 0 then
				ratio = max / (self._max or max)
			end

			local target = objects[self]
			if target then
				objects[self] = target * ratio
			end

			local cur = self._value
			if cur then
				self:SetValue_(cur * ratio)
				self._value = cur * ratio
			end
		end

		self._min = min
		self._max = max
	end

	function ElvUF:SmoothBar(bar)
		-- reset the bar
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)

		bar.SetValue_ = bar.SetValue
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetValue = bar_SetSmoothedValue
		bar.SetMinMaxValues = bar_SetSmoothedMinMaxValues
	end

	function ElvUF:DesmoothBar(bar)
		if bar.SetValue_ then
			bar.SetValue = bar.SetValue_
			bar.SetValue_ = nil
		end

		if bar.SetMinMaxValues_ then
			bar.SetMinMaxValues = bar.SetMinMaxValues_
			bar.SetMinMaxValues_ = nil
		end
	end

	function ElvUF:SetSmoothing(bar, enable)
		if enable then
			self:SmoothBar(bar)
		else
			self:DesmoothBar(bar)
		end
	end
end

for _, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)
