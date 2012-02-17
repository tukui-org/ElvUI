local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.achievement_popup ~= true then return end
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
	hooksecurefunc("AchievementAlertFrame_FixAnchors", SkinAchievePopUp)
	
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
				
				-- Background
				for i=1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions())
					if region:GetObjectType() == "Texture" then
						if region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST" then
							region:Kill()
						end
					end
				end
				
				_G["DungeonCompletionAlertFrame"..i.."Shine"]:Kill()
				_G["DungeonCompletionAlertFrame"..i.."GlowFrame"]:Kill()
				_G["DungeonCompletionAlertFrame"..i.."GlowFrame"].glow:Kill()
				
				-- Icon
				_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				
				_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:ClearAllPoints()
				_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:Point("LEFT", frame, 7, 0)
				
				if not _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b then
					_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b = CreateFrame("Frame", nil, _G["DungeonCompletionAlertFrame"..i])
					_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:SetFrameLevel(0)
					_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:SetTemplate("Default")
					_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:Point("TOPLEFT", _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"], "TOPLEFT", -2, 2)
					_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:Point("BOTTOMRIGHT", _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"], "BOTTOMRIGHT", 2, -2)
				end
			end
		end				
	end
	
	hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", SkinDungeonPopUP)
	
	
	--Guild Alert
	for i=1, GuildChallengeAlertFrame:GetNumRegions() do
		local region = select(i, GuildChallengeAlertFrame:GetRegions()) 
		if region and region:GetObjectType() == "Texture" and not region:GetName() then
			region:SetTexture(nil)
		end
	end
	
	GuildChallengeAlertFrame:SetTemplate('Default', true)
	GuildChallengeAlertFrame.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	GuildChallengeAlertFrame.backdropTexture.SetVertexColor = E.noop
	GuildChallengeAlertFrame:Height(65)
end

S:RegisterSkin('ElvUI', LoadSkin)