local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

local wipe, sort, unpack = wipe, sort, unpack
local next, pairs, tinsert = next, pairs, tinsert

local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetCVarBool = GetCVarBool
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local UNKNOWN = UNKNOWN

function E:AreOtherAddOnsEnabled()
	local EP, addons, plugins = E.Libs.EP.plugins

	for i = 1, GetNumAddOns() do
		local name = GetAddOnInfo(i)
		if name ~= 'ElvUI' and name ~= 'ElvUI_OptionsUI' and E:IsAddOnEnabled(name) then
			if EP[name] then plugins = true else addons = true end
		end
	end

	return addons, plugins
end

function E:GetDisplayMode()
	return GetCVarBool('gxMaximize') and 'Fullscreen' or 'Windowed'
end

local EnglishClassName = {
	DEATHKNIGHT = 'Death Knight',
	DEMONHUNTER = 'Demon Hunter',
	DRUID = 'Druid',
	HUNTER = 'Hunter',
	MAGE = 'Mage',
	MONK = 'Monk',
	PALADIN = 'Paladin',
	PRIEST = 'Priest',
	ROGUE = 'Rogue',
	SHAMAN = 'Shaman',
	WARLOCK = 'Warlock',
	WARRIOR = 'Warrior',
}

local EnglishSpecName = {
	[250] = 'Blood',
	[251] = 'Frost',
	[252] = 'Unholy',
	[102] = 'Balance',
	[103] = 'Feral',
	[104] = 'Guardian',
	[105] = 'Restoration',
	[253] = 'Beast Mastery',
	[254] = 'Marksmanship',
	[255] = 'Survival',
	[62] = 'Arcane',
	[63] = 'Fire',
	[64] = 'Frost',
	[268] = 'Brewmaster',
	[270] = 'Mistweaver',
	[269] = 'Windwalker',
	[65] = 'Holy',
	[66] = 'Protection',
	[70] = 'Retribution',
	[256] = 'Discipline',
	[257] = 'Holy',
	[258] = 'Shadow',
	[259] = 'Assasination',
	[260] = 'Combat',
	[261] = 'Sublety',
	[262] = 'Elemental',
	[263] = 'Enhancement',
	[264] = 'Restoration',
	[265] = 'Affliction',
	[266] = 'Demonoligy',
	[267] = 'Destruction',
	[71] = 'Arms',
	[72] = 'Fury',
	[73] = 'Protection',
	[577] = 'Havoc',
	[581] = 'Vengeance',
}

local function GetSpecName()
	return EnglishSpecName[GetSpecializationInfo(GetSpecialization())] or UNKNOWN
end

function E:CreateStatusContent(num, width, parent, anchorTo, content)
	if not content then content = CreateFrame('Frame', nil, parent) end
	content:SetSize(width, (num * 20) + ((num-1)*5)) --20 height and 5 spacing
	content:SetPoint('TOP', anchorTo, 'BOTTOM')

	local font = LSM:Fetch('font', 'Expressway')
	for i = 1, num do
		if not content['Line'..i] then
			local line = CreateFrame('Frame', nil, content)
			line:SetSize(width, 20)

			local text = line:CreateFontString(nil, 'ARTWORK')
			text:SetAllPoints()
			text:SetJustifyH('LEFT')
			text:SetJustifyV('MIDDLE')
			text:FontTemplate(font, 14, 'OUTLINE')
			line.Text = text

			if i == 1 then
				line:SetPoint('TOP', content, 'TOP')
			else
				line:SetPoint('TOP', content['Line'..(i-1)], 'BOTTOM', 0, -5)
			end

			content['Line'..i] = line
		end
	end

	return content
end

local function CloseClicked()
	if E.StatusReportToggled then
		E.StatusReportToggled = nil
		E:ToggleOptionsUI()
	end
end

function E:CreateStatusSection(width, height, headerWidth, headerHeight, parent, anchor1, anchorTo, anchor2, yOffset)
	local parentWidth, parentHeight = parent:GetSize()

	if width > parentWidth then parent:Width(width + 25) end
	if height then parent:SetHeight(parentHeight + height) end

	local section = CreateFrame('Frame', nil, parent)
	section:SetSize(width, height or 0)
	section:SetPoint(anchor1, anchorTo, anchor2, 0, yOffset)

	local header = CreateFrame('Frame', nil, section)
	header:SetSize(headerWidth or width, headerHeight)
	header:SetPoint('TOP', section)
	section.Header = header

	local font = LSM:Fetch('font', 'Expressway')
	local text = section.Header:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('TOP')
	text:SetPoint('BOTTOM')
	text:SetJustifyH('CENTER')
	text:SetJustifyV('MIDDLE')
	text:FontTemplate(font, 18, 'OUTLINE')
	section.Header.Text = text

	local leftDivider = section.Header:CreateTexture(nil, 'ARTWORK')
	leftDivider:SetHeight(8)
	leftDivider:SetPoint('LEFT', section.Header, 'LEFT', 5, 0)
	leftDivider:SetPoint('RIGHT', section.Header.Text, 'LEFT', -5, 0)
	leftDivider:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
	leftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.LeftDivider = leftDivider

	local rightDivider = section.Header:CreateTexture(nil, 'ARTWORK')
	rightDivider:SetHeight(8)
	rightDivider:SetPoint('RIGHT', section.Header, 'RIGHT', -5, 0)
	rightDivider:SetPoint('LEFT', section.Header.Text, 'RIGHT', 5, 0)
	rightDivider:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
	rightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
	section.Header.RightDivider = rightDivider

	return section
