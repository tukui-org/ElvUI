local E, L, V, P, G = unpack(ElvUI)
local TT = E:GetModule('Tooltip')

function TT:GameTooltip_ShowStatusBar(tt)
	if not tt or not tt.statusBarPool or tt:IsForbidden() then return end

	local sb = tt.statusBarPool:GetNextActive()
	if not (sb and sb.Text and sb.NineSlice) or sb.NineSlice.template then return end

	sb.NineSlice:SetTemplate(nil, nil, true)
	sb:SetStatusBarTexture(E.media.normTex)
end

function TT:SetStyle(tt, _, isEmbedded)
	if not tt or (tt == E.ScanTooltip or isEmbedded or tt.IsEmbedded or not tt.NineSlice) or tt:IsForbidden() then return end

	if tt.Delimiter1 then tt.Delimiter1:SetTexture() end
	if tt.Delimiter2 then tt.Delimiter2:SetTexture() end

	tt.NineSlice.customBackdropAlpha = TT.db.colorAlpha
	tt.NineSlice:SetTemplate('Transparent')
end
