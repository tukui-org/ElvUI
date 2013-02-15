local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local D = E:NewModule('Distributor', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")

local ipairs, pairs = ipairs, pairs
local remove,wipe = table.remove,table.wipe
local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find

----------------------------------
-- CONSTANTS
----------------------------------

local MAIN_PREFIX = "ELVUI_D"
local TRANSFER_PREFIX = "ELVUI_T"
local UL_WAIT = 5

----------------------------------
-- INITIALIZATION
----------------------------------

function D:Initialize()
	self:RegisterComm(MAIN_PREFIX)
end

----------------------------------
-- INITIAL DISTRIBUTE
----------------------------------
-- The active downloads
local Downloads = {}

-- The active uploads
local Uploads = {}

-- Used to start uploads
function D:Distribute(target, isGlobal)
	if E.isSharing then
		E:Print(L["Already Sharing!"])
		return
	end
	
	wipe(Uploads)
	
	local profileKey
	if isGlobal ~= "true" then
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
		end
		
		data = ElvDB.profiles[profileKey]
		isGlobal = "false"
	else
		profileKey = 'global'
		data = ElvDB.global
	end

	if not data or not profileKey then return end
	local serialData = self:Serialize(data)
	local length = len(serialData)
	local message = format("UPDATE:%s:%d:%s", profileKey, length, E.myname..' - '..E.myrealm) -- ex. UPDATE:sartharion:150:800:Sartharion
	
	E.isSharing = true
	Uploads[profileKey] = {
		serialData = serialData,
		length = length,
		target = target,
		isGlobal = isGlobal,
		name = E.myname..' - '..E.myrealm,
	}
	
	self:SendCommMessage(MAIN_PREFIX, message, "WHISPER", target)
	self:RegisterComm(TRANSFER_PREFIX)
	self:ScheduleTimer("StartUpload",UL_WAIT,profileKey)
	SendChatMessage(L["Sending you my ElvUI settings! Please allow up to one minute for download to complete."], "WHISPER", nil, target)
end

----------------------------------
-- MAIN
----------------------------------
function D:Main(msg, dist, sender)
	local type,args = match(msg,"(%w+):(.+)")

	-- Someone wants to send an encounter
	if type == "UPDATE" then
		local key,length,name = split(":",args)
		self:StartReceiving(key, sender, length, name)
	end
end

----------------------------------
-- UPLOAD/DOWNLOAD HANDLERS
----------------------------------
function D:StartUpload(key)
	local ul = Uploads[key]
	local message = format("%s~~%s~~%s~~%s","UPLOAD",key,ul.isGlobal,ul.serialData)

	if ul.target then
		self:SendCommMessage(TRANSFER_PREFIX, message, "WHISPER",ul.target)
	end
	
	self:ULCompleted(key)
end

function D:StartReceiving(key,sender,length,name)
	Downloads[key] = {
		key = key,
		sender = sender,
		length = length,
		name = name,
	}

	self:RegisterComm(TRANSFER_PREFIX)
end

----------------------------------
-- TRANSFERS
----------------------------------
function D:Transfer(msg, dist, sender)
	local type,key,isGlobal,serialData = match(msg,"(%w+)~~(.+)~~(.+)~~(.+)")
	isGlobal = isGlobal == "true" and true or false
	
	-- Receiving an upload
	if type == "UPLOAD" then
		local length = len(serialData)

		local dl = Downloads[key]
		if not dl then return end

		local success, data = self:Deserialize(serialData)
		-- Failed to deserialize
		if not success then
			E:Print(format(L["Failed to load %s after downloading! Request another profile from %s"],dl.name,dl.sender))
			return
		end
		-- Do popup if autoaccept disabled
		local popupkey = format("ELVUI_Confirm_%s",key)
		if not E.PopupDialogs[popupkey] then
			local textString = format(L["%s is sharing the profile: [%s]"],sender,dl.name)
			if isGlobal then
				textString = format(L["%s is sharing their filter settings. Warning: Hitting accept will cause you to lose your filters."], sender)
			end
			
			local STATIC_CONFIRM = {
				text = textString,
				OnAccept = function()
					self:DLCompleted(key,dl.sender,dl.name,data,isGlobal)
				end,
				OnCancel = function()
					self:DLRejected(key)
				end,
				button1 = L["Accept"],
				button2 = L["Reject"],
				timeout = 15,
				whileDead = 1,
				hideOnEscape = 1,
			}
			E.PopupDialogs[popupkey] = STATIC_CONFIRM
		end
		E:StaticPopup_Show(popupkey)
	end
end

----------------------------------
-- COMPLETIONS
----------------------------------
function D:ULCompleted(key)
	if Uploads[key].isGlobal == "true" then
		E:Print(format(L["Upload Complete: [%s]"],L["Filters"]))
	else
		E:Print(format(L["Upload Complete: [%s]"],Uploads[key].name))
	end
	
	E.isSharing = false
end

function D:DLCompleted(key,sender,name,data,isGlobal)
	if not isGlobal then
		ElvDB.profiles[name] = data
		local profileName = Downloads[key].name
		local popupkey = format("ELVUI_ProfileChange_%s",key)
		local STATIC_CONFIRM = {
			text = format(L["%s download from %s complete. Would you like to switch to that profile?"],profileName,sender),
			OnAccept = function()
				LibStub("AceAddon-3.0"):GetAddon("ElvUI").data:SetProfile(profileName)
			end,
			OnCancel = function() end,
			button1 = ACCEPT,
			button2 = CANCEL,
			whileDead = 1,
			hideOnEscape = 1,
		}		
		E.PopupDialogs[popupkey] = STATIC_CONFIRM
		E:StaticPopup_Show(popupkey)
	else
		ElvDB.global = data	
		E:UpdateAll(true)
	end
	
	self:UnregisterComm(TRANSFER_PREFIX)
	wipe(Downloads[key])
end

function D:DLRejected(key)
	self:UnregisterComm(TRANSFER_PREFIX)
	wipe(Downloads[key])
end

----------------------------------
-- COMM RECEIVED
----------------------------------

function D:OnCommReceived(prefix, msg, dist, sender)
	if sender == E.myname then
		--return
	end

	if prefix == MAIN_PREFIX then
		self:Main(msg, dist, sender)
	elseif prefix == TRANSFER_PREFIX then
		self:Transfer(msg, dist, sender)
	end
end

E:RegisterModule(D:GetName())