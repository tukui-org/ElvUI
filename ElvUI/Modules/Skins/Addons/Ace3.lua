local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local select = select
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local oldRegisterAsWidget, oldRegisterAsContainer
function S:Ace3_SkinDropdownPullout()
	if self and self.obj then
		if self.obj.pullout and self.obj.pullout.frame then
			self.obj.pullout.frame:SetTemplate(nil, true)
		elseif self.obj.dropdown then -- this will be LSM
			self.obj.dropdown:SetTemplate(nil, true)

			if self.obj.dropdown.slider then
				self.obj.dropdown.slider:SetTemplate()
				self.obj.dropdown.slider:SetThumbTexture(E.Media.Textures.White8x8)

				local t = self.obj.dropdown.slider:GetThumbTexture()
				t:SetVertexColor(1, .82, 0, 0.8)
				t:SetSnapToPixelGrid(false)
				t:SetTexelSnappingBias(0)
			end
		end
	end
end

function S:Ace3_RegisterAsWidget(widget)
	if not E.private.skins.ace3.enable then
		return oldRegisterAsWidget(self, widget)
	end
	local TYPE = widget.type
	if TYPE == 'MultiLineEditBox' then
		local frame = widget.frame

		if not widget.scrollBG.template then
			widget.scrollBG:SetTemplate()
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

		checkbg:CreateBackdrop()
		checkbg.backdrop:SetInside(widget.checkbg, 4, 4)
		checkbg.backdrop:SetFrameLevel(widget.checkbg.backdrop:GetFrameLevel() + 1)
		checkbg:SetTexture()
		highlight:SetTexture()

		if E.private.skins.checkBoxSkin then
			checkbg.backdrop:SetInside(widget.checkbg, 5, 5)

			check:SetTexture(E.Media.Textures.Melli)

			hooksecurefunc(check, "SetDesaturated", function(chk, value)
				if value == true then
					chk:SetVertexColor(.6, .6, .6, .8)
				else
					chk:SetVertexColor(1, .82, 0, 0.8)
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

		S:HandleNextPrevButton(button, nil, {1, .8, 0})

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.backdrop:Point('TOPLEFT', 15, -2)
		frame.backdrop:Point("BOTTOMRIGHT", -21, 0)
		frame.backdrop:SetClipsChildren(true)

		widget.label:ClearAllPoints()
		widget.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		text:ClearAllPoints()
		text:SetJustifyH('RIGHT')
		text:Point('RIGHT', button, 'LEFT', -3, 0)

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', S.Ace3_SkinDropdownPullout)
		button_cover:HookScript('OnClick', S.Ace3_SkinDropdownPullout)
	elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
		local frame = widget.frame
		local button = frame.dropButton
		local text = frame.text
		frame:StripTextures()

		S:HandleNextPrevButton(button, nil, {1, .8, 0})

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.label:ClearAllPoints()
		frame.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		frame.text:ClearAllPoints()
		frame.text:Point('RIGHT', button, 'LEFT', -2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		frame.backdrop:Point('TOPLEFT', 0, -21)
		frame.backdrop:Point('BOTTOMRIGHT', -4, -1)
		frame.backdrop:SetClipsChildren(true)

		if TYPE == 'LSM30_Sound' then
			widget.soundbutton:SetParent(frame.backdrop)
			widget.soundbutton:ClearAllPoints()
			widget.soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
		elseif TYPE == 'LSM30_Statusbar' then
			widget.bar:SetParent(frame.backdrop)
			widget.bar:ClearAllPoints()
			widget.bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
			widget.bar:Point('BOTTOMRIGHT', button, 'BOTTOMLEFT', -1, 0)
		end

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', S.Ace3_SkinDropdownPullout)
	elseif TYPE == 'EditBox' then
		local frame = widget.editbox
		local button = widget.button
		S:HandleEditBox(frame)
		S:HandleButton(button)

		button:Point('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

		hooksecurefunc(frame, 'SetPoint', function(fr, a, b, c, d, e)
			if d == 7 then
				fr:Point(a, b, c, 0, e)
			end
		end)

		frame.backdrop:Point('TOPLEFT', 0, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -1, 0)
	elseif (TYPE == 'Button' or TYPE == 'Button-ElvUI') then
		local frame = widget.frame
		S:HandleButton(frame, true, true, true)
		widget.text:SetParent(frame.backdrop)
		frame.backdrop:SetInside()
	elseif TYPE == 'Slider' then
		local frame = widget.slider
		local editbox = widget.editbox
		local lowtext = widget.lowtext
		local hightext = widget.hightext

		S:HandleSliderFrame(frame)

		editbox:SetTemplate()
		editbox:Height(15)
		editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

		lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
		hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
	elseif TYPE == 'Keybinding' then
		local button = widget.button
		local msgframe = widget.msgframe

		S:HandleButton(button, nil, true)
		button:StripTextures()
		button:CreateBackdrop(nil, true)
		button.backdrop:SetInside()

		msgframe:StripTextures()
		msgframe:SetTemplate('Transparent')
		msgframe.msg:ClearAllPoints()
		msgframe.msg:Point('CENTER')
	elseif (TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI') then
		local frame = widget.frame
		local colorSwatch = widget.colorSwatch

		if not frame.backdrop then
			frame:CreateBackdrop()
		end

		frame.backdrop:Size(24, 16)
		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('LEFT', frame, 'LEFT', 4, 0)

		colorSwatch:SetTexture(E.media.blankTex)
		colorSwatch:ClearAllPoints()
		colorSwatch:SetParent(frame.backdrop)
		colorSwatch:SetInside(frame.backdrop)
		colorSwatch:SetSnapToPixelGrid(false)
		colorSwatch:SetTexelSnappingBias(0)

		if colorSwatch.background then
			colorSwatch.background:SetColorTexture(0, 0, 0, 0)
			colorSwatch.background:SetSnapToPixelGrid(false)
			colorSwatch.background:SetTexelSnappingBias(0)
		end

		if colorSwatch.checkers then
			colorSwatch.checkers:ClearAllPoints()
			colorSwatch.checkers:SetParent(frame.backdrop)
			colorSwatch.checkers:SetInside(frame.backdrop)
			colorSwatch.checkers:SetSnapToPixelGrid(false)
			colorSwatch.checkers:SetTexelSnappingBias(0)
		end
	elseif TYPE == 'Icon' then
		widget.frame:StripTextures()
	end

	return oldRegisterAsWidget(self, widget)
end

function S:Ace3_RegisterAsContainer(widget)
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
			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child:IsObjectType('Button') and child:GetText() then
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
			widget.RefreshTree = function(wdg, scrollToSelection)
				oldRefreshTree(wdg, scrollToSelection)
				if not wdg.tree then return end
				local status = wdg.status or wdg.localstatus
				local groupstatus = status.groups
				local lines = wdg.lines
				local buttons = wdg.buttons
				local offset = status.scrollvalue

				for i = offset + 1, #lines do
					local button = buttons[i - offset]
					if button then
						if groupstatus[lines[i].uniquevalue] then
							button.toggle:SetNormalTexture(E.Media.Textures.Minus)
							button.toggle:SetPushedTexture(E.Media.Textures.Minus)
							button.toggle:SetHighlightTexture('')
						else
							button.toggle:SetNormalTexture(E.Media.Textures.Plus)
							button.toggle:SetPushedTexture(E.Media.Textures.Plus)
							button.toggle:SetHighlightTexture('')
						end
					end
				end
			end
		end

		if TYPE == 'TabGroup' then
			local oldCreateTab = widget.CreateTab
			widget.CreateTab = function(wdg, id)
				local tab = oldCreateTab(wdg, id)
				tab:StripTextures()
				tab:CreateBackdrop()
				tab.backdrop:Point('TOPLEFT', 10, -3)
				tab.backdrop:Point('BOTTOMRIGHT', -10, 0)

				hooksecurefunc(tab, 'SetPoint', function(fr, a, b, c, d, e, f)
					if f ~= 'ignore' and a == 'TOPLEFT' then
						fr:SetPoint(a, b, c, d, e+2, 'ignore')
					end
				end)

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

function S:HookAce3(AceGUI)
	if not AceGUI then return end

	oldRegisterAsWidget = AceGUI.RegisterAsWidget
	AceGUI.RegisterAsWidget = S.Ace3_RegisterAsWidget

	oldRegisterAsContainer = AceGUI.RegisterAsContainer
	AceGUI.RegisterAsContainer = S.Ace3_RegisterAsContainer

	S.SkinnedAce3 = true
end
