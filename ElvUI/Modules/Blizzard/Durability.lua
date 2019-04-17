local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

--Lua functions
local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetPosition(frame, _, parent)
	if parent == "MinimapCluster" or parent == _G.MinimapCluster then
		frame:ClearAllPoints()
		frame:Point("RIGHT", _G.Minimap, "RIGHT")
		frame:SetScale(0.6)
	end
end

function B:PositionDurabilityFrame()
	local DurabilityFrame = _G.DurabilityFrame
	DurabilityFrame:SetFrameStrata("HIGH")

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end
