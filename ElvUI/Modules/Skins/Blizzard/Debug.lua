local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

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

local function SkinOnShow()
	local ScriptErrorsFrame = _G.ScriptErrorsFrame
	ScriptErrorsFrame:SetParent(E.UIParent)
	ScriptErrorsFrame:SetTemplate('Transparent')
	S:HandleScrollBar(_G.ScriptErrorsFrameScrollBar)
	S:HandleCloseButton(_G.ScriptErrorsFrameClose)
	ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
	ScriptErrorsFrame.ScrollFrame:CreateBackdrop()
	ScriptErrorsFrame.ScrollFrame:SetFrameLevel(ScriptErrorsFrame.ScrollFrame:GetFrameLevel() + 2)

	for i=1, #FrameTexs do
		_G['ScriptErrorsFrame'..FrameTexs[i]]:SetTexture()
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
	S:HandleButton(ScriptErrorsFrame.Close)
	S:HandleNextPrevButton(ScriptErrorsFrame.PreviousError)
	S:HandleNextPrevButton(ScriptErrorsFrame.NextError)

	S:Unhook(ScriptErrorsFrame, 'OnShow')
end

local function SkinTableAttributeDisplay(frame)
	frame:StripTextures()
	frame:SetTemplate('Transparent')
	frame.ScrollFrameArt:StripTextures()
	frame.ScrollFrameArt:SetTemplate('Transparent')
	S:HandleCloseButton(frame.CloseButton)
	frame.OpenParentButton:ClearAllPoints()
	frame.OpenParentButton:SetPoint('TOPLEFT', frame, 'TOPLEFT', 2, -2)
	S:HandleNextPrevButton(frame.OpenParentButton, 'up')
	frame.OpenParentButton:SetSize(17, 17)
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:SetPoint('LEFT', frame.NavigateForwardButton, 'RIGHT')
	S:HandleCheckBox(frame.VisibilityButton)
	frame.VisibilityButton:SetSize(28, 28)
	S:HandleCheckBox(frame.HighlightButton)
	frame.HighlightButton:SetSize(28, 28)
	S:HandleCheckBox(frame.DynamicUpdateButton)
	frame.DynamicUpdateButton:SetSize(28, 28)
	frame.NavigateBackwardButton:ClearAllPoints()
	frame.NavigateBackwardButton:SetPoint('LEFT', frame.OpenParentButton, 'RIGHT', 2, 0)
	frame.NavigateForwardButton:ClearAllPoints()
	frame.NavigateForwardButton:SetPoint('LEFT', frame.NavigateBackwardButton, 'RIGHT', 2, 0)
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:SetPoint('LEFT', frame.NavigateForwardButton, 'RIGHT', 2, 0)
	S:HandleNextPrevButton(frame.DuplicateButton)
	frame.DuplicateButton:SetSize(17, 17)
	S:HandleNextPrevButton(frame.NavigateBackwardButton)
	S:HandleNextPrevButton(frame.NavigateForwardButton)
	S:HandleEditBox(frame.FilterBox)
	S:HandleScrollBar(frame.LinesScrollFrame.ScrollBar)
end

function S:ScriptErrorsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.debug) then return end

	S:SecureHookScript(_G.ScriptErrorsFrame, 'OnShow', SkinOnShow)
end

function S:Blizzard_DebugTools()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.debug) then return end

	-- Tooltips
	if E.private.skins.blizzard.tooltip then
		_G.FrameStackTooltip:HookScript('OnShow', function(s)
			if not s.template then
				s:SetTemplate('Transparent')
			end
		end)

		_G.EventTraceTooltip:HookScript('OnShow', function(s)
			s:SetTemplate('Transparent', nil, true)
		end)
	end

	for i=1, #FrameTexs do
		_G['EventTraceFrame'..FrameTexs[i]]:SetTexture()
	end

	_G.EventTraceFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.EventTraceFrameCloseButton)

	--New Table Attribute Display: mouse over frame and (/tableinspect or [/fstack -> then Ctrl])
	SkinTableAttributeDisplay(_G.TableAttributeDisplay)
	hooksecurefunc(_G.TableInspectorMixin, 'OnLoad', function(s)
		if s and s.ScrollFrameArt and not s.skinned then
			SkinTableAttributeDisplay(s)
			s.skinned = true
		end
	end)
end

-- ScriptErrorsFrame Skin
S:AddCallback('ScriptErrorsFrame')

-- EventTrace, FrameStack, TableInspect Skins
if _G.IsAddOnLoaded('Blizzard_DebugTools') then
	S:AddCallback('Blizzard_DebugTools')
else
	S:AddCallbackForAddon('Blizzard_DebugTools')
end
