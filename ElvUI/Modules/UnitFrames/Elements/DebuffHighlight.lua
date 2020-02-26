local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

function UF:Construct_DebuffHighlight(frame)
	local dbh = frame:CreateTexture(nil, "OVERLAY")
	dbh:SetInside(frame.Health.backdrop)
	dbh:SetTexture(E.media.blankTex)
	dbh:SetVertexColor(0, 0, 0, 0)
	dbh:SetBlendMode("ADD")
	dbh.PostUpdate = UF.PostUpdate_DebuffHighlight

	local glow = frame:CreateShadow(nil, true)
	glow:Hide()

	frame.DBHGlow = glow
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0.45
	frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors

	if frame.Health then
		dbh:SetParent(frame.Health)
		glow:SetParent(frame.Health)
	end

	return dbh
end

function UF:Configure_DebuffHighlight(frame)
	if E.db.unitframe.debuffHighlighting ~= 'NONE' then
		frame:EnableElement('DebuffHighlight')

		frame.DebuffHighlight:SetBlendMode(UF.db.colors.debuffHighlight.blendMode)
		frame.DebuffHighlightFilterTable = E.global.unitframe.DebuffHighlightColors

		if E.db.unitframe.debuffHighlighting == 'GLOW' then
			frame.DebuffHighlightBackdrop = true
			if frame.ThreatIndicator then
				frame.DBHGlow:SetAllPoints(frame.ThreatIndicator.glow)
			elseif frame.TargetGlow then
				frame.DBHGlow:SetAllPoints(frame.TargetGlow)
			end
		else
			frame.DebuffHighlightBackdrop = false
		end
	else
		frame:DisableElement('DebuffHighlight')
	end
end

function UF:PostUpdate_DebuffHighlight(object, debuffType, texture, wasFiltered, style, color)
	if debuffType and not wasFiltered then
		color = UF.db.colors.debuffHighlight[debuffType]
		if object.DebuffHighlightBackdrop and object.DBHGlow then
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
		else
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	end
end
