local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local ipairs, pairs, unpack, next = ipairs, pairs, unpack, next
local hooksecurefunc = hooksecurefunc

local GetItemInfo = C_Item.GetItemInfo

local ITEMQUALITY_ARTIFACT = Enum.ItemQuality.Artifact
local CurrencyContainerUtil_GetCurrencyContainerInfo = CurrencyContainerUtil.GetCurrencyContainerInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local function HandleRoleButton(button)
	local checkbox = button.checkButton
	checkbox:OffsetFrameLevel(1)
	S:HandleCheckBox(checkbox)

	button:Size(40)

	if button.IconPulse then button.IconPulse:Size(40) end
	if button.EdgePulse then button.EdgePulse:Size(40) end
	if button.shortageBorder then button.shortageBorder:Size(40) end
end

local function HonorSpecificScrollUpdateChild(bu)
	if not bu.IsSkinned then
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:StripTextures()
		bu:CreateBackdrop()
		bu.backdrop:Point('TOPLEFT', 2, 0)
		bu.backdrop:Point('BOTTOMRIGHT', -1, 2)
		bu:StyleButton(nil, true)

		bu.SelectedTexture:SetInside(bu.backdrop)
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		bu.Icon:SetTexCoord(unpack(E.TexCoords))
		bu.Icon:Point('TOPLEFT', 5, -3)

		bu.IsSkinned = true
	end
end

local function HonorSpecificScrollUpdate(frame)
	frame:ForEachFrame(HonorSpecificScrollUpdateChild)
end

function S:Blizzard_PVPUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	_G.PVPUIFrame:StripTextures()

	for i = 1, 2 do
		S:HandleTab(_G['PVPUIFrameTab'..i])
	end

	for i = 1, 4 do
		local bu = _G['PVPQueueFrameCategoryButton'..i]
		if bu then
			bu.Ring:Kill()
			bu.Background:Kill()
			S:HandleButton(bu)

			bu.Icon:Size(45)
			bu.Icon:ClearAllPoints()
			bu.Icon:Point('LEFT', 10, 0)
			S:HandleIcon(bu.Icon, true)
		end
	end

	local PVPQueueFrame = _G.PVPQueueFrame
	local HonorInset = PVPQueueFrame.HonorInset
	HonorInset.NineSlice:Hide()

	-- Plunderstorm
	local PlunderstormFrame = _G.PlunderstormFrame
	if PlunderstormFrame then
		PlunderstormFrame.Inset:StripTextures()
		S:HandleButton(PlunderstormFrame.StartQueue)
	end

	local PlunderstormPanel = HonorInset.PlunderstormPanel
	if PlunderstormPanel then
		S:HandleButton(PlunderstormPanel.PlunderstoreButton)
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture(236396) -- interface\icons\achievement_bg_winwsg.blp
	PVPQueueFrame.CategoryButton2.Icon:SetTexture(236368) -- interface\icons\achievement_bg_killxenemies_generalsroom.blp
	PVPQueueFrame.CategoryButton3.Icon:SetTexture(464820) -- interface\icons\achievement_general_stayclassy.blp

	local SeasonReward = HonorInset.RatedPanel.SeasonRewardFrame
	SeasonReward:CreateBackdrop()
	SeasonReward.Icon:SetInside(SeasonReward.backdrop)
	SeasonReward.Icon:SetTexCoord(unpack(E.TexCoords))
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

	for _, bonusButton in pairs({'RandomBGButton', 'Arena1Button', 'RandomEpicBGButton', 'BrawlButton', 'BrawlButton2'}) do
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
	hooksecurefunc(HonorFrame.SpecificScrollBox, 'Update', HonorSpecificScrollUpdate)

	hooksecurefunc('LFG_PermanentlyDisableRoleButton', function(button)
		if button.bg then button.bg:SetDesaturated(true) end
	end)

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

	for _, bu in pairs({ConquestFrame.RatedSoloShuffle, ConquestFrame.RatedBGBlitz, ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
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
			for _, reward in ipairs(currencyRewards) do
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

	-- PvP StatusBars
	for _, Frame in pairs({ HonorFrame, ConquestFrame }) do
		Frame.ConquestBar.Border:Hide()
		Frame.ConquestBar.Background:Hide()
		Frame.ConquestBar.Reward.Ring:Hide()
		Frame.ConquestBar.Reward.CircleMask:Hide()
		Frame.ConquestBar:SetTemplate('Transparent')

		Frame.ConquestBar.Reward:ClearAllPoints()
		Frame.ConquestBar.Reward:Point('LEFT', Frame.ConquestBar, 'RIGHT', 0, 0)
		S:HandleIcon(Frame.ConquestBar.Reward.Icon, true)
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
	RewardFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	RewardFrame.backdrop:SetOutside(RewardFrame.Icon)

	if NewSeasonPopup.NewSeason then
		NewSeasonPopup.NewSeason:SetTextColor(1, .8, 0)
		NewSeasonPopup.NewSeason:SetShadowOffset(1, -1)
	end

	if NewSeasonPopup.SeasonRewardText then
		NewSeasonPopup.SeasonRewardText:SetTextColor(1, .8, 0)
		NewSeasonPopup.SeasonRewardText:SetShadowOffset(1, -1)
	end

	if NewSeasonPopup.SeasonDescriptionHeader then
		NewSeasonPopup.SeasonDescriptionHeader:SetTextColor(1, 1, 1)
		NewSeasonPopup.SeasonDescriptionHeader:SetShadowOffset(1, -1)
	end

	NewSeasonPopup:HookScript('OnShow', function(popup)
		if popup.SeasonDescriptions then
			for _, text in next, popup.SeasonDescriptions do
				text:SetTextColor(1, 1, 1)
				text:SetShadowOffset(1, -1)
			end
		end
	end)
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

S:AddCallback('PVPReadyDialog')
S:AddCallbackForAddon('Blizzard_PVPUI')
