local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

function BL:CaptureBarUpdate()
	local numFrames = _G.NUM_EXTENDED_UI_FRAMES
	if not numFrames then return end

	for i=1, numFrames do
		local captureBar = _G['WorldStateCaptureBar' .. i]
		if captureBar and captureBar:IsVisible() then
			captureBar:ClearAllPoints()

			if i == 1 then
				captureBar:Point('TOP', E.UIParent, 'TOP', 0, -150)
			else
				captureBar:Point('TOPLEFT', _G['WorldStateCaptureBar' .. i - 1], 'TOPLEFT', 0, -45)
			end
		end
	end
end

function BL:PositionCaptureBar()
	if _G.ManageFramePositions then
		hooksecurefunc('ManageFramePositions', BL.CaptureBarUpdate)
	elseif _G.UIParent_ManageFramePositions then
		hooksecurefunc('UIParent_ManageFramePositions', BL.CaptureBarUpdate)
	end
end
