local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor

local fallback = { r = 0, g = 0, b = 0, a = 0 }

function UF:Construct_AuraHighlight(frame)
	local element = frame:CreateTexture(nil, 'OVERLAY')
	element:SetInside(frame.Health.backdrop)
	element:SetTexture(E.media.blankTex)
	element:SetVertexColor(0, 0, 0, 0)
	element:SetBlendMode('ADD')
	element.PostUpdate = UF.PostUpdate_AuraHighlight

	local glow = frame:CreateShadow(nil, true)
	glow:Hide()

	frame.AuraHightlightGlow = glow
	frame.AuraHighlightFilter = true
	frame.AuraHighlightFilterTable = E.global.unitframe.AuraHighlightColors

	if frame.Health then
		element:SetParent(frame.Health)
		glow:SetParent(frame.Health)
	end

	return element
end

function UF:Configure_AuraHighlight(frame)
	local mode = E.db.unitframe.debuffHighlighting
	local db = frame.db and frame.db.debuffHighlight
	if db.enable and mode ~= 'NONE' then
		if not frame:IsElementEnabled('AuraHighlight') then
			frame:EnableElement('AuraHighlight')
		end

		frame.AuraHighlight:SetBlendMode(UF.db.colors.debuffHighlight.blendMode)
		frame.AuraHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())
		frame.AuraHighlightFilterTable = E.global.unitframe.AuraHighlightColors

		if mode == 'GLOW' then
			frame.AuraHighlightBackdrop = true

			if frame.ThreatIndicator then
				frame.AuraHightlightGlow:SetAllPoints(frame.ThreatIndicator.MainGlow)
			elseif frame.TargetGlow then
				frame.AuraHightlightGlow:SetAllPoints(frame.TargetGlow)
			end
		else
			frame.AuraHighlightBackdrop = false
		end
	elseif frame:IsElementEnabled('AuraHighlight') then
		frame:DisableElement('AuraHighlight')
	end
end

function UF:PostUpdate_AuraHighlight(frame, unit, aura, debuffType, _, wasFiltered)
	if wasFiltered then return end

	local secretColor = E.Retail and aura and GetAuraDispelTypeColor(unit, aura.auraInstanceID, E.Curves.Color.Dispel)
	local color = secretColor or (E:NotSecretValue(debuffType) and UF.db.colors.debuffHighlight[debuffType]) or fallback

	if frame.AuraHighlightBackdrop and frame.AuraHightlightGlow then
		frame.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
	else
		frame.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
	end
end
