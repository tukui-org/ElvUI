local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Misc');

--Credit Haste

local position = {
	["BREATH"] = 'TOP#ElvUIParent#TOP#0#-96';
	["EXHAUSTION"] = 'TOP#ElvUIParent#TOP#0#-119';
	["FEIGNDEATH"] = 'TOP#ElvUIParent#TOP#0#-142';
};

local colors = {
	EXHAUSTION = {1, .9, 0};
	BREATH = {0.31, 0.45, 0.63};
	DEATH = {1, .7, 0};
	FEIGNDEATH = {1, .7, 0};
};

local Spawn, PauseAll

local barPool = {}

local loadPosition = function(self)
	local pos = position[self.type]
	local p1, frame, p2, x, y = strsplit("#", pos)

	return self:Point(p1, frame, p2, x, y)
end

local OnUpdate = function(self, elapsed)
	if(self.paused) then return end
	self.lastupdate = (self.lastupdate or 0) + elapsed
	if (self.lastupdate < .1) then return end
	self.lastupdate = 0

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

local function Spawn(type)
	if(barPool[type]) then return barPool[type] end
	local frame = CreateFrame('StatusBar', nil, E.UIParent)

	frame:SetScript("OnUpdate", OnUpdate)

	local r, g, b = unpack(colors[type])

	local bg = frame:CreateTexture(nil, 'BACKGROUND')
	bg:SetAllPoints(frame)
	bg:SetTexture(E["media"].blankTex)
	bg:SetVertexColor(r, g, b)
	bg:SetAlpha(0.2)

	local border = CreateFrame("Frame", nil, frame)
	border:SetOutside()
	border:SetTemplate("Default")
	border:SetFrameLevel(0)

	local text = frame:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate(nil, nil, 'OUTLINE')

	text:SetJustifyH'CENTER'
	text:SetTextColor(1, 1, 1)

	text:SetPoint('LEFT', frame)
	text:SetPoint('RIGHT', frame)
	text:Point('TOP', frame, 0, 2)
	text:SetPoint('BOTTOM', frame)

	frame:Size(222, 18)

	frame:SetStatusBarTexture(E['media'].normTex)
	frame:SetStatusBarColor(r, g, b)

	frame.type = type
	frame.text = text

	frame.Start = Start
	frame.Stop = Stop

	loadPosition(frame)

	barPool[type] = frame
	return frame
end

local function PauseAll(val)
	for _, bar in next, barPool do
		bar.paused = val
	end
end

function M:OnEnterWorld()
	for i=1, MIRRORTIMER_NUMTIMERS do
		local type, value, maxvalue, scale, paused, text = GetMirrorTimerInfo(i)
		if(type ~= 'UNKNOWN') then
			Spawn(type):Start(value, maxvalue, scale, paused, text)
		end
	end
end

function M:MirrorStart(event, type, value, maxvalue, scale, paused, text)
	return Spawn(type):Start(value, maxvalue, scale, paused, text)
end

function M:MirrorStop(event, type)
	return Spawn(type):Hide()
end

function M:MirrorPause(event, duration)
	return PauseAll((duration > 0 and duration) or nil)
end

function M:LoadMirrorBars()
	UIParent:UnregisterEvent('MIRROR_TIMER_START')

	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnEnterWorld')
	self:RegisterEvent('MIRROR_TIMER_START', 'MirrorStart')
	self:RegisterEvent('MIRROR_TIMER_STOP', 'MirrorStop')
	self:RegisterEvent('MIRROR_TIMER_PAUSE', 'MirrorPause')
end