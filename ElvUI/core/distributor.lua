local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:NewModule('Distributor', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibBase64 = LibStub("LibBase64-1.0-ElvUI")

--Cache global variables
local tonumber = tonumber
local len, format, split = string.len, string.format, string.split
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInRaid, UnitInRaid = IsInRaid, UnitInRaid
local IsInGroup, UnitInParty = IsInGroup, UnitInParty
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ACCEPT, CANCEL, YES, NO = ACCEPT, CANCEL, YES, NO

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub, UIParent, ElvDB

----------------------------------
-- CONSTANTS
----------------------------------

local REQUEST_PREFIX = "ELVUI_REQUEST"
local REPLY_PREFIX = "ELVUI_REPLY"
local TRANSFER_PREFIX = "ELVUI_TRANSFER"
local TRANSFER_COMPLETE_PREFIX = "ELVUI_COMPLETE"

-- The active downloads
local Downloads = {}
local Uploads = {}

function D:Initialize()
	self:RegisterComm(REQUEST_PREFIX)
	self:RegisterEvent("CHAT_MSG_ADDON")

	self.statusBar = CreateFrame("StatusBar", "ElvUI_Download", UIParent)
	self.statusBar:CreateBackdrop('Default')
	self.statusBar:SetStatusBarTexture(E.media.normTex)
	self.statusBar:SetStatusBarColor(0.95, 0.15, 0.15)
	self.statusBar:Size(250, 18)
	self.statusBar.text = self.statusBar:CreateFontString(nil, 'OVERLAY')
	self.statusBar.text:FontTemplate()
	self.statusBar.text:SetPoint("CENTER")
	self.statusBar:Hide()

	--Export Interface
	local AceGUI = LibStub("AceGUI-3.0")
	local exportImport = AceGUI:Create("Frame");
	exportImport:EnableResize(false)
	exportImport.frame:SetWidth(890)
	exportImport.frame:SetHeight(651)
	exportImport.frame:SetFrameStrata("TOOLTIP")
	exportImport:SetLayout("flow");
	exportImport:Hide();
	self.exportImport = exportImport

	local Box = AceGUI:Create("MultiLineEditBox");
	Box:SetNumLines(35)
	Box:DisableButton(true)
	Box:SetWidth(870)
	exportImport:AddChild(Box);
	self.exportImport.Box = Box
	
	local CheckBox = AceGUI:Create("CheckBox")
	CheckBox:SetLabel("Export As Lua")
	exportImport:AddChild(CheckBox);
	self.exportImport.CheckBox = CheckBox
	
	local exportButton = AceGUI:Create("Button")
	exportButton:SetText("Export Profile")
	exportButton:SetAutoWidth(true)
	exportButton:SetCallback("OnClick", function()
		print("exporting profile")
		-- self:ExportProfile("profile", self.exportImport.CheckBox:GetValue())
		self:ExportProfile()
	end)
	exportImport:AddChild(exportButton)
	exportButton.frame:Hide()
	self.exportImport.exportButton = exportButton
	
	local importButton = AceGUI:Create("Button")
	importButton:SetText("Import Profile")
	importButton:SetAutoWidth(true)
	importButton:SetCallback("OnClick", function()
		self:ImportProfile(self.exportImport.Box:GetText())
	end)
	exportImport:AddChild(importButton)
	importButton.frame:Hide()
	self.exportImport.importButton = importButton
end

-- Used to start uploads
function D:Distribute(target, otherServer, isGlobal)
	local profileKey, data
	if not isGlobal then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = ElvDB.profiles[profileKey]
	else
		profileKey = 'global'
		data = ElvDB.global
	end

	if not data or not profileKey then return end

	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("%s:%d:%s", profileKey, length, target)

	Uploads[profileKey] = {
		serialData = serialData,
		target = target,
	}

	if otherServer then
		if IsInRaid() and UnitInRaid("target") then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
		elseif IsInGroup() and UnitInParty("target") then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
		else
			E:Print(L["Must be in group with the player if he isn't on the same server as you."])
			return
		end
	else
		self:SendCommMessage(REQUEST_PREFIX, message, "WHISPER", target)
	end
	self:RegisterComm(REPLY_PREFIX)
	E:StaticPopup_Show('DISTRIBUTOR_WAITING')
end

function D:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	if prefix ~= TRANSFER_PREFIX or not Downloads[sender] then return end
	local cur = len(message)
	local max = Downloads[sender].length
	Downloads[sender].current = Downloads[sender].current + cur

	if Downloads[sender].current > max then
		Downloads[sender].current = max
	end

	self.statusBar:SetValue(Downloads[sender].current)
end

function D:OnCommReceived(prefix, msg, dist, sender)
	if prefix == REQUEST_PREFIX then
		local profile, length, sendTo = split(":", msg)

		if dist ~= "WHISPER" and sendTo ~= E.myname then
			return
		end

		if self.statusBar:IsShown() then
			self:SendCommMessage(REPLY_PREFIX, profile..":NO", dist, sender)
			return
		end

		local textString = format(L["%s is attempting to share the profile %s with you. Would you like to accept the request?"], sender, profile)
		if profile == "global" then
			textString = format(L["%s is attempting to share his filters with you. Would you like to accept the request?"], sender)
		end

		E.PopupDialogs['DISTRIBUTOR_RESPONSE'] = {
			text = textString,
			OnAccept = function()
				self.statusBar:SetMinMaxValues(0, length)
				self.statusBar:SetValue(0)
				self.statusBar.text:SetFormattedText(L["Data From: %s"], sender)
				E:StaticPopupSpecial_Show(self.statusBar)
				self:SendCommMessage(REPLY_PREFIX, profile..":YES", dist, sender)
			end,
			OnCancel = function()
				self:SendCommMessage(REPLY_PREFIX, profile..":NO", dist, sender)
			end,
			button1 = ACCEPT,
			button2 = CANCEL,
			timeout = 32,
			whileDead = 1,
			hideOnEscape = 1,
		}
		E:StaticPopup_Show('DISTRIBUTOR_RESPONSE')

		Downloads[sender] = {
			current = 0,
			length = tonumber(length),
			profile = profile,
		}

		self:RegisterComm(TRANSFER_PREFIX)
	elseif prefix == REPLY_PREFIX then
		self:UnregisterComm(REPLY_PREFIX)
		E:StaticPopup_Hide('DISTRIBUTOR_WAITING')

		local profileKey, response = split(":", msg)
		if response == "YES" then
			self:RegisterComm(TRANSFER_COMPLETE_PREFIX)
			self:SendCommMessage(TRANSFER_PREFIX, Uploads[profileKey].serialData, dist, Uploads[profileKey].target)
			Uploads[profileKey] = nil
		else
			E:StaticPopup_Show('DISTRIBUTOR_REQUEST_DENIED')
			Uploads[profileKey] = nil
		end
	elseif prefix == TRANSFER_PREFIX then
		self:UnregisterComm(TRANSFER_PREFIX)
		E:StaticPopupSpecial_Hide(self.statusBar)

		local profileKey = Downloads[sender].profile
		local success, data = self:Deserialize(msg)

		if success then
			local textString = format(L["Profile download complete from %s, would you like to load the profile %s now?"], sender, profileKey)

			if profileKey == "global" then
				textString = format(L["Filter download complete from %s, would you like to apply changes now?"], sender)
			else
				if not ElvDB.profiles[profileKey] then
					ElvDB.profiles[profileKey] = data
				else
					textString = format(L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."], sender, profileKey)
					E.PopupDialogs['DISTRIBUTOR_CONFIRM'] = {
						text = textString,
						button1 = ACCEPT,
						hasEditBox = 1,
						editBoxWidth = 350,
						maxLetters = 127,
						OnAccept = function(self)
							ElvDB.profiles[self.editBox:GetText()] = data
							LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(self.editBox:GetText())
							E:UpdateAll(true)
							Downloads[sender] = nil
						end,
						OnShow = function(self) self.editBox:SetText(profileKey) self.editBox:SetFocus() end,
						timeout = 0,
						exclusive = 1,
						whileDead = 1,
						hideOnEscape = 1,
						preferredIndex = 3
					}

					E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
					self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "COMPLETE", dist, sender)
					return
				end
			end

			E.PopupDialogs['DISTRIBUTOR_CONFIRM'] = {
				text = textString,
				OnAccept = function()
					if profileKey == "global" then
						E:CopyTable(ElvDB.global, data)
						E:UpdateAll(true)
					else
						LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(profileKey)
					end
					Downloads[sender] = nil
				end,
				OnCancel = function()
					Downloads[sender] = nil
				end,
				button1 = YES,
				button2 = NO,
				whileDead = 1,
				hideOnEscape = 1,
			}

			E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "COMPLETE", dist, sender)
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, "FAILED", dist, sender)
		end
	elseif prefix == TRANSFER_COMPLETE_PREFIX then
		self:UnregisterComm(TRANSFER_COMPLETE_PREFIX)
		if msg == "COMPLETE" then
			E:StaticPopup_Show('DISTRIBUTOR_SUCCESS')
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
		end
	end
