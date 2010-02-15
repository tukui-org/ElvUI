-- credit nightcracker

local ICON_SIZE = 20 --the normal size for an icon (don't change this)
local TEXT_FONT = "Interface\\Addons\\Tukui\\media\\Russel Square LT.ttf" --what font to use
local FONT_SIZE = 22 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 3 --the minimum duration to show cooldown text for
local DAY, HOUR, MINUTE = 86400, 3600, 60

local THRESHOLD = 6.5
local COLOR = {1, 1, 1}
local THRESHOLDCOLOR = {1, 0, 0}
local FADE = true

local format = string.format
local floor = math.floor

function formattime(s)
	if s >= DAY then
			return format('%dd', floor(s/DAY + 0.5)), s%DAY
	elseif s >= HOUR then
			return format('%dh', floor(s/HOUR + 0.5)), s%HOUR
	elseif s >= MINUTE then
			return format('%dm', floor(s/MINUTE + 0.5)), s%MINUTE
	elseif s <= THRESHOLD then
		return format("%.1f", s), s - format("%.1f", s)
	end
	return floor(s + 0.5), s - floor(s)
end
local function update(self, elapsed)
	if not self.text:IsShown() then return end
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
	elseif (self:GetEffectiveScale()/UIParent:GetEffectiveScale()) < MIN_SCALE then
		self.text:SetText("")
		self.nextupdate = 1
	else
		self.nextupdate = 1
		local remaining = self.duration - (GetTime() - self.start)		
		if remaining > 0 then
			local ftime, nextupdate = formattime(remaining)
			self.text:SetText(ftime)
			self.nextupdate = nextupdate
			if self:GetParent().action and FADE then self.texture:Show() else self.texture:Hide() end
			if remaining > TRESHOLD then self.text:SetTextColor(unpack(COLOR)) else self.text:SetTextColor(unpack(TRESHOLDCOLOR)) end
		else
			self.text:SetText("")
			self.text:Hide()
			self.texture:Hide()
		end
	end
end
local function createtext(self)
	local scale = min(self:GetParent():GetWidth() / ICON_SIZE, 1)
	if scale < MIN_SCALE then
			self.noOCC = true
	else
		local text = self:GetParent():CreateFontString(nil, "OVERLAY")
		text:SetFont(TEXT_FONT, FONT_SIZE * scale)
		text:SetPoint("CENTER")	
		local texture = self:GetParent():CreateTexture()
		texture:SetPoint("TOPLEFT", self, 2, -2)
		texture:SetPoint("BOTTOMRIGHT", self, -2, 2)
		texture:SetTexture(0, 0, 0, .5)
		self:SetScript("OnUpdate", update)
		self:SetAlpha(0)
		self:SetScript("OnHide", function() text:Hide() texture:Hide() end)
		self:SetScript("OnShow", function() text:Show() texture:Show() end)
		self.texture = texture
		self.text = text	
		return text
	end
end
local function startcd(self, start, duration)
	if start > 0 and duration > MIN_DURATION then
		self.start = start
		self.duration = duration
		self.nextupdate = 0
		
		local height = self:GetHeight()
		self.height = height
		
		local text = self.text or createtext(self)
		if text then
			text:Show()
		end
	end
end
hooksecurefunc(getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index, "SetCooldown", startcd)