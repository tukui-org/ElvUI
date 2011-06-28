--Reposition achievement frames
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local AchievementHolder = CreateFrame("Frame", "AchievementHolder", E.UIParent)
AchievementHolder:SetWidth(180)
AchievementHolder:SetHeight(20)
AchievementHolder:SetPoint("CENTER", E.UIParent, "CENTER", 0, 170)

local pos = "TOP"

function E.AchievementMove(self, event, ...)
	local previousFrame
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		local aFrame = _G["AchievementAlertFrame"..i]
		if ( aFrame ) then
			aFrame:ClearAllPoints()
			if pos == "TOP" then
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
hooksecurefunc("AchievementAlertFrame_FixAnchors", E.AchievementMove)

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

local initialize = false
function E.PostAchievementMove(frame)
	local point = select(1, frame:GetPoint())
	if ( not AchievementFrame ) and initialize == true then
		AchievementFrame_LoadUI()
	end
	
	if string.find(point, "TOP") or point == "CENTER" or point == "LEFT" or point == "RIGHT" then
		pos = "TOP"
	else
		pos = "BOTTOM"
	end
	
	if initialize == true then
		AchievementAlertFrame_ShowAlert(50)
	end
	
	E.AchievementMove()
	initialize = true
end

E.CreateMover(AchievementHolder, "AchievementMover", "Achievement Frames", nil, E.PostAchievementMove)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", function(self, event, ...) E.AchievementMove(self, event, ...) end)