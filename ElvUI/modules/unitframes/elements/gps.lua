local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_GPS(frame)
	local gps = CreateFrame("Frame", nil, frame)
	gps:SetFrameLevel(frame:GetFrameLevel() + 50)
	gps:Hide()

	gps.Texture = gps:CreateTexture("OVERLAY")
	gps.Texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrow.tga]])
	gps.Texture:SetBlendMode("BLEND")
	gps.Texture:SetVertexColor(214/255, 41/255, 41/255)
	gps.Texture:SetAllPoints()

	return gps
end