local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack, pairs, select = unpack, pairs, select
--WoW API / Variables
local CharacterFrameExpandButton = CharacterFrameExpandButton
local SquareButton_SetIcon = SquareButton_SetIcon

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	S:HandleCloseButton(CharacterFrameCloseButton)
	S:HandleScrollBar(ReputationListScrollFrameScrollBar)
	S:HandleScrollBar(TokenFrameContainerScrollBar)
	S:HandleScrollBar(GearManagerDialogPopupScrollFrameScrollBar)

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
		frame.rightGrad:SetTexture([[Interface\BUTTONS\WHITE8X8.blp]])
		frame.rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end
	CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(CharacterStatsPane.ItemLevelFrame)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		local level = UnitLevel("player");
		local categoryYOffset = -5;
		local statYOffset = 0;

		if (not IsAddOnLoaded("DejaCharacterStats")) then 
			if ( level >= MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY ) then
				PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, "player");
				CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(GetItemLevelColor());
				CharacterStatsPane.ItemLevelCategory:Show();
				CharacterStatsPane.ItemLevelFrame:Show();
				CharacterStatsPane.AttributesCategory:SetPoint("TOP", 0, -76);
			else
				CharacterStatsPane.ItemLevelCategory:Hide();
				CharacterStatsPane.ItemLevelFrame:Hide();
				CharacterStatsPane.AttributesCategory:SetPoint("TOP", 0, -20);
				categoryYOffset = -12;
				statYOffset = -6;
			end
		end

		local spec = GetSpecialization();
		local role = GetSpecializationRole(spec);

		CharacterStatsPane.statsFramePool:ReleaseAll();
		-- we need a stat frame to first do the math to know if we need to show the stat frame
		-- so effectively we'll always pre-allocate
		local statFrame = CharacterStatsPane.statsFramePool:Acquire();

		local lastAnchor;

		for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
			local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame];
			local numStatInCat = 0;
			for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
				local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex];
				local showStat = true;
				if ( showStat and stat.primary ) then
					local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")));
					if ( stat.primary ~= primaryStat ) then
						showStat = false;
					end
				end
				if ( showStat and stat.roles ) then
					local foundRole = false;
					for _, statRole in pairs(stat.roles) do
						if ( role == statRole ) then
							foundRole = true;
							break;
						end
					end
					showStat = foundRole;
				end
				if ( showStat ) then
					statFrame.onEnterFunc = nil;
					PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player");
					if ( not stat.hideAt or stat.hideAt ~= statFrame.numericValue ) then
						if ( numStatInCat == 0 ) then
							if ( lastAnchor ) then
								catFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, categoryYOffset);
							end
							lastAnchor = catFrame;
							statFrame:SetPoint("TOP", catFrame, "BOTTOM", 0, -2);
						else
							statFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, statYOffset);
						end
						numStatInCat = numStatInCat + 1;
						statFrame.Background:SetShown(false);
						ColorizeStatPane(statFrame)
						statFrame.leftGrad:SetShown((numStatInCat % 2) == 0)
						statFrame.rightGrad:SetShown((numStatInCat % 2) == 0)
						lastAnchor = statFrame;
						-- done with this stat frame, get the next one
						statFrame = CharacterStatsPane.statsFramePool:Acquire();
					end
				end
			end
			catFrame:SetShown(numStatInCat > 0);
		end
		-- release the current stat frame
		CharacterStatsPane.statsFramePool:Release(statFrame);
	end)

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
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(EquipmentFlyoutFrame.NavigationFrame.NextButton)

	local function SkinItemFlyouts()
		--Because EquipmentFlyout_Show seems to run as OnUpdate, prevent re-skinning the frames over and over.
		if (not EquipmentFlyoutFrameButtons.isSkinned) or (EquipmentFlyoutFrameButtons.bg2 and not EquipmentFlyoutFrameButtons.bg2.isSkinned) or (EquipmentFlyoutFrameButtons.bg3 and not EquipmentFlyoutFrameButtons.bg3.isSkinned) or (EquipmentFlyoutFrameButtons.bg4 and not EquipmentFlyoutFrameButtons.bg4.isSkinned) then
			EquipmentFlyoutFrameButtons:StripTextures()
			EquipmentFlyoutFrameButtons:SetTemplate("Transparent")
			EquipmentFlyoutFrameButtons.isSkinned = true
			if EquipmentFlyoutFrameButtons.bg2 then EquipmentFlyoutFrameButtons.bg2.isSkinned = true end
			if EquipmentFlyoutFrameButtons.bg3 then EquipmentFlyoutFrameButtons.bg3.isSkinned = true end
			if EquipmentFlyoutFrameButtons.bg4 then EquipmentFlyoutFrameButtons.bg4.isSkinned = true end
		end

		local i = 1
		local button = _G["EquipmentFlyoutFrameButton"..i]

		while button do
			if not button.isHooked then
				local icon = _G["EquipmentFlyoutFrameButton"..i.."IconTexture"]

				button:StyleButton(false)
				button:GetNormalTexture():SetTexture(nil)

				if not button.backdrop then
					button:CreateBackdrop("Default")
					button.backdrop:SetAllPoints()

					hooksecurefunc(button.IconBorder, 'SetVertexColor', function(self, r, g, b)
						self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
						self:SetTexture("")
					end)
					hooksecurefunc(button.IconBorder, 'Hide', function(self)
						self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end)
				end

				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
				button.isHooked = true
			end

			i = i + 1
			button = _G["EquipmentFlyoutFrameButton"..i]
		end
	end

	--Swap item flyout frame (shown when holding alt over a slot)
	EquipmentFlyoutFrame:HookScript("OnShow", SkinItemFlyouts)

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
	--Re-add the overlay texture which was removed right above
	CharacterModelFrameBackgroundOverlay:SetColorTexture(0,0,0)

	local function StatsPane(type)
		CharacterStatsPane[type]:StripTextures()
		CharacterStatsPane[type]:CreateBackdrop("Transparent")
		CharacterStatsPane[type].backdrop:ClearAllPoints()
		CharacterStatsPane[type].backdrop:SetPoint("CENTER")
		CharacterStatsPane[type].backdrop:SetWidth(150)
		CharacterStatsPane[type].backdrop:SetHeight(18)
	end
	CharacterFrame:SetTemplate("Transparent")
	StatsPane("EnhancementsCategory")
	StatsPane("ItemLevelCategory")
	StatsPane("AttributesCategory")

	--Titles
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.text:FontTemplate()
			hooksecurefunc(object.text, "SetFont", function(self, font, fontSize, fontStyle)
				if font ~= E["media"].normFont then
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
		hooksecurefunc(object.icon, "SetPoint", function(self, point, attachTo, anchorPoint, xOffset, yOffset, isForced)
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
	S:HandleIconSelectionFrame(GearManagerDialogPopup, NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton", frameNameOverride)

	--Handle Tabs at bottom of character frame
	for i=1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	--Buttons used to toggle between equipment manager, titles, and character stats
	local function FixSidebarTabCoords()
		for i=1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]
			if tab and not tab.backdrop then
				tab.Icon:SetAllPoints()
				tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
				tab.Highlight:SetAllPoints()
				tab.Hider:SetColorTexture(0.4,0.4,0.4,0.4)
				tab.Hider:SetAllPoints()
				tab.TabBg:Kill()

				if i == 1 then
					for i=1, tab:GetNumRegions() do
						local region = select(i, tab:GetRegions())
						region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
						hooksecurefunc(region, "SetTexCoord", function(self, x1, y1, x2, y2)
							if x1 ~= 0.16001 then
								self:SetTexCoord(0.16001, 0.86, 0.16, 0.86)
							end
						end)
					end
				end
				tab:CreateBackdrop("Default")
			end
		end
	end
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)

	--Reputation
	S:HandleCloseButton(CharacterFrame.ReputationTabHelpBox.CloseButton)

	local function UpdateFactionSkins()
		ReputationListScrollFrame:StripTextures()
		ReputationFrame:StripTextures(true)
		for i=1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]

			if statusbar then
				statusbar:SetStatusBarTexture(E["media"].normTex)

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
	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)

	--Reputation Paragon Tooltip
	local tooltip = ReputationParagonTooltip
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

	--Currency
	TokenFrame:HookScript("OnShow", function()
		for i=1, GetCurrencyListSize() do
			local button = _G["TokenFrameContainerButton"..i]

			if button then
				button.highlight:Kill()
				button.categoryMiddle:Kill()
				button.categoryLeft:Kill()
				button.categoryRight:Kill()

				if button.icon then
					button.icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end
		TokenFramePopup:StripTextures()
		TokenFramePopup:SetTemplate("Transparent")
		TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", 4, -28)
	end)
end

S:AddCallback("Character", LoadSkin)