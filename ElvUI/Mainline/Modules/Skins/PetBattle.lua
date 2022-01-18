local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local pairs = pairs
local unpack = unpack

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local C_PetBattles_GetPetType = C_PetBattles.GetPetType
local C_PetBattles_GetNumAuras = C_PetBattles.GetNumAuras
local C_PetBattles_GetAuraInfo = C_PetBattles.GetAuraInfo
local BattlePetOwner_Weather = Enum.BattlePetOwner.Weather

local function SkinPetButton(self, bf)
	if not self.backdrop then
		self:CreateBackdrop()
		self.backdrop:SetFrameStrata('LOW')
	end

	self:SetNormalTexture('')
	self.Icon:SetTexCoord(unpack(E.TexCoords))
	self.Icon:SetParent(self.backdrop)
	self.Icon:SetDrawLayer('BORDER')
	self:StyleButton(nil, nil, true)
	self.SelectedHighlight:SetAlpha(0)
	self.pushed:SetInside(self.backdrop)
	self.hover:SetInside(self.backdrop)
	self:SetFrameStrata('LOW')

	if self == bf.SwitchPetButton then
		local spbc = self:GetCheckedTexture()
		spbc:SetColorTexture(1, 1, 1, 0.3)
		spbc:SetInside(self.backdrop)
	end
end

