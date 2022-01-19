local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local pairs, ipairs = pairs, ipairs
local hooksecurefunc = hooksecurefunc

local StripAllTextures = {
	'RaidGroup1',
	'RaidGroup2',
	'RaidGroup3',
	'RaidGroup4',
	'RaidGroup5',
	'RaidGroup6',
	'RaidGroup7',
	'RaidGroup8',
}

function S:Blizzard_RaidUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.raid) then return end

	for _, object in ipairs(StripAllTextures) do
		local obj = _G[object]
		if obj then
			obj:StripTextures()
		end
	end

	S:HandleButton(_G.RaidFrameReadyCheckButton)
	S:HandleButton(_G.RaidFrameRaidInfoButton)

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

	do
		local prevButton
		for key, data in pairs(_G.RAID_CLASS_BUTTONS) do
			local index = data.button
			if index then
				local button = _G['RaidClassButton'..index]
				local icon = _G['RaidClassButton'..index..'IconTexture']
				local count = _G['RaidClassButton'..index..'Count']
				button:StripTextures()
				button:SetTemplate('Default')
				button:Size(22)

				button:ClearAllPoints()
				if index == 1 then
					button:Point('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', -34, -37)
				elseif index == 11 then
					button:Point('TOP', prevButton, 'BOTTOM', 0, -20)
				else
					button:Point('TOP', prevButton, 'BOTTOM', 0, -6)
				end
				prevButton = button

				count:FontTemplate(nil, 12, 'OUTLINE')

				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))

				if key == 'PETS' then
					icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-Pets]])
				elseif key == 'MAINTANK' then
					icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainTank]])
				elseif key == 'MAINASSIST' then
					icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainAssist]])
				else
					local coords = _G.CLASS_ICON_TCOORDS[_G.CLASS_SORT_ORDER[index]]
					if coords then
						icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
						icon:SetTexCoord(coords[1] + 0.015, coords[2] - 0.02, coords[3] + 0.018, coords[4] - 0.02)
					end
				end
			end
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
