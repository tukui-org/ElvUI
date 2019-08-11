local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local select, unpack = select, unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.help ~= true then return end

	local frames = {
		_G.HelpFrameLeftInset,
		_G.HelpFrameMainInset,
		_G.HelpFrameKnowledgebase,
		_G.HelpFrameKnowledgebaseErrorFrame,
	}

	local buttons = {
		_G.HelpFrameAccountSecurityOpenTicket,
		_G.HelpFrameOpenTicketHelpOpenTicket,
		_G.HelpFrameKnowledgebaseSearchButton,
		_G.HelpFrameKnowledgebaseNavBarHomeButton,
		_G.HelpFrameCharacterStuckStuck,
		_G.HelpFrameButton16,
		_G.HelpFrameSubmitSuggestionSubmit,
		_G.HelpFrameReportBugSubmit,
	}

	for i = 1, #frames do
		frames[i]:StripTextures(true)
		frames[i]:CreateBackdrop("Transparent")
	end

	local HelpFrameHeader = _G.HelpFrameHeader
	HelpFrameHeader:StripTextures(true)
	HelpFrameHeader:CreateBackdrop(nil, true)
	HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel() + 2)
	_G.HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(_G.HelpFrameKnowledgebaseErrorFrame:GetFrameLevel() + 2)

	local HelpFrameReportBugScrollFrame = _G.HelpFrameReportBugScrollFrame
	HelpFrameReportBugScrollFrame:StripTextures()
	HelpFrameReportBugScrollFrame:CreateBackdrop("Transparent")
	HelpFrameReportBugScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)

	for i = 1, _G.HelpFrameReportBug:GetNumChildren() do
		local child = select(i, _G.HelpFrameReportBug:GetChildren())
		if child and not child:GetName() then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(_G.HelpFrameReportBugScrollFrameScrollBar)

	local HelpFrameSubmitSuggestionScrollFrame = _G.HelpFrameSubmitSuggestionScrollFrame
	HelpFrameSubmitSuggestionScrollFrame:StripTextures()
	HelpFrameSubmitSuggestionScrollFrame:CreateBackdrop("Transparent")
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)
	for i=1, _G.HelpFrameSubmitSuggestion:GetNumChildren() do
		local child = select(i, _G.HelpFrameSubmitSuggestion:GetChildren())
		if not child:GetName() then
			child:StripTextures()
		end
	end

	S:HandleScrollBar(_G.HelpFrameSubmitSuggestionScrollFrameScrollBar)
	S:HandleScrollBar(_G.HelpFrameKnowledgebaseScrollFrame2ScrollBar)

	-- skin sub buttons
	for i = 1, #buttons do
		buttons[i]:StripTextures(true)
		S:HandleButton(buttons[i], true)

		if buttons[i].text then
			buttons[i].text:ClearAllPoints()
			buttons[i].text:Point("CENTER")
			buttons[i].text:SetJustifyH("CENTER")
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
	for i = 1, _G.HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
		local b = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
		b:StripTextures(true)
		S:HandleButton(b, true)
	end

	--Navigation buttons
	local HelpBrowserNavHome = _G.HelpBrowserNavHome
	S:HandleButton(HelpBrowserNavHome)
	HelpBrowserNavHome:Size(26)
	HelpBrowserNavHome:ClearAllPoints()
	HelpBrowserNavHome:Point("BOTTOMLEFT", _G.HelpBrowser, "TOPLEFT", -5, 9)
	S:HandleNextPrevButton(_G.HelpBrowserNavBack)
	_G.HelpBrowserNavBack:Size(26)
	S:HandleNextPrevButton(_G.HelpBrowserNavForward)
	_G.HelpBrowserNavForward:Size(26)
	S:HandleButton(_G.HelpBrowserNavReload)
	_G.HelpBrowserNavReload:Size(26)
	S:HandleButton(_G.HelpBrowserNavStop)
	_G.HelpBrowserNavStop:Size(26)
	S:HandleButton(_G.HelpBrowserBrowserSettings)
	_G.HelpBrowserBrowserSettings:Size(26)
	_G.HelpBrowserBrowserSettings:ClearAllPoints()
	_G.HelpBrowserBrowserSettings:Point("TOPRIGHT", _G.HelpFrameCloseButton, "TOPLEFT", -3, -8)

	-- skin misc items
	_G.HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	_G.HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", _G.HelpFrameMainInset, "TOPLEFT", 13, -10)
	_G.HelpFrameKnowledgebaseNavBar:StripTextures()

	local HelpFrame = _G.HelpFrame
	HelpFrame:StripTextures(true)
	HelpFrame:CreateBackdrop("Transparent")
	S:HandleEditBox(_G.HelpFrameKnowledgebaseSearchBox)
	S:HandleScrollBar(_G.HelpFrameKnowledgebaseScrollFrameScrollBar, 5)
	S:HandleCloseButton(_G.HelpFrameCloseButton, HelpFrame.backdrop)
	S:HandleCloseButton(_G.HelpFrameKnowledgebaseErrorFrameCloseButton, _G.HelpFrameKnowledgebaseErrorFrame.backdrop)

	--Hearth Stone Button
	local HelpFrameCharacterStuckHearthstone = _G.HelpFrameCharacterStuckHearthstone
	HelpFrameCharacterStuckHearthstone:StyleButton()
	HelpFrameCharacterStuckHearthstone:SetTemplate(nil, true)
	HelpFrameCharacterStuckHearthstone.IconTexture:SetInside()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(unpack(E.TexCoords))

	S:HandleButton(_G.HelpFrameGM_ResponseNeedMoreHelp)
	S:HandleButton(_G.HelpFrameGM_ResponseCancel)
	for i=1, _G.HelpFrameGM_Response:GetNumChildren() do
		local child = select(i, _G.HelpFrameGM_Response:GetChildren())
		if child and child:IsObjectType('Frame') and not child:GetName() then
			child:SetTemplate()
		end
	end
end

S:AddCallback("Help", LoadSkin)
