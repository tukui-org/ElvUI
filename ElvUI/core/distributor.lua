local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:NewModule('Distributor', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")
local libC = LibStub:GetLibrary("LibCompress")

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
	local profileKey, data
	if profileType == "profile" then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = ElvDB.profiles[profileKey]

	elseif profileType == "private" then
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[E.myname..' - '..E.myrealm]
		end

		data = ElvPrivateDB.profiles[profileKey]

	elseif profileType == "global" then
		profileKey = 'global'
		data = ElvDB.global
	end
	
	return profileKey, data
end

-- Lua APIs
local tinsert, tconcat, tremove = table.insert, table.concat, table.remove
local fmt, tostring, string_char, strsplit = string.format, tostring, string.char, strsplit
local select, pairs, next, type, unpack = select, pairs, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local setmetatable, getmetatable, rawset, rawget = setmetatable, getmetatable, rawset, rawget
local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local coroutine = coroutine

-- local functions
local encodeB64, decodeB64, tableAdd, tableSubtract, DisplayStub, removeSpellNames
local CompressDisplay, DecompressDisplay, ShowTooltip, TableToString, StringToTable
local RequestDisplay, TransmitError, TransmitDisplay

local bytetoB64 = {
    [0]="a","b","c","d","e","f","g","h",
    "i","j","k","l","m","n","o","p",
    "q","r","s","t","u","v","w","x",
    "y","z","A","B","C","D","E","F",
    "G","H","I","J","K","L","M","N",
    "O","P","Q","R","S","T","U","V",
    "W","X","Y","Z","0","1","2","3",
    "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
      a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
      i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
      q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
      y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
      G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
      O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
      W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
    ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

--This code is taken from WeakAuras2, credit goes to Mirrored and the WeakAuras Team
--This code is based on the Encode7Bit algorithm from LibCompress
--Credit goes to Galmok of European Stormrage (Horde), galmok@gmail.com
local encodeB64Table = {};
function encodeB64(str)
    local B64 = encodeB64Table;
    local remainder = 0;
    local remainder_length = 0;
    local encoded_size = 0;
    local l=#str
    local code
    for i=1,l do
        code = string.byte(str, i);
        remainder = remainder + bit_lshift(code, remainder_length);
        remainder_length = remainder_length + 8;
        while(remainder_length) >= 6 do
            encoded_size = encoded_size + 1;
            B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
            remainder = bit_rshift(remainder, 6);
            remainder_length = remainder_length - 6;
        end
    end
    if remainder_length > 0 then
        encoded_size = encoded_size + 1;
        B64[encoded_size] = bytetoB64[remainder];
    end
    return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

function decodeB64(str)
    local bit8 = decodeB64Table;
    local decoded_size = 0;
    local ch;
    local i = 1;
    local bitfield_len = 0;
    local bitfield = 0;
    local l = #str;
    while true do
        if bitfield_len >= 8 then
            decoded_size = decoded_size + 1;
            bit8[decoded_size] = string_char(bit_band(bitfield, 255));
            bitfield = bit_rshift(bitfield, 8);
            bitfield_len = bitfield_len - 8;
        end
        ch = B64tobyte[str:sub(i, i)];
        bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
        bitfield_len = bitfield_len + 6;
        if i > l then
            break;
        end
        i = i + 1;
    end
    return table.concat(bit8, "", 1, decoded_size)
end

function D:ProfileToString(profileType)
	local profileKey, data = GetProfileData(profileType)
	
	if not profileKey or not data then
		return "Error exporting profile"
	end

	local serialData = self:Serialize(data)
	local exportString = format("%s:%s:%s", profileType, profileKey, serialData)
	local compressedData = libC:CompressHuffman(exportString)
	local encodedData = encodeB64(compressedData)

	return profileType, profileKey, encodedData
end

function D:Decode(str)
	local decodedData = decodeB64(str)
	local decompressedData, message = libC:DecompressHuffman(decodedData)
	
	if not decompressedData then
		print("Error decompressing data: ", message)
		return 
	end
	
	local profileType, profileKey, serialData = split(":", decompressedData)
	local success, profileData = self:Deserialize(serialData)
	if not success then
		print("Error deserializing "..profileData)
	end
	
	return profileType, profileKey, decompressedData
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
	self.exportImport:Show()
	self.exportImport.importButton.frame:Hide()

	local Box = self.exportImport.Box
	local profileType, profileKey, displayString = self:ProfileToString("profile")
	-- local profileType, profileKey, displayString = self:ProfileToTableString("profile")

	Box.editBox:SetScript("OnEscapePressed", function() self:Export_Close(); end);
	Box.editBox:SetScript("OnChar", function() Box:SetText(displayString); Box.editBox:HighlightText(); end);
	Box.editBox:SetScript("OnMouseUp", function() Box.editBox:HighlightText(); end);
	Box.editBox:SetScript("OnTextChanged", nil);
	Box:SetLabel("Profile type: "..profileType.." - Profile name: "..profileKey);
	Box.button:Hide();
	Box:SetText(displayString);
	Box.editBox:HighlightText();
	Box:SetFocus();
end

function D:Export_Close()
	self.exportImport.Box:ClearFocus();
	self.exportImport:Hide();
end

function D:Import_Open()
	self.exportImport:Show()
	self.exportImport.importButton.frame:Show()

	local Box = self.exportImport.Box
	Box.editBox:SetScript("OnEscapePressed", nil);
	Box.editBox:SetScript("OnChar", nil);
	Box.editBox:SetScript("OnMouseUp", nil);
	Box.editBox:SetScript("OnTextChanged", nil);
	Box.button:Hide();
	Box:SetText("");
end

function D:ProfileToTableString(data)
	local ret
    local function recurse(table, level)
        for i,v in pairs(table) do
            ret = ret..strrep("    ", level).."[";
            if(type(i) == "string") then
                ret = ret.."\""..i.."\"";
            else
                ret = ret..i;
            end
            ret = ret.."] = ";

            if(type(v) == "number") then
                ret = ret..v..",\n"
            elseif(type(v) == "string") then
                ret = ret.."\""..v:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"").."\",\n"
            elseif(type(v) == "boolean") then
                if(v) then
                    ret = ret.."true,\n"
                else
                    ret = ret.."false,\n"
                end
            elseif(type(v) == "table") then
                ret = ret.."{\n"
                recurse(v, level + 1);
                ret = ret..strrep("    ", level).."},\n"
            else
                ret = ret.."\""..tostring(v).."\",\n"
            end
        end
    end

	-- local profileKey = "TestProfile"
	local profileData = data
    if type(data) == "string" then
		_, data = GetProfileData("profile")
	end
	-- ret = "[\""..profileKey.."\"] = {\n";
	ret = "{\n";
    if(profileData) then
        recurse(data, 1);
    end
    ret = ret.."}";
    -- return profileType, profileKey, ret;
	return ret;
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