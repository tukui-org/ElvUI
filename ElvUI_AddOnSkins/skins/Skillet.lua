local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

function SetModifiedBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
end

function SetOriginalBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
end

local function SkinButton(ButtonOrSpellID) -- Thanks to SinaC
	local Skillet = _G.Skillet
	if not ButtonOrSpellID then return end
	local button
		if type(ButtonOrSpellID) == "number" then
			local player = UnitName("player")
			local buttonName = "SkilletFrameTradeButton-"..player.."-"..tostring(ButtonOrSpellID)
			button = _G[buttonName]
		else
			button = ButtonOrSpellID
		end
	if button then
		local texture = button:GetNormalTexture()
			if not texture then
			texture = _G[button:GetName().."Icon"]
	end

	if texture then
		button:SetTemplate("Default", true)
		texture:SetDrawLayer('OVERLAY') -- Make sure we can see the Icons.
		texture:ClearAllPoints()
		texture:Point("TOPLEFT", 2, -2)
		texture:Point("BOTTOMRIGHT", -2, 2)
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetHighlightTexture(nil)
		button:HookScript("OnEnter", SetModifiedBackdrop)
		button:HookScript("OnLeave", SetOriginalBackdrop)
		end
	end
end

local function SkinGuildRecipes(ButtonOrSpellID)
	if not ButtonOrSpellID then return end
	local button
		if type(ButtonOrSpellID) == "number" then
			local buttonName = "SkilletFrameTradeButton-Guild Recipes-"..tostring(ButtonOrSpellID)
			button = _G[buttonName]
		else
			button = ButtonOrSpellID
		end
	if button then
		local texture = button:GetNormalTexture()
			if not texture then
			texture = _G[button:GetName().."Icon"]
			
			button:ClearAllPoints()
			button:SetPoint("BOTTOMLEFT", SkilletRankFrame, "TOPLEFT", 0, 3) --Adjust position.
	end
	
	if texture then
		button:SetTemplate("Default", true)
		texture:SetDrawLayer('OVERLAY') -- Make sure we can see the Icons.
		texture:ClearAllPoints()
		texture:Point("TOPLEFT", 2, -2)
		texture:Point("BOTTOMRIGHT", -2, 2)
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetHighlightTexture(nil)
		button:HookScript("OnEnter", SetModifiedBackdrop)
		button:HookScript("OnLeave", SetOriginalBackdrop)
		end
	end	
end

local function SkinReagentButton(ButtonName)
	if not ButtonName then return end
	local button = ButtonName
	if button then
		local texture = button:GetNormalTexture()
			if not texture then
			texture = _G[button:GetName().."Icon"]
	end

	if texture then
		button:SetTemplate("Default", true)
		texture:SetDrawLayer('OVERLAY') -- Make sure we can see the Icons.
		texture:ClearAllPoints()
		texture:Point("TOPLEFT", 2, -2)
		texture:Point("BOTTOMRIGHT", -2, 2)
		texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		end
	end
end

