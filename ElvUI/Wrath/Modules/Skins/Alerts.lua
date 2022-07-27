local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local SetLargeGuildTabardTextures = SetLargeGuildTabardTextures
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local hooksecurefunc = hooksecurefunc

local function forceAlpha(self, alpha, forced)
	if alpha ~= 1 and forced ~= true then
		self:SetAlpha(1, true)
	end
end

local function SkinAchievementAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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

	-- Icon
	frame.Icon.Texture:SetTexCoord(unpack(E.TexCoords))
	frame.Icon.Overlay:Kill()

	frame.Icon.Texture:ClearAllPoints()
	frame.Icon.Texture:Point('LEFT', frame, 7, 0)

	if not frame.Icon.Texture.b then
		frame.Icon.Texture.b = CreateFrame('Frame', nil, frame)
		frame.Icon.Texture.b:SetTemplate()
		frame.Icon.Texture.b:SetOutside(frame.Icon.Texture)
		frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
	end
end

local function SkinCriteriaAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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

	frame.Icon.Texture:SetTexCoord(unpack(E.TexCoords))
end

local function SkinDungeonCompletionAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 6)
	end

	if frame.glowFrame then
		frame.glowFrame:Kill()

		if frame.glowFrame.glow then
			frame.glowFrame.glow:Kill()
		end
	end

	if frame.shine then frame.shine:Kill() end
	if frame.raidArt then frame.raidArt:Kill() end
	if frame.heroicIcon then frame.heroicIcon:Kill() end
	if frame.dungeonArt then frame.dungeonArt:Kill() end
	if frame.dungeonArt1 then frame.dungeonArt1:Kill() end
	if frame.dungeonArt2 then frame.dungeonArt2:Kill() end
	if frame.dungeonArt3 then frame.dungeonArt3:Kill() end
	if frame.dungeonArt4 then frame.dungeonArt4:Kill() end

	-- Icon
	frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))
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

local function SkinGuildChallengeAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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
	if not frame.hooked then hooksecurefunc(frame, 'SetAlpha', forceAlpha); frame.hooked = true end

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

local function SkinInvasionAlert(frame)
	if not frame.isSkinned then
		frame:SetAlpha(1)
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)

		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 4, 4)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -7, 6)

		--Background contains the item border too, so have to remove it
		if frame.GetRegions then
			local region, icon = frame:GetRegions()
			if region and region:IsObjectType('Texture') then
				if region:GetAtlas() == 'legioninvasion-Toast-Frame' then
					region:Kill()
				end
			end

			-- Icon border
			if icon and icon:IsObjectType('Texture') then
				if icon:GetTexture() == [[Interface\Icons\Ability_Warlock_DemonicPower]] then
					icon.b = CreateFrame('Frame', nil, frame)
					icon.b:SetTemplate()
					icon.b:SetOutside(icon)
					icon:SetParent(icon.b)
					icon:SetDrawLayer('OVERLAY')
					icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end

		frame.isSkinned = true
	end
end

local function SkinScenarioAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 4, 4)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -7, 6)
	end

	-- Background
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:IsObjectType('Texture') then
			if region:GetAtlas() == 'Toast-IconBG' or region:GetAtlas() == 'Toast-Frame' then
				region:Kill()
			end
		end
	end

	frame.shine:Kill()
	frame.glowFrame:Kill()
	frame.glowFrame.glow:Kill()

	-- Icon
	frame.dungeonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.dungeonTexture:ClearAllPoints()
	frame.dungeonTexture:Point('LEFT', frame.backdrop, 9, 0)
	frame.dungeonTexture:SetDrawLayer('OVERLAY')

	-- Icon border
	if not frame.dungeonTexture.b then
		frame.dungeonTexture.b = CreateFrame('Frame', nil, frame)
		frame.dungeonTexture.b:SetTemplate()
		frame.dungeonTexture.b:SetOutside(frame.dungeonTexture)
		frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
	end
end

