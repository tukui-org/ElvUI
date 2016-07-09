local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: IsAddOnLoaded, CreateFrame, TalkingHeadFrame, UIPARENT_MANAGED_FRAME_POSITIONS

function B:PositionTalkingHead()
	local function CreateMover()
		TalkingHeadFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil
		
		TalkingHeadFrame:ClearAllPoints()
		TalkingHeadFrame:SetPoint("BOTTOM", 0, 160)

		E:CreateMover(TalkingHeadFrame, "TalkingHeadFrameMover", "Talking Head Frame")
	end

	if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		CreateMover()
	else
		local f = CreateFrame("Frame")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			TalkingHead_LoadUI();
			CreateMover()
			self:UnregisterEvent(event)
		end)
	end
end