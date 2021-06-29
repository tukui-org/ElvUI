local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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

	specIcon.bg:ClearAllPoints()
	if frame.ORIENTATION == 'LEFT' then
		specIcon.bg:Point('TOPRIGHT', frame, 'TOPRIGHT', -UF.SPACING, -UF.SPACING)
		if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or frame.USE_INSET_POWERBAR then
			specIcon.bg:Point('BOTTOMLEFT', frame.Health.backdrop, 'BOTTOMRIGHT', (-UF.BORDER + UF.SPACING*3) + frame.PORTRAIT_WIDTH, 0)
		else
			specIcon.bg:Point('BOTTOMLEFT', frame.Power.backdrop, 'BOTTOMRIGHT', (-UF.BORDER + UF.SPACING*3) + frame.PORTRAIT_WIDTH, 0)
		end
	else
		specIcon.bg:Point('TOPLEFT', frame, 'TOPLEFT', UF.SPACING, -UF.SPACING)
		if frame.USE_MINI_POWERBAR or frame.USE_POWERBAR_OFFSET or frame.USE_INSET_POWERBAR then
			specIcon.bg:Point('BOTTOMRIGHT', frame.Health.backdrop, 'BOTTOMLEFT', (UF.BORDER - UF.SPACING*3) - frame.PORTRAIT_WIDTH, 0)
		else
			specIcon.bg:Point('BOTTOMRIGHT', frame.Power.backdrop, 'BOTTOMLEFT', (UF.BORDER - UF.SPACING*3) - frame.PORTRAIT_WIDTH, 0)
		end
	end
	if frame.db.pvpSpecIcon and not frame:IsElementEnabled('PVPSpecIcon') then
		frame:EnableElement('PVPSpecIcon')
	elseif not frame.db.pvpSpecIcon and frame:IsElementEnabled('PVPSpecIcon') then
		frame:DisableElement('PVPSpecIcon')
	end
end
