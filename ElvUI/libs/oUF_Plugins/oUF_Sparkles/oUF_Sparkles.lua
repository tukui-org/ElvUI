local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local find = string.find
local sparkleCache = {}
local activeFrames = {}


local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(self, event, timestamp, combatEvent, ...)
	if(self[combatEvent]) then
		self[combatEvent](self, timeStamp, combatEvent, ...)
	end
end)

local function Update(self)
	if(self.Sparkle and self.Sparkle:IsShown() and self.unit) then
		activeFrames[self.Sparkle] = UnitGUID(self.unit)
	else
		activeFrames[self.Sparkle] = nil
	end
end

local function Enable(self)
	local unit = self.unit

	if self.Sparkle then
		self.Sparkle:Show()

		if(find(self.unit, "party") or find(self.unit, "raid")) then
			self:RegisterEvent('GROUP_ROSTER_UPDATE', Update)
		else
			Update(self)
		end
		

		return true
	end
end

local function Disable(self)
	if(self.Sparkle) then
		self.Sparkle:Hide()
		self:UnregisterEvent('GROUP_ROSTER_UPDATE', Update)
		Update(self)
	end
end

oUF:AddElement('Sparkle', nil, Enable, Disable)