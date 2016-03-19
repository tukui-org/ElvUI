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

function UF:Configure_GPS(frame)
	local GPS = frame.GPS
	if frame.db.GPSArrow.enable then
		if not frame:IsElementEnabled('GPS') then
			frame:EnableElement('GPS')
		end

		GPS:Size(frame.db.GPSArrow.size)
		GPS.onMouseOver = frame.db.GPSArrow.onMouseOver
		GPS.outOfRange = frame.db.GPSArrow.outOfRange

		GPS:Point("CENTER", frame, "CENTER", frame.db.GPSArrow.xOffset, frame.db.GPSArrow.yOffset)
	else
		if frame:IsElementEnabled('GPS') then
			frame:DisableElement('GPS')
		end
	end
end