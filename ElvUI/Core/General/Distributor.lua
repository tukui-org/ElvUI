local E, L, V, P, G = unpack(ElvUI)
local D = E:GetModule('Distributor')
local NP = E:GetModule('NamePlates')
local LibDeflate = E.Libs.Deflate

local _G = _G
local tonumber, type, gsub, pairs, pcall, loadstring = tonumber, type, gsub, pairs, pcall, loadstring
local strlen, format, split, strmatch, strfind = strlen, format, strsplit, strmatch, strfind

local ReloadUI = ReloadUI
local CreateFrame = CreateFrame
local IsInRaid, UnitInRaid = IsInRaid, UnitInRaid
local IsInGroup, UnitInParty = IsInGroup, UnitInParty
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local ACCEPT, CANCEL, YES, NO = ACCEPT, CANCEL, YES, NO
-- GLOBALS: ElvDB, ElvPrivateDB

local EXPORT_PREFIX = '!E1!' -- also in Options StyleFilters
local REQUEST_PREFIX = 'ELVUI_REQUEST'
local REPLY_PREFIX = 'ELVUI_REPLY'
local TRANSFER_PREFIX = 'ELVUI_TRANSFER'
local TRANSFER_COMPLETE_PREFIX = 'ELVUI_COMPLETE'

-- Set compression
LibDeflate.compressLevel = { level = 5 }

