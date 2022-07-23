local E, L, V, P, G = unpack(ElvUI)
local B = E:GetModule('Blizzard')

local _G = _G
local min = min
-- local CreateFrame = CreateFrame
-- local hooksecurefunc = hooksecurefunc

function B:SetObjectiveFrameHeight()
	local top = _G.WatchFrame:GetTop() or 0
	local screenHeight = E.screenHeight
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.objectiveFrameHeight)

	_G.WatchFrame:Height(watchFrameHeight)
end