local function SkinWorldQuestCompleteAlert(frame)
	if not frame.isSkinned then
		frame:SetAlpha(1)
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)

		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 10, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -14, 6)

		frame.shine:Kill()

		-- Background
		frame.ToastBackground:Kill()

		-- Icon
		frame.QuestTexture:SetTexCoord(unpack(E.TexCoords))
		frame.QuestTexture:SetDrawLayer('ARTWORK')
		frame.QuestTexture.b = CreateFrame('Frame', nil, frame)
		frame.QuestTexture.b:SetTemplate()
		frame.QuestTexture.b:SetOutside(frame.QuestTexture)
		frame.QuestTexture:SetParent(frame.QuestTexture.b)

		frame.isSkinned = true
	end
end

local function SkinLegendaryItemAlert(frame, itemLink)
	if not frame.isSkinned then
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
		frame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame.Icon:SetDrawLayer('ARTWORK')
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)

		-- Create Backdrop
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 20, -20)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 20)

		frame.isSkinned = true
	end

	local _, _, itemRarity = GetItemInfo(itemLink)
	local color = itemRarity and ITEM_QUALITY_COLORS[itemRarity]
	if color then
		frame.Icon.b:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		frame.Icon.b:SetBackdropBorderColor(0, 0, 0)
	end
end

local function SkinLootWonAlert(frame)
	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
		frame.hooked = true
	end

	frame:SetAlpha(1)
	frame.Background:Kill()

	local lootItem = frame.lootItem or frame
	lootItem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	lootItem.Icon:SetDrawLayer('BORDER')
	lootItem.IconBorder:Kill()
	lootItem.SpecRing:SetTexture('')

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
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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

local function SkinDigsiteCompleteAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -16, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 13, 6)
	end

	frame.glow:Kill()
	frame.shine:Kill()
	frame:GetRegions():Hide()
	frame.DigsiteTypeTexture:Point('LEFT', -10, -14)
end

local function SkinNewRecipeLearnedAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
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
		hooksecurefunc(frame, 'SetAlpha', forceAlpha)
		frame.hooked = true
	end

	frame.Background:Kill()
	frame.IconBorder:Kill()

	frame.Icon:SetMask('')
	frame.Icon:SetTexCoord(unpack(E.TexCoords))
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
	hooksecurefunc(_G.GuildChallengeAlertSystem, 'setUpFunction', SkinGuildChallengeAlert)
	hooksecurefunc(_G.InvasionAlertSystem, 'setUpFunction', SkinInvasionAlert)
	hooksecurefunc(_G.ScenarioAlertSystem, 'setUpFunction', SkinScenarioAlert)
	hooksecurefunc(_G.WorldQuestCompleteAlertSystem, 'setUpFunction', SkinWorldQuestCompleteAlert)

	-- Honor
	hooksecurefunc(_G.HonorAwardedAlertSystem, 'setUpFunction', SkinHonorAwardedAlert)

	-- Loot
	hooksecurefunc(_G.LegendaryItemAlertSystem, 'setUpFunction', SkinLegendaryItemAlert)
	hooksecurefunc(_G.LootAlertSystem, 'setUpFunction', SkinLootWonAlert)
	hooksecurefunc(_G.LootUpgradeAlertSystem, 'setUpFunction', SkinLootUpgradeAlert)
	hooksecurefunc(_G.MoneyWonAlertSystem, 'setUpFunction', SkinMoneyWonAlert)

	-- Professions
	hooksecurefunc(_G.DigsiteCompleteAlertSystem, 'setUpFunction', SkinDigsiteCompleteAlert)
	hooksecurefunc(_G.NewRecipeLearnedAlertSystem, 'setUpFunction', SkinNewRecipeLearnedAlert)

	-- Pets/Mounts
	hooksecurefunc(_G.NewPetAlertSystem, 'setUpFunction', SkinNewPetAlert)
	hooksecurefunc(_G.NewMountAlertSystem, 'setUpFunction', SkinNewPetAlert)
end

S:AddCallback('AlertSystem')
