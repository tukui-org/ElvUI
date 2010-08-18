local TukuiSkin = CreateFrame("Frame", nil, UIParent)

-- NOTE: i'm not reskinning everything, too much thing to do and anyway, 80% of all frames are redone for Cataclysm
-- I don't want to loose my time reskinning all panels/frame, because in a couple of month we need to redo it. :x
-- thank to karudon for helping me reskinning some elements in default interface.

local function reskin(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")
	TukuiDB.SetTemplate(f)
    f:HookScript("OnEnter", function(self) self:SetBackdropBorderColor(.69,.31,.31) self:SetBackdropColor(.69,.31,.31,.1) end)
    f:HookScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor)) self:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor)) end)
end
		
TukuiSkin:RegisterEvent("ADDON_LOADED")
TukuiSkin:SetScript("OnEvent", function(self, event, addon)
	if IsAddOnLoaded("Skinner") then return end
	
	-- stuff not in Blizzard load-on-demand
	if addon == "Tukui" then
		-- frame (panels) we need to reskin
		local skins = {
			"StaticPopup1",
			"StaticPopup2",
			"GameMenuFrame",
			"InterfaceOptionsFrame",
			"VideoOptionsFrame",
			"AudioOptionsFrame",
			"LFDDungeonReadyStatus",
		}
		
		-- reskin popup buttons
		for i = 1, 2 do
			for j = 1, 2 do
				reskin(_G["StaticPopup"..i.."Button"..j])
			end
		end
		
		for i = 1, getn(skins) do
			TukuiDB.SetTemplate(_G[skins[i]])
		end
		
		-- reskin all esc/menu buttons
		local menuButtons = {"Options", "SoundOptions", "UIOptions", "Keybindings", "Macros", "AddOns", "Logout", "Quit", "Continue", "MacOptions"}
		for i = 1, getn(menuButtons) do
		local reskinmenubutton = _G["GameMenuButton"..menuButtons[i]]
			if reskinmenubutton then
				reskin(reskinmenubutton)
			end
		end
		
		-- hide header textures and move text.
		local header = {"GameMenuFrame", "InterfaceOptionsFrame", "AudioOptionsFrame", "VideoOptionsFrame"}
		for i = 1, getn(header) do
		local title = _G[header[i].."Header"]
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", header[i], 0, 0)
				end
			end
		end
		
		-- here we reskin "normal" buttons
		local buttons = {"VideoOptionsFrameOkay", "VideoOptionsFrameCancel", "VideoOptionsFrameDefaults", "VideoOptionsFrameApply", "AudioOptionsFrameOkay", "AudioOptionsFrameCancel", 
		                 "AudioOptionsFrameDefaults", "InterfaceOptionsFrameDefaults", "InterfaceOptionsFrameOkay", "InterfaceOptionsFrameCancel"}
		for i = 1, getn(buttons) do
		local reskinbutton = _G[buttons[i]]
			if reskinbutton then
				reskin(reskinbutton)
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
		
		-- reskin battle.net popup
		TukuiDB.SetTemplate(BNToastFrame)
		
		-- reskin dropdown list on unitframes
		TukuiDB.SetTemplate(DropDownList1MenuBackdrop)
		TukuiDB.SetTemplate(DropDownList2MenuBackdrop)
		TukuiDB.SetTemplate(DropDownList1Backdrop)
		TukuiDB.SetTemplate(DropDownList2Backdrop)
	end
	
	if addon == "Blizzard_BindingUI" then
		-- do stuff, this is just an example if you need to reskin addon that are load-on-demand
	end
	
	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		-- Skin main frame and reposition the header
		TukuiDB.SetTemplate(MacOptionsFrame)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
		--Skin internal frames
		TukuiDB.SetTemplate(MacOptionsFrameMovieRecording)
		TukuiDB.SetTemplate(MacOptionsITunesRemote)
 
		--Skin buttons
		reskin(_G["MacOptionsFrameCancel"])
		reskin(_G["MacOptionsFrameOkay"])
		reskin(_G["MacOptionsButtonKeybindings"])
		reskin(_G["MacOptionsFrameDefaults"])
		reskin(_G["MacOptionsButtonCompress"])
 
		--Reposition and resize buttons
		tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsButtonCompress"]:GetPoint()
		_G["MacOptionsButtonCompress"]:SetWidth(136)
		_G["MacOptionsButtonCompress"]:SetPoint(tPoint, tRTo, tRP, tX+4, tY)
 
		_G["MacOptionsFrameCancel"]:SetWidth(96)
		_G["MacOptionsFrameCancel"]:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsFrameCancel"]:GetPoint()
		_G["MacOptionsFrameCancel"]:SetPoint(tPoint, tRTo, tRP, tX-2, tY)
 
		_G["MacOptionsFrameOkay"]:ClearAllPoints()
		_G["MacOptionsFrameOkay"]:SetWidth(96)
		_G["MacOptionsFrameOkay"]:SetHeight(22)
		_G["MacOptionsFrameOkay"]:SetPoint("LEFT",_G["MacOptionsFrameCancel"],-99,0)
 
		_G["MacOptionsButtonKeybindings"]:ClearAllPoints()
		_G["MacOptionsButtonKeybindings"]:SetWidth(96)
		_G["MacOptionsButtonKeybindings"]:SetHeight(22)
		_G["MacOptionsButtonKeybindings"]:SetPoint("LEFT",_G["MacOptionsFrameOkay"],-99,0)
 
		_G["MacOptionsFrameDefaults"]:SetWidth(96)
		_G["MacOptionsFrameDefaults"]:SetHeight(22)
	end
end)