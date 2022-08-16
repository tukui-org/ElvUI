local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, pairs, select = ipairs, pairs, select

local hooksecurefunc = hooksecurefunc
local UnitIsUnit = UnitIsUnit
local InCombatLockdown = InCombatLockdown

local function HandlePushToTalkButton(button)
	button:Size(button:GetSize())

	button.TopLeft:Hide()
	button.TopRight:Hide()
	button.BottomLeft:Hide()
	button.BottomRight:Hide()
	button.TopMiddle:Hide()
	button.MiddleLeft:Hide()
	button.MiddleRight:Hide()
	button.BottomMiddle:Hide()
	button.MiddleMiddle:Hide()
	button:SetHighlightTexture('')

	button:SetTemplate(nil, true)
	button:HookScript('OnEnter', S.SetModifiedBackdrop)
	button:HookScript('OnLeave', S.SetOriginalBackdrop)
end

local function Skin_InterfaceOptions_Buttons()
	for i = 1, #_G.INTERFACEOPTIONS_ADDONCATEGORIES do
		local button = _G['InterfaceOptionsFrameAddOnsButton'..i..'Toggle']
		if button and not button.IsSkinned then
			S:HandleCollapseTexture(button, true)
			button.IsSkinned = true
		end
	end
end

function S.AudioOptionsVoicePanel_InitializeCommunicationModeUI(btn)
	HandlePushToTalkButton(btn.PushToTalkKeybindButton)
end

