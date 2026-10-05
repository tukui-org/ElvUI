local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo
local IsPassiveSpell = IsPassiveSpell
local SpellBookSpellBank = Enum.SpellBookSpellBank
local SpellBook_GetWhatChangedItem = SpellBook_GetWhatChangedItem

local barColor = { 0, .86, 0 }

-- the Retail spellbook is skinned in PlayerSpells.lua
if E.Retail then
	S:AddCallbackForAddon('Blizzard_ProfessionsBook', nil, nil, nil, nil, nil, 'spellbook')
else
	S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'SpellBookFrame', nil, nil, nil, nil, 'spellbook')
end

local function ClearBackdrop(backdrop)
	backdrop:SetBackdropColor(0, 0, 0, 1)
end

local function FormatProfessionHook(frame, id)
	if not (id and frame and frame.icon) then return end

	local _, texture = GetProfessionInfo(id)
	if texture then
		frame.icon:SetTexture(texture)
	end
end

local function ProfessionButtonUpdate(button)
	local parent = button:GetParent()
	if not parent or not parent.spellOffset then return end

	local spellIndex = button:GetID() + parent.spellOffset

	local isPassive
	if E.Retail then
		local spellBookItemInfo = GetSpellBookItemInfo(spellIndex, SpellBookSpellBank.Player)
		isPassive = spellBookItemInfo and spellBookItemInfo.isPassive
	else
		isPassive = IsPassiveSpell(spellIndex, _G.SpellBookFrame.bookType)
	end

	if isPassive then
		button.highlightTexture:SetColorTexture(1, 1, 1, 0)
	else
		button.highlightTexture:SetColorTexture(1, 1, 1, .25)
	end

	-- Mists shows these on the spellbook pages, which are never stripped
	if E.Retail and E.private.skins.parchmentRemoverEnable then
		button.spellString:SetTextColor(1, 1, 1)
		button.subSpellString:SetTextColor(1, 1, 1)
	end
end

local function ProfessionsUpdateButtons(frame)
	ProfessionButtonUpdate(frame.SpellButton1)
	ProfessionButtonUpdate(frame.SpellButton2)
end

local function ProfessionsBookFrameUpdate()
	ProfessionsUpdateButtons(_G.PrimaryProfession1)
	ProfessionsUpdateButtons(_G.PrimaryProfession2)
	ProfessionsUpdateButtons(_G.SecondaryProfession1)
	ProfessionsUpdateButtons(_G.SecondaryProfession2)
	ProfessionsUpdateButtons(_G.SecondaryProfession3)
end

local function HandleSkillButton(button)
	button:SetCheckedTexture(E.media.normTex)
	button:GetCheckedTexture():SetColorTexture(1, 1, 1, .25)
	button:SetPushedTexture(E.media.normTex)
	button:GetPushedTexture():SetColorTexture(1, 1, 1, .5)
	button.IconTexture:SetInside()

	E:RegisterCooldown(button.cooldown)

	S:HandleIcon(button.IconTexture, true)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	_G[button:GetName()..'NameFrame']:Hide()
end

local function SkinProfessions()
	for _, button in next, { _G.PrimaryProfession1, _G.PrimaryProfession2, _G.SecondaryProfession1, _G.SecondaryProfession2, _G.SecondaryProfession3, E.Mists and _G.SecondaryProfession4 or nil } do
		button.missingHeader:SetTextColor(1, 1, 0)

		-- Mists shows this on the spellbook pages, which are never stripped
		if E.Retail then
			button.missingText:SetTextColor(1, 1, 1)
		else
			button.missingText:SetTextColor(0, 0, 0)
		end

		local a, b, c, _, e = button.statusBar:GetPoint()
		button.statusBar:Point(a, b, c, 0, e)
		button.statusBar.rankText:Point('CENTER')
		S:HandleStatusBar(button.statusBar, barColor)

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

		if button.CircleMask then
			button.CircleMask:Hide()
		end

		HandleSkillButton(button.SpellButton1)
		HandleSkillButton(button.SpellButton2)
	end

	for i = 1, 2 do
		S:HandleButton(_G['PrimaryProfession'..i], true, nil, true)
	end

	hooksecurefunc('FormatProfession', FormatProfessionHook)

	if E.Retail then
		hooksecurefunc('ProfessionsBookFrame_Update', ProfessionsBookFrameUpdate)
	else
		hooksecurefunc('UpdateProfessionButton', ProfessionButtonUpdate)
	end
end

local function SpellButtonHighlight(texture, path)
	if path == [[Interface\Buttons\ButtonHilight-Square]] then
		texture:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function SpellButtonUpdate(button)
	if _G.SpellBookFrame.bookType == _G.BOOKTYPE_PROFESSION then
		return
	end

	button.backdrop:SetShown(button.SpellName:IsShown())
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
			mainText:SetVertexColor(0, 0, 0)
		end
	end
end

local function SkinMistsSpellBook()
	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame)

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
		hooksecurefunc(button, 'UpdateButton', SpellButtonUpdate)
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
	SkinProfessions()

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

local function SpellHighlightSetTexture(texture, path)
	if path == [[Interface\Buttons\ButtonHilight-Square]] or path == [[Interface\Buttons\UI-PassiveHighlight]] then
		texture:SetColorTexture(1, 1, 1, 0.3)
	end
end

