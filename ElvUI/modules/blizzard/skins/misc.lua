local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].misc ~= true then return end

local function LoadSkin()
	-- Blizzard frame we want to reskin
	local skins = {
		"StaticPopup1",
		"StaticPopup2",
		"StaticPopup3",
		"GameMenuFrame",
		"InterfaceOptionsFrame",
		"VideoOptionsFrame",
		"AudioOptionsFrame",
		"LFDDungeonReadyStatus",
		"BNToastFrame",
		"TicketStatusFrameButton",
		"DropDownList1MenuBackdrop",
		"DropDownList2MenuBackdrop",
		"DropDownList1Backdrop",
		"DropDownList2Backdrop",
		"LFDSearchStatus",
		"AutoCompleteBox",
		"ConsolidatedBuffsTooltip",
		"ReadyCheckFrame",
		"StackSplitFrame",
		"CharacterFrame",
	}
	
	for i = 1, getn(skins) do
		_G[skins[i]]:SetTemplate("Transparent")
		if _G[skins[i]] ~= _G["GhostFrameContentsFrame"] or _G[skins[i]] ~= _G["AutoCompleteBox"] then -- frame to blacklist from create shadow function
			_G[skins[i]]:CreateShadow("Default")
		end
	end

	
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu",		
	}
	--
	for i = 1, getn(ChatMenus) do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) self:ClearAllPoints() self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, E.Scale(30)) end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) end)
		end
	end
	
	--LFD Role Picker frame
	LFDRoleCheckPopup:StripTextures()
	LFDRoleCheckPopup:SetTemplate("Transparent")
	E.SkinButton(LFDRoleCheckPopupAcceptButton)
	E.SkinButton(LFDRoleCheckPopupDeclineButton)
	E.SkinCheckBox(LFDRoleCheckPopupRoleButtonTank:GetChildren())
	E.SkinCheckBox(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
	E.SkinCheckBox(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
	LFDRoleCheckPopupRoleButtonTank:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonTank:GetChildren():GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonDPS:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonDPS:GetChildren():GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonHealer:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonHealer:GetChildren():GetFrameLevel() + 1)
	
	-- reskin popup buttons
	for i = 1, 2 do
		for j = 1, 3 do
			E.SkinButton(_G["StaticPopup"..i.."Button"..j])
			E.SkinEditBox(_G["StaticPopup"..i.."EditBox"])
			E.SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
			E.SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
			E.SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("TOPLEFT", -2, -4)
			_G["StaticPopup"..i.."EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4)
			_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
			_G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture():Kill()
			_G["StaticPopup"..i.."ItemFrame"]:SetTemplate("Default")
			_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:ClearAllPoints()
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:Point("TOPLEFT", 2, -2)
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:Point("BOTTOMRIGHT", -2, 2)
		end
	end
	
	-- reskin all esc/menu buttons
	local BlizzardMenuButtons = {
		"Options", 
		"SoundOptions", 
		"UIOptions", 
		"Keybindings", 
		"Macros",
		"Ratings",
		"AddOns", 
		"Logout", 
		"Quit", 
		"Continue", 
		"MacOptions",
		"Help"
	}
	
	for i = 1, getn(BlizzardMenuButtons) do
		local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
		if ElvuiMenuButtons then
			E.SkinButton(ElvuiMenuButtons)
		end
	end
	
	if IsAddOnLoaded("OptionHouse") then
		E.SkinButton(GameMenuButtonOptionHouse)
	end
	
	-- skin return to graveyard button
	do
		E.SkinButton(GhostFrame)
		GhostFrame:SetBackdropColor(0,0,0,0)
		GhostFrame:SetBackdropBorderColor(0,0,0,0)
		GhostFrame.SetBackdropColor = E.dummy
		GhostFrame.SetBackdropBorderColor = E.dummy
		GhostFrame:ClearAllPoints()
		GhostFrame:SetPoint("TOP", E.UIParent, "TOP", 0, -150)
		E.SkinButton(GhostFrameContentsFrame)
		GhostFrameContentsFrameIcon:SetTexture(nil)
		local x = CreateFrame("Frame", nil, GhostFrame)
		x:SetFrameStrata("MEDIUM")
		x:SetTemplate("Default")
		x:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, "TOPLEFT", E.Scale(-2), E.Scale(2))
		x:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		local tex = x:CreateTexture(nil, "OVERLAY")
		tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
		tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		tex:SetPoint("TOPLEFT", x, "TOPLEFT", E.Scale(2), E.Scale(-2))
		tex:SetPoint("BOTTOMRIGHT", x, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
	end
	
	-- hide header textures and move text/buttons.
	local BlizzardHeader = {
		"GameMenuFrame", 
		"InterfaceOptionsFrame", 
		"AudioOptionsFrame", 
		"VideoOptionsFrame",
	}
	
	for i = 1, getn(BlizzardHeader) do
		local title = _G[BlizzardHeader[i].."Header"]			
		if title then
			title:SetTexture("")
			title:ClearAllPoints()
			if title == _G["GameMenuFrameHeader"] then
				title:SetPoint("TOP", GameMenuFrame, 0, 7)
			else
				title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
			end
		end
	end
	
	-- here we reskin all "normal" buttons
	local BlizzardButtons = {
		"VideoOptionsFrameOkay", 
		"VideoOptionsFrameCancel", 
		"VideoOptionsFrameDefaults", 
		"VideoOptionsFrameApply", 
		"AudioOptionsFrameOkay", 
		"AudioOptionsFrameCancel", 
		"AudioOptionsFrameDefaults", 
		"InterfaceOptionsFrameDefaults", 
		"InterfaceOptionsFrameOkay", 
		"InterfaceOptionsFrameCancel",
		"ReadyCheckFrameYesButton",
		"ReadyCheckFrameNoButton",
		"StackSplitOkayButton",
		"StackSplitCancelButton",
		"RolePollPopupAcceptButton"
	}
	
	for i = 1, getn(BlizzardButtons) do
		local ElvuiButtons = _G[BlizzardButtons[i]]
		if ElvuiButtons then
			E.SkinButton(ElvuiButtons)
		end
	end
	
	-- if a button position is not really where we want, we move it here
	VideoOptionsFrameCancel:ClearAllPoints()
	VideoOptionsFrameCancel:SetPoint("RIGHT",VideoOptionsFrameApply,"LEFT",-4,0)		 
	VideoOptionsFrameOkay:ClearAllPoints()
	VideoOptionsFrameOkay:SetPoint("RIGHT",VideoOptionsFrameCancel,"LEFT",-4,0)	
	AudioOptionsFrameOkay:ClearAllPoints()
	AudioOptionsFrameOkay:SetPoint("RIGHT",AudioOptionsFrameCancel,"LEFT",-4,0)
	InterfaceOptionsFrameOkay:ClearAllPoints()
	InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)
	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame) 
	ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)	
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -12)
	
	-- others
	ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
	StackSplitFrame:GetRegions():Hide()

	E.SkinButton(LFDDungeonReadyDialogEnterDungeonButton)
	E.SkinButton(LFDDungeonReadyDialogLeaveQueueButton)

	RolePollPopup:SetTemplate("Transparent")
	RolePollPopup:CreateShadow("Default")
	
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then return end
		
		if IsShiftKeyDown() then
			self:StartMoving() 
		end
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing()
	end)
	
	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
		--Skin internal frames
		MacOptionsFrameMovieRecording:SetTemplate("Default", true)
		MacOptionsITunesRemote:SetTemplate("Default", true)
 
		--Skin buttons
		E.SkinButton(MacOptionsFrameCancel)
		E.SkinButton(MacOptionsFrameOkay)
		E.SkinButton(MacOptionsButtonKeybindings)
		E.SkinButton(MacOptionsFrameDefaults)
		E.SkinButton(MacOptionsButtonCompress)
 
		--Reposition and resize buttons
		local tPoint, tRTo, tRP, tX, tY =  MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:SetWidth(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:SetPoint(tPoint, tRTo, tRP, E.Scale(4), tY)
 
		MacOptionsFrameCancel:SetWidth(96)
		MacOptionsFrameCancel:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:SetPoint(tPoint, tRTo, tRP, E.Scale(-14), tY)
 
		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetWidth(96)
		MacOptionsFrameOkay:SetHeight(22)
		MacOptionsFrameOkay:SetPoint("LEFT",MacOptionsFrameCancel,E.Scale(-99),0)
 
		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetWidth(96)
		MacOptionsButtonKeybindings:SetHeight(22)
		MacOptionsButtonKeybindings:SetPoint("LEFT",MacOptionsFrameOkay,E.Scale(-99),0)
 
		MacOptionsFrameDefaults:SetWidth(96)
		MacOptionsFrameDefaults:SetHeight(22)

		-- why these buttons is using game menu template? oO
		MacOptionsButtonCompressLeft:SetAlpha(0)
		MacOptionsButtonCompressMiddle:SetAlpha(0)
		MacOptionsButtonCompressRight:SetAlpha(0)
		MacOptionsButtonKeybindingsLeft:SetAlpha(0)
		MacOptionsButtonKeybindingsMiddle:SetAlpha(0)
		MacOptionsButtonKeybindingsRight:SetAlpha(0)
	end
	
	OpacityFrame:StripTextures()
	OpacityFrame:SetTemplate("Transparent")	
	for i=1, WatchFrameCollapseExpandButton:GetNumRegions() do
		local region = select(i, WatchFrameCollapseExpandButton:GetRegions())
		if region:GetObjectType() == 'Texture' then
			region:SetDesaturated(true)
		end
	end
	
	--Chat Config
	local StripAllTextures = {
		"ChatConfigFrame",
		"ChatConfigBackgroundFrame",
		"ChatConfigCategoryFrame",
		"ChatConfigChatSettingsClassColorLegend",
		"ChatConfigChatSettingsLeft",
		"ChatConfigChannelSettingsLeft",
		"ChatConfigChannelSettingsClassColorLegend",
		"ChatConfigOtherSettingsCombat",
		"ChatConfigOtherSettingsPVP",
		"ChatConfigOtherSettingsSystem",
		"ChatConfigOtherSettingsCreature",
		"ChatConfigCombatSettingsFilters",
		"CombatConfigMessageSourcesDoneBy",
		"CombatConfigMessageSourcesDoneTo",
		"CombatConfigColorsUnitColors",
		"CombatConfigColorsHighlighting",
		"CombatConfigColorsColorizeUnitName",
		"CombatConfigColorsColorizeSpellNames",
		"CombatConfigColorsColorizeDamageNumber",
		"CombatConfigColorsColorizeDamageSchool",
		"CombatConfigColorsColorizeEntireLine",
	}
			
	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end
			
	ChatConfigFrame:SetTemplate("Transparent")
	ChatConfigBackgroundFrame:SetTemplate("Transparent")
	ChatConfigCategoryFrame:SetTemplate("Transparent")
	ChatConfigCombatSettingsFilters:SetTemplate("Transparent")
	ChatConfigChannelSettingsClassColorLegend:SetTemplate("Transparent")
	ChatConfigChatSettingsClassColorLegend:SetTemplate("Transparent")
	
	local chatbuttons = {
		"ChatConfigFrameDefaultButton",
		"ChatConfigFrameOkayButton",
		"CombatLogDefaultButton",
		"ChatConfigCombatSettingsFiltersCopyFilterButton",
		"ChatConfigCombatSettingsFiltersAddFilterButton",
		"ChatConfigCombatSettingsFiltersDeleteButton",
		"CombatConfigSettingsSaveButton",
		"ChatConfigFrameCancelButton",
	}
			
	for i = 1, #chatbuttons do
		E.SkinButton(_G[chatbuttons[i]], true)
	end	
	
	ChatConfigFrameOkayButton:Point("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:Point("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:Point("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	
	for i=1, 5 do
		local tab = _G["CombatConfigTab"..i]
		tab:StripTextures()
	end
	
	E.SkinEditBox(CombatConfigSettingsNameEditBox)
	
	--This isn't worth the effort
	--[[local function SkinChannelFrame(frame)
		frame:StripTextures()
		frame:SetTemplate("Default")
		if _G[frame:GetName().."Check"] then
			E.SkinCheckBox(_G[frame:GetName().."Check"])
		end
		
		if _G[frame:GetName().."ColorClasses"] then
			E.SkinCheckBox(_G[frame:GetName().."ColorClasses"])
		end
	end
	
	local x = CreateFrame("Frame")
	x:RegisterEvent("PLAYER_ENTERING_WORLD")
	x:SetScript("OnEvent", function(self, event)
		for i=1, #CHAT_CONFIG_CHAT_LEFT do
			local frame = _G["ChatConfigChatSettingsLeftCheckBox"..i]
			SkinChannelFrame(frame)
			
			if i > 1 then
				local point, anchor, point2, x, y = frame:GetPoint()
				frame:SetPoint(point, anchor, point2, x, y-2)
			end
		end	
		
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end)]]
	
	--DROPDOWN MENU
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			_G["DropDownList"..i.."Backdrop"]:SetTemplate("Default", true)
			_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Default", true)
		end
	end)	
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)