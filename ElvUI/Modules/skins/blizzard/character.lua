local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack, select = unpack, select
local pairs, ipairs, type = pairs, ipairs, type
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetFactionInfo = GetFactionInfo
local GetNumFactions = GetNumFactions
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PAPERDOLL_SIDEBARS, PAPERDOLL_STATINFO, PAPERDOLL_STATCATEGORIES, NUM_GEARSET_ICONS_SHOWN
-- GLOBALS: PaperDollFrame_SetItemLevel, MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY, NUM_FACTIONS_DISPLAYED

local PLACEINBAGS_LOCATION = 0xFFFFFFFF;
local IGNORESLOT_LOCATION = 0xFFFFFFFE;
local UNIGNORESLOT_LOCATION = 0xFFFFFFFD;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	S:HandleCloseButton(CharacterFrameCloseButton)
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)
	S:HandleScrollBar(TokenFrameContainerScrollBar)
	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

	-- Azerite Items
	local function UpdateAzeriteItem(self)
		if not self.styled then
			self.AzeriteTexture:SetAlpha(0)
			self.RankFrame.Texture:SetTexture("")
			self.RankFrame.Label:FontTemplate(nil, nil, "OUTLINE")

			self.styled = true
		end
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:GetHighlightTexture():SetAllPoints()
	end

	local function UpdateAzeriteEmpoweredItem(self)
		self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
		self.AzeriteTexture:SetAllPoints()
		self.AzeriteTexture:SetDrawLayer("BORDER", 1)
	end

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	}

	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"]
		local cooldown = _G["Character"..slot.."Cooldown"]
		slot = _G["Character"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
		slot:SetTemplate("Default", true)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if(cooldown) then
			E:RegisterCooldown(cooldown)
		end

		hooksecurefunc(slot.IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(slot.IconBorder, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)

		hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
		hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
	end

	-- Give character frame model backdrop it's color back
	for _, corner in pairs({"TopLeft","TopRight","BotLeft","BotRight"}) do
		local bg = _G["CharacterModelFrameBackground"..corner];
		if bg then
			bg:SetDesaturated(false);
			bg.ignoreDesaturated = true; -- so plugins can prevent this if they want.
			hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false);
				end
			end)
		end
	end

	CharacterLevelText:FontTemplate()
	CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)

	local function ColorizeStatPane(frame)
		if(frame.leftGrad) then return end
		local r, g, b = 0.8, 0.8, 0.8
		frame.leftGrad = frame:CreateTexture(nil, "BORDER")
		frame.leftGrad:SetWidth(80)
		frame.leftGrad:SetHeight(frame:GetHeight())
		frame.leftGrad:SetPoint("LEFT", frame, "CENTER")
		frame.leftGrad:SetTexture(E.media.blankTex)
		frame.leftGrad:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)

		frame.rightGrad = frame:CreateTexture(nil, "BORDER")
		frame.rightGrad:SetWidth(80)
		frame.rightGrad:SetHeight(frame:GetHeight())
		frame.rightGrad:SetPoint("RIGHT", frame, "CENTER")
		frame.rightGrad:SetTexture([[Interface\BUTTONS\WHITE8X8]])
		frame.rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end

	CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(CharacterStatsPane.ItemLevelFrame)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		if IsAddOnLoaded("DejaCharacterStats") then return end

		for _, Table in ipairs({CharacterStatsPane.statsFramePool:EnumerateActive()}) do
			if type(Table) == 'table' then
				for statFrame in pairs(Table) do
					ColorizeStatPane(statFrame)
					if statFrame.Background:IsShown() then
						statFrame.leftGrad:Show()
						statFrame.rightGrad:Show()
					else
						statFrame.leftGrad:Hide()
						statFrame.rightGrad:Hide()
					end
				end
			end
		end
	end)

	if (not IsAddOnLoaded("DejaCharacterStats")) then
		local function StatsPane(type)
			CharacterStatsPane[type]:StripTextures()
			CharacterStatsPane[type]:CreateBackdrop("Transparent")
			CharacterStatsPane[type].backdrop:ClearAllPoints()
			CharacterStatsPane[type].backdrop:SetPoint("CENTER")
			CharacterStatsPane[type].backdrop:SetWidth(150)
			CharacterStatsPane[type].backdrop:SetHeight(18)
		end

		StatsPane("EnhancementsCategory")
		StatsPane("ItemLevelCategory")
		StatsPane("AttributesCategory")
	end

	--Strip Textures
	local charframe = {
		"CharacterFrame",
		"CharacterModelFrame",
		"CharacterFrameInset",
		"CharacterStatsPane",
		"CharacterFrameInsetRight",
		"PaperDollSidebarTabs",
		"PaperDollEquipmentManagerPane",
	}

	S:HandleCloseButton(ReputationDetailCloseButton)
	S:HandleCloseButton(TokenFramePopupCloseButton)

	S:HandleCheckBox(ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(ReputationDetailLFGBonusReputationCheckBox)
	S:HandleCheckBox(TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(TokenFramePopupBackpackCheckBox)

	EquipmentFlyoutFrameHighlight:Kill()
	EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	EquipmentFlyoutFrame.NavigationFrame:SetTemplate("Transparent")
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -E.Border - E.Spacing)
	EquipmentFlyoutFrame.NavigationFrame:Point("TOPRIGHT", EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -E.Border - E.Spacing)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton, nil, true)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.NextButton)

	local function SkinItemFlyouts()
		local flyout = EquipmentFlyoutFrame;
		local buttons = flyout.buttons;
		local buttonAnchor = flyout.buttonFrame;

		if not buttonAnchor.template then
			buttonAnchor:StripTextures()
			buttonAnchor:SetTemplate("Transparent")
		end

		for i, button in ipairs(buttons) do
			if buttonAnchor["bg"..i] and buttonAnchor["bg"..i]:GetTexture() ~= nil then
				buttonAnchor["bg"..i]:SetTexture(nil)
			end

			if not button.isHooked then
				button.isHooked = true
				button:StyleButton(false)
				button:GetNormalTexture():SetTexture(nil)

				button.icon:SetInside()
				button.icon:SetTexCoord(unpack(E.TexCoords))

				if not button.backdrop then
					button:SetFrameLevel(buttonAnchor:GetFrameLevel()+2)
					button:CreateBackdrop("Default")
					button.backdrop:SetAllPoints()

					if i ~= 1 then -- dont call this intially on placeInBags button
						button.backdrop:SetBackdropBorderColor(button.IconBorder:GetVertexColor())
					end

					if i == 1 or i == 2 then
						hooksecurefunc(button.icon, 'SetTexture', function(self)
							local loc = self:GetParent().location
							if (loc == PLACEINBAGS_LOCATION) or (loc == IGNORESLOT_LOCATION) or (loc == UNIGNORESLOT_LOCATION) then
								self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
							end
						end)
					end

					button.IconBorder:SetTexture("")
					hooksecurefunc(button.IconBorder, 'SetVertexColor', function(self, r, g, b)
						self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
						self:SetTexture("")
					end)
					hooksecurefunc(button.IconBorder, 'Hide', function(self)
						self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end)
				end
			end
		end

		local width, height = buttonAnchor:GetSize()
		buttonAnchor:Size(width+3, height)
	end

	--Swap item flyout frame (shown when holding alt over a slot)
	hooksecurefunc("EquipmentFlyout_UpdateItems", SkinItemFlyouts)

	--Icon in upper right corner of character frame
	CharacterFramePortrait:Kill()

	local scrollbars = {
		"PaperDollTitlesPaneScrollBar",
		"PaperDollEquipmentManagerPaneScrollBar",
	}

	for _, scrollbar in pairs(scrollbars) do
		S:HandleScrollBar(_G[scrollbar], 5)
	end

	for _, object in pairs(charframe) do
		_G[object]:StripTextures()
	end

	--Re-add the overlay texture which was removed right above via StripTextures
	CharacterModelFrameBackgroundOverlay:SetColorTexture(0,0,0)
	CharacterModelFrame:CreateBackdrop("Default")
	CharacterModelFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	CharacterModelFrame.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	CharacterFrame:SetTemplate("Transparent")

	--Titles
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for _, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.text:FontTemplate()
			hooksecurefunc(object.text, "SetFont", function(self, font)
				if font ~= E.media.normFont then
					self:FontTemplate()
				end
			end)
		end
	end)

	--Equipement Manager
	S:HandleButton(PaperDollEquipmentManagerPaneEquipSet)
	S:HandleButton(PaperDollEquipmentManagerPaneSaveSet)
	PaperDollEquipmentManagerPaneEquipSet:Width(PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	PaperDollEquipmentManagerPaneSaveSet:Width(PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)
	PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
	PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture(nil)
	--Itemset buttons
	for _, object in pairs(PaperDollEquipmentManagerPane.buttons) do
		object.BgTop:SetTexture(nil)
		object.BgBottom:SetTexture(nil)
		object.BgMiddle:SetTexture(nil)
		object.icon:Size(36, 36)
		object.icon:SetTexCoord(unpack(E.TexCoords))
		--Making all icons the same size and position because otherwise BlizzardUI tries to attach itself to itself when it refreshes
		object.icon:Point("LEFT", object, "LEFT", 4, 0)
		hooksecurefunc(object.icon, "SetPoint", function(self, _, _, _, _, _, isForced)
			if isForced ~= true then
				self:SetPoint("LEFT", object, "LEFT", 4, 0, true)
			end
		end)
		hooksecurefunc(object.icon, "SetSize", function(self, width, height)
			if width == 30 or height == 30 then
				self:Size(36, 36)
			end
		end)
	end

	--Icon selection frame
	S:HandleIconSelectionFrame(GearManagerDialogPopup, NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton")
	S:HandleButton(GearManagerDialogPopupOkay)
	S:HandleButton(GearManagerDialogPopupCancel)
	S:HandleEditBox(GearManagerDialogPopupEditBox)

	--Handle Tabs at bottom of character frame
	for i=1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	--Buttons used to toggle between equipment manager, titles, and character stats
	local function FixSidebarTabCoords()
		for i=1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]

			if tab and not tab.backdrop then
				tab:CreateBackdrop("Default")
				tab.Icon:SetAllPoints()
				tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
				tab.Highlight:SetAllPoints()

				-- Check for DejaCharacterStats. Lets hide the Texture if the AddOn is loaded.
				if IsAddOnLoaded("DejaCharacterStats") then
					tab.Hider:SetTexture("")
				else
					tab.Hider:SetColorTexture(0.0, 0.0, 0.0, 0.8)
				end
				tab.Hider:SetAllPoints(tab.backdrop)
				tab.TabBg:Kill()

				if i == 1 then
					for x=1, tab:GetNumRegions() do
						local region = select(x, tab:GetRegions())
						region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
						hooksecurefunc(region, "SetTexCoord", function(self, x1)
							if x1 ~= 0.16001 then
								self:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
							end
						end)
					end
				end
			end
		end
	end
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)

	--Reputation
	S:HandleCloseButton(CharacterFrame.ReputationTabHelpBox.CloseButton)

	local function UpdateFactionSkins()
		ReputationListScrollFrame:StripTextures()
		ReputationFrame:StripTextures(true)
		local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
		local numFactions = GetNumFactions()
		for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]
			local button = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
			local factionIndex = factionOffset + i
			local _, _, _, _, _, _, _, _, _, isCollapsed = GetFactionInfo(factionIndex)
			if ( factionIndex <= numFactions ) then
				if button then
					if isCollapsed then
						button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton")
					else
						button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton")
					end
				end
			end

			if statusbar then
				statusbar:SetStatusBarTexture(E.media.normTex)

				if not statusbar.backdrop then
					statusbar:CreateBackdrop("Default")
					E:RegisterStatusBar(statusbar)
				end

				_G["ReputationBar"..i.."Background"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
			end
		end
		ReputationDetailFrame:StripTextures()
		ReputationDetailFrame:SetTemplate("Transparent")
		ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -28)
	end
	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)
	hooksecurefunc("ReputationFrame_Update", UpdateFactionSkins)

	--Reputation Paragon Tooltip
	if E.private.skins.blizzard.tooltip then
		local tooltip = EmbeddedItemTooltip
		local reward = tooltip.ItemTooltip
		local icon = reward.Icon
		tooltip:SetTemplate("Transparent")
		if icon then
			S:HandleIcon(icon)
			hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
				self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
				self:SetTexture("")
			end)
			hooksecurefunc(reward.IconBorder, "Hide", function(self)
				self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)
		end
		tooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent")
		end)
	end

	--Currency
	local function UpdateCurrencySkins()
		if TokenFramePopup then
			if not TokenFramePopup.template then
				TokenFramePopup:StripTextures();
				TokenFramePopup:SetTemplate("Transparent");
			end
			TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", 4, -28);
		end

		if not TokenFrameContainer.buttons then return end
		local buttons = TokenFrameContainer.buttons;
		local numButtons = #buttons;

		for i=1, numButtons do
			local button = buttons[i];

			if button then
				if button.highlight then button.highlight:Kill() end
				if button.categoryLeft then button.categoryLeft:Kill() end
				if button.categoryRight then button.categoryRight:Kill() end
				if button.categoryMiddle then button.categoryMiddle:Kill() end

				if button.icon then
					button.icon:SetTexCoord(unpack(E.TexCoords));
				end

				if button.expandIcon then
					if not button.highlightTexture then
						button.highlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT");
						button.highlightTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
						button.highlightTexture:SetBlendMode("ADD");
						button.highlightTexture:SetInside(button.expandIcon);

						-- these two only need to be called once
						-- adding them here will prevent additional calls
						button.expandIcon:Point("LEFT", 4, 0);
						button.expandIcon:SetSize(15, 15);
					end
					if button.isHeader then
						if button.isExpanded then
							button.expandIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton");
							button.expandIcon:SetTexCoord(0,1,0,1);
						else
							button.expandIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton");
							button.expandIcon:SetTexCoord(0,1,0,1);
						end
						button.highlightTexture:Show()
					else
						button.highlightTexture:Hide()
					end
				end
			end
		end
	end
	hooksecurefunc("TokenFrame_Update", UpdateCurrencySkins)
	hooksecurefunc(TokenFrameContainer, "update", UpdateCurrencySkins)

	-- Tutorials
	S:HandleCloseButton(PaperDollItemsFrame.UnspentAzeriteHelpBox.CloseButton)
end

S:AddCallback("Character", LoadSkin)
