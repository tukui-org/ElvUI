local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local random = random
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType
local InCombatLockdown = InCombatLockdown
local GetUnitPowerBarInfo = GetUnitPowerBarInfo

local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10

function UF:PowerBar_PostVisibility(power, frame)
	if not frame then frame = power.origParent or power:GetParent() end

	local db = frame and frame.db and frame.db.power
	if not db then return end

	local wasShown = frame.POWERBAR_SHOWN
	frame.POWERBAR_SHOWN = power:IsShown()

	if frame.POWERBAR_SHOWN ~= wasShown then
		UF:Configure_Power(frame, true)
		UF:Configure_InfoPanel(frame)

		if frame.HealthPrediction then
			UF:SetSize_HealComm(frame)
		end
	end
end

function UF:PowerBar_SetStatusBarColor(r, g, b)
	local frame = self.origParent or self:GetParent()
	if frame and frame.PowerPrediction and frame.PowerPrediction.mainBar then
		if UF and UF.db and UF.db.colors and UF.db.colors.powerPrediction and UF.db.colors.powerPrediction.enable then
			local color = UF.db.colors.powerPrediction.color
			frame.PowerPrediction.mainBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
		else
			frame.PowerPrediction.mainBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
		end
	end
end

function UF:PowerBar_CreateHolder(frame, power)
	local holder = CreateFrame('Frame', nil, power)
	holder:Point('BOTTOM', frame, 'BOTTOM', 0, -20)

	if frame.unitframeType then
		local key = frame.unitframeType:gsub('t(arget)','T%1'):gsub('p(layer)','P%1'):gsub('f(ocus)','F%1'):gsub('p(et)','P%1')
		E:CreateMover(holder, key..'PowerBarMover', L[key.." Powerbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,'..frame.unitframeType..',power')
	end

	return holder
end

function UF:PowerBar_EnableHolder(frame, power, detached)
	if not detached then return end -- dont enable it

	if power.Holder and power.Holder.mover then
		E:EnableMover(power.Holder.mover.name)
	else
		power.Holder = UF:PowerBar_CreateHolder(frame, power)
	end
end

function UF:PowerBar_DisableHolder(frame, power, detached)
	if detached then return end -- dont disable it

	if power.Holder and power.Holder.mover then
		E:DisableMover(power.Holder.mover.name)
	end
end

function UF:Construct_PowerBar(frame, bg, text, textPos)
	local power = CreateFrame('StatusBar', '$parent_PowerBar', frame)
	frame.POWERBAR_SHOWN = true -- we need this for autoHide
	UF.statusbars[power] = true

	power.PostUpdate = UF.PostUpdatePower
	power.PostUpdateColor = UF.PostUpdatePowerColor
	power.GetDisplayPower = UF.GetDisplayPower

	power.RaisedElementParent = UF:CreateRaisedElement(power)

	hooksecurefunc(power, 'SetStatusBarColor', UF.PowerBar_SetStatusBarColor)

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

function UF:Configure_Power(frame, healthUpdate)
	local db = frame.db
	local power = frame.Power
	power.origParent = frame

	if frame.USE_POWERBAR then
		if not frame:IsElementEnabled('Power') then
			frame:EnableElement('Power')
		end

		E:SetSmoothing(power, db.power.smoothbars)

		--Text
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.power.attachTextTo or 'Health', true)
		power.value:ClearAllPoints()
		power.value:Point(db.power.position or 'LEFT', attachPoint, db.power.position or 'LEFT', db.power.xOffset or 2, db.power.yOffset or 0)
		frame:Tag(power.value, db.power.text_format or '')

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

		if heightChanged or healthUpdate then
			--Update health size
			frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
			UF:Configure_HealthBar(frame, true)
		end

		--Position
		power:ClearAllPoints()

		local POWERBAR_WIDTH = frame.POWERBAR_WIDTH or 0
		local POWERBAR_HEIGHT = frame.POWERBAR_HEIGHT or 0
		local POWERBAR_OFFSET = frame.POWERBAR_OFFSET or 0

		local BORDER_SPACING = UF.BORDER + UF.SPACING
		local DOUBLE_BORDER = UF.BORDER * 2
		local DOUBLE_SPACING = BORDER_SPACING * 2

		-- Create and Enable the holder when detached
		UF:PowerBar_EnableHolder(frame, power, frame.POWERBAR_DETACHED)

		if frame.POWERBAR_DETACHED then
			power.Holder:Size(POWERBAR_WIDTH, POWERBAR_HEIGHT)
			power:Point('BOTTOMLEFT', power.Holder, 'BOTTOMLEFT', BORDER_SPACING, BORDER_SPACING)
			power:Size(POWERBAR_WIDTH - DOUBLE_SPACING, POWERBAR_HEIGHT - DOUBLE_SPACING)
			power:SetFrameLevel(50) --RaisedElementParent uses 100, we want lower value to allow certain icons and texts to appear above power
		elseif frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == 'LEFT' then
				power:Point('TOPRIGHT', frame.Health, 'TOPRIGHT', POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point('BOTTOMLEFT', frame.Health, 'BOTTOMLEFT', POWERBAR_OFFSET, -POWERBAR_OFFSET)
			elseif frame.ORIENTATION == 'MIDDLE' then
				power:Point('TOPLEFT', frame, 'TOPLEFT', BORDER_SPACING, -POWERBAR_OFFSET -frame.CLASSBAR_YOFFSET)
				power:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -UF.BORDER - UF.SPACING, UF.BORDER)
			else
				power:Point('TOPLEFT', frame.Health, 'TOPLEFT', -POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT', -POWERBAR_OFFSET, -POWERBAR_OFFSET)
			end
			power:OffsetFrameLevel(-5, frame.Health) --Health uses 10
		elseif frame.USE_INSET_POWERBAR then
			power:Height(POWERBAR_HEIGHT - DOUBLE_SPACING)
			power:Point('BOTTOMLEFT', frame.Health, 'BOTTOMLEFT', UF.BORDER + DOUBLE_BORDER, UF.BORDER + DOUBLE_BORDER)
			power:Point('BOTTOMRIGHT', frame.Health, 'BOTTOMRIGHT', -(UF.BORDER + DOUBLE_BORDER), UF.BORDER + DOUBLE_BORDER)
			power:SetFrameLevel(50)
		elseif frame.USE_MINI_POWERBAR then
			power:Height(POWERBAR_HEIGHT - DOUBLE_SPACING)

			local POWERHEIGHT_OFFSET = (POWERBAR_HEIGHT - UF.BORDER) * 0.5
			local DOUBLE_FOUR = DOUBLE_BORDER + 4

			if frame.ORIENTATION == 'LEFT' then
				power:Width(POWERBAR_WIDTH - DOUBLE_BORDER)
				power:Point('RIGHT', frame, 'BOTTOMRIGHT', -DOUBLE_FOUR, POWERHEIGHT_OFFSET)
			elseif frame.ORIENTATION == 'RIGHT' then
				power:Width(POWERBAR_WIDTH - DOUBLE_BORDER)
				power:Point('LEFT', frame, 'BOTTOMLEFT', DOUBLE_FOUR, POWERHEIGHT_OFFSET)
			else
				power:Point('LEFT', frame, 'BOTTOMLEFT', DOUBLE_FOUR, POWERHEIGHT_OFFSET)
				power:Point('RIGHT', frame, 'BOTTOMRIGHT', -(DOUBLE_FOUR + (frame.PVPINFO_WIDTH or 0)), POWERHEIGHT_OFFSET)
			end

			power:SetFrameLevel(50)
		else
			power:Point('TOPRIGHT', frame.Health.backdrop, 'BOTTOMRIGHT', -UF.BORDER, -UF.SPACING*3)
			power:Point('TOPLEFT', frame.Health.backdrop, 'BOTTOMLEFT', UF.BORDER, -UF.SPACING*3)
			power:Height(POWERBAR_HEIGHT - DOUBLE_SPACING)

			power:OffsetFrameLevel(5, frame.Health) --Health uses 10
		end

		-- Hide holder until we detach again
		UF:PowerBar_DisableHolder(frame, power, frame.POWERBAR_DETACHED)

		power:SetFrameStrata(db.power.strataAndLevel and db.power.strataAndLevel.useCustomStrata and db.strataAndLevel.frameStrata or 'LOW')

		if db.power.strataAndLevel and db.power.strataAndLevel.useCustomLevel then
			power:SetFrameLevel(db.power.strataAndLevel.frameLevel)
		end

		power.backdrop:OffsetFrameLevel(-1, power)

		if frame.POWERBAR_DETACHED and db.power.parent == 'UIPARENT' then
			E.FrameLocks[power] = true
			power:SetParent(E.UIParent)
		else
			E.FrameLocks[power] = nil
			power:SetParent(frame)
		end
	elseif frame:IsElementEnabled('Power') then
		frame:DisableElement('Power')
		frame:Tag(power.value, '')
	end

	frame.Power.custom_backdrop = UF.db.colors.custompowerbackdrop and UF.db.colors.power_backdrop

	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.BG, nil, UF.db.colors.invertPower, db.power.reverseFill)
end

function UF:PowerBackdropColor()
	local parent = self:GetParent()
	if parent.isTransparent then
		local r, g, b = parent:GetStatusBarColor()
		UF.UpdateBackdropTextureColor(parent, r or 0, g or 0, b or 0, E.media.backdropfadecolor[4])
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
	local classPowers = { [0] = 'MANA', 'RAGE', 'FOCUS', 'ENERGY' }

	if E.Mists then -- also handled in ConfigEnviroment
		classPowers[4] = 'RUNIC_POWER'
	elseif E.Retail then
		classPowers[4] = 'RUNIC_POWER'
		classPowers[5] = 'PAIN'
		classPowers[6] = 'FURY'
		classPowers[7] = 'LUNAR_POWER'
		classPowers[8] = 'INSANITY'
		classPowers[9] = 'MAELSTROM'
	end

	local function GetRandomPowerColor()
		local color = ElvUF.colors.power[classPowers[random(0, #classPowers)]]
		return color.r, color.g, color.b
	end

	function UF:PostUpdatePowerColor()
		local parent = self.origParent or self:GetParent()
		if parent.isForced and not self.colorClass then
			local r, g, b = GetRandomPowerColor()
			self:SetStatusBarColor(r, g, b)
		end
	end
end

do
	local ignorePets = { raidpet = true, pet = true }
	local powerTypesFull = { MANA = true, FOCUS = true, ENERGY = true }
	function UF:PostUpdatePower(unit, cur, min, max)
		local parent = self.origParent or self:GetParent()
		if parent.isForced then
			cur = random(1, 100)
			max = 100
			min = 0

			self.cur = cur
			self.max = max
			self.min = min

			self:SetMinMaxValues(min, max)
			self:SetValue(cur)
		end

		local db = parent.db and parent.db.power
		if not db then return end

		if db.hideonnpc then
			UF:PostNamePosition(parent, unit)
		end

		local pastVisibility = parent.powerVisibility
		local visibility = db.autoHide or db.notInCombat or (db.onlyHealer and not E.Classic and not ignorePets[parent.unitframeType])
		parent.powerVisibility = visibility -- so we can only call this when needed

		local barShown = self:IsShown()
		if visibility then
			local _, powerType = UnitPowerType(unit)
			local fullType = powerTypesFull[powerType]
			local autoHide = not db.autoHide or ((fullType and cur ~= max) or (not fullType and cur ~= min))
			local onlyHealer = not db.onlyHealer or (((parent.db.roleIcon and parent.db.roleIcon.enable and parent.role) or UF:GetRoleIcon(parent)) == 'HEALER')
			local notInCombat = not db.notInCombat or InCombatLockdown()

			local shouldShow = autoHide and onlyHealer and notInCombat
			if shouldShow and not barShown then
				self:Show()

				UF:PowerBar_PostVisibility(self, parent)
			elseif not shouldShow and barShown then
				self:Hide()

				UF:PowerBar_PostVisibility(self, parent)
			end
		elseif (pastVisibility ~= visibility) and not barShown then
			self:Show()

			UF:PowerBar_PostVisibility(self, parent)
		end
	end
end
