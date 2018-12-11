local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local select = select
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LibStub

local RegisterAsWidget, RegisterAsContainer
local function SkinDropdownPullout(self)
	if self and self.obj then
		if self.obj.pullout and self.obj.pullout.frame then
			self.obj.pullout.frame:SetTemplate('Default', true)
		elseif self.obj.dropdown then -- this will be LSM
			self.obj.dropdown:SetTemplate('Default', true)

			if self.obj.dropdown.slider then
				self.obj.dropdown.slider:SetTemplate('Default')
				self.obj.dropdown.slider:SetThumbTexture([[Interface\Buttons\WHITE8X8]])
				self.obj.dropdown.slider:GetThumbTexture():SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:SkinAce3()
	local AceGUI = LibStub("AceGUI-3.0", true)
	if not AceGUI then return end
	local oldRegisterAsWidget = AceGUI.RegisterAsWidget
	local ColorBlind = GetCVarBool('colorblindmode')

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

			S:HandleButton(widget.button)
			S:HandleScrollBar(widget.scrollBar)
			widget.scrollBar:Point('RIGHT', frame, 'RIGHT', 0 -4)
			widget.scrollBG:Point('TOPRIGHT', widget.scrollBar, 'TOPLEFT', -2, 19)
			widget.scrollBG:Point('BOTTOMLEFT', widget.button, 'TOPLEFT')
			widget.scrollFrame:Point('BOTTOMRIGHT', widget.scrollBG, 'BOTTOMRIGHT', -4, 8)
		elseif TYPE == 'CheckBox' then
			local check = widget.check
			local checkbg = widget.checkbg
			local highlight = widget.highlight

			checkbg:CreateBackdrop('Default')
			checkbg.backdrop:SetInside(widget.checkbg, 4, 4)
			checkbg.backdrop:SetFrameLevel(widget.checkbg.backdrop:GetFrameLevel() + 1)
			checkbg:SetTexture('')
			highlight:SetTexture('')

			if not ColorBlind then
				checkbg.backdrop:SetInside(widget.checkbg, 5, 5)

				check:SetTexture([[Interface\AddOns\ElvUI\media\textures\melli]])

				hooksecurefunc(check, "SetDesaturated", function(self, value)
					if value == true then
						self:SetVertexColor(.6, .6, .6, .8)
					else
						self:SetVertexColor(1, .82, 0, 0.8)
					end
				end)

				check.SetTexture = E.noop
				check:SetInside(widget.checkbg.backdrop)
			else
				check:SetOutside(widget.checkbg.backdrop, 3, 3)
			end

			checkbg.SetTexture = E.noop
			highlight.SetTexture = E.noop
		elseif TYPE == 'Dropdown' then
			local frame = widget.dropdown
			local button = widget.button
			local button_cover = widget.button_cover
			local text = widget.text
			frame:StripTextures()

			S:HandleNextPrevButton(button, true)

			if not frame.backdrop then
				frame:CreateBackdrop('Default')
			end

			frame.backdrop:SetPoint('TOPLEFT', 15, -2)
			frame.backdrop:SetPoint("BOTTOMRIGHT", -21, 0)

			widget.label:ClearAllPoints()
			widget.label:SetPoint('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

			button:SetSize(20, 20)
			button:ClearAllPoints()
			button:SetPoint('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

			text:ClearAllPoints()
			text:SetJustifyH('RIGHT')
			text:SetPoint('RIGHT', button, 'LEFT', -3, 0)

			button:SetParent(frame.backdrop)
			text:SetParent(frame.backdrop)
			button:HookScript('OnClick', SkinDropdownPullout)
			button_cover:HookScript('OnClick', SkinDropdownPullout)
		elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
			local frame = widget.frame
			local button = frame.dropButton
			local text = frame.text
			frame:StripTextures()

			S:HandleNextPrevButton(button, true)

			if not frame.backdrop then
				frame:CreateBackdrop('Default')
			end

			frame.label:ClearAllPoints()
			frame.label:SetPoint('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

			frame.text:ClearAllPoints()
			frame.text:SetPoint('RIGHT', button, 'LEFT', -2, 0)

			button:SetSize(20, 20)
			button:ClearAllPoints()
			button:SetPoint('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

			frame.backdrop:SetPoint('TOPLEFT', 0, -21)
			frame.backdrop:SetPoint('BOTTOMRIGHT', -4, -1)

			if TYPE == 'LSM30_Sound' then
				widget.soundbutton:SetParent(frame.backdrop)
				widget.soundbutton:ClearAllPoints()
				widget.soundbutton:SetPoint('LEFT', frame.backdrop, 'LEFT', 2, 0)
			elseif TYPE == 'LSM30_Statusbar' then
				widget.bar:SetParent(frame.backdrop)
				widget.bar:ClearAllPoints()
				widget.bar:SetPoint('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
				widget.bar:SetPoint('BOTTOMRIGHT', button, 'BOTTOMLEFT', -1, 0)
			end

			button:SetParent(frame.backdrop)
			text:SetParent(frame.backdrop)
			button:HookScript('OnClick', SkinDropdownPullout)
		elseif TYPE == 'EditBox' then
			local frame = widget.editbox
			local button = widget.button
			S:HandleEditBox(frame)
			S:HandleButton(button)

			button:SetPoint('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

			hooksecurefunc(frame, 'SetPoint', function(self, a, b, c, d, e)
				if d == 7 then
					self:SetPoint(a, b, c, 0, e)
				end
			end)

			frame.backdrop:SetPoint('TOPLEFT', 0, -2)
			frame.backdrop:SetPoint('BOTTOMRIGHT', -1, 0)
		elseif (TYPE == 'Button' or TYPE == 'Button-ElvUI') then
			local frame = widget.frame
			S:HandleButton(frame, nil, true)
			frame:StripTextures()
			frame:CreateBackdrop('Default', true)
			frame.backdrop:SetInside()
			widget.text:SetParent(frame.backdrop)
		elseif TYPE == 'Slider' then
			local frame = widget.slider
			local editbox = widget.editbox
			local lowtext = widget.lowtext
			local hightext = widget.hightext

			S:HandleSliderFrame(frame)

			editbox:SetTemplate('Default')
			editbox:Height(15)
			editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

			lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
			hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
		elseif TYPE == 'Keybinding' then
			local button = widget.button
			local msgframe = widget.msgframe

			S:HandleButton(button, nil, true)
			button:StripTextures()
			button:CreateBackdrop('Default', true)
			button.backdrop:SetInside()

			msgframe:StripTextures()
			msgframe:SetTemplate('Transparent')
			msgframe.msg:ClearAllPoints()
			msgframe.msg:SetPoint('CENTER')
		elseif (TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI') then
			local frame = widget.frame
			local colorSwatch = widget.colorSwatch

			if not frame.backdrop then
				frame:CreateBackdrop('Default')
			end

			frame.backdrop:SetSize(24, 16)
			frame.backdrop:ClearAllPoints()
			frame.backdrop:SetPoint('LEFT', frame, 'LEFT', 4, 0)

			colorSwatch:SetTexture(E.media.blankTex)
			colorSwatch:ClearAllPoints()
			colorSwatch:SetParent(frame.backdrop)
			colorSwatch:SetInside(frame.backdrop)

			if frame.texture then
				frame.texture:SetColorTexture(0, 0, 0, 0)
			end

			if frame.checkers then
				frame.checkers:ClearAllPoints()
				frame.checkers:SetDrawLayer('ARTWORK')
				frame.checkers:SetParent(frame.backdrop)
				frame.checkers:SetInside(frame.backdrop)
			end
		elseif TYPE == 'Icon' then
			widget.frame:StripTextures()
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
		if TYPE == 'ScrollFrame' then
			S:HandleScrollBar(widget.scrollbar)
		elseif TYPE == 'InlineGroup' or TYPE == 'TreeGroup' or TYPE == 'TabGroup' or TYPE == 'Frame' or TYPE == 'DropdownGroup' or TYPE == 'Window' then
			local frame = widget.content:GetParent()
			if TYPE == 'Frame' then
				frame:StripTextures()
				if not E.GUIFrame then
					E.GUIFrame = frame
				end
				for i=1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:GetObjectType() == 'Button' and child:GetText() then
						S:HandleButton(child)
					else
						child:StripTextures()
					end
				end
			elseif TYPE == 'Window' then
				frame:StripTextures()
				S:HandleCloseButton(frame.obj.closebutton)
			end
			frame:SetTemplate('Transparent')

			if widget.treeframe then
				widget.treeframe:SetTemplate('Transparent')
				frame:Point('TOPLEFT', widget.treeframe, 'TOPRIGHT', 1, 0)

				local oldRefreshTree = widget.RefreshTree
				widget.RefreshTree = function(self, scrollToSelection)
					oldRefreshTree(self, scrollToSelection)
					if not self.tree then return end
					local status = self.status or self.localstatus
					local groupstatus = status.groups
					local lines = self.lines
					local buttons = self.buttons
					local offset = status.scrollvalue

					for i = offset + 1, #lines do
						local button = buttons[i - offset]
						if button then
							if groupstatus[lines[i].uniquevalue] then
								button.toggle:SetNormalTexture([[Interface\AddOns\ElvUI\media\textures\Minus]])
								button.toggle:SetPushedTexture([[Interface\AddOns\ElvUI\media\textures\Minus]])
								button.toggle:SetHighlightTexture('')
							else
								button.toggle:SetNormalTexture([[Interface\AddOns\ElvUI\media\textures\Plus]])
								button.toggle:SetPushedTexture([[Interface\AddOns\ElvUI\media\textures\Plus]])
								button.toggle:SetHighlightTexture('')
							end
						end
					end
				end
			end

			if TYPE == 'TabGroup' then
				local oldCreateTab = widget.CreateTab
				widget.CreateTab = function(self, id)
					local tab = oldCreateTab(self, id)
					tab:StripTextures()
					tab.backdrop = CreateFrame('Frame', nil, tab)
					tab.backdrop:SetTemplate('Transparent')
					tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
					tab.backdrop:Point('TOPLEFT', 10, -3)
					tab.backdrop:Point('BOTTOMRIGHT', -10, 0)
					return tab
				end
			end

			if widget.scrollbar then
				S:HandleScrollBar(widget.scrollbar)
			end
		elseif TYPE == 'SimpleGroup' then
			local frame = widget.content:GetParent()
			frame:SetTemplate('Transparent', nil, true) --ignore border updates
			frame:SetBackdropBorderColor(0,0,0,0) --Make border completely transparent
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

S:AddCallback("Ace3", attemptSkin)
