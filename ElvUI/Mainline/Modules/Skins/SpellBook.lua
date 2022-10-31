local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, select = next, select
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local IsPassiveSpell = IsPassiveSpell

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION

local function clearBackdrop(self)
	self:SetBackdropColor(0, 0, 0, 1)
end

local function spellButtonHighlight(button, texture)
	if texture == [[Interface\Buttons\ButtonHilight-Square]] then
		button:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function UpdateButton()
	if _G.SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		return
	end

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		if button.backdrop then
			button.backdrop:SetShown(button.SpellName:IsShown())
		end

		local highlight = button.SpellHighlightTexture
		if highlight then
			if highlight:IsShown() then
				E:Flash(highlight, 1, true)
			else
				E:StopFlash(highlight)
			end
		end

		if E.private.skins.parchmentRemoverEnable then
			button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)
			button.RequiredLevelString:SetTextColor(0.6, 0.6, 0.6)

			local r = button.SpellName:GetTextColor()
			if r < 0.8 then
				button.SpellName:SetTextColor(0.6, 0.6, 0.6)
			elseif r ~= 1 then
				button.SpellName:SetTextColor(1, 1, 1)
			end
		end
	end
end

local function HandleSkillButton(button)
	if not button then return end
	button:SetCheckedTexture(E.media.normTex)
	button:GetCheckedTexture():SetColorTexture(1, 1, 1, .25)
	button:SetPushedTexture(E.media.normTex)
	button:GetPushedTexture():SetColorTexture(1, 1, 1, .5)
	button.IconTexture:SetInside()

	S:HandleIcon(button.IconTexture, true)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	local nameFrame = _G[button:GetName()..'NameFrame']
	if nameFrame then nameFrame:Hide() end
end