function S:BlizzardOptions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.blizzardOptions) then return end

	-- Here we reskin all 'normal' buttons
	S:HandleButton(_G.ReadyCheckFrameYesButton)
	S:HandleButton(_G.ReadyCheckFrameNoButton)

	local ReadyCheckFrame = _G.ReadyCheckFrame
	_G.ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameYesButton:ClearAllPoints()
	_G.ReadyCheckFrameNoButton:ClearAllPoints()
	_G.ReadyCheckFrameYesButton:Point('TOPRIGHT', ReadyCheckFrame, 'CENTER', -3, -5)
	_G.ReadyCheckFrameNoButton:Point('TOPLEFT', ReadyCheckFrame, 'CENTER', 3, -5)
	_G.ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	_G.ReadyCheckFrameText:ClearAllPoints()
	_G.ReadyCheckFrameText:Point('TOP', 0, -15)

	_G.ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript('OnShow', function(frame)
		-- Bug fix, don't show it if player is initiator
		if frame.initiator and UnitIsUnit('player', frame.initiator) then
			frame:Hide()
		end
	end)

	_G.InterfaceOptionsFrame:SetClampedToScreen(true)
	_G.InterfaceOptionsFrame:SetMovable(true)
	_G.InterfaceOptionsFrame:EnableMouse(true)
	_G.InterfaceOptionsFrame:RegisterForDrag('LeftButton', 'RightButton')
	_G.InterfaceOptionsFrame:SetScript('OnDragStart', function(frame)
		if InCombatLockdown() then return end
		frame:StartMoving()
		frame.isMoving = true
	end)
	_G.InterfaceOptionsFrame:SetScript('OnDragStop', function(frame)
		frame:StopMovingOrSizing()
		frame.isMoving = false
	end)

	--Chat Config
	local ChatConfigFrame = _G.ChatConfigFrame

	hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', function(frame)
		for tab in frame.tabPool:EnumerateActive() do
			if not tab.IsSkinned then
				tab:StripTextures()

				tab.IsSkinned = true
			end
		end
	end)

	-- Chat Config
	local ChatFrames = {
		_G.ChatConfigFrame,
		_G.ChatConfigCategoryFrame,
		_G.ChatConfigBackgroundFrame,
		_G.ChatConfigCombatSettingsFilters,
		_G.ChatConfigCombatSettingsFiltersScrollFrame,
		_G.CombatConfigColorsHighlighting,
		_G.CombatConfigColorsColorizeUnitName,
		_G.CombatConfigColorsColorizeSpellNames,
		_G.CombatConfigColorsColorizeDamageNumber,
		_G.CombatConfigColorsColorizeDamageSchool,
		_G.CombatConfigColorsColorizeEntireLine,
		_G.ChatConfigChatSettingsLeft,
		_G.ChatConfigOtherSettingsCombat,
		_G.ChatConfigOtherSettingsPVP,
		_G.ChatConfigOtherSettingsSystem,
		_G.ChatConfigOtherSettingsCreature,
		_G.ChatConfigChannelSettingsAvailable,
		_G.ChatConfigChannelSettingsAvailableBox,
		_G.ChatConfigChannelSettingsLeft,
		_G.CombatConfigMessageSourcesDoneBy,
		_G.CombatConfigColorsUnitColors,
		_G.CombatConfigMessageSourcesDoneTo,
	}

	local ChatButtons = {
		_G.ChatConfigFrameDefaultButton,
		_G.ChatConfigFrameRedockButton,
		_G.ChatConfigFrameOkayButton,
		_G.ChatConfigFrame.ToggleChatButton,
		_G.ChatConfigCombatSettingsFiltersDeleteButton,
		_G.ChatConfigCombatSettingsFiltersAddFilterButton,
		_G.ChatConfigCombatSettingsFiltersCopyFilterButton,
		_G.CombatConfigSettingsSaveButton,
		_G.CombatLogDefaultButton,
	}

	local ChatCheckBoxs = {
		_G.CombatConfigColorsHighlightingLine,
		_G.CombatConfigColorsHighlightingAbility,
		_G.CombatConfigColorsHighlightingDamage,
		_G.CombatConfigColorsHighlightingSchool,
		_G.CombatConfigColorsColorizeUnitNameCheck,
		_G.CombatConfigColorsColorizeSpellNamesCheck,
		_G.CombatConfigColorsColorizeSpellNamesSchoolColoring,
		_G.CombatConfigColorsColorizeDamageNumberCheck,
		_G.CombatConfigColorsColorizeDamageNumberSchoolColoring,
		_G.CombatConfigColorsColorizeDamageSchoolCheck,
		_G.CombatConfigColorsColorizeEntireLineCheck,
		_G.CombatConfigFormattingShowTimeStamp,
		_G.CombatConfigFormattingShowBraces,
		_G.CombatConfigFormattingUnitNames,
		_G.CombatConfigFormattingSpellNames,
		_G.CombatConfigFormattingItemNames,
		_G.CombatConfigFormattingFullText,
		_G.CombatConfigSettingsShowQuickButton,
		_G.CombatConfigSettingsSolo,
		_G.CombatConfigSettingsParty,
		_G.CombatConfigSettingsRaid,
	}

	for _, Frame in pairs(ChatFrames) do
		Frame:StripTextures()
		Frame:SetTemplate('Transparent')
	end

	for _, CheckBox in pairs(ChatCheckBoxs) do
		S:HandleCheckBox(CheckBox)
	end

	for _, Button in pairs(ChatButtons) do
		S:HandleButton(Button)
	end

	for i in pairs(_G.COMBAT_CONFIG_TABS) do
		S:HandleTab(_G['CombatConfigTab'..i])
		_G['CombatConfigTab'..i].backdrop:Point('TOPLEFT', 0, -10)
		_G['CombatConfigTab'..i].backdrop:Point('BOTTOMRIGHT', -2, 3)
		_G['CombatConfigTab'..i..'Text']:Point('BOTTOM', 0, 10)
	end

	_G.CombatConfigTab1:ClearAllPoints()
	_G.CombatConfigTab1:Point('BOTTOMLEFT', _G.ChatConfigBackgroundFrame, 'TOPLEFT', 6, -2)

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterUpButton)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterDownButton)
	_G.ChatConfigMoveFilterUpButton:Size(19, 19)
	_G.ChatConfigMoveFilterDownButton:Size(19, 19)
	_G.ChatConfigMoveFilterUpButton:Point('TOPLEFT', '$parent', 'BOTTOMLEFT', 0, -3)
	_G.ChatConfigMoveFilterDownButton:Point('LEFT', _G.ChatConfigMoveFilterUpButton, 'RIGHT', 3, 0)

	_G.ChatConfigFrameOkayButton:Point('RIGHT', '$parentCancelButton', 'RIGHT', -1, -3)
	_G.ChatConfigFrameDefaultButton:Point('BOTTOMLEFT', 12, 10)
	_G.ChatConfigCombatSettingsFiltersDeleteButton:Point('TOPRIGHT', '$parent', 'BOTTOMRIGHT', -3, -1)
	_G.ChatConfigCombatSettingsFiltersAddFilterButton:Point('RIGHT', '$parentDeleteButton', 'LEFT', -2, 0)
	_G.ChatConfigCombatSettingsFiltersCopyFilterButton:Point('RIGHT', '$parentAddFilterButton', 'LEFT', -2, 0)

	ChatConfigFrame:HookScript('OnShow', function()
		for tab in _G.ChatConfigFrameChatTabManager.tabPool:EnumerateActive() do
			S:HandleButton(tab, true)
		end
	end)

	hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
		if not _G.FCF_GetCurrentChatFrame() then
			return
		end
		for index in ipairs(frame.checkBoxTable) do
			local checkBoxNameString = frame:GetName()..'CheckBox'
			local checkBoxName = checkBoxNameString..index
			local checkBox = _G[checkBoxName]
			local check = _G[checkBoxName..'Check']
			if checkBox and not checkBox.isSkinned then
				checkBox:StripTextures()
				S:HandleCheckBox(check)
				if _G[checkBoxName..'ColorClasses'] then
					S:HandleCheckBox(_G[checkBoxName..'ColorClasses'])
				end
				checkBox.isSkinned = true
			end
		end
	end)

	hooksecurefunc('ChatConfig_UpdateTieredCheckboxes', function(frame, index)
		local group = frame.checkBoxTable[index]
		local checkBox = _G[frame:GetName()..'CheckBox'..index]
		if checkBox then
			S:HandleCheckBox(checkBox)
		end
		if group.subTypes then
			for k in ipairs(group.subTypes) do
				S:HandleCheckBox(_G[frame:GetName()..'CheckBox'..index..'_'..k])
			end
		end
	end)

	hooksecurefunc('ChatConfig_UpdateSwatches', function(frame)
		if not _G.FCF_GetCurrentChatFrame() then
			return
		end
		for index in ipairs(frame.swatchTable) do
			_G[frame:GetName()..'Swatch'..index]:StripTextures()
		end
	end)

	local OptionsFrames = { _G.InterfaceOptionsFrame, _G.InterfaceOptionsFrameCategories, _G.InterfaceOptionsFramePanelContainer, _G.InterfaceOptionsFrameAddOns, _G.VideoOptionsFrame, _G.VideoOptionsFrameCategoryFrame, _G.VideoOptionsFramePanelContainer, _G.Display_, _G.Graphics_, _G.RaidGraphics_ }
	local OptionsFrameBackdrops = { _G.AudioOptionsSoundPanelHardware, _G.AudioOptionsSoundPanelVolume, _G.AudioOptionsSoundPanelPlayback, _G.AudioOptionsVoicePanelTalking, _G.AudioOptionsVoicePanelListening, _G.AudioOptionsVoicePanelBinding }
	local OptionsButtons = { _G.GraphicsButton, _G.RaidButton }

	local InterfaceOptions = {
		_G.InterfaceOptionsFrame,
		_G.InterfaceOptionsControlsPanel,
		_G.InterfaceOptionsCombatPanel,
		_G.InterfaceOptionsDisplayPanel,
		_G.InterfaceOptionsSocialPanel,
		_G.InterfaceOptionsActionBarsPanel,
		_G.InterfaceOptionsNamesPanel,
		_G.InterfaceOptionsNamesPanelFriendly,
		_G.InterfaceOptionsNamesPanelEnemy,
		_G.InterfaceOptionsNamesPanelUnitNameplates,
		_G.InterfaceOptionsCameraPanel,
		_G.InterfaceOptionsMousePanel,
		_G.InterfaceOptionsAccessibilityPanel,
		_G.VideoOptionsFrame,
		_G.Display_,
		_G.Graphics_,
		_G.RaidGraphics_,
		_G.Advanced_,
		_G.NetworkOptionsPanel,
		_G.InterfaceOptionsLanguagesPanel,
		_G.AudioOptionsSoundPanel,
		_G.AudioOptionsSoundPanelHardware,
		_G.AudioOptionsSoundPanelVolume,
		_G.AudioOptionsSoundPanelPlayback,
		_G.AudioOptionsVoicePanel,
		_G.CompactUnitFrameProfiles,
		_G.CompactUnitFrameProfilesGeneralOptionsFrame,
	}

	for _, Frame in pairs(OptionsFrames) do
		Frame:StripTextures()
		Frame:SetTemplate('Transparent')
	end

	for _, Frame in pairs(OptionsFrameBackdrops) do
		Frame:StripTextures()
		Frame:CreateBackdrop('Transparent')
	end

	for _, Tab in pairs(OptionsButtons) do
		S:HandleButton(Tab, true)
	end

	for _, Panel in pairs(InterfaceOptions) do
		if Panel then
			for i = 1, Panel:GetNumChildren() do
				local Child = select(i, Panel:GetChildren())
				if Child:IsObjectType('CheckButton') then
					S:HandleCheckBox(Child)
				elseif Child:IsObjectType('Button') then
					S:HandleButton(Child, true)
				elseif Child:IsObjectType('Slider') then
					S:HandleSliderFrame(Child)
				elseif Child:IsObjectType('Tab') then
					S:HandleTab(Child)
				elseif Child:IsObjectType('Frame') and Child.Left and Child.Middle and Child.Right then
					S:HandleDropDownBox(Child)
				end
			end
		end
	end

	_G.InterfaceOptionsFrameTab1:Point('BOTTOMLEFT', _G.InterfaceOptionsFrameCategories, 'TOPLEFT', 6, 1)
	S:HandleButton(_G.InterfaceOptionsFrameTab1)
	_G.InterfaceOptionsFrameTab2:Point('TOPLEFT', _G.InterfaceOptionsFrameTab1, 'TOPRIGHT', 1, 0)
	S:HandleButton(_G.InterfaceOptionsFrameTab2)
	_G.InterfaceOptionsSocialPanel.EnableTwitter.Logo:SetAtlas('WoWShare-TwitterLogo')

	-- Features tab
	S:HandleCheckBox(_G.InterfaceOptionsFeaturesPanelEquipmentManager)
	S:HandleCheckBox(_G.InterfaceOptionsFeaturesPanelPreviewTalentChanges)

	-- Plus minus buttons in addons category
	hooksecurefunc('InterfaceOptions_AddCategory', Skin_InterfaceOptions_Buttons)
	Skin_InterfaceOptions_Buttons()

	-- Create New Raid Profle
	local newProfileDialog = _G.CompactUnitFrameProfilesNewProfileDialog
	if newProfileDialog then
		newProfileDialog:StripTextures()
		newProfileDialog:CreateBackdrop('Transparent')

		S:HandleDropDownBox(_G.CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector)
		S:HandleButton(_G.CompactUnitFrameProfilesNewProfileDialogCreateButton)
		S:HandleButton(_G.CompactUnitFrameProfilesNewProfileDialogCancelButton)

		if newProfileDialog.editBox then
			S:HandleEditBox(newProfileDialog.editBox)
			newProfileDialog.editBox:Size(210, 25)
		end
	end

	-- Delete Raid Profile
	local deleteProfileDialog = _G.CompactUnitFrameProfilesDeleteProfileDialog
	if deleteProfileDialog then
		deleteProfileDialog:StripTextures()
		deleteProfileDialog:CreateBackdrop('Transparent')

		S:HandleButton(_G.CompactUnitFrameProfilesDeleteProfileDialogDeleteButton)
		S:HandleButton(_G.CompactUnitFrameProfilesDeleteProfileDialogCancelButton)
	end

	-- Colorblind Submenu
	S:HandleDropDownBox(_G.InterfaceOptionsColorblindPanelColorFilterDropDown, 260)
	S:HandleSliderFrame(_G.InterfaceOptionsColorblindPanelColorblindStrengthSlider)

	-- Toggle Test Audio Button
	S:HandleButton(_G.AudioOptionsVoicePanel.TestInputDevice.ToggleTest)

	local VUMeter = _G.AudioOptionsVoicePanelTestInputDevice.VUMeter
	VUMeter.NineSlice:Hide()
	VUMeter.Status:CreateBackdrop()
	VUMeter.Status:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(VUMeter.Status)

	-- PushToTalk KeybindButton
	hooksecurefunc('AudioOptionsVoicePanel_InitializeCommunicationModeUI', S.AudioOptionsVoicePanel_InitializeCommunicationModeUI)

	-- New Voice Sliders
	S:HandleSliderFrame(_G.UnitPopupVoiceSpeakerVolume.Slider)
	S:HandleSliderFrame(_G.UnitPopupVoiceMicrophoneVolume.Slider)
	S:HandleSliderFrame(_G.UnitPopupVoiceUserVolume.Slider)
end

S:AddCallback('BlizzardOptions')
