local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local next, select = next, select
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local IsPassiveSpell = IsPassiveSpell
local SpellBook_GetWhatChangedItem = SpellBook_GetWhatChangedItem

local function clearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 1)
end

local function spellButtonHighlight(button, texture)
	if texture == [[Interface\Buttons\ButtonHilight-Square]] then
		button:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function UpdateButton()
	if _G.SpellBookFrame.bookType == _G.BOOKTYPE_PROFESSION then
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
				E:StopFlash(highlight, 1)
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

	if button.cooldown then
		E:RegisterCooldown(button.cooldown)
	end

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
		local highlight = _G['SpellButton'..i..'Highlight']

		for _, region in next, { button:GetRegions() } do
			if region:IsObjectType('Texture') and (region ~= button.FlyoutArrow
			and region ~= button.GlyphIcon and region ~= button.GlyphActivate
			and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture) then
				region:SetTexture()
			end
		end

		E:RegisterCooldown(button.cooldown)
		S:HandleIcon(button.IconTexture)

		button:CreateBackdrop(nil, true)
		button.IconTexture:SetInside(button.backdrop)

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

		highlight:SetAllPoints(button.IconTexture)
		hooksecurefunc(highlight, 'SetTexture', spellButtonHighlight)

		hooksecurefunc(button, 'UpdateButton', UpdateButton)
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and -1 or E.Border + E.Spacing, -36)

	for i = 1, 8 do
		local tab = _G['SpellBookSkillLineTab'..i]
		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
	end

	-- Skill tabs on the right side
	for i = 1, 8 do
		local tex = _G['SpellBookSkillLineTab'..i]:GetNormalTexture()
		if tex then
			S:HandleIcon(tex)
			tex:SetInside()
		end
	end

	-- Profession Tab
	for _, button in next, { _G.PrimaryProfession1, _G.PrimaryProfession2, _G.SecondaryProfession1, _G.SecondaryProfession2, _G.SecondaryProfession3, _G.SecondaryProfession4 } do
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

	-- Core Abilities Frame
	local SpellBookCoreAbilitiesFrame = _G.SpellBookCoreAbilitiesFrame
	SpellBookCoreAbilitiesFrame:Point('TOPLEFT', -80, 5)

	local classTextColor = E:ClassColor(E.myclass)
	SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookCoreAbilitiesFrame.SpecName:Point('TOP', 37, -30)

	hooksecurefunc('SpellBook_UpdateCoreAbilitiesTab', function()
		local buttons = SpellBookCoreAbilitiesFrame.Abilities
		for i = 1, #buttons do
			local button = buttons[i]
			if not button then return end

			if not button.isSkinned then
				button:CreateBackdrop()
				button.backdrop:SetAllPoints()
				button:StyleButton()

				button.EmptySlot:SetAlpha(0)
				button.ActiveTexture:SetAlpha(0)
				button.FutureTexture:SetAlpha(0)

				button.iconTexture:SetTexCoord(unpack(E.TexCoords))
				button.iconTexture:SetInside()

				button.Name:Point('TOPLEFT', 50, 0)

				if button.highlightTexture then
					hooksecurefunc(button.highlightTexture, 'SetTexture', function(_, texOrR)
						if texOrR == [[Interface\Buttons\ButtonHilight-Square]] then
							button.highlightTexture:SetTexture(1, 1, 1, 0.3)
							button.highlightTexture:SetInside()
						end
					end)
				end

				button.isSkinned = true
			end

			if button.FutureTexture:IsShown() then
				button.iconTexture:SetDesaturated(true)

				button.Name:SetTextColor(0.6, 0.6, 0.6)
				button.InfoText:SetTextColor(0.6, 0.6, 0.6)
				button.RequiredLevel:SetTextColor(0.6, 0.6, 0.6)
			else
				button.iconTexture:SetDesaturated(false)

				button.Name:SetTextColor(1, 0.80, 0.10)
				button.InfoText:SetTextColor(1, 1, 1)
				button.RequiredLevel:SetTextColor(0.8, 0.8, 0.8)
			end
		end

		local tabs = SpellBookCoreAbilitiesFrame.SpecTabs
		for i = 1, #tabs do
			local tab = tabs[i]

			if tab and not tab.isSkinned then
				tab:GetRegions():Hide()
				tab:SetTemplate()
				tab:StyleButton(nil, true)

				if i == 1 then
					tab:Point('TOPLEFT', SpellBookFrame, 'TOPRIGHT', E.PixelMode and -1 or 1, -75)
				end

				local normal = tab:GetNormalTexture()
				normal:SetInside()
				normal:SetTexCoord(unpack(E.TexCoords))

				tab.isSkinned = true
			end
		end
	end)

	-- What Has Changed Frame
	local SpellBookWhatHasChanged = _G.SpellBookWhatHasChanged
	SpellBookWhatHasChanged:Point('TOPLEFT', -80, 5)
	SpellBookWhatHasChanged.ClassName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookWhatHasChanged.ClassName:Point('TOP', 37, -30)

	hooksecurefunc('SpellBook_UpdateWhatHasChangedTab', function()
		if not SpellBookWhatHasChanged.ChangedItems then return end

		local index = 1
		local frame = SpellBookWhatHasChanged.ChangedItems[index]
		while frame do
			local mainText = select(5, frame:GetRegions())
			if mainText and mainText.SetVertexColor then
				if E.private.skins.parchmentRemoverEnable then
					mainText:SetVertexColor(1, 1, 1)
				else
					mainText:SetVertexColor(0, 0, 0)
				end
			end

			index = index + 1
			frame = SpellBookWhatHasChanged.ChangedItems[index]
		end
	end)

	local changedList = _G.WHAT_HAS_CHANGED_DISPLAY[E.myclass]
	if changedList then
		for i = 1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i)
			if frame then
				frame:StripTextures()
				frame.Number:SetTextColor(1, 1, 1)
				frame.Number:Point('TOPLEFT', -15, 16)
				frame.Title:SetTextColor(1, 1, 1)
			end
		end
	end

	-- Some Texture Magic
	hooksecurefunc('FormatProfession', function(frame, id)
		if not (id and frame and frame.icon) then return end

		local texture = select(2, GetProfessionInfo(id))
		if texture then frame.icon:SetTexture(texture) end
	end)

	hooksecurefunc('UpdateProfessionButton', function(button)
		local parent = button:GetParent()
		if not parent or not parent.spellOffset then return end

		local spellIndex = button:GetID() + parent.spellOffset
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
	local tab = _G.SpellBookFrameTabButton1
	local index, lastTab = 1, tab
	while tab do
		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('TOPLEFT', _G.SpellBookFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -19, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['SpellBookFrameTabButton'..index]
	end
end

S:AddCallback('SpellBookFrame')