function S:PetBattleFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.petbattleui) then return end

	local f = _G.PetBattleFrame
	local bf = f.BottomFrame
	local infoBars = {
		f.ActiveAlly,
		f.ActiveEnemy
	}

	S:HandleCloseButton(_G.FloatingBattlePetTooltip.CloseButton)

	-- TOP FRAMES
	f:StripTextures()

	local borderSpace = E.PixelMode and 2 or 3
	for index, infoBar in pairs(infoBars) do
		infoBar.Border:SetAlpha(0)
		infoBar.Border2:SetAlpha(0)
		infoBar.healthBarWidth = 300

		infoBar.Icon:CreateBackdrop()
		infoBar.BorderFlash:Kill()
		infoBar.HealthBarBG:Kill()
		infoBar.HealthBarFrame:Kill()

		infoBar.ActualHealthBar:SetTexCoord(0, 1, 0, 1)
		infoBar.ActualHealthBar:SetTexture(E.media.normTex)
		infoBar.ActualHealthBar:CreateBackdrop('Transparent')
		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.ActualHealthBar.backdrop:ClearAllPoints()

		infoBar.PetTypeFrame = CreateFrame('Frame', nil, infoBar)
		infoBar.PetTypeFrame:Size(100, 23)
		infoBar.PetTypeFrame.text = infoBar.PetTypeFrame:CreateFontString(nil, 'OVERLAY')
		infoBar.PetTypeFrame.text:FontTemplate()
		infoBar.PetTypeFrame.text:SetText('')

		infoBar.Name:ClearAllPoints()
		infoBar.FirstAttack = infoBar:CreateTexture(nil, 'ARTWORK')
		infoBar.FirstAttack:Size(30)
		infoBar.FirstAttack:SetTexture([[Interface\PetBattles\PetBattle-StatIcons]])

		if index == 1 then
			f.Ally2.iconPoint = infoBar.Icon.backdrop
			f.Ally3.iconPoint = infoBar.Icon.backdrop

			infoBar.ActualHealthBar:SetVertexColor(171/255, 214/255, 116/255)
			infoBar.ActualHealthBar:Point('BOTTOMLEFT', infoBar.Icon, 'BOTTOMRIGHT', 10, 0)
			infoBar.ActualHealthBar.backdrop:Point('TOPLEFT', infoBar.ActualHealthBar, -E.Border, E.Border)
			infoBar.ActualHealthBar.backdrop:Point('BOTTOMLEFT', infoBar.ActualHealthBar, -E.Border, -E.Border)
			infoBar.ActualHealthBar.backdrop:Point('RIGHT', infoBar.ActualHealthBar, 'LEFT', infoBar.healthBarWidth + borderSpace, 0)

			infoBar.Name:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'TOPLEFT', 0, 10)
			infoBar.PetTypeFrame:Point('BOTTOMRIGHT',infoBar.ActualHealthBar.backdrop, 'TOPRIGHT', 0, 4)
			infoBar.PetTypeFrame.text:Point('RIGHT')

			infoBar.FirstAttack:Point('LEFT', infoBar.ActualHealthBar.backdrop, 'RIGHT', 5, 0)
			infoBar.FirstAttack:SetTexCoord(infoBar.SpeedIcon:GetTexCoord())
			infoBar.FirstAttack:SetVertexColor(.1,.1,.1,1)
		else
			f.Enemy2.iconPoint = infoBar.Icon.backdrop
			f.Enemy3.iconPoint = infoBar.Icon.backdrop

			infoBar.ActualHealthBar:SetVertexColor(196/255, 30/255, 60/255)
			infoBar.ActualHealthBar:Point('BOTTOMRIGHT', infoBar.Icon, 'BOTTOMLEFT', -10, 0)
			infoBar.ActualHealthBar.backdrop:Point('TOPRIGHT', infoBar.ActualHealthBar, E.Border, E.Border)
			infoBar.ActualHealthBar.backdrop:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, E.Border, -E.Border)
			infoBar.ActualHealthBar.backdrop:Point('LEFT', infoBar.ActualHealthBar, 'RIGHT', -(infoBar.healthBarWidth + borderSpace), 0)

			infoBar.Name:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, 'TOPRIGHT', 0, 10)
			infoBar.PetTypeFrame:Point('BOTTOMLEFT',infoBar.ActualHealthBar.backdrop, 'TOPLEFT', 2, 4)
			infoBar.PetTypeFrame.text:Point('LEFT')

			infoBar.FirstAttack:Point('RIGHT', infoBar.ActualHealthBar.backdrop, 'LEFT', -5, 0)
			infoBar.FirstAttack:SetTexCoord(.5, 0, .5, 1)
			infoBar.FirstAttack:SetVertexColor(.1,.1,.1,1)
		end

		infoBar.HealthText:ClearAllPoints()
		infoBar.HealthText:Point('CENTER', infoBar.ActualHealthBar.backdrop, 'CENTER')

		infoBar.PetType:ClearAllPoints()
		infoBar.PetType:SetAllPoints(infoBar.PetTypeFrame)
		infoBar.PetType:SetFrameLevel(infoBar.PetTypeFrame:GetFrameLevel() + 2)
		infoBar.PetType:SetAlpha(0)

		infoBar.LevelUnderlay:SetAlpha(0)
		infoBar.Level:SetFontObject('NumberFont_Outline_Huge')
		infoBar.Level:ClearAllPoints()
		infoBar.Level:Point('BOTTOMLEFT', infoBar.Icon, 'BOTTOMLEFT', 2, 2)

		if infoBar.SpeedIcon then
			infoBar.SpeedIcon:ClearAllPoints()
			infoBar.SpeedIcon:Point('CENTER') -- to set
			infoBar.SpeedIcon:SetAlpha(0)
			infoBar.SpeedUnderlay:SetAlpha(0)
		end
	end

	-- PETS SPEED INDICATOR UPDATE
	hooksecurefunc('PetBattleFrame_UpdateSpeedIndicators', function()
		if not f.ActiveAlly.SpeedIcon:IsShown() and not f.ActiveEnemy.SpeedIcon:IsShown() then
			f.ActiveAlly.FirstAttack:Hide()
			f.ActiveEnemy.FirstAttack:Hide()
			return
		end

		for _, infoBar in pairs(infoBars) do
			infoBar.FirstAttack:Show()
			if infoBar.SpeedIcon:IsShown() then
				infoBar.FirstAttack:SetVertexColor(0,1,0,1)
			else
				infoBar.FirstAttack:SetVertexColor(.8,0,.3,1)
			end
		end
	end)

	-- PETS UNITFRAMES PET TYPE UPDATE
	hooksecurefunc('PetBattleUnitFrame_UpdatePetType', function(s)
		if s.PetType then
			local petType = C_PetBattles_GetPetType(s.petOwner, s.petIndex)
			if s.PetTypeFrame and petType then
				s.PetTypeFrame.text:SetText(_G['BATTLE_PET_NAME_'..petType])
			end
		end
	end)

	-- PETS UNITFRAMES AURA SKINS
	hooksecurefunc('PetBattleAuraHolder_Update', function(s)
		if not (s.petOwner and s.petIndex) then return end

		local nextFrame = 1
		for i=1, C_PetBattles_GetNumAuras(s.petOwner, s.petIndex) do
			local _, _, turnsRemaining, isBuff = C_PetBattles_GetAuraInfo(s.petOwner, s.petIndex, i)
			if (isBuff and s.displayBuffs) or (not isBuff and s.displayDebuffs) then
				local frame = s.frames[nextFrame]

				-- always hide the border
				frame.DebuffBorder:Hide()

				if not frame.backdrop then
					frame:CreateBackdrop()
					frame.backdrop:SetOutside(frame.Icon)
					frame.Icon:SetTexCoord(unpack(E.TexCoords))
					frame.Icon:SetParent(frame.backdrop)
				end

				if isBuff then
					frame.backdrop:SetBackdropBorderColor(0, 1, 0)
				else
					frame.backdrop:SetBackdropBorderColor(1, 0, 0)
				end

				-- move duration and change font
				frame.Duration:FontTemplate(nil, 12, 'OUTLINE')
				frame.Duration:ClearAllPoints()
				frame.Duration:Point('TOP', frame.Icon, 'BOTTOM', 1, -4)
				if turnsRemaining > 0 then
					frame.Duration:SetText(turnsRemaining)
				end
				nextFrame = nextFrame + 1
			end
		end
	end)

	-- WEATHER
	hooksecurefunc('PetBattleWeatherFrame_Update', function(s)
		local weather = C_PetBattles_GetAuraInfo(BattlePetOwner_Weather, _G.PET_BATTLE_PAD_INDEX, 1)
		if weather then
			s.Icon:Hide()
			s.BackgroundArt:ClearAllPoints()
			s.BackgroundArt:Point('TOP', s, 'TOP', 0, 14)
			s.BackgroundArt:Size(200, 100)
			s.Name:Hide()
			s.DurationShadow:Hide()
			s.Label:Hide()
			s.Duration:ClearAllPoints()
			s.Duration:Point('TOP', s, 'TOP', 0, 10)
			s:ClearAllPoints()
			s:Point('TOP', E.UIParent, 0, -15)
		end
	end)

	hooksecurefunc('PetBattleUnitFrame_UpdateDisplay', function(s)
		s.Icon:SetTexCoord(unpack(E.TexCoords))
	end)

	f.TopVersusText:ClearAllPoints()
	f.TopVersusText:Point('TOP', f, 'TOP', 0, -35)

	-- TOOLTIPS SKINNING
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.BattlePetTooltip)
		TT:SetStyle(_G.PetBattlePrimaryAbilityTooltip)
		TT:SetStyle(_G.PetBattlePrimaryUnitTooltip)
		TT:SetStyle(_G.FloatingBattlePetTooltip)
		TT:SetStyle(_G.FloatingPetBattleAbilityTooltip)

		-- BATTLEPET RARITY COLOR
		hooksecurefunc('BattlePetToolTip_Show', function(_, _, rarity)
			local tt = _G.BattlePetTooltip
			if not tt then return end

			local quality = TT.db.itemQuality and rarity and rarity > 1 and ITEM_QUALITY_COLORS[rarity]
			if quality then
				tt.NineSlice:SetBackdropBorderColor(quality.r, quality.g, quality.b)
				tt.qualityChanged = true
			elseif tt.qualityChanged then
				tt.NineSlice:SetBackdropBorderColor(unpack(E.media.bordercolor))
				tt.qualityChanged = nil
			end
		end)

		-- TOOLTIP DEFAULT POSITION
		hooksecurefunc('PetBattleAbilityTooltip_Show', function()
			local t = _G.PetBattlePrimaryAbilityTooltip
			local point, x, y = 'TOPRIGHT', -4, -4
			--Position it at the bottom right on low resolution setups
			--Otherwise the tooltip might overlap enemy team unit info
			if E.lowversion then
				point, x, y = 'BOTTOMRIGHT', -4, 4
			end

			t:ClearAllPoints()
			t:Point(point, E.UIParent, point, x, y)
		end)
	end

	local extraInfoBars = {
		f.Ally2,
		f.Ally3,
		f.Enemy2,
		f.Enemy3
	}

	local pixelSpace = E.PixelMode and 1
	for _, infoBar in pairs(extraInfoBars) do
		infoBar:Size(40)
		infoBar:SetTemplate()
		infoBar:ClearAllPoints()
		infoBar.healthBarWidth = 40

		infoBar.BorderAlive:SetAlpha(0)
		infoBar.HealthBarBG:SetAlpha(0)
		infoBar.HealthDivider:SetAlpha(0)
		infoBar.Icon:SetDrawLayer('ARTWORK')
		infoBar.Icon:CreateBackdrop()

		infoBar.ActualHealthBar:SetTexCoord(0, 1, 0, 1)
		infoBar.ActualHealthBar:SetTexture(E.media.normTex)
		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.ActualHealthBar:Point('TOPLEFT', infoBar.Icon, 'BOTTOMLEFT', 0, -(pixelSpace or 5))

		infoBar.ActualHealthBar:CreateBackdrop('Transparent')
		infoBar.ActualHealthBar.backdrop:ClearAllPoints()
		infoBar.ActualHealthBar.backdrop:Point('TOPLEFT', infoBar.Icon.backdrop, 'BOTTOMLEFT', 0, pixelSpace or -1)
		infoBar.ActualHealthBar.backdrop:Point('TOPRIGHT', infoBar.Icon.backdrop, 'BOTTOMRIGHT', 0, pixelSpace or -1)
		infoBar.ActualHealthBar.backdrop:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 0, -(pixelSpace or 2))
	end

	f.Ally2:Point('TOPRIGHT', f.Ally2.iconPoint, 'TOPLEFT', -6, -2)
	f.Ally3:Point('TOPRIGHT', f.Ally2, 'TOPLEFT', -8, 0)
	f.Enemy2:Point('TOPLEFT', f.Enemy2.iconPoint, 'TOPRIGHT', 6, -2)
	f.Enemy3:Point('TOPLEFT', f.Enemy2, 'TOPRIGHT', 8, 0)

	---------------------------------
	-- PET BATTLE ACTION BAR SETUP --
	---------------------------------

	local bar = CreateFrame('Frame', 'ElvUIPetBattleActionBar', f)
	bar:Size (52*6 + 7*10, 52 * 1 + 10*2)
	bar:EnableMouse(true)
	bar:SetTemplate()
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 4)
	bar:SetFrameLevel(2)
	bar:SetFrameStrata('BACKGROUND')

	bf:StripTextures()
	bf.MicroButtonFrame:Kill()
	bf.FlowFrame:StripTextures()
	bf.Delimiter:StripTextures()

	local turnTimer = bf.TurnTimer
	turnTimer:StripTextures()
	turnTimer.SkipButton:SetParent(bar)
	S:HandleButton(turnTimer.SkipButton)

	local SkipOffset = E.PixelMode and -1 or 1
	local XPOffset = E.PixelMode and -1 or 3
	hooksecurefunc(turnTimer.SkipButton, 'SetPoint', function(btn, _, _, _, _, _, forced)
		if forced == true then return end

		btn:ClearAllPoints()
		btn:Point('BOTTOMLEFT', bar, 'TOPLEFT', 0, SkipOffset, true)
		btn:Point('BOTTOMRIGHT', bar, 'TOPRIGHT', 0, SkipOffset, true)

		turnTimer:SetSize(turnTimer.SkipButton:GetSize()) -- set after the skip button points
	end)

	turnTimer:ClearAllPoints()
	turnTimer:Point('TOP', E.UIParent, 'TOP', 0, -140)
	turnTimer.TimerText:Point('CENTER')

	E:RegisterStatusBar(bf.xpBar)
	bf.xpBar:SetParent(bar)
	bf.xpBar:CreateBackdrop()
	bf.xpBar:ClearAllPoints()
	bf.xpBar:Point('BOTTOMLEFT', turnTimer.SkipButton, 'TOPLEFT', E.Border, XPOffset)
	bf.xpBar:Point('BOTTOMRIGHT', turnTimer.SkipButton, 'TOPRIGHT', -E.Border, XPOffset)
	bf.xpBar:SetScript('OnShow', function(s)
		s:StripTextures()
		s:SetStatusBarTexture(E.media.normTex)
	end)

	-- PETS SELECTION SKIN
	for i = 1, 3 do
		local pet = bf.PetSelectionFrame['Pet'..i]

		pet.HealthBarBG:SetAlpha(0)
		pet.HealthDivider:SetAlpha(0)
		pet.ActualHealthBar:SetAlpha(0)
		pet.SelectedTexture:SetAlpha(0)
		pet.MouseoverHighlight:SetAlpha(0)
		pet.Framing:SetAlpha(0)
		pet.Icon:SetAlpha(0)
		pet.Name:SetAlpha(0)
		pet.DeadOverlay:SetAlpha(0)
		pet.Level:SetAlpha(0)
		pet.HealthText:SetAlpha(0)
	end

	-- MOVE DEFAULT POSITION OF PETS SELECTION
	hooksecurefunc('PetBattlePetSelectionFrame_Show', function()
		bf.PetSelectionFrame:ClearAllPoints()
		bf.PetSelectionFrame:Point('BOTTOM', bf.xpBar, 'TOP', 0, 8)
	end)

	hooksecurefunc('PetBattleFrame_UpdateActionBarLayout', function()
		for i=1, _G.NUM_BATTLE_PET_ABILITIES do
			local b = bf.abilityButtons[i]
			SkinPetButton(b, bf)
			b:SetParent(bar)
			b:ClearAllPoints()

			if i == 1 then
				b:Point('BOTTOMLEFT', 10, 10)
			else
				local previous = bf.abilityButtons[i-1]
				b:Point('LEFT', previous, 'RIGHT', 10, 0)
			end
		end

		bf.SwitchPetButton:ClearAllPoints()
		bf.SwitchPetButton:Point('LEFT', bf.abilityButtons[3], 'RIGHT', 10, 0)
		SkinPetButton(bf.SwitchPetButton, bf)
		bf.CatchButton:SetParent(bar)
		bf.CatchButton:ClearAllPoints()
		bf.CatchButton:Point('LEFT', bf.SwitchPetButton, 'RIGHT', 10, 0)
		SkinPetButton(bf.CatchButton, bf)
		bf.ForfeitButton:SetParent(bar)
		bf.ForfeitButton:ClearAllPoints()
		bf.ForfeitButton:Point('LEFT', bf.CatchButton, 'RIGHT', 10, 0)
		SkinPetButton(bf.ForfeitButton, bf)
	end)

	local PetBattleQueueReadyFrame = _G.PetBattleQueueReadyFrame
	PetBattleQueueReadyFrame:StripTextures()
	PetBattleQueueReadyFrame:SetTemplate('Transparent')
	PetBattleQueueReadyFrame.Art:SetTexture([[Interface\PetBattles\PetBattlesQueue]])
	S:HandleButton(PetBattleQueueReadyFrame.AcceptButton)
	S:HandleButton(PetBattleQueueReadyFrame.DeclineButton)
end

S:AddCallback('PetBattleFrame')
