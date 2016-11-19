local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_PvPIcon(frame)
	local PvP = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK', nil, 1)
	PvP:SetSize(30, 30)
	PvP:SetPoint('CENTER', frame, 'CENTER')

	local Prestige = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK')
	Prestige:SetSize(50, 52)
	Prestige:SetPoint('CENTER', PvP, 'CENTER')

	PvP.Prestige = Prestige

	return PvP
end

function UF:Configure_PVPIcon(frame)
	local PvP = frame.PvP
	PvP:ClearAllPoints()
	PvP:Point(frame.db.pvpIcon.anchorPoint, frame.Health, frame.db.pvpIcon.anchorPoint, frame.db.pvpIcon.xOffset, frame.db.pvpIcon.yOffset)

	local scale = frame.db.pvpIcon.scale or 1
	PvP:Size(30 * scale)
	PvP.Prestige:Size(50 * scale, 52 * scale)
	
	if frame.db.pvpIcon.enable and not frame:IsElementEnabled('PvP') then
		frame:EnableElement('PvP')
	elseif not frame.db.pvpIcon.enable and frame:IsElementEnabled('PvP') then
		frame:DisableElement('PvP')
	end
end