--[[
        An edited lightweight OmniCC for Tukui
                A featureless, 'pure' version of OmniCC.
                This version should work on absolutely everything, but I've removed pretty much all of the options
--]]
local db = TukuiDB["cooldown"]
if IsAddOnLoaded("OmniCC") or db.enable ~= true then return end

local TEXT_FONT = TukuiDB["media"].font
local FONT_SIZE = 15
local MIN_SCALE = 0.5
local MIN_DURATION = 3
local R, G, B = 1, 1, 1

local i
local _G = getfenv(0)
local ClassColors = {}
local strformat, strfind = string.format, string.find

for k, v in pairs(RAID_CLASS_COLORS) do
	ClassColors[k] = strformat("%2x%2x%2x", v.r*255, v.g*255, v.b*255)
end

local function classHexColor(unit)
	_, v = UnitClass(unit)
	if v and ClassColors[v] then
		return ClassColors[v]
	else
		return "FFFFFF"
	end
end

local format = string.format
local floor = math.floor
local min = math.min

local function GetFormattedTime(s)
	if s >= 86400 then
		return format("%dd", floor(s/86400 + 0.5)), s % 86400
	elseif s >= 3600 then
		return format("%dh", floor(s/3600 + 0.5)), s % 3600
	elseif s >= 60 then
		return format("%dm", floor(s/60 + 0.5)), s % 60
	elseif s <= db.treshold then
		return format("%.1f", s), s - format("%.1f", s)
	end
	return floor(s + 0.5), s - floor(s)
end

local function Timer_OnUpdate(self, elapsed)
	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < MIN_SCALE then
				self.text:SetText("")
				self.nextUpdate = 0.5
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain + 0.5) > 0 then
					local time, nextUpdate = GetFormattedTime(remain)
					self.text:SetText(time)
					self.nextUpdate = nextUpdate
					if floor(remain + 0.5) > db.treshold then 
						self.text:SetTextColor(1,1,1) 
					else
						self.text:SetTextColor(1,0,0) 
					end
				else
					self.text:Hide()
				end
			end
		end
	end
end

local function Timer_Create(self)
	local scale = min(self:GetParent():GetWidth() / TukuiDB:Scale(25), 1)
	if scale < MIN_SCALE then
		self.noOCC = true
	else
		local text = self:CreateFontString(nil, "OVERLAY")
		text:SetPoint("CENTER", 0, 0)
		text:SetFont(TEXT_FONT, (FONT_SIZE * scale), "THINOUTLINE")
		text:SetTextColor(R, G, B)

		self.text = text
		self:SetScript("OnUpdate", Timer_OnUpdate)
		return text
	end
end

local function Timer_Start(self, start, duration)
	self.start = start
	self.duration = duration
	self.nextUpdate = 0

	local text = self.text or (not self.noOCC and Timer_Create(self))
	if text then
		text:Show()
	end
end

local methods = getmetatable(ActionButton1Cooldown).__index
hooksecurefunc(methods, "SetCooldown", function(self, start, duration)
	if start > 0 and duration > MIN_DURATION then
		Timer_Start(self, start, duration)
	else
		local text = self.text
		if text then
			text:Hide()
		end
	end
end)