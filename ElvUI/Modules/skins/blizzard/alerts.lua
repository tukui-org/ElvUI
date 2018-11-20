local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local unpack, select = unpack, select
--WoW API / Variables
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local SetLargeGuildTabardTextures = SetLargeGuildTabardTextures
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true then return end

	local function forceAlpha(self, alpha, isForced)
		if alpha ~= 1 and isForced ~= true then
			self:SetAlpha(1, true)
		end
	end

	--[[ SKINNING FUNCTIONS ]]--
	local function SkinAchievementAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end
		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame.Background, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", -2, 6)
		end

		-- Background
		frame.Background:SetTexture(nil)
		frame.OldAchievement:Kill()
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
		frame.Icon.Texture:Point("LEFT", frame, 7, 0)

		if not frame.Icon.Texture.b then
			frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
			frame.Icon.Texture.b:SetTemplate("Default")
			frame.Icon.Texture.b:SetOutside(frame.Icon.Texture)
			frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
		end
	end

	local function SkinCriteriaAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)
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
			frame.Icon.Texture.b = CreateFrame("Frame", nil, frame)
			frame.Icon.Texture.b:SetTemplate("Default")
			frame.Icon.Texture.b:Point("TOPLEFT", frame.Icon.Texture, "TOPLEFT", -3, 3)
			frame.Icon.Texture.b:Point("BOTTOMRIGHT", frame.Icon.Texture, "BOTTOMRIGHT", 3, -2)
			frame.Icon.Texture:SetParent(frame.Icon.Texture.b)
		end
		frame.Icon.Texture:SetTexCoord(unpack(E.TexCoords))
	end

	local function SkinDungeonCompletionAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end
		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)
		end

		frame.shine:Kill()
		frame.glowFrame:Kill()
		frame.glowFrame.glow:Kill()

		frame.raidArt:Kill()
		frame.dungeonArt1:Kill()
		frame.dungeonArt2:Kill()
		frame.dungeonArt3:Kill()
		frame.dungeonArt4:Kill()
		frame.heroicIcon:Kill()

		-- Icon
		frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))
		frame.dungeonTexture:SetDrawLayer('OVERLAY')
		frame.dungeonTexture:ClearAllPoints()
		frame.dungeonTexture:Point("LEFT", frame, 7, 0)

		if not frame.dungeonTexture.b then
			frame.dungeonTexture.b = CreateFrame("Frame", nil, frame)
			frame.dungeonTexture.b:SetTemplate("Default")
			frame.dungeonTexture.b:SetOutside(frame.dungeonTexture)
			frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
		end
	end

	local function SkinGuildChallengeAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)
		end

		-- Background
		local region = select(2, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\GuildFrame\\GuildChallenges" then
				region:Kill()
			end
		end

		frame.glow:Kill()
		frame.shine:Kill()
		frame.EmblemBorder:Kill()

		-- Icon border
		local EmblemIcon = frame.EmblemIcon
		if not EmblemIcon.b then
			EmblemIcon.b = CreateFrame("Frame", nil, frame)
			EmblemIcon.b:SetTemplate("Default")
			EmblemIcon.b:Point("TOPLEFT", EmblemIcon, "TOPLEFT", -3, 3)
			EmblemIcon.b:Point("BOTTOMRIGHT", EmblemIcon, "BOTTOMRIGHT", 3, -2)
			EmblemIcon:SetParent(EmblemIcon.b)
		end
		SetLargeGuildTabardTextures("player", EmblemIcon, nil, nil)
	end

	local function SkinInvasionAlert(frame)
		if not frame.isSkinned then
			frame:SetAlpha(1)
			hooksecurefunc(frame, "SetAlpha", forceAlpha);
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 4, 4)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 6)
			--Background contains the item border too, so have to remove it
			local region, icon = frame:GetRegions()
			if region and region:GetObjectType() == "Texture" then
				if region:GetAtlas() == "legioninvasion-Toast-Frame" then
					region:Kill()
				end
			end
			-- Icon border
			if icon and icon:GetObjectType() == "Texture" then
				if icon:GetTexture() == "Interface\\Icons\\Ability_Warlock_DemonicPower" then
					icon.b = CreateFrame("Frame", nil, frame)
					icon.b:SetTemplate("Default")
					icon.b:SetOutside(icon)
					icon:SetParent(icon.b)
					icon:SetDrawLayer("OVERLAY")
					icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
			frame.isSkinned = true
		end
	end

	local function SkinScenarioAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 4, 4)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 6)
		end

		-- Background
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetAtlas() == "Toast-IconBG" or region:GetAtlas() == "Toast-Frame" then
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
		frame.dungeonTexture:Point("LEFT", frame.backdrop, 9, 0)
		frame.dungeonTexture:SetDrawLayer("OVERLAY")

		-- Icon border
		if not frame.dungeonTexture.b then
			frame.dungeonTexture.b = CreateFrame("Frame", nil, frame)
			frame.dungeonTexture.b:SetTemplate("Default")
			frame.dungeonTexture.b:SetOutside(frame.dungeonTexture)
			frame.dungeonTexture:SetParent(frame.dungeonTexture.b)
		end
	end

	local function SkinWorldQuestCompleteAlert(frame)
		if not frame.isSkinned then
			frame:SetAlpha(1)
			hooksecurefunc(frame, "SetAlpha", forceAlpha)
			frame:CreateBackdrop("Transparent")
			frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -6)
			frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 6)
			frame.shine:Kill()
			-- Background
			for i = 1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST" then
						region:Kill()
					end
				end
			end
			--Icon
			frame.QuestTexture:SetTexCoord(unpack(E.TexCoords))
			frame.QuestTexture:SetDrawLayer("ARTWORK")
			frame.QuestTexture.b = CreateFrame("Frame", nil, frame)
			frame.QuestTexture.b:SetTemplate("Default")
			frame.QuestTexture.b:SetOutside(frame.QuestTexture)
			frame.QuestTexture:SetParent(frame.QuestTexture.b)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonFollowerAlert(frame, _, _, _, quality)
		if not frame.isSkinned then
			frame.glow:Kill()
			frame.shine:Kill()
			frame.FollowerBG:SetAlpha(0)
			frame.DieIcon:SetAlpha(0)
			--Background
			for i = 1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetAtlas() == "Garr_MissionToast" then
						region:Kill()
					end
				end
			end
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 16, -3)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -16, 16)

			frame.PortraitFrame.PortraitRing:Hide()
			frame.PortraitFrame.PortraitRingQuality:SetTexture("")
			frame.PortraitFrame.LevelBorder:SetAlpha(0)

			local level = frame.PortraitFrame.Level
			level:ClearAllPoints()
			level:Point("BOTTOM", frame.PortraitFrame, 0, 12)

			local squareBG = CreateFrame("Frame", nil, frame.PortraitFrame)
			squareBG:SetFrameLevel(frame.PortraitFrame:GetFrameLevel()-1)
			squareBG:Point("TOPLEFT", 3, -3)
			squareBG:Point("BOTTOMRIGHT", -3, 11)
			squareBG:SetTemplate("Default")
			frame.PortraitFrame.squareBG = squareBG

			local cover = frame.PortraitFrame.PortraitRingCover
			if cover then
				cover:SetColorTexture(0, 0, 0)
				cover:SetAllPoints(squareBG)
			end

			frame.isSkinned = true
		end

		local color = ITEM_QUALITY_COLORS[quality]
		if color then
			frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			frame.PortraitFrame.squareBG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local function SkinGarrisonShipFollowerAlert(frame)
		if not frame.isSkinned then
			frame.glow:Kill()
			frame.shine:Kill()
			frame.FollowerBG:SetAlpha(0)
			frame.DieIcon:SetAlpha(0)
			--Background
			frame.Background:Kill()
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 16, -3)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -16, 16)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonTalentAlert(frame)
		if not frame.isSkinned then
			frame:GetRegions():Hide()
			frame.glow:Kill()
			frame.shine:Kill()
			--Icon
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon:SetDrawLayer("ARTWORK")
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 8, -2)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -6, 2)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonBuildingAlert(frame)
		if not frame.isSkinned then
			frame.glow:Kill()
			frame.shine:Kill()
			frame:GetRegions():Hide()
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 8, -8)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -6, 8)
			--Icon
			frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			frame.Icon:SetDrawLayer("ARTWORK")
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonMissionAlert(frame)
		if not frame.isSkinned then
			frame.glow:Kill()
			frame.shine:Kill()
			frame.IconBG:Hide()
			frame.Background:Kill()
			--Icon
			frame.MissionType:SetTexCoord(unpack(E.TexCoords))
			frame.MissionType:SetDrawLayer("ARTWORK")
			frame.MissionType.b = CreateFrame("Frame", nil, frame)
			frame.MissionType.b:SetTemplate("Default")
			frame.MissionType.b:SetOutside(frame.MissionType)
			frame.MissionType:SetParent(frame.MissionType.b)
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 8, -2)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -6, 2)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonShipMissionAlert(frame)
		if not frame.isSkinned then
			frame.Background:Kill()
			frame.glow:Kill()
			frame.shine:Kill()
			--Icon
			frame.MissionType:SetTexCoord(unpack(E.TexCoords))
			frame.MissionType:SetDrawLayer("ARTWORK")
			frame.MissionType.b = CreateFrame("Frame", nil, frame)
			frame.MissionType.b:SetTemplate("Default")
			frame.MissionType.b:SetOutside(frame.MissionType)
			frame.MissionType:SetParent(frame.MissionType.b)
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 8, -2)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -6, 2)

			frame.isSkinned = true
		end
	end

	local function SkinGarrisonRandomMissionAlert(frame, _, _, _, _, _, quality)
		if not frame.isSkinned then
			frame.Background:Kill()
			frame.Blank:Kill()
			frame.IconBG:Kill()
			frame.glow:Kill()
			frame.shine:Kill()
			--Icon
			frame.MissionType:SetTexCoord(unpack(E.TexCoords))
			frame.MissionType:SetDrawLayer("ARTWORK")
			frame.MissionType.b = CreateFrame("Frame", nil, frame)
			frame.MissionType.b:SetTemplate("Default")
			frame.MissionType.b:SetOutside(frame.MissionType)
			frame.MissionType:SetParent(frame.MissionType.b)
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 8, -2)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -6, 2)

			frame.isSkinned = true
		end

		local color = ITEM_QUALITY_COLORS[quality]
		if color then
			frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			frame.PortraitFrame.squareBG:SetBackdropBorderColor(0, 0, 0)
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
			--Icon
			frame.Icon:SetTexCoord(unpack(E.TexCoords))
			frame.Icon:SetDrawLayer("ARTWORK")
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)
			--Create Backdrop
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 20, -20)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 20)

			frame.isSkinned = true
		end

		local _, _, itemRarity = GetItemInfo(itemLink)
		local color = ITEM_QUALITY_COLORS[itemRarity]
		if color then
			frame.Icon.b:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			frame.Icon.b:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local function SkinLootWonAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		frame.Background:Kill()
		frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.Icon:SetDrawLayer("BORDER")
		frame.IconBorder:Kill()
		frame.glow:Kill()
		frame.shine:Kill()
		frame.BGAtlas:Kill()
		frame.PvPBackground:Kill()

		frame.SpecRing:SetTexture("")
		frame.SpecIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -15)
		frame.SpecIcon:SetTexCoord(unpack(E.TexCoords))

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)
		end

		if not frame.SpecIcon.b then
			frame.SpecIcon.b = CreateFrame("Frame", nil, frame)
			frame.SpecIcon.b:SetFrameLevel(3)
			frame.SpecIcon.b:SetTemplate("Default")
			frame.SpecIcon.b:SetPoint("TOPLEFT", frame.SpecIcon, "TOPLEFT", -2, 2)
			frame.SpecIcon.b:SetPoint("BOTTOMRIGHT", frame.SpecIcon, "BOTTOMRIGHT", 2, -2)
			frame.SpecIcon:SetParent(frame.SpecIcon.b)
		end
		frame.SpecIcon.b:SetShown(frame.SpecIcon:IsShown() and frame.SpecIcon:GetTexture() ~= nil)

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
			frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
		end
	end

	local function SkinLootUpgradeAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		frame.Background:Kill()
		frame.Sheen:Kill()
		frame.BorderGlow:Kill()
		frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.Icon:SetDrawLayer("BORDER", 5)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetInside(frame.BaseQualityBorder, 5, 5)

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)
		end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -8, 8)
			frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -8)
		end
	end

	local function SkinMoneyWonAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		frame.Background:Kill()
		frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.IconBorder:Kill()

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetOutside(frame.Icon)
			frame.Icon:SetParent(frame.Icon.b)
		end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
			frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
		end
	end

	local function SkinStorePurchaseAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -6)
			frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 6)
		end

		-- Background
		frame.Background:Kill()
		frame.glow:Kill()
		frame.shine:Kill()

		-- Icon
		frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("LEFT", frame.backdrop, 9, 0)

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
			frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
			frame.Icon:SetParent(frame.Icon.b)
		end
	end

	local function SkinDigsiteCompleteAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -16, -6)
			frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 13, 6)
		end

		frame.glow:Kill()
		frame.shine:Kill()
		frame:GetRegions():Hide()
		frame.DigsiteTypeTexture:SetPoint("LEFT", -10, -14)
	end

	local function SkinNewRecipeLearnedAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', 19, -6)
			frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -23, 6)
		end

		frame.glow:Kill()
		frame.shine:Kill()
		frame:GetRegions():Hide()

		frame.Icon:SetMask("")
		frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.Icon:SetDrawLayer("BORDER", 5)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("LEFT", frame.backdrop, 9, 0)

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
			frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
			frame.Icon:SetParent(frame.Icon.b)
		end
	end

	local function SkinNewPetAlert(frame)
		frame:SetAlpha(1)
		if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

		frame.Background:Kill()
		frame.IconBorder:Kill()

		frame.Icon:SetMask("")
		frame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame.Icon:SetDrawLayer("BORDER", 5)

		-- Icon border
		if not frame.Icon.b then
			frame.Icon.b = CreateFrame("Frame", nil, frame)
			frame.Icon.b:SetTemplate("Default")
			frame.Icon.b:SetPoint("TOPLEFT", frame.Icon, "TOPLEFT", -2, 2)
			frame.Icon.b:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, -2)
			frame.Icon:SetParent(frame.Icon.b)
		end

		if not frame.backdrop then
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -8, 8)
			frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -8)
		end
	end

	--[[ HOOKS ]]--
	-- Achievements
	hooksecurefunc(AchievementAlertSystem, "setUpFunction", SkinAchievementAlert)
	hooksecurefunc(CriteriaAlertSystem, "setUpFunction", SkinCriteriaAlert)

	-- Encounters
	hooksecurefunc(DungeonCompletionAlertSystem, "setUpFunction", SkinDungeonCompletionAlert)
	hooksecurefunc(GuildChallengeAlertSystem, "setUpFunction", SkinGuildChallengeAlert)
	hooksecurefunc(InvasionAlertSystem, "setUpFunction", SkinInvasionAlert)
	hooksecurefunc(ScenarioAlertSystem, "setUpFunction", SkinScenarioAlert)
	hooksecurefunc(WorldQuestCompleteAlertSystem, "setUpFunction", SkinWorldQuestCompleteAlert)

	-- Garrisons
	hooksecurefunc(GarrisonFollowerAlertSystem, "setUpFunction", SkinGarrisonFollowerAlert)
	hooksecurefunc(GarrisonShipFollowerAlertSystem, "setUpFunction", SkinGarrisonShipFollowerAlert)
	hooksecurefunc(GarrisonTalentAlertSystem, "setUpFunction", SkinGarrisonTalentAlert)
	hooksecurefunc(GarrisonBuildingAlertSystem, "setUpFunction", SkinGarrisonBuildingAlert)
	hooksecurefunc(GarrisonMissionAlertSystem, "setUpFunction", SkinGarrisonMissionAlert)
	hooksecurefunc(GarrisonShipMissionAlertSystem, "setUpFunction", SkinGarrisonShipMissionAlert)
	hooksecurefunc(GarrisonRandomMissionAlertSystem, "setUpFunction", SkinGarrisonRandomMissionAlert)

	-- Loot
	hooksecurefunc(LegendaryItemAlertSystem, "setUpFunction", SkinLegendaryItemAlert)
	hooksecurefunc(LootAlertSystem, "setUpFunction", SkinLootWonAlert)
	hooksecurefunc(LootUpgradeAlertSystem, "setUpFunction", SkinLootUpgradeAlert)
	hooksecurefunc(MoneyWonAlertSystem, "setUpFunction", SkinMoneyWonAlert)
	hooksecurefunc(StorePurchaseAlertSystem, "setUpFunction", SkinStorePurchaseAlert)
	-- Professions
	hooksecurefunc(DigsiteCompleteAlertSystem, "setUpFunction", SkinDigsiteCompleteAlert)
	hooksecurefunc(NewRecipeLearnedAlertSystem, "setUpFunction", SkinNewRecipeLearnedAlert)

	-- Pets/Mounts
	hooksecurefunc(NewPetAlertSystem, "setUpFunction", SkinNewPetAlert)
	hooksecurefunc(NewMountAlertSystem, "setUpFunction", SkinNewPetAlert)

	--[[ STATIC SKINNING ]]--
	--Bonus Roll Money
	local frame = BonusRollMoneyWonFrame
	frame:SetAlpha(1)
	hooksecurefunc(frame, "SetAlpha", forceAlpha)
	frame.Background:Kill()
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.IconBorder:Kill()
	-- Icon border
	frame.Icon.b = CreateFrame("Frame", nil, frame)
	frame.Icon.b:SetTemplate("Default")
	frame.Icon.b:SetOutside(frame.Icon)
	frame.Icon:SetParent(frame.Icon.b)
	--Create Backdrop
	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
	frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)

	--Bonus Roll Loot
	frame = BonusRollLootWonFrame
	frame:SetAlpha(1)
	hooksecurefunc(frame, "SetAlpha", forceAlpha)
	frame.Background:Kill()
	frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.IconBorder:Kill()
	frame.glow:Kill()
	frame.shine:Kill()
	-- Icon border
	frame.Icon.b = CreateFrame("Frame", nil, frame)
	frame.Icon.b:SetTemplate("Default")
	frame.Icon.b:SetOutside(frame.Icon)
	frame.Icon:SetParent(frame.Icon.b)
	--Create Backdrop
	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
	frame.backdrop:Point('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
end

S:AddCallback("Alerts", LoadSkin)
