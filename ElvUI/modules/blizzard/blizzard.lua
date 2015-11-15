local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');
E.Blizzard = B;

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: IsAddOnLoaded, LossOfControlFrame, CreateFrame, LFRBrowseFrame

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AlertMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:SkinBlizzTimers()
	self:PositionVehicleFrame()
	self:PositionAltPowerBar()

	if not IsAddOnLoaded("DugisGuideViewerZ") then
		self:MoveObjectiveFrame()
	end

	E:CreateMover(LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

	CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end

E:RegisterModule(B:GetName())