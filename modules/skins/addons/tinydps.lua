local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')


local function LoadSkin()
	if E.db.skins.tinydps.enable ~= true then return end

	local frame = tdpsFrame
	local anchor = tdpsAnchor
	local status = tdpsStatusBar
	local font = tdpsFont
	
	if tdps then
		font.name = "Interface\\Addons\\ElvUI\\media\\fonts\\PT_Sans_Narrow.ttf"
		font.height = 10
		font.outline = "Shadow"
	end
	
	frame:SetTemplate("Default")
	frame:CreateShadow("Default")
	
	if status then
		status:SetBackdrop({bgFile = E["media"].normTex, edgeFile = E["media"].blank, tile = false, tileSize = 0, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0}})
		status:SetStatusBarTexture(E["media"].normTex)
	end
end

S:RegisterSkin('TinyDPS', LoadSkin)