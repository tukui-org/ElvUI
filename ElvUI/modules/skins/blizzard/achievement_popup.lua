local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.achievement_popup ~= true then return end
	local function SkinAchievePopUp()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i]
			
			if frame then
				frame:SetAlpha(1)
				frame.SetAlpha = E.noop
				if not frame.backdrop then
					frame:CreateBackdrop("Default")
					frame.backdrop:Point("TOPLEFT", _G[frame:GetName().."Background"], "TOPLEFT", -2, -6)
					frame.backdrop:Point("BOTTOMRIGHT", _G[frame:GetName().."Background"], "BOTTOMRIGHT", -2, 6)		
				end
				
				-- Background
				_G["AchievementAlertFrame"..i.."Background"]:SetTexture(nil)

				_G["AchievementAlertFrame"..i.."Glow"]:Kill()
				_G["AchievementAlertFrame"..i.."Shine"]:Kill()
				
				-- Text
				_G["AchievementAlertFrame"..i.."Unlocked"]:FontTemplate(nil, 12)
				_G["AchievementAlertFrame"..i.."Unlocked"]:SetTextColor(1, 1, 1)
				_G["AchievementAlertFrame"..i.."Name"]:FontTemplate(nil, 12)

				-- Icon
				_G["AchievementAlertFrame"..i.."IconTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				_G["AchievementAlertFrame"..i.."IconOverlay"]:Kill()
				
				_G["AchievementAlertFrame"..i.."IconTexture"]:ClearAllPoints()
				_G["AchievementAlertFrame"..i.."IconTexture"]:Point("LEFT", frame, 7, 0)
				
				if not _G["AchievementAlertFrame"..i.."IconTexture"].b then
					_G["AchievementAlertFrame"..i.."IconTexture"].b = CreateFrame("Frame", nil, _G["AchievementAlertFrame"..i])
					_G["AchievementAlertFrame"..i.."IconTexture"].b:SetFrameLevel(0)
					_G["AchievementAlertFrame"..i.."IconTexture"].b:SetTemplate("Default")
					_G["AchievementAlertFrame"..i.."IconTexture"].b:Point("TOPLEFT", _G["AchievementAlertFrame"..i.."IconTexture"], "TOPLEFT", -2, 2)
					_G["AchievementAlertFrame"..i.."IconTexture"].b:Point("BOTTOMRIGHT", _G["AchievementAlertFrame"..i.."IconTexture"], "BOTTOMRIGHT", 2, -2)
				end
			end
		end
	end
	hooksecurefunc("AlertFrame_SetAchievementAnchors", SkinAchievePopUp)
	
	function SkinDungeonPopUP()
		for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
			local frame = _G["DungeonCompletionAlertFrame"..i]
			if frame then
				frame:SetAlpha(1)
				frame.SetAlpha = E.noop
				if not frame.backdrop then
					frame:CreateBackdrop("Default")
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
				
				-- Icon
				frame.dungeonTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				
				frame.dungeonTexture:ClearAllPoints()
				frame.dungeonTexture:Point("LEFT", frame, 7, 0)
				
				if not frame.dungeonTexture.b then
					frame.dungeonTexture.b = CreateFrame("Frame", nil, frame)
					frame.dungeonTexture.b:SetFrameLevel(0)
					frame.dungeonTexture.b:SetTemplate("Default")
					frame.dungeonTexture.b:Point("TOPLEFT", frame.dungeonTexture, "TOPLEFT", -2, 2)
					frame.dungeonTexture.b:Point("BOTTOMRIGHT", frame.dungeonTexture, "BOTTOMRIGHT", 2, -2)
				end
			end
		end				
	end
	
	hooksecurefunc("AlertFrame_SetDungeonCompletionAnchors", SkinDungeonPopUP)
	
	
	function SkinGuildChallengePopUp()
		local frame = _G["GuildChallengeAlertFrame"]

		if frame then
			frame:SetAlpha(1)
			frame.SetAlpha = E.noop

			if not frame.backdrop then
				frame:CreateBackdrop("Default")
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

			_G["GuildChallengeAlertFrameGlow"]:Kill()
			_G["GuildChallengeAlertFrameShine"]:Kill()
			_G["GuildChallengeAlertFrameEmblemBorder"]:Kill()

			-- Icon border
			if not _G["GuildChallengeAlertFrameEmblemIcon"].b then
				_G["GuildChallengeAlertFrameEmblemIcon"].b = CreateFrame("Frame", nil, _G["GuildChallengeAlertFrame"])
				_G["GuildChallengeAlertFrameEmblemIcon"].b:SetFrameLevel(0)
				_G["GuildChallengeAlertFrameEmblemIcon"].b:SetTemplate("Default")
				_G["GuildChallengeAlertFrameEmblemIcon"].b:Point("TOPLEFT", _G["GuildChallengeAlertFrameEmblemIcon"], "TOPLEFT", -3, 3)
				_G["GuildChallengeAlertFrameEmblemIcon"].b:Point("BOTTOMRIGHT", _G["GuildChallengeAlertFrameEmblemIcon"], "BOTTOMRIGHT", 3, -2)
			end

			SetLargeGuildTabardTextures("player", GuildChallengeAlertFrameEmblemIcon, nil, nil)
		end
	end
	hooksecurefunc("AlertFrame_SetGuildChallengeAnchors", SkinGuildChallengePopUp)

	function SkinChallengePopUp()
		local frame = _G["ChallengeModeAlertFrame1"]

		if frame then
			frame:SetAlpha(1)
			frame.SetAlpha = E.noop

			if not frame.backdrop then
				frame:CreateBackdrop("Default")
				frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 19, -6)
				frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -22, 6)
			end

			-- Background
			for i = 1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\Challenges\\challenges-main" then
						region:Kill()
					end
				end
			end

			_G["ChallengeModeAlertFrame1Shine"]:Kill()
			_G["ChallengeModeAlertFrame1GlowFrame"]:Kill()
			_G["ChallengeModeAlertFrame1GlowFrame"].glow:Kill()
			_G["ChallengeModeAlertFrame1Border"]:Kill()

			-- Icon
			_G["ChallengeModeAlertFrame1DungeonTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			_G["ChallengeModeAlertFrame1DungeonTexture"]:ClearAllPoints()
			_G["ChallengeModeAlertFrame1DungeonTexture"]:Point("LEFT", frame.backdrop, 9, 0)

			-- Icon border
			if not _G["ChallengeModeAlertFrame1DungeonTexture"].b then
				_G["ChallengeModeAlertFrame1DungeonTexture"].b = CreateFrame("Frame", nil, _G["ChallengeModeAlertFrame1"])
				_G["ChallengeModeAlertFrame1DungeonTexture"].b:SetFrameLevel(0)
				_G["ChallengeModeAlertFrame1DungeonTexture"].b:SetTemplate("Default")
				_G["ChallengeModeAlertFrame1DungeonTexture"].b:Point("TOPLEFT", _G["ChallengeModeAlertFrame1DungeonTexture"], "TOPLEFT", -2, 2)
				_G["ChallengeModeAlertFrame1DungeonTexture"].b:Point("BOTTOMRIGHT", _G["ChallengeModeAlertFrame1DungeonTexture"], "BOTTOMRIGHT", 2, -2)
			end
		end
	end
	hooksecurefunc("AlertFrame_SetChallengeModeAnchors", SkinChallengePopUp)
	
	function SkinScenarioPopUp()
		local frame = _G["ScenarioAlertFrame1"]

		if frame then
			frame:SetAlpha(1)
			frame.SetAlpha = E.noop

			if not frame.backdrop then
				frame:CreateBackdrop("Transparent")
				frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 4, 4)
				frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 6)
			end

			-- Background
			for i = 1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\Scenarios\\ScenariosParts" then
						region:Kill()
					end
				end
			end

			_G["ScenarioAlertFrame1Shine"]:Kill()
			_G["ScenarioAlertFrame1GlowFrame"]:Kill()
			_G["ScenarioAlertFrame1GlowFrame"].glow:Kill()
			--_G["ScenarioAlertFrame1Border"]:Kill()

			-- Icon
			_G["ScenarioAlertFrame1DungeonTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			_G["ScenarioAlertFrame1DungeonTexture"]:ClearAllPoints()
			_G["ScenarioAlertFrame1DungeonTexture"]:Point("LEFT", frame.backdrop, 9, 0)

			-- Icon border
			if not _G["ScenarioAlertFrame1DungeonTexture"].b then
				_G["ScenarioAlertFrame1DungeonTexture"].b = CreateFrame("Frame", nil, _G["ScenarioAlertFrame1"])
				_G["ScenarioAlertFrame1DungeonTexture"].b:SetFrameLevel(0)
				_G["ScenarioAlertFrame1DungeonTexture"].b:SetTemplate("Default")
				_G["ScenarioAlertFrame1DungeonTexture"].b:Point("TOPLEFT", _G["ScenarioAlertFrame1DungeonTexture"], "TOPLEFT", -2, 2)
				_G["ScenarioAlertFrame1DungeonTexture"].b:Point("BOTTOMRIGHT", _G["ScenarioAlertFrame1DungeonTexture"], "BOTTOMRIGHT", 2, -2)
			end
		end
	end
	hooksecurefunc("AlertFrame_SetScenarioAnchors", SkinScenarioPopUp)	
end

S:RegisterSkin('ElvUI', LoadSkin)