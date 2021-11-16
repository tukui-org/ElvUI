local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip or tt.IsEmbedded or not tt.SetTemplate or not tt.SetBackdrop) or tt:IsForbidden() then return end
	tt.customBackdropAlpha = TT.db.colorAlpha
	tt:SetTemplate('Transparent')
end
