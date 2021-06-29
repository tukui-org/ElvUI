local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame('Frame', '$parent_InfoPanel', frame)
	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default
	infoPanel:CreateBackdrop(nil, true, nil, nil, true)

	return infoPanel
end

function UF:Configure_InfoPanel(frame)
	local db = frame.db

	if frame.USE_INFO_PANEL then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()

		if frame.ORIENTATION == 'RIGHT' and not (frame.unitframeType == 'arena') then
			frame.InfoPanel:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -UF.BORDER - UF.SPACING, UF.BORDER + UF.SPACING)
			if frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED then
				frame.InfoPanel:Point('TOPLEFT', frame.Power.backdrop, 'BOTTOMLEFT', UF.BORDER, -(UF.SPACING*3))
			else
				frame.InfoPanel:Point('TOPLEFT', frame.Health.backdrop, 'BOTTOMLEFT', UF.BORDER, -(UF.SPACING*3))
			end
		else
			frame.InfoPanel:Point('BOTTOMLEFT', frame, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)
			if frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED then
				frame.InfoPanel:Point('TOPRIGHT', frame.Power.backdrop, 'BOTTOMRIGHT', -UF.BORDER, -(UF.SPACING*3))
			else
				frame.InfoPanel:Point('TOPRIGHT', frame.Health.backdrop, 'BOTTOMRIGHT', -UF.BORDER, -(UF.SPACING*3))
			end
		end

		if db.infoPanel.transparent then
			frame.InfoPanel.backdrop:SetTemplate('Transparent', nil, nil, nil, true)
		else
			frame.InfoPanel.backdrop:SetTemplate(nil, true, nil, nil, true)
		end
	else
		frame.InfoPanel:Hide()
	end
end
