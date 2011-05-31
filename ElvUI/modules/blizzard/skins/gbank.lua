local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].gbank ~= true then return end

local function LoadSkin()
	GuildBankFrame:StripTextures()
	GuildBankFrame:SetTemplate("Transparent")
	GuildBankEmblemFrame:StripTextures(true)
	
	--Close button doesn't have a fucking name, extreme hackage
	for i=1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			E.SkinCloseButton(child)
		end
	end
	
	E.SkinButton(GuildBankFrameDepositButton, true)
	E.SkinButton(GuildBankFrameWithdrawButton, true)
	E.SkinButton(GuildBankInfoSaveButton, true)
	E.SkinButton(GuildBankFramePurchaseButton, true)
	
	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)

	GuildBankInfoScrollFrame:StripTextures()
	GuildBankTransactionsScrollFrame:StripTextures()
	
	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 30, -65)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -20, 63)
	
	for i=1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:StripTextures()
		
		for x=1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]
			local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate("Default", true)
			
			icon:ClearAllPoints()
			icon:Point("TOPLEFT", 2, -2)
			icon:Point("BOTTOMRIGHT", -2, 2)
			icon:SetTexCoord(.08, .92, .08, .92)
		end
	end
	
	for i=1, 8 do
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]
		_G["GuildBankTab"..i]:StripTextures(true)
		
		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate("Default", true)
		
		texture:ClearAllPoints()
		texture:Point("TOPLEFT", 2, -2)
		texture:Point("BOTTOMRIGHT", -2, 2)
		texture:SetTexCoord(.08, .92, .08, .92)
	end
	
	for i=1, 4 do
		E.SkinTab(_G["GuildBankFrameTab"..i])
	end
	
	--Popup
	GuildBankPopupFrame:StripTextures()
	GuildBankPopupScrollFrame:StripTextures()
	GuildBankPopupFrame:SetTemplate("Transparent")
	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 1, -30)
	E.SkinButton(GuildBankPopupOkayButton)
	E.SkinButton(GuildBankPopupCancelButton)
	E.SkinEditBox(GuildBankPopupEditBox)
	GuildBankPopupNameLeft:Kill()
	GuildBankPopupNameRight:Kill()
	GuildBankPopupNameMiddle:Kill()
	
	for i=1, 16 do
		local button = _G["GuildBankPopupButton"..i]
		local icon = _G[button:GetName().."Icon"]
		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton(true)
		icon:ClearAllPoints()
		icon:Point("TOPLEFT", 2, -2)
		icon:Point("BOTTOMRIGHT", -2, 2)
		icon:SetTexCoord(.08, .92, .08, .92)
	end
end

E.SkinFuncs["Blizzard_GuildBankUI"] = LoadSkin