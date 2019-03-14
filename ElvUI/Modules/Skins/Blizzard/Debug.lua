local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local FrameTexs = {
	"TopLeft",
	"TopRight",
	"Top",
	"BottomLeft",
	"BottomRight",
	"Bottom",
	"Left",
	"Right",
	"TitleBG",
	"DialogBG",
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
		_G["ScriptErrorsFrame"..FrameTexs[i]]:SetTexture()
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
	frame:SetTemplate("Transparent")
	frame.ScrollFrameArt:StripTextures()
	frame.ScrollFrameArt:SetTemplate("Transparent")
	S:HandleCloseButton(frame.CloseButton)
	frame.OpenParentButton:ClearAllPoints()
	frame.OpenParentButton:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
	S:HandleNextPrevButton(frame.OpenParentButton, 'up')
	frame.OpenParentButton:Size(17)
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:Point("LEFT", frame.NavigateForwardButton, "RIGHT")
	S:HandleCheckBox(frame.VisibilityButton)
	frame.VisibilityButton:Size(28)
	S:HandleCheckBox(frame.HighlightButton)
	frame.HighlightButton:Size(28)
	S:HandleCheckBox(frame.DynamicUpdateButton)
	frame.DynamicUpdateButton:Size(28)
	frame.NavigateBackwardButton:ClearAllPoints()
	frame.NavigateBackwardButton:Point("LEFT", frame.OpenParentButton, "RIGHT", 2, 0)
	frame.NavigateForwardButton:ClearAllPoints()
	frame.NavigateForwardButton:Point("LEFT", frame.NavigateBackwardButton, "RIGHT", 2, 0)
	frame.DuplicateButton:ClearAllPoints()
	frame.DuplicateButton:Point("LEFT", frame.NavigateForwardButton, "RIGHT", 2, 0)
	S:HandleNextPrevButton(frame.DuplicateButton)
	frame.DuplicateButton:Size(17)
	S:HandleNextPrevButton(frame.NavigateBackwardButton)
	S:HandleNextPrevButton(frame.NavigateForwardButton)
	S:HandleEditBox(frame.FilterBox)
	S:HandleScrollBar(frame.LinesScrollFrame.ScrollBar)
end

local function LoadErrorFrameSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	S:SecureHookScript(_G.ScriptErrorsFrame, 'OnShow', SkinOnShow)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	-- Tooltips
	if E.private.skins.blizzard.tooltip then
		_G.FrameStackTooltip:HookScript("OnShow", function(self)
			if not self.template then
				self:SetTemplate("Transparent")
			end
		end)

		_G.EventTraceTooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent", nil, true)
		end)
	end

	for i=1, #FrameTexs do
		_G["EventTraceFrame"..FrameTexs[i]]:SetTexture()
	end

	_G.EventTraceFrame:SetTemplate("Transparent")
	S:HandleCloseButton(_G.EventTraceFrameCloseButton)

	--New Table Attribute Display: mouse over frame and (/tableinspect or [/fstack -> then Ctrl])
	SkinTableAttributeDisplay(_G.TableAttributeDisplay)
	hooksecurefunc(_G.TableInspectorMixin, "OnLoad", function(self)
		if self and self.ScrollFrameArt and not self.skinned then
			SkinTableAttributeDisplay(self)
			self.skinned = true
		end
	end)
end

-- ScriptErrorsFrame Skin
S:AddCallback("ScriptErrorsFrame", LoadErrorFrameSkin)

-- EventTrace, FrameStack, TableInspect Skins
if _G.IsAddOnLoaded("Blizzard_DebugTools") then
	S:AddCallback("SkinDebugTools", LoadSkin)
else
	S:AddCallbackForAddon("Blizzard_DebugTools", "SkinDebugTools", LoadSkin)
end
