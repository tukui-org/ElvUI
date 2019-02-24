local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local smoothing = {}
local function Smooth(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

local function SmoothBar(bar)
	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue;
		bar.SetValue = Smooth;
	end
end

local function ResetBar(bar)
	if bar.SetValue_ then
		bar.SetValue = bar.SetValue_;
		bar.SetValue_ = nil;
	end
end

local function hook(frame)
	if frame.Health then
		SmoothBar(frame.Health)
	end
	if frame.Power then
		SmoothBar(frame.Power)
	end
	if frame.AlternativePower then
		SmoothBar(frame.AlternativePower)
	end
end

for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

local f, min, max = CreateFrame('Frame'), math.min, math.max
f:SetScript('OnUpdate', function()
	local rate = GetFramerate()
	local limit = 30/rate

	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if (cur == value or abs(new - value) < 2) and bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		elseif not bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		end
	end
end)
