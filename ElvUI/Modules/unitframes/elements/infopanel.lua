local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Global variables that we don't need to cache, list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)

	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default
	local thinBorders = self.thinBorders
	infoPanel:CreateBackdrop("Default", true, nil, thinBorders, true)

	return infoPanel
end

function UF:Configure_InfoPanel(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	if(frame.USE_INFO_PANEL) then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()

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

		if (not noTemplateChange) then
			local thinBorders = self.thinBorders
			if db.infoPanel.transparent then
				frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, thinBorders, true)
			else
				frame.InfoPanel.backdrop:SetTemplate("Default", true, nil, thinBorders, true)
			end
		end
	else
		frame.InfoPanel:Hide()
	end
end
