-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Timestamps", "AceHook-3.0", "AceEvent-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Timestamps"]

local format = string.format

local tsFormat
local tsColor

local db
local options
local defaults = {
	profile = { 
		format = "%X",
		color = { r = 0.60, g = 0.63, b = 0.64 },
		frames = {
			["Frame1"] = true,
			["Frame3"] = true,
			["Frame4"] = true,
			["Frame5"] = true,
			["Frame6"] = true,
			["Frame7"] = true
		}
	}
}


function Module:AddMessage(frame, text, ...)
	local id = frame:GetID()
	if id and db.frames["Frame"..id] and not(CHAT_TIMESTAMP_FORMAT) then
		if not ElvUI_ChatTweaks.loading then
			if not text then 
				return self.hooks[frame].AddMessage(frame, text, ...)
			end
			if db.colorByChannel then
				text = date(tsFormat) .. " " .. text
			else
				text = "|cff" .. tsColor .. date(tsFormat) .. "|r " .. text
			end
		end
		return self.hooks[frame].AddMessage(frame, text, ...)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function Module:Decorate(frame)
	if not self:IsHooked(frame, "AddMesage") then
		self:RawHook(frame, "AddMessage", true)
	end
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("Timestamps", defaults)
	db = self.db.profile
end

function Module:OnEnable()
	tsFormat = db.customFormat or "[" .. db.format .. "]"
	tsColor = ("%02x%02x%02x"):format(db.color.r * 255, db.color.g * 255, db.color.b * 255)
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[format("ChatFrame%d", i)]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index, frame in ipairs(self.TempChatFrames) do
		local cf = _G[frame]
		self:RawHook(cf, "AddMessage", true)
	end
	
	-- disable blizzard's default timestamps
	if GetCVar("showTimestamps") ~= "none" then
		SetCVar("showTimestamps", "none")
	end
end

function Module:Info()
	return L["Adds a timestamp to each line of text."]
end

function Module:GetOptions()
	if not options then
		options = {
			format = {
				type = "select",
				name = L["Timestamp format"],
				desc = L["Timestamp format"],
				values = {
					["%I:%M:%S %p"]	= L["HH:MM:SS AM (12-hour)"],
					["%I:%M:S"]		= L["HH:MM (12-hour)"],
					["%X"]			= L["HH:MM:SS (24-hour)"],
					["%I:%M"]		= L["HH:MM (12-hour)"],
					["%H:%M"]		= L["HH:MM (24-hour)"],
					["%M:%S"]		= L["MM:SS"],
				},
				get = function() return db.format end,
				set = function(info, v)
					db.format = v
					tsFormat = ("[" .. v .. "]")
				end
			},
			customFormat = {
				type = "input",
				name = L["Custom format (advanced)"],
				desc = L["Enter a custom time format. See http://www.lua.org/pil/22.1.html for a list of valid formatting symbols."],
				get = function() return db.customFormat end,
				set = function(info, v)
					if #v == 0 then v = nil end
					db.customFormat = v
					tsFormat = v
				end,
				order = 101		
			},
			color = {
				type = "color",
				name = L["Timestamp color"],
				desc = L["Timestamp color"],
				get = function()
					local c = db.color
					return c.r, c.g, c.b
				end,
				set = function(info, r, g, b, a)
					local c = db.color
					c.r, c.g, c.b = r, g, b
					tsColor = ("%02x%02x%02x"):format(r * 255, g * 255, b * 255)
				end,
				disabled = function() return db.colorByChannel end
			},
			useChannelColor = {
				type = "toggle",
				name = L["Use channel color"],
				desc = L["Color timestamps the same as the channel they appear in."],
				get = function()
					return db.colorByChannel
				end,
				set = function(info, v)
					db.colorByChannel = v
				end
			},
			frames = {
				type = "multiselect",
				name = L["Chat Frame Settings"],
				desc = L["Choose which chat frames display timestamps"],
				values = {
					["Frame1"]	= L["Chat Frame "].."1",
					["Frame3"]	= L["Chat Frame "].."3",
					["Frame4"]	= L["Chat Frame "].."4",
					["Frame5"]	= L["Chat Frame "].."5",
					["Frame6"]	= L["Chat Frame "].."6",
					["Frame7"]	= L["Chat Frame "].."7",
					["Frame8"]	= L["Chat Frame "].."8",
					["Frame9"]	= L["Chat Frame "].."9",
					["Frame10"]	= L["Chat Frame "].."10",
					["Frame11"]	= L["Chat Frame "].."11",
					["Frame12"]	= L["Chat Frame "].."12",
					["Frame13"]	= L["Chat Frame "].."13",
					["Frame14"]	= L["Chat Frame "].."14",
					["Frame15"]	= L["Chat Frame "].."15",
					["Frame16"]	= L["Chat Frame "].."16",
					["Frame17"]	= L["Chat Frame "].."17",
					["Frame18"]	= L["Chat Frame "].."18",
				},
				get = function(info, k) return db.frames[k] end,
				set = function(info, k, v) db.frames[k] = v end,
			},
		}
	end
	return options
end