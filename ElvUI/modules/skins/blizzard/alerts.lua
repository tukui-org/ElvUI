local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true then return end
	local function forceAlpha(self, alpha, isForced)
		if alpha ~= 1 and isForced ~= true then
			self:SetAlpha(1, true)
		end
	end
	
	hooksecurefunc("AlertFrame_SetAchievementAnchors", function(anchorFrame)
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i]
			
			if frame then
				frame:SetAlpha(1)
				if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end
				if not frame.backdrop then
					frame:CreateBackdrop("Transparent")
					frame.backdrop:Point("TOPLEFT", _G[frame:GetName().."Background"], "TOPLEFT", -2, -6)
					frame.backdrop:Point("BOTTOMRIGHT", _G[frame:GetName().."Background"], "BOTTOMRIGHT", -2, 6)		
				end
				
				-- Background
				_G["AchievementAlertFrame"..i.."Background"]:SetTexture(nil)
				_G["AchievementAlertFrame"..i..'OldAchievement']:Kill()
				_G["AchievementAlertFrame"..i.."Glow"]:Kill()
				_G["AchievementAlertFrame"..i.."Shine"]:Kill()
				_G["AchievementAlertFrame"..i.."GuildBanner"]:Kill()
				_G["AchievementAlertFrame"..i.."GuildBorder"]:Kill()
				-- Text
				_G["AchievementAlertFrame"..i.."Unlocked"]:FontTemplate(nil, 12)
				_G["AchievementAlertFrame"..i.."Unlocked"]:SetTextColor(1, 1, 1)
				_G["AchievementAlertFrame"..i.."Name"]:FontTemplate(nil, 12)

				-- Icon
				_G["AchievementAlertFrame"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				_G["AchievementAlertFrame"..i.."IconOverlay"]:Kill()
				
				_G["AchievementAlertFrame"..i.."IconTexture"]:ClearAllPoints()
				_G["AchievementAlertFrame"..i.."IconTexture"]:Point("LEFT", frame, 7, 0)
				
				if not _G["AchievementAlertFrame"..i.."IconTexture"].b then
					_G["AchievementAlertFrame"..i.."IconTexture"].b = CreateFrame("Frame", nil, _G["AchievementAlertFrame"..i])
					_G["AchievementAlertFrame"..i.."IconTexture"].b:SetTemplate("Default")
					_G["AchievementAlertFrame"..i.."IconTexture"].b:SetOutside(_G["AchievementAlertFrame"..i.."IconTexture"])
					_G["AchievementAlertFrame"..i.."IconTexture"]:SetParent(_G["AchievementAlertFrame"..i.."IconTexture"].b)
				end
			end
		end	
	end)

	hooksecurefunc("AlertFrame_SetDungeonCompletionAnchors", function(anchorFrame)
		for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
			local frame = _G["DungeonCompletionAlertFrame"..i]
			if frame then
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
		end		
	end)
	
	hooksecurefunc("AlertFrame_SetGuildChallengeAnchors", function(anchorFrame)
		local frame = GuildChallengeAlertFrame

		if frame then
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

			GuildChallengeAlertFrameGlow:Kill()
			GuildChallengeAlertFrameShine:Kill()
			GuildChallengeAlertFrameEmblemBorder:Kill()

			-- Icon border
			if not GuildChallengeAlertFrameEmblemIcon.b then
				GuildChallengeAlertFrameEmblemIcon.b = CreateFrame("Frame", nil, frame)
				GuildChallengeAlertFrameEmblemIcon.b:SetTemplate("Default")
				GuildChallengeAlertFrameEmblemIcon.b:Point("TOPLEFT", GuildChallengeAlertFrameEmblemIcon, "TOPLEFT", -3, 3)
				GuildChallengeAlertFrameEmblemIcon.b:Point("BOTTOMRIGHT", GuildChallengeAlertFrameEmblemIcon, "BOTTOMRIGHT", 3, -2)
				GuildChallengeAlertFrameEmblemIcon:SetParent(GuildChallengeAlertFrameEmblemIcon.b)
			end

			SetLargeGuildTabardTextures("player", GuildChallengeAlertFrameEmblemIcon, nil, nil)
		end	
	end)

	hooksecurefunc("AlertFrame_SetChallengeModeAnchors", function(anchorFrame)
		local frame = ChallengeModeAlertFrame1
		
		if frame then
			frame:SetAlpha(1)
			if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

			if not frame.backdrop then
				frame:CreateBackdrop("Transparent")
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

			ChallengeModeAlertFrame1Shine:Kill()
			ChallengeModeAlertFrame1GlowFrame:Kill()
			ChallengeModeAlertFrame1GlowFrame.glow:Kill()
			ChallengeModeAlertFrame1Border:Kill()

			-- Icon
			ChallengeModeAlertFrame1DungeonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			ChallengeModeAlertFrame1DungeonTexture:ClearAllPoints()
			ChallengeModeAlertFrame1DungeonTexture:Point("LEFT", frame.backdrop, 9, 0)

			-- Icon border
			if not ChallengeModeAlertFrame1DungeonTexture.b then
				ChallengeModeAlertFrame1DungeonTexture.b = CreateFrame("Frame", nil, frame)
				ChallengeModeAlertFrame1DungeonTexture.b:SetTemplate("Default")
				ChallengeModeAlertFrame1DungeonTexture.b:SetOutside(ChallengeModeAlertFrame1DungeonTexture)
				ChallengeModeAlertFrame1DungeonTexture:SetParent(ChallengeModeAlertFrame1DungeonTexture.b)
			end
		end	
	end)

	hooksecurefunc("AlertFrame_SetScenarioAnchors", function(anchorFrame)
		local frame = ScenarioAlertFrame1

		if frame then
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
					if region:GetTexture() == "Interface\\Scenarios\\ScenariosParts" then
						region:Kill()
					end
				end
			end

			ScenarioAlertFrame1Shine:Kill()
			ScenarioAlertFrame1GlowFrame:Kill()
			ScenarioAlertFrame1GlowFrame.glow:Kill()

			-- Icon
			ScenarioAlertFrame1DungeonTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			ScenarioAlertFrame1DungeonTexture:ClearAllPoints()
			ScenarioAlertFrame1DungeonTexture:Point("LEFT", frame.backdrop, 9, 0)

			-- Icon border
			if not ScenarioAlertFrame1DungeonTexture.b then
				ScenarioAlertFrame1DungeonTexture.b = CreateFrame("Frame", nil, frame)
				ScenarioAlertFrame1DungeonTexture.b:SetTemplate("Default")
				ScenarioAlertFrame1DungeonTexture.b:SetOutside(ScenarioAlertFrame1DungeonTexture)
				ScenarioAlertFrame1DungeonTexture:SetParent(ScenarioAlertFrame1DungeonTexture.b)
			end
		end
	end)

	hooksecurefunc('AlertFrame_SetCriteriaAnchors', function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G['CriteriaAlertFrame'..i]
			if frame then
				frame:SetAlpha(1)
				if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end

				if not frame.backdrop then
					frame:CreateBackdrop("Transparent")
					frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
					frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)
				end
				
				_G['CriteriaAlertFrame'..i..'Unlocked']:SetTextColor(1, 1, 1)
				_G['CriteriaAlertFrame'..i..'Name']:SetTextColor(1, 1, 0)
				_G['CriteriaAlertFrame'..i..'Background']:Kill()
				_G['CriteriaAlertFrame'..i..'Glow']:Kill()
				_G['CriteriaAlertFrame'..i..'Shine']:Kill()
				_G['CriteriaAlertFrame'..i..'IconBling']:Kill()
				_G['CriteriaAlertFrame'..i..'IconOverlay']:Kill()
				
				-- Icon border
				if not _G['CriteriaAlertFrame'..i..'IconTexture'].b then
					_G['CriteriaAlertFrame'..i..'IconTexture'].b = CreateFrame("Frame", nil, frame)
					_G['CriteriaAlertFrame'..i..'IconTexture'].b:SetTemplate("Default")
					_G['CriteriaAlertFrame'..i..'IconTexture'].b:Point("TOPLEFT", _G['CriteriaAlertFrame'..i..'IconTexture'], "TOPLEFT", -3, 3)
					_G['CriteriaAlertFrame'..i..'IconTexture'].b:Point("BOTTOMRIGHT", _G['CriteriaAlertFrame'..i..'IconTexture'], "BOTTOMRIGHT", 3, -2)
					_G['CriteriaAlertFrame'..i..'IconTexture']:SetParent(_G['CriteriaAlertFrame'..i..'IconTexture'].b)
				end
				_G['CriteriaAlertFrame'..i..'IconTexture']:SetTexCoord(unpack(E.TexCoords))
			end	
		end
	end)
	
	hooksecurefunc('AlertFrame_SetLootWonAnchors', function()
		for i=1, #LOOT_WON_ALERT_FRAMES do
			local frame = LOOT_WON_ALERT_FRAMES[i];
			if frame then
				frame:SetAlpha(1)
				if not frame.hooked then hooksecurefunc(frame, "SetAlpha", forceAlpha);frame.hooked = true end
				
				frame.Background:Kill()
				frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				frame.IconBorder:Kill()
				frame.glow:Kill()
				frame.shine:Kill()
				if frame.SpecRing and (not frame.SpecIcon) then frame.SpecRing:Kill() end
				
				-- Icon border
				if not frame.Icon.b then
					frame.Icon.b = CreateFrame("Frame", nil, frame)
					frame.Icon.b:SetTemplate("Default")
					frame.Icon.b:SetOutside(frame.Icon)
					frame.Icon:SetParent(frame.Icon.b)
				end
				
				if not frame.backdrop then
					frame:CreateBackdrop("Transparent")
					frame.backdrop:SetPoint('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
					frame.backdrop:SetPoint('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
				end				
			end
		end	
	end)
	
	hooksecurefunc('AlertFrame_SetMoneyWonAnchors', function()
		for i=1, #MONEY_WON_ALERT_FRAMES do
			local frame = MONEY_WON_ALERT_FRAMES[i];
			if frame then
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
					frame.backdrop:SetPoint('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
					frame.backdrop:SetPoint('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
				end				
			end
		end	
	end)
	
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

	frame:CreateBackdrop("Transparent")
	frame.backdrop:SetPoint('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
	frame.backdrop:SetPoint('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
	
	local frame = BonusRollLootWonFrame
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

	frame:CreateBackdrop("Transparent")
	frame.backdrop:SetPoint('TOPLEFT', frame.Icon.b, 'TOPLEFT', -4, 4)
	frame.backdrop:SetPoint('BOTTOMRIGHT', frame.Icon.b, 'BOTTOMRIGHT', 180, -4)
	
end

S:RegisterSkin('ElvUI', LoadSkin)