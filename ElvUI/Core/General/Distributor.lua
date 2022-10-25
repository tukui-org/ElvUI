local E, L, V, P, G = unpack(ElvUI)
local D = E:GetModule('Distributor')
local NP = E:GetModule('NamePlates')
local LibCompress = E.Libs.Compress
local LibBase64 = E.Libs.Base64

local _G = _G
local tonumber, type, gsub, pairs, pcall, loadstring = tonumber, type, gsub, pairs, pcall, loadstring
local len, format, split, find = strlen, format, strsplit, strfind

local CreateFrame = CreateFrame
local IsInRaid, UnitInRaid = IsInRaid, UnitInRaid
local IsInGroup, UnitInParty = IsInGroup, UnitInParty
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ACCEPT, CANCEL, YES, NO = ACCEPT, CANCEL, YES, NO
-- GLOBALS: ElvDB, ElvPrivateDB

local REQUEST_PREFIX = 'ELVUI_REQUEST'
local REPLY_PREFIX = 'ELVUI_REPLY'
local TRANSFER_PREFIX = 'ELVUI_TRANSFER'
local TRANSFER_COMPLETE_PREFIX = 'ELVUI_COMPLETE'

-- The active downloads
local Downloads = {}
local Uploads = {}

function D:Initialize()
	self.Initialized = true

	D:UpdateSettings()

	self.statusBar = CreateFrame('StatusBar', 'ElvUI_Download', E.UIParent)
	self.statusBar:CreateBackdrop()
	self.statusBar:SetStatusBarTexture(E.media.normTex)
	self.statusBar:SetStatusBarColor(0.95, 0.15, 0.15)
	self.statusBar:Size(250, 18)
	self.statusBar.text = self.statusBar:CreateFontString(nil, 'OVERLAY')
	self.statusBar.text:FontTemplate()
	self.statusBar.text:Point('CENTER')
	self.statusBar:Hide()
	E:RegisterStatusBar(self.statusBar)
end

function D:UpdateSettings()
	if E.global.general.allowDistributor then
		self:RegisterComm(REQUEST_PREFIX)
		self:RegisterEvent('CHAT_MSG_ADDON')
	else
		self:UnregisterComm(REQUEST_PREFIX)
		self:UnregisterEvent('CHAT_MSG_ADDON')
	end
end

-- Used to start uploads
function D:Distribute(target, otherServer, isGlobal)
	local profileKey, data
	if not isGlobal then
		profileKey = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		data = ElvDB.profiles[profileKey]
	else
		profileKey = 'global'
		data = ElvDB.global
	end

	if not data then return end

	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format('%s:%d:%s', profileKey, length, target)

	Uploads[profileKey] = {serialData = serialData, target = target}

	if otherServer then
		if IsInRaid() and UnitInRaid('target') then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID')
		elseif IsInGroup() and UnitInParty('target') then
			self:SendCommMessage(REQUEST_PREFIX, message, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'PARTY')
		else
			E:Print(L["Must be in group with the player if he isn't on the same server as you."])
			return
		end
	else
		self:SendCommMessage(REQUEST_PREFIX, message, 'WHISPER', target)
	end

	self:RegisterComm(REPLY_PREFIX)
	E:StaticPopup_Show('DISTRIBUTOR_WAITING')
end

