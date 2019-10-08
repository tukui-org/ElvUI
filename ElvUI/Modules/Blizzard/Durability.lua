local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

--Lua functions
local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local function SetPosition(frame, _, parent)
	if parent ~= _G.DurabilityFrameHolder then
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", _G.DurabilityFrameHolder, "CENTER")
	end
end

function B:PositionDurabilityFrame()
	local DurabilityFrame = _G.DurabilityFrame

	local Scale = E.db.general.durabilityScale or 1

	local DurabilityFrameHolder = CreateFrame("Frame", "DurabilityFrameHolder", E.UIParent)
	DurabilityFrameHolder:Size(DurabilityFrame:GetSize())
	DurabilityFrameHolder:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -135, -300)

	E:CreateMover(DurabilityFrameHolder, 'DurabilityFrameMover', L["Durability Frame"], nil, nil, nil, nil, nil, 'all,general')

	DurabilityFrame:SetFrameStrata("HIGH")
	DurabilityFrame:SetScale(Scale)

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end
