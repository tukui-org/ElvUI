local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local _G = _G
-- WoW API
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true or E.private.skins.blizzard.garrison ~= true then return end

	hooksecurefunc(_G["GarrisonFollowerTabMixin"], "ShowFollower", function(self, followerID, followerList)
		local followerInfo = C_Garrison_GetFollowerInfo(followerID)
		if not followerInfo then return end

		if not self.PortraitFrame.styled then
			S:HandleGarrisonPortrait(self.PortraitFrame)

			self.PortraitFrame.styled = true
		end

		local color = ITEM_QUALITY_COLORS[followerInfo.quality]
		self.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		self.Name:SetVertexColor(color.r, color.g, color.b)

		self.XPBar:ClearAllPoints()
		self.XPBar:SetPoint("BOTTOMLEFT", self.PortraitFrame, "BOTTOMRIGHT", 7, -15)
	end)
end

S:AddCallbackForAddon("Blizzard_GarrisonTemplates", "GarrisonTemplate", LoadSkin)