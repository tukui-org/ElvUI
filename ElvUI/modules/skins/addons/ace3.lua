local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack, select, pairs = unpack, select, pairs
--WoW API / Variables
local CreateFrame = CreateFrame
local SquareButton_SetIcon = SquareButton_SetIcon

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LibStub

local AceGUI = LibStub("AceGUI-3.0", true)
local RegisterAsWidget, RegisterAsContainer
local function SetModifiedBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E['media'].rgbvaluecolor))
end

local function SetOriginalBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E['media'].bordercolor))
end

local function SkinScrollBar(frame, thumbTrim)
	if _G[frame:GetName().."BG"] then _G[frame:GetName().."BG"]:SetTexture(nil) end
	if _G[frame:GetName().."Track"] then _G[frame:GetName().."Track"]:SetTexture(nil) end

	if _G[frame:GetName().."Top"] then
		_G[frame:GetName().."Top"]:SetTexture(nil)
		_G[frame:GetName().."Bottom"]:SetTexture(nil)
		_G[frame:GetName().."Middle"]:SetTexture(nil)
	end

	if _G[frame:GetName().."ScrollUpButton"] and _G[frame:GetName().."ScrollDownButton"] then
		_G[frame:GetName().."ScrollUpButton"]:StripTextures()
		if not _G[frame:GetName().."ScrollUpButton"].icon then
			S:HandleNextPrevButton(_G[frame:GetName().."ScrollUpButton"])
			SquareButton_SetIcon(_G[frame:GetName().."ScrollUpButton"], 'UP')
			_G[frame:GetName().."ScrollUpButton"]:Size(_G[frame:GetName().."ScrollUpButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollUpButton"]:GetHeight() + 7)
		end

		_G[frame:GetName().."ScrollDownButton"]:StripTextures()
		if not _G[frame:GetName().."ScrollDownButton"].icon then
			S:HandleNextPrevButton(_G[frame:GetName().."ScrollDownButton"])
			SquareButton_SetIcon(_G[frame:GetName().."ScrollDownButton"], 'DOWN')
			_G[frame:GetName().."ScrollDownButton"]:Size(_G[frame:GetName().."ScrollDownButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollDownButton"]:GetHeight() + 7)
		end

		if not frame.trackbg then
			frame.trackbg = CreateFrame("Frame", nil, frame)
			frame.trackbg:Point("TOPLEFT", _G[frame:GetName().."ScrollUpButton"], "BOTTOMLEFT", 0, -1)
			frame.trackbg:Point("BOTTOMRIGHT", _G[frame:GetName().."ScrollDownButton"], "TOPRIGHT", 0, 1)
			frame.trackbg:SetTemplate("Transparent")
		end

		if frame:GetThumbTexture() then
			if not thumbTrim then thumbTrim = 3 end
			frame:GetThumbTexture():SetTexture(nil)
			if not frame.thumbbg then
				frame.thumbbg = CreateFrame("Frame", nil, frame)
				frame.thumbbg:Point("TOPLEFT", frame:GetThumbTexture(), "TOPLEFT", 2, -thumbTrim)
				frame.thumbbg:Point("BOTTOMRIGHT", frame:GetThumbTexture(), "BOTTOMRIGHT", -2, thumbTrim)
				frame.thumbbg:SetTemplate("Default", true, true)
				frame.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
				if frame.trackbg then
					frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel())
				end
			end
		end
	end
end

local function SkinButton(f, strip, noTemplate)
	if f.Left then f.Left:SetAlpha(0)  end
	if f.Middle then f.Middle:SetAlpha(0)  end
	if f.Right then f.Right:SetAlpha(0) end

	if f.SetNormalTexture then f:SetNormalTexture("") end

	if f.SetHighlightTexture then f:SetHighlightTexture("") end

	if f.SetPushedTexture then f:SetPushedTexture("") end

	if f.SetDisabledTexture then f:SetDisabledTexture("") end

	if strip then f:StripTextures() end

	if not f.template and not noTemplate then
		f:SetTemplate("Default", true)
	end

	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinNextPrevButton(...)
	S:HandleNextPrevButton(...)
end

