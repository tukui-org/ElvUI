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