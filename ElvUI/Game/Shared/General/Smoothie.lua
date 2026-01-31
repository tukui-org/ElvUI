local E, L, V, P, G = unpack(ElvUI)

-- Credit: ls- (lightspark)

local abs, next, Lerp = abs, next, Lerp
local tonumber, assert = tonumber, assert
local activeObjects = {}
local handledObjects = {}
local TARGET_FPS = 60
local AMOUNT = 0.33

local frame = CreateFrame('Frame')
function E:Smoothing_IsCloseEnough(new, target, range)
	if range > 0 then
		return abs((new - target) / range) <= 0.001
	end

	return true
end

function E:Smoothing_OnUpdate(elapsed)
	for object, target in next, activeObjects do
		local new = Lerp(object._value, target, E:Clamp(AMOUNT * elapsed * TARGET_FPS))
		if E:Smoothing_IsCloseEnough(new, target, object._max - object._min) then
			new = target

			activeObjects[object] = nil
		end

		object:SetValue_(new)
		object._value = new
	end
end

function E:Smoothing_SetSmoothedValue(value)
	value = tonumber(value)

	assert(value, 'bar_SetSmoothedValue requires (value) to be a number.')

	self._value = self:GetValue()
	activeObjects[self] = E:Clamp(value, self._min, self._max)
end

function E:Smoothing_SetSmoothedMinMaxValues(min, max)
	min, max = tonumber(min), tonumber(max)

	assert(min and max, 'bar_SetSmoothedMinMaxValues requires (min and max) to be a number.')

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

function E:Smoothing_Enable(bar)
	bar._min, bar._max = bar:GetMinMaxValues()
	bar._value = bar:GetValue()

	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue
		bar.SetValue = E.Smoothing_SetSmoothedValue
	end
	if not bar.SetMinMaxValues_ then
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetMinMaxValues = E.Smoothing_SetSmoothedMinMaxValues
	end

	if not frame:GetScript('OnUpdate') then
		frame:SetScript('OnUpdate', E.Smoothing_OnUpdate)
	end

	handledObjects[bar] = true
end

function E:Smoothing_Disable(bar)
	if activeObjects[bar] then
		bar:SetValue_(activeObjects[bar])
		activeObjects[bar] = nil
	end

	if handledObjects[bar] then
		handledObjects[bar] = nil
	end

	if bar.SetValue_ then
		bar.SetValue = bar.SetValue_
		bar.SetValue_ = nil
	end
	if bar.SetMinMaxValues_ then
		bar.SetMinMaxValues = bar.SetMinMaxValues_
		bar.SetMinMaxValues_ = nil
	end

	if not next(handledObjects) then
		frame:SetScript('OnUpdate', nil)
	end
end

function E:SetSmoothingAmount(amount)
	AMOUNT = E:Clamp(amount, 0.2, 0.8)
end

function E:SetSmoothing(bar, enable)
	if enable then
		E:Smoothing_Enable(bar)
	else
		E:Smoothing_Disable(bar)
	end
end
