local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local FrameTexs = {
	'TopLeft',
	'TopRight',
	'Top',
	'BottomLeft',
	'BottomRight',
	'Bottom',
	'Left',
	'Right',
	'TitleBG',
	'DialogBG',
}

-- ScriptErrorsFrame Skin
S:AddCallbackForAddon('Blizzard_ScriptErrorsFrame', nil, nil, nil, nil, nil, 'debug')

-- FrameStack, TableInspect Skins
if IsAddOnLoaded('Blizzard_DebugTools') then
	S:AddCallback('Blizzard_DebugTools', nil, nil, 'debug')
else
	S:AddCallbackForAddon('Blizzard_DebugTools', nil, nil, nil, nil, nil, 'debug')
end

local function SkinOnShow()
	local ScriptErrorsFrame = _G.ScriptErrorsFrame
	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.ScriptErrorsFrameClose)

	ScriptErrorsFrame.ScrollFrame:SetTemplate()
	ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
	ScriptErrorsFrame.ScrollFrame:OffsetFrameLevel(2)

	S:HandleTrimScrollBar(_G.ScriptErrorsFrame.ScrollFrame.ScrollBar)
	ScriptErrorsFrame.ScrollFrame.ScrollBar:Point('TOPLEFT', ScriptErrorsFrame.ScrollFrame, 'TOPRIGHT', 4, 2)
	ScriptErrorsFrame.ScrollFrame.ScrollBar:Point('BOTTOMLEFT', ScriptErrorsFrame.ScrollFrame, 'BOTTOMRIGHT', 4, 2)

	for _, name in next, FrameTexs do
		_G['ScriptErrorsFrame'..name]:SetTexture()
	end

	-- Our Buttons
	if ScriptErrorsFrame.firstButton then
		S:HandleButton(ScriptErrorsFrame.firstButton)
	end
	if ScriptErrorsFrame.lastButton then
		S:HandleButton(ScriptErrorsFrame.lastButton)
	end

	-- Default Buttons
	S:HandleButton(ScriptErrorsFrame.Reload)
	S:HandleButton(E.Forever and ScriptErrorsFrame.CloseButton or ScriptErrorsFrame.Close)
	S:HandleNextPrevButton(ScriptErrorsFrame.PreviousError)
	S:HandleNextPrevButton(ScriptErrorsFrame.NextError)

	S:Unhook(ScriptErrorsFrame, 'OnShow')
end

local function SkinTableAttributeDisplay(frame)
	if frame.IsSkinned then return end

	frame:StripTextures()
	frame:SetTemplate('Transparent')
	frame.ScrollFrameArt.NineSlice:SetTemplate('Transparent')
	frame.ScrollFrameArt.NineSlice:Point('TOPLEFT', -4, 0)
	frame.ScrollFrameArt.NineSlice:Point('BOTTOMRIGHT', -8, 0)

	S:HandleTrimScrollBar(frame.LinesScrollFrame.ScrollBar)

	if not E.Modern then
		frame.LinesScrollFrame.ScrollBar.Track:Point('TOPLEFT', 12, -20)
	end

	frame.LinesScrollFrame.ScrollBar.Track.Thumb:Width(8)

	S:HandleCloseButton(frame.CloseButton)
	frame.OpenParentButton:ClearAllPoints()
	frame.OpenParentButton:Point('TOPLEFT', frame, 'TOPLEFT', 2, -2)
	S:HandleNextPrevButton(frame.OpenParentButton, 'up')
	frame.OpenParentButton:Size(17)
	S:HandleCheckBox(frame.VisibilityButton)
	frame.VisibilityButton:Size(28)
	S:HandleCheckBox(frame.HighlightButton)
	frame.HighlightButton:Size(28)
	S:HandleCheckBox(frame.DynamicUpdateButton)
	frame.DynamicUpdateButton:Size(28)
	frame.NavigateBackwardButton:ClearAllPoints()
	frame.NavigateBackwardButton:Point('LEFT', frame.OpenParentButton, 'RIGHT', 2, 0)
	frame.NavigateForwardButton:ClearAllPoints()
	frame.NavigateForwardButton:Point('LEFT', frame.NavigateBackwardButton, 'RIGHT', 2, 0)
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:Point('LEFT', frame.NavigateForwardButton, 'RIGHT', 2, 0)
	S:HandleNextPrevButton(frame.DuplicateButton)
	frame.DuplicateButton:Size(17)
	S:HandleNextPrevButton(frame.NavigateBackwardButton)
	S:HandleNextPrevButton(frame.NavigateForwardButton)
	S:HandleEditBox(frame.FilterBox)

	frame.IsSkinned = true
end

function S:Blizzard_ScriptErrorsFrame()
	S:SecureHookScript(_G.ScriptErrorsFrame, 'OnShow', SkinOnShow)
end

function S:Blizzard_DebugTools()
	-- Tooltips
	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(_G.FrameStackTooltip)
	end

	--New Table Attribute Display: mouse over frame and (/tableinspect or [/fstack -> then Ctrl])
	SkinTableAttributeDisplay(_G.TableAttributeDisplay)
	hooksecurefunc(_G.TableInspectorMixin, 'OnLoad', SkinTableAttributeDisplay)
end
