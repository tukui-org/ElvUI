local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local SetLargeGuildTabardTextures = SetLargeGuildTabardTextures

local function ForceAlpha(frame, alpha, forced)
	if alpha ~= 1 and forced ~= true then
		frame:SetAlpha(1, true)
	end
end

local function SkinAchievementAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Background, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Background, 'BOTTOMRIGHT', -2, 6)
	end

	-- Background
	frame.Background:SetTexture()
	frame.glow:Kill()
	frame.shine:Kill()
	frame.GuildBanner:Kill()
	frame.GuildBorder:Kill()

	-- Text
	frame.Unlocked:FontTemplate(nil, 12)
	frame.Unlocked:SetTextColor(1, 1, 1)
	frame.Name:FontTemplate(nil, 12)

	local icon = frame.Icon
	if icon then
		icon.Overlay:Kill()

		local texture = frame.Icon.Texture
		if texture then
			texture:SetTexCoords()
			texture:ClearAllPoints()
			texture:Point('LEFT', frame, 7, 0)

			if not icon.backdrop then
				icon:CreateBackdrop()
				icon.backdrop:SetOutside(texture)
			end
		end
	end
end

local function SkinCriteriaAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 6)
	end

	frame.Unlocked:SetTextColor(1, 1, 1)
	frame.Name:SetTextColor(1, 1, 0)
	frame.Background:Kill()
	frame.glow:Kill()
	frame.shine:Kill()
	frame.Icon.Bling:Kill()
	frame.Icon.Overlay:Kill()

	-- Icon border
	if not frame.Icon.Texture.b then
		frame.Icon.Texture.b = CreateFrame('Frame', nil, frame)
		frame.Icon.Texture.b:SetTemplate()
		frame.Icon.Texture.b:Point('TOPLEFT', frame.Icon.Texture, 'TOPLEFT', -3, 3)
		frame.Icon.Texture.b:Point('BOTTOMRIGHT', frame.Icon.Texture, 'BOTTOMRIGHT', 3, -2)
		frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
	end

	frame.Icon.Texture:SetTexCoords()
end

local function SkinGuildChallengeAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 6)
	end

	-- Background
	local region = select(2, frame:GetRegions())
	if region:IsObjectType('Texture') then
		if region:GetTexture() == [[Interface\GuildFrame\GuildChallenges]] then
			region:Kill()
		end
	end

	frame.glow:Kill()
	frame.shine:Kill()
	frame.EmblemBorder:Kill()

	-- Icon border
	local EmblemIcon = frame.EmblemIcon
	if not EmblemIcon.b then
		EmblemIcon.b = CreateFrame('Frame', nil, frame)
		EmblemIcon.b:SetTemplate()
		EmblemIcon.b:Point('TOPLEFT', EmblemIcon, 'TOPLEFT', -3, 3)
		EmblemIcon.b:Point('BOTTOMRIGHT', EmblemIcon, 'BOTTOMRIGHT', 3, -2)
		EmblemIcon:SetParent(EmblemIcon.b)
	end

	SetLargeGuildTabardTextures('player', EmblemIcon)
end

local function SkinHonorAwardedAlert(frame)
	frame:SetAlpha(1)
	if not frame.hooked then hooksecurefunc(frame, 'SetAlpha', ForceAlpha); frame.hooked = true end

	frame.Background:Kill()
	frame.IconBorder:Kill()

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
	end
end

local function SkinLootWonAlert(frame)
	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	frame:SetAlpha(1)
	frame.Background:Kill()

	local lootItem = frame.lootItem or frame
	lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	lootItem.Icon:SetDrawLayer('BORDER')
	lootItem.IconBorder:Kill()
	lootItem.SpecRing:SetTexture(E.ClearTexture)

	frame.glow:Kill()
	frame.shine:Kill()
	frame.BGAtlas:Kill()
	frame.PvPBackground:Kill()

	-- Icon border
	if not lootItem.Icon.b then
		lootItem.Icon.b = CreateFrame('Frame', nil, frame)
		lootItem.Icon.b:SetTemplate()
		lootItem.Icon.b:SetOutside(lootItem.Icon)
		lootItem.Icon:SetParent(lootItem.Icon.b)
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', lootItem.Icon.b, 'TOPLEFT', -4, 4)
		frame.backdrop:Point('BOTTOMRIGHT', lootItem.Icon.b, 'BOTTOMRIGHT', 180, -4)
	end
end

