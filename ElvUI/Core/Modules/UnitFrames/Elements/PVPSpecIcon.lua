local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_PVPSpecIcon(frame)
	local specIcon = CreateFrame('Frame', nil, frame)

	specIcon.bg = CreateFrame('Frame', nil, specIcon)
	specIcon.bg:SetTemplate(nil, nil, nil, nil, true)
	specIcon.bg:SetFrameLevel(specIcon:GetFrameLevel() - 1)
	specIcon:SetInside(specIcon.bg)

	return specIcon
end

function UF:Configure_PVPSpecIcon(frame)
	local specIcon = frame.PVPSpecIcon
	local health = not frame.USE_POWERBAR or (frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or frame.USE_INSET_POWERBAR)

	specIcon.bg:ClearAllPoints()

	if frame.ORIENTATION == 'LEFT' then
		specIcon.bg:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.SPACING, -UF.SPACING)
		specIcon.bg:Point('BOTTOMLEFT', (health and frame.Health.backdrop) or frame.Power.backdrop, 'BOTTOMRIGHT', (-UF.BORDER + UF.SPACING*3) + frame.PORTRAIT_WIDTH, 0)
	else
		specIcon.bg:Point('TOPLEFT', frame, 'TOPLEFT', UF.SPACING, -UF.SPACING)
		specIcon.bg:Point('BOTTOMRIGHT', (health and frame.Health.backdrop) or frame.Power.backdrop, 'BOTTOMLEFT', (UF.BORDER - UF.SPACING*3) - frame.PORTRAIT_WIDTH, 0)
	end

	local enabled = frame:IsElementEnabled('PVPSpecIcon')
	if frame.db.pvpSpecIcon and not enabled then
		frame:EnableElement('PVPSpecIcon')
	elseif not frame.db.pvpSpecIcon and enabled then
		frame:DisableElement('PVPSpecIcon')
	end
end
