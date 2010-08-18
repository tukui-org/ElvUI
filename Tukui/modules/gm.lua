------------------------------------------------------------------------
--	GM ticket position
------------------------------------------------------------------------

TicketStatusFrame:ClearAllPoints()
TicketStatusFrame:SetPoint("TOPLEFT", TukuiDB.Scale(4), TukuiDB.Scale(-4))
TicketStatusFrame:SetHeight(40)
TukuiDB.SetTemplate(TicketStatusFrame)

------------------------------------------------------------------------
--	GM toggle command
------------------------------------------------------------------------

SLASH_GM1 = "/gm"
SlashCmdList["GM"] = function() ToggleHelpFrame() end