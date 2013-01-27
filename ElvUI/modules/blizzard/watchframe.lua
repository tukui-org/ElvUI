local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
WatchFrameHolder:SetWidth(130)
WatchFrameHolder:SetHeight(22)
WatchFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

function B:MoveWatchFrame()
	E:CreateMover(WatchFrameHolder, 'WatchFrameMover', L['Watch Frame'])
	WatchFrameHolder:SetAllPoints(WatchFrameMover)

	
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint('TOP', WatchFrameHolder, 'TOP')
	WatchFrame:Height(E.screenheight / 2)
	WatchFrame:SetClampedToScreen(false)
	hooksecurefunc(WatchFrame,"SetPoint",function(_,_,parent)
		if parent ~= WatchFrameHolder then
			WatchFrame:ClearAllPoints()
			WatchFrame:SetPoint('TOP', WatchFrameHolder, 'TOP')
		end
	end)	
end