function D:CHAT_MSG_ADDON(_, prefix, message, _, sender)
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
		local profile, length, sendTo = split(':', msg)

		if dist ~= 'WHISPER' and sendTo ~= E.myname then
			return
		end

		if self.statusBar:IsShown() then
			self:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)
			return
		end

		local textString = format(L["%s is attempting to share the profile %s with you. Would you like to accept the request?"], sender, profile)
		if profile == 'global' then
			textString = format(L["%s is attempting to share his filters with you. Would you like to accept the request?"], sender)
		end

		E.PopupDialogs.DISTRIBUTOR_RESPONSE = {
			text = textString,
			OnAccept = function()
				self.statusBar:SetMinMaxValues(0, length)
				self.statusBar:SetValue(0)
				self.statusBar.text:SetFormattedText(L["Data From: %s"], sender)
				E:StaticPopupSpecial_Show(self.statusBar)
				self:SendCommMessage(REPLY_PREFIX, profile..':YES', dist, sender)
			end,
			OnCancel = function()
				self:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)
			end,
			button1 = ACCEPT,
			button2 = CANCEL,
			timeout = 30,
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

		local profileKey, response = split(':', msg)
		if response == 'YES' then
			self:RegisterComm(TRANSFER_COMPLETE_PREFIX)
			self:SendCommMessage(TRANSFER_PREFIX, Uploads[profileKey].serialData, dist, Uploads[profileKey].target)
		else
			E:StaticPopup_Show('DISTRIBUTOR_REQUEST_DENIED')
		end

		Uploads[profileKey] = nil
	elseif prefix == TRANSFER_PREFIX then
		self:UnregisterComm(TRANSFER_PREFIX)
		E:StaticPopupSpecial_Hide(self.statusBar)

		local profileKey = Downloads[sender].profile
		local success, data = self:Deserialize(msg)

		if success then
			local textString = format(L["Profile download complete from %s, would you like to load the profile %s now?"], sender, profileKey)

			if profileKey == 'global' then
				textString = format(L["Filter download complete from %s, would you like to apply changes now?"], sender)
			else
				if not ElvDB.profiles[profileKey] then
					ElvDB.profiles[profileKey] = data
				else
					textString = format(L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."], sender, profileKey)
					E.PopupDialogs.DISTRIBUTOR_CONFIRM = {
						text = textString,
						button1 = ACCEPT,
						hasEditBox = 1,
						editBoxWidth = 350,
						maxLetters = 127,
						OnAccept = function(popup)
							ElvDB.profiles[popup.editBox:GetText()] = data
							E.Libs.AceAddon:GetAddon('ElvUI').data:SetProfile(popup.editBox:GetText())
							E:StaggeredUpdateAll()
							Downloads[sender] = nil
						end,
						OnShow = function(popup) popup.editBox:SetText(profileKey) popup.editBox:SetFocus() end,
						timeout = 0,
						exclusive = 1,
						whileDead = 1,
						hideOnEscape = 1,
						preferredIndex = 3
					}

					E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
					self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)
					return
				end
			end

			E.PopupDialogs.DISTRIBUTOR_CONFIRM = {
				text = textString,
				OnAccept = function()
					if profileKey == 'global' then
						E:CopyTable(ElvDB.global, data)
						E:StaggeredUpdateAll()
					else
						E.Libs.AceAddon:GetAddon('ElvUI').data:SetProfile(profileKey)
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
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
			self:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'FAILED', dist, sender)
		end
	elseif prefix == TRANSFER_COMPLETE_PREFIX then
		self:UnregisterComm(TRANSFER_COMPLETE_PREFIX)
		if msg == 'COMPLETE' then
			E:StaticPopup_Show('DISTRIBUTOR_SUCCESS')
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
		end
	end
end

--Keys that should not be exported
D.blacklistedKeys = {
	profile = {
		gridSize = true,
		general = {
			cropIcon = true,
			numberPrefixStyle = true
		},
		chat = {
			hideVoiceButtons = true
		},
		bags = {
			shownBags = true
		}
	},
	private = {},
	global = {
		profileCopy = true,
		general = {
			AceGUI = true,
			UIScale = true,
			locale = true,
			version = true,
			eyefinity = true,
			ultrawide = true,
			disableTutorialButtons = true,
			allowDistributor = true
		},
		chat = {
			classColorMentionExcludedNames = true
		},
		datatexts = {
			newPanelInfo = true,
			settings = {
				Currencies = {
					tooltipData = true
				}
			}
		},
		nameplates = {
			filters = true
		},
		unitframe = {
			aurafilters = true,
			aurawatch = true,
			newCustomText = true,
		}
	},
}

--Keys that auto or user generated tables.
D.GeneratedKeys = {
	profile = {
		convertPages = true,
		movers = true,
		actionbar = {},
		nameplates = { -- this is supposed to have an 's' because yeah, oh well
			filters = true
		},
		datatexts = {
			panels = true,
		},
		unitframe = {
			units = {} -- required for the scope below for customTexts
		}
	},
	private = {
		theme = true,
		install_complete = true
	},
	global = {
		datatexts = {
			customPanels = true,
			customCurrencies = true
		},
		unitframe = {
			AuraBarColors = true,
			aurafilters = true,
			aurawatch = true
		},
		nameplates = {
			filters = true
		}
	}
}

do
	local units = D.GeneratedKeys.profile.unitframe.units
	for unit in pairs(P.unitframe.units) do
		units[unit] = {customTexts = true}
	end

	for i = 1, 10 do
		D.GeneratedKeys.profile.actionbar['bar'..i] = { paging = true }
	end
