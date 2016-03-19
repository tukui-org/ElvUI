local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true then return end
	local frames = {
		"HelpFrameLeftInset",
		"HelpFrameMainInset",
		"HelpFrameKnowledgebase",
		"HelpFrameKnowledgebaseErrorFrame",
	}

	local buttons = {
		"HelpFrameAccountSecurityOpenTicket",
		"HelpFrameOpenTicketHelpOpenTicket",
		"HelpFrameKnowledgebaseSearchButton",
		"HelpFrameKnowledgebaseNavBarHomeButton",
		"HelpFrameCharacterStuckStuck",
		"HelpFrameButton16",
		"HelpFrameSubmitSuggestionSubmit",
		"HelpFrameReportBugSubmit",
	}

	-- skin main frames
	for i = 1, #frames do
		_G[frames[i]]:StripTextures(true)
		_G[frames[i]]:CreateBackdrop("Transparent")
	end

	HelpFrameHeader:StripTextures(true)
	HelpFrameHeader:CreateBackdrop("Default", true)
	HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel() + 2)
	HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(HelpFrameKnowledgebaseErrorFrame:GetFrameLevel() + 2)

	HelpFrameReportBugScrollFrame:StripTextures()
	HelpFrameReportBugScrollFrame:CreateBackdrop("Transparent")
	HelpFrameReportBugScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)
	for i=1, HelpFrameReportBug:GetNumChildren() do
		local child = select(i, HelpFrameReportBug:GetChildren())
		if not child:GetName() then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(HelpFrameReportBugScrollFrameScrollBar)

	HelpFrameSubmitSuggestionScrollFrame:StripTextures()
	HelpFrameSubmitSuggestionScrollFrame:CreateBackdrop("Transparent")
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)
	for i=1, HelpFrameSubmitSuggestion:GetNumChildren() do
		local child = select(i, HelpFrameSubmitSuggestion:GetChildren())
		if not child:GetName() then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(HelpFrameSubmitSuggestionScrollFrameScrollBar)
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrame2ScrollBar)

	-- skin sub buttons
	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures(true)
		S:HandleButton(_G[buttons[i]], true)

		if _G[buttons[i]].text then
			_G[buttons[i]].text:ClearAllPoints()
			_G[buttons[i]].text:Point("CENTER")
			_G[buttons[i]].text:SetJustifyH("CENTER")
		end
	end

	-- skin main buttons
	for i = 1, 6 do
		local b = _G["HelpFrameButton"..i]
		S:HandleButton(b, true)
		b.text:ClearAllPoints()
		b.text:Point("CENTER")
		b.text:SetJustifyH("CENTER")
	end

	-- skin table options
	for i = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
		local b = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
		b:StripTextures(true)
		S:HandleButton(b, true)
	end
	
	--Navigation buttons
    S:HandleButton(HelpBrowserNavHome)
	HelpBrowserNavHome:Size(26)
	HelpBrowserNavHome:ClearAllPoints()
	HelpBrowserNavHome:SetPoint("BOTTOMLEFT", HelpBrowser, "TOPLEFT", -5, 9)
	S:HandleNextPrevButton(HelpBrowserNavBack)
	HelpBrowserNavBack:Size(26)
	S:HandleNextPrevButton(HelpBrowserNavForward)
	HelpBrowserNavForward:Size(26)
	S:HandleButton(HelpBrowserNavReload)
	HelpBrowserNavReload:Size(26)
	S:HandleButton(HelpBrowserNavStop)
	HelpBrowserNavStop:Size(26)
	S:HandleButton(HelpBrowserBrowserSettings)
	HelpBrowserBrowserSettings:Size(26)
	HelpBrowserBrowserSettings:ClearAllPoints()
	HelpBrowserBrowserSettings:SetPoint("TOPRIGHT", HelpFrameCloseButton, "TOPLEFT", -3, -8)

	-- skin misc items
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)
	HelpFrameKnowledgebaseNavBarOverlay:Kill()
	HelpFrameKnowledgebaseNavBar:StripTextures()

	HelpFrame:StripTextures(true)
	HelpFrame:CreateBackdrop("Transparent")
	S:HandleEditBox(HelpFrameKnowledgebaseSearchBox)
	S:HandleScrollBar(HelpFrameKnowledgebaseScrollFrameScrollBar, 5)
	S:HandleCloseButton(HelpFrameCloseButton, HelpFrame.backdrop)
	S:HandleCloseButton(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.backdrop)

	--Hearth Stone Button
	HelpFrameCharacterStuckHearthstone:StyleButton()
	HelpFrameCharacterStuckHearthstone:SetTemplate("Default", true)
	HelpFrameCharacterStuckHearthstone.IconTexture:SetInside()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(unpack(E.TexCoords))

	S:HandleButton(HelpFrameGM_ResponseNeedMoreHelp)
	S:HandleButton(HelpFrameGM_ResponseCancel)
	for i=1, HelpFrameGM_Response:GetNumChildren() do
		local child = select(i, HelpFrameGM_Response:GetChildren())
		if child and child:GetObjectType() == "Frame" and not child:GetName() then
			child:SetTemplate("Default")
		end
	end
end

S:RegisterSkin('ElvUI', LoadSkin)