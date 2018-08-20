local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select, unpack = select, unpack
--WoW API / Variables
local CLOSE = CLOSE
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.deathRecap ~= true then return end

	local DeathRecapFrame = _G["DeathRecapFrame"]
	DeathRecapFrame:StripTextures()
	S:HandleCloseButton(DeathRecapFrame.CloseXButton)
	DeathRecapFrame:SetTemplate("Transparent")

	for i=1, 5 do
		local iconBorder = DeathRecapFrame["Recap"..i].SpellInfo.IconBorder
		local icon = DeathRecapFrame["Recap"..i].SpellInfo.Icon
		iconBorder:SetAlpha(0)
		icon:SetTexCoord(unpack(E.TexCoords))
		DeathRecapFrame["Recap"..i].SpellInfo:CreateBackdrop("Default")
		DeathRecapFrame["Recap"..i].SpellInfo.backdrop:SetOutside(icon)
		icon:SetParent(DeathRecapFrame["Recap"..i].SpellInfo.backdrop)
	end

	for i=1, DeathRecapFrame:GetNumChildren() do
		local child = select(i, DeathRecapFrame:GetChildren())
		if(child:GetObjectType() == "Button" and child.GetText and child:GetText() == CLOSE) then
			S:HandleButton(child)
		end
	end
end

S:AddCallbackForAddon("Blizzard_DeathRecap", "DeathRecap", LoadSkin)
