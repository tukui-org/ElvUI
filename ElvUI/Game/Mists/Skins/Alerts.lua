local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local SetLargeGuildTabardTextures = SetLargeGuildTabardTextures
local GetItemQualityByID = C_Item.GetItemQualityByID

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
	icon.Overlay:Kill()

	local texture = icon.Texture
	texture:SetTexCoords()
	texture:ClearAllPoints()
	texture:Point('LEFT', frame, 7, 0)

	if not icon.backdrop then
		icon:CreateBackdrop()
		icon.backdrop:SetOutside(texture)
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

local function SkinDungeonCompletionAlert(frame)
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

	frame.glowFrame:Kill()
	frame.glowFrame.glow:Kill()
	frame.shine:Kill()
	frame.raidArt:Kill()
	frame.heroicIcon:Kill()
	frame.dungeonArt1:Kill()
	frame.dungeonArt2:Kill()
	frame.dungeonArt3:Kill()
	frame.dungeonArt4:Kill()

	-- Icon
	frame.dungeonTexture:SetTexCoords()
	frame.dungeonTexture:SetDrawLayer('OVERLAY')
	frame.dungeonTexture:ClearAllPoints()
	frame.dungeonTexture:Point('LEFT', frame, 7, 0)

	if not frame.dungeonTexture.b then
		frame.dungeonTexture.b = CreateFrame('Frame', nil, frame)
		frame.dungeonTexture.b:SetTemplate()
		frame.dungeonTexture.b:SetOutside(frame.dungeonTexture)
		frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
	end
end

local function SkinChallengeModeAlert(frame)
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

	frame.glowFrame:Kill()
	frame.glowFrame.glow:Kill()
	frame.shine:Kill()

	-- the $parentBorder ring are only reachable by region order
	local background, _, border = frame:GetRegions()
	background:Hide()
	border:Kill()

	-- Icon
	frame.dungeonTexture:SetTexCoords()
	frame.dungeonTexture:SetDrawLayer('OVERLAY')

	if not frame.dungeonTexture.b then
		frame.dungeonTexture.b = CreateFrame('Frame', nil, frame)
		frame.dungeonTexture.b:SetTemplate()
		frame.dungeonTexture.b:SetOutside(frame.dungeonTexture)
		frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
	end
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

	local _, background = frame:GetRegions() -- unnamed GuildChallenges art, the emblem background stays
	background:Kill()
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

local function SkinDigsiteCompleteAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -16, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 13, 6)
	end

	local background = frame:GetRegions()
	background:Hide()

	frame.glow:Kill()
	frame.shine:Kill()
	frame.DigsiteTypeTexture:Point('LEFT', -10, -14)
end

local function SkinStorePurchaseAlert(frame)
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

	local _, ring = frame:GetRegions() -- the CheckButtonGlow ring is only named Border
	ring:Kill()

	frame.Background:Kill()
	frame.glow:Kill()
	frame.shine:Kill()

	frame.Icon:SetTexCoords()
	frame.Icon:SetDrawLayer('BORDER', 5)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)
	end
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

local function SkinLegendaryItemAlert(frame, itemLink)
	if not frame.IsSkinned then
		frame.Background:Kill()
		frame.Background2:Kill()
		frame.Background3:Kill()
		frame.Ring1:Kill()
		frame.Particles3:Kill()
		frame.Particles2:Kill()
		frame.Particles1:Kill()
		frame.Starglow:Kill()
		frame.glow:Kill()
		frame.shine:Kill()

		-- Icon
		frame.Icon:SetTexCoords()
		frame.Icon:SetDrawLayer('ARTWORK')
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)

		-- Create Backdrop
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 20, -20)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 20)

		frame.IsSkinned = true
	end

	local itemRarity = GetItemQualityByID(itemLink)
	local r, g, b = E:GetItemQualityColor(itemRarity)
	frame.Icon.b:SetBackdropBorderColor(r, g, b)
end

local function SkinLootWonAlert(frame)
	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	frame:SetAlpha(1)
	frame.Background:Kill()
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.Icon:SetDrawLayer('BORDER')
	frame.IconBorder:Kill()
	frame.SpecRing:SetTexture(E.ClearTexture)

	frame.glow:Kill()
	frame.shine:Kill()
	frame.BGAtlas:Kill()
	frame.PvPBackground:Kill()

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

local function SkinNewPetAlert(frame)
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

	-- Encounters
	hooksecurefunc(_G.DungeonCompletionAlertSystem, 'setUpFunction', SkinDungeonCompletionAlert)
	hooksecurefunc(_G.ChallengeModeAlertSystem, 'setUpFunction', SkinChallengeModeAlert)
	hooksecurefunc(_G.GuildChallengeAlertSystem, 'setUpFunction', SkinGuildChallengeAlert)

	-- Archaeology
	hooksecurefunc(_G.DigsiteCompleteAlertSystem, 'setUpFunction', SkinDigsiteCompleteAlert)

	-- Store
	hooksecurefunc(_G.StorePurchaseAlertSystem, 'setUpFunction', SkinStorePurchaseAlert)

	-- Honor
	hooksecurefunc(_G.HonorAwardedAlertSystem, 'setUpFunction', SkinHonorAwardedAlert)

	-- Loot
	hooksecurefunc(_G.LegendaryItemAlertSystem, 'setUpFunction', SkinLegendaryItemAlert)
	hooksecurefunc(_G.LootAlertSystem, 'setUpFunction', SkinLootWonAlert)
	hooksecurefunc(_G.LootUpgradeAlertSystem, 'setUpFunction', SkinLootUpgradeAlert)
	hooksecurefunc(_G.MoneyWonAlertSystem, 'setUpFunction', SkinMoneyWonAlert)

	-- Professions
	hooksecurefunc(_G.NewRecipeLearnedAlertSystem, 'setUpFunction', SkinNewRecipeLearnedAlert)

	-- Pets/Mounts/Toys
	hooksecurefunc(_G.NewPetAlertSystem, 'setUpFunction', SkinNewPetAlert)
	hooksecurefunc(_G.NewMountAlertSystem, 'setUpFunction', SkinNewPetAlert)
	hooksecurefunc(_G.NewToyAlertSystem, 'setUpFunction', SkinNewPetAlert)
end

S:AddCallback('AlertSystem')
