local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:GetModule('Skins')


local function LoadSkin()
	if E.private.skins.tinydps.enable ~= true then return end
	
	local frame = tdpsFrame
	
	frame:SetTemplate("Default")
end

S:RegisterSkin('TinyDPS', LoadSkin)