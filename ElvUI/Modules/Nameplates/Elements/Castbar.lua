local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Castbar(nameplate)
	local Castbar = CreateFrame('StatusBar', nameplate:GetDebugName()..'Castbar', nameplate)
	Castbar:SetFrameStrata(nameplate:GetFrameStrata())
	Castbar:SetFrameLevel(5)
	Castbar:CreateBackdrop('Transparent')
	Castbar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[Castbar] = true

	Castbar.Button = CreateFrame('Frame', nil, Castbar)
	Castbar.Button:SetTemplate()

	Castbar.Icon = Castbar.Button:CreateTexture(nil, 'ARTWORK')
	Castbar.Icon:SetInside()
	Castbar.Icon:SetTexCoord(unpack(E.TexCoords))

	Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Time:SetPoint('RIGHT', Castbar, 'RIGHT', -4, 0)
	Castbar.Time:SetJustifyH('RIGHT')
	Castbar.Time:SetFont(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Text:SetJustifyH('LEFT')
	Castbar.Text:SetFont(E.LSM:Fetch('font', NP.db.font), NP.db.fontSize, NP.db.fontOutline)

	function Castbar:CheckInterrupt(unit)
		if (unit == 'vehicle') then
			unit = 'player'
		end

		if (self.notInterruptible and UnitCanAttack('player', unit)) then
			self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b, .7)
		else
			self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b, .7)
		end
	end

	function Castbar:PostCastStart(unit)
		self:CheckInterrupt(unit)
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostCastFailed()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostCastInterrupted()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostCastInterruptible(unit)
		self:CheckInterrupt(unit)
	end

	function Castbar:PostCastNotInterruptible(unit)
		self:CheckInterrupt(unit)
	end

	function Castbar:PostCastStop()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostChannelStart(unit)
		self:CheckInterrupt(unit)
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostChannelStop()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	return Castbar
end

function NP:Update_Castbar(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.castbar.enable then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		nameplate.Castbar.timeToHold = db.castbar.timeToHold
		nameplate.Castbar:SetSize(db.castbar.width, db.castbar.height)
		nameplate.Castbar:SetPoint('CENTER', nameplate, 'CENTER', 0, db.castbar.yOffset)

		if db.castbar.showIcon then
			nameplate.Castbar.Button:ClearAllPoints()
			nameplate.Castbar.Button:SetPoint(db.castbar.iconPosition == 'RIGHT' and 'BOTTOMLEFT' or 'BOTTOMRIGHT', nameplate.Castbar, db.castbar.iconPosition == 'RIGHT' and 'BOTTOMRIGHT' or 'BOTTOMLEFT', db.castbar.iconOffsetX, db.castbar.iconOffsetY)
			nameplate.Castbar.Button:SetSize(db.castbar.iconSize, db.castbar.iconSize)
			nameplate.Castbar.Button:Show()
		else
			nameplate.Castbar.Button:Hide()
		end

		nameplate.Castbar.Time:SetPoint('RIGHT', nameplate.Castbar, 'RIGHT', -4, 0)

		nameplate.Castbar.Text:SetPoint('LEFT', nameplate.Castbar, 'LEFT', 4, 0) -- need option
	else
		if nameplate:IsElementEnabled('Castbar') then
			nameplate:DisableElement('Castbar')
		end
	end
end
