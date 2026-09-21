local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local IsPassiveSpell = IsPassiveSpell
local SpellBook_GetWhatChangedItem = SpellBook_GetWhatChangedItem

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 1)
end

local function SpellButtonHighlight(texture, path)
	if path == [[Interface\Buttons\ButtonHilight-Square]] then
		texture:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function UpdateButton(button)
	if _G.SpellBookFrame.bookType == _G.BOOKTYPE_PROFESSION then
		return
	end

	button.backdrop:SetShown(button.SpellName:IsShown())

	if E.private.skins.parchmentRemoverEnable then
		button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)
		button.RequiredLevelString:SetTextColor(0.6, 0.6, 0.6)

		local r = button.SpellName:GetTextColor()
		if r < 0.8 then
			button.SpellName:SetTextColor(0.8, 0.8, 0.8)
		elseif r ~= 1 then
			button.SpellName:SetTextColor(1, 1, 1)
		end
	end
end

local function HandleSkillButton(button)
	button:SetCheckedTexture(E.media.normTex)
	button:SetPushedTexture(E.media.normTex)

	local checked = button:GetCheckedTexture()
	checked:SetColorTexture(1, 1, 1, .25)

	local pushed = button:GetPushedTexture()
	pushed:SetColorTexture(1, 1, 1, .5)

	E:RegisterCooldown(button.cooldown)

	button.IconTexture:SetInside()
	S:HandleIcon(button.IconTexture, true)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	local nameFrame = _G[button:GetName()..'NameFrame']
	nameFrame:Hide()
end

local function ProfessionButtonUpdate(button)
	local parent = button:GetParent()
	if not parent.spellOffset then return end

	local spellIndex = button:GetID() + parent.spellOffset
	local isPassive = IsPassiveSpell(spellIndex, _G.SpellBookFrame.bookType)
	button.highlightTexture:SetColorTexture(1, 1, 1, isPassive and 0 or 0.25)

	if E.private.skins.parchmentRemoverEnable then
		button.spellString:SetTextColor(1, 1, 1)
		button.subSpellString:SetTextColor(1, 1, 1)
	end
end

local function UpdateCoreAbilitiesTab()
	local SpellBookCoreAbilitiesFrame = _G.SpellBookCoreAbilitiesFrame
	for _, button in next, SpellBookCoreAbilitiesFrame.Abilities do
		if not button.IsSkinned then
			button:CreateBackdrop()
			button.backdrop:SetAllPoints()
			button:StyleButton()

			button.EmptySlot:SetAlpha(0)
			button.ActiveTexture:SetAlpha(0)
			button.FutureTexture:SetAlpha(0)

			button.iconTexture:SetTexCoords()
			button.iconTexture:SetInside()

			button.Name:Point('TOPLEFT', 50, 0)

			button.highlightTexture:SetInside()
			hooksecurefunc(button.highlightTexture, 'SetTexture', SpellButtonHighlight)

			button.IsSkinned = true
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

	for i, tab in next, SpellBookCoreAbilitiesFrame.SpecTabs do
		if not tab.IsSkinned then
			local background = tab:GetRegions()
			background:Hide()

			tab:SetTemplate()
			tab:StyleButton(nil, true)

			if i == 1 then
				tab:Point('TOPLEFT', _G.SpellBookFrame, 'TOPRIGHT', E.PixelMode and -1 or 1, -75)
			end

			local normal = tab:GetNormalTexture()
			normal:SetInside()
			normal:SetTexCoords()

			tab.IsSkinned = true
		end
	end
end

local function UpdateWhatHasChangedTab()
	for _, frame in next, _G.SpellBookWhatHasChanged.ChangedItems do
		local _, _, _, _, mainText = frame:GetRegions()
		if mainText and mainText.SetVertexColor then
			if E.private.skins.parchmentRemoverEnable then
				mainText:SetVertexColor(1, 1, 1)
			else
				mainText:SetVertexColor(0, 0, 0)
			end
		end
	end
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
			if region:IsObjectType('Texture') and region ~= button.Arrow then
				region:SetTexture()
			end
		end

		E:RegisterCooldown(button.cooldown)
		S:HandleIcon(button.IconTexture)

		button:CreateBackdrop(nil, true)
		button.IconTexture:SetInside(button.backdrop)

		if E.private.skins.parchmentRemoverEnable then
			button:SetHighlightTexture(E.ClearTexture)
		end

		highlight:SetAllPoints(button.IconTexture)
		hooksecurefunc(highlight, 'SetTexture', SpellButtonHighlight)
		hooksecurefunc(button, 'UpdateButton', UpdateButton)
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and -1 or E.Border + E.Spacing, -36)

	-- Skill tabs on the right side
	for i = 1, 8 do
		local tab = _G['SpellBookSkillLineTab'..i]
		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)

		local normal = tab:GetNormalTexture()
		S:HandleIcon(normal)
		normal:SetInside()
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

		if button.icon then -- primary professions only
			S:HandleIcon(button.icon)

			button:StripTextures()
			button.professionName:Point('TOPLEFT', 100, -4)

			button:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			button.backdrop.Center:SetDrawLayer('BORDER', -1)
			button.backdrop:SetOutside(button.icon)
			button.backdrop:SetBackdropColor(0, 0, 0, 1)
			button.backdrop.callbackBackdropColor = ClearBackdrop

			button.icon:SetDesaturated(false)
			button.icon:SetAlpha(1)
		end

		HandleSkillButton(button.SpellButton1)
		HandleSkillButton(button.SpellButton2)
	end

	hooksecurefunc('UpdateProfessionButton', ProfessionButtonUpdate)

	-- Core Abilities Frame
	local SpellBookCoreAbilitiesFrame = _G.SpellBookCoreAbilitiesFrame
	SpellBookCoreAbilitiesFrame:Point('TOPLEFT', -80, 5)

	local classTextColor = E.myClassColor
	SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookCoreAbilitiesFrame.SpecName:Point('TOP', 37, -30)

	hooksecurefunc('SpellBook_UpdateCoreAbilitiesTab', UpdateCoreAbilitiesTab)

	-- What Has Changed Frame
	local SpellBookWhatHasChanged = _G.SpellBookWhatHasChanged
	SpellBookWhatHasChanged:Point('TOPLEFT', -80, 5)
	SpellBookWhatHasChanged.ClassName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookWhatHasChanged.ClassName:Point('TOP', 37, -30)

	hooksecurefunc('SpellBook_UpdateWhatHasChangedTab', UpdateWhatHasChangedTab)

	local changedList = _G.WHAT_HAS_CHANGED_DISPLAY[E.myclass]
	for i = 1, #changedList do
		local frame = SpellBook_GetWhatChangedItem(i)
		frame:StripTextures()
		frame.Number:SetTextColor(1, 1, 1)
		frame.Number:Point('TOPLEFT', -15, 16)
		frame.Title:SetTextColor(1, 1, 1)
	end

	-- Bottom Tabs
	local LastSpellTab = _G.SpellBookFrameTabButton1
	for i = 1, 5 do
		local tab = _G['SpellBookFrameTabButton'..i]
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if i == 1 then
			tab:Point('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', -10, 0)
		else
			tab:Point('TOPLEFT', LastSpellTab, 'TOPRIGHT', -19, 0)
		end

		LastSpellTab = tab
	end
end

S:AddCallback('SpellBookFrame')
