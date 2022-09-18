local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local CanQueueForWintergrasp = CanQueueForWintergrasp
local hooksecurefunc = hooksecurefunc

function S:SkinBattlefield()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.battlefield) then return end

	-- Main Frame
	local BattlefieldFrame = _G.BattlefieldFrame
	BattlefieldFrame:StripTextures(true)
	BattlefieldFrame:CreateBackdrop('Transparent')
	BattlefieldFrame.backdrop:Point('TOPLEFT', 9, -12)
	BattlefieldFrame.backdrop:Point('BOTTOMRIGHT', -32, 75)

	_G.BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
	_G.BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	_G.BattlefieldFrameGroupJoinButton:Point('RIGHT', _G.BattlefieldFrameJoinButton, 'LEFT', -2, 0)

	-- Wintergrasp Queue Button
	local WintergraspTimer = _G.WintergraspTimer
	WintergraspTimer:Size(30)
	WintergraspTimer:SetTemplate()
	WintergraspTimer.texture:SetInside()
	WintergraspTimer.texture:SetDrawLayer('ARTWORK')
	WintergraspTimer.texture:SetTexCoord(0.1875, 0.8125, 0.59375, 0.90625)

	hooksecurefunc('WintergraspTimer_OnUpdate', function()
		local canQueue = CanQueueForWintergrasp()
		if canQueue then
			_G.WintergraspTimer.texture:SetTexCoord(0.1875, 0.8125, 0.59375, 0.90625)
		end
	end)

	local backdrop_level = BattlefieldFrame.backdrop:GetFrameLevel()

	-- Custom Backdrop 1
	local topBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	topBackdrop:SetTemplate('Transparent')
	topBackdrop:Height(130)
	topBackdrop:Width(330)
	topBackdrop:Point('TOP', BattlefieldFrame, 'TOP', -12, -38)
	topBackdrop:SetFrameLevel(backdrop_level)
	BattlefieldFrame.TopBackdrop = topBackdrop

	-- Custom Backdrop 2
	local bottomBackdrop = CreateFrame('Frame', nil, BattlefieldFrame)
	bottomBackdrop:SetTemplate('Transparent')
	bottomBackdrop:Height(230)
	bottomBackdrop:Width(330)
	bottomBackdrop:Point('BOTTOM', BattlefieldFrame, 'BOTTOM', -12, 110)
	bottomBackdrop:SetFrameLevel(backdrop_level)
	BattlefieldFrame.BottomBackdrop = bottomBackdrop

	S:HandleCloseButton(_G.BattlefieldFrameCloseButton)
	_G.BattlefieldFrameCloseButton:Point('TOPRIGHT', -26, -5)
end

S:AddCallback('SkinBattlefield')
