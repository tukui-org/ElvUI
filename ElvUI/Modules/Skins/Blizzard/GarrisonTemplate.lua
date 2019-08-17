local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or (E.private.skins.blizzard.orderhall ~= true or E.private.skins.blizzard.garrison ~= true) then return end

	hooksecurefunc(_G.GarrisonFollowerTabMixin, "ShowFollower", function(self, followerID)
		local followerInfo = followerID and C_Garrison_GetFollowerInfo(followerID)
		if not followerInfo then return end

		if not self.PortraitFrameStyled then
			S:HandleGarrisonPortrait(self.PortraitFrame)
			self.PortraitFrameStyled = true
		end

		local color = followerInfo.quality and ITEM_QUALITY_COLORS[followerInfo.quality]
		if color then
			if self.PortraitFrame.backdrop then
				self.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			self.Name:SetVertexColor(color.r, color.g, color.b)
		end

		self.XPBar:ClearAllPoints()
		self.XPBar:Point("BOTTOMLEFT", self.PortraitFrame, "BOTTOMRIGHT", 7, -15)
	end)
end

S:AddCallbackForAddon("Blizzard_GarrisonTemplates", "GarrisonTemplate", LoadSkin)
