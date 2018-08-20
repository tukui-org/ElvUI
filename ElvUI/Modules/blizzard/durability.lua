local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
--Lua functions
local _G = _G

--No point caching anything else here, but list them here for mikk's FindGlobals script
-- GLOBALS: DurabilityFrame, hooksecurefunc, Minimap

function B:PositionDurabilityFrame()
	DurabilityFrame:SetFrameStrata("HIGH")

	local function SetPosition(self, _, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT")
			DurabilityFrame:SetScale(0.6)
		end
	end
	hooksecurefunc(DurabilityFrame,"SetPoint", SetPosition)
end
