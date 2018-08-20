local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, HelpOpenWebTicketButton, Minimap, GMMover, UIParent, hooksecurefunc

function B:PositionGMFrames()
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:Point("TOPLEFT", E.UIParent, 'TOPLEFT', 250, -5)
	E:CreateMover(TicketStatusFrame, "GMMover", L["GM Ticket Frame"])

	--Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, _, anchor)
		if anchor == UIParent then
			TicketStatusFrame:ClearAllPoints()
			TicketStatusFrame:Point("TOPLEFT", GMMover, 0, 0)
		end
	end)

	HelpOpenTicketButton:SetParent(Minimap)
	HelpOpenWebTicketButton:SetParent(Minimap)
end
