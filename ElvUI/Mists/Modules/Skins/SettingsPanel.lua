local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleDropDownArrow(button, direction)
	button.NormalTexture:SetAlpha(0)
	button.PushedTexture:SetAlpha(0)
	button:GetHighlightTexture():SetAlpha(0)

	local dis = button:GetDisabledTexture()
	S:SetupArrow(dis, direction)
	dis:SetVertexColor(0, 0, 0, .7)
	dis:SetDrawLayer('OVERLAY')
	dis:SetInside(button, 4, 4)

	local tex = button:CreateTexture(nil, 'ARTWORK')
	tex:SetInside(button, 4, 4)
	S:SetupArrow(tex, direction)
end

local function HandleOptionDropDown(option)
	local button = option.Button
	S:HandleButton(button)
	button.NormalTexture:SetAlpha(0)
	button.HighlightTexture:SetAlpha(0)

	HandleDropDownArrow(option.DecrementButton, 'left')
	HandleDropDownArrow(option.IncrementButton, 'right')
end

local function HandleDropdown(option)
	S:HandleButton(option.Dropdown)
	S:HandleButton(option.DecrementButton)
	S:HandleButton(option.IncrementButton)
end

local function HandleTabs(tab)
	if tab then
		tab:StripTextures(true)
	end
end

local function UpdateKeybindButtons(self)
	if not self.bindingsPool then return end
	for panel in self.bindingsPool:EnumerateActive() do
		if not panel.IsSkinned then
			S:HandleButton(panel.Button1)
			S:HandleButton(panel.Button2)
			if panel.CustomButton then S:HandleButton(panel.CustomButton) end
			panel.IsSkinned = true
		end
	end
end

local function UpdateHeaderExpand(self, expanded)
	self.collapseTex:SetAtlas(expanded and 'Soulbinds_Collection_CategoryHeader_Collapse' or 'Soulbinds_Collection_CategoryHeader_Expand', true)

	UpdateKeybindButtons(self)
end

local function HandleCheckbox(checkbox)
	checkbox:CreateBackdrop()
	checkbox.backdrop:SetInside(nil, 4, 4)

	for _, region in next, { checkbox:GetRegions() } do
		if region:IsObjectType('Texture') then
			if region:GetAtlas() == 'checkmark-minimal' then
				if E.private.skins.checkBoxSkin then
					region:SetTexture(E.Media.Textures.Melli)

					local checkedTexture = checkbox:GetCheckedTexture()
					checkedTexture:SetVertexColor(1, .82, 0, 0.8)
					checkedTexture:SetInside(checkbox.backdrop)
				end
			else
				region:SetTexture(E.ClearTexture)
			end
		end
	end
end

local function HandleControlGroup(controls)
	for _, child in next, { controls:GetChildren() } do
		if child.SliderWithSteppers then
			S:HandleStepSlider(child.SliderWithSteppers)
		end
		if child.Checkbox then
			S:HandleCheckBox(child.Checkbox)
		end
		if child.Control then
			HandleDropdown(child.Control)
		end
	end
end

local function HandleControlTab(tab)
	tab:StripTextures(nil, true)
	tab:CreateBackdrop()

	local spacing = E.Retail and 3 or 10
	tab.backdrop:Point('TOPLEFT', spacing, E.PixelMode and -12 or -14)
	tab.backdrop:Point('BOTTOMRIGHT', -spacing, -2)
end

local function CategoryListScrollUpdateChild(child)
	if not child.IsSkinned then
		if child.Background then
			child.Background:SetAlpha(0)
			child.Background:CreateBackdrop('Transparent')
			child.Background.backdrop:Point('TOPLEFT', 5, -5)
			child.Background.backdrop:Point('BOTTOMRIGHT', -5, 0)
		end

		local toggle = child.Toggle
		if toggle then
			toggle:GetPushedTexture():SetAlpha(0)
		end

		child.IsSkinned = true
	end
end

local function CategoryListScrollUpdate(frame)
	frame:ForEachFrame(CategoryListScrollUpdateChild)
end

