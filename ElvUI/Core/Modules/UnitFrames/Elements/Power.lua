local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local random = random
local unpack = unpack
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType
local hooksecurefunc = hooksecurefunc
local GetUnitPowerBarInfo = GetUnitPowerBarInfo
local InCombatLockdown = InCombatLockdown
local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10

function UF:Construct_PowerBar(frame, bg, text, textPos)
	local power = CreateFrame('StatusBar', '$parent_PowerBar', frame)
	UF.statusbars[power] = true

	hooksecurefunc(power, 'SetStatusBarColor', function(_, r, g, b)
		if frame and frame.PowerPrediction and frame.PowerPrediction.mainBar then
			if UF and UF.db and UF.db.colors and UF.db.colors.powerPrediction and UF.db.colors.powerPrediction.enable then
				local color = UF.db.colors.powerPrediction.color
				frame.PowerPrediction.mainBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
			else
				frame.PowerPrediction.mainBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
			end
		end
	end)

	power.RaisedElementParent = UF:CreateRaisedElement(power, true)

	power.PostUpdate = UF.PostUpdatePower
	power.PostUpdateColor = UF.PostUpdatePowerColor
	power.GetDisplayPower = UF.GetDisplayPower

	if bg then
		power.BG = power:CreateTexture(nil, 'BORDER')
		power.BG:SetAllPoints()
		power.BG:SetTexture(E.media.blankTex)
	end

	if text then
		power.value = UF:CreateRaisedText(frame.RaisedElementParent)
		power.value:Point(textPos, frame.Health, textPos, textPos == 'LEFT' and 2 or -2, 0)
	end

	power.useAtlas = false
	power.colorDisconnected = false
	power.colorTapping = false
	power:CreateBackdrop(nil, nil, nil, nil, true)
	power.backdrop.callbackBackdropColor = UF.PowerBackdropColor

	UF:Construct_ClipFrame(frame, power)

	return power
end

function UF:Configure_Power(frame)
	local db = frame.db
	local power = frame.Power
	power.origParent = frame

	if frame.USE_POWERBAR then
		if not frame:IsElementEnabled('Power') then
			frame:EnableElement('Power')
		end

		--Show the power here so that attached texts can be displayed correctly.
		power:Show() --Since it is updated in the PostUpdatePower, so it's fine!

		E:SetSmoothing(power, UF.db.smoothbars)

		--Text
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.power.attachTextTo, true)
		power.value:ClearAllPoints()
		power.value:Point(db.power.position, attachPoint, db.power.position, db.power.xOffset, db.power.yOffset)
		frame:Tag(power.value, db.power.text_format)

		if db.power.attachTextTo == 'Power' then
			power.value:SetParent(power.RaisedElementParent)
		else
			power.value:SetParent(frame.RaisedElementParent)
		end

		if db.power.reverseFill then
			power:SetReverseFill(true)
		else
			power:SetReverseFill(false)
		end

		--Colors
		power.colorClass = nil
		power.colorReaction = nil
		power.colorPower = nil
		power.colorSelection = nil
		power.displayAltPower = db.power.displayAltPower

		if E.Retail and UF.db.colors.powerselection then
			power.colorSelection = true
		--[[elseif UF.db.colors.powerthreat then
			power.colorThreat = true]]
		elseif UF.db.colors.powerclass then
			power.colorClass = true
			power.colorReaction = true
		else
			power.colorPower = true
		end

		--Fix height in case it is lower than the theme allows
		local heightChanged = false
		if not UF.thinBorders and frame.POWERBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 7
			db.power.height = 7
			heightChanged = true
		elseif UF.thinBorders and frame.POWERBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
			frame.POWERBAR_HEIGHT = 3
			db.power.height = 3
			heightChanged = true
		end
		if heightChanged then
			--Update health size
			frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
			UF:Configure_HealthBar(frame)
		end

		--Position
		power:ClearAllPoints()
		local OFFSET = (UF.BORDER + UF.SPACING)*2

		if frame.POWERBAR_DETACHED then
			if power.Holder and power.Holder.mover then
				E:EnableMover(power.Holder.mover.name)
			else
				power.Holder = CreateFrame('Frame', nil, power)
				power.Holder:Point('BOTTOM', frame, 'BOTTOM', 0, -20)

				if frame.unitframeType then
					local key = frame.unitframeType:gsub('t(arget)','T%1'):gsub('p(layer)','P%1'):gsub('f(ocus)','F%1'):gsub('p(et)','P%1')
					E:CreateMover(power.Holder, key..'PowerBarMover', L[key.." Powerbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,'..frame.unitframeType..',power')
				end
			end

			power.Holder:Size(frame.POWERBAR_WIDTH, frame.POWERBAR_HEIGHT)
			power:Point('BOTTOMLEFT', power.Holder, 'BOTTOMLEFT', UF.BORDER+UF.SPACING, UF.BORDER+UF.SPACING)
			power:Size(frame.POWERBAR_WIDTH - OFFSET, frame.POWERBAR_HEIGHT - OFFSET)
			power:SetFrameLevel(50) --RaisedElementParent uses 100, we want lower value to allow certain icons and texts to appear above power
		elseif frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == 'LEFT' then
				power:Point('TOPRIGHT', frame.Health, 'TOPRIGHT', frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power:Point('BOTTOMLEFT', frame.Health, 'BOTTOMLEFT', frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			elseif frame.ORIENTATION == 'MIDDLE' then
				power:Point('TOPLEFT', frame, 'TOPLEFT', UF.BORDER + UF.SPACING, -frame.POWERBAR_OFFSET -frame.CLASSBAR_YOFFSET)
				power:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -UF.BORDER - UF.SPACING, UF.BORDER)
			else
				power:Point('TOPLEFT', frame.Health, 'TOPLEFT', -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
				power:Point('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT', -frame.POWERBAR_OFFSET, -frame.POWERBAR_OFFSET)
			end
			power:SetFrameLevel(frame.Health:GetFrameLevel() - 5) --Health uses 10
		elseif frame.USE_INSET_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT - OFFSET)
			power:Point('BOTTOMLEFT', frame.Health, 'BOTTOMLEFT', UF.BORDER + (UF.BORDER*2), UF.BORDER + (UF.BORDER*2))
			power:Point('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT', -(UF.BORDER + (UF.BORDER*2)), UF.BORDER + (UF.BORDER*2))
			power:SetFrameLevel(50)
		elseif frame.USE_MINI_POWERBAR then
			power:Height(frame.POWERBAR_HEIGHT - OFFSET)

			if frame.ORIENTATION == 'LEFT' then
				power:Width(frame.POWERBAR_WIDTH - UF.BORDER*2)
				power:Point('RIGHT', frame, 'BOTTOMRIGHT', -(UF.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-UF.BORDER)*0.5))
			elseif frame.ORIENTATION == 'RIGHT' then
				power:Width(frame.POWERBAR_WIDTH - UF.BORDER*2)
				power:Point('LEFT', frame, 'BOTTOMLEFT', (UF.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-UF.BORDER)*0.5))
			else
				power:Point('LEFT', frame, 'BOTTOMLEFT', (UF.BORDER*2 + 4), ((frame.POWERBAR_HEIGHT-UF.BORDER)*0.5))
				power:Point('RIGHT', frame, 'BOTTOMRIGHT', -(UF.BORDER*2 + 4 + (frame.PVPINFO_WIDTH or 0)), ((frame.POWERBAR_HEIGHT-UF.BORDER)*0.5))
			end

			power:SetFrameLevel(50)
		else
			power:Point('TOPRIGHT', frame.Health.backdrop, 'BOTTOMRIGHT', -UF.BORDER, -UF.SPACING*3)
			power:Point('TOPLEFT', frame.Health.backdrop, 'BOTTOMLEFT', UF.BORDER, -UF.SPACING*3)
			power:Height(frame.POWERBAR_HEIGHT - OFFSET)

			power:SetFrameLevel(frame.Health:GetFrameLevel() + 5) --Health uses 10
		end

		--Hide mover until we detach again
		if not frame.POWERBAR_DETACHED and power.Holder and power.Holder.mover then
			E:DisableMover(power.Holder.mover.name)
		end

		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomStrata then
			power:SetFrameStrata(db.power.strataAndLevel.frameStrata)
		else
			power:SetFrameStrata('LOW')
		end
		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomLevel then
			power:SetFrameLevel(db.power.strataAndLevel.frameLevel)
		end

		power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)

		if frame.POWERBAR_DETACHED and db.power.parent == 'UIPARENT' then
			E.FrameLocks[power] = true
			power:SetParent(E.UIParent)
		else
			E.FrameLocks[power] = nil
			power:SetParent(frame)
		end
	elseif frame:IsElementEnabled('Power') then
		frame:DisableElement('Power')
		power:Hide()
		frame:Tag(power.value, '')
	end

	frame.Power.custom_backdrop = UF.db.colors.custompowerbackdrop and UF.db.colors.power_backdrop

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.BG, nil, UF.db.colors.invertPower, db.power.reverseFill)
end

