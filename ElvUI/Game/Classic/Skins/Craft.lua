local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetCraftInfo = GetCraftInfo
local GetNumCrafts = GetNumCrafts
local GetCraftNumReagents = GetCraftNumReagents
local GetCraftItemLink = GetCraftItemLink
local GetCraftReagentInfo = GetCraftReagentInfo
local GetCraftReagentItemLink = GetCraftReagentItemLink
local GetCraftSelectionIndex = GetCraftSelectionIndex

local GetItemQualityByID = C_Item.GetItemQualityByID

local function SetSelection(id)
	if not id then return end

	local _, _, craftType = GetCraftInfo(id)
	if craftType == 'header' or GetCraftSelectionIndex() > GetNumCrafts() then return end -- same bails as CraftFrame_SetSelection

	_G.CraftReagentLabel:Point('TOPLEFT', _G.CraftDescription, 'BOTTOMLEFT', 0, -10)

	local CraftIcon = _G.CraftIcon
	local normal = CraftIcon:GetNormalTexture()
	if normal then -- cleared when the craft has no icon
		S:HandleIcon(normal)
	end

	local skillLink = GetCraftItemLink(id)
	if skillLink then
		local quality = GetItemQualityByID(skillLink)
		if quality and quality > 1 then
			local r, g, b = E:GetItemQualityColor(quality)
			CraftIcon.backdrop:SetBackdropBorderColor(r, g, b)
			_G.CraftName:SetTextColor(r, g, b)
		else
			CraftIcon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			_G.CraftName:SetTextColor(1, 1, 1)
		end
	end

	local numReagents = GetCraftNumReagents(id)
	for i = 1, numReagents do
		local reagentLink = GetCraftReagentItemLink(id, i)
		if reagentLink then
			local reagent = _G['CraftReagent'..i]
			local quality = GetItemQualityByID(reagentLink)

			if quality and quality > 1 then
				local r, g, b = E:GetItemQualityColor(quality)
				reagent.Icon.backdrop:SetBackdropBorderColor(r, g, b)

				local _, _, reagentCount, playerReagentCount = GetCraftReagentInfo(id, i)
				if playerReagentCount < reagentCount then
					reagent.Name:SetTextColor(0.5, 0.5, 0.5)
				else
					reagent.Name:SetTextColor(r, g, b)
				end
			else
				reagent.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end

	_G.CraftDetailScrollFrameScrollBar:SetShown(numReagents >= 5) -- Blizzard always shows it, its IsEnabled() == 0 check never matches
end

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

	_G.CraftRequirements:SetTextColor(1, 0.80, 0.10)

	_G.CraftExpandButtonFrame:StripTextures()

	local CraftCollapseAllButton = _G.CraftCollapseAllButton
	S:HandleCollapseTexture(CraftCollapseAllButton, nil, true)
	CraftCollapseAllButton:SetHighlightTexture(E.ClearTexture)

	for i = 1, _G.CRAFTS_DISPLAYED do
		local button = _G['Craft'..i]
		S:HandleCollapseTexture(button, nil, true)

		local normal = button:GetNormalTexture()
		normal:Size(14)
		normal:Point('LEFT', 4, 1)

		local highlight = button:GetHighlightTexture()
		highlight:SetTexture(E.ClearTexture)
		highlight.SetTexture = E.noop
	end

	for i = 1, _G.MAX_CRAFT_REAGENTS do
		local reagent = _G['CraftReagent'..i]
		S:HandleIcon(reagent.Icon, true)
		reagent.Icon:SetDrawLayer('ARTWORK')
		reagent.Count:SetDrawLayer('OVERLAY')
		reagent.NameFrame:SetAlpha(0)
	end

	_G.CraftReagent1:Point('TOPLEFT', _G.CraftReagentLabel, 'BOTTOMLEFT', -3, -3)
	_G.CraftReagent2:Point('LEFT', _G.CraftReagent1, 'RIGHT', 3, 0)
	_G.CraftReagent4:Point('LEFT', _G.CraftReagent3, 'RIGHT', 3, 0)
	_G.CraftReagent6:Point('LEFT', _G.CraftReagent5, 'RIGHT', 3, 0)
	_G.CraftReagent8:Point('LEFT', _G.CraftReagent7, 'RIGHT', 3, 0)

	local CraftIcon = _G.CraftIcon
	CraftIcon:Size(40)
	CraftIcon:Point('TOPLEFT', 2, -3)
	CraftIcon:CreateBackdrop()

	hooksecurefunc('CraftFrame_SetSelection', SetSelection)
end

S:AddCallbackForAddon('Blizzard_CraftUI', 'SkinCraft')
