local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetPosition(frame, _, anchor)
	if anchor and (anchor == _G.UIParent) then
		frame:ClearAllPoints()
		frame:Point("TOPLEFT", _G.GMMover, 0, 0)
	end
end

function B:PositionGMFrames()
	local TicketStatusFrame = _G.TicketStatusFrame

	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:Point("TOPLEFT", E.UIParent, 'TOPLEFT', 250, -5)
	E:CreateMover(TicketStatusFrame, "GMMover", L["GM Ticket Frame"])

	--Blizzard repositions this frame now in UIParent_UpdateTopFramePositions
	hooksecurefunc(TicketStatusFrame, "SetPoint", SetPosition)

	_G.HelpOpenTicketButton:SetParent(_G.Minimap)
	_G.HelpOpenWebTicketButton:SetParent(_G.Minimap)
end
