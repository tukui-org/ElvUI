local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

function S:SkinPVPFrame()
	-- Honor/Arena/PvP Tab
	local PVPFrame = _G.PVPFrame
	S:HandleFrame(PVPFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.PVPParentFrameCloseButton)
	_G.PVPParentFrameCloseButton:Point('TOPRIGHT', -26, -5)

	for i = 1, MAX_ARENA_TEAMS do
		local pvpTeam = _G['PVPTeam'..i]

		pvpTeam:StripTextures()
		pvpTeam:CreateBackdrop()
		pvpTeam.backdrop:Point('TOPLEFT', 9, -4)
		pvpTeam.backdrop:Point('BOTTOMRIGHT', -24, 3)

		pvpTeam:HookScript('OnEnter', S.SetModifiedBackdrop)
		pvpTeam:HookScript('OnLeave', S.SetOriginalBackdrop)

		_G['PVPTeam'..i..'Highlight']:Kill()
	end

	local PVPTeamDetails = _G.PVPTeamDetails
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate('Transparent')

	local PVPFrameToggleButton = _G.PVPFrameToggleButton
	S:HandleNextPrevButton(PVPFrameToggleButton)
	PVPFrameToggleButton:Point('BOTTOMRIGHT', PVPFrame, 'BOTTOMRIGHT', -48, 81)
	PVPFrameToggleButton:Size(14)

	for i = 1, 5 do
		local header = _G['PVPTeamDetailsFrameColumnHeader'..i]
		header:StripTextures()
		header:StyleButton()
	end

	for i = 1, 10 do
		local button = _G['PVPTeamDetailsButton'..i]
		button:Width(335)
		S:HandleButtonHighlight(button)
	end

	-- BG Queue Tabs
	S:HandleTab(_G.PVPParentFrameTab1)
	S:HandleTab(_G.PVPParentFrameTab2)

	-- Reposition Tabs
	_G.PVPParentFrameTab1:ClearAllPoints()
	_G.PVPParentFrameTab1:Point('TOPLEFT', _G.PVPParentFrame, 'BOTTOMLEFT', 1, 76)
	_G.PVPParentFrameTab2:Point('TOPLEFT', _G.PVPParentFrameTab1, 'TOPRIGHT', -19, 0)

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)
end

function S:SkinBattlefield()
	-- Main Frame
	local BattlefieldFrame = _G.BattlefieldFrame
	BattlefieldFrame:StripTextures(true)
	S:HandleFrame(BattlefieldFrame, true, nil, 11, -12, -32, 76)

	_G.BattlefieldFrameInfoScrollFrameChildFrameRewardsInfoDescription:SetTextColor(1, 1, 1)
	_G.BattlefieldFrameInfoScrollFrameChildFrameDescription:SetTextColor(1, 1, 1)

	S:HandleButton(_G.BattlefieldFrameCancelButton)
	S:HandleButton(_G.BattlefieldFrameJoinButton)
	S:HandleButton(_G.BattlefieldFrameGroupJoinButton)

	_G.BattlefieldFrameGroupJoinButton:Point('RIGHT', _G.BattlefieldFrameJoinButton, 'LEFT', -2, 0)

	_G.BattlefieldFrameTypeScrollFrame:StripTextures()
	S:HandleScrollBar(_G.BattlefieldFrameTypeScrollFrameScrollBar)

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

function S:SkinPVPReadyDialog()
	-- PvP Queue Popup
	_G.PVPReadyDialog:StripTextures()
	_G.PVPReadyDialog:SetTemplate('Transparent')
	S:HandleButton(_G.PVPReadyDialogEnterBattleButton)
	S:HandleButton(_G.PVPReadyDialogHideButton)
end

function S:SkinPVP()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	S:SkinPVPFrame()
	S:SkinBattlefield()
	S:SkinPVPReadyDialog()
end

S:AddCallback('SkinPVP')
