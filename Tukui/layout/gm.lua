------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", 250, -5)


------------------------------------------------------------------------
--	GM toggle command
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = function() ToggleHelpFrame() end