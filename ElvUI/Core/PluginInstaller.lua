--[[--------------------------------------------------------------------
	* Plugins pass their info using the table like:
	addon = {
		Title = 'Your Own Title',
		Name = 'AddOnName',
		tutorialImage = 'TexturePath',
		tutorialImageSize = {x,y},
		tutorialImagetutorialImagePoint = {xOffset,yOffset},
		Pages = {
			function1,
			function2,
			function3,
		},
		StepTitles = {
			'Title 1',
			'Title 2',
			'Title 3',
		},
		StepTitlesColor = {r, g, b},
		StepTitlesColorSelected = {r, g, b},
		StepTitleWidth = 140,
		StepTitleButtonWidth = 130,
		StepTitleTextJustification = 'CENTER'
	}

	E:GetModule('PluginInstaller'):Queue(addon)

	* Title is wat displayed on top of the window. By default it's "ElvUI Plugin Installation"
	* Name is how your installation will be showin in 'pending list', Default is 'Unknown'
	* tutorialImage is a path to your own texture to use in frame. if not specified, then it will use ElvUI's one
	* Pages is a table to set up pages of your install where numbers are representing actual pages' order and function is what previously was used to set layout. For example

	function function1()
		PluginInstallFrame.SubTitle:SetText('Title Text')
		PluginInstallFrame.Desc1:SetText('Desc 1 Tet')
		PluginInstallFrame.Desc2:SetText('Desc 2 Tet')
		PluginInstallFrame.Desc3:SetText('Desc 3 Tet')

		PluginInstallFrame.Option1:Show()
		PluginInstallFrame.Option1:SetScript('OnClick', function() <Do Some Stuff> end)
		PluginInstallFrame.Option1:SetText('Text 1')

		PluginInstallFrame.Option2:Show()
		PluginInstallFrame.Option2:SetScript('OnClick', function() <Do Some Other Stuff> end)
		PluginInstallFrame.Option2:SetText('Text 2')
	end

	StepTitles					- a table to specify 'titles' for your install steps.
		* If specified and number of lines here = number of pages then you'll get an additional frame to the right of main frame
		* with a list of steps (current one being highlighted), clicking on those will open respective step. BenikUI style of doing stuff.
	StepTitlesColor				- a table with color values to color 'titles' when they are not active
	StepTitlesColorSelected		- a table with color values to color 'titles' when they are active
	StepTitleWidth				- Width of the steps frame on the right side
	StepTitleButtonWidth		- Width of each step button in the steps frame
	StepTitleTextJustification	- The justification of the text on each step button ('LEFT', 'RIGHT', 'CENTER'). Default: 'CENTER'
--------------------------------------------------------------------]]--

local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local PI = E:GetModule('PluginInstaller')
local S = E:GetModule('Skins')

local _G = _G
local pairs, unpack = pairs, unpack
local tinsert, tremove, format = tinsert, tremove, format

local PlaySound = PlaySound
local CreateFrame = CreateFrame
local UIFrameFadeOut = UIFrameFadeOut
local CONTINUE, PREVIOUS, UNKNOWN = CONTINUE, PREVIOUS, UNKNOWN
-- GLOBALS: PluginInstallFrame

--Installation Functions
PI.Installs = {}
local f
local BUTTON_HEIGHT = 20

local function ResetAll()
	f.Next:Disable()
	f.Prev:Disable()
	f.Option1:Hide()
	f.Option1:SetScript('OnClick', nil)
	f.Option1:SetText('')
	f.Option2:Hide()
	f.Option2:SetScript('OnClick', nil)
	f.Option2:SetText('')
	f.Option3:Hide()
	f.Option3:SetScript('OnClick', nil)
	f.Option3:SetText('')
	f.Option4:Hide()
	f.Option4:SetScript('OnClick', nil)
	f.Option4:SetText('')
	f.SubTitle:SetText('')
	f.Desc1:SetText('')
	f.Desc2:SetText('')
	f.Desc3:SetText('')
	f.Desc4:SetText('')
	f:Size(550, 400)
	if f.StepTitles then
		for i = 1, #f.side.Lines do f.side.Lines[i].text:SetText('') end
	end
