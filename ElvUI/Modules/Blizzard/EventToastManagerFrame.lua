local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local Holder
local function Reanchor(frame, _, anchor)
	if anchor and (anchor ~= Holder) then
		frame:ClearAllPoints()
		frame:Point('TOP', Holder)
	end
end

function B:Handle_EventToastManagerFrame()
	if not Holder then
		Holder = CreateFrame('Frame', 'EventToastManagerFrameHolder', E.UIParent)
		Holder:Size(200, 20)
		Holder:Point('TOP', E.UIParent, 'TOP', 0, -120)
	end

	E:CreateMover(Holder, 'EventToastManagerFrameMover', L["Event Toast Manager Frame"])

	_G.EventToastManagerFrame:ClearAllPoints()
	_G.EventToastManagerFrame:Point('TOP', Holder)
	hooksecurefunc(_G.EventToastManagerFrame, 'SetPoint', Reanchor)
end
