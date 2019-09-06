local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local ipairs, pairs, unpack = ipairs, pairs, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local CurrencyContainerUtil_GetCurrencyContainerInfo = CurrencyContainerUtil.GetCurrencyContainerInfo
local GetCurrencyInfo = GetCurrencyInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

local function HandleRoleChecks(button, ...)
	button:StripTextures()
	button:DisableDrawLayer("ARTWORK")
	button:DisableDrawLayer("OVERLAY")

	button.bg = button:CreateTexture(nil, 'BACKGROUND', nil, -7)
	button.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	button.bg:SetTexCoord(...)
	button.bg:Point("CENTER")
	button.bg:Size(40)
	button.bg:SetAlpha(0.6)
	S:HandleCheckBox(button.checkButton)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end

	_G.PVPUIFrame:StripTextures()

	for i = 1, 2 do
		S:HandleTab(_G["PVPUIFrameTab"..i])
	end

	for i = 1, 3 do
		local bu = _G["PVPQueueFrameCategoryButton"..i]
		bu.Ring:Kill()
		bu.Background:Kill()
		S:HandleButton(bu)

		bu.Icon:Size(45)
		bu.Icon:ClearAllPoints()
		bu.Icon:Point("LEFT", 10, 0)
		S:HandleIcon(bu.Icon, true)
	end

	local PVPQueueFrame = _G.PVPQueueFrame
	PVPQueueFrame.HonorInset:StripTextures()

	PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
	PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\Achievement_General_StayClassy")

	local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
	SeasonReward.CircleMask:Hide()
	SeasonReward.Ring:Hide()
	SeasonReward.Icon:SetTexCoord(unpack(E.TexCoords))
	local RewardFrameBorder = CreateFrame("Frame", nil, SeasonReward)
	RewardFrameBorder:SetTemplate()
	RewardFrameBorder:SetOutside(SeasonReward.Icon)
	SeasonReward.Icon:SetParent(RewardFrameBorder)
	SeasonReward.Icon:SetDrawLayer("OVERLAY")

	-- Honor Frame
	local HonorFrame = _G.HonorFrame
	HonorFrame:StripTextures()

	S:HandleScrollBar(_G.HonorFrameSpecificFrameScrollBar)
	S:HandleButton(_G.HonorFrameQueueButton, true)
	S:HandleDropDownBox(_G.HonorFrameTypeDropDown)

	local BonusFrame = HonorFrame.BonusFrame
	BonusFrame:StripTextures()
	BonusFrame.ShadowOverlay:Hide()
	BonusFrame.WorldBattlesTexture:Hide()

	for _, bonusButton in pairs({"RandomBGButton", "Arena1Button", "RandomEpicBGButton", "BrawlButton"}) do
		local bu = BonusFrame[bonusButton]
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward:StripTextures()
		S:HandleIcon(reward.Icon, true)

		reward.EnlistmentBonus:StripTextures()
		reward.EnlistmentBonus:SetTemplate()
		reward.EnlistmentBonus:Size(20, 20)
		reward.EnlistmentBonus:Point("TOPRIGHT", 2, 2)

		local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
		EnlistmentBonusIcon:Point("TOPLEFT", reward.EnlistmentBonus, "TOPLEFT", 2, -2)
		EnlistmentBonusIcon:Point("BOTTOMRIGHT", reward.EnlistmentBonus, "BOTTOMRIGHT", -2, 2)
		EnlistmentBonusIcon:SetTexture("Interface\\Icons\\achievement_guildperk_honorablemention_rank2")
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	-- Honor Frame Specific Buttons
	for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		bu:StripTextures()
		bu:CreateBackdrop()
		bu.backdrop:Point("TOPLEFT", 2, 0)
		bu.backdrop:Point("BOTTOMRIGHT", -1, 2)
		bu:StyleButton(nil, true)

		bu.SelectedTexture:SetInside(bu.backdrop)
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		bu.Icon:SetTexCoord(unpack(E.TexCoords))
		bu.Icon:Point("TOPLEFT", 5, -3)
	end

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(self)
		if self.bg then
			self.bg:SetDesaturated(true)
		end
	end)

	-- New tiny Role icons in Bfa
	HandleRoleChecks(HonorFrame.TankIcon, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(HonorFrame.HealerIcon, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(HonorFrame.DPSIcon, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	-- Conquest Frame
	local ConquestFrame = _G.ConquestFrame
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	S:HandleButton(_G.ConquestJoinButton, true)

	HandleRoleChecks(ConquestFrame.TankIcon, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(ConquestFrame.HealerIcon, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(ConquestFrame.DPSIcon, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward:StripTextures()
		S:HandleIcon(reward.Icon, true)
	end

	ConquestFrame.Arena3v3:Point("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -2)

	-- Item Borders for HonorFrame & ConquestFrame
	hooksecurefunc('PVPUIFrame_ConfigureRewardFrame', function(rewardFrame, honor, experience, itemRewards, currencyRewards)
		local rewardTexture, rewardQuaility = nil, 1

		if currencyRewards then
			for _, reward in ipairs(currencyRewards) do
				local name, _, texture, _, _, _, _, quality = GetCurrencyInfo(reward.id)
				if quality == _G.LE_ITEM_QUALITY_ARTIFACT then
					_, rewardTexture, _, rewardQuaility = CurrencyContainerUtil_GetCurrencyContainerInfo(reward.id, reward.quantity, name, texture, quality)
				end
			end
		end

		local _
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
		_G.ConquestTooltip:SetTemplate("Transparent")
	end

	-- PvP StatusBars
	for _, Frame in pairs({ HonorFrame, ConquestFrame }) do
		Frame.ConquestBar.Border:Hide()
		Frame.ConquestBar.Background:Hide()
		Frame.ConquestBar.Reward.Ring:Hide()
		Frame.ConquestBar.Reward.CircleMask:Hide()

		if not Frame.ConquestBar.backdrop then
			Frame.ConquestBar:CreateBackdrop()
			Frame.ConquestBar.backdrop:SetOutside()
		end

		Frame.ConquestBar.Reward:Point("LEFT", Frame.ConquestBar, "RIGHT", -8, 0)
		Frame.ConquestBar:SetStatusBarTexture(E.media.normTex)
		Frame.ConquestBar:SetStatusBarColor(unpack(E.myfaction == "Alliance" and {0.05, 0.15, 0.36} or {0.63, 0.09, 0.09}))

		S:HandleIcon(Frame.ConquestBar.Reward.Icon)
	end

	--Tutorials
	S:HandleCloseButton(_G.PremadeGroupsPvPTutorialAlert.CloseButton)
	S:HandleCloseButton(HonorFrame.BonusFrame.BrawlHelpBox.CloseButton)

	-- New Season Frame
	local NewSeasonPopup = _G.PVPQueueFrame.NewSeasonPopup
	S:HandleButton(NewSeasonPopup.Leave)
	NewSeasonPopup:StripTextures()
	NewSeasonPopup:CreateBackdrop("Overlay")
	NewSeasonPopup:SetFrameLevel(5)
	NewSeasonPopup.NewSeason:SetTextColor(1, .8, 0)
	NewSeasonPopup.NewSeason:SetShadowOffset(1, -1)
	NewSeasonPopup.SeasonDescription:SetTextColor(1, 1, 1)
	NewSeasonPopup.SeasonDescription:SetShadowOffset(1, -1)
	NewSeasonPopup.SeasonDescription2:SetTextColor(1, 1, 1)
	NewSeasonPopup.SeasonDescription2:SetShadowOffset(1, -1)

	local RewardFrame = _G.SeasonRewardFrame
	RewardFrame.CircleMask:SetAlpha(0)
	RewardFrame.Ring:SetAlpha(0)
	RewardFrame.Icon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallbackForAddon('Blizzard_PVPUI', "PvPUI", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end

	--PVP QUEUE FRAME
	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate("Transparent")
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogLeaveQueueButton)
	S:HandleCloseButton(_G.PVPReadyDialogCloseButton)
	_G.PVPReadyDialogRoleIcon.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	_G.PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, queueType, _, role)
		if role == "DAMAGER" then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == "TANK" then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == "HEALER" then
			_G.PVPReadyDialogRoleIcon.texture:SetTexCoord(_G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end

		if queueType == "ARENA" then
			self:Height(100)
		end

		self.background:Hide()
	end)
end

S:AddCallback("PVP", LoadSecondarySkin)
