local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Skins = E:GetModule('Skins')

local _G = _G
local CreateFrame = CreateFrame
local DISABLE = DISABLE
local HIDE = HIDE
-- GLOBALS: ElvUITutorialWindow

E.TutorialList = {
	L["Need help? Join our Discord: https://discord.gg/xFWcfgE"],
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
	L["To quickly move around certain elements of the UI, type /moveui"],
	L["From time to time you should compare your ElvUI version against the most recent version on our website or the Tukui client."],
	L["To list all available ElvUI commands, type in chat /ehelp"]
}

function E:SetNextTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial + 1

	if self.db.currentTutorial > #E.TutorialList then
		self.db.currentTutorial = 1
	end

	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SetPrevTutorial()
	self.db.currentTutorial = self.db.currentTutorial or 0
	self.db.currentTutorial = self.db.currentTutorial - 1

	if self.db.currentTutorial <= 0 then
		self.db.currentTutorial = #E.TutorialList
	end

	ElvUITutorialWindow.desc:SetText(E.TutorialList[self.db.currentTutorial])
end

function E:SpawnTutorialFrame()
	local f = CreateFrame('Frame', 'ElvUITutorialWindow', E.UIParent)
	f:SetFrameStrata('DIALOG')
	f:SetToplevel(true)
	f:SetClampedToScreen(true)
	f:Width(360)
	f:Height(110)
	f:SetTemplate('Transparent')
	f:Hide()

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate(nil, true)
	header:Width(120); header:Height(25)
	header:Point('CENTER', f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString(nil, 'OVERLAY')
	title:FontTemplate()
	title:Point('CENTER', header, 'CENTER')
	title:SetText('ElvUI')

	local desc = f:CreateFontString(nil, 'ARTWORK')
	desc:SetFontObject('GameFontHighlight')
	desc:SetJustifyV('TOP')
	desc:SetJustifyH('LEFT')
	desc:Point('TOPLEFT', 18, -32)
	desc:Point('BOTTOMRIGHT', -18, 30)
	f.desc = desc

	f.disableButton = CreateFrame('CheckButton', f:GetName()..'DisableButton', f, 'OptionsCheckButtonTemplate')
	_G[f.disableButton:GetName() .. 'Text']:SetText(DISABLE)
	f.disableButton:Point('BOTTOMLEFT')
	Skins:HandleCheckBox(f.disableButton)
	f.disableButton:SetScript('OnShow', function(btn) btn:SetChecked(E.db.hideTutorial) end)

	f.disableButton:SetScript('OnClick', function(btn) E.db.hideTutorial = btn:GetChecked() end)

	f.hideButton = CreateFrame('Button', f:GetName()..'HideButton', f, 'OptionsButtonTemplate')
	f.hideButton:Point('BOTTOMRIGHT', -5, 5)
	Skins:HandleButton(f.hideButton)
	_G[f.hideButton:GetName() .. 'Text']:SetText(HIDE)
	f.hideButton:SetScript('OnClick', function(btn) E:StaticPopupSpecial_Hide(btn:GetParent()) end)

	f.nextButton = CreateFrame('Button', f:GetName()..'NextButton', f, 'OptionsButtonTemplate')
	f.nextButton:Point('RIGHT', f.hideButton, 'LEFT', -4, 0)
	f.nextButton:Width(20)
	Skins:HandleButton(f.nextButton)
	_G[f.nextButton:GetName() .. 'Text']:SetText('>')
	f.nextButton:SetScript('OnClick', function() E:SetNextTutorial() end)

	f.prevButton = CreateFrame('Button', f:GetName()..'PrevButton', f, 'OptionsButtonTemplate')
	f.prevButton:Point('RIGHT', f.nextButton, 'LEFT', -4, 0)
	f.prevButton:Width(20)
	Skins:HandleButton(f.prevButton)
	_G[f.prevButton:GetName() .. 'Text']:SetText('<')
	f.prevButton:SetScript('OnClick', function() E:SetPrevTutorial() end)

	return f
end

function E:Tutorials(forceShow)
	if (not forceShow and self.db.hideTutorial) or (not forceShow and not self.private.install_complete) then return end
	local f = ElvUITutorialWindow
	if not f then
		f = E:SpawnTutorialFrame()
	end

	E:StaticPopupSpecial_Show(f)

	self:SetNextTutorial()
end
