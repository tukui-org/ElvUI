-- reposition capture bar somewhere else than default Blizzard position.
local function CaptureUpdate()
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local cb = _G["WorldStateCaptureBar"..i]
		if cb and cb:IsShown() then
			cb:ClearAllPoints()
			cb:SetPoint("TOP", UIParent, "TOP", 0, TukuiDB.Scale(-120))
		end
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", CaptureUpdate)