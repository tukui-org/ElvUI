local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc
local CLASS_SORT_ORDER = CLASS_SORT_ORDER

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

S:AddCallbackForAddon('Blizzard_RaidUI', nil, nil, nil, nil, nil, 'raid')

local function RaidPulloutGetFrame()
	for i = 1, _G.NUM_RAID_PULLOUT_FRAMES do
		local backdrop = _G['RaidPullout'..i..'MenuBackdrop']
		backdrop.NineSlice:SetTemplate('Transparent')
	end
end

local bars = { 'HealthBar', 'ManaBar', 'Target', 'TargetTarget' }
local function RaidPulloutUpdate(pullOutFrame)
	local frameName = pullOutFrame:GetName()
	for i = 1, pullOutFrame.numPulloutButtons do
		local name = frameName..'Button'..i
		local object = _G[name]
		if not object.backdrop then
			for _, v in ipairs(bars) do
				local bar = _G[name..v]
				bar:StripTextures()
				bar:SetStatusBarTexture(E.media.normTex)
			end

			local manabar = object.manabar
			manabar:Point('TOP', object.healthbar, 'BOTTOM', 0, 0)

			local target = _G[name..'Target']
			target:Point('TOP', manabar, 'BOTTOM', 0, -1)

			object:CreateBackdrop('Transparent')
			object.backdrop:NudgePoint(nil, -10)
			object.backdrop:NudgePoint(nil, 1, nil, 2)
		end

		local targettarget = _G[name..'TargetTargetFrame']
		targettarget.NineSlice:SetTemplate('Transparent')
	end
end

local function HandleClassButtons()
	local numClasses = _G.MAX_CLASSES
	local plusOne = numClasses + 1
	local plusTwo = numClasses + 2
	local plusThree = numClasses + 3

	local prevButton
	for index = 1, _G.MAX_RAID_CLASS_BUTTONS do -- classes, pets, main tank, main assist
		local button = _G['RaidClassButton'..index]
		local icon = _G['RaidClassButton'..index..'IconTexture']
		local count = _G['RaidClassButton'..index..'Count']

		button:StripTextures()
		button:SetTemplate()
		button:Size(22)

		button:ClearAllPoints()
		if index == 1 then
			button:Point('TOPLEFT', _G.RaidFrame, 'TOPRIGHT', -3, -48)
		elseif index == plusOne then
			button:Point('TOP', prevButton, 'BOTTOM', 0, -25)
		else
			button:Point('TOP', prevButton, 'BOTTOM', 0, -5)
		end
		prevButton = button

		icon:SetInside()

		if index == plusOne then
			icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-Pets]])
			icon:SetTexCoords()
		elseif index == plusTwo then
			icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainTank]])
			icon:SetTexCoords()
		elseif index == plusThree then
			icon:SetTexture([[Interface\RaidFrame\UI-RaidFrame-MainAssist]])
			icon:SetTexCoords()
		else
			icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
			icon:SetTexCoord(E:GetClassCoords(CLASS_SORT_ORDER[index], .02))
		end

		count:FontTemplate(nil, 12, 'OUTLINE')
		count:SetTextHeight(12) -- fixes blur
	end
end

function S:Blizzard_RaidUI()
	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()

		for j = 1, 5 do
			local slot = _G[object..'Slot'..j]
			slot:StripTextures()
			slot:SetTemplate('Transparent')
		end
	end

	for i = 1, _G.MAX_RAID_GROUPS*5 do
		S:HandleButton(_G['RaidGroupButton'..i], true)
	end

	-- Mainline has no ready check button, never shows the class buttons and cannot drag out pullouts
	if not E.Modern then
		S:HandleButton(_G.RaidFrameReadyCheckButton)

		HandleClassButtons() -- Classes on the right side of the Raid Control

		hooksecurefunc('RaidPullout_GetFrame', RaidPulloutGetFrame)
		hooksecurefunc('RaidPullout_Update', RaidPulloutUpdate)
	end
end