end

function E:CreateStatusFrame()
	--Main frame
	local StatusFrame = CreateFrame('Frame', 'ElvUIStatusReport', E.UIParent)
	StatusFrame:SetPoint('CENTER', E.UIParent, 'CENTER')
	StatusFrame:SetFrameStrata('HIGH')
	StatusFrame:CreateBackdrop('Transparent', nil, true)
	StatusFrame.backdrop:SetBackdropColor(0, 0, 0, 0.6)
	StatusFrame:SetMovable(true)
	StatusFrame:SetSize(0, 35)
	StatusFrame:Hide()

	--Plugin frame
	local PluginFrame = CreateFrame('Frame', 'ElvUIStatusPlugins', StatusFrame)
	PluginFrame:SetPoint('TOPLEFT', StatusFrame, 'TOPRIGHT', E:Scale(E.Border * 2 + 1), 0)
	PluginFrame:SetFrameStrata('HIGH')
	PluginFrame:CreateBackdrop('Transparent', nil, true)
	PluginFrame.backdrop:SetBackdropColor(0, 0, 0, 0.6)
	PluginFrame:SetSize(0, 25)
	StatusFrame.PluginFrame = PluginFrame

	--Close button and script to retoggle the options.
	StatusFrame:CreateCloseButton()
	StatusFrame.CloseButton:HookScript('OnClick', CloseClicked)

	--Title logo (drag to move frame)
	local titleLogoFrame = CreateFrame('Frame', nil, StatusFrame, 'TitleDragAreaTemplate')
	titleLogoFrame:SetPoint('CENTER', StatusFrame, 'TOP')
	titleLogoFrame:SetSize(240, 80)
	StatusFrame.TitleLogoFrame = titleLogoFrame

	local LogoTop = StatusFrame.TitleLogoFrame:CreateTexture(nil, 'ARTWORK')
	LogoTop:SetPoint('CENTER', titleLogoFrame, 'TOP', 0, -36)
	LogoTop:SetTexture(E.Media.Textures.LogoTopSmall)
	LogoTop:SetSize(128, 64)
	titleLogoFrame.LogoTop = LogoTop

	local LogoBottom = StatusFrame.TitleLogoFrame:CreateTexture(nil, 'ARTWORK')
	LogoBottom:SetPoint('CENTER', titleLogoFrame, 'TOP', 0, -36)
	LogoBottom:SetTexture(E.Media.Textures.LogoBottomSmall)
	LogoBottom:SetSize(128, 64)
	titleLogoFrame.LogoBottom = LogoBottom

	--Sections
	StatusFrame.Section1 = E:CreateStatusSection(300, 125, nil, 30, StatusFrame, 'TOP', StatusFrame, 'TOP', -30)
	StatusFrame.Section2 = E:CreateStatusSection(300, 150, nil, 30, StatusFrame, 'TOP', StatusFrame.Section1, 'BOTTOM', 0)
	StatusFrame.Section3 = E:CreateStatusSection(300, 185, nil, 30, StatusFrame, 'TOP', StatusFrame.Section2, 'BOTTOM', 0)
	--StatusFrame.Section4 = E:CreateStatusSection(300, 60, nil, 30, StatusFrame, 'TOP', StatusFrame.Section3, 'BOTTOM', 0)
	PluginFrame.SectionP = E:CreateStatusSection(280, nil, nil, 30, PluginFrame, 'TOP', PluginFrame, 'TOP', -10)

	--Section content
	StatusFrame.Section1.Content = E:CreateStatusContent(4, 260, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = E:CreateStatusContent(5, 260, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = E:CreateStatusContent(6, 260, StatusFrame.Section3, StatusFrame.Section3.Header)
	--StatusFrame.Section4.Content = CreateFrame('Frame', nil, StatusFrame.Section4)
	--StatusFrame.Section4.Content:SetSize(240, 25)
	--StatusFrame.Section4.Content:SetPoint('TOP', StatusFrame.Section4.Header, 'BOTTOM', 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText('Recommended Scale: |cff4beb2c%s|r', E:PixelBestSize())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText('UI Scale Is: |cff4beb2c%s|r', E.global.general.UIScale)
	StatusFrame.Section2.Content.Line1.Text:SetFormattedText('Version of WoW: |cff4beb2c%s (build %s)|r', E.wowpatch, E.wowbuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText('Client Language: |cff4beb2c%s|r', E.locale)
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText('Using Mac Client: |cff4beb2c%s|r', E.isMacClient and 'Yes' or 'No')
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText('Faction: |cff4beb2c%s|r', E.myfaction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText('Race: |cff4beb2c%s|r', E.myrace)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText('Class: |cff4beb2c%s|r', EnglishClassName[E.myclass])

	--[[Export buttons
	StatusFrame.Section4.Content.Button1 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button1:SetSize(100, 25)
	StatusFrame.Section4.Content.Button1:SetPoint('LEFT', StatusFrame.Section4.Content, 'LEFT')
	StatusFrame.Section4.Content.Button1:SetText('Forum')
	StatusFrame.Section4.Content.Button1:SetButtonState('DISABLED')
	StatusFrame.Section4.Content.Button2 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button2:SetSize(100, 25)
	StatusFrame.Section4.Content.Button2:SetPoint('RIGHT', StatusFrame.Section4.Content, 'RIGHT')
	StatusFrame.Section4.Content.Button2:SetText('Ticket')
	StatusFrame.Section4.Content.Button2:SetButtonState('DISABLED')
	Skins:HandleButton(StatusFrame.Section4.Content.Button1, true)
	Skins:HandleButton(StatusFrame.Section4.Content.Button2, true)]]

	return StatusFrame
end

local function pluginSort(a, b)
	local A, B = a.title or a.name, b.title or b.name
	if A and B then
		return E:StripString(A) < E:StripString(B)
	end
end

local pluginData = {}
function E:UpdateStatusFrame()
	local StatusFrame = E.StatusFrame
	local PluginFrame = StatusFrame.PluginFrame

	--Section headers
	local valueColor = E.media.hexvaluecolor
	StatusFrame.Section1.Header.Text:SetFormattedText('%sAddOn Info|r', valueColor)
	StatusFrame.Section2.Header.Text:SetFormattedText('%sWoW Info|r', valueColor)
	StatusFrame.Section3.Header.Text:SetFormattedText('%sCharacter Info|r', valueColor)
	--StatusFrame.Section4.Header.Text:SetFormattedText('%sExport To|r', valueColor)

	StatusFrame.Section1.Content.Line3.Text:SetFormattedText('Recommended Scale: |cff4beb2c%s|r', E:PixelBestSize())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText('UI Scale Is: |cff4beb2c%s|r', E.global.general.UIScale)

	local PluginSection = PluginFrame.SectionP
	PluginSection.Header.Text:SetFormattedText('%sPlugins|r', valueColor)

	local verWarning = E.recievedOutOfDateMessage and 'ff3333' or E.shownUpdatedWhileRunningPopup and 'ff9933'
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText('Version of ElvUI: |cff%s%.2f|r', verWarning or '33ff33', E.version)

	local addons, plugins = E:AreOtherAddOnsEnabled()
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText('Other AddOns Enabled: |cff%s|r', (not addons and plugins and 'ff9933Plugins') or (addons and 'ff3333Yes') or '33ff33No')

	if plugins then
		wipe(pluginData)
		for _, data in pairs(E.Libs.EP.plugins) do
			if data and not data.isLib then
				tinsert(pluginData, data)
			end
		end

		if next(pluginData) then
			sort(pluginData, pluginSort)

			local count = #pluginData
			local width = PluginSection:GetWidth()
			PluginSection.Content = E:CreateStatusContent(count, width, PluginSection, PluginSection.Header, PluginSection.Content)

			for i=1, count do
				local data = pluginData[i]
				local color = data.old and 'ff3333' or '33ff33'
				PluginSection.Content['Line'..i].Text:SetFormattedText('%s |cff888888v|r|cff%s%s|r', data.title or data.name, color, data.version)
			end

			PluginFrame.SectionP:SetHeight(count * 20)
			PluginFrame:SetHeight(PluginSection.Content:GetHeight() + 50)
			PluginFrame:Show()
		else
			PluginFrame:Hide()
		end
	else
		PluginFrame:Hide()
	end

	local Section2 = StatusFrame.Section2
	Section2.Content.Line3.Text:SetFormattedText('Display Mode: |cff4beb2c%s|r', E:GetDisplayMode())
	Section2.Content.Line4.Text:SetFormattedText('Resolution: |cff4beb2c%s|r', E.resolution)

	local Section3 = StatusFrame.Section3
	Section3.Content.Line4.Text:SetFormattedText('Specialization: |cff4beb2c%s|r', GetSpecName())
	Section3.Content.Line5.Text:SetFormattedText('Level: |cff4beb2c%s|r', E.mylevel)
	Section3.Content.Line6.Text:SetFormattedText('Zone: |cff4beb2c%s|r', GetRealZoneText() or UNKNOWN)

	StatusFrame.TitleLogoFrame.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))
end

function E:ShowStatusReport()
	if not E.StatusFrame then
		E.StatusFrame = E:CreateStatusFrame()
	end

	if not E.StatusFrame:IsShown() then
		E:UpdateStatusFrame()
		E.StatusFrame:Raise() --Set framelevel above everything else
		E.StatusFrame:Show()
	else
		E.StatusFrame:Hide()
	end
end