end

local function SetPage(PageNum, PrevPage)
	f.CurrentPage = PageNum
	f.PrevPage = PrevPage
	ResetAll()
	f.Status.anim.progress:SetChange(PageNum)
	f.Status.anim.progress:Play()

	local r, g, b = E:ColorGradient(f.CurrentPage / f.MaxPage, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	f.Status:SetStatusBarColor(r, g, b)

	if PageNum == f.MaxPage then
		f.Next:Disable()
	else
		f.Next:Enable()
	end

	if PageNum == 1 then
		f.Prev:Disable()
	else
		f.Prev:Enable()
	end

	f.Pages[f.CurrentPage]()
	f.Status.text:SetFormattedText('%d / %d', f.CurrentPage, f.MaxPage)
	if f.StepTitles then
		for i = 1, #f.side.Lines do
			local line, color = f.side.Lines[i]
			line.text:SetText(f.StepTitles[i])
			if i == f.CurrentPage then
				color = f.StepTitlesColorSelected or {.09,.52,.82}
			else
				color = f.StepTitlesColor or {1,1,1}
			end
			line.text:SetTextColor(color[1] or color.r, color[2] or color.g, color[3] or color.b)
		end
	end
end

local function NextPage()
	if f.CurrentPage ~= f.MaxPage then
		f.CurrentPage = f.CurrentPage + 1
		SetPage(f.CurrentPage, f.CurrentPage - 1)
	end
end

local function PreviousPage()
	if f.CurrentPage ~= 1 then
		f.CurrentPage = f.CurrentPage - 1
		SetPage(f.CurrentPage, f.CurrentPage + 1)
	end
end

function PI:CreateStepComplete()
	local imsg = CreateFrame('Frame', 'PluginInstallStepComplete', E.UIParent)
	imsg:Size(418, 72)
	imsg:Point('TOP', 0, -190)
	imsg:Hide()
	imsg:SetScript('OnShow', function(frame)
		if frame.message then
			PlaySound(888) -- LevelUp Sound
			frame.text:SetText(frame.message)
			UIFrameFadeOut(frame, 3.5, 1, 0)
			E:Delay(4, frame.Hide, frame)
			frame.message = nil
		else
			frame:Hide()
		end
	end)

	imsg.firstShow = false

	imsg.bg = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.bg:Point('BOTTOM')
	imsg.bg:Size(326, 103)
	imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	imsg.bg:SetVertexColor(1, 1, 1, 0.6)

	imsg.lineTop = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.lineTop:SetDrawLayer('BACKGROUND', 2)
	imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineTop:Point('TOP')
	imsg.lineTop:Size(418, 7)
	imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.lineBottom = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
	imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineBottom:Point('BOTTOM')
	imsg.lineBottom:Size(418, 7)
	imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.text = imsg:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
	imsg.text:Point('BOTTOM', 0, 12)
	imsg.text:SetTextColor(1, 0.82, 0)
	imsg.text:SetJustifyH('CENTER')
end

function PI:CreateFrame()
	f = CreateFrame('Button', 'PluginInstallFrame', E.UIParent)
	f.SetPage = SetPage
	f:Size(550, 400)
	f:SetTemplate('Transparent')
	f:Point('CENTER')
	f:SetFrameStrata('TOOLTIP')
	f:SetMovable(true)

	f.MoveFrame = CreateFrame('Frame', nil, f, 'TitleDragAreaTemplate')
	f.MoveFrame:Size(450, 50)
	f.MoveFrame:Point('TOP', f, 'TOP')

	f.Title = f:CreateFontString(nil, 'OVERLAY')
	f.Title:FontTemplate(nil, 17, nil)
	f.Title:Point('TOP', 0, -5)

	f.Next = CreateFrame('Button', 'PluginInstallNextButton', f, 'UIPanelButtonTemplate')
	f.Next:Size(110, 25)
	f.Next:Point('BOTTOMRIGHT', -5, 5)
	f.Next:SetText(CONTINUE)
	f.Next:Disable()
	f.Next:SetScript('OnClick', NextPage)
	S:HandleButton(f.Next)

	f.Prev = CreateFrame('Button', 'PluginInstallPrevButton', f, 'UIPanelButtonTemplate')
	f.Prev:Size(110, 25)
	f.Prev:Point('BOTTOMLEFT', 5, 5)
	f.Prev:SetText(PREVIOUS)
	f.Prev:Disable()
	f.Prev:SetScript('OnClick', PreviousPage)
	S:HandleButton(f.Prev)

	f.Status = CreateFrame('StatusBar', 'PluginInstallStatus', f)
	f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
	f.Status:CreateBackdrop(nil, true)
	f.Status:SetStatusBarTexture(E.media.normTex)
	f.Status:SetStatusBarColor(unpack(E.media.rgbvaluecolor))
	f.Status:Point('TOPLEFT', f.Prev, 'TOPRIGHT', 6, -2)
	f.Status:Point('BOTTOMRIGHT', f.Next, 'BOTTOMLEFT', -6, 2)
	-- Setup StatusBar Animation
	f.Status.anim = _G.CreateAnimationGroup(f.Status)
	f.Status.anim.progress = f.Status.anim:CreateAnimation('Progress')
	f.Status.anim.progress:SetEasing('Out')
	f.Status.anim.progress:SetDuration(.3)

	f.Status.text = f.Status:CreateFontString(nil, 'OVERLAY')
	f.Status.text:FontTemplate(nil, 14, 'OUTLINE')
	f.Status.text:Point('CENTER')

	f.Option1 = CreateFrame('Button', 'PluginInstallOption1Button', f, 'UIPanelButtonTemplate')
	f.Option1:Size(160, 30)
	f.Option1:Point('BOTTOM', 0, 45)
	f.Option1:SetText('')
	f.Option1:Hide()
	S:HandleButton(f.Option1)

	f.Option2 = CreateFrame('Button', 'PluginInstallOption2Button', f, 'UIPanelButtonTemplate')
	f.Option2:Size(110, 30)
	f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45)
	f.Option2:SetText('')
	f.Option2:Hide()
	f.Option2:SetScript('OnShow', function() f.Option1:Width(110); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45) end)
	f.Option2:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45) end)
	S:HandleButton(f.Option2)

	f.Option3 = CreateFrame('Button', 'PluginInstallOption3Button', f, 'UIPanelButtonTemplate')
	f.Option3:Size(100, 30)
	f.Option3:Point('LEFT', f.Option2, 'RIGHT', 4, 0)
	f.Option3:SetText('')
	f.Option3:Hide()
	f.Option3:SetScript('OnShow', function() f.Option1:Width(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:Width(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45) end)
	f.Option3:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
	S:HandleButton(f.Option3)

	f.Option4 = CreateFrame('Button', 'PluginInstallOption4Button', f, 'UIPanelButtonTemplate')
	f.Option4:Size(100, 30)
	f.Option4:Point('LEFT', f.Option3, 'RIGHT', 4, 0)
	f.Option4:SetText('')
	f.Option4:Hide()
	f.Option4:SetScript('OnShow', function()
		f.Option1:Width(100)
		f.Option2:Width(100)

		f.Option1:ClearAllPoints()
		f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0)
		f.Option2:ClearAllPoints()
		f.Option2:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45)
	end)
	f.Option4:SetScript('OnHide', function() f.Option1:Width(160); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOM', 0, 45); f.Option2:Width(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
	S:HandleButton(f.Option4)

	f.SubTitle = f:CreateFontString(nil, 'OVERLAY')
	f.SubTitle:FontTemplate(nil, 15, nil)
	f.SubTitle:Point('TOP', 0, -40)

	f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc1:FontTemplate()
	f.Desc1:Point('TOPLEFT', 20, -75)
	f.Desc1:Width(f:GetWidth() - 40)

	f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc2:FontTemplate()
	f.Desc2:Point('TOP', f.Desc1, 'BOTTOM', 0, -20)
	f.Desc2:Width(f:GetWidth() - 40)

	f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc3:FontTemplate()
	f.Desc3:Point('TOP', f.Desc2, 'BOTTOM', 0, -20)
	f.Desc3:Width(f:GetWidth() - 40)

	f.Desc4 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc4:FontTemplate()
	f.Desc4:Point('TOP', f.Desc3, 'BOTTOM', 0, -20)
	f.Desc4:Width(f:GetWidth() - 40)

	local close = CreateFrame('Button', 'PluginInstallCloseButton', f, 'UIPanelCloseButton')
	close:Point('TOPRIGHT', f, 'TOPRIGHT')
	close:SetScript('OnClick', function() f:Hide() end)
	S:HandleCloseButton(close)

	f.pending = CreateFrame('Frame', 'PluginInstallPendingButton', f)
	f.pending:Size(20, 20)
	f.pending:Point('TOPLEFT', f, 'TOPLEFT', 8, -8)
	f.pending.tex = f.pending:CreateTexture(nil, 'OVERLAY')
	f.pending.tex:Point('TOPLEFT', f.pending, 'TOPLEFT', 2, -2)
	f.pending.tex:Point('BOTTOMRIGHT', f.pending, 'BOTTOMRIGHT', -2, 2)
	f.pending.tex:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon]])
	f.pending:CreateBackdrop('Transparent')
	f.pending:SetScript('OnEnter', function(button)
		_G.GameTooltip:SetOwner(button, 'ANCHOR_BOTTOMLEFT', E.PixelMode and -7 or -9)
		_G.GameTooltip:AddLine(L["List of installations in queue:"], 1, 1, 1)
		_G.GameTooltip:AddLine(' ')
		for i = 1, #PI.Installs do
			_G.GameTooltip:AddDoubleLine(format('%d. %s', i, (PI.Installs[i].Name or UNKNOWN)), i == 1 and format('|cff00FF00%s|r', L["In Progress"]) or format('|cffFF0000%s|r', L["Pending"]))
		end
		_G.GameTooltip:Show()
	end)
	f.pending:SetScript('OnLeave', function()
		_G.GameTooltip:Hide()
	end)

	f.tutorialImage = f:CreateTexture('PluginInstallTutorialImage', 'OVERLAY')
	f.tutorialImage2 = f:CreateTexture('PluginInstallTutorialImage2', 'OVERLAY')

	f.side = CreateFrame('Frame', 'PluginInstallTitleFrame', f)
	f.side:SetTemplate('Transparent')
	f.side:Point('TOPLEFT', f, 'TOPRIGHT', E.PixelMode and 1 or 3, 0)
	f.side:Point('BOTTOMLEFT', f, 'BOTTOMRIGHT', E.PixelMode and 1 or 3, 0)
	f.side:Width(140)
	f.side.text = f.side:CreateFontString(nil, 'OVERLAY')
	f.side.text:Point('TOP', f.side, 'TOP', 0, -4)
	f.side.text:FontTemplate(nil, 18, 'OUTLINE')
	f.side.text:SetText(L["Steps"])
	f.side.Lines = {} --Table to keep shown lines
	f.side:Hide()
	for i = 1, 18 do
		local button = CreateFrame('Button', nil, f)
		if i == 1 then
			button:Point('TOP', f.side.text, 'BOTTOM', 0, -6)
		else
			button:Point('TOP', f.side.Lines[i - 1], 'BOTTOM')
		end
		button:Size(130, BUTTON_HEIGHT)
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:Point('TOPLEFT', button, 'TOPLEFT', 2, -2)
		button.text:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
		button.text:FontTemplate(nil, 14, 'OUTLINE')
		button:SetScript('OnClick', function() if i <= f.MaxPage then SetPage(i, f.CurrentPage) end end)
		button.text:SetText('')
		f.side.Lines[i] = button
		button:Hide()
	end

	f:Hide()

	f:SetScript('OnHide', function() PI:CloseInstall() end)
