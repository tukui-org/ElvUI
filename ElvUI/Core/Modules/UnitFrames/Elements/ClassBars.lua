local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local ElvUF = E.oUF

local max = max
local wipe = wipe
local next = next
local pairs = pairs
local ipairs = ipairs
local unpack = unpack

local CreateFrame = CreateFrame
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
local SPEC_MONK_MISTWEAVER = SPEC_MONK_MISTWEAVER or 2

UF.ClassPowerTypes = { 'ClassPower', 'AdditionalPower', 'Runes', 'Stagger', 'Totems', 'AlternativePower', 'EclipseBar' }
UF.ClassPowerColors = { COMBO_POINTS = 'comboPoints', ESSENCE = 'EVOKER', CHI = 'MONK' }

local AltManaTypes = { Rage = 1, Energy = 3 }
if E.Retail then
	AltManaTypes.LunarPower = 8
	AltManaTypes.Maelstrom = 11
	AltManaTypes.Insanity = 13
end

function UF:GetClassPower_Construct(frame)
	frame.ClassPower = UF:Construct_ClassBar(frame)
	frame.ClassBar = 'ClassPower'

	if E.myclass == 'DRUID' then
		frame.AdditionalPower = UF:Construct_AdditionalPowerBar(frame)

		if E.Mists then
			frame.EclipseBar = UF:Construct_DruidEclipseBar(frame)
		end
	elseif E.myclass == 'MONK' then
		frame.Stagger = UF:Construct_Stagger(frame) -- Retail: Classbar, Mists: AdditionalPower

		if E.Mists then
			frame.AdditionalPower = UF:Construct_AdditionalPowerBar(frame)
		end
	elseif E.myclass == 'DEATHKNIGHT' then
		frame.Runes = UF:Construct_DeathKnightResourceBar(frame)
		frame.ClassBar = 'Runes'
	elseif not E.Retail and E.myclass == 'SHAMAN' then
		frame.Totems = UF:Construct_Totems(frame)
	end

	if E.Classic and E.myclass ~= 'WARRIOR' then
		frame.EnergyManaRegen = UF:Construct_EnergyManaRegen(frame)
	end
end

function UF:PostVisibility_ClassBars(frame)
	if not (frame and frame.db) then return end

	UF:Configure_ClassBar(frame)
	UF:Configure_Power(frame)
	UF:Configure_InfoPanel(frame)
end

function UF:ClassPower_SetBarColor(bar, r, g, b, custom_backdrop)
	bar:SetStatusBarColor(r, g, b)

	if bar.bg then
		if custom_backdrop then
			bar.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		else
			bar.bg:SetVertexColor(r * .35, g * .35, b * .35)
		end
	end
end

function UF:ClassPower_GetColor(colors, powerType)
	local all, power = colors.classResources, colors.power
	local mine = all and all[E.myclass]

	return all, powerType ~= 'MANA' and (all[UF.ClassPowerColors[powerType]] or (mine and mine[powerType]) or mine), power[powerType] or power.MANA
end

function UF:ClassPower_BarColor(bar, index, colors, powers, isRunes)
	return (isRunes and colors.DEATHKNIGHT[bar.runeType or 0]) or (index and powers and powers[index]) or powers
end

function UF:ClassPower_UpdateColor(powerType, rune)
	local isRunes = powerType == 'RUNES'
	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	local colors, powers, fallback = UF:ClassPower_GetColor(UF.db.colors, powerType)
	if isRunes and UF.db.colors.chargingRunes then
		UF:Runes_UpdateCharged(self, rune, custom_backdrop)
	elseif isRunes and rune then
		local color = UF:ClassPower_BarColor(isRunes, rune)
		UF:ClassPower_SetBarColor(rune, color.r, color.g, color.b, custom_backdrop)
	else
		for index, bar in ipairs(self) do
			local color = UF:ClassPower_BarColor(bar, index, colors, powers, isRunes)
			if not color or not color.r then
				UF:ClassPower_SetBarColor(bar, fallback.r, fallback.g, fallback.b, custom_backdrop)
			else
				UF:ClassPower_SetBarColor(bar, color.r, color.g, color.b, custom_backdrop)
			end
		end
	end
end

