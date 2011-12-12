-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local E, L, DF			= unpack(ElvUI)
local _G				= getfenv(0)
local AceConfig			= LibStub("AceConfig-3.0")
local AceConfigDialog	= LibStub("AceConfigDialog-3.0")
local L					= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks", false)
if IsAddOnLoaded("Prat") or IsAddOnLoaded("Chatter") or not DF["chat"].enable then return end

-- load globals
ElvUI_ChatTweaks				= LibStub("AceAddon-3.0"):NewAddon("ElvUI_ChatTweaks", "AceConsole-3.0", "AceHook-3.0")
ElvUI_ChatTweaks.version		= GetAddOnMetadata("ElvUI_ChatTweaks", "Version")
ElvUI_ChatTweaks.addon			= "|cff1784d1ElvUI Chat Tweaks|r version |cff00ff00" .. ElvUI_ChatTweaks.version .. "|r"

local concat	= table.concat
local insert	= table.insert
local sort		= table.sort

-- for all modules
local prototype = {
	Decorate		= function(self, chatframe) end,
	Popout			= function(self, chatframe, srcchatframe) end,
	TempChatFrames	= {},
	AddTempChat		= function(self, name) insert(self.TempChatFrames, name) end,
	AlwaysDecorate	= function(self, chatframe) end,
}

ElvUI_ChatTweaks:SetDefaultModulePrototype(prototype)
ElvUI_ChatTweaks:SetDefaultModuleState(false)

local function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do insert(a, n) end
	sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then 
			return nil
		else 
			return a[i], t[a[i]]
		end
	end
	return iter
end

--[[ Ace3 Framework Events ]]--
function ElvUI_ChatTweaks:OnInitialize()
	self.db	= LibStub("AceDB-3.0"):New("ElvUI_ChatTweaksDB", self.defaults)
	-- add the modules' options tables
	for k, v in self:IterateModules() do
		self.options.args.general.args[k:gsub(" ", "_")] = {
			type		= "group",
			name		= v.name or k,
			--guiInline	= true,
			args		= nil
		}
		local t
		if v.GetOptions then
			t = v:GetOptions()
			t.settingsHeader = {
				type	= "header",
				name	= L["Settings"],
				order	= 12
			}
		end
		t = t or {}
		t.toggle = {
			type	= "toggle",
			name	= v.toggleLabel or (L["Enable "] .. (v.name or k)),
			width	= "double",
			desc	= v:Info() and v:Info() or (L["Enable "] .. (v.name or k)),
			order	= 11,
			get		= function() return ElvUI_ChatTweaks.db.profile.modules[k] ~= false or false end,
			set		= function(_, value)
				ElvUI_ChatTweaks.db.profile.modules[k] = value
				if value then
					ElvUI_ChatTweaks:EnableModule(k)
					ElvUI_ChatTweaks:Print(L["Enabled"], format("|cff00ff00%s|r", k), L["Module"])
				else
					ElvUI_ChatTweaks:DisableModule(k)
					ElvUI_ChatTweaks:Print(L["Disabled"], format("|cffff0000%s|r", k), L["Module"])
				end
			end
		}
		t.header = {
			type	= "header",
			name	= v.name or k,
			order	= 9
		}
		if v.Info then
			t.description = {
				type	= "description",
				name	= v:Info() .. "\n\n",
				order	= 10
			}
		end
		self.options.args.general.args[k:gsub(" ", "_")].args = t
	end
	
	self.db.RegisterCallback(self, "OnProfileChanged", "SetUpdateConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "SetUpdateConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "SetUpdateConfig")
end