end

function PI:Queue(addon)
	local addonIsQueued = false
	for _, v in pairs(self.Installs) do
		if v.Name == addon.Name then
			addonIsQueued = true
		end
	end

	if not addonIsQueued then
		tinsert(self.Installs, #(self.Installs)+1, addon)
		self:RunInstall()
	end
end

function PI:CloseInstall()
	tremove(self.Installs, 1)
	f.side:Hide()
	for i = 1, #f.side.Lines do
		f.side.Lines[i].text:SetText('')
		f.side.Lines[i]:Hide()
	end
	if #self.Installs > 0 then
		E:Delay(1, PI.RunInstall, PI)
	end
end

function PI:RunInstall()
	if not E.private.install_complete then return end

	local db = self.Installs[1]
	if db and not f:IsShown() and not (_G.ElvUIInstallFrame and _G.ElvUIInstallFrame:IsShown()) then
		f.StepTitles = nil
		f.StepTitlesColor = nil
		f.StepTitlesColorSelected = nil

		f.CurrentPage = 0
		f.MaxPage = #(db.Pages)

		f.Title:SetText(db.Title or L["ElvUI Plugin Installation"])
		f.Status:SetMinMaxValues(0, f.MaxPage)
		f.Status.text:SetText(f.CurrentPage..' / '..f.MaxPage)

		-- Logo
		local LogoTop = db.tutorialImage or E.Media.Textures.LogoTop
		f.tutorialImage:SetTexture(LogoTop)
		f.tutorialImage:ClearAllPoints()
		if db.tutorialImageSize then
			f.tutorialImage:Size(db.tutorialImageSize[1], db.tutorialImageSize[2])
		else
			f.tutorialImage:Size(256, 128)
		end
		if db.tutorialImagePoint then
			f.tutorialImage:Point('BOTTOM', 0 + db.tutorialImagePoint[1], 70 + db.tutorialImagePoint[2])
		else
			f.tutorialImage:Point('BOTTOM', 0, 70)
		end
		if db.tutorialImageVertexColor then
			f.tutorialImage:SetVertexColor(unpack(db.tutorialImageVertexColor))
		elseif LogoTop == E.Media.Textures.LogoTop then
			f.tutorialImage:SetVertexColor(unpack(E.media.rgbvaluecolor))
		else
			f.tutorialImage:SetVertexColor(1, 1, 1)
		end

		--Alt Logo
		if LogoTop == E.Media.Textures.LogoTop or db.tutorialImage2 then
			f.tutorialImage2:SetTexture(db.tutorialImage2 or E.Media.Textures.LogoBottom)
			f.tutorialImage2:ClearAllPoints()
			if db.tutorialImage2Size then
				f.tutorialImage2:Size(db.tutorialImage2Size[1], db.tutorialImage2Size[2])
			else
				f.tutorialImage2:Size(256, 128)
			end
			if db.tutorialImage2Point then
				f.tutorialImage2:Point('BOTTOM', 0 + db.tutorialImage2Point[1], 70 + db.tutorialImage2Point[2])
			else
				f.tutorialImage2:Point('BOTTOM', 0, 70)
			end
			if db.tutorialImage2VertexColor then
				f.tutorialImage2:SetVertexColor(unpack(db.tutorialImage2VertexColor))
			else
				f.tutorialImage2:SetVertexColor(1, 1, 1)
			end
		end

		f.Pages = db.Pages

		f:Show()
		f:ClearAllPoints()
		f:Point('CENTER')

		if db.StepTitles and #db.StepTitles == f.MaxPage then
			f:Point('CENTER', E.UIParent, 'CENTER', -((db.StepTitleWidth or 140)/2), 0)
			f.side:Width(db.StepTitleWidth or 140)
			f.side:Show()

			for i = 1, #f.side.Lines do
				if db.StepTitles[i] then
					f.side.Lines[i]:Width(db.StepTitleButtonWidth or 130)
					f.side.Lines[i].text:SetJustifyH(db.StepTitleTextJustification or 'CENTER')
					f.side.Lines[i]:Show()
				end
			end

			f.StepTitles = db.StepTitles
			f.StepTitlesColor = db.StepTitlesColor
			f.StepTitlesColorSelected = db.StepTitlesColorSelected
		end

		NextPage()
	end

	if #self.Installs > 1 then
		f.pending:Show()
		E:Flash(f.pending, 0.53, true)
	else
		f.pending:Hide()
		E:StopFlash(f.pending)
	end
end

function PI:Initialize()
	PI.Initialized = true
	PI:CreateStepComplete()
	PI:CreateFrame()
end

E:RegisterModule(PI:GetName())
