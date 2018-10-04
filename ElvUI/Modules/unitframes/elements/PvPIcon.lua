local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_PvPIcon(frame)
	local PvPIndicator = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK', nil, 1)
	PvPIndicator:SetSize(30, 30)
	PvPIndicator:SetPoint('CENTER', frame, 'CENTER')

	local Badge = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'ARTWORK')
	Badge:SetSize(50, 52)
	Badge:SetPoint('CENTER', PvPIndicator, 'CENTER')

	PvPIndicator.Badge = Badge

	return PvPIndicator
end

function UF:Configure_PVPIcon(frame)
	local PvPIndicator = frame.PvPIndicator
	PvPIndicator:ClearAllPoints()
	PvPIndicator:Point(frame.db.pvpIcon.anchorPoint, frame.Health, frame.db.pvpIcon.anchorPoint, frame.db.pvpIcon.xOffset, frame.db.pvpIcon.yOffset)

	local scale = frame.db.pvpIcon.scale or 1
	PvPIndicator:Size(30 * scale)
	PvPIndicator.Badge:Size(50 * scale, 52 * scale)

	if frame.db.pvpIcon.enable and not frame:IsElementEnabled('PvPIndicator') then
		frame:EnableElement('PvPIndicator')
	elseif not frame.db.pvpIcon.enable and frame:IsElementEnabled('PvPIndicator') then
		frame:DisableElement('PvPIndicator')
	end
end
