local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, unpack = ipairs, unpack
local hooksecurefunc = hooksecurefunc

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

	do -- Classes on the right side of the Raid Control
		local prevButton
		for index = 1, 13 do
			local button = _G['RaidClassButton'..index]
			local icon = _G['RaidClassButton'..index..'IconTexture']
			local count = _G['RaidClassButton'..index..'Count']

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
				icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-Pets]])
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 12 then
				icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainTank]])
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 13 then
				icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainAssist]])
				icon:SetTexCoord(unpack(E.TexCoords))
			end

			count:FontTemplate(nil, 12, 'OUTLINE')
			count:SetTextHeight(12) -- fixes blur
		end
	end

	hooksecurefunc('RaidPullout_GetFrame', function()
		for i = 1, _G.NUM_RAID_PULLOUT_FRAMES do
			local backdrop = _G['RaidPullout'..i..'MenuBackdrop']
			if backdrop and backdrop.NineSlice then
				backdrop.NineSlice:SetTemplate('Transparent')
			end
		end
	end)

	local bars = { 'HealthBar', 'ManaBar', 'Target', 'TargetTarget' }
	hooksecurefunc('RaidPullout_Update', function(pullOutFrame)
		local frameName = pullOutFrame:GetName()
		for i = 1, pullOutFrame.numPulloutButtons do
			local name = frameName..'Button'..i
			local object = _G[name]
			if object then
				if not object.backdrop then
					for _, v in ipairs(bars) do
						local bar = _G[name..v]
						if bar then
							bar:StripTextures()
							bar:SetStatusBarTexture(E.media.normTex)
						end
					end

					local manabar = object.manabar
					if manabar then
						manabar:Point('TOP', object.healthbar, 'BOTTOM', 0, 0)
					end

					local target = _G[name..'Target']
					if target and manabar then
						target:Point('TOP', manabar, 'BOTTOM', 0, -1)
					end

					object:CreateBackdrop('Transparent')

					object.backdrop:NudgePoint(nil, -10)
					object.backdrop:NudgePoint(nil, 1, nil, 2)
				end

				local targettarget = _G[name..'TargetTargetFrame']
				if targettarget and targettarget.NineSlice then
					targettarget.NineSlice:SetTemplate('Transparent')
				end
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_RaidUI')
