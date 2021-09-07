local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs
local unpack = unpack

local hooksecurefunc = hooksecurefunc

function S:Blizzard_RaidUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.raid) then return end

	local StripAllTextures = {
		_G.RaidGroup1,
		_G.RaidGroup2,
		_G.RaidGroup3,
		_G.RaidGroup4,
		_G.RaidGroup5,
		_G.RaidGroup6,
		_G.RaidGroup7,
		_G.RaidGroup8
	}

	for _, object in ipairs(StripAllTextures) do
		object:StripTextures()
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
		for index = 1, 13 do
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
				local coords = _G.CLASS_ICON_TCOORDS[_G.CLASS_SORT_ORDER[index]]
				if coords then
					icon:SetTexture('Interface\\WorldStateFrame\\Icons-Classes')
					icon:SetTexCoord(coords[1] + 0.015, coords[2] - 0.02, coords[3] + 0.018, coords[4] - 0.02)
				end
			end

			count:FontTemplate(nil, 12, 'OUTLINE')
		end
	end

	local function skinPulloutFrames()
		local rp
		for i = 1, _G.NUM_RAID_PULLOUT_FRAMES do
			rp = _G['RaidPullout'..i]
			if not rp.backdrop then
				_G['RaidPullout'..i..'MenuBackdrop']:SetBackdrop(nil)
				S:HandleFrame(rp, true, nil, 9, -17, -7, 10)
			end
		end
	end

	hooksecurefunc('RaidPullout_GetFrame', function()
		skinPulloutFrames()
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
