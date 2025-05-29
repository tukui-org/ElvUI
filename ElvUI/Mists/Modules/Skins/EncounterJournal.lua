local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local select = select
local next = next
local rad = rad

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function HandleButton(btn, strip, ...)
	S:HandleButton(btn, strip, ...)

	local str = btn:GetFontString()
	if str then
		str:SetTextColor(1, 1, 1)
	end
end

local SkinOverviewInfo
do -- this prevents a taint trying to force a color lock by setting it to E.noop
	local LockColors = {}
	local function LockValue(button, r, g, b)
		local rr, gg, bb = unpack(E.media.rgbvaluecolor)
		if r ~= rr or gg ~= g or b ~= bb then
			button:SetTextColor(rr, gg, bb)
		end
	end

	local function LockWhite(button, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			button:SetTextColor(1, 1, 1)
		end
	end

	local function LockColor(button, valuecolor)
		if LockColors[button] then return end

		hooksecurefunc(button, 'SetTextColor', (valuecolor and LockValue) or LockWhite)

		LockColors[button] = true
	end

	SkinOverviewInfo = function(frame, _, index)
		local header = frame.overviews[index]
		if not header.IsSkinned then
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture()
			end

			HandleButton(header.button)

			LockColor(header.button.title, true)
			LockColor(header.button.expandedIcon)

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			header.description:SetTextColor(1, 1, 1)

			header.IsSkinned = true
		end
	end
end

local function SkinOverviewInfoBullets(object)
	local parent = object:GetParent()

	if parent.Bullets then
		for _, bullet in next, parent.Bullets do
			if not bullet.IsSkinned then
				bullet.Text:SetTextColor('P', 1, 1, 1)
				bullet.IsSkinned = true
			end
		end
	end
end

local function SkinAbilitiesInfo()
	local index = 1
	local header = _G['EncounterJournalInfoHeader'..index]
	while header do
		if not header.IsSkinned then
			header.flashAnim.Play = E.noop

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture()
			end

			header.description:SetTextColor(1, 1, 1)
			header.button.title:SetTextColor(unpack(E.media.rgbvaluecolor))
			header.button.title.SetTextColor = E.noop
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = E.noop

			HandleButton(header.button)

			header.button.bg = CreateFrame('Frame', nil, header.button)
			header.button.bg:SetTemplate()
			header.button.bg:SetOutside(header.button.abilityIcon)
			header.button.bg:OffsetFrameLevel(-1)
			header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)

			header.IsSkinned = true
		end

		if header.button.abilityIcon:IsShown() then
			header.button.bg:Show()
		else
			header.button.bg:Hide()
		end

		index = index + 1
		header = _G['EncounterJournalInfoHeader'..index]
	end
end

local function InstanceSelectScrollUpdateChild(child)
	if not child.IsSkinned then
		child:SetNormalTexture(E.ClearTexture)
		child:SetHighlightTexture(E.ClearTexture)
		child:SetPushedTexture(E.ClearTexture)

		local bgImage = child.bgImage
		if bgImage then
			bgImage:CreateBackdrop()
			bgImage.backdrop:Point('TOPLEFT', 3, -3)
			bgImage.backdrop:Point('BOTTOMRIGHT', -4, 2)
		end

		child.IsSkinned = true
	end
end

local function InstanceSelectScrollUpdate(frame)
	frame:ForEachFrame(InstanceSelectScrollUpdateChild)
end

local function BossesScrollUpdateChild(child)
	if not child.IsSkinned then
		S:HandleButton(child)

		local hl = child:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		child.text:SetTextColor(1, 1, 1)
		child.text.SetTextColor = E.noop
		child.creature:Point('TOPLEFT', 0, -4)

		child.IsSkinned = true
	end
end

local function BossesScrollUpdate(frame)
	frame:ForEachFrame(BossesScrollUpdateChild)
end

local function LootContainerUpdateChild(child)
	if not child.IsSkinned then
		if child.bossTexture then child.bossTexture:SetAlpha(0) end
		if child.bosslessTexture then child.bosslessTexture:SetAlpha(0) end

		if child.name and child.icon then
			child.icon:SetSize(32, 32)
			child.icon:Point('TOPLEFT', E.PixelMode and 3 or 4, -(E.PixelMode and 7 or 8))
			S:HandleIcon(child.icon, true)
			S:HandleIconBorder(child.IconBorder, child.icon.backdrop)

			child.name:ClearAllPoints()
			child.name:Point('TOPLEFT', child.icon, 'TOPRIGHT', 6, -2)

			-- we only want this when name and icon both exist
			if not child.backdrop then
				child:CreateBackdrop('Transparent')
				child.backdrop:Point('TOPLEFT')
				child.backdrop:Point('BOTTOMRIGHT', 0, 1)
			end
		end

		if child.boss then
			child.boss:ClearAllPoints()
			child.boss:Point('BOTTOMLEFT', 4, 6)
			child.boss:SetTextColor(1, 1, 1)
		end

		if child.slot then
			child.slot:ClearAllPoints()
			child.slot:Point('TOPLEFT', child.name, 'BOTTOMLEFT', 0, -3)
			child.slot:SetTextColor(1, 1, 1)
		end

		if child.armorType then
			child.armorType:ClearAllPoints()
			child.armorType:Point('RIGHT', child, 'RIGHT', -10, 0)
			child.armorType:SetTextColor(1, 1, 1)
		end

		child.IsSkinned = true
	end
