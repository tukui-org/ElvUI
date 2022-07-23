local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local pairs, ipairs = pairs, ipairs
local hooksecurefunc = hooksecurefunc

function S:Blizzard_RaidUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.raid) then return end

	hooksecurefunc('RaidPullout_GetFrame', function()
		for i = 1, _G.NUM_RAID_PULLOUT_FRAMES do
			local rp = _G['RaidPullout'..i]
			if rp and not rp.backdrop then
				S:HandleFrame(rp, true, nil, 9, -17, -7, 10)
			end
		end
	end)

	hooksecurefunc('RaidPullout_Update', function(pullOutFrame)
		local pfName = pullOutFrame:GetName()
		local pfBName, pfBObj, pfTot

		for i = 1, pullOutFrame.numPulloutButtons do
			pfBName = pfName..'Button'..i
			pfBObj = _G[pfBName]
			pfTot = _G[pfBName..'TargetTargetFrame']

			if not pfBObj.backdrop then
				local sBar

				for _, v in ipairs({'HealthBar', 'ManaBar', 'Target', 'TargetTarget'}) do
					sBar = _G[pfBName..v]
					sBar:StripTextures()
					sBar:SetStatusBarTexture(E.media.normTex)
				end

				_G[pfBName..'ManaBar']:Point('TOP', '$parentHealthBar', 'BOTTOM', 0, 0)
				_G[pfBName..'Target']:Point('TOP', '$parentManaBar', 'BOTTOM', 0, -1)

				pfBObj:CreateBackdrop('Default')
				pfBObj.backdrop:Point('TOPLEFT', E.PixelMode and 0 or -1, -(E.PixelMode and 10 or 9))
				pfBObj.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 0 or 1, E.PixelMode and 1 or 0)
			end

			if not pfTot.backdrop then
				pfTot:StripTextures()
				pfTot:CreateBackdrop('Default')
				pfTot.backdrop:Point('TOPLEFT', E.PixelMode and 10 or 9, -(E.PixelMode and 15 or 14))
				pfTot.backdrop:Point('BOTTOMRIGHT', -(E.PixelMode and 10 or 9), E.PixelMode and 8 or 7)
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_RaidUI')