end

local function GetProfileData(profileType)
	if not profileType or type(profileType) ~= "string" then
		print("Error getting profile data. You must supply 'profileType' argument (string)")
	end

	local profileKey, success
	local data = {}

	if profileType == "profile" then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = table.copy(ElvDB.profiles[profileKey], true)
		success, data = E:CleanTableDuplicates(data, P)

	elseif profileType == "private" then
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = table.copy(ElvPrivateDB.profiles[profileKey], true)
		success, data = E:CleanTableDuplicates(data, V)

	elseif profileType == "global" then
		profileKey = 'global'

		data = table.copy(ElvDB.global, true)
		success, data = E:CleanTableDuplicates(data, G)
	end

	if not success then
		print("Error cleaning table:", data)
		return
	end
	
	return profileKey, data
end

function D:ProfileToString(profileType)
	local profileKey, data = GetProfileData(profileType)
	
	if not profileKey or not data then
		return "Error exporting profile"
	end

	local serialData = self:Serialize(data)
	local exportString = format("%s:%s:%s", profileType, profileKey, serialData)
	local compressedData = LibCompress:CompressHuffman(exportString)
	local encodedData = LibBase64:Encode(compressedData)

	return profileKey, encodedData
end

function D:ProfileToLuaString(profileType)
	local profileKey, profileData = GetProfileData(profileType)

	local profileExport
	if profileData then
		profileExport = E:TableToLuaString(profileData)
	end

    return profileKey, profileExport
