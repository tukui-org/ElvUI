local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_Castbar(frame)
	local Castbar = CreateFrame('StatusBar', nil, frame)
	Castbar:SetFrameStrata(frame:GetFrameStrata())
	Castbar:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
	Castbar:SetFrameLevel(6)
	Castbar:CreateBackdrop('Transparent')
	Castbar:SetHeight(16) -- need option
	Castbar:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 0, -20) -- need option
	Castbar:SetPoint('TOPRIGHT', frame, 'BOTTOMRIGHT', 0, -20) -- need option

	Castbar.Button = CreateFrame('Frame', nil, Castbar)
	Castbar.Button:SetSize(18, 18) -- need option
	Castbar.Button:SetTemplate()
	Castbar.Button:SetPoint('RIGHT', Castbar, 'LEFT', -6, 0) -- need option

	Castbar.Icon = Castbar.Button:CreateTexture(nil, 'ARTWORK')
	Castbar.Icon:SetInside()
	Castbar.Icon:SetTexCoord(unpack(E.TexCoords))

	Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Time:SetFont(E.LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	Castbar.Time:SetPoint('RIGHT', Castbar, 'RIGHT', -4, 0)
	Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	Castbar.Time:SetJustifyH('RIGHT')

	Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Text:SetFont(E.LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	Castbar.Text:SetPoint('LEFT', Castbar, 'LEFT', 4, 0) -- need option
	Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	Castbar.Text:SetJustifyH('LEFT')
	Castbar.Text:SetSize(75, 16) -- need option

	local function CheckInterrupt(castbar, unit)
		if (unit == 'vehicle') then
			unit = 'player'
		end

		if (castbar.notInterruptible and UnitCanAttack('player', unit)) then
			castbar:SetStatusBarColor(0.87, 0.37, 0.37, 0.7)
		else
			castbar:SetStatusBarColor(0.29, 0.67, 0.30, 0.7)
		end
	end

	Castbar.PostCastStart = CheckInterrupt
	Castbar.PostCastInterruptible = CheckInterrupt
	Castbar.PostCastNotInterruptible = CheckInterrupt
	Castbar.PostChannelStart = CheckInterrupt

	return Castbar
end