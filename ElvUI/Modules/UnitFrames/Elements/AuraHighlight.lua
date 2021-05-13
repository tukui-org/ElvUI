local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

function UF:Construct_AuraHighlight(frame)
	local dbh = frame:CreateTexture(nil, 'OVERLAY')
	dbh:SetInside(frame.Health.backdrop)
	dbh:SetTexture(E.media.blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode('ADD')
	dbh.PostUpdate = UF.PostUpdate_AuraHighlight

	local glow = frame:CreateShadow(nil, true)
	glow:Hide()

	frame.AuraHightlightGlow = glow
	frame.AuraHighlightFilter = true
	frame.AuraHighlightFilterTable = E.global.unitframe.AuraHighlightColors

	if frame.Health then
		dbh:SetParent(frame.Health)
		glow:SetParent(frame.Health)
	end

	return dbh
end

function UF:Configure_AuraHighlight(frame)
	if E.db.unitframe.debuffHighlighting ~= 'NONE' then
		frame:EnableElement('AuraHighlight')

		frame.AuraHighlight:SetBlendMode(UF.db.colors.debuffHighlight.blendMode)
		frame.AuraHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())
		frame.AuraHighlightFilterTable = E.global.unitframe.AuraHighlightColors

		if E.db.unitframe.debuffHighlighting == 'GLOW' then
			frame.AuraHighlightBackdrop = true
			if frame.ThreatIndicator then
				frame.AuraHightlightGlow:SetAllPoints(frame.ThreatIndicator.MainGlow)
			elseif frame.TargetGlow then
				frame.AuraHightlightGlow:SetAllPoints(frame.TargetGlow)
			end
		else
			frame.AuraHighlightBackdrop = false
		end
	else
		frame:DisableElement('AuraHighlight')
	end
end

function UF:PostUpdate_AuraHighlight(object, debuffType, _, wasFiltered)
	if debuffType and not wasFiltered then
		local color = UF.db.colors.debuffHighlight[debuffType]
		if object.AuraHighlightBackdrop and object.AuraHightlightGlow then
			object.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
		else
			object.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	end
end
