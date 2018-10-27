local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Threat(frame)
	local threat = CreateFrame("Frame", nil, frame)

	--Main ThreatGlow
	frame:CreateShadow('Default')
	threat.glow = frame.shadow
	threat.glow:SetParent(frame)
	threat.glow:Hide()
	frame.shadow = nil

	--Secondary ThreatGlow, for power frame when using power offset
	frame:CreateShadow('Default')
	threat.powerGlow = frame.shadow
	threat.powerGlow:SetParent(frame)
	threat.powerGlow:SetFrameStrata('BACKGROUND')
	threat.powerGlow:Hide()
	frame.shadow = nil

	threat.texIcon = threat:CreateTexture(nil, 'OVERLAY')
	threat.texIcon:Size(8)
	threat.texIcon:SetTexture(E.media.blankTex)
	threat.texIcon:Hide()

	threat.PostUpdate = self.UpdateThreat
	return threat
end

function UF:Configure_Threat(frame)
	if not frame.VARIABLES_SET then return end
	local threat = frame.ThreatIndicator
	local db = frame.db

	if db.threatStyle ~= 'NONE' and db.threatStyle ~= nil then
		if not frame:IsElementEnabled('ThreatIndicator') then
			frame:EnableElement('ThreatIndicator')
		end

		if db.threatStyle == "GLOW" then
			threat:SetFrameStrata('BACKGROUND')
			threat.glow:SetFrameStrata('BACKGROUND')
			threat.glow:ClearAllPoints()
			if frame.USE_POWERBAR_OFFSET then
				if frame.ORIENTATION == "RIGHT" then
					threat.glow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING + (frame.USE_CLASSBAR and (frame.USE_MINI_CLASSBAR and 0 or frame.CLASSBAR_HEIGHT) or 0))
					threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
				else
					threat.glow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING + (frame.USE_CLASSBAR and (frame.USE_MINI_CLASSBAR and 0 or frame.CLASSBAR_HEIGHT) or 0))
					threat.glow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
				end

				threat.powerGlow:ClearAllPoints()
				threat.powerGlow:Point("TOPLEFT", frame.Power.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING)
				threat.powerGlow:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
			else
				threat.glow:Point("TOPLEFT", -frame.SHADOW_SPACING, frame.SHADOW_SPACING-(frame.USE_MINI_CLASSBAR and frame.CLASSBAR_YOFFSET or 0))

				if frame.USE_MINI_POWERBAR then
					threat.glow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
					threat.glow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
				else
					threat.glow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
					threat.glow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
				end
			end
		elseif db.threatStyle == "ICONTOPLEFT" or db.threatStyle == "ICONTOPRIGHT" or db.threatStyle == "ICONBOTTOMLEFT" or db.threatStyle == "ICONBOTTOMRIGHT" or db.threatStyle == "ICONTOP" or db.threatStyle == "ICONBOTTOM" or db.threatStyle == "ICONLEFT" or db.threatStyle == "ICONRIGHT" then
			threat:SetFrameStrata('LOW')
			threat:SetFrameLevel(75) --Inset power uses 50, we want it to appear above that
			local point = db.threatStyle
			point = point:gsub("ICON", "")

			threat.texIcon:ClearAllPoints()
			threat.texIcon:Point(point, frame.Health, point)
		elseif db.threatStyle == "HEALTHBORDER" then
			if frame.InfoPanel then
				frame.InfoPanel:SetFrameLevel(frame.Health:GetFrameLevel() - 3)
			end
		elseif db.threatStyle == "INFOPANELBORDER" then
			if frame.InfoPanel then
				frame.InfoPanel:SetFrameLevel(frame.Health:GetFrameLevel() + 3)
			end
		end
	elseif frame:IsElementEnabled('ThreatIndicator') then
		frame:DisableElement('ThreatIndicator')
	end
end

function UF:UpdateThreat(unit, status, r, g, b)
	local parent = self:GetParent()

	if (parent.unit ~= unit) or not unit then return end

	local db = parent.db
	if not db then return end

	if status and status > 1 then
		if db.threatStyle == 'GLOW' then
			self.glow:Show()
			self.glow:SetBackdropBorderColor(r, g, b)

			if parent.USE_POWERBAR_OFFSET then
				self.powerGlow:Show()
				self.powerGlow:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.ClassBar and parent[parent.ClassBar] and parent[parent.ClassBar].backdrop then
				parent[parent.ClassBar].backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.InfoPanel and parent.InfoPanel.backdrop then
				parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle == 'INFOPANELBORDER' then
			parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Show()
			self.texIcon:SetVertexColor(r, g, b)
		end
	else
		r, g, b = unpack(E.media.unitframeBorderColor)
		if db.threatStyle == 'GLOW' then
			self.glow:Hide()
			self.powerGlow:Hide()
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.ClassBar and parent[parent.ClassBar] and parent[parent.ClassBar].backdrop then
				parent[parent.ClassBar].backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.InfoPanel and parent.InfoPanel.backdrop then
				parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle == 'INFOPANELBORDER' then
			parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Hide()
		end
	end
end
