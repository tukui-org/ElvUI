local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LevelUpDisplay, BossBanner, hooksecurefunc

local Holder = CreateFrame("Frame", "LevelUpBossBannerHolder", E.UIParent)
Holder:SetSize(200, 20)
Holder:SetPoint("TOP", E.UIParent, "TOP", 0, -120)

function B:Handle_LevelUpDisplay_BossBanner()
	E:CreateMover(Holder, "LevelUpBossBannerMover", L["Level Up Display / Boss Banner"])

	local function Reanchor(frame, _, anchor)
		if anchor ~= Holder then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", Holder)
		end
	end

	--Level Up Display
	LevelUpDisplay:ClearAllPoints()
	LevelUpDisplay:SetPoint("TOP", Holder)
	hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)

	--Boss Banner
	BossBanner:ClearAllPoints()
	BossBanner:SetPoint("TOP", Holder)
	hooksecurefunc(BossBanner, "SetPoint", Reanchor)
end
