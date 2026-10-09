local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, pairs, next = ipairs, pairs, next
local hooksecurefunc = hooksecurefunc

local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame

S:AddCallbackForAddon('Blizzard_ChatFrame', nil, nil, nil, nil, nil, 'blizzardOptions')

local function UpdateCheckboxes(frame)
	if not FCF_GetCurrentChatFrame() then return end

	local nameString = frame:GetName()..'Checkbox'
	for index in ipairs(frame.checkBoxTable) do
		local checkboxName = nameString..index
		local checkbox = _G[checkboxName]
		if not checkbox.IsSkinned then
			checkbox:StripTextures()
			S:HandleCheckBox(_G[checkboxName..'Check'])

			local colorClasses = not E.Modern and _G[checkboxName..'ColorClasses']
			if colorClasses then -- only the chat and channel list templates have one
				S:HandleCheckBox(colorClasses)
			end

			checkbox.IsSkinned = true
		end
	end
end

local function CreateTieredCheckboxes(frame, checkBoxTable)
	if frame.IsSkinned then return end

	local nameString = frame:GetName()..'Checkbox'
	for index, value in ipairs(checkBoxTable) do
		local checkboxName = nameString..index
		S:HandleCheckBox(_G[checkboxName])

		if value.subTypes then
			for i in ipairs(value.subTypes) do
				S:HandleCheckBox(_G[checkboxName..'_'..i])
			end
		end
	end

	frame.IsSkinned = true
end

local function UpdateWidth(frame)
	for tab in frame.tabPool:EnumerateActive() do
		if not tab.IsSkinned then
			tab:StripTextures()
			tab:SetAlpha(1)

			-- 1px above the category box, text centered inside
			tab:CreateBackdrop('Transparent')
			tab.backdrop:Point('TOPLEFT', 3, -11)
			tab.backdrop:Point('BOTTOMRIGHT', -3, 1)

			if not E.Modern then -- classic anchors the text between the side textures
				tab.Text:ClearAllPoints()
				tab.Text:Point('CENTER', 0, -5)
			end

			tab.IsSkinned = true
		end

		tab:SetWidth(80)
	end
end

local function UpdateSwatches(frame)
	if not frame.swatchTable then return end

	local nameString = frame:GetName()..'Swatch'
	for index in ipairs(frame.swatchTable) do
		local bu = _G[nameString..index]
		if not bu.IsSkinned then
			bu:StripTextures()
			bu:CreateBackdrop('Transparent')
			bu.backdrop:SetInside()

			bu.IsSkinned = true
		end
	end
end

local function CreateBoxes(frame)
	local boxName = frame:GetName()..'Box'
	for index in next, frame.boxTable do
		local box = _G[boxName..index]
		box.NineSlice:SetTemplate('Transparent')
		S:HandleButton(box.Button)
	end
end

local function UpdateMessageCheckboxes(frame)
	if not frame.checkBoxTable then return end

	local nameString = frame:GetName()..'Checkbox'
	for index in ipairs(frame.checkBoxTable) do
		local checkBox = _G[nameString..index]
		if not checkBox.IsSkinned then
			S:HandleCheckBox(checkBox)

			checkBox.IsSkinned = true
		end
	end
end

