local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

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

local PLACEINBAGS_LOCATION = 0xFFFFFFFF
local IGNORESLOT_LOCATION = 0xFFFFFFFE
local UNIGNORESLOT_LOCATION = 0xFFFFFFFD

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture()
		self.RankFrame.Label:FontTemplate(nil, nil, "OUTLINE")

		self.styled = true
	end
	self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	self:GetHighlightTexture():SetAllPoints()
end

local function UpdateAzeriteEmpoweredItem(self)
	self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
	self.AzeriteTexture:SetInside()
	self.AzeriteTexture:SetTexCoord(unpack(E.TexCoords))
	self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function ColorizeStatPane(frame)
	if frame.leftGrad then return end

	local r, g, b = 0.8, 0.8, 0.8
	frame.leftGrad = frame:CreateTexture(nil, "BORDER")
	frame.leftGrad:Width(80)
	frame.leftGrad:Height(frame:GetHeight())
	frame.leftGrad:Point("LEFT", frame, "CENTER")
	frame.leftGrad:SetTexture(E.Media.Textures.White8x8)
	frame.leftGrad:SetGradientAlpha("Horizontal", r, g, b, 0.25, r, g, b, 0)

	frame.rightGrad = frame:CreateTexture(nil, "BORDER")
	frame.rightGrad:Width(80)
	frame.rightGrad:Height(frame:GetHeight())
	frame.rightGrad:Point("RIGHT", frame, "CENTER")
	frame.rightGrad:SetTexture(E.Media.Textures.White8x8)
	frame.rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.25)
end

local function StatsPane(which)
	local CharacterStatsPane = _G.CharacterStatsPane
	CharacterStatsPane[which]:StripTextures()
	CharacterStatsPane[which]:CreateBackdrop("Transparent")
	CharacterStatsPane[which].backdrop:ClearAllPoints()
	CharacterStatsPane[which].backdrop:Point("CENTER")
	CharacterStatsPane[which].backdrop:Width(150)
	CharacterStatsPane[which].backdrop:Height(18)
end

