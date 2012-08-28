local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

function B:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', UIParent)
<<<<<<< HEAD
	holder:SetPoint('BOTTOM', E.UIParent, 'BOTTOM', 0, 195)
=======
	holder:SetPoint('TOP', E.UIParent, 'TOP', 0, -108)
>>>>>>> ElvUI/master
	holder:Size(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint('CENTER', holder, 'CENTER')
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true
	
	E:CreateMover(holder, 'AltPowerBarMover', 'Alternative Power')
end