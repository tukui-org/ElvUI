local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

-- Credit: ls- (lightspark)
local abs, next, Lerp = abs, next, Lerp
local activeObjects = {}
local handledObjects = {}
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
local function onUpdate(_, elapsed)
	for object, target in next, activeObjects do
		if object.SetValue_ then
			local new = Lerp(object._value, target, clamp(0.33 * elapsed * TARGET_FPS))
			if isCloseEnough(new, target, object._max - object._min) then
				new = target
				activeObjects[object] = nil
			end

			object:SetValue_(new)
			object._value = new
		else
			activeObjects[object] = nil
		end
	end
end

local function bar_SetSmoothedValue(self, value)
	self._value = self:GetValue()
	activeObjects[self] = clamp(value, self._min, self._max)
end

local function bar_SetSmoothedMinMaxValues(self, min, max)
	self:SetMinMaxValues_(min, max)

	if self._max and self._max ~= max then
		local ratio = 1
		if max ~= 0 and self._max and self._max ~= 0 then
			ratio = max / (self._max or max)
		end

		local target = activeObjects[self]
		if target then
			activeObjects[self] = target * ratio
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

local function SmoothBar(bar)
	-- reset the bar
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)

	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue
		bar.SetValue = bar_SetSmoothedValue
	end
	if not bar.SetMinMaxValues_ then
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetMinMaxValues = bar_SetSmoothedMinMaxValues
	end

	if not frame:GetScript("OnUpdate") then
		frame:SetScript("OnUpdate", onUpdate)
	end

	handledObjects[bar] = true
end

local function DesmoothBar(bar)
	local oldValue = activeObjects[bar]
	if oldValue then
		activeObjects[bar] = nil
	end

	if handledObjects[bar] then
		handledObjects[bar] = nil
	end

	if bar.SetValue_ then
		if oldValue then
			bar:SetValue_(oldValue)
		end

		bar.SetValue = bar.SetValue_
		bar.SetValue_ = nil
	end
	if bar.SetMinMaxValues_ then
		bar.SetMinMaxValues = bar.SetMinMaxValues_
		bar.SetMinMaxValues_ = nil
	end

	if not next(handledObjects) then
		frame:SetScript("OnUpdate", nil)
	end
end

function E:SetSmoothing(bar, enable)
	if enable then
		SmoothBar(bar)
	else
		DesmoothBar(bar)
	end
end
