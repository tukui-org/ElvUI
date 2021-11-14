local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt or not tt.statusBarPool or tt:IsForbidden() then return end

	local sb = tt.statusBarPool:GetNextActive()
	if (not sb or not sb.Text) or sb.backdrop then return end

	sb:StripTextures()
	sb:CreateBackdrop(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:SetStyle(tt)
	if not tt or (tt == E.ScanTooltip or tt.IsEmbedded or not tt.SetTemplate or not tt.SetBackdrop) or tt:IsForbidden() then return end
	tt.customBackdropAlpha = TT.db.colorAlpha
	tt:SetTemplate('Transparent')
end
