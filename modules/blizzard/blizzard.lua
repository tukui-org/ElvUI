local E, L, DF = unpack(select(2, ...)); --Engine
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
end

E:RegisterModule(B:GetName())