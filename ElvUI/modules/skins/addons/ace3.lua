local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--if not ANonBuggyFuckingSkin then return end

local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI then return end

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
		_G[frame:GetName().."ScrollUpButton"]:SetTemplate("Default", true)
		if not _G[frame:GetName().."ScrollUpButton"].texture then
			_G[frame:GetName().."ScrollUpButton"].texture = _G[frame:GetName().."ScrollUpButton"]:CreateTexture(nil, 'OVERLAY')
			_G[frame:GetName().."ScrollUpButton"].texture:Point("TOPLEFT", 2, -2)
			_G[frame:GetName().."ScrollUpButton"].texture:Point("BOTTOMRIGHT", -2, 2)
			_G[frame:GetName().."ScrollUpButton"].texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrowup.tga]])
			_G[frame:GetName().."ScrollUpButton"].texture:SetVertexColor(unpack(E["media"].bordercolor))
		end
		_G[frame:GetName().."ScrollUpButton"]:HookScript('OnEnter', function(self)
			SetModifiedBackdrop(self)
			--self.texture:SetVertexColor(unpack(E["media"].valuecolor))			
		end)	
		_G[frame:GetName().."ScrollUpButton"]:HookScript('OnLeave', function(self)
			SetOriginalBackdrop(self)
			--self.texture:SetVertexColor(unpack(E["media"].bordercolor))	
		end)		
		
		_G[frame:GetName().."ScrollDownButton"]:StripTextures()
		_G[frame:GetName().."ScrollDownButton"]:SetTemplate("Default", true)
		_G[frame:GetName().."ScrollDownButton"]:HookScript('OnEnter', SetModifiedBackdrop)
		_G[frame:GetName().."ScrollDownButton"]:HookScript('OnLeave', SetOriginalBackdrop)		
		if not _G[frame:GetName().."ScrollDownButton"].texture then
			_G[frame:GetName().."ScrollDownButton"].texture = _G[frame:GetName().."ScrollDownButton"]:CreateTexture(nil, 'OVERLAY')
			_G[frame:GetName().."ScrollDownButton"].texture:Point("TOPLEFT", 2, -2)
			_G[frame:GetName().."ScrollDownButton"].texture:Point("BOTTOMRIGHT", -2, 2)
			_G[frame:GetName().."ScrollDownButton"].texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\arrowdown.tga]])
			_G[frame:GetName().."ScrollDownButton"].texture:SetVertexColor(unpack(E["media"].bordercolor))
		end
		
		_G[frame:GetName().."ScrollDownButton"]:HookScript('OnEnter', function(self)
			SetModifiedBackdrop(self)	
		end)	
		_G[frame:GetName().."ScrollDownButton"]:HookScript('OnLeave', function(self)
			SetOriginalBackdrop(self)
		end)				
		
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
				frame.thumbbg:SetTemplate("Default", true)
				if frame.trackbg then
					frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel())
				end
			end
		end	
	end	
end

local function SkinButton(f, strip, noTemplate)
	if f:GetName() then
		local l = _G[f:GetName().."Left"]
		local m = _G[f:GetName().."Middle"]
		local r = _G[f:GetName().."Right"]
		
		
		if l then l:SetAlpha(0) end
		if m then m:SetAlpha(0) end
		if r then r:SetAlpha(0) end
	end

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

local function SkinNextPrevButton(btn, horizonal)
	btn:SetTemplate("Default")
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7)	

	if horizonal then
		btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.72, 0.65, 0.29, 0.65, 0.72)
		btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.8, 0.65, 0.35, 0.65, 0.8)
		btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)	
	else
		btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)
		
		if btn:GetPushedTexture() then
			btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.81, 0.65, 0.35, 0.65, 0.81)
		end
		if btn:GetDisabledTexture() then
			btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
		end
	end
	
	btn:GetNormalTexture():ClearAllPoints()
	btn:GetNormalTexture():Point("TOPLEFT", 2, -2)
	btn:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
	if btn:GetDisabledTexture() then
		btn:GetDisabledTexture():SetAllPoints(btn:GetNormalTexture())
	end
	
	if btn:GetPushedTexture() then
		btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
	end
	
	btn:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end


local function SkinAce3()
	local oldRegisterAsWidget = AceGUI.RegisterAsWidget
	AceGUI.RegisterAsWidget = function(self, widget)
		if not E.private.skins.ace3.enable then
			return oldRegisterAsWidget(self, widget)
		end
		local TYPE = widget.type
		--print(TYPE)
		if TYPE == 'MultiLineEditBox' then
			local frame = widget.frame
			
			if not widget.scrollBG.template then
				widget.scrollBG:SetTemplate('Default')
			end

			SkinButton(widget.button)
			SkinScrollBar(widget.scrollBar)
			widget.scrollBar:SetPoint("RIGHT", frame, "RIGHT", 0 -4)
			widget.scrollBG:SetPoint("TOPRIGHT", widget.scrollBar, "TOPLEFT", -2, 19)
			widget.scrollBG:SetPoint("BOTTOMLEFT", widget.button, "TOPLEFT")
			widget.scrollFrame:SetPoint("BOTTOMRIGHT", widget.scrollBG, "BOTTOMRIGHT", -4, 8)
		elseif TYPE == "CheckBox" then
			widget.checkbg:Kill()
			widget.highlight:Kill()
			
			if not widget.skinnedCheckBG then
				widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
				widget.skinnedCheckBG:SetTemplate('Default')
				widget.skinnedCheckBG:Point('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
				widget.skinnedCheckBG:Point('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
			end
			
			if widget.skinnedCheckBG.oborder then
				widget.check:SetParent(widget.skinnedCheckBG.oborder)
			else
				widget.check:SetParent(widget.skinnedCheckBG)
			end
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
					widget.bar:ClearAllPoints()
					widget.bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
					widget.bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
					widget.bar:SetParent(frame.backdrop)
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
			_G[frame:GetName()..'Left']:Kill()
			_G[frame:GetName()..'Middle']:Kill()
			_G[frame:GetName()..'Right']:Kill()
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
			frame.backdrop:Point("TOPLEFT", 2, -2)
			frame.backdrop:Point("BOTTOMRIGHT", -2, 2)
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
			frame:GetThumbTexture():SetVertexColor(unpack(E["media"].bordercolor))
			frame:GetThumbTexture():Size(HEIGHT-2,HEIGHT+2)
			
			editbox:SetTemplate('Default')
			editbox:Height(15)
			editbox:Point("TOP", frame, "BOTTOM", 0, -1)
			
			lowtext:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 2, -2)
			hightext:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -2, -2)

		
		--[[elseif TYPE == "ColorPicker" then
			local frame = widget.frame
			local colorSwatch = widget.colorSwatch
		]]
		end
		return oldRegisterAsWidget(self, widget)
	end

	local oldRegisterAsContainer = AceGUI.RegisterAsContainer

	AceGUI.RegisterAsContainer = function(self, widget)
		if not E.private.skins.ace3.enable then
			return oldRegisterAsContainer(self, widget)
		end	
		local TYPE = widget.type

		if TYPE == "ScrollFrame" then
			local frame = widget.scrollbar
			SkinScrollBar(frame)
		elseif TYPE == "InlineGroup" or TYPE == "TreeGroup" or TYPE == "TabGroup" or TYPE == "SimpleGroup" or TYPE == "Frame" or TYPE == "DropdownGroup" then
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
					button.toggleText:SetPoint('CENTER')
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
end

S:RegisterSkin('Ace3', SkinAce3, true)