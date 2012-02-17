local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

local AchievementHolder = CreateFrame("Frame", "AchievementHolder", E.UIParent)
AchievementHolder:SetWidth(180)
AchievementHolder:SetHeight(20)
AchievementHolder:SetPoint("TOP", E.UIParent, "TOP", 0, -170)

local POSITION = "TOP"

function B:AchievementMove()
	local previousFrame
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		local aFrame = _G["AchievementAlertFrame"..i]
		if ( aFrame ) then
			aFrame:ClearAllPoints()
			if POSITION == "TOP" then
				if ( previousFrame and previousFrame:IsShown() ) then
					aFrame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -10)
				else
					aFrame:SetPoint("TOP", AchievementHolder, "BOTTOM")
				end
			else
				if ( previousFrame and previousFrame:IsShown() ) then
					aFrame:SetPoint("BOTTOM", previousFrame, "TOP", 0, 10)
				else
					aFrame:SetPoint("BOTTOM", AchievementHolder, "TOP")	
				end			
			end
			
			previousFrame = aFrame
		end
	end
	
end

local initialize = 0
local function PostAchievementMove(frame, pos)
	initialize = initialize + 1
	if ( not AchievementFrame ) and initialize > 2 then
		AchievementFrame_LoadUI()
	end
	POSITION = pos	
	if initialize > 2 then
		AchievementAlertFrame_ShowAlert(50)
	end
	
	B:AchievementMove()
end

--/run GuildChallengeAlertFrame_ShowAlert(3, 2, 5)
function B:AchievementMovers()
	hooksecurefunc("AchievementAlertFrame_FixAnchors", B.AchievementMove)
	hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", function()
		for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
			local aFrame = _G["AchievementAlertFrame"..i]
			if ( aFrame and aFrame:IsShown() ) then
				DungeonCompletionAlertFrame1:ClearAllPoints()
				if pos == "TOP" then
					DungeonCompletionAlertFrame1:SetPoint("TOP", aFrame, "BOTTOM", 0, -10)
				else
					DungeonCompletionAlertFrame1:SetPoint("BOTTOM", aFrame, "TOP", 0, 10)
				end
				
				return
			end
			
			DungeonCompletionAlertFrame1:ClearAllPoints()	
			if pos == "TOP" then
				DungeonCompletionAlertFrame1:SetPoint("TOP", AchievementHolder, "BOTTOM")
			else
				DungeonCompletionAlertFrame1:SetPoint("BOTTOM", AchievementHolder, "TOP")
			end
		end
	end)	
	
	hooksecurefunc('GuildChallengeAlertFrame_FixAnchors', function()
		local aFrame
		for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
			if _G["AchievementAlertFrame"..i] and _G["AchievementAlertFrame"..i]:IsShown() then
				aFrame = _G["AchievementAlertFrame"..i]
			end
		end
		
		if DungeonCompletionAlertFrame1:IsShown() then
			aFrame = DungeonCompletionAlertFrame1
		end
		
		if aFrame == nil then
			aFrame = AchievementHolder
		end
		
		GuildChallengeAlertFrame:ClearAllPoints()
		if pos == "TOP" then
			GuildChallengeAlertFrame:SetPoint("TOP", aFrame, "BOTTOM", 0, -10)
		else
			GuildChallengeAlertFrame:SetPoint("BOTTOM", aFrame, "TOP", 0, 10)
		end
	end)
	
	self:RegisterEvent("ACHIEVEMENT_EARNED", 'AchievementMove')
	E:CreateMover(AchievementHolder, "AchievementMover", "Achievement Frames", nil, PostAchievementMove)
end