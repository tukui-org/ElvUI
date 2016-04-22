local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")



function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP

end


E:RegisterModule(NP:GetName())