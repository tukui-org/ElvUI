local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
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

		bu:SetTemplate()
		bu:StyleButton(nil, true)

		bu.Icon:SetTexCoord(.15, .85, .15, .85)
		bu.Icon:Point("LEFT", bu, "LEFT")
		bu.Icon:SetDrawLayer("OVERLAY")
		bu.Icon:Size(45)
		bu.Icon:ClearAllPoints()
		bu.Icon:Point("LEFT", 10, 0)
		bu.border = CreateFrame("Frame", nil, bu)
		bu.border:SetTemplate("Default")
		bu.border:SetOutside(bu.Icon)
		bu.Icon:SetParent(bu.border)
	end

	PVPQueueFrameBg:Hide()
	PVPQueueFrameInsetRightBorder:Hide()
	PVPQueueFrameInsetLeftBorder:Hide()
	PVPQueueFrameInsetTopBorder:Hide()
	PVPQueueFrameInsetBottomBorder:Hide()
	PVPQueueFrameInsetBotLeftCorner:Hide()
	PVPQueueFrameInsetBotRightCorner:Hide()
	PVPQueueFrameInsetTopRightCorner:Hide()
	PVPQueueFrameInsetTopLeftCorner:Hide()

	-- Honor Frame
	local HonorFrame = _G["HonorFrame"]
	local Inset = HonorFrame.Inset

	for i = 1, 9 do
		select(i, Inset:GetRegions()):Hide()
	end

	S:HandleScrollBar(HonorFrameSpecificFrameScrollBar)
	S:HandleButton(HonorFrameQueueButton, true)
	S:HandleDropDownBox(HonorFrameTypeDropDown, 180)

	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:Hide()
	HonorFrame.BonusFrame.WorldBattlesTexture:Hide()
	HonorFrame.BonusFrame.RandomBGButton:StripTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetTemplate()
	HonorFrame.BonusFrame.RandomBGButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

	HonorFrame.BonusFrame.Arena1Button:StripTextures()
	HonorFrame.BonusFrame.Arena1Button:SetTemplate()
	HonorFrame.BonusFrame.Arena1Button:StyleButton(nil, true)
	HonorFrame.BonusFrame.Arena1Button.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.Arena1Button.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

	HonorFrame.BonusFrame.LargeBattlegroundButton:StripTextures()
	HonorFrame.BonusFrame.LargeBattlegroundButton:SetTemplate()
	HonorFrame.BonusFrame.LargeBattlegroundButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.LargeBattlegroundButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.LargeBattlegroundButton.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

	HonorFrame.BonusFrame.BrawlButton:StripTextures()
	HonorFrame.BonusFrame.BrawlButton:SetTemplate()
	HonorFrame.BonusFrame.BrawlButton:StyleButton(nil, true)
	HonorFrame.BonusFrame.BrawlButton.SelectedTexture:SetInside()
	HonorFrame.BonusFrame.BrawlButton.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

	for _, button in pairs({HonorFrame.BonusFrame.RandomBGButton, HonorFrame.BonusFrame.Arena1Button, HonorFrame.BonusFrame.BrawlButton}) do
		button.Reward:StripTextures()
		button.Reward:SetTemplate("Default")
		button.Reward:SetSize(40, 40)
		button.Reward:SetPoint("RIGHT", button, "RIGHT", -8, 0)

		button.Reward.Icon:SetAllPoints()
		button.Reward.Icon:SetPoint("TOPLEFT", 2, -2)
		button.Reward.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		button.Reward.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		button.Reward.EnlistmentBonus:StripTextures()
		button.Reward.EnlistmentBonus:SetTemplate("Default")
		button.Reward.EnlistmentBonus:SetSize(20, 20)
		button.Reward.EnlistmentBonus:SetPoint("TOPRIGHT", 2, 2)

		local EnlistmentBonusIcon = button.Reward.EnlistmentBonus:CreateTexture(nil, nil, self)
		EnlistmentBonusIcon:SetPoint("TOPLEFT", button.Reward.EnlistmentBonus, "TOPLEFT", 2, -2)
		EnlistmentBonusIcon:SetPoint("BOTTOMRIGHT", button.Reward.EnlistmentBonus, "BOTTOMRIGHT", -2, 2)
		EnlistmentBonusIcon:SetTexture("Interface\\Icons\\achievement_guildperk_honorablemention_rank2")
		EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
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
	local Inset = ConquestFrame.Inset

	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	for i = 1, 9 do
		select(i, Inset:GetRegions()):Hide()
	end

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

	local function handleButton(button)
		button:StripTextures()
		button:SetTemplate()
		button:StyleButton(nil, true)
		button.SelectedTexture:SetInside()
		button.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)

		button.Reward:StripTextures()
		button.Reward:SetTemplate("Default")
		button.Reward:SetSize(35, 35)
		button.Reward:SetPoint("RIGHT", button, "RIGHT", -7, -1)

		button.Reward.Icon:SetAllPoints()
		button.Reward.Icon:SetPoint("TOPLEFT", 2, -2)
		button.Reward.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		button.Reward.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		button.Reward.WeeklyBonus:StripTextures()
		button.Reward.WeeklyBonus:SetTemplate("Default")
		button.Reward.WeeklyBonus:SetSize(20, 20)
		button.Reward.WeeklyBonus:SetPoint("TOPRIGHT", 2, 2)

		local WeeklyBonusIcon = button.Reward.WeeklyBonus:CreateTexture(nil, nil, self)
		WeeklyBonusIcon:SetPoint("TOPLEFT", button.Reward.WeeklyBonus, "TOPLEFT", 2, -2)
		WeeklyBonusIcon:SetPoint("BOTTOMRIGHT", button.Reward.WeeklyBonus, "BOTTOMRIGHT", -2, 2)
		WeeklyBonusIcon:SetTexture("Interface\\Icons\\ability_skyreach_flash_bang")
		WeeklyBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	handleButton(ConquestFrame.RatedBG)
	handleButton(ConquestFrame.Arena2v2)
	handleButton(ConquestFrame.Arena3v3)

	ConquestFrame.Arena3v3:Point("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -2)

	if E.private.skins.blizzard.tooltip then
		ConquestTooltip:SetTemplate("Transparent")
		PVPRewardTooltip:SetTemplate("Transparent")
	end

	S:SkinPVPHonorXPBar('HonorFrame')
	S:SkinPVPHonorXPBar('ConquestFrame')

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