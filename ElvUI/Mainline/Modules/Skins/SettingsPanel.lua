local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleTabs(tab)
	if tab then tab:StripTextures(true) end
end

local function ReskinDropDownArrow(button, direction)
	button.NormalTexture:SetAlpha(0)
	button.PushedTexture:SetAlpha(0)
	button:GetHighlightTexture():SetAlpha(0)

	local dis = button:GetDisabledTexture()
	--S:HandleNextPrevButton(dis, direction) -- ToDo: DF
	dis:SetVertexColor(0, 0, 0, .7)
	dis:SetDrawLayer('OVERLAY')
	dis:SetInside(button, 4, 4)

	local tex = button:CreateTexture(nil, 'ARTWORK')
	tex:SetInside(button, 4, 4)
	--S:HandleNextPrevButton(tex, direction) -- ToDo: DF
end

local function ReskinOptionDropDown(option)
	local button = option.Button
	S:HandleButton(button)
	button.NormalTexture:SetAlpha(0)
	button.HighlightTexture:SetAlpha(0)

	ReskinDropDownArrow(option.DecrementButton, 'left')
	ReskinDropDownArrow(option.IncrementButton, 'right')
end

local function UpdateKeybindButtons(self)
	if not self.bindingsPool then return end
	for panel in self.bindingsPool:EnumerateActive() do
		if not panel.isSkinned then
			S:HandleButton(panel.Button1)
			S:HandleButton(panel.Button2)
			if panel.CustomButton then S:HandleButton(panel.CustomButton) end
			panel.isSkinned = true
		end
	end
end

local function UpdateHeaderExpand(self, expanded)
	self.collapseTex:SetAtlas(expanded and 'Soulbinds_Collection_CategoryHeader_Collapse' or 'Soulbinds_Collection_CategoryHeader_Expand', true)

	UpdateKeybindButtons(self)
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

	hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				if child.Background then
					child.Background:SetAlpha(0)
					child.Background:CreateBackdrop('Transparent')
					child.Background.backdrop:SetPoint('TOPLEFT', 5, -5)
					child.Background.backdrop:SetPoint('BOTTOMRIGHT', -5, 0)
				end

				local toggle = child.Toggle
				if toggle then -- ToDo Handle the toggle. DF
					toggle:GetPushedTexture():SetAlpha(0)
				end

				child.isSkinned = true
			end
		end
	end)

	SettingsPanel.Container:CreateBackdrop('Transparent')
	SettingsPanel.Container.backdrop:SetInside()
	S:HandleButton(SettingsPanel.Container.SettingsList.Header.DefaultsButton)
	S:HandleTrimScrollBar(SettingsPanel.Container.SettingsList.ScrollBar)

	hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			if not child.isSkinned then
				if child.CheckBox then
					S:HandleCheckBox(child.CheckBox)
				end

				--[[if child.DropDown then
					ReskinOptionDropDown(child.DropDown)
				end
				if child.ColorBlindFilterDropDown then
					ReskinOptionDropDown(child.ColorBlindFilterDropDown)
				end]]

				for j = 1, 13 do
					local control = child['Control'..j]
					if control then
						if control.DropDown then
							ReskinOptionDropDown(control.DropDown)
						end
					end
				end

				if child.Button then
					if child.Button:GetWidth() < 250 then
						S:HandleButton(child.Button)
					else
						child.Button:StripTextures()
						child.Button.Right:SetAlpha(0)
						child.Button:CreateBackdrop('Transparent')
						child.Button.backdrop:SetPoint('TOPLEFT', 2, -1)
						child.Button.backdrop:SetPoint('BOTTOMRIGHT', -2, 3)

						child.Button.hl = child.Button:CreateTexture(nil, 'HIGHLIGHT')
						child.Button.hl:SetColorTexture(0.8, 0.8, 0, 0.6)
						child.Button.hl:SetInside(child.Button.backdrop)
						child.Button.hl:SetBlendMode('ADD')

						child.collapseTex = child.Button.backdrop:CreateTexture(nil, 'OVERLAY')
						child.collapseTex:SetPoint('RIGHT', -10, 0)

						UpdateHeaderExpand(child, false)
						hooksecurefunc(child, 'EvaluateVisibility', UpdateHeaderExpand)
					end
				end
				if child.ToggleTest then
					S:HandleButton(child.ToggleTest)
					child.VUMeter:StripTextures()
					child.VUMeter.NineSlice:Hide()
					child.VUMeter:CreateBackdrop()
					child.VUMeter.backdrop:SetInside(4, 4)
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

				child.isSkinned = true
			end
		end
	end)

	for _, frame in next, { _G.CompactUnitFrameProfiles, _G.CompactUnitFrameProfilesGeneralOptionsFrame } do
		for _, child in next, { frame:GetChildren() } do
			if child:IsObjectType('CheckButton') then
				S:HandleCheckBox(child)
			elseif child:IsObjectType('Button') then
				S:HandleButton(child)
			elseif child.Left and child.Middle and child.Right and child:IsObjectType('Frame') then
				S:HandleDropdownBox(child)
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