local function SkinItemFlyouts()
	local flyout = _G.EquipmentFlyoutFrame
	local buttons = flyout.buttons
	local buttonAnchor = flyout.buttonFrame

	if not buttonAnchor.template then
		buttonAnchor:StripTextures()
		buttonAnchor:SetTemplate("Transparent")
	end

	for i, button in ipairs(buttons) do
		if buttonAnchor["bg"..i] and buttonAnchor["bg"..i]:GetTexture() ~= nil then
			buttonAnchor["bg"..i]:SetTexture()
		end

		if not button.isHooked then
			button.isHooked = true
			button:StyleButton(false)
			button:GetNormalTexture():SetTexture()

			button.icon:SetInside()
			button.icon:SetTexCoord(unpack(E.TexCoords))

			if not button.backdrop then
				button:SetFrameLevel(buttonAnchor:GetFrameLevel()+2)
				button:CreateBackdrop()
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

				button.IconBorder:SetTexture()
				hooksecurefunc(button.IconBorder, 'SetVertexColor', function(self, r, g, b)
					self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
					self:SetTexture()
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

local function FixSidebarTabCoords()
	for i=1, #_G.PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]

		if tab and not tab.backdrop then
			tab:CreateBackdrop()
			tab.Icon:SetAllPoints()
			tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
			tab.Highlight:SetAllPoints()

			-- Check for DejaCharacterStats. Lets hide the Texture if the AddOn is loaded.
			if IsAddOnLoaded("DejaCharacterStats") then
				tab.Hider:SetTexture()
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

local function UpdateFactionSkins()
	_G.ReputationListScrollFrame:StripTextures()
	_G.ReputationFrame:StripTextures(true)

	local factionOffset = FauxScrollFrame_GetOffset(_G.ReputationListScrollFrame)
	local numFactions = GetNumFactions()

	for i = 1, _G.NUM_FACTIONS_DISPLAYED, 1 do
		local statusbar = _G["ReputationBar"..i.."ReputationBar"]
		local button = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
		local factionIndex = factionOffset + i
		local _, _, _, _, _, _, _, _, _, isCollapsed = GetFactionInfo(factionIndex)
		if factionIndex <= numFactions then
			if button then
				if isCollapsed then
					button:SetNormalTexture(E.Media.Textures.PlusButton)
				else
					button:SetNormalTexture(E.Media.Textures.MinusButton)
				end
			end
		end

		if statusbar then
			statusbar:SetStatusBarTexture(E.media.normTex)

			if not statusbar.backdrop then
				statusbar:CreateBackdrop()
				E:RegisterStatusBar(statusbar)
			end

			_G["ReputationBar"..i.."Background"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture()
			_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture()
		end
	end

	local ReputationDetailFrame = _G.ReputationDetailFrame
	ReputationDetailFrame:StripTextures()
	ReputationDetailFrame:ClearAllPoints()
	ReputationDetailFrame:Point("TOPLEFT", _G.ReputationFrame, "TOPRIGHT", 4, -28)
	if not ReputationDetailFrame.backdrop then
		ReputationDetailFrame:CreateBackdrop("Transparent")
	end
end

local function UpdateCurrencySkins()
	local TokenFramePopup = _G.TokenFramePopup

	if TokenFramePopup then
		TokenFramePopup:StripTextures()
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:Point("TOPLEFT", _G.TokenFrame, "TOPRIGHT", 4, -28)
		if not TokenFramePopup.backdrop then
			TokenFramePopup:CreateBackdrop("Transparent")
		end
	end

	local TokenFrameContainer = _G.TokenFrameContainer
	if not TokenFrameContainer.buttons then return end

	local buttons = TokenFrameContainer.buttons
	local numButtons = #buttons

	for i=1, numButtons do
		local button = buttons[i]

		if button then
			if button.highlight then button.highlight:Kill() end
			if button.categoryLeft then button.categoryLeft:Kill() end
			if button.categoryRight then button.categoryRight:Kill() end
			if button.categoryMiddle then button.categoryMiddle:Kill() end

			if button.icon then
				button.icon:SetTexCoord(unpack(E.TexCoords))
			end

			if button.expandIcon then
				if not button.highlightTexture then
					button.highlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT")
					button.highlightTexture:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
					button.highlightTexture:SetBlendMode("ADD")
					button.highlightTexture:SetInside(button.expandIcon)

					-- these two only need to be called once
					-- adding them here will prevent additional calls
					button.expandIcon:Point("LEFT", 4, 0)
					button.expandIcon:Size(15, 15)
				end

				if button.isHeader then
					if button.isExpanded then
						button.expandIcon:SetTexture(E.Media.Textures.MinusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					else
						button.expandIcon:SetTexture(E.Media.Textures.PlusButton)
						button.expandIcon:SetTexCoord(0,1,0,1)
					end

					button.highlightTexture:Show()
				else
					button.highlightTexture:Hide()
				end
			end
		end
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true then return end

	-- General
	local CharacterFrame = _G.CharacterFrame
	S:HandlePortraitFrame(CharacterFrame)

	S:HandleScrollBar(_G.ReputationListScrollFrameScrollBar)
	S:HandleScrollBar(_G.TokenFrameContainerScrollBar)
	S:HandleScrollBar(_G.GearManagerDialogPopupScrollFrameScrollBar)

	for _, Slot in pairs({_G.PaperDollItemsFrame:GetChildren()}) do
		if Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton") then
			S:HandleIcon(Slot.icon)
			Slot:StripTextures()
			Slot:SetTemplate()
			Slot:StyleButton(Slot)
			Slot.icon:SetInside()

			local Cooldown = _G[Slot:GetName().."Cooldown"]
			E:RegisterCooldown(Cooldown)

			hooksecurefunc(Slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
			hooksecurefunc(Slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

			if Slot.popoutButton:GetPoint() == 'TOP' then
				Slot.popoutButton:Point("TOP", Slot, "BOTTOM", 0, 2)
			else
				Slot.popoutButton:Point("LEFT", Slot, "RIGHT", -2, 0)
			end

			Slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
			Slot.IconBorder:SetAlpha(0)
			hooksecurefunc(Slot.IconBorder, 'SetVertexColor', function(_, r, g, b) Slot:SetBackdropBorderColor(r, g, b) end)
			hooksecurefunc(Slot.IconBorder, 'Hide', function() Slot:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
		end
	end

	--Give character frame model backdrop it's color back
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

	_G.CharacterLevelText:FontTemplate()
	_G.CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)
	_G.CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(_G.CharacterStatsPane.ItemLevelFrame)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		if IsAddOnLoaded("DejaCharacterStats") then return end

		for _, Table in ipairs({_G.CharacterStatsPane.statsFramePool:EnumerateActive()}) do
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

	if not IsAddOnLoaded("DejaCharacterStats") then
		StatsPane("EnhancementsCategory")
		StatsPane("ItemLevelCategory")
		StatsPane("AttributesCategory")
	end

	--Strip Textures
	local charframe = {
		"CharacterModelFrame",
		"CharacterFrameInset",
		"CharacterStatsPane",
		"CharacterFrameInsetRight",
		"PaperDollSidebarTabs",
		"PaperDollEquipmentManagerPane",
	}

	S:HandleCloseButton(_G.ReputationDetailCloseButton)
	S:HandleCloseButton(_G.TokenFramePopupCloseButton)

	S:HandleCheckBox(_G.ReputationDetailAtWarCheckBox)
	S:HandleCheckBox(_G.ReputationDetailMainScreenCheckBox)
	S:HandleCheckBox(_G.ReputationDetailInactiveCheckBox)
	S:HandleCheckBox(_G.ReputationDetailLFGBonusReputationCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupInactiveCheckBox)
	S:HandleCheckBox(_G.TokenFramePopupBackpackCheckBox)

	_G.EquipmentFlyoutFrameHighlight:Kill()
	_G.EquipmentFlyoutFrame.NavigationFrame:StripTextures()
	_G.EquipmentFlyoutFrame.NavigationFrame:SetTemplate("Transparent")
	_G.EquipmentFlyoutFrame.NavigationFrame:Point("TOPLEFT", _G.EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -E.Border - E.Spacing)
	_G.EquipmentFlyoutFrame.NavigationFrame:Point("TOPRIGHT", _G.EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -E.Border - E.Spacing)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	S:HandleNextPrevButton(_G.EquipmentFlyoutFrame.NavigationFrame.NextButton)

	--Swap item flyout frame (shown when holding alt over a slot)
	hooksecurefunc("EquipmentFlyout_UpdateItems", SkinItemFlyouts)

	--Icon in upper right corner of character frame
	_G.CharacterFramePortrait:Kill()

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
	_G.CharacterModelFrameBackgroundOverlay:SetColorTexture(0,0,0)
	_G.CharacterModelFrame:CreateBackdrop()
	_G.CharacterModelFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	_G.CharacterModelFrame.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	--Titles
	_G.PaperDollTitlesPane:HookScript("OnShow", function()
		for _, object in pairs(_G.PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture()
			object.BgBottom:SetTexture()
			object.BgMiddle:SetTexture()
			object.text:FontTemplate()
			hooksecurefunc(object.text, "SetFont", function(self, font)
				if font ~= E.media.normFont then
					self:FontTemplate()
				end
			end)
		end
	end)

	--Equipement Manager
	S:HandleButton(_G.PaperDollEquipmentManagerPaneEquipSet)
	S:HandleButton(_G.PaperDollEquipmentManagerPaneSaveSet)
	_G.PaperDollEquipmentManagerPaneEquipSet:Width(_G.PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneSaveSet:Width(_G.PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)
	_G.PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", _G.PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	_G.PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", _G.PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)

	--Itemset buttons
	for _, object in pairs(_G.PaperDollEquipmentManagerPane.buttons) do
		object.BgTop:SetTexture()
		object.BgBottom:SetTexture()
		object.BgMiddle:SetTexture()
		object.icon:Size(36, 36)
		object.icon:SetTexCoord(unpack(E.TexCoords))
		--Making all icons the same size and position because otherwise BlizzardUI tries to attach itself to itself when it refreshes
		object.icon:Point("LEFT", object, "LEFT", 4, 0)
		hooksecurefunc(object.icon, "SetPoint", function(self, _, _, _, _, _, isForced)
			if isForced ~= true then
				self:Point("LEFT", object, "LEFT", 4, 0, true)
			end
		end)
		hooksecurefunc(object.icon, "SetSize", function(self, width, height)
			if width == 30 or height == 30 then
				self:Size(36, 36)
			end
		end)
	end

	--Icon selection frame
	S:HandleIconSelectionFrame(_G.GearManagerDialogPopup, _G.NUM_GEARSET_ICONS_SHOWN, "GearManagerDialogPopupButton")
	S:HandleButton(_G.GearManagerDialogPopupOkay)
	S:HandleButton(_G.GearManagerDialogPopupCancel)
	S:HandleEditBox(_G.GearManagerDialogPopupEditBox)

	--Handle Tabs at bottom of character frame
	for i=1, 4 do
		S:HandleTab(_G["CharacterFrameTab"..i])
	end

	--Buttons used to toggle between equipment manager, titles, and character stats
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)

	--Reputation
	S:HandleCloseButton(CharacterFrame.ReputationTabHelpBox.CloseButton)

	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)
	hooksecurefunc("ReputationFrame_Update", UpdateFactionSkins)

	--Reputation Paragon Tooltip
	if E.private.skins.blizzard.tooltip then
		local tooltip = _G.EmbeddedItemTooltip
		local reward = tooltip.ItemTooltip
		local icon = reward.Icon
		tooltip:SetTemplate("Transparent")
		if icon then
			S:HandleIcon(icon, true)
			hooksecurefunc(reward.IconBorder, "SetVertexColor", function(self, r, g, b)
				self:GetParent().Icon.backdrop:SetBackdropBorderColor(r, g, b)
				self:SetTexture()
			end)
			hooksecurefunc(reward.IconBorder, "Hide", function(self)
				self:GetParent().Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)
		end
		tooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent")
		end)
	end

	--Currency
	hooksecurefunc("TokenFrame_Update", UpdateCurrencySkins)
	hooksecurefunc(_G.TokenFrameContainer, "update", UpdateCurrencySkins)

	-- Tutorials
	S:HandleCloseButton(_G.PaperDollItemsFrame.HelpTipBox.CloseButton)
end

S:AddCallback("Character", LoadSkin)
