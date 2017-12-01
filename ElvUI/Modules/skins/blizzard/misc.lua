local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local getn = getn
local pairs = pairs
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SquareButton_SetIcon, UIDROPDOWNMENU_MAXLEVELS, L_UIDROPDOWNMENU_MAXLEVELS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.misc ~= true then return end

	-- Blizzard frame we want to reskin
	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"StaticPopup4",
		"InterfaceOptionsFrame",
		"VideoOptionsFrame",
		"AudioOptionsFrame",
		"AutoCompleteBox",
		"ReadyCheckFrame",
		"StackSplitFrame",
		"QueueStatusFrame",
		"LFDReadyCheckPopup",
		"DropDownList1Backdrop",
		"DropDownList1MenuBackdrop",

		--DropDownMenu library support
		"L_DropDownList1Backdrop",
		"L_DropDownList1MenuBackdrop"
	}

	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
	end

	QueueStatusFrame:StripTextures()

	if not IsAddOnLoaded("ConsolePort") then
		-- reskin all esc/menu buttons
		local BlizzardMenuButtons = {
			"GameMenuButtonOptions",
			"GameMenuButtonSoundOptions",
			"GameMenuButtonUIOptions",
			"GameMenuButtonKeybindings",
			"GameMenuButtonMacros",
			"GameMenuButtonAddOns",
			"GameMenuButtonWhatsNew",
			"GameMenuButtonRatings",
			"GameMenuButtonAddons",
			"GameMenuButtonLogout",
			"GameMenuButtonQuit",
			"GameMenuButtonContinue",
			"GameMenuButtonMacOptions",
			"GameMenuButtonStore",
			"GameMenuButtonHelp"
		}

		for i = 1, #BlizzardMenuButtons do
			local menuButton = _G[BlizzardMenuButtons[i]]
			if menuButton then
				S:HandleButton(menuButton)
			end
		end

		-- Skin the ElvUI Menu Button
		S:HandleButton(GameMenuFrame.ElvUI)
	end

	if not IsAddOnLoaded("ConsolePort") then
		GameMenuFrame:SetTemplate("Transparent")
		GameMenuFrameHeader:SetTexture("")
		GameMenuFrameHeader:ClearAllPoints()
		GameMenuFrameHeader:Point("TOP", GameMenuFrame, 0, 7)
	end

	if IsAddOnLoaded("OptionHouse") then
		S:HandleButton(GameMenuButtonOptionHouse)
	end

	-- since we cant hook `CinematicFrame_OnShow` or `CinematicFrame_OnEvent` directly
	-- we can just hook onto this function so that we can get the correct `self`
	-- this is called through `CinematicFrame_OnShow` so the result would still happen where we want
	hooksecurefunc('CinematicFrame_OnDisplaySizeChanged', function(self)
		if self and self.closeDialog and not self.closeDialog.template then
			self.closeDialog:StripTextures()
			self.closeDialog:SetTemplate('Transparent')
			local dialogName = self.closeDialog.GetName and self.closeDialog:GetName()
			local closeButton = self.closeDialog.ConfirmButton or (dialogName and _G[dialogName..'ConfirmButton'])
			local resumeButton = self.closeDialog.ResumeButton or (dialogName and _G[dialogName..'ResumeButton'])
			if closeButton then S:HandleButton(closeButton) end
			if resumeButton then S:HandleButton(resumeButton) end
		end
	end)

	-- same as above except `MovieFrame_OnEvent` and `MovieFrame_OnShow`
	-- cant be hooked directly so we can just use this
	-- this is called through `MovieFrame_OnEvent` on the event `PLAY_MOVIE`
	hooksecurefunc('MovieFrame_PlayMovie', function(self)
		if self and self.CloseDialog and not self.CloseDialog.template then
			self.CloseDialog:StripTextures()
			self.CloseDialog:SetTemplate('Transparent')
			S:HandleButton(self.CloseDialog.ConfirmButton)
			S:HandleButton(self.CloseDialog.ResumeButton)
		end
	end)

	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",
	}

	for i = 1, getn(ChatMenus) do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Transparent", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) self:ClearAllPoints() self:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30) end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Transparent", true) self:SetBackdropColor(unpack(E['media'].backdropfadecolor)) end)
		end
	end

	--LFD Role Picker frame
	local roleButtons = {
		LFDRoleCheckPopupRoleButtonTank,
		LFDRoleCheckPopupRoleButtonDPS,
		LFDRoleCheckPopupRoleButtonHealer,
	}

	LFDRoleCheckPopup:StripTextures()
	LFDRoleCheckPopup:SetTemplate("Transparent")
	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	for _, roleButton in pairs(roleButtons) do
		S:HandleCheckBox(roleButton.checkButton or roleButton.CheckButton, true)
		roleButton:DisableDrawLayer("OVERLAY")
	end

	-- reskin popup buttons
	for i = 1, 4 do
		for j = 1, 3 do
			S:HandleButton(_G["StaticPopup"..i.."Button"..j])
		end
		S:HandleEditBox(_G["StaticPopup"..i.."EditBox"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
		S:HandleEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
		_G["StaticPopup"..i.."EditBox"].backdrop:Point("TOPLEFT", -2, -4)
		_G["StaticPopup"..i.."EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4)
		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
		_G["StaticPopup"..i.."ItemFrame"]:SetTemplate("Default")
		_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
		_G["StaticPopup"..i.."ItemFrame"].IconBorder:SetAlpha(0)
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetInside()
		local normTex = _G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture()
		if normTex then
			normTex:SetTexture(nil)
			hooksecurefunc(normTex, "SetTexture", function(self, tex)
				if tex ~= nil then self:SetTexture(nil) end
			end)
		end

		-- Quality IconBorder
		hooksecurefunc(_G["StaticPopup"..i.."ItemFrame"].IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(_G["StaticPopup"..i.."ItemFrame"].IconBorder, 'Hide', function(self)
			self:GetParent():SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	-- skin return to graveyard button
	do
		GhostFrameMiddle:SetAlpha(0)
		GhostFrameRight:SetAlpha(0)
		GhostFrameLeft:SetAlpha(0)
		GhostFrame:StripTextures()
		GhostFrame:ClearAllPoints()
		GhostFrame:Point("TOP", E.UIParent, "TOP", 0, -150)
		GhostFrameContentsFrame:SetTemplate("Transparent")
		GhostFrameContentsFrameText:Point("TOPLEFT", 53, 0)
		GhostFrameContentsFrameIcon:SetTexCoord(unpack(E.TexCoords))
		GhostFrameContentsFrameIcon:Point("RIGHT", GhostFrameContentsFrameText, "LEFT", -12, 0)
		local b = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
		local p = E.PixelMode and 1 or 2
		b:Point("TOPLEFT", GhostFrameContentsFrameIcon, -p, p)
		b:Point("BOTTOMRIGHT", GhostFrameContentsFrameIcon, p, -p)
		GhostFrameContentsFrameIcon:SetSize(37,38)
		GhostFrameContentsFrameIcon:SetParent(b)
		b:SetTemplate("Default")
	end

	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")

	--[[WatchFrameCollapseExpandButton:StripTextures()
	S:HandleCloseButton(WatchFrameCollapseExpandButton)
	WatchFrameCollapseExpandButton:Size(30)
	WatchFrameCollapseExpandButton.text:SetText('-')
	WatchFrameCollapseExpandButton:SetFrameStrata('MEDIUM')

	hooksecurefunc('WatchFrame_Expand', function()
		WatchFrameCollapseExpandButton.text:SetText('-')
	end)

	hooksecurefunc('WatchFrame_Collapse', function()
		WatchFrameCollapseExpandButton.text:SetText('+')
	end)]]

	--DropDownMenu
	hooksecurefunc("UIDropDownMenu_CreateFrames", function()
		if not _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent")
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent")
		end
	end)

	--LibUIDropDownMenu
	hooksecurefunc("L_UIDropDownMenu_CreateFrames", function()
		if not _G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
			_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent")
			_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent")
		end
	end)

	--[[local function SkinWatchFrameItems()
		for i=1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			if button and not button.skinned then
				button:CreateBackdrop('Default')
				button.backdrop:SetAllPoints()
				button:StyleButton()
				_G["WatchFrameItem"..i.."NormalTexture"]:SetAlpha(0)
				_G["WatchFrameItem"..i.."IconTexture"]:SetInside()
				_G["WatchFrameItem"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				E:RegisterCooldown(_G["WatchFrameItem"..i.."Cooldown"])
				button.skinned = true
			end
		end
	end
	hooksecurefunc("QuestPOIUpdateIcons", SkinWatchFrameItems)]]
	--WatchFrame:HookScript("OnEvent", SkinWatchFrameItems)

	S:HandleCloseButton(SideDressUpModelCloseButton)
	SideDressUpFrame:StripTextures()
	SideDressUpFrame.BGTopLeft:Hide()
	SideDressUpFrame.BGBottomLeft:Hide()
	S:HandleButton(SideDressUpModelResetButton)
	SideDressUpFrame:SetTemplate("Transparent")

	-- StackSplit
	StackSplitFrame:GetRegions():Hide()

	StackSplitFrame.bg1 = CreateFrame("Frame", nil, StackSplitFrame)
	StackSplitFrame.bg1:SetTemplate("Transparent")
	StackSplitFrame.bg1:Point("TOPLEFT", 10, -15)
	StackSplitFrame.bg1:Point("BOTTOMRIGHT", -10, 55)
	StackSplitFrame.bg1:SetFrameLevel(StackSplitFrame.bg1:GetFrameLevel() - 1)

	--NavBar Buttons (Used in WorldMapFrame, EncounterJournal and HelpFrame)
	local function SkinNavBarButtons(self)
		if (self:GetParent():GetName() == "EncounterJournal" and not E.private.skins.blizzard.encounterjournal) or (self:GetParent():GetName() == "WorldMapFrame" and not E.private.skins.blizzard.worldmap) or (self:GetParent():GetName() == "HelpFrameKnowledgebase" and not E.private.skins.blizzard.help) then
			return
		end
		local navButton = self.navList[#self.navList]
		if navButton and not navButton.isSkinned then
			S:HandleButton(navButton, true)
			if navButton.MenuArrowButton then
				S:HandleNextPrevButton(navButton.MenuArrowButton, true)
			end

			navButton.isSkinned = true
		end
	end
	hooksecurefunc("NavBar_AddButton", SkinNavBarButtons)

	--New Table Attribute Display (/fstack -> then Ctrl)
	local function dynamicScrollButtonVisibility(button, frame)
		if not button.dynamicVisibility then
			button:HookScript("OnShow", function(self) frame:Show() end)
			button:HookScript("OnHide", function(self) frame:Hide() end)
			button.dynamicVisibility = true
		end
	end

	local function SkinTableAttributeDisplay(frame)
		frame:StripTextures()
		frame:SetTemplate("Transparent")
		frame.ScrollFrameArt:StripTextures()
		frame.ScrollFrameArt:SetTemplate("Transparent")
		S:HandleCloseButton(frame.CloseButton)
		frame.OpenParentButton:ClearAllPoints()
		frame.OpenParentButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		S:HandleNextPrevButton(frame.OpenParentButton, true)
		frame.OpenParentButton:Size(17)
		frame.DuplicateButton:ClearAllPoints()
		frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT")
		S:HandleCheckBox(frame.VisibilityButton)
		S:HandleCheckBox(frame.HighlightButton)
		S:HandleCheckBox(frame.DynamicUpdateButton)
		frame.NavigateBackwardButton:ClearAllPoints()
		frame.NavigateBackwardButton:SetPoint("LEFT", frame.OpenParentButton, "RIGHT", 2, 0)
		frame.NavigateForwardButton:ClearAllPoints()
		frame.NavigateForwardButton:SetPoint("LEFT", frame.NavigateBackwardButton, "RIGHT", 2, 0)
		frame.DuplicateButton:ClearAllPoints()
		frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT", 2, 0)
		S:HandleNextPrevButton(frame.DuplicateButton, true, true)
		frame.DuplicateButton:Size(17)
		S:HandleNextPrevButton(frame.NavigateBackwardButton, nil, true)
		S:HandleNextPrevButton(frame.NavigateForwardButton)
		S:HandleEditBox(frame.FilterBox)

		-- reason: UIParentScrollBar .. ???
		if frame.LinesScrollFrame and frame.LinesScrollFrame.ScrollBar then
			local s = frame.LinesScrollFrame.ScrollBar
			s.ScrollUpButton:StripTextures()
			if not s.ScrollUpButton.icon then
				S:HandleNextPrevButton(s.ScrollUpButton)
				SquareButton_SetIcon(s.ScrollUpButton, 'UP')
				s.ScrollUpButton:Size(s.ScrollUpButton:GetWidth() + 7, s.ScrollUpButton:GetHeight() + 7)
			end

			s.ScrollDownButton:StripTextures()
			if not s.ScrollDownButton.icon then
				S:HandleNextPrevButton(s.ScrollDownButton)
				SquareButton_SetIcon(s.ScrollDownButton, 'DOWN')
				s.ScrollDownButton:Size(s.ScrollDownButton:GetWidth() + 7, s.ScrollDownButton:GetHeight() + 7)
			end

			if not s.trackbg then
				s.trackbg = CreateFrame("Frame", "$parentTrackBG", frame.LinesScrollFrame)
				s.trackbg:Point("TOPLEFT", s.ScrollUpButton, "BOTTOMLEFT", 0, -1)
				s.trackbg:Point("TOPRIGHT", s.ScrollUpButton, "BOTTOMRIGHT", 0, -1)
				s.trackbg:Point("BOTTOMLEFT", s.ScrollDownButton, "TOPLEFT", 0, 1)
				s.trackbg:SetTemplate("Transparent")
				dynamicScrollButtonVisibility(s.ScrollUpButton, s.trackbg) -- UpButton handles the TrackBG visibility
			end

			local t = frame.LinesScrollFrame.ScrollBar:GetThumbTexture()
			if t then
				t:SetTexture(nil)
				if not s.thumbbg then
					s.thumbbg = CreateFrame("Frame", "$parentThumbBG", frame.LinesScrollFrame)
					s.thumbbg:Point("TOPLEFT", t, "TOPLEFT", 2, -3)
					s.thumbbg:Point("BOTTOMRIGHT", t, "BOTTOMRIGHT", -2, 3)
					s.thumbbg:SetTemplate("Default", true, true)
					s.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
					if s.trackbg then
						s.thumbbg:SetFrameLevel(s.trackbg:GetFrameLevel()+1)
					end
					dynamicScrollButtonVisibility(s.ScrollDownButton, s.thumbbg) -- DownButton handles the ThumbBG visibility
				end
			end
		end
	end

	SkinTableAttributeDisplay(TableAttributeDisplay)
	hooksecurefunc(TableInspectorMixin, "OnLoad", function(self)
		if self and self.ScrollFrameArt and not self.skinned then
			SkinTableAttributeDisplay(self)
			self.skinned = true
		end
	end)
end

S:AddCallback("SkinMisc", LoadSkin)