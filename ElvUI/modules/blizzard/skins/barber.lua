local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].barber ~= true then return end

local function LoadSkin()
	local buttons = {
		"BarberShopFrameOkayButton",
		"BarberShopFrameCancelButton",
		"BarberShopFrameResetButton",
	}
	BarberShopFrameOkayButton:Point("RIGHT", BarberShopFrameSelector4, "BOTTOM", 2, -50)
	
	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		E.SkinButton(_G[buttons[i]])
	end
	

	for i = 1, 4 do
		local f = _G["BarberShopFrameSelector"..i]
		local f2 = _G["BarberShopFrameSelector"..i-1]
		E.SkinNextPrevButton(_G["BarberShopFrameSelector"..i.."Prev"])
		E.SkinNextPrevButton(_G["BarberShopFrameSelector"..i.."Next"])
		
		if i ~= 1 then
			f:ClearAllPoints()
			f:Point("TOP", f2, "BOTTOM", 0, -3)			
		end
		
		if f then
			f:StripTextures()
		end
	end
	
	BarberShopFrameSelector1:ClearAllPoints()
	BarberShopFrameSelector1:Point("TOP", 0, -12)
	
	BarberShopFrameResetButton:ClearAllPoints()
	BarberShopFrameResetButton:Point("BOTTOM", 0, 12)

	BarberShopFrame:StripTextures()
	BarberShopFrame:SetTemplate("Transparent")
	BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)
	
	BarberShopFrameMoneyFrame:StripTextures()
	BarberShopFrameMoneyFrame:CreateBackdrop()
	BarberShopFrameBackground:Kill()
	
	BarberShopBannerFrameBGTexture:Kill()
	BarberShopBannerFrame:Kill()
	
	BarberShopAltFormFrameBorder:StripTextures()
	BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
	BarberShopAltFormFrame:StripTextures()
	BarberShopAltFormFrame:CreateBackdrop("Transparent")
end

E.SkinFuncs["Blizzard_BarbershopUI"] = LoadSkin