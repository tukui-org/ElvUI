local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AzeriteUI ~= true then return end

	AzeriteEmpoweredItemUI:StripTextures()
	AzeriteEmpoweredItemUI.BorderFrame:StripTextures()
	AzeriteEmpoweredItemUIPortrait:Hide()
	AzeriteEmpoweredItemUIPortraitFrame:Hide()

	S:HandleCloseButton(AzeriteEmpoweredItemUICloseButton)

	local function AdjustSizeForTiers(self, numTiers)
		self.BackgroundFrame:SetPoint("TOPLEFT", 4, 0)
		if numTiers == 3 then
			self:SetSize(474, 468)
		else
			self:SetSize(615, 612)
		end
	end

	function S:AzeriteEmpoweredItemUIFrame(frame)
		hooksecurefunc(frame, "AdjustSizeForTiers", AdjustSizeForTiers)

		frame:SetClipsChildren(true)

		frame.BackgroundFrame.KeyOverlay.Shadow:ClearAllPoints()
		frame.BackgroundFrame.KeyOverlay.Shadow:SetPoint("TOPLEFT", -5, 0)
		frame.BackgroundFrame.KeyOverlay.Shadow:SetPoint("BOTTOMRIGHT", frame.BackgroundFrame.KeyOverlay, "TOPRIGHT", 5, -40)
	end
	S:AzeriteEmpoweredItemUIFrame(AzeriteEmpoweredItemUI)
end

S:AddCallbackForAddon("Blizzard_AzeriteUI", "AzeriteUI", LoadSkin)