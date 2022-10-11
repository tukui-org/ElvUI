local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, select = pairs, select
local CreateFrame = CreateFrame
local GetProfessionInfo = GetProfessionInfo
local IsPassiveSpell = IsPassiveSpell
local hooksecurefunc = hooksecurefunc
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

		local ht = button.SpellHighlightTexture
		if ht and ht:IsShown() then
			E:Flash(ht, 1, true)
		elseif ht then
			E:StopFlash(ht)
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
	button:SetPushedTexture(E.media.normTex)
	button.IconTexture:SetInside()

	S:HandleIcon(button.IconTexture)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	local nameFrame = _G[button:GetName().."NameFrame"]
	if nameFrame then nameFrame:Hide() end
end

function S:SpellBookFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	local SpellBookFrame = _G.SpellBookFrame
	S:HandlePortraitFrame(SpellBookFrame)

	for _, object in pairs({ 'SpellBookSpellIconsFrame', 'SpellBookSideTabsFrame', 'SpellBookPageNavigationFrame' }) do
		_G[object]:StripTextures()
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
			_G['SpellBookPage'..i]:SetParent(pagebackdrop)
			_G['SpellBookPage'..i]:SetDrawLayer('BACKGROUND', 3)
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

		for j = 1, button:GetNumRegions() do
			local region = select(j, button:GetRegions())
			if region:IsObjectType('Texture') then
				if region ~= button.FlyoutArrow and region ~= button.GlyphIcon and region ~= button.GlyphActivate
					and region ~= button.AbilityHighlight and region ~= button.SpellHighlightTexture then
					region:SetTexture()
				end
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
			button:SetHighlightTexture('')
		end

		highlight:SetAllPoints(icon)
		hooksecurefunc(highlight, 'SetTexture', spellButtonHighlight)

		hooksecurefunc(button, 'UpdateButton', UpdateButton)
	end

	_G.SpellBookSkillLineTab1:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)

	for i = 1, 8 do
		local Tab = _G['SpellBookSkillLineTab'..i]
		Tab:StripTextures()
		Tab:SetTemplate()
		Tab:StyleButton(nil, true)
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
	local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3"}
	for i, button in pairs(professions) do
		local bu = _G[button]
		bu.missingHeader:SetTextColor(1, 1, 0)

		if E.private.skins.parchmentRemoverEnable then
			bu.missingText:SetTextColor(1, 1, 1)
		else
			bu.missingText:SetTextColor(0, 0, 0)
		end

		local a, b, c, _, e = bu.statusBar:GetPoint()
		bu.statusBar:Point(a, b, c, 0, e)
		bu.statusBar.rankText:Point('CENTER')
		S:HandleStatusBar(bu.statusBar, {0, .86, 0})

		if a == 'BOTTOMLEFT' then
			bu.rank:Point('BOTTOMLEFT', bu.statusBar, 'TOPLEFT', 0, 4)
		elseif a == 'TOPLEFT' then
			bu.rank:Point('TOPLEFT', bu.professionName, 'BOTTOMLEFT', 0, -20)
		end

		if bu.unlearn then
			bu.unlearn:Point('RIGHT', bu.statusBar, 'LEFT', -18, -5)
		end

		if bu.icon then
			S:HandleIcon(bu.icon)

			bu:StripTextures()
			bu.professionName:Point('TOPLEFT', 100, -4)

			bu:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			bu.backdrop.Center:SetDrawLayer('BORDER', -1)
			bu.backdrop:SetOutside(bu.icon)
			bu.backdrop:SetBackdropColor(0, 0, 0, 1)
			bu.backdrop.callbackBackdropColor = clearBackdrop

			bu.icon:SetDesaturated(false)
			bu.icon:SetAlpha(1)
		end

		HandleSkillButton(bu.SpellButton1)
		HandleSkillButton(bu.SpellButton2)
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


	hooksecurefunc('UpdateProfessionButton', function(self)
		local spellIndex = self:GetID() + self:GetParent().spellOffset
		local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType)
		if isPassive then
			self.highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			self.highlightTexture:SetColorTexture(1, 1, 1, .25)
		end

		if E.private.skins.parchmentRemoverEnable then
			if self.spellString then
				self.spellString:SetTextColor(1, 1, 1)
			end
			if self.subSpellString then
				self.subSpellString:SetTextColor(1, 1, 1)
			end
			if self.SpellName then
				self.SpellName:SetTextColor(1, 1, 1)
			end
			if self.SpellSubName then
				self.SpellSubName:SetTextColor(1, 1, 1)
			end
		end
	end)

	--Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G['SpellBookFrameTabButton'..i])
	end

	_G.SpellBookFrameTabButton1:ClearAllPoints()
	_G.SpellBookFrameTabButton1:Point('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', 0, 2)

end

S:AddCallback('SpellBookFrame')
