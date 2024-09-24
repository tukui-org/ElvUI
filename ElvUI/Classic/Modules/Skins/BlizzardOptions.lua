local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, pairs, next = ipairs, pairs, next

local hooksecurefunc = hooksecurefunc

function S:BlizzardOptions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.blizzardOptions) then return end

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
		_G.ChatConfigTextToSpeechChannelSettingsLeft
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

	_G.ChatConfigChatSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')
	_G.ChatConfigChannelSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterUpButton)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterDownButton)
	_G.ChatConfigMoveFilterUpButton:Size(19)
	_G.ChatConfigMoveFilterDownButton:Size(19)
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
			local checkBoxNameString = frame:GetName()..'Checkbox'
			local checkBoxName = checkBoxNameString..index
			local checkBox = _G[checkBoxName]
			local check = _G[checkBoxName..'Check']
			if checkBox and not checkBox.IsSkinned then
				checkBox:StripTextures()
				S:HandleCheckBox(check)
				if _G[checkBoxName..'ColorClasses'] then
					S:HandleCheckBox(_G[checkBoxName..'ColorClasses'])
				end
				checkBox.IsSkinned = true
			end
		end
	end)

	hooksecurefunc('ChatConfig_UpdateTieredCheckboxes', function(frame, index)
		local group = frame.checkBoxTable[index]
		local checkBox = _G[frame:GetName()..'Checkbox'..index]
		if checkBox then
			S:HandleCheckBox(checkBox)
		end
		if group.subTypes then
			for k in ipairs(group.subTypes) do
				S:HandleCheckBox(_G[frame:GetName()..'Checkbox'..index..'_'..k])
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

	hooksecurefunc('ChatConfig_CreateBoxes', function(frame)
		local boxName = frame:GetName()..'Box'

		if frame.boxTable then
			for index in next, frame.boxTable do
				local box = _G[boxName..index]
				if box then
					box.NineSlice:SetTemplate('Transparent')
					if box.Button then
						S:HandleButton(box.Button)
					end
				end
			end
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
			for _, Child in next, { Panel:GetChildren() } do
				if Child:IsObjectType('CheckButton') then
					S:HandleCheckBox(Child)
				elseif Child:IsObjectType('Button') then
					S:HandleButton(Child, true)
				elseif Child:IsObjectType('Slider') then
					S:HandleSliderFrame(Child)
				elseif Child:IsObjectType('Tab') then
					S:HandleTab(Child)
				elseif Child:IsObjectType('Frame') and (Child.Left and Child.Middle and Child.Right) then
					S:HandleDropDownBox(Child)
				end
			end
		end
	end

	-- Create New Raid Profle
	local newProfileDialog = _G.CompactUnitFrameProfilesNewProfileDialog
	if newProfileDialog then
		newProfileDialog:StripTextures()
		newProfileDialog:CreateBackdrop('Transparent')

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

	-- TextToSpeech
	_G.TextToSpeechButton:StripTextures()

	S:HandleButton(_G.TextToSpeechFramePlaySampleButton)
	S:HandleButton(_G.TextToSpeechFramePlaySampleAlternateButton)
	S:HandleButton(_G.TextToSpeechDefaultButton)
	S:HandleCheckBox(_G.TextToSpeechCharacterSpecificButton)

	S:HandleSliderFrame(_G.TextToSpeechFrameAdjustRateSlider)
	S:HandleSliderFrame(_G.TextToSpeechFrameAdjustVolumeSlider)

	for _, checkbox in pairs({ -- check boxes
		'PlayActivitySoundWhenNotFocusedCheckButton',
		'PlaySoundSeparatingChatLinesCheckButton',
		'AddCharacterNameToSpeechCheckButton',
		'NarrateMyMessagesCheckButton',
		'UseAlternateVoiceForSystemMessagesCheckButton',
	}) do
		S:HandleCheckBox(_G.TextToSpeechFramePanelContainer[checkbox])
	end

	hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', function(frame)
		if not frame.checkBoxTable then return end

		local nameString = frame:GetName()..'CheckBox'
		for index in ipairs(frame.checkBoxTable) do
			local checkBox = _G[nameString..index]
			if checkBox and not checkBox.IsSkinned then
				S:HandleCheckBox(checkBox)

				checkBox.IsSkinned = true
			end
		end
	end)
end

S:AddCallback('BlizzardOptions')
