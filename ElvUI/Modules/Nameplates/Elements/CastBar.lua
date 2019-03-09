local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local unpack = unpack
local CreateFrame = CreateFrame
local UnitCanAttack = UnitCanAttack

function NP:Construct_Castbar(nameplate)
	local Castbar = CreateFrame('StatusBar', nameplate:GetDebugName()..'Castbar', nameplate)
	Castbar:SetFrameStrata(nameplate:GetFrameStrata())
	Castbar:SetFrameLevel(5)
	Castbar:CreateBackdrop('Transparent')
	Castbar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))

	local statusBarTexture = Castbar:GetStatusBarTexture()
	statusBarTexture:SetSnapToPixelGrid(false)
	statusBarTexture:SetTexelSnappingBias(0)

	NP.StatusBars[Castbar] = true

	Castbar.Button = CreateFrame('Frame', nil, Castbar)
	Castbar.Button:SetTemplate()

	Castbar.Icon = Castbar.Button:CreateTexture(nil, 'ARTWORK')
	Castbar.Icon:SetInside()
	Castbar.Icon:SetTexCoord(unpack(E.TexCoords))
	Castbar.Icon:SetSnapToPixelGrid(false)
	Castbar.Icon:SetTexelSnappingBias(0)

	Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Time:Point('RIGHT', Castbar, 'RIGHT', -4, 0)
	Castbar.Time:SetJustifyH('RIGHT')

	Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
	Castbar.Text:SetJustifyH('LEFT')

	function Castbar:CheckInterrupt(unit)
		if (unit == 'vehicle') then
			unit = 'player'
		end

		if (self.notInterruptible and UnitCanAttack('player', unit)) then
			self:SetStatusBarColor(NP.db.colors.castNoInterruptColor.r, NP.db.colors.castNoInterruptColor.g, NP.db.colors.castNoInterruptColor.b, .7)

			if self.Icon then
				self.Icon:SetDesaturated(true)
			end
		else
			self:SetStatusBarColor(NP.db.colors.castColor.r, NP.db.colors.castColor.g, NP.db.colors.castColor.b, .7)

			if self.Icon then
				self.Icon:SetDesaturated(false)
			end
		end
	end

	function Castbar:CustomDelayText()
		if self.casting then
			if self.castTimeFormat == "CURRENT" then
				self.Time:SetFormattedText("%.1f", self.duration)
			elseif self.castTimeFormat == "CURRENT_MAX" then
				self.Time:SetFormattedText("%.1f / %.1f", self.duration, self.max)
			else --REMAINING
				self.Time:SetFormattedText("%.1f", (self.max - self.duration))
			end
		else
			if self.channelTimeFormat == "CURRENT" then
				self.Time:SetFormattedText("%.1f", (self.max - self.duration))
			elseif self.channelTimeFormat == "CURRENT_MAX" then
				self.Time:SetFormattedText("%.1f / %.1f", (self.max - self.duration), self.max)
			else --REMAINING
				self.Time:SetFormattedText("%.1f", self.duration)
			end
		end
	end

	function Castbar:CustomTimeText()
		if self.casting then
			if self.castTimeFormat == "CURRENT" then
				self.Time:SetFormattedText("%.1f", self.duration)
			elseif self.castTimeFormat == "CURRENT_MAX" then
				self.Time:SetFormattedText("%.1f / %.1f", self.duration, self.max)
			else --REMAINING
				self.Time:SetFormattedText("%.1f", (self.max - self.duration))
			end
		else
			if self.channelTimeFormat == "CURRENT" then
				self.Time:SetFormattedText("%.1f", (self.max - self.duration))
			elseif self.channelTimeFormat == "CURRENT_MAX" then
				self.Time:SetFormattedText("%.1f / %.1f", (self.max - self.duration), self.max)
			else --REMAINING
				self.Time:SetFormattedText("%.1f", self.duration)
			end
		end
	end

	function Castbar:PostCastStart(unit)
		self:CheckInterrupt(unit)
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostCastFail()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	function Castbar:PostCastInterruptible(unit)
		self:CheckInterrupt(unit)
	end

	function Castbar:PostCastStop()
		NP:StyleFilterUpdate(nameplate, 'FAKE_Casting')
	end

	return Castbar
end

