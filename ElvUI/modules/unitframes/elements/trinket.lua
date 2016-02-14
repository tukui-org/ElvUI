local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_Trinket(frame)
	local trinket = CreateFrame("Frame", nil, frame)
	trinket.bg = CreateFrame("Frame", nil, trinket)
	trinket.bg:SetTemplate("Default", nil, nil, E.global.tukuiMode)
	trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
	trinket:SetInside(trinket.bg)

	return trinket
end