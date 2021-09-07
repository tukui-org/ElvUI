local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack, select = unpack, select
local ipairs = ipairs

local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local hooksecurefunc = hooksecurefunc

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
		slot:CreateBackdrop('Default')
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()

		if cooldown then
			E:RegisterCooldown(cooldown)
		end
	end

	local function styleButton(button)
		if button.hasItem then
			local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
			if itemID then
				local quality = select(3, GetItemInfo(itemID))

				if not quality then
					E:Delay(0.1, function()
						if InspectFrame.unit then
							styleButton(button)
						end
					end)

					return
				elseif quality and quality > 1 then
					button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
				end
			end
		end

		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	hooksecurefunc('InspectPaperDollItemSlotButton_Update', styleButton)

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
	_G.InspectTalentFrameScrollFrame:CreateBackdrop('Default')

	S:HandleScrollBar(_G.InspectTalentFrameScrollFrameScrollBar)
	_G.InspectTalentFrameScrollFrameScrollBar:Point('TOPLEFT', _G.InspectTalentFrameScrollFrame, 'TOPRIGHT', 10, -16)

	for i = 1, _G.MAX_NUM_TALENTS do
		local talent = _G['InspectTalentFrameTalent'..i]
		local icon = _G['InspectTalentFrameTalent'..i..'IconTexture']
		local rank = _G['InspectTalentFrameTalent'..i..'Rank']

		if talent then
			talent:StripTextures()
			talent:SetTemplate('Default')
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
		inspectpvpTeam:CreateBackdrop('Default')
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
