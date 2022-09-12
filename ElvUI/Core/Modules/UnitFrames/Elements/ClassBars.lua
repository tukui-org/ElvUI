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
-- GLOBALS: ElvUF_Player

local AltManaTypes = { Rage = 1 }
local ClassPowerTypes = { 'ClassPower', 'AdditionalPower', 'Runes', 'Stagger', 'Totems', 'AlternativePower' }

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
	elseif E.myclass == 'MONK' then
		frame.Stagger = UF:Construct_Stagger(frame)
	elseif E.myclass == 'DEATHKNIGHT' then
		frame.Runes = UF:Construct_DeathKnightResourceBar(frame)
		frame.ClassBar = 'Runes'
	elseif E.Retail and (E.myclass == 'SHAMAN' or E.myclass == 'PRIEST') then
		frame.AdditionalPower = UF:Construct_AdditionalPowerBar(frame)
	elseif E.myclass == 'SHAMAN' then
		frame.Totems = UF:Construct_Totems(frame)
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

function UF:ClassPower_UpdateColor(powerType, rune)
	local custom_backdrop = UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop
	local isRunes = powerType == 'RUNES'

	local colors = UF.db.colors.classResources
	local fallback = UF.db.colors.power[powerType]

	if isRunes and E.Retail and UF.db.colors.chargingRunes then
		UF:Runes_UpdateCharged(self, custom_backdrop)
	elseif isRunes and rune then
		local color = colors.DEATHKNIGHT[rune.runeType or 0]
		UF:ClassPower_SetBarColor(rune, color.r, color.g, color.b, custom_backdrop)
	else
		local classColor = (isRunes and colors.DEATHKNIGHT) or (powerType == 'COMBO_POINTS' and colors.comboPoints) or (powerType == 'CHI' and colors.MONK) or (powerType == 'Totems' and colors.SHAMAN)
		for i, bar in ipairs(self) do
			local color = (isRunes and classColor[bar.runeType or 0]) or (classColor and classColor[i]) or colors[E.myclass] or fallback
			UF:ClassPower_SetBarColor(bar, color.r, color.g, color.b, custom_backdrop)
		end
	end
end

