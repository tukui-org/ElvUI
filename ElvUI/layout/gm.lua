------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------
local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 250, -5)

DB.CreateMover(TicketStatusFrame, "GMMover", "GM Ticket Frame")