end

local function LootContainerUpdate(frame)
	frame:ForEachFrame(LootContainerUpdateChild)
end

local function LoreScrollingFontChild(child)
	if child.FontString then
		child.FontString:SetTextColor(1, 1, 1)
	end
end

function S:Blizzard_EncounterJournal()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.encounterjournal) then return end

	local EJ = _G.EncounterJournal
	S:HandlePortraitFrame(EJ)

	EJ.navBar:StripTextures(true)
	EJ.navBar.overlay:StripTextures(true)

	EJ.navBar:CreateBackdrop()
	EJ.navBar.backdrop:Point('TOPLEFT', -2, 0)
	EJ.navBar.backdrop:Point('BOTTOMRIGHT')
	HandleButton(EJ.navBar.home, true)

	S:HandleEditBox(EJ.searchBox)
	EJ.searchBox:ClearAllPoints()
	EJ.searchBox:Point('TOPLEFT', EJ.navBar, 'TOPRIGHT', 4, 0)

	local InstanceSelect = EJ.instanceSelect
	InstanceSelect.bg:Kill()

	S:HandleDropDownBox(InstanceSelect.ExpansionDropdown)
	S:HandleDropDownBox(_G.EncounterJournalEncounterFrameInfo.LootContainer.filter, 100)
	S:HandleDropDownBox(_G.EncounterJournalEncounterFrameInfo.LootContainer.slotFilter, 100)
	S:HandleDropDownBox(_G.EncounterJournalEncounterFrameInfoDifficulty, 110)
	S:HandleTrimScrollBar(InstanceSelect.ScrollBar)

	-- Bottom tabs
	for _, tab in next, {
		_G.EncounterJournalDungeonTab,
		_G.EncounterJournalRaidTab,
	} do
		S:HandleTab(tab)
	end

	_G.EncounterJournalDungeonTab:ClearAllPoints()
	_G.EncounterJournalDungeonTab:Point('TOPLEFT', _G.EncounterJournal, 'BOTTOMLEFT', -10, 0)

	_G.EncounterJournalRaidTab:ClearAllPoints()
	_G.EncounterJournalRaidTab:Point('LEFT', _G.EncounterJournalDungeonTab, 'RIGHT', -19, 0)

	--Encounter Info Frame
	local EncounterInfo = EJ.encounter.info
	EncounterInfo:SetTemplate('Transparent')

	EncounterInfo.encounterTitle:Kill()

	EncounterInfo.leftShadow:SetAlpha(0) -- dont kill these
	EncounterInfo.rightShadow:SetAlpha(0) -- it will taint

	EncounterInfo.instanceButton.icon:Size(32)
	EncounterInfo.instanceButton.icon:SetTexCoord(0, 1, 0, 1)
	EncounterInfo.instanceButton:SetNormalTexture(E.ClearTexture)
	EncounterInfo.instanceButton:SetHighlightTexture(E.ClearTexture)

	EncounterInfo.model.dungeonBG:Kill()
	_G.EncounterJournalEncounterFrameInfoBG:Height(385)
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Kill()

	EncounterInfo.instanceButton:ClearAllPoints()
	EncounterInfo.instanceButton:Point('TOPLEFT', EncounterInfo, 'TOPLEFT', 0, 10)

	EncounterInfo.instanceTitle:ClearAllPoints()
	EncounterInfo.instanceTitle:Point('BOTTOM', EncounterInfo.bossesScroll, 'TOP', 10, 15)

	EncounterInfo.difficulty:StripTextures()
	EncounterInfo.reset:StripTextures()

	-- Buttons
	EncounterInfo.difficulty:ClearAllPoints()
	EncounterInfo.difficulty:Point('BOTTOMRIGHT', _G.EncounterJournalEncounterFrameInfoBG, 'TOPRIGHT', -5, 7)
	HandleButton(EncounterInfo.reset)
	HandleButton(EncounterInfo.difficulty)

	EncounterInfo.reset:ClearAllPoints()
	EncounterInfo.reset:Point('TOPRIGHT', EncounterInfo.difficulty, 'TOPLEFT', -10, 0)
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
	_G.EncounterJournalEncounterFrameInfoResetButtonTexture:SetTexCoord(0.90625000, 0.94726563, 0.00097656, 0.02050781)

	S:HandleTrimScrollBar(EncounterInfo.BossesScrollBar)
	S:HandleTrimScrollBar(_G.EncounterJournalEncounterFrameInstanceFrame.LoreScrollBar)

	_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.85)
	_G.EncounterJournalEncounterFrameInstanceFrameBG:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameBG:Point('CENTER', 0, 40)
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameTitle:Point('TOP', 0, -26)
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:ClearAllPoints()
	_G.EncounterJournalEncounterFrameInstanceFrameMapButton:Point('LEFT', 55, -56)

	S:HandleTrimScrollBar(EncounterInfo.overviewScroll.ScrollBar)
	S:HandleTrimScrollBar(EncounterInfo.detailsScroll.ScrollBar)
	S:HandleTrimScrollBar(EncounterInfo.LootContainer.ScrollBar)

	EncounterInfo.detailsScroll:Height(360)
	EncounterInfo.LootContainer:Height(360)
	EncounterInfo.overviewScroll:Height(360)

	-- Tabs
	for _, name in next, { 'overviewTab', 'modelTab', 'bossTab', 'lootTab' } do
		local info = _G.EncounterJournal.encounter.info

		local tab = info[name]
		tab:CreateBackdrop('Transparent')
		tab.backdrop:SetInside(nil, 2, 2)

		tab:SetNormalTexture(E.ClearTexture)
		tab:SetPushedTexture(E.ClearTexture)
		tab:SetDisabledTexture(E.ClearTexture)

		local hl = tab:GetHighlightTexture()
		local r, g, b = unpack(E.media.rgbvaluecolor)
		hl:SetColorTexture(r, g, b, .2)
		hl:SetInside(tab.backdrop)

		tab:ClearAllPoints()
		if name == 'overviewTab' then
			tab:Point('TOPLEFT', _G.EncounterJournalEncounterFrameInfo, 'TOPRIGHT', 9, 0)
		elseif name == 'lootTab' then
			tab:Point('TOPLEFT', info.overviewTab, 'BOTTOMLEFT', 0, -1)
		elseif name == 'bossTab' then
			tab:Point('TOPLEFT', info.lootTab, 'BOTTOMLEFT', 0, -1)
		elseif name == 'modelTab' then
			tab:Point('TOPLEFT', info.bossTab, 'BOTTOMLEFT', 0, -1)

		end
	end

	-- Search
	_G.EncounterJournalSearchResults:StripTextures()
	_G.EncounterJournalSearchResults:SetTemplate()
	_G.EncounterJournalSearchBox.searchPreviewContainer:StripTextures()

	S:HandleCloseButton(_G.EncounterJournalSearchResultsCloseButton)
	S:HandleTrimScrollBar(_G.EncounterJournalSearchResults.ScrollBar)

	for _, button in next, { _G.EncounterJournalEncounterFrameInfoFilterToggle, _G.EncounterJournalEncounterFrameInfoSlotFilterToggle } do
		HandleButton(button, true)
	end

	hooksecurefunc(_G.EncounterJournal.instanceSelect.ScrollBox, 'Update', InstanceSelectScrollUpdate)

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc(_G.EncounterJournal.encounter.info.BossesScrollBox, 'Update', BossesScrollUpdate)
		hooksecurefunc(_G.EncounterJournal.encounter.info.LootContainer.ScrollBox, 'Update', LootContainerUpdate)

		hooksecurefunc('EncounterJournal_SetUpOverview', SkinOverviewInfo)
		hooksecurefunc('EncounterJournal_SetBullets', SkinOverviewInfoBullets)
		hooksecurefunc('EncounterJournal_ToggleHeaders', SkinAbilitiesInfo)

		_G.EncounterJournalEncounterFrameInfoBG:Kill()
		EncounterInfo.detailsScroll.child.description:SetTextColor(1, 1, 1)
		EncounterInfo.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)

		_G.EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject('GameFontNormalLarge')
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, .8, 0)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor('P', 1, 1, 1)

		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetTexCoord(0.71, 0.06, 0.582, 0.08)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetRotation(rad(180))
		_G.EncounterJournalEncounterFrameInstanceFrameBG:SetScale(0.7)
		_G.EncounterJournalEncounterFrameInstanceFrameBG:CreateBackdrop()
		_G.EncounterJournalEncounterFrameInstanceFrame.titleBG:SetAlpha(0)
		_G.EncounterJournalEncounterFrameInstanceFrameTitle:FontTemplate(nil, 25)

		for _, child in next, { _G.EncounterJournalEncounterFrameInstanceFrame.LoreScrollingFont.ScrollBox.ScrollTarget:GetChildren() } do
			LoreScrollingFontChild(child)
		end
	end
end

S:AddCallbackForAddon('Blizzard_EncounterJournal')