function ElvUI_ChatTweaks:OnEnable()
	for k, v in self:IterateModules() do
		if self.db.profile.modules[k] ~= false then v:Enable() end
	end
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ElvUI_ChatTweaks", self.options)
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.frames = {}
	self.frames.general		= AceConfigDialog:AddToBlizOptions("ElvUI_ChatTweaks", "ElvUI_ChatTweaks", nil, "general")
	self.frames.profiles	= AceConfigDialog:AddToBlizOptions("ElvUI_ChatTweaks", L["Profiles"], "ElvUI_ChatTweaks", "profiles")
	self.frames.about		= LibStub("LibAboutPanel").new("ElvUI_ChatTweaks", "ElvUI_ChatTweaks")
	
	self:AddMenuHook(self, {
		text	= L["ElvUI ChatTweaks"],
		func	= ElvUI_ChatTweaks.OpenConfig,
		notCheckable = 1
	})
	self:RawHook("FCF_Tab_OnClick", true)
	
	-- chat command
	self:RegisterChatCommand("ct", function(args)
		local cmd = self:GetArgs(args)
		if cmd == "config" then
			self:OpenConfig()
		elseif cmd == "modules" then
			local modStatus, enabled, disabled = {}, 0, 0
			for name, module in self:IterateModules() do
				modStatus[name] = module:IsEnabled() and true or false
				if module:IsEnabled() then enabled = enabled + 1
				else disabled = disabled + 1 end
			end
			
			if not modStatus then
				self:Print(L["|cffff0000No modules found.|r"])
			else
				local moduleName		= "    +|cff00ffff%s|r - %s"
				local enabledModule 	= L["|cff00ff00Enabled|r"]
				local disabledModule	= L["|cffff0000Disabled|r"]
				self:Print(format(L[" |cffffff00%d|r Total Modules (|cff00ff00%d|r Enabled, |cffff0000%d|r Disabled)"], (enabled + disabled), enabled, disabled))
				for name, status in pairsByKeys(modStatus) do
					print(format(moduleName, name, status == true and enabledModule or disabledModule))
				end
			end
		elseif not cmd or cmd == "help" then
			local argStr = L["   |cff00ff00/ct %s|r - %s"]
			local clrStr = L["   |cff00ff00%s|r or |cff00ff00%s|r - %s"]
			local cmdStr = L["   |cff00ff00%s|r - %s"]
			self:Print(L["Available Chat Command Arguments"])
			print(format(argStr, "config", L["Opens configuration window."]))
			print(format(argStr, "modules", L["Prints module status."]))
			print(format(argStr, "help", L["Print this again."]))
			-- determine if clear chat command module is enabled
			
			for name, module in self:IterateModules() do
				if module:IsEnabled() and name == "Clear Chat Commands" then
					print(format(clrStr, "/clr", "/clear", L["Clear current chat."]))
					print(format(clrStr, "/clrall", "/clearall", L["Clear all chat windows."]))
				elseif module:IsEnabled() and name == "GKick Command" then
					print(format(cmdStr, "/gkick", L["Alternate command to kick someone from guild."]))
				elseif module:IsEnabled() and name == "Group Say Command" then
					print(format(cmdStr, "/gs", L["Talk to your group based on party/raid status."]))
				end
			end
		end
	end)
end

do
	local info, menuHooks = {}, {}
	function ElvUI_ChatTweaks:AddMenuHook(module, hook)
		menuHooks[module] = hook
	end
	
	function ElvUI_ChatTweaks:RemoveMenuHook(module)
		menuHooks[module] = nil
	end
	
	function ElvUI_ChatTweaks:FCF_Tab_OnClick(...)
		self.hooks.FCF_Tab_OnClick(...)
		for module, v in pairs(menuHooks) do
			local menu
			if type(v) == "table" then
				menu = v
			else
				menu = module[v](module, ...)
			end
			UIDropDownMenu_AddButton(menu)
		end
	end
end

function ElvUI_ChatTweaks:FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	local frame = self.hooks.FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, selectWindow)
	if frame then
		for k, v in self:IterateModules() do
			if not frame.isDecorated then
				v:AddTempChat(frame:GetName())
			end
			if v:IsEnabled() and not frame.isDecorated then
				v:Decorate(frame)
			end
			if v:IsEnabled() then
				v:Popout(frame, sourceChatFrame or DEFAULT_CHAT_FRAME)
			end
			v:AlwaysDecorate(frame)
		end
	end
	FCFDock_ForceReanchoring(GENERAL_CHAT_DOCK)
	return frame
end

function ElvUI_ChatTweaks:OpenConfig()
	ElvUI_ChatTweaks:Print("Showing Configuration Options")
	InterfaceOptionsFrame_OpenToCategory(ElvUI_ChatTweaks.frames.general)	
end


function ElvUI_ChatTweaks:SetUpdateConfig(event, database, newProfileKey)
	self.db = database.profile
	self:UpdateConfig()
end

function ElvUI_ChatTweaks:UpdateConfig()
	for k, v in self:IterateModules() do
		if v:IsEnabled() then
			v:Disable()
			v:Enable()
		end
	end
end

--[[ Ace3 Options ]]--
ElvUI_ChatTweaks.options = {
	type = "group",
	args = {
		general = {
			type	= "group",
			name	= L["ElvUI ChatTweaks"],
			childGroups = "tree",
			args	= {
				description = {
					type	= "description",
					width	= "full",
					name	= ElvUI_ChatTweaks.addon .. L[" is designed to add a lot of the functionality of full fledged chat addons like Prat or Chatter, but without a lot of the unneeded bloat.  I wrote it to be as lightweight as possible, while still powerful enough to accomplish it's intended function.\n"],
					order	= 1,
				},
			}
		}
	}
}

ElvUI_ChatTweaks.defaults = {
	profile	= {
		modules = {
			["Auto Profession Link"]		= false,
			["Channel Colors"]				= false,
			["Channel Names"]				= true,
			["Channel Sounds"]				= false,
			["Clear Chat Commands"]			= false,
			["Custom Emotes"]				= false,
			["Custom Chat Filters"]			= true,
			["Damage Meters"]				= true,
			["GInvite Alternate Command"]	= false,
			["GKick Command"]				= false,
			["Group Say Command"]			= false,
			["Invite Links"]				= false,
			["Raid Helper"]					= true,
			["Spam Filter"]					= true,
			["Spam Throttle"]				= true,
			["Timestamps"]					= true,
			["Whisper Filter"]				= true,
		}
	}
}