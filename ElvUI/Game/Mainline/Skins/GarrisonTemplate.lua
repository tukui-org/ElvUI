local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local C_Garrison_GetFollowerInfo = C_Garrison.GetFollowerInfo

function S:Blizzard_GarrisonTemplates()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.orderhall or not E.private.skins.blizzard.garrison then return end

	hooksecurefunc(_G.GarrisonFollowerTabMixin, 'ShowFollower', function(s, followerID)
		local followerInfo = followerID and C_Garrison_GetFollowerInfo(followerID)
		if not followerInfo then return end

		if not s.PortraitFrameStyled then
			S:HandleGarrisonPortrait(s.PortraitFrame)
			s.PortraitFrameStyled = true
		end

		local r, g, b = E:GetItemQualityColor(followerInfo.quality or 1)

		s.Name:SetVertexColor(r, g, b)
		s.PortraitFrame.Portrait.backdrop:SetBackdropBorderColor(r, g, b)

		s.XPBar:ClearAllPoints()
		s.XPBar:Point('BOTTOMLEFT', s.PortraitFrame, 'BOTTOMRIGHT', 7, -15)
	end)
end

S:AddCallbackForAddon('Blizzard_GarrisonTemplates')