function S:SkinAce3()
	local AceGUI = LibStub("AceGUI-3.0", true)
	if not AceGUI then return end
	local oldRegisterAsWidget = AceGUI.RegisterAsWidget

	RegisterAsWidget = function(self, widget)
		if not E.private.skins.ace3.enable then
			return oldRegisterAsWidget(self, widget)
		end
		local TYPE = widget.type
		if TYPE == 'MultiLineEditBox' then
			local frame = widget.frame

			if not widget.scrollBG.template then
				widget.scrollBG:SetTemplate('Default')
			end

			SkinButton(widget.button)
			SkinScrollBar(widget.scrollBar)
			widget.scrollBar:Point("RIGHT", frame, "RIGHT", 0 -4)
			widget.scrollBG:Point("TOPRIGHT", widget.scrollBar, "TOPLEFT", -2, 19)
			widget.scrollBG:Point("BOTTOMLEFT", widget.button, "TOPLEFT")
			widget.scrollFrame:Point("BOTTOMRIGHT", widget.scrollBG, "BOTTOMRIGHT", -4, 8)
		elseif TYPE == "CheckBox" then
			widget.checkbg:Kill()
			widget.highlight:Kill()

			if not widget.skinnedCheckBG then
				widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
				widget.skinnedCheckBG:SetTemplate('Default')
				widget.skinnedCheckBG:Point('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
				widget.skinnedCheckBG:Point('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
			end

			widget.check:SetParent(widget.skinnedCheckBG)
		elseif TYPE == "Dropdown" then
			local frame = widget.dropdown
			local button = widget.button
			local text = widget.text
			frame:StripTextures()

			button:ClearAllPoints()
			button:Point("RIGHT", frame, "RIGHT", -20, 0)

			SkinNextPrevButton(button, true)

			if not frame.backdrop then
				frame:CreateBackdrop("Default")
				frame.backdrop:Point("TOPLEFT", 20, -2)
				frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
			end
			button:SetParent(frame.backdrop)
			text:SetParent(frame.backdrop)
			button:HookScript('OnClick', function(this)
				local self = this.obj
				self.pullout.frame:SetTemplate('Default', true)
			end)
		elseif TYPE == "LSM30_Font" or TYPE == "LSM30_Sound" or TYPE == "LSM30_Border" or TYPE == "LSM30_Background" or TYPE == "LSM30_Statusbar" then
			local frame = widget.frame
			local button = frame.dropButton
			local text = frame.text
			frame:StripTextures()

			SkinNextPrevButton(button, true)
			frame.text:ClearAllPoints()
			frame.text:Point('RIGHT', button, 'LEFT', -2, 0)

			button:ClearAllPoints()
			button:Point("RIGHT", frame, "RIGHT", -10, -6)

			if not frame.backdrop then
				frame:CreateBackdrop("Default")
				if TYPE == "LSM30_Font" then
					frame.backdrop:Point("TOPLEFT", 20, -17)
				elseif TYPE == "LSM30_Sound" then
					frame.backdrop:Point("TOPLEFT", 20, -17)
					widget.soundbutton:SetParent(frame.backdrop)
					widget.soundbutton:ClearAllPoints()
					widget.soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
				elseif TYPE == "LSM30_Statusbar" then
					frame.backdrop:Point("TOPLEFT", 20, -17)
					widget.bar:SetParent(frame.backdrop)
					widget.bar:SetInside()
				elseif TYPE == "LSM30_Border" or TYPE == "LSM30_Background" then
					frame.backdrop:Point("TOPLEFT", 42, -16)
				end

				frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
			end
			button:SetParent(frame.backdrop)
			text:SetParent(frame.backdrop)
			button:HookScript('OnClick', function(this, button)
				local self = this.obj
				if self.dropdown then
					self.dropdown:SetTemplate('Default', true)
				end
			end)
		elseif TYPE == "EditBox" then
			local frame = widget.editbox
			local button = widget.button
			frame.Left:Kill()
			frame.Middle:Kill()
			frame.Right:Kill()
			frame:Height(17)
			frame:CreateBackdrop('Default')
			frame.backdrop:Point('TOPLEFT', -2, 0)
			frame.backdrop:Point('BOTTOMRIGHT', 2, 0)
			frame.backdrop:SetParent(widget.frame)
			frame:SetParent(frame.backdrop)
			SkinButton(button)
		elseif TYPE == "Button" then
			local frame = widget.frame
			SkinButton(frame, nil, true)
			frame:StripTextures()
			frame:CreateBackdrop('Default', true)
			frame.backdrop:SetInside()
			widget.text:SetParent(frame.backdrop)
		elseif TYPE == "Button-ElvUI" then
			local frame = widget.frame
			SkinButton(frame, nil, true)
			frame:StripTextures()
			frame:CreateBackdrop('Default', true)
			frame.backdrop:SetInside()
			widget.text:SetParent(frame.backdrop)
		elseif TYPE == "Slider" then
			local frame = widget.slider
			local editbox = widget.editbox
			local lowtext = widget.lowtext
			local hightext = widget.hightext
			local HEIGHT = 12

			frame:StripTextures()
			frame:SetTemplate('Default')
			frame:Height(HEIGHT)
			frame:SetThumbTexture(E["media"].blankTex)
			frame:GetThumbTexture():SetVertexColor(0.3, 0.3, 0.3)
			frame:GetThumbTexture():Size(HEIGHT-2,HEIGHT+2)

			editbox:SetTemplate('Default')
			editbox:Height(15)
			editbox:Point("TOP", frame, "BOTTOM", 0, -1)

			lowtext:Point("TOPLEFT", frame, "BOTTOMLEFT", 2, -2)
			hightext:Point("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -2)


		--[[elseif TYPE == "ColorPicker" then
			local frame = widget.frame
			local colorSwatch = widget.colorSwatch
		]]
		end
		return oldRegisterAsWidget(self, widget)
	end
	AceGUI.RegisterAsWidget = RegisterAsWidget
	--LibStub("AceGUI-3.0"):Create("Window")
	local oldRegisterAsContainer = AceGUI.RegisterAsContainer
	RegisterAsContainer = function(self, widget)
		if not E.private.skins.ace3.enable then
			return oldRegisterAsContainer(self, widget)
		end
		local TYPE = widget.type
		if TYPE == "ScrollFrame" then
			local frame = widget.scrollbar
			SkinScrollBar(frame)
		elseif TYPE == "InlineGroup" or TYPE == "TreeGroup" or TYPE == "TabGroup" or TYPE == "SimpleGroup" or TYPE == "Frame" or TYPE == "DropdownGroup" or TYPE == "Window" then
			local frame = widget.content:GetParent()
			if TYPE == "Frame" then
				frame:StripTextures()
				for i=1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:GetObjectType() == "Button" and child:GetText() then
						SkinButton(child)
					else
						child:StripTextures()
					end
				end
			elseif TYPE == "Window" then
				frame:StripTextures()
				S:HandleCloseButton(frame.obj.closebutton)
			end
			frame:SetTemplate('Transparent')

			if widget.treeframe then
				widget.treeframe:SetTemplate('Transparent')
				frame:Point("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)

				local oldCreateButton = widget.CreateButton
				widget.CreateButton = function(self)
					local button = oldCreateButton(self)
					button.toggle:StripTextures()
					button.toggle.SetNormalTexture = E.noop
					button.toggle.SetPushedTexture = E.noop
					button.toggleText = button.toggle:CreateFontString(nil, 'OVERLAY')
					button.toggleText:FontTemplate(nil, 19)
					button.toggleText:Point('CENTER')
					button.toggleText:SetText('+')
					return button
				end

				local oldRefreshTree = widget.RefreshTree
				widget.RefreshTree = function(self, scrollToSelection)
					oldRefreshTree(self, scrollToSelection)
					if not self.tree then return end
					local status = self.status or self.localstatus
					local groupstatus = status.groups
					local lines = self.lines
					local buttons = self.buttons

					for i, line in pairs(lines) do
						local button = buttons[i]
						if groupstatus[line.uniquevalue] and button then
							button.toggleText:SetText('-')
						elseif button then
							button.toggleText:SetText('+')
						end
					end
				end
			end

			if TYPE == "TabGroup" then
				local oldCreateTab = widget.CreateTab
				widget.CreateTab = function(self, id)
					local tab = oldCreateTab(self, id)
					tab:StripTextures()
					return tab
				end
			end

			if widget.scrollbar then
				SkinScrollBar(widget.scrollbar)
			end
		end

		return oldRegisterAsContainer(self, widget)
	end
	AceGUI.RegisterAsContainer = RegisterAsContainer
end

local function attemptSkin()
	local AceGUI = LibStub("AceGUI-3.0", true)
	if AceGUI and (AceGUI.RegisterAsContainer ~= RegisterAsContainer or AceGUI.RegisterAsWidget ~= RegisterAsWidget) then
		S:SkinAce3()
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", attemptSkin)

S:RegisterSkin('Ace3', S.SkinAce3, true)