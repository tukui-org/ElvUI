local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables

function UF:Construct_PvPIndicator(frame)
	local pvp = frame.RaisedElementParent:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(pvp)

	return pvp
end