-- The active downloads
local Downloads = {}
local Uploads = {}

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
		chat = {
			channelAlerts = {
				CHANNEL = true
			}
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
		units[unit] = { customTexts = true }
	end

	for i = 1, 10 do
		D.GeneratedKeys.profile.actionbar['bar'..i] = { paging = true }
	end
end

function D:Initialize()
	D.Initialized = true

	D:UpdateSettings()

	D.StatusBar = CreateFrame('StatusBar', 'ElvUI_Distributor_StatusBar', E.UIParent)
	D.StatusBar:CreateBackdrop()
	D.StatusBar:SetStatusBarTexture(E.media.normTex)
	D.StatusBar:SetStatusBarColor(0.95, 0.15, 0.15)
	D.StatusBar:Size(250, 18)
	D.StatusBar:Hide()

	D.StatusBar.text = D.StatusBar:CreateFontString(nil, 'OVERLAY')
	D.StatusBar.text:FontTemplate()
	D.StatusBar.text:Point('CENTER')

	E:RegisterStatusBar(D.StatusBar)
end

function D:UpdateSettings()
	if E.global.general.allowDistributor then
		D:RegisterComm(REQUEST_PREFIX)
		D:RegisterEvent('CHAT_MSG_ADDON')
	else
		D:UnregisterComm(REQUEST_PREFIX)
		D:UnregisterEvent('CHAT_MSG_ADDON')
	end
end

-- Used to start uploads
function D:Distribute(target, otherServer, dataKey)
	local profileKey, data
	if dataKey == 'global' then
		profileKey = dataKey
		data = ElvDB.global
	elseif dataKey == 'private' then
		profileKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		data = ElvPrivateDB.profiles[profileKey]
	else
		profileKey = ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm]
		data = ElvDB.profiles[profileKey]
	end

	if not data then return end
	if dataKey == 'global' then
		data = E:RemoveTableDuplicates(data, G, D.GeneratedKeys.global)
		data = E:FilterTableFromBlacklist(data, D.blacklistedKeys.global)
	elseif dataKey == 'private' then
		data = E:RemoveTableDuplicates(data, V, D.GeneratedKeys.private)
		data = E:FilterTableFromBlacklist(data, D.blacklistedKeys.private)
	else
		data = E:RemoveTableDuplicates(data, P, D.GeneratedKeys.profile)
		data = E:FilterTableFromBlacklist(data, D.blacklistedKeys.profile)
	end

	local serialString = D:Serialize(data)
	local length = strlen(serialString)
	local message = format('%s:%d:%s:%s', profileKey, length, target, dataKey or 'profile')

	Uploads[profileKey] = { serialString = serialString, target = target }

	if otherServer then
		if IsInRaid() and UnitInRaid('target') then
			D:SendCommMessage(REQUEST_PREFIX, message, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID')
		elseif IsInGroup() and UnitInParty('target') then
			D:SendCommMessage(REQUEST_PREFIX, message, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'PARTY')
		else
			E:Print(L["Must be in group with the player if he isn't on the same server as you."])
			return
		end
	else
		D:SendCommMessage(REQUEST_PREFIX, message, 'WHISPER', target)
	end

	D:RegisterComm(REPLY_PREFIX)
	E:StaticPopup_Show('DISTRIBUTOR_WAITING')
end

function D:CHAT_MSG_ADDON(_, prefix, message, _, senderOne, senderTwo)
	local download = prefix == TRANSFER_PREFIX and Downloads[strfind(senderOne, '-') and senderOne or senderTwo]
	if not download then return end

	local cur, max = strlen(message), download.length
	local current = download.current + cur
	if current > max then current = max end
	download.current = current

	D.StatusBar:SetValue(current)
end

function D:OnCommReceived(prefix, msg, dist, sender)
	if prefix == REQUEST_PREFIX then
		local profile, length, sendTo, dataKey = split(':', msg)
		if dist ~= 'WHISPER' and sendTo ~= E.myname then return end

		if D.StatusBar:IsShown() then
			D:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)

			return
		end

		local textString
		if dataKey == 'global' then
			textString = format(L["%s is attempting to share the Global Profile with you. Would you like to accept the request?"], sender)
		elseif dataKey == 'private' then
			textString = format(L["%s is attempting to share the Private Profile (%s) with you. Would you like to accept the request?"], sender, profile)
		elseif dataKey == 'profile' then
			textString = format(L["%s is attempting to share the Profile (%s) with you. Would you like to accept the request?"], sender, profile)
		end

		if not textString then return end

		local response = E.PopupDialogs.DISTRIBUTOR_RESPONSE
		response.text = textString
		response.OnAccept = function()
			D.StatusBar:SetMinMaxValues(0, length)
			D.StatusBar:SetValue(0)
			D.StatusBar.text:SetFormattedText(L["Data From: %s"], sender)
			E:StaticPopupSpecial_Show(D.StatusBar)
			D:SendCommMessage(REPLY_PREFIX, profile..':YES', dist, sender)
		end
		response.OnCancel = function()
			D:SendCommMessage(REPLY_PREFIX, profile..':NO', dist, sender)
		end

		E:StaticPopup_Show('DISTRIBUTOR_RESPONSE')

		Downloads[sender] = {
			current = 0,
			length = tonumber(length),
			profile = profile,
			dataKey = dataKey
		}

		D:RegisterComm(TRANSFER_PREFIX)
	elseif prefix == REPLY_PREFIX then
		D:UnregisterComm(REPLY_PREFIX)
		E:StaticPopup_Hide('DISTRIBUTOR_WAITING')

		local profileKey, response = split(':', msg)
		local upload = Uploads[profileKey]
		if upload and response == 'YES' then
			D:RegisterComm(TRANSFER_COMPLETE_PREFIX)
			D:SendCommMessage(TRANSFER_PREFIX, upload.serialString, dist, upload.target)
		else
			E:StaticPopup_Show('DISTRIBUTOR_REQUEST_DENIED')
		end

		Uploads[profileKey] = nil
	elseif prefix == TRANSFER_PREFIX then
		D:UnregisterComm(TRANSFER_PREFIX)
		E:StaticPopupSpecial_Hide(D.StatusBar)

		local download, success, data = Downloads[sender]
		local profileKey = download and download.profile
		if profileKey then -- verify sender first before trying to handle the msg
			success, data = D:Deserialize(msg)
		end

		if success then
			local textString = format(L["Profile download complete from %s, would you like to load the profile %s now?"], sender, profileKey)

			local confirm = E.PopupDialogs.DISTRIBUTOR_CONFIRM
			local import = E.PopupDialogs.IMPORT_RL
			import.OnAccept = ReloadUI -- private will select the profile first

			if download.dataKey == 'global' then
				textString = format(L["Download complete from %s, would you like to apply changes now?"], sender)
			else
				if download.dataKey == 'private' and not ElvPrivateDB.profiles[profileKey] then
					ElvPrivateDB.profiles[profileKey] = data
				elseif download.dataKey == 'profile' and not ElvDB.profiles[profileKey] then
					ElvDB.profiles[profileKey] = data
				else
					textString = format(L["Profile download complete from %s, but the profile %s already exists. Change the name or else it will overwrite the existing profile."], sender, profileKey)

					confirm.text = textString
					confirm.button1 = ACCEPT
					confirm.button2 = nil
					confirm.hasEditBox = 1
					confirm.editBoxWidth = 350
					confirm.maxLetters = 127
					confirm.timeout = 0
					confirm.exclusive = 1
					confirm.preferredIndex = 3

					confirm.OnAccept = function()
						if download.dataKey == 'private' then
							ElvPrivateDB.profiles[profileKey] = data

							import.OnAccept = function()
								E.charSettings:SetProfile(profileKey)
								ReloadUI()
							end

							E:StaticPopup_Show('IMPORT_RL')
						elseif download.dataKey == 'profile' then
							ElvDB.profiles[profileKey] = data

							E.data:SetProfile(profileKey)
							E:StaggeredUpdateAll()
						end

						Downloads[sender] = nil
					end
					confirm.OnShow = function(frame)
						frame.editBox:SetText(profileKey)
						frame.editBox:SetFocus()
					end
					confirm.OnCancel = nil

					E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
					D:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)

					return
				end
			end

			confirm.text = textString
			confirm.button1 = YES
			confirm.button2 = NO
			confirm.hasEditBox = nil
			confirm.editBoxWidth = nil
			confirm.maxLetters = nil
			confirm.timeout = nil
			confirm.exclusive = nil
			confirm.preferredIndex = nil

			confirm.OnAccept = function()
				if download.dataKey == 'global' then
					E:CopyTable(ElvDB.global, data)
					E:StaggeredUpdateAll()
				elseif download.dataKey == 'private' then
					import.OnAccept = function()
						E.charSettings:SetProfile(profileKey)
						ReloadUI()
					end

					E:StaticPopup_Show('IMPORT_RL')
				elseif download.dataKey == 'profile' then
					E.data:SetProfile(profileKey)
				end

				Downloads[sender] = nil
			end
			confirm.OnShow = nil
			confirm.OnCancel = function()
				Downloads[sender] = nil
			end

			E:StaticPopup_Show('DISTRIBUTOR_CONFIRM')
			D:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'COMPLETE', dist, sender)
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
			D:SendCommMessage(TRANSFER_COMPLETE_PREFIX, 'FAILED', dist, sender)
		end
	elseif prefix == TRANSFER_COMPLETE_PREFIX then
		D:UnregisterComm(TRANSFER_COMPLETE_PREFIX)

		if msg == 'COMPLETE' then
			E:StaticPopup_Show('DISTRIBUTOR_SUCCESS')
		else
			E:StaticPopup_Show('DISTRIBUTOR_FAILED')
		end
	end
