local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end

	_G["PVPUIFrame"]:StripTextures()

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
		S:HandleTexture(bu.Icon, bu)
	end

	local PVPQueueFrame = _G["PVPQueueFrame"]
	PVPQueueFrame.HonorInset:StripTextures()
	PVPQueueFrame.HonorInset.HonorLevelDisplay.NextRewardLevel.LevelLabel:FontTemplate()

	local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
	SeasonReward.CircleMask:Hide()
	SeasonReward.Ring:Hide()
	SeasonReward.Icon:SetTexCoord(unpack(E.TexCoords))
	local RewardFrameBorder = CreateFrame("Frame", nil, SeasonReward)
	RewardFrameBorder:SetTemplate("Default")
	RewardFrameBorder:SetOutside(SeasonReward.Icon)
	SeasonReward.Icon:SetParent(RewardFrameBorder)
	SeasonReward.Icon:SetDrawLayer("OVERLAY")

	-- Honor Frame
	local HonorFrame = _G["HonorFrame"]
	HonorFrame:StripTextures()

	S:HandleScrollBar(HonorFrameSpecificFrameScrollBar)
	S:HandleButton(HonorFrameQueueButton, true)
	S:HandleDropDownBox(HonorFrameTypeDropDown, 180)

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
		S:HandleTexture(reward.Icon, reward)

		reward.EnlistmentBonus:StripTextures()
		reward.EnlistmentBonus:SetTemplate("Default")
		reward.EnlistmentBonus:SetSize(20, 20)
		reward.EnlistmentBonus:SetPoint("TOPRIGHT", 2, 2)

		local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
		EnlistmentBonusIcon:SetPoint("TOPLEFT", reward.EnlistmentBonus, "TOPLEFT", 2, -2)
		EnlistmentBonusIcon:SetPoint("BOTTOMRIGHT", reward.EnlistmentBonus, "BOTTOMRIGHT", -2, 2)
		EnlistmentBonusIcon:SetTexture("Interface\\Icons\\achievement_guildperk_honorablemention_rank2")
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	-- Honor Frame Specific Buttons
	for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:StripTextures()
		bu:CreateBackdrop("Default")
		bu:StyleButton(nil, true)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		bu.Icon:SetTexCoord(unpack(E.TexCoords))
		bu.Icon:SetPoint("TOPLEFT", 5, -3)
	end

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(self)
		if self.bg then
			self.bg:SetDesaturated(true)
		end
	end)

	-- New tiny Role icons in Bfa
	HonorFrame.TankIcon:StripTextures()
	HonorFrame.TankIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.TankIcon:DisableDrawLayer("OVERLAY")

	HonorFrame.TankIcon.bg = HonorFrame.TankIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.TankIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.TankIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HonorFrame.TankIcon.bg:Point("CENTER")
	HonorFrame.TankIcon.bg:Size(40)
	HonorFrame.TankIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(HonorFrame.TankIcon.checkButton)

	HonorFrame.HealerIcon:StripTextures()
	HonorFrame.HealerIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.HealerIcon:DisableDrawLayer("OVERLAY")

	HonorFrame.HealerIcon.bg = HonorFrame.HealerIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.HealerIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.HealerIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HonorFrame.HealerIcon.bg:Point("CENTER")
	HonorFrame.HealerIcon.bg:Size(40)
	HonorFrame.HealerIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(HonorFrame.HealerIcon.checkButton)

	HonorFrame.DPSIcon:StripTextures()
	HonorFrame.DPSIcon:DisableDrawLayer("ARTWORK")
	HonorFrame.DPSIcon:DisableDrawLayer("OVERLAY")

	HonorFrame.DPSIcon.bg = HonorFrame.DPSIcon:CreateTexture(nil, 'BACKGROUND')
	HonorFrame.DPSIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	HonorFrame.DPSIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
	HonorFrame.DPSIcon.bg:Point("CENTER")
	HonorFrame.DPSIcon.bg:Size(40)
	HonorFrame.DPSIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(HonorFrame.DPSIcon.checkButton)

	-- Conquest Frame
	local ConquestFrame = _G["ConquestFrame"]
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	S:HandleButton(ConquestJoinButton, true)

	-- New tiny Role icons in Bfa
	ConquestFrame.TankIcon:StripTextures()
	ConquestFrame.TankIcon:DisableDrawLayer("ARTWORK")
	ConquestFrame.TankIcon:DisableDrawLayer("OVERLAY")

	ConquestFrame.TankIcon.bg = ConquestFrame.TankIcon:CreateTexture(nil, 'BACKGROUND')
	ConquestFrame.TankIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	ConquestFrame.TankIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	ConquestFrame.TankIcon.bg:Point("CENTER")
	ConquestFrame.TankIcon.bg:Size(40)
	ConquestFrame.TankIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(ConquestFrame.TankIcon.checkButton)

	ConquestFrame.HealerIcon:StripTextures()
	ConquestFrame.HealerIcon:DisableDrawLayer("ARTWORK")
	ConquestFrame.HealerIcon:DisableDrawLayer("OVERLAY")

	ConquestFrame.HealerIcon.bg = ConquestFrame.HealerIcon:CreateTexture(nil, 'BACKGROUND')
	ConquestFrame.HealerIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	ConquestFrame.HealerIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	ConquestFrame.HealerIcon.bg:Point("CENTER")
	ConquestFrame.HealerIcon.bg:Size(40)
	ConquestFrame.HealerIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(ConquestFrame.HealerIcon.checkButton)

	ConquestFrame.DPSIcon:StripTextures()
	ConquestFrame.DPSIcon:DisableDrawLayer("ARTWORK")
	ConquestFrame.DPSIcon:DisableDrawLayer("OVERLAY")

	ConquestFrame.DPSIcon.bg = ConquestFrame.DPSIcon:CreateTexture(nil, 'BACKGROUND')
	ConquestFrame.DPSIcon.bg:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	ConquestFrame.DPSIcon.bg:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
	ConquestFrame.DPSIcon.bg:Point("CENTER")
	ConquestFrame.DPSIcon.bg:Size(40)
	ConquestFrame.DPSIcon.bg:SetAlpha(0.6)
	S:HandleCheckBox(ConquestFrame.DPSIcon.checkButton)

	for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
		local reward = bu.Reward
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		reward:StripTextures()
		S:HandleTexture(reward.Icon, reward)
	end

	ConquestFrame.Arena3v3:Point("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -2)

	if E.private.skins.blizzard.tooltip then
		ConquestTooltip:SetTemplate("Transparent")
	end

	-- Honor Frame StatusBar
	local bar = HonorFrame.ConquestBar
	if bar then
		if bar.Border then bar.Border:Hide() end
		if bar.Background then bar.Background:Hide() end

		if E.myfaction == "Alliance" then
			bar:SetStatusBarColor(0.05, 0.15, 0.36)
		else
			bar:SetStatusBarColor(0.63, 0.09, 0.09)
		end

		if not bar.backdrop then
			bar:CreateBackdrop("Default")
			bar.backdrop:SetOutside()
		end
		E:RegisterStatusBar(bar)
	end

	-- Icon
	HonorFrame.ConquestBar.Reward.Ring:Hide()
	HonorFrame.ConquestBar.Reward.CircleMask:Hide()
	HonorFrame.ConquestBar.Reward.Icon:SetTexCoord(unpack(E.TexCoords))

	-- Conquest Frame StatusBar
	local bar = ConquestFrame.ConquestBar
	if bar then
		if bar.Border then bar.Border:Hide() end
		if bar.Background then bar.Background:Hide() end

		if E.myfaction == "Alliance" then
			bar:SetStatusBarColor(0.05, 0.15, 0.36)
		else
			bar:SetStatusBarColor(0.63, 0.09, 0.09)
		end

		if not bar.backdrop then
			bar:CreateBackdrop("Default")
			bar.backdrop:SetOutside()
		end
		E:RegisterStatusBar(bar)
	end

	-- Icon
	ConquestFrame.ConquestBar.Reward.Ring:Hide()
	ConquestFrame.ConquestBar.Reward.CircleMask:Hide()
	ConquestFrame.ConquestBar.Reward.Icon:SetTexCoord(unpack(E.TexCoords))

	--Tutorials
	S:HandleCloseButton(PremadeGroupsPvPTutorialAlert.CloseButton)
	S:HandleCloseButton(HonorFrame.BonusFrame.BrawlHelpBox.CloseButton)
end

S:AddCallbackForAddon('Blizzard_PVPUI', "PvPUI", LoadSkin)

local function LoadSecondarySkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.pvp ~= true then return end

	--PVP QUEUE FRAME
	PVPReadyDialog:StripTextures()
	PVPReadyDialog:SetTemplate("Transparent")
	S:HandleButton(PVPReadyDialogEnterBattleButton)
	S:HandleButton(PVPReadyDialogLeaveQueueButton)
	S:HandleCloseButton(PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIcon.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)

	hooksecurefunc("PVPReadyDialog_Display", function(self, _, _, _, queueType, _, role)
		if role == "DAMAGER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
		elseif role == "TANK" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
		elseif role == "HEALER" then
			PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
		end

		if queueType == "ARENA" then
			self:Height(100)
		end

		self.background:Hide()
	end)
end

S:AddCallback("PVP", LoadSecondarySkin)
