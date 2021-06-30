local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_OrderHallUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.orderhall) then return end

	local classColor = E:ClassColor(E.myclass, true)

	-- CommandBar
	local OrderHallCommandBar = _G.OrderHallCommandBar
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:SetTemplate('Transparent')
	OrderHallCommandBar.ClassIcon:SetTexture([[Interface\TargetingFrame\UI-Classes-Circles]])
	OrderHallCommandBar.ClassIcon:Size(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas('legionmission-icon-currency', false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	local OrderHallTalentFrame = _G.OrderHallTalentFrame
	S:HandlePortraitFrame(OrderHallTalentFrame)
	S:HandleButton(OrderHallTalentFrame.BackButton)
	S:HandleIcon(OrderHallTalentFrame.Currency.Icon, true)
	OrderHallTalentFrame.OverlayElements:SetAlpha(0)

	hooksecurefunc(OrderHallTalentFrame, 'RefreshAllData', function(frame)
		if frame.CloseButton.Border then frame.CloseButton.Border:SetAlpha(0) end
		if frame.CurrencyBG then frame.CurrencyBG:SetAlpha(0) end

		frame:StripTextures()
		frame:SetTemplate('Transparent')

		if frame.buttonPool then
			for bu in frame.buttonPool:EnumerateActive() do
				if bu.talent then
					bu:SetTemplate()

					bu.Border:SetAlpha(0)
					bu.Highlight:SetColorTexture(1, 1, 1, .25)
					bu.Icon:SetTexCoord(unpack(E.TexCoords))
					bu.Icon:SetInside()

					if bu.talent.isBeingResearched then
						bu:SetBackdropBorderColor(0, 1, 0)
					elseif bu.talent.researched or bu.talent.selected then
						bu:SetBackdropBorderColor(1, 0.8, 0)
					else
						bu:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI')