local function SkinLootUpgradeAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	frame.Background:Kill()
	frame.Sheen:Kill()
	frame.BorderGlow:Kill()
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.Icon:SetDrawLayer('BORDER', 5)
	frame.Icon:ClearAllPoints()
	frame.Icon:SetInside(frame.BaseQualityBorder, 5, 5)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -8, 8)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -8)
	end
end

local function SkinMoneyWonAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	frame.Background:Kill()
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.IconBorder:Kill()

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
	end
end

local function SkinEntitlementDeliveredAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 10, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -14, 6)
	end

	-- Background
	frame.Background:Kill()
	frame.glow:Kill()
	frame.shine:Kill()

	-- Icon
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.Icon:ClearAllPoints()
	frame.Icon:Point('LEFT', frame.backdrop, 9, 0)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:Point('TOPLEFT', frame.Icon, 'TOPLEFT', -2, 2)
		frame.Icon.b:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 2, -2)
		frame.Icon:SetParent(frame.Icon.b)
	end
end

local function SkinRafRewardDeliveredAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 10, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -14, 6)
	end

	-- Background
	frame.StandardBackground:Kill()
	frame.glow:Kill()
	frame.shine:Kill()

	-- Icon
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.Icon:ClearAllPoints()
	frame.Icon:Point('LEFT', frame.backdrop, 9, 0)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:Point('TOPLEFT', frame.Icon, 'TOPLEFT', -2, 2)
		frame.Icon.b:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 2, -2)
		frame.Icon:SetParent(frame.Icon.b)
	end
end

local function SkinNewRecipeLearnedAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 19, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -23, 6)
	end

	frame.glow:Kill()
	frame.shine:Kill()
	frame:GetRegions():Hide()

	frame.Icon:SetMask('')
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.Icon:SetDrawLayer('BORDER', 5)
	frame.Icon:ClearAllPoints()
	frame.Icon:Point('LEFT', frame.backdrop, 9, 0)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:Point('TOPLEFT', frame.Icon, 'TOPLEFT', -2, 2)
		frame.Icon.b:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 2, -2)
		frame.Icon:SetParent(frame.Icon.b)
	end
end

local function SkinMiscAlerts(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	frame.Background:Kill()
	frame.IconBorder:Kill()

	frame.Icon:SetMask('')
	frame.Icon:SetTexCoords()
	frame.Icon:SetDrawLayer('BORDER', 5)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:Point('TOPLEFT', frame.Icon, 'TOPLEFT', -2, 2)
		frame.Icon.b:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 2, -2)
		frame.Icon:SetParent(frame.Icon.b)
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -8, 8)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -8)
	end
end

function S:AlertSystem()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.alertframes) then return end

	-- Achievements
	hooksecurefunc(_G.AchievementAlertSystem, 'setUpFunction', SkinAchievementAlert)
	hooksecurefunc(_G.CriteriaAlertSystem, 'setUpFunction', SkinCriteriaAlert)

	-- Guild
	hooksecurefunc(_G.GuildChallengeAlertSystem, 'setUpFunction', SkinGuildChallengeAlert)

	-- Honor
	hooksecurefunc(_G.HonorAwardedAlertSystem, 'setUpFunction', SkinHonorAwardedAlert)

	-- Loot
	hooksecurefunc(_G.LootAlertSystem, 'setUpFunction', SkinLootWonAlert)
	hooksecurefunc(_G.LootUpgradeAlertSystem, 'setUpFunction', SkinLootUpgradeAlert)
	hooksecurefunc(_G.MoneyWonAlertSystem, 'setUpFunction', SkinMoneyWonAlert)
	hooksecurefunc(_G.EntitlementDeliveredAlertSystem, 'setUpFunction', SkinEntitlementDeliveredAlert)
	hooksecurefunc(_G.RafRewardDeliveredAlertSystem, 'setUpFunction', SkinRafRewardDeliveredAlert)

	-- Professions
	hooksecurefunc(_G.NewRecipeLearnedAlertSystem, 'setUpFunction', SkinNewRecipeLearnedAlert)

	-- Pets/Mounts/Toys
	hooksecurefunc(_G.NewPetAlertSystem, 'setUpFunction', SkinMiscAlerts)
	hooksecurefunc(_G.NewMountAlertSystem, 'setUpFunction', SkinMiscAlerts)
	hooksecurefunc(_G.NewToyAlertSystem, 'setUpFunction', SkinMiscAlerts)

	-- Cosmetics
	hooksecurefunc(_G.NewCosmeticAlertFrameSystem, 'setUpFunction', SkinMiscAlerts)
end

S:AddCallback('AlertSystem')
