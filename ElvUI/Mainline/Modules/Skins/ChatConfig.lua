local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, pairs, select = ipairs, pairs, select

local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local hooksecurefunc = hooksecurefunc

local function ReskinPickerOptions(self)
	local scrollTarget = self.ScrollBox.ScrollTarget
	if scrollTarget then
		for i = 1, scrollTarget:GetNumChildren() do
			local child = select(i, scrollTarget:GetChildren())
			if not child.IsSkinned then
				child.UnCheck:SetTexture(nil)
				child.Highlight:SetColorTexture(1, .82, 0, 0.4)

				local check = child.Check
				check:SetColorTexture(1, .82, 0, 0.8)
				check:SetSize(10, 10)
				check:SetPoint('LEFT', 2, 0)
				check:CreateBackdrop('Transparent')

				child.IsSkinned = true
			end
		end
	end
end

local function HandleVoicePicker(voicePicker)
	local customFrame = voicePicker:GetChildren()
	customFrame:StripTextures()
	customFrame:CreateBackdrop('Transparent')
	voicePicker:HookScript('OnShow', ReskinPickerOptions)
end

function S:ChatConfig()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.blizzardOptions) then return end

	local ChatConfigFrame = _G.ChatConfigFrame
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate('Transparent')

	ChatConfigFrame.Header:StripTextures()

	hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
		if not FCF_GetCurrentChatFrame() then return end

		local nameString = frame:GetName()..'CheckBox'
		for index in ipairs(frame.checkBoxTable) do
			local checkBoxName = nameString..index
			local checkbox = _G[checkBoxName]
			if checkbox and not checkbox.IsSkinned then
				checkbox:StripTextures()
				S:HandleCheckBox(_G[checkBoxName..'Check'])

				checkbox.IsSkinned = true
			end
		end
	end)

	hooksecurefunc('ChatConfig_CreateTieredCheckboxes', function(frame, checkBoxTable)
		if frame.IsSkinned then return end

		local nameString = frame:GetName()..'CheckBox'
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = nameString..index
			S:HandleCheckBox(_G[checkBoxName])

			if value.subTypes then
				for i in ipairs(value.subTypes) do
					S:HandleCheckBox(_G[checkBoxName..'_'..i])
				end
			end
		end

		frame.IsSkinned = true
	end)

	hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', function(self)
		for tab in self.tabPool:EnumerateActive() do
			if not tab.IsSkinned then
				tab:StripTextures()

				tab.IsSkinned = true
			end
		end
	end)

	for i = 1, 5 do
		local tab = _G['CombatConfigTab'..i]
		if tab then
			tab:StripTextures()

			if tab.Text then
				tab.Text:SetWidth(tab.Text:GetWidth() + 10)
			end
		end
	end

	local backdrops = {
		_G.ChatConfigCategoryFrame,
		_G.ChatConfigBackgroundFrame,
		_G.ChatConfigCombatSettingsFilters,
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
		_G.ChatConfigChannelSettingsLeft,
		_G.CombatConfigMessageSourcesDoneBy,
		_G.CombatConfigColorsUnitColors,
		_G.CombatConfigMessageSourcesDoneTo,
	}
	for _, frame in pairs(backdrops) do
		frame:StripTextures()
	end

	_G.ChatConfigCategoryFrame:CreateBackdrop('Transparent')
	_G.ChatConfigCategoryFrame.backdrop:SetInside()

	_G.ChatConfigBackgroundFrame:CreateBackdrop('Transparent')
	_G.ChatConfigBackgroundFrame.backdrop:SetInside()

	_G.ChatConfigCombatSettingsFilters:CreateBackdrop('Transparent')
	_G.ChatConfigCombatSettingsFilters.backdrop:SetInside()

	local combatBoxes = {
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
		_G.CombatConfigSettingsRaid
	}
	for _, box in pairs(combatBoxes) do
		S:HandleCheckBox(box)
	end

	hooksecurefunc('ChatConfig_UpdateSwatches', function(frame)
		if not frame.swatchTable then return end

		local nameString = frame:GetName()..'Swatch'
		local baseName, colorSwatch
		for index in ipairs(frame.swatchTable) do
			baseName = nameString..index
			local bu = _G[baseName]
			if not bu.IsSkinned then
				bu:StripTextures()
				bu:CreateBackdrop('Transparent')
				bu.backdrop:SetInside()

				bu.IsSkinned = true
			end
		end
	end)

	S:HandleButton(_G.CombatLogDefaultButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersCopyFilterButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersAddFilterButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersDeleteButton)
	S:HandleButton(_G.CombatConfigSettingsSaveButton)
	S:HandleButton(_G.ChatConfigFrameOkayButton)
	S:HandleButton(_G.ChatConfigFrameDefaultButton)
	S:HandleButton(_G.ChatConfigFrameRedockButton)
	S:HandleButton(_G.ChatConfigFrame.ToggleChatButton)
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterUpButton, 'up')
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterDownButton, 'down')
	_G.ChatConfigMoveFilterUpButton:SetSize(22, 22)
	_G.ChatConfigMoveFilterDownButton:SetSize(22, 22)
	_G.ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint('RIGHT', _G.ChatConfigCombatSettingsFiltersDeleteButton, 'LEFT', -1, 0)
	_G.ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint('RIGHT', _G.ChatConfigCombatSettingsFiltersAddFilterButton, 'LEFT', -1, 0)
	_G.ChatConfigMoveFilterUpButton:SetPoint('TOPLEFT', _G.ChatConfigCombatSettingsFilters, 'BOTTOMLEFT', 3, 0)
	_G.ChatConfigMoveFilterDownButton:SetPoint('LEFT', _G.ChatConfigMoveFilterUpButton, 'RIGHT', 1, 0)

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineBySource)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineByTarget)
	S:HandleTrimScrollBar(_G.ChatConfigCombatSettingsFilters.ScrollBar)

	-- TextToSpeech
	_G.TextToSpeechButton:StripTextures()

	S:HandleButton(_G.TextToSpeechFramePlaySampleButton)
	S:HandleButton(_G.TextToSpeechFramePlaySampleAlternateButton)
	S:HandleButton(_G.TextToSpeechDefaultButton)
	S:HandleCheckBox(_G.TextToSpeechCharacterSpecificButton)

	S:HandleDropDownBox(_G.TextToSpeechFrameTtsVoiceDropdown)
	S:HandleDropDownBox(_G.TextToSpeechFrameTtsVoiceAlternateDropdown)
	S:HandleSliderFrame(_G.TextToSpeechFrameAdjustRateSlider)
	S:HandleSliderFrame(_G.TextToSpeechFrameAdjustVolumeSlider)

	local checkboxes = {
		'PlayActivitySoundWhenNotFocusedCheckButton',
		'PlaySoundSeparatingChatLinesCheckButton',
		'AddCharacterNameToSpeechCheckButton',
		'NarrateMyMessagesCheckButton',
		'UseAlternateVoiceForSystemMessagesCheckButton',
	}
	for _, checkbox in pairs(checkboxes) do
		local check = _G.TextToSpeechFramePanelContainer[checkbox]
		S:HandleCheckBox(check)
	end

	hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', function(frame)
		local checkBoxTable = frame.checkBoxTable
		if checkBoxTable then
			local checkBoxNameString = frame:GetName()..'CheckBox'
			local checkBoxName, checkBox
			for index in ipairs(checkBoxTable) do
				checkBoxName = checkBoxNameString..index
				checkBox = _G[checkBoxName]
				if checkBox and not checkBox.IsSkinned then
					S:HandleCheckBox(checkBox)

					checkBox.IsSkinned = true
				end
			end
		end
	end)

	HandleVoicePicker(_G.TextToSpeechFrameTtsVoicePicker)
	HandleVoicePicker(_G.TextToSpeechFrameTtsVoiceAlternatePicker)

	_G.ChatConfigTextToSpeechChannelSettingsLeft:StripTextures()
end

S:AddCallback('ChatConfig')