local function ClassicSpellButtonUpdate(button)
	button.backdrop:SetShown(button.SpellName:IsShown())

	local highlight = button:GetHighlightTexture()
	if highlight:IsShown() then
		E:Flash(highlight, 1, true)
	else
		E:StopFlash(highlight, 1)
	end

	button.SpellSubName:SetTextColor(0.6, 0.6, 0.6)

	local r = button.SpellName:GetTextColor()
	if r < 0.8 then
		button.SpellName:SetTextColor(0.8, 0.8, 0.8)
	elseif r ~= 1 then
		button.SpellName:SetTextColor(1, 1, 1)
	end
end

local function SkinClassicSpellBook()
	S:HandleFrame(_G.SpellBookFrame, true, nil, 11, -12, -32, 76)

	local showAllRanks = _G.ShowAllSpellRanksCheckbox
	S:HandleCheckBox(showAllRanks)
	showAllRanks:Point('TOPLEFT', 20, -20)

	_G.SpellBookTitleText:Point('TOP', -10, -17)
	_G.SpellBookTitleText:SetTextColor(1, 1, 1)

	_G.SpellBookPageText:SetTextColor(1, 1, 1)
	_G.SpellBookPageText:Point('BOTTOM', -10, 87)

	S:HandleNextPrevButton(_G.SpellBookPrevPageButton)
	_G.SpellBookPrevPageButton:Point('BOTTOMRIGHT', _G.SpellBookFrame, 'BOTTOMRIGHT', -73, 87)
	_G.SpellBookPrevPageButton:Size(24)

	S:HandleNextPrevButton(_G.SpellBookNextPageButton)
	_G.SpellBookNextPageButton:Point('TOPLEFT', _G.SpellBookPrevPageButton, 'TOPLEFT', 30, 0)
	_G.SpellBookNextPageButton:Size(24)

	S:HandleCloseButton(_G.SpellBookCloseButton, _G.SpellBookFrame.backdrop)

	for i = 1, 3 do -- frame tabs, only spell and pet are ever shown
		local tab = _G['SpellBookFrameTabButton'..i]

		tab:GetNormalTexture():SetTexture(nil)
		tab:GetDisabledTexture():SetTexture(nil)

		S:HandleTab(tab)

		tab.backdrop:Point('TOPLEFT', 14, -14)
		tab.backdrop:Point('BOTTOMRIGHT', -14, 22)
	end

	-- Reposition Tabs
	_G.SpellBookFrameTabButton1:ClearAllPoints()
	_G.SpellBookFrameTabButton1:Point('TOPLEFT', _G.SpellBookFrame, 'BOTTOMLEFT', -3, 89)
	_G.SpellBookFrameTabButton2:Point('TOPLEFT', _G.SpellBookFrameTabButton1, 'TOPRIGHT', -27, 0)
	_G.SpellBookFrameTabButton3:Point('TOPLEFT', _G.SpellBookFrameTabButton2, 'TOPRIGHT', -27, 0)

	-- Spell Buttons
	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G['SpellButton'..i]
		local icon = _G['SpellButton'..i..'IconTexture']
		local cooldown = _G['SpellButton'..i..'Cooldown']
		local highlight = _G['SpellButton'..i..'Highlight']

		for _, region in next, { button:GetRegions() } do
			if region:IsObjectType('Texture') and region ~= button.Arrow then
				region:SetTexture(nil)
			end
		end

		E:RegisterCooldown(cooldown)
		S:HandleIcon(icon)

		button:CreateBackdrop(nil, true)
		icon:SetInside(button.backdrop)

		button.bg = CreateFrame('Frame', nil, button)
		button.bg:SetTemplate('Transparent')
		button.bg:Point('TOPLEFT', -6, 6)
		button.bg:Point('BOTTOMRIGHT', 112, -6)
		button.bg:Height(46)
		button.bg:OffsetFrameLevel(-1, button)

		highlight:SetAllPoints()
		hooksecurefunc(highlight, 'SetTexture', SpellHighlightSetTexture)
		hooksecurefunc(button, 'UpdateButton', ClassicSpellButtonUpdate)
	end

	_G.SpellButton1:PointXY(28, -55)

	-- evens
	for i = 2, _G.SPELLS_PER_PAGE, 2 do
		_G['SpellButton'..i]:PointXY(163, 0)
	end
	-- odds
	for i = 3, _G.SPELLS_PER_PAGE, 2 do
		_G['SpellButton'..i]:PointXY(0, -20)
	end

	for i = 1, _G.MAX_SKILLLINE_TABS do
		local tab = _G['SpellBookSkillLineTab'..i]
		tab:StripTextures()
		tab:SetTemplate(nil, true)
		tab:StyleButton(nil, true)

		local normalTexture = tab:GetNormalTexture()
		normalTexture:SetInside()
		normalTexture:SetTexCoords()

		_G['SpellBookSkillLineTab'..i..'Flash']:Kill()
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', _G.SpellBookSideTabsFrame, 'TOPRIGHT', -31, -70)
end

function S:Blizzard_ProfessionsBook()
	local ProfessionsBookFrame = _G.ProfessionsBookFrame
	S:HandleFrame(ProfessionsBookFrame)

	if E.global.general.disableTutorialButtons then
		_G.ProfessionsBookFrameTutorialButton:Kill()
	else
		_G.ProfessionsBookFrameTutorialButton.Ring:Hide()
	end

	--Profession Tab
	SkinProfessions()
end

function S:SpellBookFrame()
	if E.Mists then
		SkinMistsSpellBook()
	else
		SkinClassicSpellBook()
	end
end
