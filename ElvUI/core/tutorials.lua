local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

E.TutorialList = {
	L['For technical support visit us at www.tukui.org.'],
	L['You can toggle the microbar by using your middle mouse button on the minimap.'],
	L['A raid marker feature is available by pressing Escape -> Keybinds scroll to the bottom under ElvUI and setting a keybind for the raid marker.'],
	L['You can set your keybinds quickly by typing /kb.'],
	L['If you need to reset the gold datatext type /resetgold.']
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
	local f = CreateFrame("Frame", "ElvUITutorialWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate('Transparent')
	f:SetPoint("TOP", 0, -50)
	f:Hide()

	local S = E:GetModule('Skins')

	local header = CreateFrame('Button', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(120); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)
	header:EnableMouse(true)
	header:RegisterForClicks('AnyUp', 'AnyDown')
	header:SetScript('OnMouseDown', function() f:StartMoving() end)
	header:SetScript('OnMouseUp', function() f:StopMovingOrSizing() end)
	
	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 30)
	f.desc = desc
	
	f.disableButton = CreateFrame("CheckButton", f:GetName()..'DisableButton', f, "OptionsCheckButtonTemplate")
	_G[f.disableButton:GetName() .. "Text"]:SetText(DISABLE)
	f.disableButton:SetPoint("BOTTOMLEFT")
	S:HandleCheckBox(f.disableButton)
	f.disableButton:SetScript("OnShow", function(self) self:SetChecked(E.db.hideTutorial) end)

	f.disableButton:SetScript("OnClick", function(self) E.db.hideTutorial = self:GetChecked() end)

	f.hideButton = CreateFrame("Button", f:GetName()..'HideButton', f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -5, 5)	
	S:HandleButton(f.hideButton)	
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)
	f.hideButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	
	f.nextButton = CreateFrame("Button", f:GetName()..'NextButton', f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, 'LEFT', -4, 0)	
	f.nextButton:Width(20)
	S:HandleButton(f.nextButton)	
	_G[f.nextButton:GetName() .. "Text"]:SetText('>')
	f.nextButton:SetScript("OnClick", function(self) E:SetNextTutorial() end)

	f.prevButton = CreateFrame("Button", f:GetName()..'PrevButton', f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, 'LEFT', -4, 0)	
	f.prevButton:Width(20)
	S:HandleButton(f.prevButton)	
	_G[f.prevButton:GetName() .. "Text"]:SetText('<')
	f.prevButton:SetScript("OnClick", function(self) E:SetPrevTutorial() end)

	return f
end

function E:Tutorials(forceShow)
	if (not forceShow and self.db.hideTutorial) or (not forceShow and not self.db.install_complete) then return; end
	local f = ElvUITutorialWindow
	if not f then
		f = E:SpawnTutorialFrame()
	end
	
	f:Show()
	
	self:SetNextTutorial()
end