end

function D:GetProfileData(dataType, dataKey)
	if not dataType or type(dataType) ~= 'string' then return end

	local profileData, profileKey = {}
	if dataType == 'profile' then
		--Copy current profile data
		profileKey = dataKey or (ElvDB.profileKeys and ElvDB.profileKeys[E.mynameRealm])

		local data = ElvDB.profiles[profileKey]
		if not data then return end -- bad dataKey

		profileData = E:CopyTable(profileData, data)

		--This table will also hold all default values, not just the changed settings.
		--This makes the table huge, and will cause the WoW client to lock up for several seconds.
		--We compare against the default table and remove all duplicates from our table. The table is now much smaller.
		profileData = E:RemoveTableDuplicates(profileData, P, D.GeneratedKeys.profile)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.profile)
	elseif dataType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		profileData = E:CopyTable(profileData, ElvPrivateDB.profiles[privateKey])
		profileData = E:RemoveTableDuplicates(profileData, V, D.GeneratedKeys.private)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.private)
		profileKey = 'private'
	elseif dataType == 'global' then
		profileData = E:CopyTable(profileData, ElvDB.global)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
		profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.global)
		profileKey = 'global'
	elseif dataType == 'filters' then
		profileData.unitframe = {}
		profileData.unitframe.aurafilters = E:CopyTable({}, ElvDB.global.unitframe.aurafilters)
		profileData.unitframe.aurawatch = E:CopyTable({}, ElvDB.global.unitframe.aurawatch)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
		profileKey = 'filters'
	elseif dataType == 'styleFilters' then
		profileKey = 'styleFilters'
		profileData.nameplates = {}
		profileData.nameplates.filters = E:CopyTable({}, ElvDB.global.nameplates.filters)
		NP:StyleFilterClearDefaults(profileData.nameplates.filters)
		profileData = E:RemoveTableDuplicates(profileData, G, D.GeneratedKeys.global)
	end

	return profileKey, profileData
end

function D:GetProfileExport(dataType, dataKey, dataFormat)
	local profileKey, profileData = D:GetProfileData(dataType, dataKey)
	if not profileKey or not profileData or (profileData and type(profileData) ~= 'table') then return end

	local profileExport
	if dataFormat == 'text' then
		local serialString = D:Serialize(profileData)
		local exportString = D:CreateProfileExport(dataType, profileKey, serialString)
		local compressedData = LibDeflate:CompressDeflate(exportString, LibDeflate.compressLevel)
		local printableString = LibDeflate:EncodeForPrint(compressedData)
		profileExport = printableString and format('%s%s', EXPORT_PREFIX, printableString) or nil
	elseif dataFormat == 'luaTable' then
		local exportString = E:TableToLuaString(profileData)
		profileExport = D:CreateProfileExport(dataType, profileKey, exportString)
	elseif dataFormat == 'luaPlugin' then
		profileExport = E:ProfileTableToPluginFormat(profileData, dataType)
	end

	return profileKey, profileExport
