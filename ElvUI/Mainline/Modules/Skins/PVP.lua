local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local ipairs, pairs, unpack, next = ipairs, pairs, unpack, next

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local ITEMQUALITY_ARTIFACT = Enum.ItemQuality.Artifact
local CurrencyContainerUtil_GetCurrencyContainerInfo = CurrencyContainerUtil.GetCurrencyContainerInfo
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local function HandleRoleChecks(button, ...)
	button:StripTextures()
	button:DisableDrawLayer('ARTWORK')
	button:DisableDrawLayer('OVERLAY')

	button.bg = button:CreateTexture(nil, 'BACKGROUND', nil, -7)
	button.bg:SetTexture(E.Media.Textures.RolesHQ)
	button.bg:SetTexCoord(...)
	button.bg:Point('CENTER')
	button.bg:Size(40, 40)
	button.bg:SetAlpha(0.6)
	S:HandleCheckBox(button.checkButton)
end

function S:Blizzard_PVPUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	_G.PVPUIFrame:StripTextures()

	for i = 1, 2 do
		S:HandleTab(_G['PVPUIFrameTab'..i])
	end

	for i = 1, 3 do
		local bu = _G['PVPQueueFrameCategoryButton'..i]
		bu.Ring:Kill()
		bu.Background:Kill()
		S:HandleButton(bu)

		bu.Icon:Size(45)
		bu.Icon:ClearAllPoints()
		bu.Icon:Point('LEFT', 10, 0)
		S:HandleIcon(bu.Icon, true)
	end

	local PVPQueueFrame = _G.PVPQueueFrame
	PVPQueueFrame.HonorInset:StripTextures()

	PVPQueueFrame.CategoryButton1.Icon:SetTexture(236396) -- interface/icons/achievement_bg_winwsg.blp
	PVPQueueFrame.CategoryButton2.Icon:SetTexture(236368) -- interface/icons/achievement_bg_killxenemies_generalsroom.blp
	PVPQueueFrame.CategoryButton3.Icon:SetTexture(464820) -- interface/icons/achievement_general_stayclassy.blp

	local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
	SeasonReward:CreateBackdrop()
	SeasonReward.Icon:SetInside(SeasonReward.backdrop)
	SeasonReward.Icon:SetTexCoord(unpack(E.TexCoords))
	SeasonReward.CircleMask:Hide()
	SeasonReward.Ring:Hide()

	-- Honor Frame
	local HonorFrame = _G.HonorFrame
	HonorFrame:StripTextures()

	S:HandleScrollBar(_G.HonorFrameSpecificFrameScrollBar)
	S:HandleDropDownBox(_G.HonorFrameTypeDropDown, 230)
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
		reward.EnlistmentBonus:Size(20, 20)
		reward.EnlistmentBonus:Point('TOPRIGHT', 2, 2)

		local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
		EnlistmentBonusIcon:Point('TOPLEFT', reward.EnlistmentBonus, 'TOPLEFT', 2, -2)
		EnlistmentBonusIcon:Point('BOTTOMRIGHT', reward.EnlistmentBonus, 'BOTTOMRIGHT', -2, 2)
		EnlistmentBonusIcon:SetTexture([[Interface\Icons\achievement_guildperk_honorablemention_rank2]])
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	-- Honor Frame Specific Buttons
	for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:SetNormalTexture('')
		bu:SetHighlightTexture('')

		bu:StripTextures()
		bu:CreateBackdrop()
		bu.backdrop:Point('TOPLEFT', 2, 0)
		bu.backdrop:Point('BOTTOMRIGHT', -1, 2)
		bu:StyleButton(nil, true)

		bu.SelectedTexture:SetInside(bu.backdrop)
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		bu.Icon:SetTexCoord(unpack(E.TexCoords))
		bu.Icon:Point('TOPLEFT', 5, -3)
	end

	hooksecurefunc('LFG_PermanentlyDisableRoleButton', function(s)
		if s.bg then s.bg:SetDesaturated(true) end
	end)

	-- New tiny Role icons in Bfa
	HandleRoleChecks(HonorFrame.TankIcon, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(HonorFrame.HealerIcon, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(HonorFrame.DPSIcon, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	-- Conquest Frame
	local ConquestFrame = _G.ConquestFrame
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	S:HandleButton(_G.ConquestJoinButton)

	HandleRoleChecks(ConquestFrame.TankIcon, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(ConquestFrame.HealerIcon, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(ConquestFrame.DPSIcon, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
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
			rewardFrame.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(rewardQuaility))
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

	--PVP QUEUE FRAME
	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogLeaveQueueButton)
	S:HandleCloseButton(_G.PVPReadyDialogCloseButton)
	_G.PVPReadyDialogRoleIcon.texture:SetTexture(E.Media.Textures.RolesHQ)
	_G.PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)

	hooksecurefunc('PVPReadyDialog_Display', function(s, _, _, _, queueType, _, role)
		if role == 'DAMAGER' then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == 'TANK' then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == 'HEALER' then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end

		if queueType == 'ARENA' then
			s:Height(100)
		end

		s.background:Hide()
	end)
end

S:AddCallback('PVPReadyDialog')
S:AddCallbackForAddon('Blizzard_PVPUI')
