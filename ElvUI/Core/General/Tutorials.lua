local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local CreateFrame = CreateFrame
local DISABLE = DISABLE
local HIDE = HIDE

E.TutorialList = {
	L["Need help? Join our Discord: https://discord.tukui.org"],
	L["You can enter the keybind mode by typing /kb"],
	L["Don't forget to backup your WTF folder, all your profiles and settings are in there."],
	L["If you are experiencing issues with ElvUI try disabling all your addons except ElvUI first."],
	L["You can access the copy chat and chat menu functions by left/right clicking on the icon in the top right corner of the chat panel."],
	L["You can see someones average item level inside the tooltip by holding shift and mousing over them."],
	L["To setup chat colors, chat channels and chat font size, right-click the chat tab name."],
	L["ElvUI has a dual spec feature which allows you to load different profiles based on your current spec on the fly. You can enable it in the profiles tab."],
	L["A raid marker feature is available by pressing Escape -> Keybinds. Scroll to the bottom -> ElvUI -> Raid Marker."],
	L["You can access the microbar by using middle mouse button on the minimap. You can also enable the MicroBar in the actionbar settings."],
	L["If you accidentally removed a default chat tab you can always re-run the chat part of the ElvUI installer."],
	L["You can quickly change your displayed DataTexts by mousing over them while holding ALT."],
	L["To quickly move around certain elements of the UI, type /emove"],
	L["From time to time you should compare your ElvUI version against the most recent version on our website."],
	L["To list all available ElvUI commands, type in chat /ehelp"]
}

local tutorial
function E:SetNextTutorial()
	E.db.currentTutorial = E.db.currentTutorial or 0
	E.db.currentTutorial = E.db.currentTutorial + 1

	if E.db.currentTutorial > #E.TutorialList then
		E.db.currentTutorial = 1
	end

	tutorial.desc:SetText(E.TutorialList[E.db.currentTutorial])
end

function E:SetPrevTutorial()
	E.db.currentTutorial = E.db.currentTutorial or 0
	E.db.currentTutorial = E.db.currentTutorial - 1

	if E.db.currentTutorial <= 0 then
		E.db.currentTutorial = #E.TutorialList
	end

	tutorial.desc:SetText(E.TutorialList[E.db.currentTutorial])
end

function E:SpawnTutorialFrame()
	tutorial = CreateFrame('Frame', 'ElvUITutorialWindow', E.UIParent)
	tutorial:SetFrameStrata('DIALOG')
	tutorial:SetToplevel(true)
	tutorial:SetClampedToScreen(true)
	tutorial:Width(360)
	tutorial:Height(110)
	tutorial:SetTemplate('Transparent')
	tutorial:Hide()

	E.TutorialWindow = tutorial

	local header = CreateFrame('Button', '$parentHeader', tutorial)
	header:SetTemplate(nil, true)
	header:Width(120); header:Height(25)
	header:Point('CENTER', tutorial, 'TOP')
	header:OffsetFrameLevel(2)

	local title = header:CreateFontString(nil, 'OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText('ElvUI')
	tutorial.title = title

	local desc = tutorial:CreateFontString(nil, 'ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -32)
	desc:Point('BOTTOMRIGHT', -18, 30)
	tutorial.desc = desc

	local disableButton = CreateFrame('CheckButton', '$parentDisableButton', tutorial, 'UICheckButtonTemplate')
	disableButton:Point('BOTTOMLEFT')
	disableButton:SetScript('OnShow', function(btn) btn:SetChecked(E.db.hideTutorial) end)
	disableButton:SetScript('OnClick', function(btn) E.db.hideTutorial = btn:GetChecked() end)
	disableButton.Text:SetText(DISABLE)
	S:HandleCheckBox(disableButton)

	local hideButton = CreateFrame('Button', '$parentHideButton', tutorial, 'UIPanelButtonTemplate')
	hideButton:Point('BOTTOMRIGHT', -5, 5)
	hideButton:SetScript('OnClick', function() E:StaticPopupSpecial_Hide(tutorial) end)
	hideButton.Text:SetText(HIDE)
	S:HandleButton(hideButton)

	local nextButton = CreateFrame('Button', '$parentNextButton', tutorial, 'UIPanelButtonTemplate')
	nextButton:Point('RIGHT', hideButton, 'LEFT', -4, 0)
	nextButton:Width(20)
	nextButton:SetScript('OnClick', function() E:SetNextTutorial() end)
	nextButton.Text:SetText('>')
	S:HandleButton(nextButton)

	local prevButton = CreateFrame('Button', '$parentPrevButton', tutorial, 'UIPanelButtonTemplate')
	prevButton:Point('RIGHT', nextButton, 'LEFT', -4, 0)
	prevButton:Width(20)
	prevButton:SetScript('OnClick', function() E:SetPrevTutorial() end)
	prevButton.Text:SetText('<')
	S:HandleButton(prevButton)

	return tutorial
end

function E:Tutorials(forceShow)
	if not forceShow and (E.db.hideTutorial or not E.private.install_complete) then return end

	E:StaticPopupSpecial_Show(tutorial or E:SpawnTutorialFrame())
	E:SetNextTutorial()
end
