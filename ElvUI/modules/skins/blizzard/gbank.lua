local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local unpack = unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.gbank ~= true then return end
	GuildBankFrame:StripTextures()
	GuildBankFrame:SetTemplate("Transparent")
	GuildBankEmblemFrame:StripTextures(true)
	GuildBankMoneyFrameBackground:Kill()
	S:HandleScrollBar(GuildBankPopupScrollFrameScrollBar)

	--Close button doesn't have a fucking name, extreme hackage
	for i=1, GuildBankFrame:GetNumChildren() do
		local child = select(i, GuildBankFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	S:HandleButton(GuildBankFrameDepositButton, true)
	S:HandleButton(GuildBankFrameWithdrawButton, true)
	S:HandleButton(GuildBankInfoSaveButton, true)
	S:HandleButton(GuildBankFramePurchaseButton, true)

	GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)
	GuildBankInfoScrollFrame:Point('TOPLEFT', GuildBankInfo, 'TOPLEFT', -10, 12)
	GuildBankInfoScrollFrame:StripTextures()
	GuildBankInfoScrollFrame:Width(GuildBankInfoScrollFrame:GetWidth() - 8)
	GuildBankTransactionsScrollFrame:StripTextures()

	GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
	GuildBankFrame.inset:SetTemplate("Default")
	GuildBankFrame.inset:Point("TOPLEFT", 20, -58)
	GuildBankFrame.inset:Point("BOTTOMRIGHT", -16, 60)

	for i=1, NUM_GUILDBANK_COLUMNS do
		_G["GuildBankColumn"..i]:StripTextures()

		for x=1, NUM_SLOTS_PER_GUILDBANK_GROUP do
			local button = _G["GuildBankColumn"..i.."Button"..x]
			local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
			local texture = _G["GuildBankColumn"..i.."Button"..x.."NormalTexture"]
			if texture then
				texture:SetTexture(nil)
			end
			button:StyleButton()
			button:SetTemplate("Default", true)

			button.IconBorder:SetTexture(nil)
			hooksecurefunc(button.IconBorder,'SetVertexColor',function(self,r,g,b,a)
				button:SetBackdropBorderColor(r,g,b,a)
			end)
			hooksecurefunc(button.IconBorder,'Hide',function()
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	for i=1, MAX_GUILDBANK_TABS do
		local button = _G["GuildBankTab"..i.."Button"]
		local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]
		_G["GuildBankTab"..i]:StripTextures(true)

		button:StripTextures()
		button:StyleButton(true)
		button:SetTemplate("Default", true)

		texture:SetInside()
		texture:SetTexCoord(unpack(E.TexCoords))
	end

	for i=1, 4 do
		S:HandleTab(_G["GuildBankFrameTab"..i])
	end

	--Popup
	GuildBankPopupFrame:StripTextures()
	GuildBankPopupScrollFrame:StripTextures()
	GuildBankPopupFrame:SetTemplate("Transparent")
	GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 1, -30)
	S:HandleButton(GuildBankPopupOkayButton)
	S:HandleButton(GuildBankPopupCancelButton)
	S:HandleEditBox(GuildBankPopupEditBox)
	GuildBankPopupNameLeft:Kill()
	GuildBankPopupNameRight:Kill()
	GuildBankPopupNameMiddle:Kill()

	GuildItemSearchBox.Left:Kill()
	GuildItemSearchBox.Middle:Kill()
	GuildItemSearchBox.Right:Kill()
	GuildItemSearchBox.searchIcon:Kill()
	GuildItemSearchBox:CreateBackdrop("Overlay")
	GuildItemSearchBox.backdrop:Point("TOPLEFT", 10, -1)
	GuildItemSearchBox.backdrop:Point("BOTTOMRIGHT", -1, 1)

	for i=1, NUM_GUILDBANK_ICONS_SHOWN do
		local button = _G["GuildBankPopupButton"..i]
		local icon = _G[button:GetName().."Icon"]
		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton(true)
		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))
	end

	S:HandleScrollBar(GuildBankTransactionsScrollFrameScrollBar)
	S:HandleScrollBar(GuildBankInfoScrollFrameScrollBar)
end

S:RegisterSkin("Blizzard_GuildBankUI", LoadSkin)