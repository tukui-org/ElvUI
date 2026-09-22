local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local ITEMQUALITY_ARTIFACT = Enum.ItemQuality.Artifact
local CurrencyContainerUtil_GetCurrencyContainerInfo = CurrencyContainerUtil.GetCurrencyContainerInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetItemInfo = C_Item.GetItemInfo

local categoryButtonIcons = {
	236396, -- interface\icons\achievement_bg_winwsg
	236368, -- interface\icons\achievement_bg_killxenemies_generalsroom
	464820, -- interface\icons\achievement_general_stayclassy
	236179, -- interface\icons\ability_hunter_focusedaim
}

local function HandleRoleButton(button)
	local checkbox = button.checkButton
	checkbox:OffsetFrameLevel(1)
	S:HandleCheckBox(checkbox)

	button:Size(40)
	button.IconPulse:Size(40)
	button.EdgePulse:Size(40)
	button.shortageBorder:Size(40)
end

local function SpecificScrollUpdateChild(bu)
	if not bu.IsSkinned then

		bu:StripTextures()
		bu:SetTemplate()
		bu:StyleButton(nil, true)

		bu.SelectedTexture:SetInside(bu.backdrop)
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		bu.Icon:SetTexCoords()
		bu.Icon:Point('TOPLEFT', 5, -3)

		bu.IsSkinned = true
	end
end

local function SpecificScrollUpdate(frame)
	frame:ForEachFrame(SpecificScrollUpdateChild)
end

local function HandleCategoryButtons(name, icons)
	local index = 1
	local button = _G.PVPQueueFrame[name..index]
	while button do
		button.Ring:Hide()
		button.CircleMask:Hide()
		button.Background:Kill()

		S:HandleButton(button)

		local icon = button.Icon
		local texture = icons[index]
		if texture then
			icon:SetTexture(texture)
		end

		icon:Size(45)
		icon:ClearAllPoints()
		icon:Point('LEFT', 10, 0)

		S:HandleIcon(icon, true)

		index = index + 1
		button = _G.PVPQueueFrame[name..index]
	end
end

