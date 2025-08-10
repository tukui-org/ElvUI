local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandleButton(button)
	if button.IsSkinned then return end

	if button.Border then
		button.Border:SetAlpha(0)
	end

	if button.Icon then
		S:HandleIcon(button.Icon)
	end

	button.IsSkinned = true
end

local function UpdateButton(self)
	self:ForEachFrame(HandleButton)
end

local function HandleOptionSlot(frame, skip)
	local option = frame.OptionsList
	option:StripTextures()
	option:SetTemplate()

	if not skip then
		hooksecurefunc(option.ScrollBox, 'Update', UpdateButton)
	end
end

local function SetRewards(rewardFrame)
	if not rewardFrame.backdrop then
		rewardFrame:CreateBackdrop('Transparent')
		rewardFrame.NameFrame:SetAlpha(0)
		S:HandleIcon(rewardFrame.Icon, true)
		S:HandleIconBorder(rewardFrame.IconBorder, rewardFrame.Icon.backdrop)
	end
end

local function DifficultyPickerFrame_Update(frame)
	frame:ForEachFrame(SetRewards)
end

local function UpdatePaginatedButtonDisplay(frame)
	if not frame.buttons then return end

	for _, button in next, frame.buttons do
		local icon = button.Icon
		if icon and not icon.backdrop then
			S:HandleIcon(icon, true)
		end
	end
end

function S:Blizzard_DelvesCompanionConfiguration()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local CompanionConfigurationFrame = _G.DelvesCompanionConfigurationFrame
	CompanionConfigurationFrame.CloseButton:ClearAllPoints()
	CompanionConfigurationFrame.CloseButton:Point('TOPRIGHT', CompanionConfigurationFrame, 'TOPRIGHT', -3, -3)
	S:HandlePortraitFrame(CompanionConfigurationFrame)
	S:HandleButton(CompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

	HandleOptionSlot(CompanionConfigurationFrame.CompanionCombatRoleSlot, true)
	HandleOptionSlot(CompanionConfigurationFrame.CompanionUtilityTrinketSlot)
	HandleOptionSlot(CompanionConfigurationFrame.CompanionCombatTrinketSlot)

	local CompanionAbilityListFrame = _G.DelvesCompanionAbilityListFrame
	S:HandlePortraitFrame(CompanionAbilityListFrame)
	S:HandleDropDownBox(CompanionAbilityListFrame.DelvesCompanionRoleDropdown) -- ??
	S:HandleNextPrevButton(CompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton)
	S:HandleNextPrevButton(CompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton)

	hooksecurefunc(CompanionAbilityListFrame, 'UpdatePaginatedButtonDisplay', UpdatePaginatedButtonDisplay)
end

S:AddCallbackForAddon('Blizzard_DelvesCompanionConfiguration')

function S:Blizzard_DelvesDifficultyPicker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local DifficultyPickerFrame = _G.DelvesDifficultyPickerFrame
	DifficultyPickerFrame:StripTextures()
	DifficultyPickerFrame:SetTemplate('Transparent')

	S:HandleCloseButton(DifficultyPickerFrame.CloseButton)
	DifficultyPickerFrame.CloseButton:ClearAllPoints()
	DifficultyPickerFrame.CloseButton:Point('TOPRIGHT', DifficultyPickerFrame, 'TOPRIGHT', -3, -3)
	S:HandleDropDownBox(DifficultyPickerFrame.Dropdown)
	S:HandleButton(DifficultyPickerFrame.EnterDelveButton)

	hooksecurefunc(DifficultyPickerFrame.DelveRewardsContainerFrame.ScrollBox, 'Update', DifficultyPickerFrame_Update)
end

S:AddCallbackForAddon('Blizzard_DelvesDifficultyPicker')

function S:Blizzard_DelvesDashboardUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	local Dashboard = _G.DelvesDashboardFrame
	Dashboard.DashboardBackground:SetAlpha(0)
	S:HandleButton(Dashboard.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

S:AddCallbackForAddon('Blizzard_DelvesDashboardUI')