local function SkinIcon(self)

	if SkilletDoBasic_Campfire then SkinButton(SkilletDoBasic_Campfire) end
	if SkilletDoProspecting    then SkinButton(SkilletDoProspecting)    end
	if SkilletDoDisenchant     then SkinButton(SkilletDoDisenchant)     end
	if SkilletDoMilling        then SkinButton(SkilletDoMilling)        end

	if 2259  then SkinButton(2259)  end -- Alchemy	
	if 2018  then SkinButton(2018)  end -- Blacksmithing
	if 7411  then SkinButton(7411)  end -- Enchanting
	if 4036  then SkinButton(4036)  end -- Engineering	
	if 45357 then SkinButton(45357) end -- Inscription
	if 25229 then SkinButton(25229) end -- Jewelcrafting
	if 2108  then SkinButton(2108)  end -- Leatherworking
	if 2656  then SkinButton(2656)  end -- Smelting
	if 3908  then SkinButton(3908)  end -- Tailoring
	if 2550  then SkinButton(2550)  end -- Cooking	
	if 3273  then SkinButton(3273)  end -- Firstaid
	if 53428 then SkinButton(53428) end -- Runeforging

	local icon = _G["SkilletHideUncraftableRecipes"]
	icon:SetScript("OnUpdate", nil)

	SkinButton(SkilletHideUncraftableRecipes)
	SkinButton(SkilletRecipeDifficultyButton)
	SkinButton(SkilletExpandAllButton)
	SkinButton(SkilletCollapseAllButton)
	S:HandleButton(SkilletShowOptionsButton)
	SkilletShowOptionsButton:SetHeight(16)
	SkilletShowOptionsButton:SetWidth(12)
	SkilletShowOptionsButton:SetPoint("RIGHT", SkilletFrameCloseButton, "LEFT", 3, 0)
	
	if not SkilletShowOptionsButton.text then
		SkilletShowOptionsButton.text = SkilletShowOptionsButton:CreateFontString(nil, 'OVERLAY')
	
		SkilletShowOptionsButton.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 12, 'OUTLINE')
		SkilletShowOptionsButton.text:SetText(" ?")
		SkilletShowOptionsButton.text:SetTextColor(1, 0, 0)	
		SkilletShowOptionsButton.text:SetJustifyH('CENTER')
		SkilletShowOptionsButton.text:SetPoint('CENTER', SkilletShowOptionsButton, 'CENTER')
	end
end

local function SkinShopping(self)
	SkilletShoppingList:StripTextures()
	SkilletShoppingList:SetTemplate("Transparent")
	SkilletShoppingListParent:StripTextures()
	SkilletShoppingListParent:SetTemplate("Default")
	S:HandleCloseButton(SkilletShoppingListCloseButton)
	S:HandleCheckBox(SkilletShowQueuesFromAllAlts)
	S:HandleScrollBar(SkilletShoppingListListScrollBar)
end

local function SkinPluginButtons(self)

		if SkilletPluginDropdown1 then
			S:HandleButton(_G["SkilletPluginDropdown1"])
		end
		if SkilletPluginDropdown2 then
			S:HandleButton(_G["SkilletPluginDropdown2"])
		end
end	

