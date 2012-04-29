local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local B = E:NewModule('Blizzard', 'AceEvent-3.0');

E.Blizzard = B;

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AchievementMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:SkinBlizzTimers()
	self:PositionVehicleFrame()
	self:MoveWatchFrame()
	
	CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)	
end

E:RegisterModule(B:GetName())