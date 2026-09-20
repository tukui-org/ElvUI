local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next

local function HandleRoleButton(button)
	local checkbox = button.checkButton
	checkbox:OffsetFrameLevel(1)
	S:HandleCheckBox(checkbox)

	button:Size(40)
end

local function HandleHonorDropdown(dropdown)
	dropdown.Left:Kill()
	dropdown.Middle:Kill()
	dropdown.Right:Kill()

	dropdown:CreateBackdrop()
	dropdown.backdrop:Point('TOPLEFT', 14, -2)
	dropdown.backdrop:Point('BOTTOMRIGHT', -6, 10)

	dropdown:Width(220)
	dropdown:ClearAllPoints()
	dropdown:Point('TOPRIGHT', _G.HonorQueueFrame.RoleInset, 'TOPRIGHT', 6, -72)

	dropdown.Button:SetHitRectInsets(-150, 1, 1, 1) -- stupid but ok
	S:HandleNextPrevButton(dropdown.Button, 'down')
end

function S:Blizzard_PVPUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	local PVPQueueFrame = _G.PVPQueueFrame
	for i = 1, 4 do
		local bu = PVPQueueFrame['CategoryButton'..i]
		bu.Ring:Kill()
		bu.Background:Kill()
		bu.CircleMask:Hide()
		S:HandleButton(bu)

		bu.Icon:Size(45)
		bu.Icon:ClearAllPoints()
		bu.Icon:Point('LEFT', 10, 0)
		S:HandleIcon(bu.Icon, true)
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture(236396) -- interface\icons\achievement_bg_winwsg.blp
	PVPQueueFrame.CategoryButton2.Icon:SetTexture(236368) -- interface\icons\achievement_bg_killxenemies_generalsroom.blp
	PVPQueueFrame.CategoryButton3.Icon:SetTexture(132349) -- interface\icons\ability_warrior_offensivestance.blp
	PVPQueueFrame.CategoryButton4.Icon:SetTexture(464820) -- interface\icons\achievement_general_stayclassy.blp

	-- Casual Tab
	local HonorFrame = _G.HonorQueueFrame
	HonorFrame:StripTextures()

	_G.HonorQueueFrame.RoleInset.Background:Kill()
	_G.HonorQueueFrame.RoleInset.NineSlice:StripTextures()

	S:HandleScrollBar(_G.HonorQueueFrameSpecificFrameScrollBar)

	local BonusFrame = HonorFrame.BonusFrame
	BonusFrame:StripTextures()
	BonusFrame.ShadowOverlay:Hide()
	BonusFrame.WorldBattlesTexture:Hide()

	-- TODO: This is a fake dropdown
	HandleHonorDropdown(_G.HonorQueueFrameTypeDropDown)

	for _, bu in next, { BonusFrame.RandomBGButton, BonusFrame.CallToArmsButton, BonusFrame.WorldPVP1Button, BonusFrame.WorldPVP2Button } do
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
	end

	S:HandleButton(HonorFrame.SoloQueueButton)
	S:HandleButton(HonorFrame.GroupQueueButton)

	HandleRoleButton(HonorFrame.RoleInset.TankIcon)
	HandleRoleButton(HonorFrame.RoleInset.HealerIcon)
	HandleRoleButton(HonorFrame.RoleInset.DPSIcon)

	-- Rated Tab
	local ConquestFrame = _G.ConquestQueueFrame
	ConquestFrame:StripTextures()
	ConquestFrame.ShadowOverlay:Hide()

	S:HandleButton(_G.ConquestJoinButton)

	for _, bu in next, { ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.Arena5v5, ConquestFrame.RatedBG } do
		S:HandleButton(bu)
		bu.SelectedTexture:SetInside()
		bu.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
	end

	ConquestFrame.Arena3v3:Point('TOP', ConquestFrame.Arena2v2, 'BOTTOM', 0, -2)
	ConquestFrame.Arena5v5:Point('TOP', ConquestFrame.Arena3v3, 'BOTTOM', 0, -2)

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.ConquestTooltip)
	end

	-- War Games Tab
	local WarGamesQueueFrame = _G.WarGamesQueueFrame
	WarGamesQueueFrame:StripTextures()
	S:HandleScrollBar(_G.WarGamesQueueFrameScrollFrameScrollBar)
	S:HandleScrollBar(_G.WarGamesQueueFrameInfoScrollFrameScrollBar)
	_G.WarGamesQueueFrameDescription:SetTextColor(1, 1, 1)
	WarGamesQueueFrame.HorizontalBar:Kill()
	S:HandleButton(_G.WarGameStartButton)
end

function S:PVPReadyDialog()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogHideButton)
end

S:AddCallback('PVPReadyDialog')
S:AddCallbackForAddon('Blizzard_PVPUI')
