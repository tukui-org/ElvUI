local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local select = select
local hooksecurefunc = hooksecurefunc

local function ReskinEventTraceButton(button)
	S:HandleButton(button)
	button.NormalTexture:SetAlpha(0)
	button.MouseoverOverlay:SetAlpha(0)
end

local function ReskinScrollArrow(self, direction) -- simpy needs to finish that :P
	self.Texture:SetAlpha(0)
	self.Overlay:SetAlpha(0)

	local tex = self:CreateTexture(nil, 'ARTWORK')
	tex:SetAllPoints()
	tex:CreateBackdrop('Transparent')
end

local function reskinScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local hideButton = child and child.HideButton
		if hideButton and not hideButton.IsSkinned then
			S:HandleCloseButton(hideButton)

			hideButton:ClearAllPoints()
			hideButton:SetPoint('LEFT', 3, 0)

			local checkButton = child.CheckButton
			if checkButton then
				S:HandleCheckBox(checkButton)
				checkButton:SetSize(22, 22)
			end

			hideButton.IsSkinned = true
		end
	end
end

local function ReskinEventTraceScrollBox(frame)
	frame:DisableDrawLayer('BACKGROUND')
	frame:CreateBackdrop('Transparent')
	hooksecurefunc(frame, 'Update', reskinScrollChild)
end

local function ReskinEventTraceFrame(frame)
	ReskinEventTraceScrollBox(frame.ScrollBox)
end

function S:Blizzard_EventTrace()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.eventLog) then return end

	-- Frame
	local EventTrace = _G.EventTrace
	EventTrace:StripTextures()
	EventTrace:CreateBackdrop('Transparent')
	S:HandleCloseButton(_G.EventTraceCloseButton)

	-- Top Buttons
	local SubtitleBar = EventTrace.SubtitleBar
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