function UF:PowerBackdropColor()
	local parent = self:GetParent()
	if parent.isTransparent then
		local r, g, b = parent:GetStatusBarColor()
		UF.UpdateBackdropTextureColor(parent, r, g, b, E.media.backdropfadecolor[4])
	else
		self:SetBackdropColor(unpack(E.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
	end
end

function UF:GetDisplayPower()
	local barInfo = GetUnitPowerBarInfo(self.__owner.unit)
	if barInfo then
		return POWERTYPE_ALTERNATE, barInfo.minPower
	end
end

do
	local tokens = {[0]='MANA','RAGE','FOCUS','ENERGY','RUNIC_POWER'}
	local function GetRandomPowerColor()
		local color = ElvUF.colors.power[tokens[random(0,4)]]
		return color[1], color[2], color[3]
	end

	function UF:PostUpdatePowerColor()
		local parent = self.origParent or self:GetParent()
		if parent.isForced and not self.colorClass then
			self:SetStatusBarColor(GetRandomPowerColor())
		end
	end
end

do
	local powerTypesFull = {MANA = true, FOCUS = true, ENERGY = true}
	local individualUnits = {player = true, target = true, targettarget = true, targettargettarget = true, focus = true, focustarget = true, pet = true, pettarget = true}
	function UF:PostUpdatePower(unit, cur, min, max)
		local parent = self.origParent or self:GetParent()
		if parent.isForced then
			self.cur = random(1, 100)
			self.max = 100
			self:SetMinMaxValues(0, self.max)
			self:SetValue(self.cur)
		end

		local db = parent.db and parent.db.power
		if not db then return end

		if individualUnits[unit] and db.autoHide and parent.POWERBAR_DETACHED then
			local _, powerType = UnitPowerType(unit)
			if (powerTypesFull[powerType] and cur == max) or cur == min or (db.notInCombat and not InCombatLockdown()) then
				self:Hide()
			else
				self:Show()
			end
		elseif not self:IsShown() then
			self:Show()
		end

		if db.hideonnpc then
			UF:PostNamePosition(parent, unit)
		end
	end
end
