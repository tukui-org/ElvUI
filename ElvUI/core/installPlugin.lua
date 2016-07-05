local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local PI = E:NewModule("PluginInstaller")

--Installation Functions
PI.Installs = {}
local f

local function ResetAll()
	PluginInstallNextButton:Disable()
	PluginInstallPrevButton:Disable()
	PluginInstallOption1Button:Hide()
	PluginInstallOption1Button:SetScript("OnClick", nil)
	PluginInstallOption1Button:SetText("")
	PluginInstallOption2Button:Hide()
	PluginInstallOption2Button:SetScript('OnClick', nil)
	PluginInstallOption2Button:SetText('')
	PluginInstallOption3Button:Hide()
	PluginInstallOption3Button:SetScript('OnClick', nil)
	PluginInstallOption3Button:SetText('')
	PluginInstallOption4Button:Hide()
	PluginInstallOption4Button:SetScript('OnClick', nil)
	PluginInstallOption4Button:SetText('')
	PluginInstallFrame.SubTitle:SetText("")
	PluginInstallFrame.Desc1:SetText("")
	PluginInstallFrame.Desc2:SetText("")
	PluginInstallFrame.Desc3:SetText("")
	PluginInstallFrame:Size(550, 400)
end

local function SetPage(PageNum)
	f.CurrentPage = PageNum
	ResetAll()
	PluginInstallStatus:SetValue(PageNum)

	if PageNum == f.MaxPage then
		PluginInstallNextButton:Disable()
	else
		PluginInstallNextButton:Enable()
	end

	if PageNum == 1 then
		PluginInstallPrevButton:Disable()
	else
		PluginInstallPrevButton:Enable()
	end

	f.Pages[f.CurrentPage]()
	f.Status.text:SetText(f.CurrentPage.." / "..f.MaxPage)
end

local function NextPage()
	if f.CurrentPage ~= f.MaxPage then
		f.CurrentPage = f.CurrentPage + 1
		SetPage(f.CurrentPage)
	end
end

local function PreviousPage()
	if f.CurrentPage ~= 1 then
		f.CurrentPage = f.CurrentPage - 1
		SetPage(f.CurrentPage)
	end
end

function PI:CreateStepComplete()
	local imsg = CreateFrame("Frame", "PluginInstallStepComplete", E.UIParent)
	imsg:Size(418, 72)
	imsg:Point("TOP", 0, -190)
	imsg:Hide()
	imsg:SetScript('OnShow', function(self)
		if self.message then
			PlaySoundFile([[Sound\Interface\LevelUp.wav]])
			self.text:SetText(self.message)
			UIFrameFadeOut(self, 3.5, 1, 0)
			E:Delay(4, function() self:Hide() end)
			self.message = nil
		else
			self:Hide()
		end
	end)

	imsg.firstShow = false

	imsg.bg = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.bg:SetPoint('BOTTOM')
	imsg.bg:Size(326, 103)
	imsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	imsg.bg:SetVertexColor(1, 1, 1, 0.6)

	imsg.lineTop = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.lineTop:SetDrawLayer('BACKGROUND', 2)
	imsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineTop:SetPoint("TOP")
	imsg.lineTop:Size(418, 7)
	imsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.lineBottom = imsg:CreateTexture(nil, 'BACKGROUND')
	imsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
	imsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	imsg.lineBottom:SetPoint("BOTTOM")
	imsg.lineBottom:Size(418, 7)
	imsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	imsg.text = imsg:CreateFontString(nil, 'ARTWORK', 'GameFont_Gigantic')
	imsg.text:Point("BOTTOM", 0, 12)
	imsg.text:SetTextColor(1, 0.82, 0)
	imsg.text:SetJustifyH("CENTER")
end

