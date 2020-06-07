local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)
	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default

	local thinBorders = self.thinBorders
	infoPanel:CreateBackdrop(nil, true, nil, thinBorders, true)

	return infoPanel
end

function UF:Configure_InfoPanel(frame)
	local db = frame.db

	if frame.USE_INFO_PANEL then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()
		frame.InfoPanel:Size(db.width - (frame.BORDER * 2), db.infoPanel.height)

		local parent

		if not db.infoPanel.above and (frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
			parent = frame.Power.backdrop
		else
			parent = frame.Health.backdrop
		end

		if db.infoPanel.above then
			frame.InfoPanel:Point('BOTTOM', parent, 'TOP', 0, (frame.SPACING*3))
		else
			frame.InfoPanel:Point('TOP', parent, 'BOTTOM', 0, -(frame.SPACING*3))
		end

		local thinBorders = self.thinBorders
		if db.infoPanel.transparent then
			frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, thinBorders, true)
		else
			frame.InfoPanel.backdrop:SetTemplate(nil, true, nil, thinBorders, true)
		end
	else
		frame.InfoPanel:Hide()
	end
end