function UF:Configure_ClassBar(frame)
	local db = frame.db
	if not db then return end

	local bars = frame[frame.ClassBar]
	if not bars then return end

	bars.Holder = frame.ClassBarHolder
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
		if MAX_CLASS_BAR == 1 or frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3
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
	elseif frame.ClassBar == 'AdditionalPower' or frame.ClassBar == 'Stagger' or frame.ClassBar == 'AlternativePower' then
		bars:SetOrientation(isVertical and 'VERTICAL' or 'HORIZONTAL')
	end

	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		bars:ClearAllPoints()
		bars:Point('CENTER', frame.Health.backdrop, 'TOP', 0, 0)

		bars:SetFrameLevel(50) --RaisedElementParent uses 100, we want it lower than this

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
		end
	elseif frame.CLASSBAR_DETACHED then
		bars.Holder:Size(db.classbar.detachedWidth, db.classbar.height)

		bars:ClearAllPoints()
		bars:Point('BOTTOMLEFT', bars.Holder, 'BOTTOMLEFT', UF.BORDER + UF.SPACING, UF.BORDER + UF.SPACING)

		if not bars.Holder.mover then
			E:CreateMover(bars.Holder, 'ClassBarMover', L["Classbar"], nil, nil, nil, 'ALL,SOLO', nil, 'unitframe,individualUnits,player,classbar')
		else
			E:EnableMover(bars.Holder.mover:GetName())
		end

		bars:SetFrameStrata(db.classbar.strataAndLevel.useCustomStrata and db.classbar.strataAndLevel.frameStrata or 'LOW')
		bars:SetFrameLevel(db.classbar.strataAndLevel.useCustomLevel and db.classbar.strataAndLevel.frameLevel or frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached
	else
		bars:ClearAllPoints()
		if frame.ORIENTATION == 'RIGHT' then
			bars:Point('BOTTOMRIGHT', frame.Health.backdrop, 'TOPRIGHT', -UF.BORDER, UF.SPACING*3)
		else
			bars:Point('BOTTOMLEFT', frame.Health.backdrop, 'TOPLEFT', UF.BORDER, UF.SPACING*3)
		end

		bars:SetFrameStrata('LOW')
		bars:SetFrameLevel(frame.Health:GetFrameLevel() + 10) --Health uses 10, Power uses (Health + 5) when attached

		if bars.Holder and bars.Holder.mover then
			E:DisableMover(bars.Holder.mover:GetName())
		end
	end

	if frame.CLASSBAR_DETACHED and db.classbar.parent == 'UIPARENT' then
		E.FrameLocks[bars] = true
		bars:SetParent(E.UIParent)
	else
		E.FrameLocks[bars] = nil
		bars:SetParent(frame)
	end

	if frame.USE_CLASSBAR then
		for _, powerType in pairs(ClassPowerTypes) do
			if frame[powerType] then
				if powerType == 'AdditionalPower' then
					local altMana, displayMana = E.db.unitframe.altManaPowers[E.myclass], frame.AdditionalPower.displayPairs[E.myclass]
					wipe(displayMana)

					if altMana then
						for name, value in pairs(altMana) do
							local altType = AltManaTypes[name]
							if altType and value then
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
			end
		end
	else
		for _, powerType in pairs(ClassPowerTypes) do
			if frame[powerType] and frame:IsElementEnabled(powerType) then
				frame:DisableElement(powerType)
			end
		end
	end

	UF:Update_StatusBars(UF.classbars)

	UF.ToggleResourceBar(bars) -- keep after classbar height update
end

local function ToggleResourceBar(bars)
	local frame = bars.origParent or bars:GetParent()

	local db = frame.db
	if not db then return end

	frame.CLASSBAR_SHOWN = frame[frame.ClassBar]:IsShown()

	if bars.text then bars.text:SetAlpha(frame.CLASSBAR_SHOWN and 1 or 0) end

	frame.CLASSBAR_HEIGHT = frame.USE_CLASSBAR and ((db.classbar and db.classbar.height) or (frame.AlternativePower and db.power.height)) or 0
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and ((UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5))) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))

	UF:Configure_CustomTexts(frame)
	UF:Configure_HealthBar(frame)
	UF:Configure_Portrait(frame)

	-- keep this after the configure_healtbar, we need the one updated before we match the healpred size to -1
	if frame.HealthPrediction then
		UF:SetSize_HealComm(frame)
	end
end
UF.ToggleResourceBar = ToggleResourceBar --Make available to combobar

-------------------------------------------------------------
-- MONK, PALADIN, WARLOCK, MAGE, and COMBOS
-------------------------------------------------------------
function UF:Construct_ClassBar(frame)
	local bars = CreateFrame('Frame', '$parent_ClassBar', frame)
	bars:CreateBackdrop(nil, nil, nil, nil, true)
	bars:Hide()

	local maxBars = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)
	for i = 1, maxBars do
		local bar = CreateFrame('StatusBar', frame:GetName()..'ClassIconButton'..i, bars)
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

	bars:SetScript('OnShow', ToggleResourceBar)
	bars:SetScript('OnHide', ToggleResourceBar)

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
			local r, g, b = unpack(ElvUF.colors.chargedComboPoint)
			for _, cIndex in next, chargedPoints do
				local cPoint = self[cIndex]
				if cPoint then
					cPoint:SetStatusBarColor(r, g, b)
					cPoint.bg:SetVertexColor(r * .35, g * .35, b * .35)
				end
			end
		end
	end
end

-------------------------------------------------------------
-- DEATHKNIGHT
-------------------------------------------------------------
function UF:Runes_UpdateCharged(runes, custom_backdrop)
	local colors = UF.db.colors.classResources.DEATHKNIGHT
	for _, bar in ipairs(runes) do
		local value = bar:GetValue()
		local color = colors[(value and value ~= 1 and -1) or bar.runeType or 0]
		UF:ClassPower_SetBarColor(bar, color.r, color.g, color.b, custom_backdrop)
	end
