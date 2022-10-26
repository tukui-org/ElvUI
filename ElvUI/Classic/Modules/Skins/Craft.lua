local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, strfind, select = unpack, strfind, select

local GetItemInfo = GetItemInfo
local GetCraftNumReagents = GetCraftNumReagents
local GetItemQualityColor = GetItemQualityColor
local GetCraftItemLink = GetCraftItemLink
local GetCraftReagentInfo = GetCraftReagentInfo
local GetCraftReagentItemLink = GetCraftReagentItemLink
local hooksecurefunc = hooksecurefunc

function S:SkinCraft()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.craft) then return end

	local CraftFrame = _G.CraftFrame
	S:HandleFrame(CraftFrame, true, nil, 11, -12, -32, 76)

	local CraftRankFrame = _G.CraftRankFrame
	CraftRankFrame:StripTextures()
	CraftRankFrame:Size(322, 16)
	CraftRankFrame:ClearAllPoints()
	CraftRankFrame:Point('TOP', -10, -45)
	CraftRankFrame:CreateBackdrop()
	CraftRankFrame:SetStatusBarTexture(E.media.normTex)
	CraftRankFrame:SetStatusBarColor(0.13, 0.35, 0.80)
	E:RegisterStatusBar(CraftRankFrame)

	_G.CraftRankFrameBorder:StripTextures()

	_G.CraftListScrollFrame:StripTextures()
	_G.CraftDetailScrollFrame:StripTextures()
	_G.CraftDetailScrollChildFrame:StripTextures()

	S:HandleScrollBar(_G.CraftListScrollFrameScrollBar)
	S:HandleScrollBar(_G.CraftDetailScrollFrameScrollBar)

	S:HandleButton(_G.CraftCancelButton)

	S:HandleButton(_G.CraftCreateButton)

	local CraftIcon = _G.CraftIcon

	_G.CraftRequirements:SetTextColor(1, 0.80, 0.10)

	S:HandleCloseButton(_G.CraftFrameCloseButton, CraftFrame.backdrop)

	_G.CraftExpandButtonFrame:StripTextures()

	local CraftCollapseAllButton = _G.CraftCollapseAllButton
	CraftCollapseAllButton:Point('LEFT', _G.CraftExpandTabLeft, 'RIGHT', -8, 5)
	CraftCollapseAllButton:GetNormalTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetNormalTexture():Size(15)

	CraftCollapseAllButton:SetHighlightTexture(E.ClearTexture)
	CraftCollapseAllButton.SetHighlightTexture = E.noop

	CraftCollapseAllButton:SetDisabledTexture(E.Media.Textures.MinusButton)
	CraftCollapseAllButton.SetDisabledTexture = E.noop
	CraftCollapseAllButton:GetDisabledTexture():Point('LEFT', 3, 2)
	CraftCollapseAllButton:GetDisabledTexture():Size(15)
	CraftCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	for i = 1, _G.CRAFTS_DISPLAYED do
		local button = _G['Craft'..i]
		local highlight = _G['Craft'..i..'Highlight']

		button:GetNormalTexture():Size(14)
		button:GetNormalTexture():Point('LEFT', 4, 1)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop
	end

	for i = 1, _G.MAX_CRAFT_REAGENTS do
		local icon = _G['CraftReagent'..i..'IconTexture']
		local count = _G['CraftReagent'..i..'Count']
		local nameFrame = _G['CraftReagent'..i..'NameFrame']

		S:HandleIcon(icon, true)
		icon:SetDrawLayer('ARTWORK')
		count:SetDrawLayer('OVERLAY')

		nameFrame:SetAlpha(0)
	end

	_G.CraftReagent1:Point('TOPLEFT', _G.CraftReagentLabel, 'BOTTOMLEFT', -3, -3)
	_G.CraftReagent2:Point('LEFT', _G.CraftReagent1, 'RIGHT', 3, 0)
	_G.CraftReagent4:Point('LEFT', _G.CraftReagent3, 'RIGHT', 3, 0)
	_G.CraftReagent6:Point('LEFT', _G.CraftReagent5, 'RIGHT', 3, 0)
	_G.CraftReagent8:Point('LEFT', _G.CraftReagent7, 'RIGHT', 3, 0)

	hooksecurefunc('CraftFrame_Update', function()
		for i = 1, _G.CRAFTS_DISPLAYED do
			local button = _G['Craft'..i]
			local texture = button:GetNormalTexture():GetTexture()
			if texture then
				if strfind(texture, 'MinusButton') then
					button:SetNormalTexture(E.Media.Textures.MinusButton)
				elseif strfind(texture, 'PlusButton') then
					button:SetNormalTexture(E.Media.Textures.PlusButton)
				end
			end
		end

		if CraftCollapseAllButton.collapsed then
			CraftCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
		else
			CraftCollapseAllButton:SetNormalTexture(E.Media.Textures.MinusButton)
		end
	end)

	CraftIcon:CreateBackdrop()

	hooksecurefunc('CraftFrame_SetSelection', function(id)
		if ( not id ) then
			return
		end

		local CraftReagentLabel = _G.CraftReagentLabel
		CraftReagentLabel:Point('TOPLEFT', _G.CraftDescription, 'BOTTOMLEFT', 0, -10)

		if CraftIcon:GetNormalTexture() then
			S:HandleIcon(CraftIcon:GetNormalTexture())
		end

		CraftIcon:Size(40)
		CraftIcon:Point('TOPLEFT', 2, -3)

		local skillLink = GetCraftItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				CraftIcon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
				_G.CraftName:SetTextColor(GetItemQualityColor(quality))
			else
				CraftIcon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				_G.CraftName:SetTextColor(1, 1, 1)
			end
		end

		local numReagents = GetCraftNumReagents(id)
		for i = 1, numReagents, 1 do
			local _, _, reagentCount, playerReagentCount = GetCraftReagentInfo(id, i)
			local reagentLink = GetCraftReagentItemLink(id, i)
			local icon = _G['CraftReagent'..i..'IconTexture']
			local name = _G['CraftReagent'..i..'Name']

			if reagentLink then
				local quality = select(3, GetItemInfo(reagentLink))
				if quality and quality > 1 then
					icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					if playerReagentCount < reagentCount then
						name:SetTextColor(0.5, 0.5, 0.5)
					else
						name:SetTextColor(GetItemQualityColor(quality))
					end
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end

		if (numReagents < 5) then
			_G.CraftDetailScrollFrameScrollBar:Hide()
			_G.CraftDetailScrollFrameTop:Hide()
			_G.CraftDetailScrollFrameBottom:Hide()
		else
			_G.CraftDetailScrollFrameScrollBar:Show()
			_G.CraftDetailScrollFrameTop:Show()
			_G.CraftDetailScrollFrameBottom:Show()
		end
	end)
end

S:AddCallbackForAddon('Blizzard_CraftUI', 'SkinCraft')
