local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local select = select
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

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
		if self.StyleFrame and self.StyleFrame.Background and self.StyleFrame.Background.GetTexture and self.StyleFrame.Background:GetTexture() then
			self.StyleFrame:SetFrameLevel(1)

			for i = 1, self.StyleFrame:GetNumRegions() do
				local region = select(i, self.StyleFrame:GetRegions())
				if region and region:IsObjectType('Texture') then
					if region == self.StyleFrame.Background then
						region:SetAllPoints()
						region:SetDrawLayer("ARTWORK", 1)
						region:SetAlpha(0.8)
					else
						region:Hide()
					end
				end
			end
		elseif self.Background then
			self.Background:SetDrawLayer("ARTWORK")
			self.Background:SetAlpha(0.8)
		end

		if self.NineSlice then self.NineSlice:Hide() end
		if self.OverlayElements then self.OverlayElements:Hide() end
		if self.CloseButton.Border then self.CloseButton.Border:Hide() end
		if self.CurrencyBG then self.CurrencyBG:Hide() end
		if self.PortraitFrame then self.PortraitFrame:Hide() end
		if self.portrait then self.portrait:Hide() end
		if self.skinned then return end

		if self.Currency.Icon then self.Currency.Icon:SetTexCoord(unpack(E.TexCoords)) end

		for i=1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if region and region:IsObjectType('Texture') then
				if not ((region == self.Background) or (self.Currency and self.Currency.Icon and region == self.Currency.Icon)) then
					region:SetTexture(nil)
				end
			end
		end

		self:SetTemplate("Transparent")
		S:HandleCloseButton(self.CloseButton)
		S:HandleButton(self.BackButton)

		if self.LeftInset then
			self.LeftInset:StripTextures()

			if self.Background and not self.LeftInset.backdrop then
				self.LeftInset:CreateBackdrop("Transparent")
				self.LeftInset.backdrop:SetFrameLevel(self.LeftInset.backdrop:GetFrameLevel()+1)
			end

			self.LeftInset.backdrop:Point('TOPLEFT', self.Background, 'TOPLEFT', E.Border-1, -E.Border+1)
			self.LeftInset.backdrop:Point('BOTTOMRIGHT', self.Background, 'BOTTOMRIGHT', -E.Border+1, E.Border-1)
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