local function SkilletFrameOnShow(self)
	
	local StripAllTextures = {
				"SkilletFrame",
				"SkilletSkillListParent",
				"SkilletReagentParent",
				"SkilletQueueParent",
				"SkilletRecipeNotesFrame",
				"SkilletQueueManagementParent",
				"SkilletSkillTooltip",
				"SkilletStandalonQueue",
				"SkilletViewCraftersParent",
				}
				
		for _, object in pairs(StripAllTextures) do
					_G[object]:StripTextures()
		end	

	local SetTemplateD = {
				"SkilletSkillListParent",
				"SkilletReagentParent",
				"SkilletQueueParent",
				"SkilletQueueManagementParent",
				"SkilletViewCraftersParent",
				}

	local SetTemplateT = {
				"SkilletFrame",
				"SkilletRecipeNotesFrame",
				"SkilletSkillTooltip",
				"SkilletStandalonQueue",
				}	
				
		for _, object in pairs(SetTemplateD) do
					_G[object]:SetTemplate("Default")
		end	

		for _, object in pairs(SetTemplateT) do
					_G[object]:SetTemplate("Transparent")
		end	

		S:HandleCloseButton(SkilletNotesCloseButton)

		SkilletSkillListParent:SetPoint("TOPLEFT", SkilletFrame, "TOPLEFT", 5, -100)
		SkilletRankFrame:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -57)
		SkilletRankFrameRed:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -70)
		SkilletRankFrameOrange:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -70)
		SkilletRankFrameYellow:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -70)
		SkilletRankFrameGreen:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -70)
		SkilletRankFrameGray:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", -12, -70)
		SkilletRecipeGroupDropdown:SetPoint("BOTTOMLEFT", SkilletSkillListParent, "TOPLEFT", 45, 43)
		SkilletRecipeGroupOperations:SetPoint("LEFT", SkilletRecipeGroupDropdownButton, "RIGHT", 4, 0)
		SkilletSortAscButton:SetPoint("LEFT", SkilletSortDropdownButton, "RIGHT", 4, 0)
		SkilletSortDescButton:SetPoint("LEFT", SkilletSortDropdownButton, "RIGHT", 4, 0)
		SkilletSearchFilterClear:SetPoint("LEFT", SkilletFilterBox, "RIGHT", -2, 0)
		SkilletQueueSaveButton:SetPoint("LEFT", SkilletQueueSaveEditBox, "RIGHT", 5, 0)
		SkilletQueueLoadButton:SetPoint("LEFT", SkilletQueueLoadDropdownButton, "RIGHT", 5, 0)
		SkilletQueueDeleteButton:SetPoint("LEFT", SkilletQueueLoadButton, "RIGHT", 2, 0)
		SkilletHideUncraftableRecipes:SetPoint("BOTTOMRIGHT", SkilletSkillListParent, "TOPRIGHT", -5, 5)
		SkilletFrameCloseButton:ClearAllPoints()
		SkilletFrameCloseButton:SetPoint("TOPRIGHT", SkilletFrame, "TOPRIGHT", 0, 0)
		SkilletTradeSkillLinkButton:SetPoint("RIGHT", SkilletShowOptionsButton, "LEFT", 0, 0)
		SkilletViewCraftersButton:SetPoint("RIGHT", SkilletQueueManagementButton, "LEFT", -5, 0)
		
		SkilletTradeskillTooltip:StripTextures()
		SkilletTradeskillTooltip:SetTemplate("Default")

		S:HandleScrollBar(SkilletQueueListScrollBar)

	for i=1,3 do
		local queDelete = _G["SkilletQueueButton"..i.."DeleteButton"]
			S:HandleButton(queDelete)
			queDelete:SetWidth(14)
			queDelete:SetHeight(14)
	end

	if Enchantrix_BarkerOptions_Frame then
		Enchantrix_BarkerOptions_Frame:StripTextures()
		Enchantrix_BarkerOptions_Frame:SetTemplate("Default")
		Enchantrix_BarkerOptions_Frame:SetHeight(480)

		for i=1,4 do 
			tabs = _G["Enchantrix_BarkerOptions_FrameTab"..i]
				S:HandleTab(tabs)
		end

		Enchantrix_BarkerOptions_FrameTab1:ClearAllPoints()
		Enchantrix_BarkerOptions_FrameTab1:SetPoint("TOPLEFT", Enchantrix_BarkerOptions_Frame, "BOTTOMLEFT", 11, 1)
		Enchantrix_BarkerOptions_CloseButton:SetPoint("TOPRIGHT", Enchantrix_BarkerOptions_Frame, "TOPRIGHT", -5, -2)

		S:HandleButton(Enchantrix_BarkerOptionsBark_Button)
		S:HandleButton(Enchantrix_BarkerOptionsReset_Button)
		S:HandleButton(Enchantrix_BarkerOptionsTest_Button)

		S:HandleCloseButton(Enchantrix_BarkerOptions_CloseButton)
	end
end

local function SkinReagentIcon(self, event, ...)
	
	local ReagentIcons = {
		"SkilletSkillIcon",
		"SkilletReagent1Icon",
		"SkilletReagent2Icon",
		"SkilletReagent3Icon",
		"SkilletReagent4Icon",
		"SkilletReagent5Icon",
		"SkilletReagent6Icon",
		"SkilletReagent7Icon",
		"SkilletReagent8Icon",
		"SkilletReagent9Icon",
		"SkilletReagent10Icon", -- Is there only 10?
		}

		for _, button in pairs(ReagentIcons) do
						SkinReagentButton(_G[button])
		end	
	
end

