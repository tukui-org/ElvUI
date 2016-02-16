local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)
	infoPanel:CreateBackdrop("Default", true, nil, self.thinBorders)
	
	return infoPanel
end

function UF:Configure_InfoPanel(frame)
	if(frame.USE_INFO_PANEL) then
		frame.InfoPanel:Show()

		if frame.ORIENTATION == "RIGHT" and not (frame.unitframeType == "arena") then
			frame.InfoPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.BORDER - frame.SPACING, frame.BORDER + frame.SPACING)
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:SetPoint("TOPLEFT", frame.Power.backdrop, "BOTTOMLEFT", frame.BORDER, -(frame.SPACING*3))
			else
				frame.InfoPanel:SetPoint("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", frame.BORDER, -(frame.SPACING*3))
			end
		else
			frame.InfoPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			if(frame.USE_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED) then
				frame.InfoPanel:SetPoint("TOPRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", -frame.BORDER, -(frame.SPACING*3))
			else
				frame.InfoPanel:SetPoint("TOPRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", -frame.BORDER, -(frame.SPACING*3))
			end		
		end
		
		frame.InfoPanel:SetFrameStrata(frame.Health:GetFrameStrata())
		frame.InfoPanel:SetFrameLevel(frame.Health:GetFrameLevel())
	else
		frame.InfoPanel:Hide()
	end
end