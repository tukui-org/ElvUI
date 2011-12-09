local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
WatchFrameHolder:SetWidth(130)
WatchFrameHolder:SetHeight(22)
WatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

function B:MoveWatchFrame()
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint('TOP', WatchFrameHolder, 'TOP')
	WatchFrame.ClearAllPoints = E.noop
	WatchFrame.SetPoint = E.noop
	WatchFrame:Height(E.screenheight / 2)
	
	E:CreateMover(WatchFrameHolder, 'WatchFrameMover', 'Watch Frame')
end