end

function D:CreateProfileExport(dataType, dataKey, dataString)
	return (dataType == 'profile' and format('%s::%s::%s', dataString, dataType, dataKey)) or (dataType and format('%s::%s', dataString, dataType))
end

function D:GetImportStringType(dataString)
	return (strmatch(dataString, '^'..EXPORT_PREFIX) and 'Deflate') or (strmatch(dataString, '^{') and 'Table') or ''
end

function D:Decode(dataString)
	local stringType = D:GetImportStringType(dataString)
	local profileInfo, profileType, profileKey, profileData

	if stringType == 'Deflate' then
		local data = gsub(dataString, '^'..EXPORT_PREFIX, '')
		local decodedData = LibDeflate:DecodeForPrint(data)
		local decompressed = LibDeflate:DecompressDeflate(decodedData)

		if not decompressed then
			E:Print('Error decompressing data.')
			return
		end

		local serializedData, success
		serializedData, profileInfo = E:SplitString(decompressed, '^^::') -- '^^' indicates the end of the AceSerializer string

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

function D:SetImportedProfile(dataType, dataKey, dataProfile, force)
	if dataType == 'profile' then
		local profileData = E:FilterTableFromBlacklist(dataProfile, D.blacklistedKeys.profile) --Remove unwanted options from import
		if not ElvDB.profiles[dataKey] or force then
			if force and E.data.keys.profile == dataKey then
				--Overwriting an active profile doesn't update when calling SetProfile
				--So make it look like we use a different profile
				E.data.keys.profile = dataKey..'_Temp'
			end

			ElvDB.profiles[dataKey] = profileData

			--Calling SetProfile will now update all settings correctly
			E.data:SetProfile(dataKey)
		else
			E:StaticPopup_Show('IMPORT_PROFILE_EXISTS', nil, nil, { profileKey = dataKey, profileType = dataType, profileData = profileData })
		end
	elseif dataType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]
		if privateKey then
			local profileData = E:FilterTableFromBlacklist(dataProfile, D.blacklistedKeys.private) --Remove unwanted options from import
			ElvPrivateDB.profiles[privateKey] = profileData
			E:StaticPopup_Show('IMPORT_RL')
		end
	elseif dataType == 'global' then
		local profileData = E:FilterTableFromBlacklist(dataProfile, D.blacklistedKeys.global) --Remove unwanted options from import
		E:CopyTable(ElvDB.global, profileData)
		E:StaggeredUpdateAll()
	elseif dataType == 'filters' then
		E:CopyTable(ElvDB.global.unitframe, dataProfile.unitframe)
		E:UpdateUnitFrames()
	elseif dataType == 'styleFilters' then
		E:CopyTable(ElvDB.global.nameplates, dataProfile.nameplates or dataProfile.nameplate)
		E:UpdateNamePlates()
	end
end

function D:ExportProfile(dataType, dataKey, dataFormat) -- dataKey can be nil
	if not dataType or not dataFormat then
		E:Print('Bad argument to "ExportProfile" (string expected)')
		return
	end

	return D:GetProfileExport(dataType, dataKey, dataFormat)
end

function D:ImportProfile(dataString)
	local profileType, profileKey, profileData = D:Decode(dataString)
	if not profileData or type(profileData) ~= 'table' then
		E:Print('Error: something went wrong when converting string to table!')
		return
	end

	if profileType and ((profileType == 'profile' and profileKey) or profileType ~= 'profile') then
		D:SetImportedProfile(profileType, profileKey, profileData)
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

E.PopupDialogs.DISTRIBUTOR_RESPONSE = {
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 30,
	whileDead = 1,
	hideOnEscape = 1
}

E.PopupDialogs.DISTRIBUTOR_CONFIRM = {
	whileDead = 1,
	hideOnEscape = 1
}

E.PopupDialogs.IMPORT_PROFILE_EXISTS = {
	text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(frame, data)
		D:SetImportedProfile(data.profileType, frame.editBox:GetText(), data.profileData, true)
	end,
	EditBoxOnTextChanged = function(frame)
		frame:GetParent().button1:SetEnabled(frame:GetText() ~= '')
	end,
	OnShow = function(frame, data)
		frame.editBox:SetText(data.profileKey)
		frame.editBox:SetFocus()
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
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

E:RegisterModule(D:GetName())
