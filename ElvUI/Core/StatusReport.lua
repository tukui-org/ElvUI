local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Skins = E:GetModule('Skins')

--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetCVar = GetCVar
local GetLocale = GetLocale
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo

local function AreOtherAddOnsEnabled()
	local name
	for i = 1, GetNumAddOns() do
		name = GetAddOnInfo(i)
		if ((name ~= 'ElvUI' and name ~= 'ElvUI_OptionsUI') and E:IsAddOnEnabled(name)) then --Loaded or load on demand
			return 'Yes'
		end
	end
	return 'No'
end

local function GetDisplayMode()
	local window, maximize = GetCVar('gxWindow'), GetCVar('gxMaximize')
	local displayMode

	if window == '1' then
		if maximize == '1' then
			displayMode = 'Windowed (Fullscreen)'
		else
			displayMode = 'Windowed'
		end
	else
		displayMode = 'Fullscreen'
	end

	return displayMode
end

local EnglishClassName = {
	['DEATHKNIGHT'] = 'Death Knight',
	['DEMONHUNTER'] = 'Demon Hunter',
	['DRUID'] = 'Druid',
	['HUNTER'] = 'Hunter',
	['MAGE'] = 'Mage',
	['MONK'] = 'Monk',
	['PALADIN'] = 'Paladin',
	['PRIEST'] = 'Priest',
	['ROGUE'] = 'Rogue',
	['SHAMAN'] = 'Shaman',
	['WARLOCK'] = 'Warlock',
	['WARRIOR'] = 'Warrior',
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
	return EnglishSpecName[GetSpecializationInfo(GetSpecialization())]
end

local function CreateContentLines(num, parent, anchorTo)
	local content = CreateFrame('Frame', nil, parent)
	content:Size(260, (num * 20) + ((num-1)*5)) --20 height and 5 spacing
	content:Point('TOP', anchorTo, 'BOTTOM',0 , -5)

	for i = 1, num do
		local line = CreateFrame('Frame', nil, content)
		line:Size(260, 20)

		local text = line:CreateFontString(nil, 'ARTWORK', 'SystemFont_Outline')
		text:SetAllPoints()
		text:SetJustifyH('LEFT')
		text:SetJustifyV('MIDDLE')
		line.Text = text

		local numLine = line
		if i == 1 then
			numLine:Point('TOP', content, 'TOP')
		else
			numLine:Point('TOP', content['Line'..(i-1)], 'BOTTOM', 0, -5)
		end

		content['Line'..i] = numLine
	end

	return content
end

local function CloseClicked()
	if E.StatusReportToggled then
		E.StatusReportToggled = nil
		E:ToggleOptionsUI()
	end
end

function E:CreateStatusFrame()
	local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
		local section = CreateFrame('Frame', nil, parent)
		section:Size(width, height)
		section:Point(anchor1, anchorTo, anchor2, 0, yOffset)

		local header = CreateFrame('Frame', nil, section)
		header:Size(300, 30)
		header:Point('TOP', section)
		section.Header = header

		local text = section.Header:CreateFontString(nil, 'ARTWORK', 'SystemFont_Outline')
		text:Point('TOP')
		text:Point('BOTTOM')
		text:SetJustifyH('CENTER')
		text:SetJustifyV('MIDDLE')

		local font, fontHeight, fontFlags = text:GetFont()
		text:FontTemplate(font, fontHeight*1.3, fontFlags)
		section.Header.Text = text

		local leftDivider = section.Header:CreateTexture(nil, 'ARTWORK')
		leftDivider:Height(8)
		leftDivider:Point('LEFT', section.Header, 'LEFT', 5, 0)
		leftDivider:Point('RIGHT', section.Header.Text, 'LEFT', -5, 0)
		leftDivider:SetTexture('Interface\\Tooltips\\UI-Tooltip-Border')
		leftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
		section.Header.LeftDivider = leftDivider

		local rightDivider = section.Header:CreateTexture(nil, 'ARTWORK')
		rightDivider:Height(8)
		rightDivider:Point('RIGHT', section.Header, 'RIGHT', -5, 0)
		rightDivider:Point('LEFT', section.Header.Text, 'RIGHT', 5, 0)
		rightDivider:SetTexture('Interface\\Tooltips\\UI-Tooltip-Border')
		rightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)
		section.Header.RightDivider = rightDivider

		return section
	end

	--Main frame
	local StatusFrame = CreateFrame('Frame', 'ElvUIStatusReport', E.UIParent)
	StatusFrame:Size(320, 555)
	StatusFrame:Point('CENTER', E.UIParent, 'CENTER')
	StatusFrame:SetFrameStrata('HIGH')
	StatusFrame:CreateBackdrop('Transparent', nil, true)
	StatusFrame.backdrop:SetBackdropColor(0, 0, 0, 0.6)
	StatusFrame:SetMovable(true)
	StatusFrame:Hide()

	--Close button and script to retoggle the options.
	StatusFrame:CreateCloseButton()
	StatusFrame.CloseButton:HookScript('OnClick', CloseClicked)

	--Title logo (drag to move frame)
	local titleLogoFrame = CreateFrame('Frame', nil, StatusFrame, 'TitleDragAreaTemplate')
	titleLogoFrame:Point('CENTER', StatusFrame, 'TOP')
	titleLogoFrame:Size(240, 80)
	StatusFrame.TitleLogoFrame = titleLogoFrame

	local titleTexture = StatusFrame.TitleLogoFrame:CreateTexture(nil, 'ARTWORK')
	titleTexture:Point('CENTER', titleLogoFrame, 'TOP', 0, -36)
	titleTexture:SetTexture(E.Media.Textures.LogoSmall)
	titleTexture:Size(128, 64)
	titleLogoFrame.Texture = titleTexture

	--Sections
	StatusFrame.Section1 = CreateSection(300, 125, StatusFrame, 'TOP', StatusFrame, 'TOP', -30)
	StatusFrame.Section2 = CreateSection(300, 150, StatusFrame, 'TOP', StatusFrame.Section1, 'BOTTOM', 0)
	StatusFrame.Section3 = CreateSection(300, 185, StatusFrame, 'TOP', StatusFrame.Section2, 'BOTTOM', 0)
	StatusFrame.Section4 = CreateSection(300, 60, StatusFrame, 'TOP', StatusFrame.Section3, 'BOTTOM', 0)

	--Section headers
	StatusFrame.Section1.Header.Text:SetText('|cfffe7b2cAddOn Info|r')
	StatusFrame.Section2.Header.Text:SetText('|cfffe7b2cWoW Info|r')
	StatusFrame.Section3.Header.Text:SetText('|cfffe7b2cCharacter Info|r')
	StatusFrame.Section4.Header.Text:SetText('|cfffe7b2cExport To|r')

	--Section content
	StatusFrame.Section1.Content = CreateContentLines(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateContentLines(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateContentLines(6, StatusFrame.Section3, StatusFrame.Section3.Header)
	StatusFrame.Section4.Content = CreateFrame('Frame', nil, StatusFrame.Section4)
	StatusFrame.Section4.Content:Size(240, 25)
	StatusFrame.Section4.Content:Point('TOP', StatusFrame.Section4.Header, 'BOTTOM', 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText('Version of ElvUI: |cff4beb2c%s|r', E.version)
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText('Other AddOns Enabled: |cff4beb2c%s|r', AreOtherAddOnsEnabled())
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText('Recommended Scale: |cff4beb2c%s|r', E:PixelBestSize())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText('UI Scale Is: |cff4beb2c%s|r', E.global.general.UIScale)
	StatusFrame.Section2.Content.Line1.Text:SetFormattedText('Version of WoW: |cff4beb2c%s (build %s)|r', E.wowpatch, E.wowbuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText('Client Language: |cff4beb2c%s|r', GetLocale())
	StatusFrame.Section2.Content.Line3.Text:SetFormattedText('Display Mode: |cff4beb2c%s|r', GetDisplayMode())
	StatusFrame.Section2.Content.Line4.Text:SetFormattedText('Resolution: |cff4beb2c%s|r', E.resolution)
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText('Using Mac Client: |cff4beb2c%s|r', (E.isMacClient == true and 'Yes' or 'No'))
	StatusFrame.Section3.Content.Line1.Text:SetFormattedText('Faction: |cff4beb2c%s|r', E.myfaction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText('Race: |cff4beb2c%s|r', E.myrace)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText('Class: |cff4beb2c%s|r', EnglishClassName[E.myclass])
	StatusFrame.Section3.Content.Line4.Text:SetFormattedText('Specialization: |cff4beb2c%s|r', GetSpecName())
	StatusFrame.Section3.Content.Line5.Text:SetFormattedText('Level: |cff4beb2c%s|r', E.mylevel)
	StatusFrame.Section3.Content.Line6.Text:SetFormattedText('Zone: |cff4beb2c%s|r', GetRealZoneText())

	--Export buttons
	StatusFrame.Section4.Content.Button1 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button1:Size(100, 25)
	StatusFrame.Section4.Content.Button1:Point('LEFT', StatusFrame.Section4.Content, 'LEFT')
	StatusFrame.Section4.Content.Button1:SetText('Forum')
	StatusFrame.Section4.Content.Button1:SetButtonState('DISABLED')
	StatusFrame.Section4.Content.Button2 = CreateFrame('Button', nil, StatusFrame.Section4.Content, 'UIPanelButtonTemplate')
	StatusFrame.Section4.Content.Button2:Size(100, 25)
	StatusFrame.Section4.Content.Button2:Point('RIGHT', StatusFrame.Section4.Content, 'RIGHT')
	StatusFrame.Section4.Content.Button2:SetText('Ticket')
	StatusFrame.Section4.Content.Button2:SetButtonState('DISABLED')
	Skins:HandleButton(StatusFrame.Section4.Content.Button1, true)
	Skins:HandleButton(StatusFrame.Section4.Content.Button2, true)

	return StatusFrame
end

local function UpdateDynamicValues()
	local StatusFrame = E.StatusFrame

	local Section2 = StatusFrame.Section2
	Section2.Content.Line3.Text:SetFormattedText('Display Mode: |cff4beb2c%s|r', GetDisplayMode())
	Section2.Content.Line4.Text:SetFormattedText('Resolution: |cff4beb2c%s|r', E.resolution)

	local Section3 = StatusFrame.Section3
	Section3.Content.Line4.Text:SetFormattedText('Specialization: |cff4beb2c%s|r', GetSpecName())
	Section3.Content.Line5.Text:SetFormattedText('Level: |cff4beb2c%s|r', E.mylevel)
	Section3.Content.Line6.Text:SetFormattedText('Zone: |cff4beb2c%s|r', GetRealZoneText())
end

function E:ShowStatusReport()
	if not E.StatusFrame then
		E.StatusFrame = E:CreateStatusFrame()
	end

	if not E.StatusFrame:IsShown() then
		UpdateDynamicValues()
		E.StatusFrame:Raise() --Set framelevel above everything else
		E.StatusFrame:Show()
	else
		E.StatusFrame:Hide()
	end
end
