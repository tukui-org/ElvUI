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

--Global variables that we don't cache, list them here for the mikk"s Find Globals script
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
	self.statusBar.text = self.statusBar:CreateFontString(nil, "OVERLAY")
	self.statusBar.text:FontTemplate()
	self.statusBar.text:SetPoint("CENTER")
	self.statusBar:Hide()
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
		profileKey = "global"
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
		print("Bad argument #1 to 'GetProfileprofileData' (string expected)")
	end

	local profileKey
	local profileData = {}

	if profileType == "profile" then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		--Copy current profile data
		profileData = E:CopyTable(profileData , ElvDB.profiles[profileKey])
		--This table will also hold all default values, not just the changed settings.
		--This makes the table huge, and will cause the WoW client to lock up for several seconds.
		--We compare against the default table and remove all duplicates from our table. The table is now much smaller.
		profileData = E:RemoveTableDuplicates(profileData, P)

	elseif profileType == "private" then
		local privateProfileKey = E.myname..' - '..E.myrealm
		profileKey = "private"

		profileData = E:CopyTable(profileData, ElvPrivateDB.profiles[privateProfileKey])
		profileData = E:RemoveTableDuplicates(profileData, V)

	elseif profileType == "global" then
		profileKey = "global"

		profileData = E:CopyTable(profileData, ElvDB.global)
		profileData = E:RemoveTableDuplicates(profileData, G)
	end
	
	return profileKey, profileData
end

local function ProfileToString(profileType)
	local profileKey, profileData = GetProfileData(profileType)
	
	if not profileKey or not profileData then
		print("Error in ProfileToString, GetProfileData returned nil!")
		return
	end

	local serialData = D:Serialize(profileData)
	local exportString

	if profileType == "profile" then
		exportString = format("%s:%s:%s", serialData, profileType, profileKey)
	else
		exportString = format("%s:%s", serialData, profileType)
	end
	
	local compressedData = LibCompress:CompressHuffman(exportString)
	local encodedData = LibBase64:Encode(compressedData)

	return profileKey, encodedData
end

local function ProfileToLuaString(profileType)
	local profileKey, profileData = GetProfileData(profileType)
	
	if not profileKey or not profileData then
		print("Error in ProfileToLuaString, GetProfileData returned nil!")
		return
	end

	local profileExport, exportString
	if profileData then
		exportString = E:TableToLuaString(profileData)
		if profileType == "profile" then
			profileExport = format("%s:%s:%s", exportString, profileType, profileKey)
		else
			profileExport = format("%s:%s", exportString, profileType)
		end
	end

    return profileKey, profileExport
end

local function GetExportString(profileType, exportType)
	local profileKey, profileExport
	if exportType == "text" then
		profileKey, profileExport = ProfileToString(profileType)
	elseif exportType == "lua" then
		profileKey, profileExport = ProfileToLuaString(profileType)
	end
	
	return profileKey, profileExport
end

local function SetImportedProfile(profileType, profileKey, profileData, force)
	D.profileType = nil
	D.profileKey = nil
	D.profileData = nil

	if profileType == "profile" then
		if not ElvDB.profiles[profileKey] or force then
			if force then
				--Overwriting a profile doesn't update immediately
				--So make it look like we use a different profile
				local tempKey = profileKey.."_Temp"
				LibStub("AceAddon-3.0"):GetAddon("ElvUI").data.keys.profile = tempKey
			end
			ElvDB.profiles[profileKey] = profileData
			LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(profileKey)
			E:UpdateAll(true)
			print("just set profile:", profileKey)
		else
			D.profileType = profileType
			D.profileKey = profileKey
			D.profileData = profileData
			E:StaticPopup_Show('IMPORT_PROFILE_EXISTS')
		end
	elseif profileType == "private" then
		local profileKey = ElvPrivateDB.profileKeys[E.myname..' - '..E.myrealm]
		ElvPrivateDB.profiles[profileKey] = profileData
		E:StaticPopup_Show('CONFIG_RL')
	elseif profileType == "global" then
		E:CopyTable(ElvDB.global, profileData)
		E:UpdateAll(true)
	end
end

function D:ExportProfile(profileType, exportType)
	if not profileType then
		print("Bad argument #1 to 'ExportProfile' (string expected)")
	end
	if not exportType then
		print("Bad argument #2 to 'ExportProfile' (string expected)")
	end

	local profileKey, profileData = GetExportString(profileType, exportType)
	
	if not profileKey or not profileData then
		print("Error: something went wrong")
	end
	return profileKey, profileData
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData
	local isBase64 = LibBase64:IsBase64(dataString)
	
	if isBase64 then
		local decodedData = LibBase64:Decode(dataString)
		local decompressedData, message = LibCompress:DecompressHuffman(decodedData)
		
		if not decompressedData then
			print("Error decompressing data:", message)
			return
		end
		
		local serializedData, success
		serializedData, profileType, profileKey = split(":", decompressedData)
		success, profileData = D:Deserialize(serializedData)
		if not success then
			print("Error deserializing:", profileData)
			return
		end
	else
		--Importing lua strings is currently not working correctly because of how mover strings are saved
		--See http://git.tukui.org/Elv/elvui/commit/f74fa2bdde45328a82689c8f781798dd4af07b12
		-- local profileDataAsString
		-- profileDataAsString, profileType, profileKey = split(":", dataString)
		-- profileData, message = loadstring(format("%s %s", "return", profileDataAsString))()
		--if not profileData then
			--print("Error converting lua string to table:", message)
			--return
		--end
		E:Print("Sorry, importing a lua string is currently not working. It will be fixed soon(tm)")
		return
	end
	
	if not profileData or type(profileData) ~= "table" then
		print("Error importing profile: Corrupted string?")
		return
	end
	
	if not profileType or (profileType and profileType == "profile" and not profileKey) then
		--Can't remember what I was doing here. Will need to look at it again later.
	else
		SetImportedProfile(profileType, profileKey, profileData)
	end
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
	text = L["The profile you tried to import already exists. If you don't choose a new name, then it will overwrite your current profile."],
	button1 = ACCEPT,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self)
		local profileType = D.profileType
		local profileKey = self.editBox:GetText()
		local profileData = D.profileData
		SetImportedProfile(profileType, profileKey, profileData, true)
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() == "" then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable()
		end
	end,
	OnShow = function(self) self.editBox:SetText(D.profileKey) self.editBox:SetFocus() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

E:RegisterModule(D:GetName())