local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

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

	-- Options Dropdown
	local SubtitleBar = EventTrace.SubtitleBar
	SubtitleBar.OptionsDropdown:SetWidth(135)
	S:HandleButton(SubtitleBar.OptionsDropdown)

	-- Log Bar
	local LogBar = EventTrace.Log.Bar
	S:HandleEditBox(LogBar.SearchBox)
	LogBar.SearchBox:SetHeight(18)

	-- Menu Buttons
	local FilterBar = EventTrace.Filter.Bar
	for _, button in next, {
		SubtitleBar.ViewLog,
		SubtitleBar.ViewFilter,
		LogBar.DiscardAllButton,
		LogBar.PlaybackButton,
		LogBar.MarkButton,
		FilterBar.DiscardAllButton,
		FilterBar.UncheckAllButton,
		FilterBar.CheckAllButton,
	} do
		button:StripTextures()
		S:HandleButton(button)
	end

	-- Resize Button
	EventTrace.ResizeButton:ClearAllPoints()
	EventTrace.ResizeButton:Point('BOTTOMRIGHT', 1, -1)

	ReskinEventTraceFrame(EventTrace.Log.Events)
	ReskinEventTraceFrame(EventTrace.Log.Search)
	ReskinEventTraceFrame(EventTrace.Filter)
end

S:AddCallbackForAddon('Blizzard_EventTrace')
