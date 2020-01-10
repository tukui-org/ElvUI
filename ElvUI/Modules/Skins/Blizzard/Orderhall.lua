local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select = select
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc


function S:Blizzard_OrderHallUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.orderhall) then return end

	local classColor = E:ClassColor(E.myclass, true)

	-- CommandBar
	local OrderHallCommandBar = _G.OrderHallCommandBar
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:CreateBackdrop("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:Size(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	local OrderHallTalentFrame = _G.OrderHallTalentFrame

	S:HandlePortraitFrame(OrderHallTalentFrame, true)
	S:HandleButton(OrderHallTalentFrame.BackButton)
	S:HandleIcon(OrderHallTalentFrame.Currency.Icon)
	OrderHallTalentFrame.OverlayElements:SetAlpha(0)

	hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
		-- We need to hide the objects again after an update is happen.
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
		if self.CurrencyBG then self.CurrencyBG:SetAlpha(0) end
		self:StripTextures()

		for i = 1, self:GetNumChildren() do
			local bu = select(i, self:GetChildren())
			if bu and bu.talent then
				bu.Border:SetAlpha(0)
				bu.Icon:SetTexCoord(unpack(E.TexCoords))

				if not bu.backdrop then
					bu:CreateBackdrop()
					bu.backdrop:SetOutside(bu.Icon)
				end

				bu.Highlight:SetColorTexture(1, 1, 1, .25)

				if bu.talent.selected then
					bu.backdrop:SetBackdropBorderColor(1, 1, 0)
				else
					bu.backdrop:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI')