function S:Blizzard_PVPUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	_G.PVPUIFrame:StripTextures()

	local PVPQueueFrame = _G.PVPQueueFrame
	local HonorInset = PVPQueueFrame.HonorInset
	HonorInset:SetTemplate('Transparent')
	HonorInset.Background:Hide()
	HonorInset.NineSlice:Hide()

	-- Plunderstorm
	_G.PlunderstormFrame.Inset:StripTextures()
	S:HandleButton(_G.PlunderstormFrame.StartQueue)
	S:HandleButton(HonorInset.PlunderstormPanel.PlunderstoreButton)

	HandleCategoryButtons('CategoryButton', categoryButtonIcons)

	local SeasonReward = HonorInset.RatedPanel.SeasonRewardFrame
	SeasonReward:CreateBackdrop()
	SeasonReward.Icon:SetInside(SeasonReward.backdrop)
	SeasonReward.Icon:SetTexCoords()
	SeasonReward.CircleMask:Hide()
	SeasonReward.Ring:Hide()

	-- Honor Frame
	local HonorFrame = _G.HonorFrame
	HonorFrame:StripTextures()

	S:HandleTrimScrollBar(_G.HonorFrame.SpecificScrollBar)
	S:HandleDropDownBox(_G.HonorFrameTypeDropdown, 230)
	S:HandleButton(_G.HonorFrameQueueButton)

	local BonusFrame = HonorFrame.BonusFrame
	BonusFrame:StripTextures()
	BonusFrame.ShadowOverlay:Hide()
	BonusFrame.WorldBattlesTexture:Hide()

	for _, bonusButton in next, {'RandomBGButton', 'Arena1Button', 'RandomEpicBGButton', 'BrawlButton', 'BrawlButton2'} do
		local bu = BonusFrame[bonusButton]
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward.Border:Hide()
		reward.CircleMask:Hide()
		S:HandleIcon(reward.Icon, true)

		reward.EnlistmentBonus:StripTextures()
		reward.EnlistmentBonus:SetTemplate()
		reward.EnlistmentBonus:Size(20)
		reward.EnlistmentBonus:Point('TOPRIGHT', 2, 2)

		local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
		EnlistmentBonusIcon:Point('TOPLEFT', reward.EnlistmentBonus, 'TOPLEFT', 2, -2)
		EnlistmentBonusIcon:Point('BOTTOMRIGHT', reward.EnlistmentBonus, 'BOTTOMRIGHT', -2, 2)
		EnlistmentBonusIcon:SetTexture([[Interface\Icons\achievement_guildperk_honorablemention_rank2]])
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	-- Honor Frame Specific Buttons
	hooksecurefunc(HonorFrame.SpecificScrollBox, 'Update', SpecificScrollUpdate)

	HandleRoleButton(HonorFrame.RoleList.TankIcon)
	HandleRoleButton(HonorFrame.RoleList.HealerIcon)
	HandleRoleButton(HonorFrame.RoleList.DPSIcon)

	-- Conquest Frame
	local ConquestFrame = _G.ConquestFrame
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	S:HandleButton(_G.ConquestJoinButton)

	HandleRoleButton(ConquestFrame.RoleList.TankIcon)
	HandleRoleButton(ConquestFrame.RoleList.HealerIcon)
	HandleRoleButton(ConquestFrame.RoleList.DPSIcon)

	for _, bu in next, {ConquestFrame.RatedSoloShuffle, ConquestFrame.RatedBGBlitz, ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG} do
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward.Border:Hide()
		reward.CircleMask:Hide()
		S:HandleIcon(reward.Icon, true)
	end

	ConquestFrame.Arena3v3:Point('TOP', ConquestFrame.Arena2v2, 'BOTTOM', 0, -2)

	-- Item Borders for HonorFrame & ConquestFrame
	hooksecurefunc('PVPUIFrame_ConfigureRewardFrame', function(rewardFrame, _, _, itemRewards, currencyRewards)
		local rewardTexture, rewardQuaility, _ = nil, 1

		if currencyRewards then
			for _, reward in next, currencyRewards do
				local info = C_CurrencyInfo_GetCurrencyInfo(reward.id)
				if info and info.quality == ITEMQUALITY_ARTIFACT then
					_, rewardTexture, _, rewardQuaility = CurrencyContainerUtil_GetCurrencyContainerInfo(reward.id, reward.quantity, info.name, info.iconFileID, info.quality)
				end
			end
		end

		if not rewardTexture and itemRewards then
			local reward = itemRewards[1]
			if reward then
				_, _, rewardQuaility, _, _, _, _, _, _, rewardTexture = GetItemInfo(reward.id)
			end
		end

		if rewardTexture then
			rewardFrame.Icon:SetTexture(rewardTexture)

			if rewardFrame.Icon.backdrop then
				local r, g, b = E:GetItemQualityColor(rewardQuaility)
				rewardFrame.Icon.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end
	end)

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.ConquestTooltip)
	end

	-- New Season Frame
	local NewSeasonPopup = _G.PVPQueueFrame.NewSeasonPopup
	S:HandleButton(NewSeasonPopup.Leave)
	NewSeasonPopup:StripTextures()
	NewSeasonPopup:SetTemplate()
	NewSeasonPopup:SetFrameLevel(5)

	local RewardFrame = NewSeasonPopup.SeasonRewardFrame
	RewardFrame:CreateBackdrop()
	RewardFrame.CircleMask:Hide()
	RewardFrame.Ring:Hide()
	RewardFrame.Icon:SetTexCoords()
	RewardFrame.backdrop:SetOutside(RewardFrame.Icon)

	NewSeasonPopup.NewSeason:SetTextColor(1, .8, 0)
	NewSeasonPopup.NewSeason:SetShadowOffset(1, -1)
	NewSeasonPopup.SeasonRewardText:SetTextColor(1, .8, 0)
	NewSeasonPopup.SeasonRewardText:SetShadowOffset(1, -1)
	NewSeasonPopup.SeasonDescriptionHeader:SetTextColor(1, 1, 1)
	NewSeasonPopup.SeasonDescriptionHeader:SetShadowOffset(1, -1)

	NewSeasonPopup:HookScript('OnShow', function(popup)
		for _, text in next, popup.SeasonDescriptions do -- created in the popup's own OnShow
			text:SetTextColor(1, 1, 1)
			text:SetShadowOffset(1, -1)
		end
	end)

	-- Training Grounds Frame
	local TrainingGroundsFrame = _G.TrainingGroundsFrame
	TrainingGroundsFrame:StripTextures()

	S:HandleDropDownBox(TrainingGroundsFrame.TypeDropdown, 230)
	S:HandleButton(TrainingGroundsFrame.QueueButton)

	local BonusTrainingGroundList = TrainingGroundsFrame.BonusTrainingGroundList
	BonusTrainingGroundList:StripTextures()
	BonusTrainingGroundList.ShadowOverlay:Hide()
	BonusTrainingGroundList.WorldBattlesTexture:Hide()

	for _, bonusButton in next, {'RandomTrainingGroundButton', 'RandomTrainingGroundArenaButton'} do
		local bu = BonusTrainingGroundList[bonusButton]
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward.Border:Hide()
		reward.CircleMask:Hide()
		S:HandleIcon(reward.Icon, true)

		reward.EnlistmentBonus:StripTextures()
		reward.EnlistmentBonus:SetTemplate()
		reward.EnlistmentBonus:Size(20)
		reward.EnlistmentBonus:Point('TOPRIGHT', 2, 2)

		local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
		EnlistmentBonusIcon:Point('TOPLEFT', reward.EnlistmentBonus, 'TOPLEFT', 2, -2)
		EnlistmentBonusIcon:Point('BOTTOMRIGHT', reward.EnlistmentBonus, 'BOTTOMRIGHT', -2, 2)
		EnlistmentBonusIcon:SetTexture([[Interface\Icons\achievement_guildperk_honorablemention_rank2]])
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	HandleRoleButton(TrainingGroundsFrame.RoleList.TankIcon)
	HandleRoleButton(TrainingGroundsFrame.RoleList.HealerIcon)
	HandleRoleButton(TrainingGroundsFrame.RoleList.DPSIcon)

	S:HandleTrimScrollBar(TrainingGroundsFrame.SpecificTrainingGroundList.ScrollBar)

	-- Training Grounds Specific Buttons
	hooksecurefunc(TrainingGroundsFrame.SpecificTrainingGroundList.ScrollBox, 'Update', SpecificScrollUpdate)

	-- PvP StatusBars
	for _, Frame in next, { HonorFrame, ConquestFrame, TrainingGroundsFrame } do
		Frame.ConquestBar.Border:Hide()
		Frame.ConquestBar.Background:Hide()
		Frame.ConquestBar.Reward.Ring:Hide()
		Frame.ConquestBar.Reward.CircleMask:Hide()
		Frame.ConquestBar:SetTemplate('Transparent')

		Frame.ConquestBar.Reward:ClearAllPoints()
		Frame.ConquestBar.Reward:Point('LEFT', Frame.ConquestBar, 'RIGHT', 0, 0)
		S:HandleIcon(Frame.ConquestBar.Reward.Icon, true)
	end
end

function S:PVPReadyDialog()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	S:HandleCloseButton(_G.PVPReadyDialogCloseButton)
	S:SkinReadyDialog(_G.PVPReadyDialog, 54)

	hooksecurefunc('PVPReadyDialog_Display', function(dialog, _, _, isRated, queueType)
		dialog.enterButton:ClearAllPoints()

		if dialog.leaveButton:IsShown() then
			dialog.enterButton:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -7, 16)

			dialog.leaveButton:ClearAllPoints()
			dialog.leaveButton:Point('BOTTOMLEFT', dialog, 'BOTTOM', 7, 16)
		else
			dialog.enterButton:Point('BOTTOM', 0, 16)
		end

		if queueType == 'BATTLEGROUND' and not isRated then
			dialog.background:SetTexCoord(0, 1, 0.01, 1)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_GroupFinder', 'PVPReadyDialog')
S:AddCallbackForAddon('Blizzard_PVPUI')