end

function D:Decode(str)
	local isBase64 = LibBase64:IsBase64(str)
	
	if isBase64 then
		print("base64 detected")
		local decodedData = LibBase64:Decode(str)
		local decompressedData, message = LibCompress:DecompressHuffman(decodedData)
		
		if not decompressedData then
			print("Error decompressing data:", message)
			return
		end
		
		local profileType, profileKey, serialData = split(":", decompressedData)
		local success, profileData = self:Deserialize(serialData)
		if not success then
			print("Error deserializing:", profileData)
			return
		end
		
		return profileType, profileKey, profileData
	else
		print("no base64")
	end
end

function D:ExportProfile()
	local profileType = "profile" --TODO: Let the user choose profile type
	local profileKey, profileExport = self:GetExportString(profileType, self.exportImport.CheckBox:GetValue())
	local Box = self.exportImport.Box
	Box:SetLabel("Profile type: "..profileType.." - Profile name: "..profileKey);
	Box:SetText(profileExport);
	Box.editBox:HighlightText();
	Box:SetFocus();
	Box.exportString = profileExport
end

function D:GetExportString(profileType, asLua)
	local profileKey, profileExport
	if not asLua then
		profileKey, profileExport = self:ProfileToString(profileType)
	else
		profileKey, profileExport = self:ProfileToLuaString(profileType)
	end
	
	return profileKey, profileExport
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData = self:Decode(dataString)
	
	if not profileType or not profileKey or not profileData then
		print("something wrong with profile")
		return
	end
	
	if type(profileData) == "string" then
		self.exportImport.Box:SetText(profileData)
		return
	end
	
	if not ElvDB.profiles[profileKey] then
		ElvDB.profiles[profileKey] = profileData
		LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(profileKey)
		E:UpdateAll(true)
	else
		self.tempData = profileData
		E:StaticPopup_Show('IMPORT_PROFILE_EXISTS')
	end
end

function D:Export_Open()
	D:ExportProfile()

	local Box = self.exportImport.Box
	Box.editBox:SetScript("OnEscapePressed", function() self:Export_Close(); end);
	Box.editBox:SetScript("OnChar", function() Box:SetText(Box.exportString); Box.editBox:HighlightText(); end);
	Box.editBox:SetScript("OnMouseUp", function() Box.editBox:HighlightText(); end);
	Box.editBox:SetScript("OnTextChanged", nil);
	Box.button:Hide();

	self.exportImport:Show()
	self.exportImport.importButton.frame:Hide()
	self.exportImport.exportButton.frame:Show()
	self.exportImport.CheckBox.frame:Show()
end

function D:Export_Close()
	self.exportImport.Box:ClearFocus();
	self.exportImport:Hide();
end

function D:Import_Open()
	self.exportImport:Show()
	self.exportImport.importButton.frame:Show()
	self.exportImport.CheckBox.frame:Hide()
	self.exportImport.exportButton.frame:Hide()

	local Box = self.exportImport.Box
	Box.editBox:SetScript("OnEscapePressed", nil);
	Box.editBox:SetScript("OnChar", nil);
	Box.editBox:SetScript("OnMouseUp", nil);
	Box.editBox:SetScript("OnTextChanged", nil);
	Box.button:Hide();
	Box:SetText("");
end

E.PopupDialogs['DISTRIBUTOR_SUCCESS'] = {
	text = L["Your profile was successfully recieved by the player."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs['DISTRIBUTOR_WAITING'] = {
	text = L["Profile request sent. Waiting for response from player."],
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 35,
}

E.PopupDialogs['DISTRIBUTOR_REQUEST_DENIED'] = {
	text = L["Request was denied by user."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs['DISTRIBUTOR_FAILED'] = {
	text = L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = OKAY,
}

E.PopupDialogs['DISTRIBUTOR_RESPONSE'] = {}
E.PopupDialogs['DISTRIBUTOR_CONFIRM'] = {}

E.PopupDialogs['IMPORT_PROFILE_EXISTS'] = {
	text = L["The profile you tried to import already exists. Please choose a new name for the imported profile."],
	button1 = ACCEPT,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self)
		if self.editBox:GetText() == "" then return; end
		ElvDB.profiles[self.editBox:GetText()] = D.tempData
		D.tempData = nil
		LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(self.editBox:GetText())
		E:UpdateAll(true)
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
}

E:RegisterModule(D:GetName())