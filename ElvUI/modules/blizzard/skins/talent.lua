local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].talent ~= true then return end

local function LoadSkin()
	local buttons = {
		"PlayerTalentFrameToggleSummariesButton",
		"PlayerTalentFrameActivateButton",
	}
	PlayerTalentFrameToggleSummariesButton:Point("BOTTOM", PlayerTalentFrame, "BOTTOM",0,5)

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		E.SkinButton(_G[buttons[i]])
	end

	local StripAllTextures = {
		"PlayerTalentFrame",
		"PlayerTalentFrameInset",
		"PlayerTalentFrameTalents",
		"PlayerTalentFramePanel1HeaderIcon",
		"PlayerTalentFramePanel2HeaderIcon",
		"PlayerTalentFramePanel3HeaderIcon",
		"PlayerTalentFramePetTalents",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local function StripTalentFramePanelTextures(object)
		for i=1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetName():find("Branch") then
					region:SetDrawLayer("OVERLAY")
				else
					region:SetTexture(nil)
				end
			end
		end
	end

	StripTalentFramePanelTextures(PlayerTalentFramePanel1)
	StripTalentFramePanelTextures(PlayerTalentFramePanel2)
	StripTalentFramePanelTextures(PlayerTalentFramePanel3)
	StripTalentFramePanelTextures(PlayerTalentFramePetPanel)

	for i=1, 3 do
		_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:GetFrameLevel() + 5)
		_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:StripTextures(true)
		E.SkinButton(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])
	end

	local KillTextures = {
		"PlayerTalentFramePanel1InactiveShadow",
		"PlayerTalentFramePanel2InactiveShadow",
		"PlayerTalentFramePanel3InactiveShadow",
		"PlayerTalentFramePanel1SummaryRoleIcon",
		"PlayerTalentFramePanel2SummaryRoleIcon",
		"PlayerTalentFramePanel3SummaryRoleIcon",
		"PlayerTalentFramePetShadowOverlay",
		"PlayerTalentFrameHeaderHelpBox",
	}

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	for i=1, 3 do
		_G["PlayerTalentFramePanel"..i.."Arrow"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."Arrow"]:GetFrameLevel() + 2)
	end
	PlayerTalentFramePetPanelArrow:SetFrameStrata("HIGH")


	PlayerTalentFrame:SetTemplate("Transparent")
	PlayerTalentFramePanel1:CreateBackdrop("Transparent")
	PlayerTalentFramePanel1.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel1, "TOPLEFT", 3, -3 )
	PlayerTalentFramePanel1.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel1, "BOTTOMRIGHT", -3, 3 )
	PlayerTalentFramePanel2:CreateBackdrop("Transparent")
	PlayerTalentFramePanel2.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel2, "TOPLEFT", 3, -3 )
	PlayerTalentFramePanel2.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel2, "BOTTOMRIGHT", -3, 3 )
	PlayerTalentFramePanel3:CreateBackdrop("Transparent")
	PlayerTalentFramePanel3.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel3, "TOPLEFT", 3, -3 )
	PlayerTalentFramePanel3.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel3, "BOTTOMRIGHT", -3, 3 )
	PlayerTalentFrame:CreateShadow("Default")
	E.SkinCloseButton(PlayerTalentFrameCloseButton)

	function talentpairs(inspect,pet)
	   local tab,tal=1,0
	   return function()
		  tal=tal+1
		  if tal>GetNumTalents(tab,inspect,pet) then
			 tal=1
			 tab=tab+1
		  end
		  if tab<=GetNumTalentTabs(inspect,pet) then
			 return tab,tal
		  end
	   end
	end

	--Skin TalentButtons
	local function TalentButtons(self, first, i, j)
		local button = _G["PlayerTalentFramePanel"..i.."Talent"..j]
		local icon = _G["PlayerTalentFramePanel"..i.."Talent"..j.."IconTexture"]

		if first then
			button:StripTextures()
		end
		
		if button.Rank then
			button.Rank:SetFont(C["media"].font, 12, 'THINOUTLINE')
			button.Rank:ClearAllPoints()
			button.Rank:SetPoint("BOTTOMRIGHT")
		end
		
		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			button:StyleButton()
			button.SetHighlightTexture = E.dummy
			button.SetPushedTexture = E.dummy
			button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			
			icon:ClearAllPoints()
			icon:SetAllPoints()
			button:SetFrameLevel(button:GetFrameLevel() +1)
			button:CreateBackdrop("Default", true)
		end
	end

	local function TalentSummaryButtons(self, first, active, i, j)
		if active then
			button = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1"]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1Icon"]
		else
			button = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j]
			icon = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j.."Icon"]
		end

		if first then
			button:StripTextures()
		end

		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			button:SetFrameLevel(button:GetFrameLevel() +1)
			local frame = CreateFrame("Frame",nil, button)
			frame:CreateBackdrop("Default", true)
			frame:SetFrameLevel(button:GetFrameLevel() -1)
			frame:ClearAllPoints()
			frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
			frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
		end
	end

	for i=1, 2 do
		local tab = _G["PlayerSpecTab"..i]
		if tab then
			local a = tab:GetRegions()
			a:Hide()
			tab:StripTextures()
			tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			
			tab:GetNormalTexture():ClearAllPoints()
			tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
			tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)

			tab:CreateBackdrop("Default")
			tab.backdrop:SetAllPoints()
			tab:StyleButton(true)
		end
	end

	--Reposition tabs
	PlayerSpecTab1:ClearAllPoints()
	PlayerSpecTab1:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 2, -32)
	PlayerSpecTab1.SetPoint = E.dummy

	local function TalentSummaryClean(i)
		local frame = _G["PlayerTalentFramePanel"..i.."Summary"]
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:CreateBackdrop("Default")
		frame:SetFrameLevel(frame:GetFrameLevel() +1)
		local a,b,_,d,_,_,_,_,_,_,_,_,m,_ = frame:GetRegions()
		a:Hide()
		b:Hide()
		d:Hide()
		m:Hide()
		
		_G["PlayerTalentFramePanel"..i.."SummaryIcon"]:SetTexCoord(.08, .92, .08, .92)
	end

	local function TalentHeaderIcon(self, first, i)
		local button = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
		local icon = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]
		local panel = _G["PlayerTalentFramePanel"..i]
		local text = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]

		if first then
			button:StripTextures()
		end
		
		_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]:SetFont(C["media"].font, 12, 'THINOUTLINE')

		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			button:SetFrameLevel(button:GetFrameLevel() +1)
			button:ClearAllPoints()
			button:Point("TOPLEFT",panel,"TOPLEFT", 4, -4)
			text:SetFont(C["media"].font, 12, 'THINOUTLINE')
			text:Point("BOTTOMRIGHT",button, "BOTTOMRIGHT", -1, 2)
			local frame = CreateFrame("Frame",nil, button)
			frame:CreateBackdrop("Default", true)
			frame:SetFrameLevel(button:GetFrameLevel() +1)
			frame:ClearAllPoints()
			frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
			frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
		end
	end		

	for i=1, 3 do
		TalentSummaryClean(i)
		TalentHeaderIcon(nil, true, i)
		for j=1, 2 do
			TalentSummaryButtons(nil, true, true, i, j)
			TalentSummaryButtons(nil, true, false, i, j)
		end
	end

	for tab,talent in talentpairs() do
		TalentButtons(nil, true, tab, talent)
	end

	for i=1, 3 do
		E.SkinTab(_G["PlayerTalentFrameTab"..i])
	end

	--PET TALENTS
	E.SkinRotateButton(PlayerTalentFramePetModelRotateLeftButton)
	E.SkinRotateButton(PlayerTalentFramePetModelRotateRightButton)
	PlayerTalentFramePetModelRotateLeftButton:Point("BOTTOM", PlayerTalentFramePetModel, "BOTTOM", -4, 4)
	PlayerTalentFramePetModelRotateRightButton:Point("TOPLEFT", PlayerTalentFramePetModelRotateLeftButton, "TOPRIGHT", 4, 0)
	PlayerTalentFramePetPanel:CreateBackdrop("Transparent")
	PlayerTalentFramePetPanel.backdrop:Point( "TOPLEFT", PlayerTalentFramePetPanel, "TOPLEFT", 3, -3 )
	PlayerTalentFramePetPanel.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePetPanel, "BOTTOMRIGHT", -3, 3 )
	PlayerTalentFramePetModel:CreateBackdrop("Transparent")
	PlayerTalentFramePetModel.backdrop:Point( "TOPLEFT", PlayerTalentFramePetModel, "TOPLEFT")
	PlayerTalentFramePetModel.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePetModel, "BOTTOMRIGHT")
	E.SkinButton(PlayerTalentFrameLearnButton, true)
	E.SkinButton(PlayerTalentFrameResetButton, true)

	local function PetHeaderIcon(self, first)
		local button = _G["PlayerTalentFramePetPanelHeaderIcon"]
		local icon = _G["PlayerTalentFramePetPanelHeaderIconIcon"]
		local panel = _G["PlayerTalentFramePetPanel"]
		local d = select(4, button:GetRegions())

		if first then
			button:StripTextures()
		end

		if icon then
			d:ClearAllPoints()
			pointsSpent = select(5,GetTalentTabInfo( 1, Partycheck, true, 1 ))
			icon:SetTexCoord(.08, .92, .08, .92)
			button:SetFrameLevel(button:GetFrameLevel() +1)
			button:ClearAllPoints()
			button:Point("TOPLEFT",panel,"TOPLEFT", 5, -5)
			local text = button:FontString(nil, C["media"].font, 12, C["media"].fontFLAG)
			text:Point("BOTTOMRIGHT",button, "BOTTOMRIGHT", -1, 2)
			text:SetText(pointsSpent)
			local frame = CreateFrame("Frame",nil, button)
			frame:CreateBackdrop("Default", true)
			frame:SetFrameLevel(button:GetFrameLevel() +1)
			frame:ClearAllPoints()
			frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
			frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
		end
	end

	local function PetInfoIcon(self, first)
		local button = _G["PlayerTalentFramePetInfo"]
		local icon = _G["PlayerTalentFramePetIcon"]
		local panel = _G["PlayerTalentFramePetModel"]

		PlayerTalentFramePetDiet:Hide();

		local petFoodList = { GetPetFoodTypes() };
		if #petFoodList > 0 then
			diet = petFoodList[1]
		else
			diet = "None"
		end

		if first then
			button:StripTextures()
		end

		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			button:SetFrameLevel(button:GetFrameLevel() +1)
			button:ClearAllPoints()
			button:Point("BOTTOMLEFT",panel,"TOPLEFT", 0, 10)
			local text = button:FontString(nil, C["media"].font, 12, C["media"].fontFLAG)
			text:Point("TOPRIGHT",button, "TOPRIGHT", 0, -10)
			text:SetText(diet)
			local frame = CreateFrame("Frame",nil, button)
			frame:CreateBackdrop("Default", true)
			frame:SetFrameLevel(button:GetFrameLevel() +1)
			frame:ClearAllPoints()
			frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
			frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
		end
	end	

	local function PetTalentButtons(self, first, i)
		local button = _G["PlayerTalentFramePetPanelTalent"..i]
		local icon = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]

		if first then
			button:StripTextures()
		end
		
		if button.Rank then
			button.Rank:SetFont(C["media"].font, 12, 'THINOUTLINE')
			button.Rank:ClearAllPoints()
			button.Rank:SetPoint("BOTTOMRIGHT")
		end
		
		if icon then
			button:StyleButton()
			button.SetHighlightTexture = E.dummy
			button.SetPushedTexture = E.dummy
			button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
			button:GetHighlightTexture():SetAllPoints(icon)
			button:GetPushedTexture():SetAllPoints(icon)
			
			icon:SetTexCoord(.08, .92, .08, .92)
			icon:ClearAllPoints()
			icon:SetAllPoints()
			button:SetFrameLevel(button:GetFrameLevel() +1)
			button:CreateBackdrop("Default", true)
		end
	end	

	PetInfoIcon(nil, true)
	PetHeaderIcon(nil, true)
	for i=1,GetNumTalents(1,false,true) do
		PetTalentButtons(nil,true,i)
	end
end

E.SkinFuncs["Blizzard_TalentUI"] = LoadSkin