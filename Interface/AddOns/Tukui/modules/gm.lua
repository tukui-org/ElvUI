------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 0, 0)

------------------------------------------------------------------------
--	GM toggle command
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = function() ToggleHelpFrame() end