function UF:Configure_ClassBar(frame)
	local db = frame.db
	if not db then return end

	local bars = frame[frame.ClassBar]
	if not bars then return end

	bars.Holder = frame.ClassBarHolder
	bars.AdditionalHolder = frame.AdditionalPower and frame.ClassAdditionalHolder
	bars.origParent = frame

	local MAX_CLASS_BAR = frame.MAX_CLASS_BAR

	--Fix height in case it is lower than the theme allows, or in case it's higher than 30px when not detached
	if not UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7) then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.classbar then db.classbar.height = 7 end
	elseif UF.thinBorders and (frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3) then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.classbar then db.classbar.height = 3 end
	elseif not frame.CLASSBAR_DETACHED and frame.CLASSBAR_HEIGHT > 30 then
		frame.CLASSBAR_HEIGHT = 10
		if db.classbar then db.classbar.height = 10 end
	end

	--We don't want to modify the original frame.CLASSBAR_WIDTH value, as it bugs out when the classbar gains more buttons
	local CLASSBAR_WIDTH = E:Scale(frame.CLASSBAR_WIDTH)
	local SPACING = E:Scale((UF.BORDER + UF.SPACING)*2)
	local isVertical = frame.CLASSBAR_DETACHED and db.classbar.verticalOrientation

	local color = E.db.unitframe.colors.borderColor
	if not bars.backdrop.forcedBorderColors then
		bars.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		if MAX_CLASS_BAR == 1 or frame.ClassBar == 'EclipseBar' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2 / 3
		else
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * (MAX_CLASS_BAR - 1) / MAX_CLASS_BAR
		end
	elseif frame.CLASSBAR_DETACHED then --Detached
		CLASSBAR_WIDTH = db.classbar.detachedWidth
	end

	bars:Width(CLASSBAR_WIDTH - SPACING)
	bars:Height(frame.CLASSBAR_HEIGHT - SPACING)

	if frame.ClassBar == 'ClassPower' or frame.ClassBar == 'Runes' or frame.ClassBar == 'Totems' then
		if frame.ClassBar == 'Runes' then
			bars.sortOrder = (db.classbar.sortDirection ~= 'NONE') and db.classbar.sortDirection
			bars.colorSpec = E.Retail and UF.db.colors.runeBySpec
		end

		local maxClassBarButtons = max(UF.classMaxResourceBar[E.myclass] or 0, frame.ClassBar == 'Totems' and 4 or MAX_COMBO_POINTS)
		for i = 1, maxClassBarButtons do
			local button = bars[i]
			button.backdrop:Hide()

			if i <= MAX_CLASS_BAR then
				if not button.backdrop.forcedBorderColors then
					button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				end

				button:Height(bars:GetHeight())

				if MAX_CLASS_BAR == 1 then
					button:Width(CLASSBAR_WIDTH)
				elseif frame.USE_MINI_CLASSBAR then
					if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
						button:Width(CLASSBAR_WIDTH)
					else
						button:Width((CLASSBAR_WIDTH - (((frame.CLASSBAR_DETACHED and db.classbar.spacing or 5) + (UF.BORDER*2 + UF.SPACING*2))*(MAX_CLASS_BAR - 1)) - UF.BORDER*2)/MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
					end
				elseif i ~= MAX_CLASS_BAR then
					button:Width((CLASSBAR_WIDTH - ((MAX_CLASS_BAR-1)*(UF.BORDER*2-UF.SPACING))) / MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
				end

				button:GetStatusBarTexture():SetHorizTile(false)
				button:ClearAllPoints()

				if i == 1 then
					button:Point('LEFT', bars)
				else
					local prevButton = bars[i-1]
					if frame.USE_MINI_CLASSBAR then
						if frame.CLASSBAR_DETACHED and db.classbar.orientation == 'VERTICAL' then
							button:Point('BOTTOM', prevButton, 'TOP', 0, (db.classbar.spacing + UF.BORDER*2 + UF.SPACING*2))
						else
							button:Point('LEFT', prevButton, 'RIGHT', ((frame.CLASSBAR_DETACHED and db.classbar.spacing or 5) + UF.BORDER*2 + UF.SPACING*2), 0) --5px spacing between borders of each button(replaced with Detached Spacing option if detached)
						end
					elseif i == MAX_CLASS_BAR then
						button:Point('LEFT', prevButton, 'RIGHT', UF.BORDER-UF.SPACING, 0)
						button:Point('RIGHT', bars)
					else
						button:Point('LEFT', prevButton, 'RIGHT', UF.BORDER-UF.SPACING, 0)
					end
				end

				button.backdrop:SetShown(frame.USE_MINI_CLASSBAR)

				button:SetOrientation(isVertical and 'VERTICAL' or 'HORIZONTAL')

				if frame.ClassBar == 'ClassPower' or frame.ClassBar == 'Totems' then
					button.bg:SetParent(frame.USE_MINI_CLASSBAR and bars[i].backdrop or bars)
				end
			end
		end

		bars.backdrop:SetShown(not frame.USE_MINI_CLASSBAR and frame.USE_CLASSBAR)
	elseif frame.ClassBar == 'EclipseBar' then
		local lunarTex = bars.LunarBar:GetStatusBarTexture()

		local lr, lg, lb = unpack(ElvUF.colors.ClassBars.DRUID[1])
		bars.LunarBar:SetMinMaxValues(-1, 1)
		bars.LunarBar:SetStatusBarColor(lr, lg, lb)
		bars.LunarBar:Size(CLASSBAR_WIDTH - SPACING, frame.CLASSBAR_HEIGHT - SPACING)
		bars.LunarBar:SetOrientation(isVertical and 'VERTICAL' or 'HORIZONTAL')
		E:SetSmoothing(bars.LunarBar, db.classbar and db.classbar.smoothbars)

		local sr, sg, sb = unpack(ElvUF.colors.ClassBars.DRUID[2])
		bars.SolarBar:SetMinMaxValues(-1, 1)
		bars.SolarBar:SetStatusBarColor(sr, sg, sb)
		bars.SolarBar:Size(CLASSBAR_WIDTH - SPACING, frame.CLASSBAR_HEIGHT - SPACING)
		bars.SolarBar:SetOrientation(isVertical and 'VERTICAL' or 'HORIZONTAL')
		bars.SolarBar:ClearAllPoints()
		bars.SolarBar:Point(isVertical and 'BOTTOM' or 'LEFT', lunarTex, isVertical and 'TOP' or 'RIGHT')
		E:SetSmoothing(bars.SolarBar, db.classbar and db.classbar.smoothbars)

		bars.Arrow:ClearAllPoints()
		bars.Arrow:Point('CENTER', lunarTex, isVertical and 'TOP' or 'RIGHT', 0, isVertical and -4 or 0)
	elseif frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
		bars:SetOrientation(isVertical and 'VERTICAL' or 'HORIZONTAL')
	end

	if bars.AdditionalHolder then
		bars.AdditionalHolder:Size(db.classAdditional.width, db.classAdditional.height)

		if not bars.AdditionalHolder.mover then
			E:CreateMover(bars.AdditionalHolder, 'AdditionalPowerMover', L["Additional Class Power"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,classbar')
		else
			E:EnableMover(bars.AdditionalHolder.mover.name)
		end

		if frame.Stagger then
			frame.Stagger:ClearAllPoints()
			frame.Stagger:Point('BOTTOMLEFT', bars.AdditionalHolder, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)
			frame.Stagger:Size(db.classAdditional.width - SPACING, db.classAdditional.height - SPACING)
			frame.Stagger:SetFrameLevel(db.classAdditional.frameLevel)
			frame.Stagger:SetFrameStrata(db.classAdditional.frameStrata)
			frame.Stagger:SetOrientation(db.classAdditional.orientation)
		end

		if frame.AdditionalPower then
			frame.AdditionalPower:ClearAllPoints()
			frame.AdditionalPower:Point('BOTTOMLEFT', bars.AdditionalHolder, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)
			frame.AdditionalPower:Size(db.classAdditional.width - SPACING, db.classAdditional.height - SPACING)
			frame.AdditionalPower:SetFrameLevel(db.classAdditional.frameLevel)
			frame.AdditionalPower:SetFrameStrata(db.classAdditional.frameStrata)
			frame.AdditionalPower:SetOrientation(db.classAdditional.orientation)
		end
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point('CENTER', frame.Health.backdrop, 'TOP', 0, 0)

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover.name)
		end
	elseif frame.CLASSBAR_DETACHED then
		bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)

		bars:ClearAllPoints()
		bars:Point('BOTTOMLEFT', bars.Holder, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

		if not bars.Holder.mover then
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Class Bar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,classbar')
		else
			E:EnableMover(bars.Holder.mover.name)
		end

		bars:SetFrameStrata(db.classbar.strataAndLevel.useCustomStrata and db.classbar.strataAndLevel.frameStrata or 'LOW')
		bars:SetFrameLevel(db.classbar.strataAndLevel.useCustomLevel and db.classbar.strataAndLevel.frameLevel or frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
	else
		bars:OffsetFrameLevel(10, frame.Health) --Health uses 10, Power uses (Health + 5) when attached
		bars:SetFrameStrata('LOW')
		bars:ClearAllPoints()

		if frame.ORIENTATION == 'RIGHT' then
			bars:Point('BOTTOMRIGHT', frame.Health.backdrop, 'TOPRIGHT', -UF.BORDER, UF.SPACING*3)
		else
			bars:Point('BOTTOMLEFT', frame.Health.backdrop, 'TOPLEFT', UF.BORDER, UF.SPACING*3)
		end

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover.name)
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == 'UIPARENT' then
		E.FrameLocks[bars] = true
		bars:SetParent(E.UIParent)
	else
		E.FrameLocks[bars] = nil
		bars:SetParent(frame)
	end

	for _, powerType in pairs(UF.ClassPowerTypes) do
		if frame[powerType] then
			if frame.USE_CLASSBAR then
				if powerType == 'AdditionalPower' then
					local displayMana = frame.AdditionalPower.displayPairs[E.myclass]
					wipe(displayMana)

					local altMana = E.db.unitframe.altManaPowers[E.myclass]
					if altMana then
						for name, value in pairs(altMana) do
							local altType = value and AltManaTypes[name]
							if altType then
								displayMana[altType] = value
							end
						end
					end

					local display = next(displayMana)
					local enabled = frame:IsElementEnabled(powerType)
					if display and not enabled then
						frame:EnableElement(powerType)
					elseif enabled and not display then
						frame:DisableElement(powerType)
					end
				elseif not frame:IsElementEnabled(powerType) then
					frame:EnableElement(powerType)
				end
			elseif frame:IsElementEnabled(powerType) then
				frame:DisableElement(powerType)
			end
		end
	end

	UF:Update_StatusBars(UF.classbars)

	UF.ToggleResourceBar(bars) -- keep after classbar height update
end

function UF:ToggleResourceBar()
	local frame = self.origParent or self:GetParent()

	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = frame[frame.ClassBar]:IsShown()

	if self.text then self.text:SetAlpha(frame.CLASSBAR_SHOWN and 1 or 0) end

	frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and ((db.classbar and db.classbar.height) or (frame.AlternativePower and db.power.height)) or 0
	frame.CLASSBAR_YOFFSET = ((not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED)) and 0 or (frame.USE_MINI_CLASSBAR and ((UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5))) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))

	UF:Configure_CustomTexts(frame)
	UF:Configure_HealthBar(frame)
	UF:Configure_Portrait(frame)

	-- keep this after the configure_healtbar, we need the one updated before we match the healpred size to -1
	if frame.HealthPrediction then
		UF:SetSize_HealComm(frame)
	end
end

-------------------------------------------------------------
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame('Frame', '$parent_ClassBar', frame)
	bars:CreateBackdrop(nil, nil, nil, nil, true)
	bars:Hide()

	bars.RaisedElementParent = UF:CreateRaisedElement(bars)

	local frameName = frame:GetName()
	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
	for i = 1, maxBars do
		local bar = CreateFrame('StatusBar', frameName..'ClassIconButton'..i, bars)
		bar:SetStatusBarTexture(E.media.blankTex) --Dummy really, this needs to be set so we can change the color
		bar:GetStatusBarTexture():SetHorizTile(false)

		UF.statusbars[bar] = true
		UF.classbars[bar] = true

		bar:CreateBackdrop(nil, nil, nil, nil, true)
		bar.backdrop:SetParent(bars)

		bar.bg = bars:CreateTexture(nil, 'BORDER')
		bar.bg:SetTexture(E.media.blankTex)
		bar.bg:SetInside(bar.backdrop)

		bars[i] = bar
	end

	bars.PostVisibility = UF.PostVisibilityClassBar
	bars.PostUpdate = UF.UpdateClassBar
	bars.UpdateColor = UF.ClassPower_UpdateColor
	bars.UpdateTexture = E.noop --We don't use textures but statusbars, so prevent errors

	bars:SetScript('OnShow', UF.ToggleResourceBar)
	bars:SetScript('OnHide', UF.ToggleResourceBar)

	return bars
end

function UF:PostVisibilityClassBar()
	UF:PostVisibility_ClassBars(self.origParent or self:GetParent())
end

function UF:UpdateClassBar(current, maxBars, hasMaxChanged, powerType, chargedPoints)
	local frame = self.origParent or self:GetParent()
	local db = frame.db
	if not db then return end

	local isShown = self:IsShown()
	local stateChanged

	if not frame.USE_CLASSBAR or (current == 0 and db.classbar.autoHide) or maxBars == 0 or not maxBars then
		self:Hide()
		if isShown then
			stateChanged = true
		end
	else
		self:Show()
		if not isShown then
			stateChanged = true
		end
	end

	if maxBars and maxBars > 0 and hasMaxChanged then
		frame.MAX_CLASS_BAR = maxBars
		UF:Configure_ClassBar(frame, current)
	elseif stateChanged then
		UF:Configure_ClassBar(frame, current)
	end

	for i, bar in ipairs(self) do
		if maxBars and (i <= maxBars) then
			bar.bg:Show()
		else
			bar.bg:Hide()
		end
	end

	if powerType == 'COMBO_POINTS' and E.myclass == 'ROGUE' then
		UF.ClassPower_UpdateColor(self, powerType)

		if chargedPoints then
			local color = ElvUF.colors.chargedComboPoint
			for _, cIndex in next, chargedPoints do
				local cPoint = self[cIndex]
				if cPoint then
					cPoint:SetStatusBarColor(color.r, color.g, color.b)
					cPoint.bg:SetVertexColor(color.r * .35, color.g * .35, color.b * .35)
				end
			end
		end
	end
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------

function UF:Runes_GetColor(rune, colors, classPower)
	local value = rune:GetValue()

	if E.Mists then
		local _, maxDuration = rune:GetMinMaxValues()
		local duration = value == maxDuration and 1 or ((value * maxDuration) / 255) + .35

		local color = colors[rune.runeType or 0]
		return color.r * duration, color.g * duration, color.b * duration
	else -- classPower is for nameplates only
		local color = (value == 1 and classPower) or colors[(value and value ~= 1 and -1) or rune.runeType or 0]
		return color.r, color.g, color.b
	end
end

function UF:Runes_UpdateCharged(runes, rune, custom_backdrop)
	local colors = UF.db.colors.classResources.DEATHKNIGHT
	if not custom_backdrop then
		custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	end

	if rune then
		local r, g, b = UF:Runes_GetColor(rune, colors)
		UF:ClassPower_SetBarColor(rune, r, g, b, UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop)
	elseif runes then
		for _, bar in ipairs(runes) do
			local r, g, b = UF:Runes_GetColor(bar, colors)
			UF:ClassPower_SetBarColor(bar, r, g, b, custom_backdrop)
		end
	end
end

function UF:Runes_PostUpdate(_, hasVehicle, allReady)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if hasVehicle then
		self:SetShown(false)
	else
		self:SetShown(not db.classbar.autoHide or not allReady)
	end

	if UF.db.colors.chargingRunes then
		UF:Runes_UpdateCharged(self)
	end
end

function UF:Runes_UpdateChargedColor()
	if UF.db.colors.chargingRunes then
		UF:Runes_UpdateCharged(nil, self)
	end
end

function UF:Runes_PostUpdateColor(r, g, b, color, rune)
	UF.ClassPower_UpdateColor(self, 'RUNES', rune)
end

function UF:Construct_DeathKnightResourceBar(frame)
	local runes = CreateFrame('Frame', '$parent_Runes', frame)
	runes:CreateBackdrop(nil, nil, nil, nil, true)
	runes.backdrop:Hide()

	for i = 1, UF.classMaxResourceBar[E.myclass] do
		local rune = CreateFrame('StatusBar', frame:GetName()..'RuneButton'..i, runes)
		rune:SetStatusBarTexture(E.media.blankTex)
		rune:GetStatusBarTexture():SetHorizTile(false)

		UF.statusbars[rune] = true
		UF.classbars[rune] = true

		rune:CreateBackdrop(nil, nil, nil, nil, true)
		rune.PostUpdateColor = UF.Runes_UpdateChargedColor
		rune.__owner = runes
		rune.backdrop:SetParent(runes)

		rune.bg = rune:CreateTexture(nil, 'BORDER')
		rune.bg:SetTexture(E.media.blankTex)
		rune.bg:SetInside(rune.backdrop)
		rune.bg.multiplier = 0.35

		runes[i] = rune
	end

	runes.PostUpdate = UF.Runes_PostUpdate
	runes.PostUpdateColor = UF.Runes_PostUpdateColor

	runes:SetScript('OnShow', UF.ToggleResourceBar)
	runes:SetScript('OnHide', UF.ToggleResourceBar)

	return runes
end

-------------------------------------------------------------
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', '$parent_AdditionalPowerBar', frame)
	additionalPower.colorPower = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateColor = UF.PostColorAdditionalPower
	additionalPower.PostVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop(nil, nil, nil, nil, true)
	additionalPower:SetStatusBarTexture(E.media.blankTex)

	UF.statusbars[additionalPower] = true
	UF.classbars[additionalPower] = true

	additionalPower.RaisedElementParent = UF:CreateRaisedElement(additionalPower)
	additionalPower.text = UF:CreateRaisedText(additionalPower.RaisedElementParent)
	additionalPower.displayPairs = {[E.myclass] = {}} -- display power types

	additionalPower.bg = additionalPower:CreateTexture(nil, 'BORDER')
	additionalPower.bg:SetTexture(E.media.blankTex)
	additionalPower.bg:SetInside(nil, 0, 0)
	additionalPower.bg.multiplier = 0.35

	additionalPower:SetScript('OnShow', UF.ToggleResourceBar)
	additionalPower:SetScript('OnHide', UF.ToggleResourceBar)

	UF:Construct_ClipFrame(frame, additionalPower)

	return additionalPower
end

function UF:PostColorAdditionalPower()
	local frame = self.origParent or self:GetParent()
	if frame.USE_CLASSBAR then
		local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
		if custom_backdrop then
			self.bg:SetVertexColor(custom_backdrop.r, custom_backdrop.g, custom_backdrop.b)
		end
	end
end

function UF:PostUpdateAdditionalPower(CUR, MAX, event)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	self:SetShown((frame.USE_CLASSBAR and event ~= 'ElementDisable') and (CUR ~= MAX or not db.classAdditional.autoHide) and (not E.Mists or E.myclass ~= 'MONK' or E.myspec == SPEC_MONK_MISTWEAVER))
end

function UF:PostVisibilityAdditionalPower()
	-- this used to do something but now the bar is split off
end

-----------------------------------------------------------
-- Energy Mana Regen Ticks
-----------------------------------------------------------
function UF:Construct_EnergyManaRegen(frame)
	local element = CreateFrame('StatusBar', nil, frame.Power)
	element:SetStatusBarTexture(E.media.blankTex)
	element:OffsetFrameLevel(10, frame.Power)
	element:SetMinMaxValues(0, 2)
	element:SetAllPoints()

	local barTexture = element:GetStatusBarTexture()
	barTexture:SetAlpha(0)

	element.RaisedElementParent = UF:CreateRaisedElement(element)

	element.Spark = element:CreateTexture(nil, 'OVERLAY')
	element.Spark:SetTexture(E.media.blankTex)
	element.Spark:SetVertexColor(0.9, 0.9, 0.9, 0.6)
	element.Spark:SetBlendMode('ADD')
	element.Spark:Point('RIGHT', barTexture)
	element.Spark:Point('BOTTOM')
	element.Spark:Point('TOP')
	element.Spark:Width(2)

	return element
end

function UF:Configure_EnergyManaRegen(frame)
	if frame.db.power.EnergyManaRegen then
		if not frame:IsElementEnabled('EnergyManaRegen') then
			frame:EnableElement('EnergyManaRegen')
		end

		frame.EnergyManaRegen:SetFrameStrata(frame.Power:GetFrameStrata())
		frame.EnergyManaRegen:OffsetFrameLevel(10, frame.Power)
	elseif frame:IsElementEnabled('EnergyManaRegen') then
		frame:DisableElement('EnergyManaRegen')
	end
end

-----------------------------------------------------------
-- Eclipse Bar (Cataclysm)
-----------------------------------------------------------
function UF:Construct_DruidEclipseBar(frame)
	local eclipseBar = CreateFrame('Frame', '$parent_EclipsePowerBar', frame)
	eclipseBar:CreateBackdrop(nil, nil, nil, self.thinBorders, true)

	eclipseBar.LunarBar = CreateFrame('StatusBar', 'LunarBar', eclipseBar)
	eclipseBar.LunarBar:Point('LEFT', eclipseBar)
	eclipseBar.LunarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.LunarBar] = true

	eclipseBar.SolarBar = CreateFrame('StatusBar', 'SolarBar', eclipseBar)
	eclipseBar.SolarBar:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[eclipseBar.SolarBar] = true

	eclipseBar.RaisedElementParent = UF:CreateRaisedElement(eclipseBar)

	eclipseBar.Arrow = eclipseBar.LunarBar:CreateTexture(nil, 'OVERLAY')
	eclipseBar.Arrow:SetTexture(E.Media.Textures.ArrowUp)
	eclipseBar.Arrow:SetPoint('CENTER')

	eclipseBar.PostDirectionChange = UF.EclipsePostDirectionChange
	eclipseBar.PostUpdateVisibility = UF.EclipsePostUpdateVisibility

	eclipseBar:SetScript('OnShow', UF.ToggleResourceBar)
	eclipseBar:SetScript('OnHide', UF.ToggleResourceBar)

	return eclipseBar
