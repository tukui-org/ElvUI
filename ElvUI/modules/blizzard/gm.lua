------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 250, -5)

E.CreateMover(TicketStatusFrame, "GMMover", "GM Ticket Frame")

HelpOpenTicketButton:SetParent(Minimap)
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT")