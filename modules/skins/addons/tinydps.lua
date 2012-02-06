local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')


local function LoadSkin()
	if E.db.skins.tinydps.enable ~= true then return end
	
	local frame = tdpsFrame
	
	frame:SetTemplate("Default")
end

S:RegisterSkin('TinyDPS', LoadSkin)