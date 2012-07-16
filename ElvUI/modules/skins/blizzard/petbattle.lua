local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.petbattleui ~= true then return end
	local f = PetBattleFrame
	local bf = f.BottomFrame
	local infoBars = {
		f.ActiveAlly,
		f.ActiveEnemy
	}

	-- TOP FRAMES
	f:StripTextures()

	for index, infoBar in pairs(infoBars) do
		infoBar.Border:SetAlpha(0)
		infoBar.Border2:SetAlpha(0)
		infoBar.healthBarWidth = 300
		
		infoBar.IconBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.IconBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)
		infoBar.IconBackdrop:SetOutside(infoBar.Icon)
		infoBar.IconBackdrop:SetTemplate()
		
		infoBar.HealthBarBG:Kill()
		infoBar.HealthBarFrame:Kill()
		infoBar.HealthBarBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.HealthBarBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)
		infoBar.HealthBarBackdrop:SetTemplate("Transparent")	
		infoBar.HealthBarBackdrop:Width(infoBar.healthBarWidth + 4)
		infoBar.ActualHealthBar:SetTexture(E.media.normTex)
		
		infoBar.PetTypeFrame = CreateFrame("Frame", nil, infoBar)
		infoBar.PetTypeFrame:Size(100, 23)
		infoBar.PetTypeFrame.text = infoBar.PetTypeFrame:CreateFontString(nil, 'OVERLAY')
		infoBar.PetTypeFrame.text:FontTemplate()
		infoBar.PetTypeFrame.text:SetText("")
	
		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.Name:ClearAllPoints()
		
		infoBar.FirstAttack = infoBar:CreateTexture(nil, "ARTWORK")
		infoBar.FirstAttack:Size(30)
		infoBar.FirstAttack:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")		
		if index == 1 then
			infoBar.HealthBarBackdrop:Point('TOPLEFT', infoBar.ActualHealthBar, 'TOPLEFT', -2, 2)
			infoBar.HealthBarBackdrop:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'BOTTOMLEFT', -2, -2)
			infoBar.ActualHealthBar:SetVertexColor(171/255, 214/255, 116/255)	
			f.Ally2.iconPoint = infoBar.IconBackdrop
			f.Ally3.iconPoint = infoBar.IconBackdrop
			
			infoBar.ActualHealthBar:Point('BOTTOMLEFT', infoBar.Icon, 'BOTTOMRIGHT', 10, 0)		
			infoBar.Name:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'TOPLEFT', 0, 10)
			infoBar.PetTypeFrame:SetPoint("BOTTOMRIGHT",infoBar.HealthBarBackdrop, "TOPRIGHT", 0, 4)
			infoBar.PetTypeFrame.text:SetPoint("RIGHT")			
			
			infoBar.FirstAttack:SetPoint("LEFT", infoBar.HealthBarBackdrop, "RIGHT", 5, 0)
			infoBar.FirstAttack:SetTexCoord(infoBar.SpeedIcon:GetTexCoord())
			infoBar.FirstAttack:SetVertexColor(.1,.1,.1,1)
		
		else
			infoBar.HealthBarBackdrop:Point('TOPRIGHT', infoBar.ActualHealthBar, 'TOPRIGHT', 2, 2)
			infoBar.HealthBarBackdrop:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, 'BOTTOMRIGHT', 2, -2)
			infoBar.ActualHealthBar:SetVertexColor(196/255,  30/255,  60/255)
			f.Enemy2.iconPoint = infoBar.IconBackdrop
			f.Enemy3.iconPoint = infoBar.IconBackdrop	

			infoBar.ActualHealthBar:Point('BOTTOMRIGHT', infoBar.Icon, 'BOTTOMLEFT', -10, 0)
			infoBar.Name:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, 'TOPRIGHT', 0, 10)		

			infoBar.PetTypeFrame:SetPoint("BOTTOMLEFT",infoBar.HealthBarBackdrop, "TOPLEFT", 2, 4)
			infoBar.PetTypeFrame.text:SetPoint("LEFT")			
			
			infoBar.FirstAttack:SetPoint("RIGHT", infoBar.HealthBarBackdrop, "LEFT", -5, 0)
			infoBar.FirstAttack:SetTexCoord(.5, 0, .5, 1)
			infoBar.FirstAttack:SetVertexColor(.1,.1,.1,1)			
		end
		
		infoBar.HealthText:ClearAllPoints()
		infoBar.HealthText:SetPoint('CENTER', infoBar.HealthBarBackdrop, 'CENTER')
		
		infoBar.PetType:ClearAllPoints()
		infoBar.PetType:SetAllPoints(infoBar.PetTypeFrame)
		infoBar.PetType:SetFrameLevel(infoBar.PetTypeFrame:GetFrameLevel() + 2)
		infoBar.PetType:SetAlpha(0)		
		
		infoBar.LevelUnderlay:SetAlpha(0)
		infoBar.Level:SetFontObject(NumberFont_Outline_Huge)
		infoBar.Level:ClearAllPoints()
		infoBar.Level:Point('BOTTOMLEFT', infoBar.Icon, 'BOTTOMLEFT', 2, 2)
		if infoBar.SpeedIcon then
			infoBar.SpeedIcon:ClearAllPoints()
			infoBar.SpeedIcon:SetPoint("CENTER") -- to set
			infoBar.SpeedIcon:SetAlpha(0)
			infoBar.SpeedUnderlay:SetAlpha(0)		
		end
	end
	
	-- PETS SPEED INDICATOR UPDATE
	hooksecurefunc("PetBattleFrame_UpdateSpeedIndicators", function(self)
		if not f.ActiveAlly.SpeedIcon:IsShown() and not f.ActiveEnemy.SpeedIcon:IsShown() then
			f.ActiveAlly.FirstAttack:SetVertexColor(.1,.1,.1,1)
			f.ActiveEnemy.FirstAttack:SetVertexColor(.1,.1,.1,1)
			return
		end

		for i, infoBar in pairs(infoBars) do
			if infoBar.SpeedIcon:IsShown() then
				infoBar.FirstAttack:SetVertexColor(0,1,0,1)
			else
				infoBar.FirstAttack:SetVertexColor(.8,0,.3,1)
			end
		end
	end)
	
	-- PETS UNITFRAMES PET TYPE UPDATE
	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
		if self.PetType then
			local petType = C_PetBattles.GetPetType(self.petOwner, self.petIndex)
			if self.PetTypeFrame then
				self.PetTypeFrame.text:SetText(PET_TYPE_SUFFIX[petType])
			end
		end
	end)	
		
	-- PETS UNITFRAMES AURA SKINS
	hooksecurefunc("PetBattleAuraHolder_Update", function(self)
		if not self.petOwner or not self.petIndex then return end

		-- skin buffs and debuffs
		for i=1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local frame = self.frames[i]
			if frame then
				local isBuff = select(4, C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i))

				-- auras are stretched, fix it
				frame:Width(frame:GetHeight())

				-- always hide the border
				frame.DebuffBorder:Hide()

				-- move duration inside
				frame.Duration:FontTemplate(E.media.font, 10, "OUTLINE")
				frame.Duration:ClearAllPoints()
				frame.Duration:SetPoint("TOP", frame, "TOP", 1, -8)

				if not frame.isSkinned then
					frame:CreateBackdrop()
					frame.backdrop:SetInside(frame, 4, 4)
					frame.Icon:SetTexCoord(unpack(E.TexCoords))
					frame.Icon:SetInside(frame.backdrop)
					frame.Icon:SetParent(frame.backdrop)
				end

				if isBuff then
					frame.backdrop:SetBackdropBorderColor(0, 1, 0)
				else
					frame.backdrop:SetBackdropBorderColor(1, 0, 0)
				end
			end
		end
	end)	
		
	-- WEATHER
	hooksecurefunc("PetBattleWeatherFrame_Update", function(self)
		local weather = C_PetBattles.GetAuraInfo(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, 1)
		if weather then
			self.Icon:Hide()
			self.Name:Hide()
			self.DurationShadow:Hide()
			self.Label:Hide()
			self.Duration:SetPoint("CENTER", self, 0, 8)
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, 0, -15)
		end
	end)	

	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
		self.Icon:SetTexCoord(unpack(E.TexCoords))
	end)

	f.TopVersusText:ClearAllPoints()
	f.TopVersusText:SetPoint("TOP", f, "TOP", 0, -42)

	-- TOOLTIPS SKINNING
	PetBattlePrimaryAbilityTooltip.Background:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.Delimiter1:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.Delimiter2:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderTop:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderTopLeft:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderTopRight:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderLeft:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderRight:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderBottom:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderBottomRight:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip.BorderBottomLeft:SetTexture(nil)
	PetBattlePrimaryAbilityTooltip:SetTemplate()

	PetBattlePrimaryUnitTooltip.Delimiter:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.Background:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderTop:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderTopLeft:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderTopRight:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderLeft:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderRight:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderBottom:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderBottomRight:SetTexture(nil)
	PetBattlePrimaryUnitTooltip.BorderBottomLeft:SetTexture(nil)
	PetBattlePrimaryUnitTooltip:SetTemplate("Transparent")
		
	-- TOOLTIP DEFAULT POSITION
	hooksecurefunc("PetBattleAbilityTooltip_Show", function()
		local t = PetBattlePrimaryAbilityTooltip
		t:ClearAllPoints()
		t:SetPoint("TOPRIGHT", E.UIParent, "TOPRIGHT", -4, -4)
	end)
	

	local extraInfoBars = {
		f.Ally2,
		f.Ally3,
		f.Enemy2,
		f.Enemy3
	}	
	
	for index, infoBar in pairs(extraInfoBars) do
		infoBar.BorderAlive:SetAlpha(0)
		infoBar.HealthBarBG:SetAlpha(0)
		infoBar.HealthDivider:SetAlpha(0)	
		infoBar:Size(40)
		infoBar:CreateBackdrop()
		infoBar:ClearAllPoints()		
		
		infoBar.healthBarWidth = 40
		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.ActualHealthBar:SetPoint("TOPLEFT", infoBar.backdrop, 'BOTTOMLEFT', 2, -3)	
		
		infoBar.HealthBarBackdrop = CreateFrame("Frame", nil, infoBar)
		infoBar.HealthBarBackdrop:SetFrameLevel(infoBar:GetFrameLevel() - 1)
		infoBar.HealthBarBackdrop:SetTemplate("Default")	
		infoBar.HealthBarBackdrop:Width(infoBar.healthBarWidth + 4)	
		infoBar.HealthBarBackdrop:Point('TOPLEFT', infoBar.ActualHealthBar, 'TOPLEFT', -2, 2)
		infoBar.HealthBarBackdrop:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'BOTTOMLEFT', -2, -1)		
	end
	
	f.Ally2:SetPoint("TOPRIGHT", f.Ally2.iconPoint, "TOPLEFT", -6, -2)
	f.Ally3:SetPoint('TOPRIGHT', f.Ally2, 'TOPLEFT', -8, 0)
	f.Enemy2:SetPoint("TOPLEFT", f.Enemy2.iconPoint, "TOPRIGHT", 6, -2)
	f.Enemy3:SetPoint('TOPLEFT', f.Enemy2, 'TOPRIGHT', 8, 0)
	
	---------------------------------
	-- PET BATTLE ACTION BAR SETUP --
	---------------------------------

	local bar = CreateFrame("Frame", "ElvUIPetBattleActionBar", f)
	bar:SetSize (52*6 + 7*10, 52 * 1 + 10*2)
	bar:EnableMouse(true)
	bar:SetTemplate()
	bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 4)
	bar:SetFrameLevel(0)
	bar:SetFrameStrata('BACKGROUND')
	bar.backdropTexture:SetDrawLayer('BACKGROUND', 0)
	
	bf:StripTextures()
	bf.TurnTimer:StripTextures()
	bf.TurnTimer.SkipButton:SetParent(bar)
	S:HandleButton(bf.TurnTimer.SkipButton)
			
	bf.TurnTimer.SkipButton:Width(bar:GetWidth())
	bf.TurnTimer.SkipButton:ClearAllPoints()
	bf.TurnTimer.SkipButton:SetPoint("BOTTOM", bar, "TOP", 0, 1)
	bf.TurnTimer.SkipButton.ClearAllPoints = E.noop
	bf.TurnTimer.SkipButton.SetPoint = E.noop

	bf.TurnTimer:Size(bf.TurnTimer.SkipButton:GetWidth(), bf.TurnTimer.SkipButton:GetHeight())
	bf.TurnTimer:ClearAllPoints()
	bf.TurnTimer:SetPoint("TOP", UIParent, "TOP", 0, -140)
	bf.TurnTimer.TimerText:SetPoint("CENTER")	
	
	bf.FlowFrame:StripTextures()
	bf.MicroButtonFrame:Kill()
	bf.Delimiter:StripTextures()
	bf.xpBar:SetParent(bar)
	bf.xpBar:Width(bar:GetWidth() - 4)
	bf.xpBar:CreateBackdrop()
	bf.xpBar:ClearAllPoints()
	bf.xpBar:SetPoint("BOTTOM", bf.TurnTimer.SkipButton, "TOP", 0, 3)
	bf.xpBar:SetScript("OnShow", function(self) self:StripTextures() self:SetStatusBarTexture(E.media.normTex) end)

	-- PETS SELECTION SKIN
	for i = 1, 3 do
		local pet = bf.PetSelectionFrame["Pet"..i]

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
	hooksecurefunc("PetBattlePetSelectionFrame_Show", function()
		bf.PetSelectionFrame:ClearAllPoints()
		bf.PetSelectionFrame:SetPoint("BOTTOM", bf.xpBar, "TOP", 0, 8)
	end)

		
	local function SkinPetButton(self)
		if not self.backdrop then
			self:CreateBackdrop()
		end
		self:SetNormalTexture("")
		self.Icon:SetTexCoord(unpack(E.TexCoords))
		self.Icon:SetParent(self.backdrop)
		self.Icon:SetDrawLayer('BORDER')
		self.checked = true -- avoid create a check
		self:StyleButton()
		self.SelectedHighlight:SetAlpha(0)
		self.pushed:SetInside(self.backdrop)
		self.hover:SetInside(self.backdrop)
		self:SetFrameStrata('LOW')
		self.backdrop:SetFrameStrata('LOW')
	end

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
		for i=1, NUM_BATTLE_PET_ABILITIES do
			local b = bf.abilityButtons[i]
			SkinPetButton(b)
			b:SetParent(bar)
			b:ClearAllPoints()
			if i == 1 then
				b:SetPoint("BOTTOMLEFT", 10, 10)
			else
				local previous = bf.abilityButtons[i-1]
				b:SetPoint("LEFT", previous, "RIGHT", 10, 0)
			end
		end

		bf.SwitchPetButton:ClearAllPoints()
		bf.SwitchPetButton:SetPoint("LEFT", bf.abilityButtons[3], "RIGHT", 10, 0)
		SkinPetButton(bf.SwitchPetButton)
		bf.CatchButton:SetParent(bar)
		bf.CatchButton:ClearAllPoints()
		bf.CatchButton:SetPoint("LEFT", bf.SwitchPetButton, "RIGHT", 10, 0)
		SkinPetButton(bf.CatchButton)
		bf.ForfeitButton:SetParent(bar)
		bf.ForfeitButton:ClearAllPoints()
		bf.ForfeitButton:SetPoint("LEFT", bf.CatchButton, "RIGHT", 10, 0)
		SkinPetButton(bf.ForfeitButton)
	end)	
end

S:RegisterSkin('ElvUI', LoadSkin)