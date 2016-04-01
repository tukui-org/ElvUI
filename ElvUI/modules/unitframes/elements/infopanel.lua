local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)
	infoPanel:SetFrameStrata("LOW")
	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default
	local thinBorders = self.thinBorders
	if(E.global.tukuiMode) then
		thinBorders = false
	end
	infoPanel:CreateBackdrop("Default", true, nil, thinBorders)

	return infoPanel
end

function UF:Configure_InfoPanel(frame, noTemplateChange)
	local db = frame.db

	if(frame.USE_INFO_PANEL) then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()

		if frame.ORIENTATION == "RIGHT" and not (frame.unitframeType == "arena") then
			frame.InfoPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.BORDER - frame.SPACING - (E.global.tukuiMode and frame.BORDER*2 or 0), frame.BORDER + frame.SPACING + (E.global.tukuiMode and frame.BORDER*2 or 0))
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:SetPoint("TOPLEFT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER - frame.STAGGER_WIDTH + (E.global.tukuiMode and frame.BORDER*2 or 0), -(frame.SPACING*3) - (E.global.tukuiMode and frame.BORDER*2 or 0))
			else
				frame.InfoPanel:SetPoint("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER - frame.STAGGER_WIDTH + (E.global.tukuiMode and frame.BORDER*2 or 0), -(frame.SPACING*3) - (E.global.tukuiMode and frame.BORDER*2 or 0))
			end
		else
			frame.InfoPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING + (E.global.tukuiMode and frame.BORDER*2 or 0), frame.BORDER + frame.SPACING + (E.global.tukuiMode and frame.BORDER*2 or 0))
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:SetPoint("TOPRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.STAGGER_WIDTH - (E.global.tukuiMode and frame.BORDER*2 or 0), -(frame.SPACING*3) - (E.global.tukuiMode and frame.BORDER*2 or 0))
			else
				frame.InfoPanel:SetPoint("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER + frame.STAGGER_WIDTH - (E.global.tukuiMode and frame.BORDER*2 or 0), -(frame.SPACING*3) - (E.global.tukuiMode and frame.BORDER*2 or 0))
			end
		end

		if (not noTemplateChange) then
			local thinBorders = self.thinBorders
			if(E.global.tukuiMode) then
				thinBorders = false
			end

			if db.infoPanel.transparent then
				frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, thinBorders)
			else
				frame.InfoPanel.backdrop:SetTemplate("Default", true, nil, thinBorders)
			end
		end
	else
		frame.InfoPanel:Hide()
	end
end