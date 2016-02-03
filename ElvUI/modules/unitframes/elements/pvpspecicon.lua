local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_PVPSpecIcon(frame)
	local specIcon = CreateFrame("Frame", nil, frame)
	specIcon.bg = CreateFrame("Frame", nil, specIcon)
	specIcon.bg:SetTemplate("Default")
	specIcon.bg:SetFrameLevel(specIcon:GetFrameLevel() - 1)
	specIcon:SetInside(specIcon.bg)

	return specIcon
end