local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select
local ipairs = ipairs

local GetInventoryItemID = GetInventoryItemID
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc

local MAX_ARENA_TEAMS = MAX_ARENA_TEAMS

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	if not unit then return end

	local itemID = GetInventoryItemID(unit, button:GetID())
	if itemID then
		local quality = select(3, GetItemInfo(itemID))
		if quality and quality > 1 then
			button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			return
		end
	end

	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

function S:Blizzard_InspectUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.inspect) then return end

	local InspectFrame = _G.InspectFrame
	S:HandleFrame(InspectFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.InspectFrameCloseButton, InspectFrame.backdrop)

	for i = 1, #_G.INSPECTFRAME_SUBFRAMES do
		S:HandleTab(_G['InspectFrameTab'..i])
	end

	_G.InspectPaperDollFrame:StripTextures()

	for _, slot in ipairs({ _G.InspectPaperDollItemsFrame:GetChildren() }) do
		local icon = _G[slot:GetName()..'IconTexture']
		local cooldown = _G[slot:GetName()..'Cooldown']

		slot:StripTextures()
		slot:CreateBackdrop()
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', Update_InspectPaperDollItemSlotButton)

	S:HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
	_G.InspectModelFrameRotateLeftButton:Point('TOPLEFT', 3, -3)

	S:HandleRotateButton(_G.InspectModelFrameRotateRightButton)
	_G.InspectModelFrameRotateRightButton:Point('TOPLEFT', _G.InspectModelFrameRotateLeftButton, 'TOPRIGHT', 3, 0)

	-- Talents
	S:HandleFrame(_G.InspectTalentFrame, true, nil, 11, -12, -32, 76)
	S:HandleCloseButton(_G.InspectTalentFrameCloseButton, _G.InspectTalentFrame.backdrop)

	_G.InspectTalentFrameCancelButton:Kill()

	for i = 1, 3 do
		S:HandleTab(_G['InspectTalentFrameTab'..i], true)
	end

	_G.InspectTalentFrameScrollFrame:StripTextures()
	_G.InspectTalentFrameScrollFrame:CreateBackdrop()

	S:HandleScrollBar(_G.InspectTalentFrameScrollFrameScrollBar)
	_G.InspectTalentFrameScrollFrameScrollBar:Point('TOPLEFT', _G.InspectTalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['InspectTalentFrameTalent'..i]
		local icon = _G['InspectTalentFrameTalent'..i..'IconTexture']
		local rank = _G['InspectTalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate()
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer('ARTWORK')

			rank:SetFont(E.LSM:Fetch('font', E.db['general'].font), 12, 'OUTLINE')
		end
	end

	-- Honor/Arena/PvP Tab
	local InspectPVPFrame = _G.InspectPVPFrame
	InspectPVPFrame:StripTextures(true)

	for i = 1, MAX_ARENA_TEAMS do
		local inspectpvpTeam = _G['InspectPVPTeam'..i]

		inspectpvpTeam:StripTextures()
		inspectpvpTeam:CreateBackdrop()
		inspectpvpTeam.backdrop:Point('TOPLEFT', 9, -4)
		inspectpvpTeam.backdrop:Point('BOTTOMRIGHT', -24, 3)

		inspectpvpTeam:HookScript('OnEnter', S.SetModifiedBackdrop)
		inspectpvpTeam:HookScript('OnLeave', S.SetOriginalBackdrop)

		_G['InspectPVPTeam'..i..'Highlight']:Kill()
	end

	local PVPTeamDetails = _G.PVPTeamDetails
	PVPTeamDetails:StripTextures()
	PVPTeamDetails:SetTemplate('Transparent')
	PVPTeamDetails:Point('TOPLEFT', InspectPVPFrame, 'TOPRIGHT', -30, -12)

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

	S:HandleButton(_G.PVPTeamDetailsAddTeamMember)
	S:HandleNextPrevButton(_G.PVPTeamDetailsToggleButton)
	S:HandleCloseButton(_G.PVPTeamDetailsCloseButton)
end

S:AddCallbackForAddon('Blizzard_InspectUI')
