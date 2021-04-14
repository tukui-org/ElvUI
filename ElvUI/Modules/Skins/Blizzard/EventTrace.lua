local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_EventTrace()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.eventLog) then return end

	-- Frame
	local EventTrace = _G.EventTrace
	EventTrace:StripTextures()
	EventTrace:CreateBackdrop('Transparent')
	S:HandleCloseButton(EventTraceCloseButton)

	-- Top Buttons
	EventTrace.SubtitleBar.ViewLog:StripTextures()
	EventTrace.SubtitleBar.ViewFilter:StripTextures()
	S:HandleButton(EventTrace.SubtitleBar.ViewLog)
	S:HandleButton(EventTrace.SubtitleBar.ViewFilter)

	-- Options Dropdown
	local OptionsDropDown = EventTrace.SubtitleBar.OptionsDropDown
	OptionsDropDown:SetWidth(135)
	S:HandleButton(OptionsDropDown)

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
	EventTrace.ResizeButton:SetAlpha(0)

end

S:AddCallbackForAddon('Blizzard_EventTrace')
