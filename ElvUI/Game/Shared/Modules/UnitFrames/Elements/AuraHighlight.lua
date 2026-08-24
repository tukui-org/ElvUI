local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor
local CreateFrame = CreateFrame

local FALLBACK = Mixin({ r = 0, g = 0, b = 0, a = 0 }, ColorMixin)

function UF:Construct_AuraHighlight(frame)
	if E.Retail then
		local highlight = CreateFrame('Frame', '$parentAuraHighlight', frame)
		highlight.good = E:Auras_Create(highlight, 'Good')
		highlight.bad = E:Auras_Create(highlight, 'Bad')

		return highlight
	else
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
end

do
	local filters = {
		good = 'HELPFUL',
		bad = 'HARMFUL|RAID'
	}

	function UF:AuraHighlight_SetupContainer(frame, highlight, which)
		local container = highlight[which]
		if not container then return end

		container:SetAllPoints(frame.Health:GetStatusBarTexture())
		container.blendMode = UF.db.colors.debuffHighlight.blendMode
		container.highlightMode = E.db.unitframe.debuffHighlighting
		container.glowAnchor = highlight.glowAnchor
		container.filter = filters[which]
		container.isHighlight = true

		if not container.candidateTemp then
			container.candidateTemp = {}
		end -- trash object for reuse

		if which == 'good' then
			E:Auras_SetupList(container, E.global.unitframe.AuraHighlightColors)

			container:SetFrameLevel(12) -- HealPrediction uses 11
		else
			container:SetFrameLevel(13)
		end

		E:Auras_GroupUnit(container, frame.__unit)
		E:Auras_SetHighlight(container)
	end
end

function UF:Configure_AuraHighlight(frame)
	local mode = E.db.unitframe.debuffHighlighting
	local db = mode ~= 'NONE' and (frame.db and frame.db.debuffHighlight)

	local enabled = db and db.enable
	local highlight = frame.AuraHighlight
	if E.Retail then
		local good = highlight.good
		good.enabled = enabled
		good.key = 'good'

		local bad = highlight.bad
		bad.enabled = enabled
		bad.key = 'bad'
	end

	if enabled then
		if not frame:IsElementEnabled('AuraHighlight') then
			frame:EnableElement('AuraHighlight')
		end

		highlight.glowAnchor = (frame.ThreatIndicator and frame.ThreatIndicator.MainGlow) or frame.TargetGlow

		if E.Retail then -- this will lead to call on `Auras_SetEnabled`
			UF:AuraHighlight_SetupContainer(frame, highlight, 'good')
			UF:AuraHighlight_SetupContainer(frame, highlight, 'bad')
		else
			highlight:SetBlendMode(UF.db.colors.debuffHighlight.blendMode)
			highlight:SetAllPoints(frame.Health:GetStatusBarTexture())
			frame.AuraHighlightFilterTable = E.global.unitframe.AuraHighlightColors

			if mode == 'GLOW' then
				frame.AuraHighlightBackdrop = true

				if highlight.glowAnchor then
					frame.AuraHightlightGlow:SetAllPoints(highlight.glowAnchor)
				end
			else
				frame.AuraHighlightBackdrop = false
			end
		end
	elseif E.Retail then -- this will lead to call on `Auras_SetEnabled`
		E:Auras_GroupUnit(highlight.good, frame.__unit)
		E:Auras_GroupUnit(highlight.bad, frame.__unit)
	elseif frame:IsElementEnabled('AuraHighlight') then
		frame:DisableElement('AuraHighlight')
	end
end

function UF:PostUpdate_AuraHighlight(frame, unit, aura, debuffType, _, wasFiltered)
	if wasFiltered then return end

	local curve = E.Retail and E.Curves.Color.Auras.highlight
	local secretColor = curve and aura and GetAuraDispelTypeColor(unit, aura.auraInstanceID, curve)
	local color = secretColor or (E:NotSecretValue(debuffType) and UF.db.colors.debuffHighlight[debuffType]) or FALLBACK

	if frame.AuraHighlightBackdrop and frame.AuraHightlightGlow then
		frame.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
	else
		frame.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
	end
end
