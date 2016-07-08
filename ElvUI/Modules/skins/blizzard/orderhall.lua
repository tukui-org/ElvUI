local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	-- CommandBar
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:SetTemplate("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetFont(E["media"].normFont, 12, "OUTLINE")
	-- It's a classhall so why not bringing a bit color in it ;)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:ClearAllPoints()
	OrderHallCommandBar.WorldMapButton:SetPoint("RIGHT", OrderHallCommandBar, -5, -2)
end

S:RegisterSkin('Blizzard_OrderHallUI', LoadSkin)
