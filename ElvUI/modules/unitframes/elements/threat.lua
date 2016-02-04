local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Threat(frame, glow)
	local threat = CreateFrame("Frame", nil, frame)

	frame:CreateShadow('Default')
	threat.glow = frame.shadow
	threat.glow:SetParent(frame)
	threat.glow:Hide()
	frame.shadow = nil

	threat.texIcon = threat:CreateTexture(nil, 'OVERLAY')
	threat.texIcon:Size(8)
	threat.texIcon:SetTexture(E['media'].blankTex)
	threat.texIcon:Hide()

	threat.PostUpdate = self.UpdateThreat
	return threat
end

function UF:Configure_Threat(frame)
	local threat = frame.Threat
	local db = frame.db

	if db.threatStyle ~= 'NONE' and db.threatStyle ~= nil then
		if not frame:IsElementEnabled('Threat') then
			frame:EnableElement('Threat')
		end

		if db.threatStyle == "GLOW" then
			threat:SetFrameStrata('BACKGROUND')
			threat.glow:SetFrameStrata('BACKGROUND')
			threat.glow:ClearAllPoints()
			if frame.USE_POWERBAR_OFFSET then
				if frame.ORIENTATION == "LEFT" then
					threat.glow:Point("TOPLEFT", -frame.SHADOW_SPACING, frame.SHADOW_SPACING-(frame.USE_MINI_CLASSBAR and frame.CLASSBAR_YOFFSET or 0))
					threat.glow:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
				elseif frame.ORIENTATION == "RIGHT" then
					threat.glow:Point("TOPRIGHT", frame.SHADOW_SPACING, frame.SHADOW_SPACING-(frame.USE_MINI_CLASSBAR and frame.CLASSBAR_YOFFSET or 0))
					threat.glow:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
				else
					threat.glow:Point("TOPRIGHT", frame.Health.backdrop, "TOPRIGHT", frame.SHADOW_SPACING, frame.SHADOW_SPACING)
					threat.glow:Point("BOTTOMLEFT", frame.Health.backdrop, "BOTTOMLEFT", -frame.SHADOW_SPACING, -frame.SHADOW_SPACING)
				end
			else
				threat.glow:SetBackdropBorderColor(0, 0, 0, 0)
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
			threat:SetFrameStrata('HIGH')
			local point = db.threatStyle
			point = point:gsub("ICON", "")

			threat.texIcon:ClearAllPoints()
			threat.texIcon:Point(point, frame.Health, point)
		end
	elseif frame:IsElementEnabled('Threat') then
		frame:DisableElement('Threat')
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
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.ClassBar and parent.ClassBar.backdrop then
				parent.ClassBar.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Show()
			self.texIcon:SetVertexColor(r, g, b)
		end
	else
		r, g, b = unpack(E.media.bordercolor)
		if db.threatStyle == 'GLOW' then
			self.glow:Hide()
		elseif db.threatStyle == 'BORDERS' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)

			if parent.Power and parent.Power.backdrop then
				parent.Power.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if parent.ClassBar and parent.ClassBar.backdrop then
				parent.ClassBar.backdrop:SetBackdropBorderColor(r, g, b)
			end
		elseif db.threatStyle == 'HEALTHBORDER' then
			parent.Health.backdrop:SetBackdropBorderColor(r, g, b)
		elseif db.threatStyle ~= 'NONE' and self.texIcon then
			self.texIcon:Hide()
		end
	end
end