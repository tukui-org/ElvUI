local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

function S:Blizzard_GarrisonTemplates()
	if E.private.skins.blizzard.enable ~= true or (E.private.skins.blizzard.orderhall ~= true or E.private.skins.blizzard.garrison ~= true) then return end

	hooksecurefunc(_G.GarrisonFollowerTabMixin, 'ShowFollower', function(s, followerID)
		local followerInfo = followerID and C_Garrison_GetFollowerInfo(followerID)
		if not followerInfo then return end

		if not s.PortraitFrameStyled then
			S:HandleGarrisonPortrait(s.PortraitFrame)
			s.PortraitFrameStyled = true
		end

		local color = followerInfo.quality and ITEM_QUALITY_COLORS[followerInfo.quality]
		if color then
			if s.PortraitFrame.backdrop then
				s.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			s.Name:SetVertexColor(color.r, color.g, color.b)
		end

		s.XPBar:ClearAllPoints()
		s.XPBar:Point('BOTTOMLEFT', s.PortraitFrame, 'BOTTOMRIGHT', 7, -15)
	end)
end

S:AddCallbackForAddon('Blizzard_GarrisonTemplates')