local function SkilletFrameOnUpdate(self, event, ...)
	local Skillet = _G.Skillet

	SkilletRecipeNotesButton:SetPoint("BOTTOMRIGHT", SkilletReagentParent, "TOPRIGHT", 0, 2)
	SkilletQueueManagementButton:SetPoint("RIGHT", SkilletRecipeNotesButton, "LEFT", -5, 0)
	SkilletItemCountInputBox:SetPoint("BOTTOM", SkilletCreateCountSlider, "TOP", 0, 2)	

	if SkilletDoBasic_Campfire then -- cooking = basic campfire
		SkilletDoBasic_Campfire:ClearAllPoints()
		SkilletDoBasic_Campfire:SetPoint("BOTTOMRIGHT", SkilletRankFrame, "TOPRIGHT", 0, 3)
	end
	if SkilletDoDisenchant then
		SkilletDoDisenchant:ClearAllPoints()-- enchanting = disenchant
		SkilletDoDisenchant:SetPoint("BOTTOMRIGHT", SkilletRankFrame, "TOPRIGHT", -26, 3)
	end	
	if SkilletDoProspecting then -- jewelcrafting = prospecting
		SkilletDoProspecting:ClearAllPoints()
		SkilletDoProspecting:SetPoint("BOTTOMRIGHT", SkilletRankFrame, "TOPRIGHT", -52, 3)
	end
	if SkilletDoMilling then -- inscription = milling
		SkilletDoMilling:ClearAllPoints()
		SkilletDoMilling:SetPoint("BOTTOMRIGHT", SkilletRankFrame, "TOPRIGHT", -78, 3)
	end
	
	SkinGuildRecipes(2259) -- Alchemy
	SkinGuildRecipes(2018) -- Blacksmithing
	SkinGuildRecipes(7411) -- Enchanting
	SkinGuildRecipes(4036) -- Engineering
	SkinGuildRecipes(45357)-- Inscription
	SkinGuildRecipes(25229)-- Jewelcrafting
	SkinGuildRecipes(2108) -- Leatherworking
	SkinGuildRecipes(2656) -- Smelting
	SkinGuildRecipes(3908) -- Tailoring
	SkinGuildRecipes(53428)-- Runeforging
	SkinGuildRecipes(3273) -- Firstaid
	SkinGuildRecipes(2550) -- Cooking
	
	x = 0
	local player = UnitName("player")
	icon = "SkilletFrameTradeButtons-"..player
	template = "SkilletTradeButtonTemplate"
	local tradeSkillList = Skillet.tradeSkillList
	local nonLinkingTrade = { [2656] = true, [53428] = true }
	for i=1,#tradeSkillList,1 do
		local tradeID = Skillet.tradeSkillList[i]
		local ranks = Skillet:GetSkillRanks(player, tradeID)
		local tradeLink

		if Skillet.db.realm.linkDB[player] then
			tradeLink = Skillet.db.realm.linkDB[player][tradeID]

			if nonLinkingTrade[tradeID] then
				tradeLink = nil
			end
		end
		
		if ranks then
			local spellName, _, spellIcon = GetSpellInfo(tradeID)
			local buttonName = "SkilletFrameTradeButton-"..player.."-"..tradeID
			local bName = _G[buttonName]
				if not bName then
					bName = CreateFrame("CheckButton",bName,nil,UIParent)--CreateFrame("CheckButton", buttonName, frame, "SkilletTradeButtonTemplate")
				end 
			bName:ClearAllPoints()
			bName:SetPoint("BOTTOMLEFT", SkilletRankFrame, "TOPLEFT", x, 3)
			x = x + bName:GetWidth() + 1
		end
	end

	if SkilletQueueButton13DeleteButton then
		for i=1,13 do
			local queDelete = _G["SkilletQueueButton"..i.."DeleteButton"]
			S:HandleButton(queDelete)
			queDelete:SetWidth(14)
			queDelete:SetHeight(14)
		end
	end
end