end

function UF:EclipsePostDirectionChange(direction)
	local frame = self.origParent or self:GetParent()
	local vertical = frame.CLASSBAR_DETACHED and frame.db.classbar.verticalOrientation
	local r, g, b = unpack(ElvUF.colors.ClassBars.DRUID[direction == 'sun' and 1 or 2])

	self.Arrow:SetShown(direction == 'sun' or direction == 'moon')
	self.Arrow:SetRotation(direction == 'sun' and (vertical and 0 or -1.57) or (vertical and 3.14 or 1.57))
	self.Arrow:SetVertexColor(r, g, b)
end

function UF:EclipsePostUpdateVisibility(enabled)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = (enabled and 'EclipseBar') or 'ClassPower'

	UF:PostVisibility_ClassBars(frame)
end

-----------------------------------------------------------
-- Stagger Bar
-----------------------------------------------------------
function UF:Construct_Stagger(frame)
	local stagger = CreateFrame('Statusbar', '$parent_Stagger', frame)
	stagger:CreateBackdrop(nil,nil, nil, nil, true)
	stagger.PostUpdate = UF.PostUpdateStagger
	stagger.PostVisibility = UF.PostUpdateVisibilityStagger

	UF.statusbars[stagger] = true
	UF.classbars[stagger] = true

	stagger:SetScript('OnShow', UF.ToggleResourceBar)
	stagger:SetScript('OnHide', UF.ToggleResourceBar)

	return stagger
