local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SearingPlasmaTrackerSkin"
local function SkinSearingPlasmaTracker(self)
	AS:SkinFrame(SearingPlasmaTrackerFrame)
end
AS:RegisterSkin(name,SkinSearingPlasmaTracker)