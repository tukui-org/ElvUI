------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 250, -5)

ElvDB.CreateMover(TicketStatusFrame, "GMMover", "GM Ticket Frame")