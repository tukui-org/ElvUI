local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

function CreateBackdrop(frame)
	local pixel = E:Scale(1)
	local parent = frame
	if E.PixelMode then
		frame.bordertop = parent:CreateTexture(nil, "BORDER")
		frame.bordertop:SetPoint("TOPLEFT", frame, "TOPLEFT", -pixel, pixel)
		frame.bordertop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", pixel, pixel)
		frame.bordertop:SetHeight(pixel)
		frame.bordertop:SetTexture(unpack(E["media"].bordercolor))
		frame.bordertop:SetDrawLayer("BORDER", 1)

		frame.borderbottom = parent:CreateTexture(nil, "BORDER")
		frame.borderbottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -pixel, -pixel)
		frame.borderbottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", pixel, -pixel)
		frame.borderbottom:SetHeight(pixel)
		frame.borderbottom:SetTexture(unpack(E["media"].bordercolor))
		frame.borderbottom:SetDrawLayer("BORDER", 1)

		frame.borderleft = parent:CreateTexture(nil, "BORDER")
		frame.borderleft:SetPoint("TOPLEFT", frame, "TOPLEFT", -pixel, pixel)
		frame.borderleft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", pixel, -pixel)
		frame.borderleft:SetWidth(pixel)
		frame.borderleft:SetTexture(unpack(E["media"].bordercolor))
		frame.borderleft:SetDrawLayer("BORDER", 1)

		frame.borderright = parent:CreateTexture(nil, "BORDER")
		frame.borderright:SetPoint("TOPRIGHT", frame, "TOPRIGHT", pixel, pixel)
		frame.borderright:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -pixel, -pixel)
		frame.borderright:SetWidth(pixel)
		frame.borderright:SetTexture(unpack(E["media"].bordercolor))
		frame.borderright:SetDrawLayer("BORDER", 1)
	else
		frame.bordertop = parent:CreateTexture(nil, "ARTWORK")
		frame.bordertop:SetPoint("TOPLEFT", frame, "TOPLEFT", -pixel*2, pixel*2)
		frame.bordertop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", pixel*2, pixel*2)
		frame.bordertop:SetHeight(pixel)
		frame.bordertop:SetTexture(unpack(E.media.bordercolor))
		frame.bordertop:SetDrawLayer("ARTWORK", -6)

		frame.bordertop.backdrop = parent:CreateTexture(nil, "ARTWORK")
		frame.bordertop.backdrop:SetPoint("TOPLEFT", frame.bordertop, "TOPLEFT", -pixel, pixel)
		frame.bordertop.backdrop:SetPoint("TOPRIGHT", frame.bordertop, "TOPRIGHT", pixel, pixel)
		frame.bordertop.backdrop:SetHeight(pixel * 3)
		frame.bordertop.backdrop:SetTexture(0, 0, 0)
		frame.bordertop.backdrop:SetDrawLayer("ARTWORK", -7)

		frame.borderbottom = parent:CreateTexture(nil, "ARTWORK")
		frame.borderbottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -pixel*2, -pixel*2)
		frame.borderbottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", pixel*2, -pixel*2)
		frame.borderbottom:SetHeight(pixel)
		frame.borderbottom:SetTexture(unpack(E.media.bordercolor))
		frame.borderbottom:SetDrawLayer("ARTWORK", -6)

		frame.borderbottom.backdrop = parent:CreateTexture(nil, "ARTWORK")
		frame.borderbottom.backdrop:SetPoint("BOTTOMLEFT", frame.borderbottom, "BOTTOMLEFT", -pixel, -pixel)
		frame.borderbottom.backdrop:SetPoint("BOTTOMRIGHT", frame.borderbottom, "BOTTOMRIGHT", pixel, -pixel)
		frame.borderbottom.backdrop:SetHeight(pixel * 3)
		frame.borderbottom.backdrop:SetTexture(0, 0, 0)
		frame.borderbottom.backdrop:SetDrawLayer("ARTWORK", -7)

		frame.borderleft = parent:CreateTexture(nil, "ARTWORK")
		frame.borderleft:SetPoint("TOPLEFT", frame, "TOPLEFT", -pixel*2, pixel*2)
		frame.borderleft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", pixel*2, -pixel*2)
		frame.borderleft:SetWidth(pixel)
		frame.borderleft:SetTexture(unpack(E.media.bordercolor))
		frame.borderleft:SetDrawLayer("ARTWORK", -6)

		frame.borderleft.backdrop = parent:CreateTexture(nil, "ARTWORK")
		frame.borderleft.backdrop:SetPoint("TOPLEFT", frame.borderleft, "TOPLEFT", -pixel, pixel)
		frame.borderleft.backdrop:SetPoint("BOTTOMLEFT", frame.borderleft, "BOTTOMLEFT", -pixel, -pixel)
		frame.borderleft.backdrop:SetWidth(pixel * 3)
		frame.borderleft.backdrop:SetTexture(0, 0, 0)
		frame.borderleft.backdrop:SetDrawLayer("ARTWORK", -7)

		frame.borderright = parent:CreateTexture(nil, "ARTWORK")
		frame.borderright:SetPoint("TOPRIGHT", frame, "TOPRIGHT", pixel*2, pixel*2)
		frame.borderright:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -pixel*2, -pixel*2)
		frame.borderright:SetWidth(pixel)
		frame.borderright:SetTexture(unpack(E.media.bordercolor))
		frame.borderright:SetDrawLayer("ARTWORK", -6)

		frame.borderright.backdrop = parent:CreateTexture(nil, "ARTWORK")
		frame.borderright.backdrop:SetPoint("TOPRIGHT", frame.borderright, "TOPRIGHT", pixel, pixel)
		frame.borderright.backdrop:SetPoint("BOTTOMRIGHT", frame.borderright, "BOTTOMRIGHT", pixel, -pixel)
		frame.borderright.backdrop:SetWidth(pixel * 3)
		frame.borderright.backdrop:SetTexture(0, 0, 0)
		frame.borderright.backdrop:SetDrawLayer("ARTWORK", -7)
	end
