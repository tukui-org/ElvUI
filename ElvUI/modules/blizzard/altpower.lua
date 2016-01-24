local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, UIParent, PlayerPowerBarAlt, hooksecurefunc, AltPowerBarHolder

function B:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -18)
	holder:Size(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:Point('CENTER', holder, 'CENTER')
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	--The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	--calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	--Doing ".ClearAllPoints = function() end" causes error when you enter combat.
	local function Position(self)
		self:Point('CENTER', AltPowerBarHolder, 'CENTER')
	end
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", Position)

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"])
end