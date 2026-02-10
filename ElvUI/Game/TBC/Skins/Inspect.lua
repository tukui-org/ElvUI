local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetInventoryItemQuality = GetInventoryItemQuality

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

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	-- Tabs
	HandleTabs()

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()
	_G.InspectModelFrameBackgroundOverlay:SetTexture(E.Media.Textures.Invisible)
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

		local name = slot:GetName()
		local icon = _G[name..'IconTexture']
		if icon then
			icon:SetTexCoords()
			icon:SetInside()
		end

		local cooldown = _G[name..'Cooldown']
		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)

	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Talents
	local InspectTalentFrame = _G.InspectTalentFrame
	S:HandleFrame(InspectTalentFrame, true, nil, 15, -14, -32, 78)

	for i = 1, 3 do
		local tab = _G['InspectTalentFrameTab'..i]
		if tab then
			S:HandleTab(tab, true)
		end
	end

	local scrollFrame = _G.InspectTalentFrameScrollFrame
	if scrollFrame then
		scrollFrame:StripTextures()
		scrollFrame:CreateBackdrop()

		local scrollBar = _G.InspectTalentFrameScrollFrameScrollBar
		if scrollBar then
			S:HandleScrollBar(scrollBar)
			scrollBar:Point('TOPLEFT', scrollFrame, 'TOPRIGHT', 10, -16)
		end
	end

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['InspectTalentFrameTalent'..i]
		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			local icon = _G['InspectTalentFrameTalent'..i..'IconTexture']
			if icon then
				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetDrawLayer('ARTWORK')
			end

			local rank = _G['InspectTalentFrameTalent'..i..'Rank']
			if rank then
				rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
			end
		end
	end

	local PointsBar = _G.InspectTalentFramePointsBar
	if PointsBar then
		PointsBar:StripTextures()
		PointsBar:SetTemplate('Transparent')
	end

	-- Honor/Arena/PvP Tab
	local InspectPVPFrame = _G.InspectPVPFrame
	InspectPVPFrame:StripTextures(true)

	for i = 1, _G.MAX_ARENA_TEAMS do
		local inspectpvpTeam = _G['InspectPVPTeam'..i]
		if inspectpvpTeam then
			inspectpvpTeam:StripTextures()
			inspectpvpTeam:CreateBackdrop()
			inspectpvpTeam.backdrop:Point('TOPLEFT', 9, -4)
			inspectpvpTeam.backdrop:Point('BOTTOMRIGHT', -24, 3)

			inspectpvpTeam:HookScript('OnEnter', S.SetModifiedBackdrop)
			inspectpvpTeam:HookScript('OnLeave', S.SetOriginalBackdrop)

			local highlight = _G['InspectPVPTeam'..i..'Highlight']
			if highlight then
				highlight:Kill()
			end
		end
	end

	local PVPTeamDetails = _G.PVPTeamDetails
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate('Transparent')
	PVPTeamDetails:Point('TOPLEFT', InspectPVPFrame, 'TOPRIGHT', -30, -12)

	for i = 1, 5 do
		local header = _G['PVPTeamDetailsFrameColumnHeader'..i]
		if header then
			header:StripTextures()
			header:StyleButton()
		end
	end

	for i = 1, 10 do
		local button = _G['PVPTeamDetailsButton'..i]
		if button then
			button:Width(335)
			S:HandleButtonHighlight(button)
		end
	end

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