function PI:CreateFrame()
	f = CreateFrame("Button", "PluginInstallFrame", E.UIParent)
	f.SetPage = SetPage
	f:Size(550, 400)
	f:SetTemplate("Transparent")
	f:SetPoint("CENTER")
	f:SetFrameStrata('TOOLTIP')

	f.Title = f:CreateFontString(nil, 'OVERLAY')
	f.Title:FontTemplate(nil, 17, nil)
	f.Title:Point("TOP", 0, -5)

	f.Next = CreateFrame("Button", "PluginInstallNextButton", f, "UIPanelButtonTemplate")
	f.Next:StripTextures()
	f.Next:SetTemplate("Default", true)
	f.Next:Size(110, 25)
	f.Next:Point("BOTTOMRIGHT", -5, 5)
	f.Next:SetText(CONTINUE)
	f.Next:Disable()
	f.Next:SetScript("OnClick", NextPage)
	E.Skins:HandleButton(f.Next, true)

	f.Prev = CreateFrame("Button", "PluginInstallPrevButton", f, "UIPanelButtonTemplate")
	f.Prev:StripTextures()
	f.Prev:SetTemplate("Default", true)
	f.Prev:Size(110, 25)
	f.Prev:Point("BOTTOMLEFT", 5, 5)
	f.Prev:SetText(PREVIOUS)
	f.Prev:Disable()
	f.Prev:SetScript("OnClick", PreviousPage)
	E.Skins:HandleButton(f.Prev, true)

	f.Status = CreateFrame("StatusBar", "PluginInstallStatus", f)
	f.Status:SetFrameLevel(f.Status:GetFrameLevel() + 2)
	f.Status:CreateBackdrop("Default")
	f.Status:SetStatusBarTexture(E["media"].normTex)
	f.Status:SetStatusBarColor(unpack(E["media"].rgbvaluecolor))
	f.Status:Point("TOPLEFT", f.Prev, "TOPRIGHT", 6, -2)
	f.Status:Point("BOTTOMRIGHT", f.Next, "BOTTOMLEFT", -6, 2)
	f.Status.text = f.Status:CreateFontString(nil, 'OVERLAY')
	f.Status.text:FontTemplate()
	f.Status.text:SetPoint("CENTER")

	f.Option1 = CreateFrame("Button", "PluginInstallOption1Button", f, "UIPanelButtonTemplate")
	f.Option1:StripTextures()
	f.Option1:Size(160, 30)
	f.Option1:Point("BOTTOM", 0, 45)
	f.Option1:SetText("")
	f.Option1:Hide()
	E.Skins:HandleButton(f.Option1, true)

	f.Option2 = CreateFrame("Button", "PluginInstallOption2Button", f, "UIPanelButtonTemplate")
	f.Option2:StripTextures()
	f.Option2:Size(110, 30)
	f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45)
	f.Option2:SetText("")
	f.Option2:Hide()
	f.Option2:SetScript('OnShow', function() f.Option1:SetWidth(110); f.Option1:ClearAllPoints(); f.Option1:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45) end)
	f.Option2:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45) end)
	E.Skins:HandleButton(f.Option2, true)

	f.Option3 = CreateFrame("Button", "PluginInstallOption3Button", f, "UIPanelButtonTemplate")
	f.Option3:StripTextures()
	f.Option3:Size(100, 30)
	f.Option3:Point('LEFT', f.Option2, 'RIGHT', 4, 0)
	f.Option3:SetText("")
	f.Option3:Hide()
	f.Option3:SetScript('OnShow', function() f.Option1:SetWidth(100); f.Option1:ClearAllPoints(); f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0); f.Option2:SetWidth(100); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOM', f, 'BOTTOM', 0, 45)  end)
	f.Option3:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:SetWidth(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
	E.Skins:HandleButton(f.Option3, true)

	f.Option4 = CreateFrame("Button", "PluginInstallOption4Button", f, "UIPanelButtonTemplate")
	f.Option4:StripTextures()
	f.Option4:Size(100, 30)
	f.Option4:Point('LEFT', f.Option3, 'RIGHT', 4, 0)
	f.Option4:SetText("")
	f.Option4:Hide()
	f.Option4:SetScript('OnShow', function()
		f.Option1:Width(100)
		f.Option2:Width(100)

		f.Option1:ClearAllPoints();
		f.Option1:Point('RIGHT', f.Option2, 'LEFT', -4, 0);
		f.Option2:ClearAllPoints();
		f.Option2:Point('BOTTOMRIGHT', f, 'BOTTOM', -4, 45)
	end)
	f.Option4:SetScript('OnHide', function() f.Option1:SetWidth(160); f.Option1:ClearAllPoints(); f.Option1:Point("BOTTOM", 0, 45); f.Option2:SetWidth(110); f.Option2:ClearAllPoints(); f.Option2:Point('BOTTOMLEFT', f, 'BOTTOM', 4, 45) end)
	E.Skins:HandleButton(f.Option4, true)

	f.SubTitle = f:CreateFontString(nil, 'OVERLAY')
	f.SubTitle:FontTemplate(nil, 15, nil)
	f.SubTitle:Point("TOP", 0, -40)

	f.Desc1 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc1:FontTemplate()
	f.Desc1:Point("TOPLEFT", 20, -75)
	f.Desc1:Width(f:GetWidth() - 40)

	f.Desc2 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc2:FontTemplate()
	f.Desc2:Point("TOP", f.Desc1, "BOTTOM", 0, -20)
	f.Desc2:Width(f:GetWidth() - 40)

	f.Desc3 = f:CreateFontString(nil, 'OVERLAY')
	f.Desc3:FontTemplate()
	f.Desc3:Point("TOP", f.Desc2, "BOTTOM", 0, -20)
	f.Desc3:Width(f:GetWidth() - 40)

	local close = CreateFrame("Button", "PluginInstallCloseButton", f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT")
	close:SetScript("OnClick", function()
		PI:CloseInstall()
		f:Hide()
	end)
	E.Skins:HandleCloseButton(close)

	local pending = CreateFrame("Frame", "PluginInstallPendingButton", f)
	pending:Size(20, 20)
	pending:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8)
	pending:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", E.PixelMode and -7 or -9); PI:PendingList(); GameTooltip:Show() end)
	pending:SetScript("OnLeave", function() GameTooltip:Hide() end)
	pending.tex = pending:CreateTexture(nil, 'OVERLAY')
	pending.tex:Point('TOPLEFT', pending, 'TOPLEFT', 2, -2)
	pending.tex:Point('BOTTOMRIGHT', pending, 'BOTTOMRIGHT', -2, 2)
	pending.tex:SetTexture([[Interface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon]])
	pending:CreateBackdrop("Transparent")

	f.tutorialImage = f:CreateTexture('PluginInstallTutorialImage', 'OVERLAY')
	f.tutorialImage:Size(256, 128)
	f.tutorialImage:Point('BOTTOM', 0, 70)

	f:Hide()
end

--Plugins pass their info using the table like:
--[[ 
	addon = {
		Name = "AddOnName",
		tutorialImage = "TexturePath",
		Pages = {
			[1] = function1,
			[2] = function2,
			[3] = function3,
		}
	}
	where function is what previously was used to set layout
	function function1()
		PluginInstallFrame.SubTitle:SetText("Title Text")
		PluginInstallFrame.Desc1:SetText("Desc 1 Tet")
		PluginInstallFrame.Desc2:SetText("Desc 2 Tet")
		PluginInstallFrame.Desc3:SetText("Desc 3 Tet")

		PluginInstallFrame.Option1:Show()
		PluginInstallFrame.Option1:SetScript('OnClick', function() <Do Some Stuff> end)
		PluginInstallFrame.Option1:SetText("Text 1")

		PluginInstallFrame.Option2:Show()
		PluginInstallFrame.Option2:SetScript('OnClick', function() <Do Some Other Stuff> end)
		PluginInstallFrame.Option2:SetText("Text 2")
	end
]]
function PI:Queue(addon)
	local queue = true
	for k, v in pairs(self.Installs) do
		if v.Name == addon.Name then queue = false end
	end

	if queue then tinsert(self.Installs, #(self.Installs)+1, addon); self:RunInstall() end
end

function PI:CloseInstall()
	tremove(self.Installs, 1)
end

function PI:RunInstall()
	if not E.private.install_complete then return end
	if self.Installs[1] and not PluginInstallFrame:IsShown() and not (ElvUIInstallFrame and ElvUIInstallFrame:IsShown()) then
		local db = self.Installs[1]
		f.CurrentPage = 0
		f.MaxPage = #(db.Pages)

		f.Title:SetText(db.Title or L["ElvUI Plugin Installation"])
		f.Status:SetMinMaxValues(0, f.MaxPage)
		f.Status.text:SetText(f.CurrentPage.." / "..f.MaxPage)
		f.tutorialImage:SetTexture(db.tutorialImage or [[Interface\AddOns\ElvUI\media\textures\logo.tga]])

		f.Pages = db.Pages

		PluginInstallFrame:Show()
		NextPage()
	end
	if #(self.Installs) > 1 then
		PluginInstallPendingButton:Show()
		E:Flash(PluginInstallPendingButton, 0.53, true)
	else
		PluginInstallPendingButton:Hide()
		E:StopFlash(PluginInstallPendingButton)
	end
end

function PI:PendingList()
	GameTooltip:AddLine(L["List of installations in queue:"], 1, 1, 1)
	GameTooltip:AddLine(" ")
	for i = 1, #(self.Installs) do
		GameTooltip:AddDoubleLine(i..". "..self.Installs[i].Name or UNKNOWN, i == 1 and "|cff00FF00"..L["In Progress"].."|r" or "|cffFF0000"..L["Pending"].."|r")
	end
end

function PI:Initialize()
	PI:CreateStepComplete()
	PI:CreateFrame()
end

E:RegisterModule(PI:GetName())