local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


local function SetModifiedBackdrop(self)
	if C["general"].classcolortheme == true then
		self:SetBackdropBorderColor(unpack(C["media"].bordercolor))		
	else
		self:SetBackdropBorderColor(unpack(C["media"].valuecolor))	
	end
end

local function SetOriginalBackdrop(self)
	local color = RAID_CLASS_COLORS[E.myclass]
	if C["general"].classcolortheme == true then
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		self:SetBackdropColor(unpack(C["media"].backdropcolor))
		self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end
end

local function SkinButton(f)
	if f:GetName() then
		local l = _G[f:GetName().."Left"]
		local m = _G[f:GetName().."Middle"]
		local r = _G[f:GetName().."Right"]
		
		
		if l then l:SetAlpha(0) end
		if m then m:SetAlpha(0) end
		if r then r:SetAlpha(0) end
	end
	
	if f.SetNormalTexture then
		f:SetNormalTexture("")
	end
	
	if f.SetHighlightTexture then
		f:SetHighlightTexture("")
	end
	
	if f.SetPushedTexture then
		f:SetPushedTexture("")
	end
	
	if f.SetDisabledTexture then
		f:SetDisabledTexture("")
	end
	f:SetTemplate("Default", true)
	
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local ElvuiSkin = CreateFrame("Frame")
ElvuiSkin:RegisterEvent("ADDON_LOADED")
ElvuiSkin:SetScript("OnEvent", function(self, event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then return end
	
	if addon == "Blizzard_DebugTools" then
		local noscalemult = E.mult * C["general"].uiscale
		local bg = {
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		}
		
		ScriptErrorsFrame:SetBackdrop(bg)
		ScriptErrorsFrame:SetBackdropColor(unpack(C.media.backdropfadecolor))
		ScriptErrorsFrame:SetBackdropBorderColor(unpack(C.media.bordercolor))	

		EventTraceFrame:SetTemplate("Transparent")
		
		local texs = {
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
		
		for i=1, #texs do
			_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
			_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
		end
		
		local bg = {
		  bgFile = C["media"].normTex, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		}
		
		for i=1, ScriptErrorsFrame:GetNumChildren() do
			local child = select(i, ScriptErrorsFrame:GetChildren())
			if child:GetObjectType() == "Button" and not child:GetName() then
				
				SkinButton(child)
				child:SetBackdrop(bg)
				child:SetBackdropColor(unpack(C.media.backdropcolor))
				child:SetBackdropBorderColor(unpack(C.media.bordercolor))	
			end
		end	
	end
	
	-- stuff not in Blizzard load-on-demand
	if addon == "ElvUI" then
		-- Blizzard frame we want to reskin
		local skins = {
			"StaticPopup1",
			"StaticPopup2",
			"StaticPopup3",
			"GameMenuFrame",
			"InterfaceOptionsFrame",
			"VideoOptionsFrame",
			"AudioOptionsFrame",
			"LFDDungeonReadyStatus",
			"BNToastFrame",
			"TicketStatusFrameButton",
			"DropDownList1MenuBackdrop",
			"DropDownList2MenuBackdrop",
			"DropDownList1Backdrop",
			"DropDownList2Backdrop",
			"LFDSearchStatus",
			"AutoCompleteBox",
			"ColorPickerFrame",
			"ConsolidatedBuffsTooltip",
			"ReadyCheckFrame",
		}
		
		for i = 1, getn(skins) do
			_G[skins[i]]:SetTemplate("Default", true)
			if _G[skins[i]] ~= _G["GhostFrameContentsFrame"] or _G[skins[i]] ~= _G["AutoCompleteBox"] then -- frame to blacklist from create shadow function
				_G[skins[i]]:CreateShadow("Default")
			end
			_G[skins[i]]:SetBackdropColor(unpack(C["media"].backdropfadecolor))
		end
		
		local ChatMenus = {
			"ChatMenu",
			"EmoteMenu",
			"LanguageMenu",
			"VoiceMacroMenu",		
		}
		--
		for i = 1, getn(ChatMenus) do
			if _G[ChatMenus[i]] == _G["ChatMenu"] then
				_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) self:ClearAllPoints() self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, E.Scale(30)) end)
			else
				_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) end)
			end
		end
		
		-- reskin popup buttons
		for i = 1, 2 do
			for j = 1, 3 do
				SkinButton(_G["StaticPopup"..i.."Button"..j])
			end
		end
		
		-- reskin all esc/menu buttons
		local BlizzardMenuButtons = {
			"Options", 
			"SoundOptions", 
			"UIOptions", 
			"Keybindings", 
			"Macros",
			"Ratings",
			"AddOns", 
			"Logout", 
			"Quit", 
			"Continue", 
			"MacOptions"
		}
		
		for i = 1, getn(BlizzardMenuButtons) do
			local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
			if ElvuiMenuButtons then
				SkinButton(ElvuiMenuButtons)
			end
		end
		
		if IsAddOnLoaded("OptionHouse") then
			SkinButton(GameMenuButtonOptionHouse)
		end
		
		-- skin return to graveyard button
		do
			SkinButton(GhostFrame)
			GhostFrame:SetBackdropColor(0,0,0,0)
			GhostFrame:SetBackdropBorderColor(0,0,0,0)
			GhostFrame.SetBackdropColor = E.dummy
			GhostFrame.SetBackdropBorderColor = E.dummy
			GhostFrame:ClearAllPoints()
			GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
			SkinButton(GhostFrameContentsFrame)
			GhostFrameContentsFrameIcon:SetTexture(nil)
			local x = CreateFrame("Frame", nil, GhostFrame)
			x:SetFrameStrata("MEDIUM")
			x:SetTemplate("Default")
			x:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, "TOPLEFT", E.Scale(-2), E.Scale(2))
			x:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			local tex = x:CreateTexture(nil, "OVERLAY")
			tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
			tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			tex:SetPoint("TOPLEFT", x, "TOPLEFT", E.Scale(2), E.Scale(-2))
			tex:SetPoint("BOTTOMRIGHT", x, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
		end
		
		-- hide header textures and move text/buttons.
		local BlizzardHeader = {
			"GameMenuFrame", 
			"InterfaceOptionsFrame", 
			"AudioOptionsFrame", 
			"VideoOptionsFrame",
			"ColorPickerFrame"
		}
		
		for i = 1, getn(BlizzardHeader) do
			local title = _G[BlizzardHeader[i].."Header"]			
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
				end
			end
		end
		
		-- here we reskin all "normal" buttons
		local BlizzardButtons = {
			"VideoOptionsFrameOkay", 
			"VideoOptionsFrameCancel", 
			"VideoOptionsFrameDefaults", 
			"VideoOptionsFrameApply", 
			"AudioOptionsFrameOkay", 
			"AudioOptionsFrameCancel", 
			"AudioOptionsFrameDefaults", 
			"InterfaceOptionsFrameDefaults", 
			"InterfaceOptionsFrameOkay", 
			"InterfaceOptionsFrameCancel",
			"ColorPickerOkayButton",
			"ColorPickerCancelButton",
			"ReadyCheckFrameYesButton",
			"ReadyCheckFrameNoButton",
		}
		
		for i = 1, getn(BlizzardButtons) do
			local ElvuiButtons = _G[BlizzardButtons[i]]
			if ElvuiButtons then
				SkinButton(ElvuiButtons)
			end
		end
		
		-- if a button position is not really where we want, we move it here
		_G["VideoOptionsFrameCancel"]:ClearAllPoints()
		_G["VideoOptionsFrameCancel"]:SetPoint("RIGHT",_G["VideoOptionsFrameApply"],"LEFT",-4,0)		 
		_G["VideoOptionsFrameOkay"]:ClearAllPoints()
		_G["VideoOptionsFrameOkay"]:SetPoint("RIGHT",_G["VideoOptionsFrameCancel"],"LEFT",-4,0)	
		_G["AudioOptionsFrameOkay"]:ClearAllPoints()
		_G["AudioOptionsFrameOkay"]:SetPoint("RIGHT",_G["AudioOptionsFrameCancel"],"LEFT",-4,0)
		_G["InterfaceOptionsFrameOkay"]:ClearAllPoints()
		_G["InterfaceOptionsFrameOkay"]:SetPoint("RIGHT",_G["InterfaceOptionsFrameCancel"],"LEFT", -4,0)
		_G["ColorPickerCancelButton"]:ClearAllPoints()
		_G["ColorPickerOkayButton"]:ClearAllPoints()
		_G["ColorPickerCancelButton"]:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", -6, 6)
		_G["ColorPickerOkayButton"]:SetPoint("RIGHT",_G["ColorPickerCancelButton"],"LEFT", -4,0)
		_G["ReadyCheckFrameYesButton"]:SetParent(_G["ReadyCheckFrame"])
		_G["ReadyCheckFrameNoButton"]:SetParent(_G["ReadyCheckFrame"]) 
		_G["ReadyCheckFrameYesButton"]:SetPoint("RIGHT", _G["ReadyCheckFrame"], "CENTER", -1, 0)
		_G["ReadyCheckFrameNoButton"]:SetPoint("LEFT", _G["ReadyCheckFrameYesButton"], "RIGHT", 3, 0)
		_G["ReadyCheckFrameText"]:SetParent(_G["ReadyCheckFrame"])	
		_G["ReadyCheckFrameText"]:ClearAllPoints()
		_G["ReadyCheckFrameText"]:SetPoint("TOP", 0, -12)
		
		-- others
		_G["ReadyCheckListenerFrame"]:SetAlpha(0)
		_G["ReadyCheckFrame"]:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
		
		RolePollPopup:SetTemplate("Transparent")
		RolePollPopup:CreateShadow("Default")
		LFDDungeonReadyDialog:SetTemplate("Transparent")
		LFDDungeonReadyDialog:CreateShadow("Default")
		SkinButton(LFDDungeonReadyDialogEnterDungeonButton)
		SkinButton(LFDDungeonReadyDialogLeaveQueueButton)
		SkinButton(ColorPickerOkayButton)
		SkinButton(ColorPickerCancelButton)
	end
		
	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		-- Skin main frame and reposition the header
		MacOptionsFrame:SetTemplate("Default", true)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
		--Skin internal frames
		MacOptionsFrameMovieRecording:SetTemplate("Default", true)
		MacOptionsITunesRemote:SetTemplate("Default", true)
 
		--Skin buttons
		SkinButton(_G["MacOptionsFrameCancel"])
		SkinButton(_G["MacOptionsFrameOkay"])
		SkinButton(_G["MacOptionsButtonKeybindings"])
		SkinButton(_G["MacOptionsFrameDefaults"])
		SkinButton(_G["MacOptionsButtonCompress"])
 
		--Reposition and resize buttons
		local tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsButtonCompress"]:GetPoint()
		_G["MacOptionsButtonCompress"]:SetWidth(136)
		_G["MacOptionsButtonCompress"]:ClearAllPoints()
		_G["MacOptionsButtonCompress"]:SetPoint(tPoint, tRTo, tRP, E.Scale(4), tY)
 
		_G["MacOptionsFrameCancel"]:SetWidth(96)
		_G["MacOptionsFrameCancel"]:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsFrameCancel"]:GetPoint()
		_G["MacOptionsFrameCancel"]:ClearAllPoints()
		_G["MacOptionsFrameCancel"]:SetPoint(tPoint, tRTo, tRP, E.Scale(-14), tY)
 
		_G["MacOptionsFrameOkay"]:ClearAllPoints()
		_G["MacOptionsFrameOkay"]:SetWidth(96)
		_G["MacOptionsFrameOkay"]:SetHeight(22)
		_G["MacOptionsFrameOkay"]:SetPoint("LEFT",_G["MacOptionsFrameCancel"],E.Scale(-99),0)
 
		_G["MacOptionsButtonKeybindings"]:ClearAllPoints()
		_G["MacOptionsButtonKeybindings"]:SetWidth(96)
		_G["MacOptionsButtonKeybindings"]:SetHeight(22)
		_G["MacOptionsButtonKeybindings"]:SetPoint("LEFT",_G["MacOptionsFrameOkay"],E.Scale(-99),0)
 
		_G["MacOptionsFrameDefaults"]:SetWidth(96)
		_G["MacOptionsFrameDefaults"]:SetHeight(22)

		-- why these buttons is using game menu template? oO
		_G["MacOptionsButtonCompressLeft"]:SetAlpha(0)
		_G["MacOptionsButtonCompressMiddle"]:SetAlpha(0)
		_G["MacOptionsButtonCompressRight"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsLeft"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsMiddle"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsRight"]:SetAlpha(0)
	end
end)