end

function UF:Runes_PostUpdate(_, hasVehicle, allReady)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	self:SetShown(not hasVehicle and not db.classbar.autoHide or not allReady)

	if E.Retail and UF.db.colors.chargingRunes then
		UF:Runes_UpdateCharged(self, UF.db.colors.customclasspowerbackdrop and UF.db.colors.classpower_backdrop)
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
		rune.backdrop:SetParent(runes)

		rune.bg = rune:CreateTexture(nil, 'BORDER')
		rune.bg:SetTexture(E.media.blankTex)
		rune.bg:SetInside(rune.backdrop)
		rune.bg.multiplier = 0.35

		runes[i] = rune
	end

	runes.PostUpdate = UF.Runes_PostUpdate
	runes.PostUpdateColor = UF.Runes_PostUpdateColor

	runes:SetScript('OnShow', ToggleResourceBar)
	runes:SetScript('OnHide', ToggleResourceBar)

	return runes
end

-------------------------------------------------------------
-- ALTERNATIVE MANA BAR
-------------------------------------------------------------
function UF:Construct_AdditionalPowerBar(frame)
	local additionalPower = CreateFrame('StatusBar', '$parent_AdditionalPowerBar', frame)
	additionalPower.colorPower = true
	additionalPower.frequentUpdates = true
	additionalPower.PostUpdate = UF.PostUpdateAdditionalPower
	additionalPower.PostUpdateColor = UF.PostColorAdditionalPower
	additionalPower.PostVisibility = UF.PostVisibilityAdditionalPower
	additionalPower:CreateBackdrop(nil, nil, nil, nil, true)
	additionalPower:SetStatusBarTexture(E.media.blankTex)

	UF.statusbars[additionalPower] = true
	UF.classbars[additionalPower] = true

	additionalPower.RaisedElementParent = UF:CreateRaisedElement(additionalPower, true)
	additionalPower.text = UF:CreateRaisedText(additionalPower.RaisedElementParent)
	additionalPower.displayPairs = {[E.myclass] = {}} -- display power types

	additionalPower.bg = additionalPower:CreateTexture(nil, 'BORDER')
	additionalPower.bg:SetTexture(E.media.blankTex)
	additionalPower.bg:SetInside(nil, 0, 0)
	additionalPower.bg.multiplier = 0.35

	additionalPower:SetScript('OnShow', ToggleResourceBar)
	additionalPower:SetScript('OnHide', ToggleResourceBar)

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

	if frame.USE_CLASSBAR and event ~= 'ElementDisable' and (CUR ~= MAX or not db.classbar.autoHide) then
		self:Show()
	else
		self:Hide()
	end
end

function UF:PostVisibilityAdditionalPower(enabled)
	local frame = self.origParent or self:GetParent()

	frame.ClassBar = (enabled and 'AdditionalPower') or 'ClassPower'

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

	stagger:SetScript('OnShow', ToggleResourceBar)
	stagger:SetScript('OnHide', ToggleResourceBar)

	return stagger
end

function UF:PostUpdateStagger(stagger)
	local frame = self.origParent or self:GetParent()
	local db = frame.db

	if not frame.USE_CLASSBAR or (stagger == 0 and db.classbar.autoHide) then
		self:Hide()
	else
		self:Show()
	end
end

function UF:PostUpdateVisibilityStagger(_, _, isShown, stateChanged)
	self.ClassBar = (isShown and 'Stagger') or 'ClassPower'

	if stateChanged then
		UF:PostVisibility_ClassBars(self)
	end
end

-----------------------------------------------------------
-- Totems
-----------------------------------------------------------

function UF:Totems_PostUpdateColor()
	UF.ClassPower_UpdateColor(self, 'Totems')
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
