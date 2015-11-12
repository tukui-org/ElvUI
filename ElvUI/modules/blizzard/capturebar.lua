local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--Cache global variables
local _G = _G

local function CaptureUpdate()
	if NUM_EXTENDED_UI_FRAMES then
		local captureBar
		for i=1, NUM_EXTENDED_UI_FRAMES do
			captureBar = _G["WorldStateCaptureBar" .. i]

			if captureBar and captureBar:IsVisible() then
				captureBar:ClearAllPoints()

				if( i == 1 ) then
					captureBar:Point("TOP", E.UIParent, "TOP", 0, -170)
				else
					captureBar:Point("TOPLEFT", _G["WorldStateCaptureBar" .. i - 1], "TOPLEFT", 0, -45)
				end
			end
		end
	end
end

function B:PositionCaptureBar()
	hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)
end