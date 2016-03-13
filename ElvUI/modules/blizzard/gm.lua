local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: TicketStatusFrame, HelpOpenTicketButton, Minimap

function B:PositionGMFrames()
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:Point("TOPLEFT", E.UIParent, 'TOPLEFT', 250, -5)

	E:CreateMover(TicketStatusFrame, "GMMover", L["GM Ticket Frame"])

	HelpOpenTicketButton:SetParent(Minimap)
	HelpOpenTicketButton:ClearAllPoints()
	HelpOpenTicketButton:Point("TOPRIGHT", Minimap, "TOPRIGHT")
end