function S:Blizzard_ChatFrame()
	local ChatConfigFrame = _G.ChatConfigFrame
	ChatConfigFrame:StripTextures()
	ChatConfigFrame:SetTemplate('Transparent')

	if E.Modern then
		ChatConfigFrame.Header:StripTextures()
	end

	hooksecurefunc('ChatConfig_UpdateSwatches', UpdateSwatches)
	hooksecurefunc('ChatConfig_UpdateCheckboxes', UpdateCheckboxes)
	hooksecurefunc('ChatConfig_CreateTieredCheckboxes', CreateTieredCheckboxes)
	hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', UpdateWidth)

	if not E.Modern then
		hooksecurefunc('ChatConfig_CreateBoxes', CreateBoxes)
	end

	do
		local i = 1
		local tab = _G['CombatConfigTab'..i]
		while tab do
			tab:StripTextures()

			tab:SetWidth(i <= 2 and 90 or 70)

			i = i + 1
			tab = _G['CombatConfigTab'..i]
		end
	end

	for _, frame in next, { -- backdrops
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
		E.Modern and _G.ChatConfigOtherSettingsAdditionalColors or nil,
		_G.ChatConfigOtherSettingsCombat,
		_G.ChatConfigOtherSettingsPVP,
		_G.ChatConfigOtherSettingsSystem,
		_G.ChatConfigOtherSettingsCreature,
		_G.ChatConfigChannelSettingsLeft,
		_G.CombatConfigMessageSourcesDoneBy,
		_G.CombatConfigColorsUnitColors,
		_G.CombatConfigMessageSourcesDoneTo,
		_G.ChatConfigTextToSpeechChannelSettingsLeft
	} do
		frame:StripTextures()
	end

	_G.ChatConfigCategoryFrame:CreateBackdrop('Transparent')
	_G.ChatConfigCategoryFrame.backdrop:SetInside()

	_G.ChatConfigBackgroundFrame:CreateBackdrop('Transparent')
	_G.ChatConfigBackgroundFrame.backdrop:SetInside()

	_G.ChatConfigCombatSettingsFilters:CreateBackdrop('Transparent')
	_G.ChatConfigCombatSettingsFilters.backdrop:SetInside()

	if not E.Modern then
		for _, frame in next, {
			_G.ChatConfigCombatSettingsFiltersScrollFrame,
			_G.ChatConfigChannelSettingsAvailable
		} do
			frame:StripTextures()
			frame:SetTemplate('Transparent')
		end

		_G.ChatConfigChatSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')
		_G.ChatConfigChannelSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')
	end

	for _, box in pairs({ -- combat boxes
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
	}) do
		S:HandleCheckBox(box)
	end

	S:HandleButton(_G.CombatLogDefaultButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersCopyFilterButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersAddFilterButton)
	S:HandleButton(_G.ChatConfigCombatSettingsFiltersDeleteButton)
	S:HandleButton(_G.CombatConfigSettingsSaveButton)
	S:HandleButton(_G.ChatConfigFrameOkayButton)
	S:HandleButton(_G.ChatConfigFrameDefaultButton)
	S:HandleButton(_G.ChatConfigFrameRedockButton)

	_G.ChatConfigFrameRedockButton:Point('BOTTOMLEFT', _G.ChatConfigFrameDefaultButton, 'BOTTOMRIGHT', 1, 0)

	if not E.Modern then
		S:HandleButton(ChatConfigFrame.ToggleChatButton)
	end

	S:HandleNextPrevButton(_G.ChatConfigMoveFilterUpButton, 'up')
	S:HandleNextPrevButton(_G.ChatConfigMoveFilterDownButton, 'down')

	_G.ChatConfigMoveFilterUpButton:SetSize(22, 22)
	_G.ChatConfigMoveFilterDownButton:SetSize(22, 22)
	_G.ChatConfigCombatSettingsFiltersAddFilterButton:Point('RIGHT', _G.ChatConfigCombatSettingsFiltersDeleteButton, 'LEFT', -1, 0)
	_G.ChatConfigCombatSettingsFiltersCopyFilterButton:Point('RIGHT', _G.ChatConfigCombatSettingsFiltersAddFilterButton, 'LEFT', -1, 0)
	_G.ChatConfigMoveFilterUpButton:Point('TOPLEFT', _G.ChatConfigCombatSettingsFilters, 'BOTTOMLEFT', 3, 0)
	_G.ChatConfigMoveFilterDownButton:Point('LEFT', _G.ChatConfigMoveFilterUpButton, 'RIGHT', 1, 0)

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineBySource)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineByTarget)

	if E.Modern then
		S:HandleTrimScrollBar(_G.ChatConfigCombatSettingsFilters.ScrollBar)
	else
		S:HandleScrollBar(_G.ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
	end

	-- TextToSpeech
	_G.TextToSpeechButton:StripTextures()
	S:HandleButton(_G.TextToSpeechDefaultButton)
	S:HandleCheckBox(_G.TextToSpeechCharacterSpecificButton)

	local container = _G.TextToSpeechFramePanelContainer
	S:HandleButton(container.PlaySampleButton)
	S:HandleButton(container.PlaySampleAlternateButton)
	S:HandleDropDownBox(container.TtsVoiceDropdown)
	S:HandleDropDownBox(container.TtsVoiceAlternateDropdown)
	S:HandleSliderFrame(container.AdjustRateSlider.Slider)
	S:HandleSliderFrame(container.AdjustVolumeSlider.Slider)

	for _, checkbox in pairs({ -- check boxes
		'PlayActivitySoundWhenNotFocusedCheckButton',
		'PlaySoundSeparatingChatLinesCheckButton',
		'AddCharacterNameToSpeechCheckButton',
		'NarrateMyMessagesCheckButton',
		'UseAlternateVoiceForSystemMessagesCheckButton',
	}) do
		S:HandleCheckBox(container[checkbox])
	end

	hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', UpdateMessageCheckboxes)
end
