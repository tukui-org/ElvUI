local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local unpack = unpack
local CreateFrame = CreateFrame

function UF:Construct_Threat(frame)
	local threat = CreateFrame("Frame", nil, frame)

	--Main ThreatGlow
	threat.MainGlow = frame:CreateShadow(nil, true)
	threat.MainGlow:SetParent(frame)
	threat.MainGlow:Hide()

	--Secondary ThreatGlow, for power frame when using power offset
	threat.PowerGlow = frame:CreateShadow(nil, true)
	threat.PowerGlow:SetParent(frame)
	threat.PowerGlow:SetFrameStrata('BACKGROUND')
	threat.PowerGlow:Hide()

	threat.TextureIcon = threat:CreateTexture(nil, 'OVERLAY')
	threat.TextureIcon:Size(8)
	threat.TextureIcon:SetTexture(E.media.blankTex)
	threat.TextureIcon:Hide()

	threat.PostUpdate = self.UpdateThreat
	return threat
end

function UF:Configure_Threat(frame)
	if not frame.ThreatIndicator then return end

	local threat = frame.ThreatIndicator
	if not threat then return end

	local db = frame.db
	if db.threatStyle and db.threatStyle ~= 'NONE' then
		if not frame:IsElementEnabled('ThreatIndicator') then
			frame:EnableElement('ThreatIndicator')
		end

		if db.threatStyle == "GLOW" then
			threat:SetFrameStrata('BACKGROUND')
			threat.MainGlow:SetFrameStrata('BACKGROUND')
			threat.MainGlow:ClearAllPoints()
			if frame.USE_POWERBAR_OFFSET then
				threat.MainGlow:Point("TOPLEFT", frame.Health.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING + (frame.USE_CLASSBAR and (frame.USE_MINI_CLASSBAR and 0 or frame.CLASSBAR_HEIGHT) or 0))
				threat.MainGlow:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)

				threat.PowerGlow:ClearAllPoints()
				threat.PowerGlow:Point("TOPLEFT", frame.Power.backdrop, "TOPLEFT", -frame.SHADOW_SPACING - frame.SPACING, frame.SHADOW_SPACING + frame.SPACING)
				threat.PowerGlow:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMRIGHT", frame.SHADOW_SPACING + frame.SPACING, -frame.SHADOW_SPACING - frame.SPACING)
			else
				threat.MainGlow:Point("TOPLEFT", -frame.SHADOW_SPACING, frame.SHADOW_SPACING-(frame.USE_MINI_CLASSBAR and frame.CLASSBAR_YOFFSET or 0))

				if frame.USE_MINI_POWERBAR then
					threat.MainGlow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
					threat.MainGlow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING + (frame.POWERBAR_HEIGHT/2))
				else
					threat.MainGlow:Point("BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
					threat.MainGlow:Point("BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
				end
			end
		elseif db.threatStyle:match('^ICON') then
			threat:SetFrameStrata('LOW')
			threat:SetFrameLevel(75) --Inset power uses 50, we want it to appear above that

			local point = db.threatStyle:gsub("ICON", "")
			threat.TextureIcon:ClearAllPoints()
			threat.TextureIcon:Point(point, frame.Health, point)
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
	if not unit or parent.unit ~= unit then return end

	local db = parent.db
	if not db or (not db.threatStyle or db.threatStyle == 'NONE') then return end

	if status and status > 1 then
		if db.threatStyle == 'GLOW' then
			self.MainGlow:Show()
			self.MainGlow:SetBackdropBorderColor(r, g, b)

			if parent.USE_POWERBAR_OFFSET then
				self.PowerGlow:Show()
				self.PowerGlow:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			local classBar = parent.ClassBar and parent[parent.ClassBar]
			if classBar and classBar.backdrop then
				classBar.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.InfoPanel and parent.InfoPanel.backdrop then
				parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle == 'INFOPANELBORDER' then
			parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.TextureIcon then
			self.TextureIcon:Show()
			self.TextureIcon:SetVertexColor(r, g, b)
		end
	else
		r, g, b = unpack(E.media.unitframeBorderColor)
		if db.threatStyle == 'GLOW' then
			self.MainGlow:Hide()
			self.PowerGlow:Hide()
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			local classBar = parent.ClassBar and parent[parent.ClassBar]
			if classBar and classBar.backdrop then
				classBar.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.InfoPanel and parent.InfoPanel.backdrop then
				parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle == 'INFOPANELBORDER' then
			parent.InfoPanel.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.TextureIcon then
			self.TextureIcon:Hide()
		end
	end
end
