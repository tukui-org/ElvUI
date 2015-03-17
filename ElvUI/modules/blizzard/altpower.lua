local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

function B:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', UIParent)
	holder:SetPoint('TOP', E.UIParent, 'TOP', 0, -18)
	holder:Size(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint('CENTER', holder, 'CENTER')
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"])
end