function NP:COMBAT_LOG_EVENT_UNFILTERED()
	local _, event, _, sourceGUID, sourceName, _, _, targetGUID = CombatLogGetCurrentEventInfo()

	if (event == "SPELL_INTERRUPT") and targetGUID and (sourceName and sourceName ~= "") then
		local plate = C_NamePlate.GetNamePlateForUnit('target')
		if plate and (plate.unitFrame and plate.unitFrame.Castbar) then
			local db = plate.unitFrame.frameType and self.db and self.db.units and self.db.units[plate.unitFrame.frameType]
			local healthBar = (db and db.health and db.health.enable) or (plate.unitFrame.isTarget and self.db.alwaysShowTargetHealth)
			if healthBar and (db and db.castbar and db.castbar.enable) and db.castbar.sourceInterrupt then
				local holdTime = db.castbar.timeToHold
				if holdTime > 0 then
					if db.castbar.sourceInterruptClassColor then
						local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
						if sourceClass then
							local classColor = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[sourceClass]) or RAID_CLASS_COLORS[sourceClass];
							sourceClass = classColor and classColor.colorStr
						end

						plate.unitFrame.Castbar.Text:SetText(INTERRUPTED.." > "..(sourceClass and strjoin('', '|c', sourceClass, sourceName)) or sourceName)
					else
						plate.unitFrame.Castbar.Text:SetText(INTERRUPTED.." > "..sourceName)
					end
				end
			end
		end
	end
end

function NP:Update_Castbar(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.castbar.enable then
		if not nameplate:IsElementEnabled('Castbar') then
			nameplate:EnableElement('Castbar')
		end

		nameplate.Castbar.timeToHold = db.castbar.timeToHold
		nameplate.Castbar:Size(db.castbar.width, db.castbar.height)
		nameplate.Castbar:Point('CENTER', nameplate, 'CENTER', 0, db.castbar.yOffset)

		if db.castbar.showIcon then
			nameplate.Castbar.Button:ClearAllPoints()
			nameplate.Castbar.Button:Point(db.castbar.iconPosition == 'RIGHT' and 'BOTTOMLEFT' or 'BOTTOMRIGHT', nameplate.Castbar, db.castbar.iconPosition == 'RIGHT' and 'BOTTOMRIGHT' or 'BOTTOMLEFT', db.castbar.iconOffsetX, db.castbar.iconOffsetY)
			nameplate.Castbar.Button:Size(db.castbar.iconSize, db.castbar.iconSize)
			nameplate.Castbar.Button:Show()
		else
			nameplate.Castbar.Button:Hide()
		end

		nameplate.Castbar.Time:ClearAllPoints()
		nameplate.Castbar.Text:ClearAllPoints()

		if db.castbar.textPosition == "BELOW" then
			nameplate.Castbar.Time:Point('TOPRIGHT', nameplate.Castbar, 'BOTTOMRIGHT')
			nameplate.Castbar.Text:Point('TOPLEFT', nameplate.Castbar, 'BOTTOMLEFT')
		elseif db.castbar.textPosition == "ABOVE" then
			nameplate.Castbar.Time:Point('BOTTOMRIGHT', nameplate.Castbar, 'TOPRIGHT')
			nameplate.Castbar.Text:Point('BOTTOMLEFT', nameplate.Castbar, 'TOPLEFT')
		else
			nameplate.Castbar.Time:Point('RIGHT', nameplate.Castbar, 'RIGHT', -4, 0)
			nameplate.Castbar.Text:Point('LEFT', nameplate.Castbar, 'LEFT', 4, 0)
		end

		if db.castbar.hideTime then
			nameplate.Castbar.Time:Hide()
		else
			nameplate.Castbar.Time:SetFont(E.LSM:Fetch('font', db.castbar.font), db.castbar.fontSize, db.castbar.fontOutline)
			nameplate.Castbar.Time:Show()
		end

		if db.castbar.hideSpellName then
			nameplate.Castbar.Text:Hide()
		else
			nameplate.Castbar.Text:SetFont(E.LSM:Fetch('font', db.castbar.font), db.castbar.fontSize, db.castbar.fontOutline)
			nameplate.Castbar.Text:Show()
		end
	else
		if nameplate:IsElementEnabled('Castbar') then
			nameplate:DisableElement('Castbar')
		end
	end
end