end


function UF:Construct_HealthBar(frame, bg, text, textPos)
	local health = CreateFrame('StatusBar', nil, frame)
	UF['statusbars'][health] = true

	health:SetFrameStrata("LOW")
	health.PostUpdate = self.PostUpdateHealth

	if bg then
		local parent = health
		if(frame.Portrait and frame.Portrait.overlay) then
			parent = frame.Portrait.overlay
		end
		health.bgFrame = CreateFrame("StatusBar", nil, parent)
		health.bgFrame:SetAllPoints(health)
		health.bgFrame:SetStatusBarTexture(E["media"].blankTex)
		health.bgFrame.multiplier = 0.25
		health.bgFrame:SetReverseFill(true)
		health.bgFrame:SetFrameLevel(health:GetFrameLevel() + 3)
		CreateBackdrop(health.bgFrame)
	end

	if text then
		health.value = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
		UF:Configure_FontString(health.value)
		health.value:SetParent(frame)

		local x = -2
		if textPos == 'LEFT' then
			x = 2
		end

		health.value:Point(textPos, health, textPos, x, 0)
	end

	health.colorTapping = true
	health.colorDisconnected = true
	health.backdrop = CreateFrame("Frame", nil, health)
	health.backdrop:SetOutside(health)

	return health
end

function UF:PostUpdateHealth(unit, min, max)
	self.bgFrame:SetMinMaxValues(self:GetMinMaxValues())
	self.bgFrame:SetValue(max-min)

	local r,g,b = self:GetStatusBarColor()
	local mu = self.bgFrame.multiplier

	local parent = self:GetParent()
	if parent.isForced then
		min = random(1, max)
		self:SetValue(min)
	end

	if parent.ResurrectIcon then
		parent.ResurrectIcon:SetAlpha(min == 0 and 1 or 0)
	end

	local r, g, b = self:GetStatusBarColor()
	local colors = E.db['unitframe']['colors'];
	if (colors.healthclass == true and colors.colorhealthbyvalue == true) or (colors.colorhealthbyvalue and parent.isForced) and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		r,g,b = ElvUF.ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

		self:SetStatusBarColor(r, g, b)
	end

	if colors.classbackdrop then
		local reaction = UnitReaction(unit, 'player')
		local t
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			t = parent.colors.class[class]
		elseif reaction then
			t = parent.colors.reaction[reaction]
		end

		if t then
			r,g,b = t[1], t[2], t[3]
		end
	end

	if colors.useDeadBackdrop and UnitIsDeadOrGhost(unit) then
		local backdrop = colors.health_backdrop_dead
		self.bgFrame:SetStatusBarColor(backdrop.r, backdrop.g, backdrop.b)
	elseif colors.customhealthbackdrop then
		local backdrop = colors.health_backdrop
		self.bgFrame:SetStatusBarColor(backdrop.r, backdrop.g, backdrop.b)
	else
		self.bgFrame:SetStatusBarColor(r * mu, g * mu, b * mu)
	end

	if(UF.db.colors.transparentHealth) then
		r, g, b = self:GetStatusBarColor()
		self:SetStatusBarColor(r, g, b, 0.58)
	end
end

