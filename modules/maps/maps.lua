local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local M = E:NewModule('Maps', 'AceHook-3.0', 'AceEvent-3.0');

E.Maps = M

function M:Initialize()
	self:LoadMinimap()
end

E:RegisterModule(M:GetName())