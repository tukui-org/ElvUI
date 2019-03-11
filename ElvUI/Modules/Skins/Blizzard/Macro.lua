local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
local format = format
--WoW API / Variables
local HideUIPanel = HideUIPanel
local ShowUIPanel = ShowUIPanel

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.macro ~= true then return end

	local MacroFrame = _G.MacroFrame
	S:HandlePortraitFrame(MacroFrame, true)
	MacroFrame:Width(360)

	_G.MacroFrameTextBackground:StripTextures()
	_G.MacroFrameTextBackground:SetTemplate()
	_G.MacroButtonScrollFrame:StripTextures()
	_G.MacroButtonScrollFrame:CreateBackdrop()

	S:HandleScrollBar(_G.MacroButtonScrollFrameScrollBar)
	S:HandleScrollBar(_G.MacroFrameScrollFrameScrollBar)

	local buttons = {
		_G.MacroSaveButton,
		_G.MacroCancelButton,
		_G.MacroDeleteButton,
		_G.MacroNewButton,
		_G.MacroExitButton,
		_G.MacroEditButton,
		_G.MacroFrameTab1,
		_G.MacroFrameTab2,
	}

	for i = 1, #buttons do
		buttons[i]:StripTextures()
		S:HandleButton(buttons[i])
	end

	_G.MacroNewButton:ClearAllPoints()
	_G.MacroNewButton:SetPoint("RIGHT", _G.MacroExitButton, "LEFT", -2 , 0)

	for i = 1, 2 do
		local tab = _G[format("MacroFrameTab%s", i)]
		tab:Height(22)
	end
	_G.MacroFrameTab1:Point("TOPLEFT", MacroFrame, "TOPLEFT", 85, -39)
	_G.MacroFrameTab2:Point("LEFT", _G.MacroFrameTab1, "RIGHT", 4, 0)

	--Reposition edit button
	_G.MacroEditButton:ClearAllPoints()
	_G.MacroEditButton:Point("BOTTOMLEFT", _G.MacroFrameSelectedMacroButton, "BOTTOMRIGHT", 10, 0)

	-- Regular scroll bar
	S:HandleScrollBar(_G.MacroButtonScrollFrame)

	-- Big icon
	_G.MacroFrameSelectedMacroButton:StripTextures()
	_G.MacroFrameSelectedMacroButton:StyleButton(true)
	_G.MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture()
	_G.MacroFrameSelectedMacroButton:SetTemplate()
	_G.MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(E.TexCoords))
	_G.MacroFrameSelectedMacroButtonIcon:Point("TOPLEFT", E.mult, -E.mult)
	_G.MacroFrameSelectedMacroButtonIcon:Point("BOTTOMRIGHT", -E.mult, E.mult)

	-- Skin all buttons
	for i = 1, _G.MAX_ACCOUNT_MACROS do
		local b = _G["MacroButton"..i]
		local t = _G["MacroButton"..i.."Icon"]

		if b then
			b:StripTextures()
			b:StyleButton(true)
			b:SetTemplate(nil, true)
		end

		if t then
			t:SetTexCoord(unpack(E.TexCoords))
			t:Point("TOPLEFT", E.mult, -E.mult)
			t:Point("BOTTOMRIGHT", -E.mult, E.mult)
		end
	end

	--Icon selection frame
	ShowUIPanel(MacroFrame); --Toggle frame to create necessary variables needed for popup frame
	HideUIPanel(MacroFrame);
	local MacroPopupFrame = _G.MacroPopupFrame
	MacroPopupFrame:Show() --Toggle the frame in order to create the necessary button elements
	MacroPopupFrame:Hide()

	-- Popout Frame
	S:HandleButton(MacroPopupFrame.BorderBox.OkayButton)
	S:HandleButton(MacroPopupFrame.BorderBox.CancelButton)
	S:HandleScrollBar(_G.MacroPopupScrollFrameScrollBar)
	S:HandleEditBox(_G.MacroPopupEditBox)
	_G.MacroPopupNameLeft:SetTexture()
	_G.MacroPopupNameMiddle:SetTexture()
	_G.MacroPopupNameRight:SetTexture()

	S:HandleIconSelectionFrame(MacroPopupFrame, _G.NUM_MACRO_ICONS_SHOWN, "MacroPopupButton", "MacroPopup")

	MacroPopupFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:Point("TOPLEFT", MacroFrame, "TOPRIGHT", 2, 0)
	end)
end

S:AddCallbackForAddon("Blizzard_MacroUI", "Macro", LoadSkin)
