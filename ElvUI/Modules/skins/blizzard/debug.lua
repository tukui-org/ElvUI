local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

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

local function LoadErrorFrameSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	local function SkinOnShow()
		local ScriptErrorsFrame = _G["ScriptErrorsFrame"]
		ScriptErrorsFrame:SetParent(E.UIParent)
		ScriptErrorsFrame:SetTemplate('Transparent')
		S:HandleScrollBar(ScriptErrorsFrameScrollBar)
		S:HandleCloseButton(ScriptErrorsFrameClose)
		ScriptErrorsFrame.ScrollFrame.Text:FontTemplate(nil, 13)
		ScriptErrorsFrame.ScrollFrame:CreateBackdrop('Default')
		ScriptErrorsFrame.ScrollFrame:SetFrameLevel(ScriptErrorsFrame.ScrollFrame:GetFrameLevel() + 2)

		for i=1, #FrameTexs do
			_G["ScriptErrorsFrame"..FrameTexs[i]]:SetTexture(nil)
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
		S:HandleNextPrevButton(ScriptErrorsFrame.PreviousError, nil, true)
		S:HandleNextPrevButton(ScriptErrorsFrame.NextError)

		S:Unhook(ScriptErrorsFrame, 'OnShow')
	end

	S:SecureHookScript(ScriptErrorsFrame, 'OnShow', SkinOnShow)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.debug ~= true then return end

	-- Tooltips
	if E.private.skins.blizzard.tooltip then
		FrameStackTooltip:HookScript("OnShow", function(self)
			if not self.template then
				self:SetTemplate("Transparent")
			end
		end)

		EventTraceTooltip:HookScript("OnShow", function(self)
			if not self.template then
				self:SetTemplate("Transparent", nil, true) --ignore updates
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
				self:SetBackdropColor(unpack(E.media.backdropfadecolor))
			end
		end)
	end

	for i=1, #FrameTexs do
		_G["EventTraceFrame"..FrameTexs[i]]:SetTexture(nil)
	end

	EventTraceFrame:SetTemplate("Transparent")
	S:HandleCloseButton(EventTraceFrameCloseButton)

	--New Table Attribute Display: mouse over frame and (/tableinspect or [/fstack -> then Ctrl])
	local function dynamicScrollButtonVisibility(button, frame)
		if not button.dynamicVisibility then
			frame:SetShown(button:IsShown())
			button:HookScript("OnShow", function() frame:Show() end)
			button:HookScript("OnHide", function() frame:Hide() end)
			button.dynamicVisibility = true
		end
	end

	local function SkinTableAttributeDisplay(frame)
		frame:StripTextures()
		frame:SetTemplate("Transparent")
		frame.ScrollFrameArt:StripTextures()
		frame.ScrollFrameArt:SetTemplate("Transparent")
		S:HandleCloseButton(frame.CloseButton)
		frame.OpenParentButton:ClearAllPoints()
		frame.OpenParentButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		S:HandleNextPrevButton(frame.OpenParentButton, true)
		frame.OpenParentButton:Size(17)
		frame.DuplicateButton:ClearAllPoints()
		frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT")
		S:HandleCheckBox(frame.VisibilityButton)
		S:HandleCheckBox(frame.HighlightButton)
		S:HandleCheckBox(frame.DynamicUpdateButton)
		frame.NavigateBackwardButton:ClearAllPoints()
		frame.NavigateBackwardButton:SetPoint("LEFT", frame.OpenParentButton, "RIGHT", 2, 0)
		frame.NavigateForwardButton:ClearAllPoints()
		frame.NavigateForwardButton:SetPoint("LEFT", frame.NavigateBackwardButton, "RIGHT", 2, 0)
		frame.DuplicateButton:ClearAllPoints()
		frame.DuplicateButton:SetPoint("LEFT", frame.NavigateForwardButton, "RIGHT", 2, 0)
		S:HandleNextPrevButton(frame.DuplicateButton, true, true)
		frame.DuplicateButton:Size(17)
		S:HandleNextPrevButton(frame.NavigateBackwardButton, nil, true)
		S:HandleNextPrevButton(frame.NavigateForwardButton)
		S:HandleEditBox(frame.FilterBox)

		-- reason: UIParentScrollBar .. ???
		if frame.LinesScrollFrame and frame.LinesScrollFrame.ScrollBar then
			local s = frame.LinesScrollFrame.ScrollBar
			s.ScrollUpButton:StripTextures()
			if not s.ScrollUpButton.icon then
				S:HandleNextPrevButton(s.ScrollUpButton, true, true)
				s.ScrollUpButton:Size(s.ScrollUpButton:GetWidth() + 7, s.ScrollUpButton:GetHeight() + 7)
			end

			s.ScrollDownButton:StripTextures()
			if not s.ScrollDownButton.icon then
				S:HandleNextPrevButton(s.ScrollDownButton, true)
				s.ScrollDownButton:Size(s.ScrollDownButton:GetWidth() + 7, s.ScrollDownButton:GetHeight() + 7)
			end

			if not s.trackbg then
				s.trackbg = CreateFrame("Frame", "$parentTrackBG", frame.LinesScrollFrame)
				s.trackbg:Point("TOPLEFT", s.ScrollUpButton, "BOTTOMLEFT", 0, -1)
				s.trackbg:Point("TOPRIGHT", s.ScrollUpButton, "BOTTOMRIGHT", 0, -1)
				s.trackbg:Point("BOTTOMLEFT", s.ScrollDownButton, "TOPLEFT", 0, 1)
				s.trackbg:SetTemplate("Transparent")
				dynamicScrollButtonVisibility(s.ScrollUpButton, s.trackbg) -- UpButton handles the TrackBG visibility
			end

			local t = frame.LinesScrollFrame.ScrollBar:GetThumbTexture()
			if t then
				t:SetTexture(nil)
				if not s.thumbbg then
					s.thumbbg = CreateFrame("Frame", "$parentThumbBG", frame.LinesScrollFrame)
					s.thumbbg:Point("TOPLEFT", t, "TOPLEFT", 2, -3)
					s.thumbbg:Point("BOTTOMRIGHT", t, "BOTTOMRIGHT", -2, 3)
					s.thumbbg:SetTemplate("Default", true, true)
					s.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
					if s.trackbg then
						s.thumbbg:SetFrameLevel(s.trackbg:GetFrameLevel()+1)
					end
					dynamicScrollButtonVisibility(s.ScrollDownButton, s.thumbbg) -- DownButton handles the ThumbBG visibility
				end
			end
		end
	end

	SkinTableAttributeDisplay(TableAttributeDisplay)
	hooksecurefunc(TableInspectorMixin, "OnLoad", function(self)
		if self and self.ScrollFrameArt and not self.skinned then
			SkinTableAttributeDisplay(self)
			self.skinned = true
		end
	end)
end

-- ScriptErrorsFrame Skin
S:AddCallback("ScriptErrorsFrame", LoadErrorFrameSkin)

-- EventTrace, FrameStack, TableInspect Skins
if IsAddOnLoaded("Blizzard_DebugTools") then
	S:AddCallback("SkinDebugTools", LoadSkin)
else
	S:AddCallbackForAddon("Blizzard_DebugTools", "SkinDebugTools", LoadSkin)
end
