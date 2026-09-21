local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local ipairs, pairs, next = ipairs, pairs, next

local function ChatConfigFrame_OnShow()
	for tab in _G.ChatConfigFrameChatTabManager.tabPool:EnumerateActive() do
		S:HandleButton(tab, true)
	end
end

local function UpdateWidth(frame)
	for tab in frame.tabPool:EnumerateActive() do
		if not tab.IsSkinned then
			tab:StripTextures()

			tab.IsSkinned = true
		end
	end
end

local function UpdateCheckboxes(frame)
	if not _G.FCF_GetCurrentChatFrame() then
		return
	end

	for index in ipairs(frame.checkBoxTable) do
		local frameName = frame:GetName()
		local checkName = frameName..'Checkbox'..index
		local checkBox = _G[checkName]
		if checkBox and not checkBox.IsSkinned then
			checkBox:StripTextures()
			S:HandleCheckBox(_G[checkName..'Check'])

			local colorClasses = _G[checkName..'ColorClasses']
			if colorClasses then
				S:HandleCheckBox(colorClasses)
			end

			checkBox.IsSkinned = true
		end
	end
end

local function UpdateTieredCheckboxes(frame, index)
	local frameName = frame:GetName()
	local checkName = frameName..'Checkbox'..index
	local checkBox = _G[checkName]
	if checkBox then
		S:HandleCheckBox(checkBox)
	end

	local group = frame.checkBoxTable[index]
	if group.subTypes then
		for k in ipairs(group.subTypes) do
			S:HandleCheckBox(_G[checkName..'_'..k])
		end
	end
end

local function UpdateSwatches(frame)
	if not _G.FCF_GetCurrentChatFrame() then
		return
	end
	for index in ipairs(frame.swatchTable) do
		_G[frame:GetName()..'Swatch'..index]:StripTextures()
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

function S:BlizzardOptions()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.blizzardOptions) then return end

	--Chat Config
	local ChatConfigFrame = _G.ChatConfigFrame

	hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', UpdateWidth)
	hooksecurefunc('ChatConfig_UpdateCheckboxes', UpdateCheckboxes)
	hooksecurefunc('ChatConfig_UpdateTieredCheckboxes', UpdateTieredCheckboxes)
	hooksecurefunc('ChatConfig_UpdateSwatches', UpdateSwatches)
	hooksecurefunc('ChatConfig_CreateBoxes', CreateBoxes)

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
	end

	_G.CombatConfigTab1:ClearAllPoints()
	_G.CombatConfigTab1:Point('BOTTOMLEFT', _G.ChatConfigBackgroundFrame, 'TOPLEFT', 6, -2)

	_G.ChatConfigChatSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')
	_G.ChatConfigChannelSettingsClassColorLegend.NineSlice:SetTemplate('Transparent')

	S:HandleEditBox(_G.CombatConfigSettingsNameEditBox)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineBySource)
	S:HandleRadioButton(_G.CombatConfigColorsColorizeEntireLineByTarget)
	S:HandleScrollBar(_G.ChatConfigCombatSettingsFiltersScrollFrameScrollBar)
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

	ChatConfigFrame:HookScript('OnShow', ChatConfigFrame_OnShow)

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

S:AddCallback('BlizzardOptions')