end

local function GetProfileData(profileType)
	if not profileType or type(profileType) ~= 'string' then
		E:Print('Bad argument #1 to "GetProfileData" (string expected)')
		return
	end

	local profileData, profileKey = {}
	if profileType == 'profile' then
		--Copy current profile data
		profileKey = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		profileData = E:CopyTable(profileData, ElvDB.profiles[profileKey])

		--This table will also hold all default values, not just the changed settings.
		--This makes the table huge, and will cause the WoW client to lock up for several seconds.
		--We compare against the default table and remove all duplicates from our table. The table is now much smaller.
		profileData = E:RemoveTableDuplicates(profileData, P, D.GeneratedKeys.profile)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.profile)
	elseif profileType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		profileData = E:CopyTable(profileData, ElvPrivateDB.profiles[privateKey])
		profileData = E:RemoveTableDuplicates(profileData, V, D.GeneratedKeys.private)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.private)
		profileKey = 'private'
	elseif profileType == 'global' then
		profileData = E:CopyTable(profileData, ElvDB.global)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.global)
		profileKey = 'global'
	elseif profileType == 'filters' then
		profileData.unitframe = {}
		profileData.unitframe.aurafilters = E:CopyTable({}, ElvDB.global.unitframe.aurafilters)
		profileData.unitframe.aurawatch = E:CopyTable({}, ElvDB.global.unitframe.aurawatch)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
		profileKey = 'filters'
	elseif profileType == 'styleFilters' then
		profileKey = 'styleFilters'
		profileData.nameplates = {}
		profileData.nameplates.filters = E:CopyTable({}, ElvDB.global.nameplates.filters)
		NP:StyleFilterClearDefaults(profileData.nameplates.filters)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
	end

	return profileKey, profileData
end

local function GetProfileExport(profileType, exportFormat)
	local profileExport, exportString
	local profileKey, profileData = GetProfileData(profileType)

	if not profileKey or not profileData or (profileData and type(profileData) ~= 'table') then
		E:Print('Error getting data from "GetProfileData"')
		return
	end

	if exportFormat == 'text' then
		local serialData = D:Serialize(profileData)
		exportString = D:CreateProfileExport(serialData, profileType, profileKey)
		local compressedData = LibCompress:Compress(exportString)
		local encodedData = LibBase64:Encode(compressedData)
		profileExport = encodedData
	elseif exportFormat == 'luaTable' then
		exportString = E:TableToLuaString(profileData)
		profileExport = D:CreateProfileExport(exportString, profileType, profileKey)
	elseif exportFormat == 'luaPlugin' then
		profileExport = E:ProfileTableToPluginFormat(profileData, profileType)
	end

	return profileKey, profileExport
end

function D:CreateProfileExport(dataString, profileType, profileKey)
	local returnString

	if profileType == 'profile' then
		returnString = format('%s::%s::%s', dataString, profileType, profileKey)
	else
		returnString = format('%s::%s', dataString, profileType)
	end

	return returnString
end

function D:GetImportStringType(dataString)
	local stringType = ''

	if LibBase64:IsBase64(dataString) then
		stringType = 'Base64'
	elseif find(dataString, '{') then --Basic check to weed out obviously wrong strings
		stringType = 'Table'
	end

	return stringType
end