end

function UF:PostUpdateStagger(stagger)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if E.Retail then
		local autohide = stagger == 0 and db.classbar.autoHide
		self:SetShown(frame.USE_CLASSBAR and not autohide)
	else
		local autohide = stagger == 0 and db.classAdditional.autoHide
		local altPower = E.db.unitframe.altManaPowers[E.myclass]
		self:SetShown(altPower and altPower.Stagger and not autohide)
	end
end

function UF:PostUpdateVisibilityStagger(_, _, isShown, stateChanged)
	if not E.Retail then return end

	self.ClassBar = (isShown and 'Stagger') or 'ClassPower'

	if stateChanged then
		UF:PostVisibility_ClassBars(self)
	end
end

-----------------------------------------------------------
-- Totems
-----------------------------------------------------------

function UF:Totems_PostUpdateColor()
	UF.ClassPower_UpdateColor(self, 'TOTEMS')
end

function UF:Construct_Totems(frame)
	local totems = CreateFrame('Frame', nil, frame)
	totems:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)

	for i = 1, 4 do
		local totem = CreateFrame('StatusBar', frame:GetName()..'Totem'..i, totems)
		totem:CreateBackdrop(nil, nil, nil, UF.thinBorders, true)
		totem.backdrop:SetParent(totems)

		UF.statusbars[totem] = true
		UF.classbars[totem] = true

		totem:EnableMouse(true)
		totem:SetStatusBarTexture(E.media.blankTex)
		totem:SetMinMaxValues(0, 1)
		totem:SetValue(0)

		totem.bg = totem:CreateTexture(nil, 'BORDER')
		totem.bg:SetTexture(E.media.blankTex)
		totem.bg:SetInside(totem, 0, 0)

		totems[i] = totem
	end

	totems.PostUpdateColor = UF.Totems_PostUpdateColor

	UF.Totems_PostUpdateColor(totems)

	frame.MAX_CLASS_BAR = 4
	frame.ClassBar = 'Totems'

	return totems
end
