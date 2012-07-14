local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function LoadSkin()
	local f = PetBattleFrame
	local infoBars = {
		f.ActiveAlly,
		f.ActiveEnemy
	}

	-- GENERAL
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
		
		infoBar.PetType:ClearAllPoints()
		infoBar.ActualHealthBar:ClearAllPoints()
		infoBar.Name:ClearAllPoints()
		if index == 1 then
			infoBar.PetType:SetPoint("TOPRIGHT", 162, -35)
			infoBar.HealthBarBackdrop:Point('TOPLEFT', infoBar.ActualHealthBar, 'TOPLEFT', -2, 2)
			infoBar.HealthBarBackdrop:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'BOTTOMLEFT', -2, -2)
			infoBar.ActualHealthBar:SetVertexColor(171/255, 214/255, 116/255)	
			f.Ally2.iconPoint = infoBar.IconBackdrop
			f.Ally3.iconPoint = infoBar.IconBackdrop
			
			infoBar.ActualHealthBar:Point('BOTTOMLEFT', infoBar.Icon, 'BOTTOMRIGHT', 10, 0)		
			infoBar.Name:Point('BOTTOMLEFT', infoBar.ActualHealthBar, 'TOPLEFT', 0, 10)
		else
			infoBar.PetType:SetPoint("TOPLEFT", -162, -35)
			infoBar.HealthBarBackdrop:Point('TOPRIGHT', infoBar.ActualHealthBar, 'TOPRIGHT', 2, 2)
			infoBar.HealthBarBackdrop:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, 'BOTTOMRIGHT', 2, -2)
			infoBar.ActualHealthBar:SetVertexColor(196/255,  30/255,  60/255)
			f.Enemy2.iconPoint = infoBar.IconBackdrop
			f.Enemy3.iconPoint = infoBar.IconBackdrop	

			infoBar.ActualHealthBar:Point('BOTTOMRIGHT', infoBar.Icon, 'BOTTOMLEFT', -10, 0)
			infoBar.Name:Point('BOTTOMRIGHT', infoBar.ActualHealthBar, 'TOPRIGHT', 0, 10)			
		end
		
		infoBar.HealthText:ClearAllPoints()
		infoBar.HealthText:SetPoint('CENTER', infoBar.ActualHealthBar, 'CENTER')
		
		
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
	

	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
		self.Icon:SetTexCoord(unpack(E.TexCoords))
	end)


	f.TopVersusText:ClearAllPoints()
	f.TopVersusText:SetPoint("TOP", f, "TOP", 0, -42)

	PetBattlePrimaryAbilityTooltip:StripTextures()
	PetBattlePrimaryAbilityTooltip:SetTemplate('Transparent')
	PetBattlePrimaryUnitTooltip:StripTextures()
	PetBattlePrimaryUnitTooltip:SetTemplate('Transparent')

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
	f.Enemy3:SetPoint('TOPLEFT', f.Ally2, 'TOPRIGHT', 8, 0)
end

S:RegisterSkin('ElvUI', LoadSkin)