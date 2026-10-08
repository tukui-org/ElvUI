local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_DelvesCompanionConfiguration', nil, nil, nil, nil, nil, 'lfg')
S:AddCallbackForAddon('Blizzard_DelvesDifficultyPicker', nil, nil, nil, nil, nil, 'lfg')

local function HandleButton(button)
	if button.IsSkinned then return end

	S:HandleIcon(button.Icon, true)
	S:HandleIconBorder(button.Border, button.Icon.backdrop)

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
	for _, button in next, frame.buttons do -- also holds a nodeIDs lookup table
		if button.Icon and not button.Icon.backdrop then
			S:HandleIcon(button.Icon, true)
		end
	end
end

function S:Blizzard_DelvesCompanionConfiguration()
	local CompanionConfiguration = _G.DelvesCompanionConfigurationFrame
	CompanionConfiguration.CloseButton:ClearAllPoints()
	CompanionConfiguration.CloseButton:Point('TOPRIGHT', CompanionConfiguration, 'TOPRIGHT', -3, -3)
	S:HandlePortraitFrame(CompanionConfiguration)
	S:HandleButton(CompanionConfiguration.CompanionConfigShowAbilitiesButton)

	local CompanionSlots = CompanionConfiguration.CompanionSlots
	HandleOptionSlot(CompanionSlots.CompanionCombatRoleSlot, true)
	HandleOptionSlot(CompanionSlots.CompanionFlavorSlot)
	HandleOptionSlot(CompanionSlots.CompanionUtilityTrinketSlot)
	HandleOptionSlot(CompanionSlots.CompanionCombatTrinketSlot)

	local CompanionAbilityListFrame = _G.DelvesCompanionAbilityListFrame
	S:HandlePortraitFrame(CompanionAbilityListFrame)
	S:HandleDropDownBox(CompanionAbilityListFrame.DelvesCompanionRoleDropdown) -- ??
	S:HandleNextPrevButton(CompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton)
	S:HandleNextPrevButton(CompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton)

	hooksecurefunc(CompanionAbilityListFrame, 'UpdatePaginatedButtonDisplay', UpdatePaginatedButtonDisplay)
end

function S:Blizzard_DelvesDifficultyPicker()
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