function S:SpellBookFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame)

	for _, frame in next, { _G.SpellBookSpellIconsFrame, _G.SpellBookSideTabsFrame, _G.SpellBookPageNavigationFrame } do
		frame:StripTextures()
	end

	if E.global.general.disableTutorialButtons then
		_G.SpellBookFrameTutorialButton:Kill()
	end

	if E.private.skins.parchmentRemoverEnable then
		_G.SpellBookPage1:SetAlpha(0)
		_G.SpellBookPage2:SetAlpha(0)
		_G.SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
	else
		local pagebackdrop = CreateFrame('Frame', nil, SpellBookFrame)
		pagebackdrop:SetTemplate()
		pagebackdrop:Point('TOPLEFT', _G.SpellBookPage1, 'TOPLEFT', -2, 2)
		pagebackdrop:Point('BOTTOMRIGHT', SpellBookFrame, 'BOTTOMRIGHT', -8, 4)
		SpellBookFrame.pagebackdrop = pagebackdrop

		for i = 1, 2 do
			local page = _G['SpellBookPage'..i]
			page:SetParent(pagebackdrop)
			page:SetDrawLayer('BACKGROUND', 3)
		end
	end

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton, nil, nil, true)
	S:HandleNextPrevButton(_G.SpellBookNextPageButton, nil, nil, true)

	_G.SpellBookPageText:ClearAllPoints()
	_G.SpellBookPageText:Point('RIGHT', _G.SpellBookPrevPageButton, 'LEFT', -5, 0)

	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local highlight =_G['SpellButton'..i..'Highlight']

		for _, region in next, { button:GetRegions() } do
			if region:IsObjectType('Texture') and (region ~= button.FlyoutArrow
			and region ~= button.GlyphIcon and region ~= button.GlyphActivate
			and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture) then
				region:SetTexture()
			end
		end

		E:RegisterCooldown(_G['SpellButton'..i..'Cooldown'])
		S:HandleIcon(icon)

		button:CreateBackdrop(nil, true)
		icon:SetInside(button.backdrop)

		local ht = button.SpellHighlightTexture
		if ht then
			ht:SetColorTexture(0.8, 0.8, 0, 0.6)
			ht:SetInside(button.backdrop)
		end

		if button.shine then
			button.shine:ClearAllPoints()
			button.shine:Point('TOPLEFT', button, 'TOPLEFT', -3, 3)
			button.shine:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 3, -3)
		end

		if E.private.skins.parchmentRemoverEnable then
			button:SetHighlightTexture(E.ClearTexture)
		end

		highlight:SetAllPoints(icon)
		hooksecurefunc(highlight, 'SetTexture', spellButtonHighlight)

		hooksecurefunc(button, 'UpdateButton', UpdateButton)
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)

	for i = 1, 8 do
		local tab = _G['SpellBookSkillLineTab'..i]
		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
	end

	hooksecurefunc('SpellBookFrame_UpdateSkillLineTabs', function()
		for i = 1, 8 do
			local tex = _G['SpellBookSkillLineTab'..i]:GetNormalTexture()
			if tex then
				S:HandleIcon(tex)
				tex:SetInside()
			end
		end
	end)

	--Profession Tab
	for _, button in next, { _G.PrimaryProfession1, _G.PrimaryProfession2, _G.SecondaryProfession1, _G.SecondaryProfession2, _G.SecondaryProfession3 } do
		button.missingHeader:SetTextColor(1, 1, 0)

		if E.private.skins.parchmentRemoverEnable then
			button.missingText:SetTextColor(1, 1, 1)
		else
			button.missingText:SetTextColor(0, 0, 0)
		end

		local a, b, c, _, e = button.statusBar:GetPoint()
		button.statusBar:Point(a, b, c, 0, e)
		button.statusBar.rankText:Point('CENTER')
		S:HandleStatusBar(button.statusBar, {0, .86, 0})

		if a == 'BOTTOMLEFT' then
			button.rank:Point('BOTTOMLEFT', button.statusBar, 'TOPLEFT', 0, 4)
		elseif a == 'TOPLEFT' then
			button.rank:Point('TOPLEFT', button.professionName, 'BOTTOMLEFT', 0, -20)
		end

		if button.unlearn then
			button.unlearn:Point('RIGHT', button.statusBar, 'LEFT', -18, -5)
		end

		if button.icon then
			S:HandleIcon(button.icon)

			button:StripTextures()
			button.professionName:Point('TOPLEFT', 100, -4)

			button:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			button.backdrop.Center:SetDrawLayer('BORDER', -1)
			button.backdrop:SetOutside(button.icon)
			button.backdrop:SetBackdropColor(0, 0, 0, 1)
			button.backdrop.callbackBackdropColor = clearBackdrop

			button.icon:SetDesaturated(false)
			button.icon:SetAlpha(1)
		end

		HandleSkillButton(button.SpellButton1)
		HandleSkillButton(button.SpellButton2)
	end

	for i = 1, 2 do
		local button = _G['PrimaryProfession'..i]
		S:HandleButton(button, true, nil, true)

		if button.iconTexture then
			S:HandleIcon(button.iconTexture, true)
		end
	end

	-- Some Texture Magic
	hooksecurefunc('FormatProfession', function(frame, id)
		if not (id and frame and frame.icon) then return end

		local texture = select(2, GetProfessionInfo(id))
		if texture then frame.icon:SetTexture(texture) end
	end)

	hooksecurefunc('UpdateProfessionButton', function(button)
		local spellIndex = button:GetID() + button:GetParent().spellOffset
		local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType)
		if isPassive then
			button.highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			button.highlightTexture:SetColorTexture(1, 1, 1, .25)
		end

		if E.private.skins.parchmentRemoverEnable then
			if button.spellString then
				button.spellString:SetTextColor(1, 1, 1)
			end
			if button.subSpellString then
				button.subSpellString:SetTextColor(1, 1, 1)
			end
			if button.SpellName then
				button.SpellName:SetTextColor(1, 1, 1)
			end
			if button.SpellSubName then
				button.SpellSubName:SetTextColor(1, 1, 1)
			end
		end
	end)

	-- Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G['SpellBookFrameTabButton'..i])
	end

	-- Reposition Tabs
	hooksecurefunc('SpellBookFrame_Update', function()
		local tab = _G.SpellBookFrameTabButton1
		local index, lastTab = 1, tab
		while tab do
			tab:ClearAllPoints()

			if index == 1 then
				tab:Point('TOPLEFT', _G.SpellBookFrame, 'BOTTOMLEFT', -3, 0)
			else
				tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
				lastTab = tab
			end

			index = index + 1
			tab = _G['SpellBookFrameTabButton'..index]
		end
	end)
end

S:AddCallback('SpellBookFrame')