local function SettingsListScrollUpdateChild(child)
	if not child.IsSkinned then
		if child.NineSlice then
			child.NineSlice:SetAlpha(0)
			child:CreateBackdrop('Transparent')
			child.backdrop:Point('TOPLEFT', 15, -30)
			child.backdrop:Point('BOTTOMRIGHT', -30, -5)
		end
		if child.Checkbox then
			HandleCheckbox(child.Checkbox)
		end
		if child.Dropdown then
			HandleOptionDropDown(child.Dropdown)
		end
		if child.Control then
			HandleDropdown(child.Control)
		end
		if child.ColorBlindFilterDropDown then
			HandleOptionDropDown(child.ColorBlindFilterDropDown)
		end
		if child.Button then
			if child.Button:GetWidth() < 250 then
				S:HandleButton(child.Button)
			else
				child.Button:StripTextures()
				child.Button.Right:SetAlpha(0)
				child.Button:CreateBackdrop('Transparent')
				child.Button.backdrop:Point('TOPLEFT', 2, -1)
				child.Button.backdrop:Point('BOTTOMRIGHT', -2, 3)

				child.Button.hl = child.Button:CreateTexture(nil, 'HIGHLIGHT')
				child.Button.hl:SetColorTexture(0.8, 0.8, 0, 0.6)
				child.Button.hl:SetInside(child.Button.backdrop)
				child.Button.hl:SetBlendMode('ADD')

				child.collapseTex = child.Button.backdrop:CreateTexture(nil, 'OVERLAY')
				child.collapseTex:Point('RIGHT', -10, 0)

				UpdateHeaderExpand(child, false)
				hooksecurefunc(child, 'EvaluateVisibility', UpdateHeaderExpand)
			end
		end
		if child.ToggleTest then
			S:HandleButton(child.ToggleTest)
			child.VUMeter:StripTextures()
			child.VUMeter.NineSlice:Hide()
			child.VUMeter:CreateBackdrop()
			child.VUMeter.backdrop:SetInside(nil, 4, 4)
			child.VUMeter.Status:SetStatusBarTexture(E.media.normTex)
			child.VUMeter.Status:SetInside(child.VUMeter.backdrop)
			E:RegisterStatusBar(child.VUMeter.Status)
		end
		if child.PushToTalkKeybindButton then
			S:HandleButton(child.PushToTalkKeybindButton)
		end
		if child.SliderWithSteppers then
			S:HandleStepSlider(child.SliderWithSteppers)
		end
		if child.Button1 and child.Button2 then
			S:HandleButton(child.Button1)
			S:HandleButton(child.Button2)
		end
		if child.Controls then
			for i = 1, #child.Controls do
				local control = child.Controls[i]
				if control.SliderWithSteppers then
					S:HandleStepSlider(control.SliderWithSteppers)
				end
			end
		end
		if child.BaseTab then
			HandleControlTab(child.BaseTab)
		end
		if child.RaidTab then
			HandleControlTab(child.RaidTab)
		end
		if child.BaseQualityControls then
			HandleControlGroup(child.BaseQualityControls)
		end
		if child.RaidQualityControls then
			HandleControlGroup(child.RaidQualityControls)
		end

		child.IsSkinned = true
	end
end

local function SettingsListScrollUpdate(frame)
	frame:ForEachFrame(SettingsListScrollUpdateChild)
end

function S:SettingsPanel()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.blizzardOptions) then return end

	local SettingsPanel = _G.SettingsPanel
	SettingsPanel:StripTextures()
	SettingsPanel.Bg:Hide()

	SettingsPanel:CreateBackdrop('Transparent')
	S:HandleCloseButton(SettingsPanel.ClosePanelButton)
	S:HandleEditBox(SettingsPanel.SearchBox)
	S:HandleButton(SettingsPanel.ApplyButton)
	S:HandleButton(SettingsPanel.CloseButton)

	HandleTabs(SettingsPanel.GameTab)
	HandleTabs(SettingsPanel.AddOnsTab)

	SettingsPanel.CategoryList:CreateBackdrop('Transparent')
	SettingsPanel.CategoryList.backdrop:SetInside()

	S:HandleTrimScrollBar(SettingsPanel.CategoryList.ScrollBar)

	hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, 'Update', CategoryListScrollUpdate)

	SettingsPanel.Container:CreateBackdrop('Transparent')
	SettingsPanel.Container.backdrop:SetInside()
	S:HandleButton(SettingsPanel.Container.SettingsList.Header.DefaultsButton)
	S:HandleTrimScrollBar(SettingsPanel.Container.SettingsList.ScrollBar)

	hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', SettingsListScrollUpdate)

	for _, frame in next, { _G.CompactUnitFrameProfiles, _G.CompactUnitFrameProfilesGeneralOptionsFrame } do
		for _, child in next, { frame:GetChildren() } do
			if child:IsObjectType('CheckButton') then
				S:HandleCheckBox(child)
			elseif child:IsObjectType('Button') then
				S:HandleButton(child)
			elseif child:IsObjectType('Frame') and (child.Left and child.Middle and child.Right) then
				S:HandleDropDownBox(child)
			end
		end
	end

	if _G.CompactUnitFrameProfilesSeparator then
		_G.CompactUnitFrameProfilesSeparator:SetAtlas('Options_HorizontalDivider')
	end

	if _G.CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG then
		_G.CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()
		_G.CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:CreateBackdrop('Transparent')
	end
end

S:AddCallback('SettingsPanel')
