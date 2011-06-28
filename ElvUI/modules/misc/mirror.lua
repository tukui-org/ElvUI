
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

---------------------------------------------------------------------
-- original by haste, edited for Elvui :)
---------------------------------------------------------------------

local _, settings = ...

local _DEFAULTS = {
	width = E.Scale(220),
	height = E.Scale(18),
	texture = C["media"].normTex,

	position = {
		["BREATH"] = 'TOP#ElvUIParent#TOP#0#-96';
		["EXHAUSTION"] = 'TOP#ElvUIParent#TOP#0#-119';
		["FEIGNDEATH"] = 'TOP#ElvUIParent#TOP#0#-142';
	};

	colors = {
		EXHAUSTION = {1, .9, 0};
		BREATH = {0.31, 0.45, 0.63};
		DEATH = {1, .7, 0};
		FEIGNDEATH = {1, .7, 0};
	};
}

do
	settings = setmetatable(settings, {__index = _DEFAULTS})
	for k,v in next, settings do
		if(type(v) == 'table') then
			settings[k] = setmetatable(settings[k], {__index = _DEFAULTS[k]})
		end
	end
end

local Spawn, PauseAll
do
	local barPool = {}

	local loadPosition = function(self)
		local pos = settings.position[self.type]
		local p1, frame, p2, x, y = strsplit("#", pos)

		return self:SetPoint(p1, frame, p2, E.Scale(x), E.Scale(y))
	end

	local OnUpdate = function(self, elapsed)
		if(self.paused) then return end

		self:SetValue(GetMirrorTimerProgress(self.type) / 1e3)
	end

	local Start = function(self, value, maxvalue, scale, paused, text)
		if(paused > 0) then
			self.paused = 1
		elseif(self.paused) then
			self.paused = nil
		end

		self.text:SetText(text)

		self:SetMinMaxValues(0, maxvalue / 1e3)
		self:SetValue(value / 1e3)

		if(not self:IsShown()) then self:Show() end
	end

	function Spawn(type)
		if(barPool[type]) then return barPool[type] end
		local frame = CreateFrame('StatusBar', nil, E.UIParent)

		frame:SetScript("OnUpdate", OnUpdate)

		local r, g, b = unpack(settings.colors[type])

		local bg = frame:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(frame)
		bg:SetTexture(C["media"].blank)
		bg:SetVertexColor(r * .5, g * .5, b * .5)
		
		local border = CreateFrame("Frame", nil, frame)
		border:SetPoint("TOPLEFT", frame, E.Scale(-2), E.Scale(2))
		border:SetPoint("BOTTOMRIGHT", frame, E.Scale(2), E.Scale(-2))
		border:SetTemplate("Default")
		border:SetFrameLevel(0)

		local text = frame:CreateFontString(nil, 'OVERLAY')
		text:SetFont(C["media"].uffont, C["general"].fontscale, "THINOUTLINE")
		text:SetShadowOffset(E.mult, -E.mult)
		text:SetShadowColor(0, 0, 0, 1)

		text:SetJustifyH'CENTER'
		text:SetTextColor(1, 1, 1)

		text:SetPoint('LEFT', frame)
		text:SetPoint('RIGHT', frame)
		text:SetPoint('TOP', frame, 0, E.Scale(2))
		text:SetPoint('BOTTOM', frame)

		frame:SetSize(settings.width, settings.height)

		frame:SetStatusBarTexture(settings.texture)
		frame:SetStatusBarColor(r, g, b)

		frame.type = type
		frame.text = text

		frame.Start = Start
		frame.Stop = Stop

		loadPosition(frame)

		barPool[type] = frame
		return frame
	end

	function PauseAll(val)
		for _, bar in next, barPool do
			bar.paused = val
		end
	end
end

local frame = CreateFrame'Frame'
frame:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, ...)
end)

function frame:ADDON_LOADED(addon)
	if(addon == 'ElvUI') then
		UIParent:UnregisterEvent'MIRROR_TIMER_START'

		self:UnregisterEvent'ADDON_LOADED'
		self.ADDON_LOADED = nil
	end
end
frame:RegisterEvent'ADDON_LOADED'

function frame:PLAYER_ENTERING_WORLD()
	for i=1, MIRRORTIMER_NUMTIMERS do
		local type, value, maxvalue, scale, paused, text = GetMirrorTimerInfo(i)
		if(type ~= 'UNKNOWN') then
			Spawn(type):Start(value, maxvalue, scale, paused, text)
		end
	end
end
frame:RegisterEvent'PLAYER_ENTERING_WORLD'

function frame:MIRROR_TIMER_START(type, value, maxvalue, scale, paused, text)
	return Spawn(type):Start(value, maxvalue, scale, paused, text)
end
frame:RegisterEvent'MIRROR_TIMER_START'

function frame:MIRROR_TIMER_STOP(type)
	return Spawn(type):Hide()
end
frame:RegisterEvent'MIRROR_TIMER_STOP'

function frame:MIRROR_TIMER_PAUSE(duration)
	return PauseAll((duration > 0 and duration) or nil)
end
frame:RegisterEvent'MIRROR_TIMER_PAUSE'