function D:Decode(dataString)
	local profileInfo, profileType, profileKey, profileData
	local stringType = self:GetImportStringType(dataString)

	if stringType == 'Base64' then
		local decodedData = LibBase64:Decode(dataString)
		local decompressedData, decompressedMessage = LibCompress:Decompress(decodedData)

		if not decompressedData then
			E:Print('Error decompressing data:', decompressedMessage)
			return
		end

		local serializedData, success
		serializedData, profileInfo = E:SplitString(decompressedData, '^^::') -- '^^' indicates the end of the AceSerializer string

		if not profileInfo then
			E:Print('Error importing profile. String is invalid or corrupted!')
			return
		end

		serializedData = format('%s%s', serializedData, '^^') --Add back the AceSerializer terminator
		profileType, profileKey = E:SplitString(profileInfo, '::')
		success, profileData = D:Deserialize(serializedData)

		if not success then
			E:Print('Error deserializing:', profileData)
			return
		end
	elseif stringType == 'Table' then
		local profileDataAsString
		profileDataAsString, profileInfo = E:SplitString(dataString, '}::') -- '}::' indicates the end of the table

		if not profileInfo then
			E:Print('Error extracting profile info. Invalid import string!')
			return
		end

		if not profileDataAsString then
			E:Print('Error extracting profile data. Invalid import string!')
			return
		end

		profileDataAsString = format('%s%s', profileDataAsString, '}') --Add back the missing '}'
		profileDataAsString = gsub(profileDataAsString, '\124\124', '\124') --Remove escape pipe characters
		profileType, profileKey = E:SplitString(profileInfo, '::')

		local profileMessage
		local profileToTable = loadstring(format('%s %s', 'return', profileDataAsString))
		if profileToTable then profileMessage, profileData = pcall(profileToTable) end

		if profileMessage and (not profileData or type(profileData) ~= 'table') then
			E:Print('Error converting lua string to table:', profileMessage)
			return
		end
	end

	return profileType, profileKey, profileData
end

local function SetImportedProfile(profileType, profileKey, profileData, force)
	if profileType == 'profile' then
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.profile) --Remove unwanted options from import

		if not ElvDB.profiles[profileKey] or force then
			if force and E.data.keys.profile == profileKey then
				--Overwriting an active profile doesn't update when calling SetProfile
				--So make it look like we use a different profile
				E.data.keys.profile = profileKey..'_Temp'
			end

			ElvDB.profiles[profileKey] = profileData

			--Calling SetProfile will now update all settings correctly
			E.data:SetProfile(profileKey)
		else
			E:StaticPopup_Show('IMPORT_PROFILE_EXISTS', nil, nil, {profileKey = profileKey, profileType = profileType, profileData = profileData})
		end
	elseif profileType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		if privateKey then
			profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.private) --Remove unwanted options from import
			ElvPrivateDB.profiles[privateKey] = profileData
			E:StaticPopup_Show('IMPORT_RL')
		end
	elseif profileType == 'global' then
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.global) --Remove unwanted options from import
		E:CopyTable(ElvDB.global, profileData)
		E:StaticPopup_Show('IMPORT_RL')
	elseif profileType == 'filters' then
		E:CopyTable(ElvDB.global.unitframe, profileData.unitframe)
		E:UpdateUnitFrames()
	elseif profileType == 'styleFilters' then
		E:CopyTable(ElvDB.global.nameplates, profileData.nameplates or profileData.nameplate)
		E:UpdateNamePlates()
	end
end

function D:ExportProfile(profileType, exportFormat)
	if not profileType or not exportFormat then
		E:Print('Bad argument to "ExportProfile" (string expected)')
		return
	end

	local profileKey, profileExport = GetProfileExport(profileType, exportFormat)

	return profileKey, profileExport
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData = self:Decode(dataString)

	if not profileData or type(profileData) ~= 'table' then
		E:Print('Error: something went wrong when converting string to table!')
		return
	end

	if profileType and ((profileType == 'profile' and profileKey) or profileType ~= 'profile') then
		SetImportedProfile(profileType, profileKey, profileData)
	end

	return true
end

E.PopupDialogs.DISTRIBUTOR_SUCCESS = {
	text = L["Your profile was successfully recieved by the player."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_WAITING = {
	text = L["Profile request sent. Waiting for response from player."],
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 20,
}

E.PopupDialogs.DISTRIBUTOR_REQUEST_DENIED = {
	text = L["Request was denied by user."],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_FAILED = {
	text = L["Lord! It's a miracle! The download up and vanished like a fart in the wind! Try Again!"],
	whileDead = 1,
	hideOnEscape = 1,
	button1 = _G.OKAY,
}

E.PopupDialogs.DISTRIBUTOR_RESPONSE = {}
E.PopupDialogs.DISTRIBUTOR_CONFIRM = {}

E.PopupDialogs.IMPORT_PROFILE_EXISTS = {
	text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self, data)
		SetImportedProfile(data.profileType, self.editBox:GetText(), data.profileData, true)
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() == '' then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable()
		end
	end,
	OnShow = function(self, data)
		self.editBox:SetText(data.profileKey)
		self.editBox:SetFocus()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

E.PopupDialogs.IMPORT_RL = {
	text = L["You have imported settings which may require a UI reload to take effect. Reload now?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = _G.ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

E:RegisterModule(D:GetName())
