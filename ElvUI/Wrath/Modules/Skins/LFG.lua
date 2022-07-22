local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, select = pairs, select

local function LFGTabs()
	LFGParentFrameTab1:ClearAllPoints()
	LFGParentFrameTab1:Point('TOPLEFT', LFGParentFrame, 'BOTTOMLEFT', 16, 0)
	LFGParentFrameTab2:ClearAllPoints()
	LFGParentFrameTab2:Point('LEFT', LFGParentFrameTab1, 'RIGHT', -14, 0)
end

function S:Blizzard_LookingForGroupUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end
	-- Needs full Wrath rework

	_G.LFGParentFramePortrait:Kill()

	local LFGListingFrame = _G.LFGListingFrame
	LFGListingFrame:StripTextures()
	LFGListingFrame:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
	LFGListingFrame:HookScript('OnShow', LFGTabs)

	local LFGBrowseFrame = _G.LFGBrowseFrame
	LFGBrowseFrame:StripTextures()
	LFGBrowseFrame:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
	LFGBrowseFrame:HookScript('OnShow', LFGTabs)

	do
		local i = 1
		local tab = _G['LFGParentFrameTab'..i]
		while tab do
			S:HandleTab(tab)
			tab.IsSkinned = true

			i = i + 1
			tab = _G['LFGParentFrameTab'..i]
		end
	end

	for i = 1, LFGParentFrame:GetNumChildren() do
		local child = select(i, LFGParentFrame:GetChildren())
		if not child.IsSkinned and child:GetObjectType() == 'Button' then
			child:ClearAllPoints()
			child:Point('TOPRIGHT', 2, 2)

			S:HandleCloseButton(child)
			child.IsSkinned = true
		end
	end
end

S:AddCallbackForAddon('Blizzard_LookingForGroupUI')
