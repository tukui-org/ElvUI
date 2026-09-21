local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local GetInventoryItemQuality = GetInventoryItemQuality

local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS
local MAX_TALENT_TABS = MAX_TALENT_TABS
local MAX_NUM_TALENTS = MAX_NUM_TALENTS

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())

	local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)
	button.backdrop:SetBackdropBorderColor(r, g, b)
end

local function HandleTabs()
	local tab = _G.InspectFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.InspectFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['InspectFrameTab'..index]
	end
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	S:HandleFrame(_G.InspectFrame)

	-- Tabs
	HandleTabs()

	_G.InspectPaperDollFrame:StripTextures()
	_G.InspectModelFrameBackgroundOverlay:SetTexture(E.media.blankTex)
	_G.InspectModelFrameBackgroundOverlay:SetVertexColor(0, 0, 0, 0.6)
	_G.InspectModelFrameBackgroundOverlay:CreateBackdrop('Transparent')

	_G.InspectModelFrameBorderTopLeft:Kill()
	_G.InspectModelFrameBorderTopRight:Kill()
	_G.InspectModelFrameBorderTop:Kill()
	_G.InspectModelFrameBorderLeft:Kill()
	_G.InspectModelFrameBorderRight:Kill()
	_G.InspectModelFrameBorderBottomLeft:Kill()
	_G.InspectModelFrameBorderBottomRight:Kill()
	_G.InspectModelFrameBorderBottom:Kill()

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:OffsetFrameLevel(2)
		slot:StyleButton()

		local icon = slot.icon
		icon:SetTexCoords()
		icon:SetInside()
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)

	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- PvP Tab
	_G.InspectPVPFrame:StripTextures()

	for i = 1, MAX_ARENA_TEAMS do
		local team = _G['InspectPVPTeam'..i]
		team:StripTextures()
		team:CreateBackdrop()
		team.backdrop:Point('TOPLEFT', 9, -4)
		team.backdrop:Point('BOTTOMRIGHT', -24, 3)

		team:HookScript('OnEnter', S.SetModifiedBackdrop)
		team:HookScript('OnLeave', S.SetOriginalBackdrop)

		_G['InspectPVPTeam'..i..'Highlight']:Kill()
	end

	-- Talent Tab
	_G.InspectTalentFrame:StripTextures()

	for i = 1, MAX_TALENT_TABS do -- HandleTab looks weird on these
		local tab = _G['InspectTalentFrameTab'..i]
		tab:StripTextures()
		tab:Height(24)
		S:HandleButton(tab)
	end

	local pointsBar = _G.InspectTalentFramePointsBar
	pointsBar:StripTextures()

	_G.InspectTalentFrameSpentPointsText:Point('LEFT', pointsBar, 'LEFT', 12, -1)
	_G.InspectTalentFrameTalentPointsText:Point('RIGHT', pointsBar, 'RIGHT', -12, -1)

	local scrollFrame = _G.InspectTalentFrameScrollFrame
	scrollFrame:StripTextures()
	scrollFrame:CreateBackdrop()

	local scrollBar = _G.InspectTalentFrameScrollFrameScrollBar
	S:HandleScrollBar(scrollBar)
	scrollBar:Point('TOPLEFT', scrollFrame, 'TOPRIGHT', 10, -16)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G['InspectTalentFrameTalent'..i]
		talent:StripTextures()
		talent:SetTemplate()
		talent:StyleButton()

		local icon = talent.icon
		icon:SetInside()
		icon:SetTexCoords()
		icon:SetDrawLayer('ARTWORK')

		local rank = _G['InspectTalentFrameTalent'..i..'Rank']
		rank:FontTemplate(nil, 12, 'OUTLINE')
	end
end

S:AddCallbackForAddon('Blizzard_InspectUI')
