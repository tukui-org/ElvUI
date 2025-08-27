local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function ReskinEventTraceButton(button)
	S:HandleButton(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function ReskinScrollUpdateChild(child)
	local button = child.HideButton
	if button and not button.IsSkinned then
		S:HandleCloseButton(button)

		button:ClearAllPoints()
		button:Point('LEFT', 3, 0)

		local checkButton = child.CheckButton
		if checkButton then
			S:HandleCheckBox(checkButton)
			checkButton:SetSize(22, 22)
		end

		button.IsSkinned = true
	end
end

local function ReskinScrollUpdate(frame)
	frame:ForEachFrame(ReskinScrollUpdateChild)
end

local function ReskinEventTraceScrollBox(frame)
	frame:DisableDrawLayer('BACKGROUND')
	frame:CreateBackdrop('Transparent')

	hooksecurefunc(frame, 'Update', ReskinScrollUpdate)
end

local function ReskinEventTraceFrame(frame)
	ReskinEventTraceScrollBox(frame.ScrollBox)
	S:HandleTrimScrollBar(frame.ScrollBar)
end

function S:Blizzard_EventTrace()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.eventLog) then return end

	-- Frame
	local EventTrace = _G.EventTrace
	EventTrace:StripTextures()
	EventTrace:CreateBackdrop('Transparent')
	S:HandleCloseButton(_G.EventTraceCloseButton)

	_G.EventTraceTooltip:SetFrameLevel(10)

	-- Top Buttons
	local SubtitleBar = EventTrace.SubtitleBar
	EventTrace.SubtitleBar.ViewLog:StripTextures()
	EventTrace.SubtitleBar.ViewFilter:StripTextures()
	S:HandleButton(EventTrace.SubtitleBar.ViewLog)
	S:HandleButton(EventTrace.SubtitleBar.ViewFilter)

	-- Options Dropdown
	S:HandleButton(EventTrace.SubtitleBar.OptionsDropdown)

	-- Log Bar
	local LogBar = EventTrace.Log.Bar
	S:HandleEditBox(LogBar.SearchBox)
	LogBar.SearchBox:SetHeight(18)
	LogBar.DiscardAllButton:StripTextures()
	LogBar.PlaybackButton:StripTextures()
	LogBar.MarkButton:StripTextures()
	S:HandleButton(LogBar.DiscardAllButton)
	S:HandleButton(LogBar.PlaybackButton)
	S:HandleButton(LogBar.MarkButton)

	-- Filter Bar
	local FilterBar = EventTrace.Filter.Bar
	FilterBar.DiscardAllButton:StripTextures()
	FilterBar.UncheckAllButton:StripTextures()
	FilterBar.CheckAllButton:StripTextures()
	S:HandleButton(FilterBar.DiscardAllButton)
	S:HandleButton(FilterBar.UncheckAllButton)
	S:HandleButton(FilterBar.CheckAllButton)

	-- Resize Button
	EventTrace.ResizeButton:ClearAllPoints()
	EventTrace.ResizeButton:Point('BOTTOMRIGHT', 1, -1)

	ReskinEventTraceFrame(EventTrace.Log.Events)
	ReskinEventTraceFrame(EventTrace.Log.Search)
	ReskinEventTraceFrame(EventTrace.Filter)

	local buttons = {
		SubtitleBar.ViewLog,
		SubtitleBar.ViewFilter,
		LogBar.DiscardAllButton,
		LogBar.PlaybackButton,
		LogBar.MarkButton,
		FilterBar.DiscardAllButton,
		FilterBar.UncheckAllButton,
		FilterBar.CheckAllButton,
	}

	for _, button in pairs(buttons) do
		ReskinEventTraceButton(button)
	end
end

S:AddCallbackForAddon('Blizzard_EventTrace')
