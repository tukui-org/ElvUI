local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local select = select
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CUSTOM_CLASS_COLORS, OrderHallCommandBar, OrderHallMissionFrame, ClassHallTalentInset
-- GLOBALS: OrderHallTalentFrame, OrderHallTalentFramePortrait, OrderHallTalentFramePortraitFrame


local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

	-- CommandBar
	local OrderHallCommandBar = _G["OrderHallCommandBar"]
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:CreateBackdrop("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	-- Talent Frame
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

	OrderHallTalentFrame:HookScript("OnShow", function(self)
		if self.Currency and self.Currency.Icon and self.Currency.Icon.GetAtlas then
			local currencyIconAtlas = self.Currency.Icon:GetAtlas()
			if currencyIconAtlas and (currencyIconAtlas ~= self.currencyIconAtlas) then
				self.currencyIconAtlas = currencyIconAtlas
			end
			if self.currencyIconAtlas then
				self.Currency.Icon:SetAtlas(self.currencyIconAtlas, false)
			end
		end

		local StyleFrameBackground = self.StyleFrame and self.StyleFrame.Background and self.StyleFrame.Background.GetTexture and self.StyleFrame.Background:GetTexture()
		local TalentFrameBackground = self.Background and self.Background.GetTexture and self.Background:GetTexture()
		local TalentBackgroundTexture = StyleFrameBackground or TalentFrameBackground
		local TalentBackground = (StyleFrameBackground and self.StyleFrame.Background) or (TalentFrameBackground and self.Background)
		if TalentBackground and TalentBackgroundTexture and (TalentBackgroundTexture ~= self.backgroundTexture) then
			self.backgroundTexture = TalentBackgroundTexture
		end

		local TalentInset = self.LeftInset
		if TalentInset then
			TalentInset:StripTextures()
			if TalentBackground and not TalentInset.backdrop then
				TalentInset:CreateBackdrop("Transparent")
				TalentInset.backdrop:SetFrameLevel(TalentInset.backdrop:GetFrameLevel()+1)
			end

			TalentInset.backdrop:Point('TOPLEFT', TalentBackground, 'TOPLEFT', E.Border-1, -E.Border+1)
			TalentInset.backdrop:Point('BOTTOMRIGHT', TalentBackground, 'BOTTOMRIGHT', -E.Border+1, E.Border-1)
		end
		if TalentBackground then
			TalentBackground:SetDrawLayer("ARTWORK")
			TalentBackground:SetAlpha(0.8)
		end

		if self.StyleFrame then self.StyleFrame:SetAlpha(0) end
		if self.PortraitFrame then self.PortraitFrame:Hide() end
		if self.CornerLogo then self.CornerLogo:Hide() end
		if self.portrait then self.portrait:Hide() end
		if self.skinned then return end

		self:StripTextures()
		self:SetTemplate("Transparent")

		S:HandleCloseButton(self.CloseButton)
		S:HandleButton(self.BackButton)

		if TalentBackground and self.backgroundTexture then
			TalentBackground:SetTexture(self.backgroundTexture)
		end

		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			if child and child.Icon and child.DoneGlow and not child.backdrop then
				child:StyleButton()
				child:CreateBackdrop()
				child.Border:SetAlpha(0)
				child.Highlight:SetAlpha(0)
				child.AlphaIconOverlay:SetTexture(nil)
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

		self.choiceTexturePool:ReleaseAll()

		hooksecurefunc(self, "RefreshAllData", function(frame)
			frame.choiceTexturePool:ReleaseAll()
			for i = 1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child and child.Icon and child.backdrop then
					colorBorder(child, child.backdrop, child.Border:GetAtlas())
				end
			end
		end)

		self.skinned = true
	end)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI', "OrderHall", LoadSkin)
