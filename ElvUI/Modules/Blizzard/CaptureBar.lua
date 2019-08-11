local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function CaptureUpdate()
	if _G.NUM_EXTENDED_UI_FRAMES then
		local captureBar
		for i=1, _G.NUM_EXTENDED_UI_FRAMES do
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
