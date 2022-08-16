local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, unpack = ipairs, unpack
local hooksecurefunc = hooksecurefunc
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CLASS_SORT_ORDER = CLASS_SORT_ORDER

local StripAllTextures = {
	'RaidGroup1',
	'RaidGroup2',
	'RaidGroup3',
	'RaidGroup4',
	'RaidGroup5',
	'RaidGroup6',
	'RaidGroup7',
	'RaidGroup8'
}

function S:Blizzard_RaidUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.raid) then return end

	-- Raid Frame Tab
	S:HandleButton(_G.RaidFrameReadyCheckButton)

	_G.RaidFrameConvertToRaidButton:Point('BOTTOMRIGHT', -6, 4)

	for _, object in ipairs(StripAllTextures) do
		local obj = _G[object]
		if obj then
			obj:StripTextures()
		end
	end

	for i = 1, _G.MAX_RAID_GROUPS * 5 do
		S:HandleButton(_G['RaidGroupButton'..i], true)
	end

	for i = 1, 8 do
		for j = 1, 5 do
			local slot = _G['RaidGroup'..i..'Slot'..j]
			slot:StripTextures()
			slot:SetTemplate('Transparent')
		end
	end

	_G.RaidClassButton1:ClearAllPoints()
	_G.RaidClassButton1:Point('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', -50, -50)

	-- Classes on the right side of the Raid Control
	do
		local prevButton
		local button, icon, count, coords

		for index = 1, 13 do
			button = _G['RaidClassButton'..index]
			icon = _G['RaidClassButton'..index..'IconTexture']
			count = _G['RaidClassButton'..index..'Count']

			button:StripTextures()
			button:SetTemplate()
			button:Size(22)

			button:ClearAllPoints()
			if index == 1 then
				button:Point('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', -3, -48)
			elseif index == 11 then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -25)
			else
				button:Point('TOP', prevButton, 'BOTTOM', 0, -5)
			end
			prevButton = button

			icon:SetInside()

			if index == 11 then
				icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-Pets')
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 12 then
				icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-MainTank')
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 13 then
				icon:SetTexture('Interface\\RaidFrame\\UI-RaidFrame-MainAssist')
				icon:SetTexCoord(unpack(E.TexCoords))
			else
				coords = CLASS_ICON_TCOORDS[CLASS_SORT_ORDER[index]]
				icon:SetTexture('Interface\\WorldStateFrame\\Icons-Classes')
				icon:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
			end

			count:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	hooksecurefunc('RaidPullout_GetFrame', function()
		for i = 1, _G.NUM_RAID_PULLOUT_FRAMES do
			local rp = _G['RaidPullout'..i]
			if rp and not rp.backdrop then
				S:HandleFrame(rp, true, nil, 9, -17, -7, 10)
			end
		end
	end)

	local bars = { 'HealthBar', 'ManaBar', 'Target', 'TargetTarget' }
	hooksecurefunc('RaidPullout_Update', function(pullOutFrame)
		local pfName = pullOutFrame:GetName()
		local pfBName, pfBObj, pfTot

		for i = 1, pullOutFrame.numPulloutButtons do
			pfBName = pfName..'Button'..i
			pfBObj = _G[pfBName]
			pfTot = _G[pfBName..'TargetTargetFrame']

			if not pfBObj.backdrop then
				local sBar

				for _, v in ipairs(bars) do
					sBar = _G[pfBName..v]
					sBar:StripTextures()
					sBar:SetStatusBarTexture(E.media.normTex)
				end

				_G[pfBName..'ManaBar']:Point('TOP', '$parentHealthBar', 'BOTTOM', 0, 0)
				_G[pfBName..'Target']:Point('TOP', '$parentManaBar', 'BOTTOM', 0, -1)

				pfBObj:CreateBackdrop()
				pfBObj.backdrop:Point('TOPLEFT', E.PixelMode and 0 or -1, -(E.PixelMode and 10 or 9))
				pfBObj.backdrop:Point('BOTTOMRIGHT', E.PixelMode and 0 or 1, E.PixelMode and 1 or 0)
			end

			if not pfTot.backdrop then
				pfTot:StripTextures()
				pfTot:CreateBackdrop()
				pfTot.backdrop:Point('TOPLEFT', E.PixelMode and 10 or 9, -(E.PixelMode and 15 or 14))
				pfTot.backdrop:Point('BOTTOMRIGHT', -(E.PixelMode and 10 or 9), E.PixelMode and 8 or 7)
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_RaidUI')
