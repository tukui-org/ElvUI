local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Castbar(nameplate)
	local Castbar = CreateFrame('StatusBar', nil, nameplate)
	Castbar:SetFrameStrata(nameplate:GetFrameStrata())
	Castbar:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
	Castbar:SetFrameLevel(6)
	Castbar:CreateBackdrop('Transparent')
	Castbar:SetHeight(16) -- need option
	Castbar:SetPoint('TOPLEFT', nameplate, 'BOTTOMLEFT', 0, -20) -- need option
	Castbar:SetPoint('TOPRIGHT', nameplate, 'BOTTOMRIGHT', 0, -20) -- need option

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
			castbar:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b, .7)
		else
			castbar:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b, .7)
		end
	end

	function Castbar:PostCastStart(unit)
		CheckInterrupt(self, unit)
	end

	function Castbar:PostCastInterruptible(unit)
		CheckInterrupt(self, unit)
	end

	function Castbar:PostCastNotInterruptible(unit)
		CheckInterrupt(self, unit)
	end

	function Castbar:PostChannelStart(unit)
		CheckInterrupt(self, unit)
	end

	return Castbar
end

function NP:Update_Castbar(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.castbar.enable then
		nameplate:EnableElement('Castbar')
		nameplate.Castbar.timeToHold = db.castbar.timeToHold
		if db.castbar.iconPosition then
		end
	else
		nameplate:DisableElement('Castbar')
	end
end