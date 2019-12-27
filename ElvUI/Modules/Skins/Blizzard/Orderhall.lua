local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select = select
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function colorBorder(child, backdrop, atlas)
	if child.AlphaIconOverlay:IsShown() then --isBeingResearched or (talentAvailability and not selected)
		local alpha = child.AlphaIconOverlay:GetAlpha()
		if alpha <= 0.5 then --talentAvailability
			backdrop:SetBackdropBorderColor(0.5, 0.5, 0.5) --[border = grey, shadow x2]
			child.darkOverlay:SetColorTexture(0, 0, 0, 0.50)
			child.darkOverlay:Show()
		elseif alpha <= 0.7 then --isBeingResearched
			backdrop:SetBackdropBorderColor(0,1,1) --[border = teal, shadow x1]
			child.darkOverlay:SetColorTexture(0, 0, 0, 0.25)
			child.darkOverlay:Show()
		end
	elseif atlas == "orderhalltalents-spellborder-green" then
		backdrop:SetBackdropBorderColor(0,1,0) --[border = green, no shadow]
		child.darkOverlay:Hide()
	elseif atlas == "orderhalltalents-spellborder-yellow" then
		backdrop:SetBackdropBorderColor(1,1,0) --[border = yellow, no shadow]
		child.darkOverlay:Hide()
	elseif atlas == "orderhalltalents-spellborder" then
		backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		child.darkOverlay:SetColorTexture(0, 0, 0, 0.75) --[border will be default, shadow x3]
		child.darkOverlay:Show()
	end
end

function S:SkinOrderHall()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

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

	-- Talent Frame
	_G.OrderHallTalentFrame:HookScript("OnShow", function(s)
		if s.StyleFrame and s.StyleFrame.Background and s.StyleFrame.Background.GetTexture and s.StyleFrame.Background:GetTexture() then
			s.StyleFrame:SetFrameLevel(1)

			for i = 1, s.StyleFrame:GetNumRegions() do
				local region = select(i, s.StyleFrame:GetRegions())
				if region and region:IsObjectType('Texture') then
					if region == s.StyleFrame.Background then
						region:SetAllPoints()
						region:SetDrawLayer("ARTWORK", 1)
						region:SetAlpha(0.8)
					else
						region:Hide()
					end
				end
			end
		elseif s.Background then
			s.Background:SetDrawLayer("ARTWORK")
			s.Background:SetAlpha(0.8)
		end

		if s.NineSlice then s.NineSlice:Hide() end
		if s.OverlayElements then s.OverlayElements:Hide() end
		if s.CloseButton.Border then s.CloseButton.Border:Hide() end
		if s.CurrencyBG then s.CurrencyBG:Hide() end
		if s.PortraitFrame then s.PortraitFrame:Hide() end
		if s.portrait then s.portrait:Hide() end
		if s.skinned then return end

		if s.Currency.Icon then s.Currency.Icon:SetTexCoord(unpack(E.TexCoords)) end

		for i=1, s:GetNumRegions() do
			local region = select(i, s:GetRegions())
			if region and region:IsObjectType('Texture') then
				if not ((region == s.Background) or (s.Currency and s.Currency.Icon and region == s.Currency.Icon)) then
					region:SetTexture()
				end
			end
		end

		s:SetTemplate("Transparent")
		S:HandleCloseButton(s.CloseButton)
		S:HandleButton(s.BackButton)

		if s.LeftInset then
			s.LeftInset:StripTextures()

			if s.Background and not s.LeftInset.backdrop then
				s.LeftInset:CreateBackdrop("Transparent")
				s.LeftInset.backdrop:SetFrameLevel(s.LeftInset.backdrop:GetFrameLevel()+1)
			end

			s.LeftInset.backdrop:Point('TOPLEFT', s.Background, 'TOPLEFT', E.Border-1, -E.Border+1)
			s.LeftInset.backdrop:Point('BOTTOMRIGHT', s.Background, 'BOTTOMRIGHT', -E.Border+1, E.Border-1)
		end

		for i = 1, s:GetNumChildren() do
			local child = select(i, s:GetChildren())
			if child and child.Icon and child.DoneGlow and not child.backdrop then
				child:StyleButton()
				child:CreateBackdrop()
				child.Border:SetAlpha(0)
				child.Highlight:SetAlpha(0)
				child.AlphaIconOverlay:SetTexture()
				child.Icon:SetTexCoord(unpack(E.TexCoords))
				child.Icon:SetInside(child.backdrop)
				child.hover:SetInside(child.backdrop)
				child.pushed:SetInside(child.backdrop)
				child.backdrop:SetFrameLevel(child.backdrop:GetFrameLevel()+1)

				child.darkOverlay = child:CreateTexture()
				child.darkOverlay:SetAllPoints(child.Icon)
				child.darkOverlay:SetDrawLayer('OVERLAY')
				child.darkOverlay:Hide()

				colorBorder(child, child.backdrop, child.Border:GetAtlas())

				child.TalentDoneAnim:HookScript("OnFinished", function()
					child.Border:SetAlpha(0) -- clear the yellow glow border again, after it finishes the animation
				end)
			end
		end

		s.choiceTexturePool:ReleaseAll()

		hooksecurefunc(s, "RefreshAllData", function(frame)
			frame.choiceTexturePool:ReleaseAll()

			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child and child.Icon and child.backdrop then
					colorBorder(child, child.backdrop, child.Border:GetAtlas())
				end
			end
		end)

		s.skinned = true
	end)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI', 'SkinOrderHall')