local name = "SkilletSkin"
local function SkinSkillet(Self)
		local buttons = {
			"SkilletQueueAllButton",
			"SkilletCreateAllButton",
			"SkilletQueueButton",
			"SkilletCreateButton",
			"SkilletQueueManagementButton",
			"SkilletPluginButton",
			"SkilletShoppingListButton",
			"SkilletEmptyQueueButton",
			"SkilletStartQueueButton",
			"SkilletQueueOnlyButton",
			"SkilletQueueLoadButton",
			"SkilletQueueDeleteButton",
			"SkilletQueueSaveButton",
			"SkilletRecipeNotesButton",
			"SkilletViewCraftersButton",
			"SkilletMerchantBuyFrameButton",
		}

		for _, button in pairs(buttons) do
			S:HandleButton(_G[button])
		end	

		S:HandleCloseButton(SkilletFrameCloseButton)
		S:HandleCloseButton(SkilletStandalonQueueCloseButton)

		S:HandleDropDownBox(SkilletRecipeGroupDropdown)
		S:HandleDropDownBox(SkilletSortDropdown)
		S:HandleDropDownBox(SkilletQueueLoadDropdown)

		AS:Desaturate(SkilletSearchFilterClear)

		SkilletSortAscButton:StripTextures()
		SkilletSortAscButton:SetTemplate("Default", true)
		if not SkilletSortAscButton.texture then
			SkilletSortAscButton.texture = SkilletSortAscButton:CreateTexture(nil, 'OVERLAY')
			SkilletSortAscButton.texture:Point("TOPLEFT", 2, -2)
			SkilletSortAscButton.texture:Point("BOTTOMRIGHT", -2, 2)
			SkilletSortAscButton.texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrowup.tga]])
			SkilletSortAscButton.texture:SetVertexColor(unpack(E["media"].bordercolor))
		end

		SkilletSortDescButton:StripTextures()
		SkilletSortDescButton:SetTemplate("Default", true)
		if not SkilletSortDescButton.texture then
			SkilletSortDescButton.texture = SkilletSortDescButton:CreateTexture(nil, 'OVERLAY')
			SkilletSortDescButton.texture:Point("TOPLEFT", 2, -2)
			SkilletSortDescButton.texture:Point("BOTTOMRIGHT", -2, 2)
			SkilletSortDescButton.texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrowdown.tga]])
			SkilletSortDescButton.texture:SetVertexColor(unpack(E["media"].bordercolor))
		end

		S:HandleNextPrevButton(SkilletRecipeGroupOperations)

		S:HandleEditBox(SkilletItemCountInputBox)
		S:HandleEditBox(SkillButtonNameEdit)
		S:HandleEditBox(GroupButtonNameEdit)
		S:HandleEditBox(SkilletFilterBox)
		SkilletFilterBox:SetHeight(20)
		S:HandleEditBox(SkilletQueueSaveEditBox)
	
		SkilletRankFrameBorder:StripTextures()
		AS:SkinStatusBar(SkilletRankFrame)
		SkilletRankFrame:SetHeight(10)		
	
		S:HandleScrollBar(SkilletSkillListScrollBar, 5)

		local SkilletOnload = _G["SkilletSkillListParent"]
		SkilletOnload:SetScript("OnShow", SkilletFrameOnShow)

		local SkilletOnUpdate = _G["SkilletSkillListParent"]
		SkilletOnUpdate:SetScript("OnUpdate", SkilletFrameOnUpdate)

		local Shopping = _G["SkilletShoppingList"]
		Shopping:SetScript("OnShow", SkinShopping)

		local icon = _G["SkilletHideUncraftableRecipes"]
		icon:SetScript("OnUpdate", SkinIcon)
		local reagent = _G["SkilletReagentParent"]
		reagent:SetScript("OnUpdate", SkinReagentIcon)

		local plugin = _G["SkilletPluginButton"]
		plugin:SetScript("PostClick", SkinPluginButtons)
end
AS:RegisterSkin(name,SkinSkillet)