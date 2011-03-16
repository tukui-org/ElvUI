local ElvuiConfig = LibStub("AceAddon-3.0"):NewAddon("ElvuiConfig", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ElvuiConfig", false)
local LSM = LibStub("LibSharedMedia-3.0")
local db
local defaults

LSM:Register("statusbar","Elvui Gloss", [[Interface\AddOns\ElvUI\media\textures\normTex.tga]])
LSM:Register("statusbar","Elvui Norm", [[Interface\AddOns\ElvUI\media\textures\normTex2.tga]])
LSM:Register("background","Elvui Blank", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "Elvui GlowBorder", [[Interface\AddOns\ElvUI\media\textures\glowTex.tga]])
LSM:Register("font","Elvui Font", [[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]])
LSM:Register("sound","Elvui Warning", [[Interface\AddOns\ElvUI\media\sounds\warning.mp3]])
LSM:Register("sound","Elvui Whisper", [[Interface\AddOns\ElvUI\media\sounds\whisper.mp3]])


function ElvuiConfig:LoadDefaults()
	local E, C, L = unpack(ElvUI)
	
	--Defaults
	defaults = {
		profile = {
			general = C["general"],
		},
	}
end	

function ElvuiConfig:OnInitialize()
	self:RegisterEvent("PLAYER_LOGIN")
	self.OnInitialize = nil
end

function ElvuiConfig:PLAYER_LOGIN()
	self:LoadDefaults()
	
	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("ElvConfig", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile

	LSM.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateUsedMedia")
	self:SetupOptions()
end

function ElvuiConfig:UpdateUsedMedia(event, mediatype, key)
	if mediatype == "statusbar" then
		--if key == db.Bar.Texture then self:UpdateBarTextureSettings() end
	elseif mediatype == "font" then
		--if key == db.TitleBar.Font then self:UpdateTitleBar() end
		--if key == db.Bar.Font then self:UpdateBarLabelSettings() self:UpdateBars() end
	elseif mediatype == "background" then
		--if key == db.Background.Texture then self:UpdateBackdrop() end
	elseif mediatype == "border" then
		--if key == db.Background.BorderTexture then self:UpdateBackdrop() end
	--elseif mediatype == "sound" then
		-- Do nothing
	end
end

function ElvuiConfig:OnProfileChanged(event, database, newProfileKey)
	print('profile changed')
end

function ElvuiConfig:SetupOptions()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ElvuiConfig", self.GenerateOptions)

	-- The ordering here matters, it determines the order in the Blizzard Interface Options
	local ACD3 = LibStub("AceConfigDialog-3.0")
	self.optionsFrames = {}
	self.optionsFrames.ElvuiConfig = ACD3:AddToBlizOptions("ElvuiConfig", "ElvUI", nil, "general")
	--self:RegisterModuleOptions("Profiles", function() return LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) end, L["Profiles"])


	self.SetupOptions = nil
end

function ElvuiConfig.GenerateOptions()
	if ElvuiConfig.noconfig then assert(false, ElvuiConfig.noconfig) end
	if not ElvuiConfig.Options then
		ElvuiConfig.GenerateOptionsInternal()
		ElvuiConfig.GenerateOptionsInternal = nil
		moduleOptions = nil
	end
	return ElvuiConfig.Options
end

function ElvuiConfig.GenerateOptionsInternal()
	local E, C, L = unpack(ElvUI)
	
	ElvuiConfig.Options = {
		type = "group",
		name = "ElvUI",
		args = {
			general = {
				order = 1,
				type = "group",
				name = L["General Settings"],
				desc = L["General Settings"],
				get = function(info) return db.general[ info[#info] ] end,
				set = function(info, value) db.general[ info[#info] ] = value end,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["ELVUI_DESC"],
					},
					autoscale = {
						order = 2,
						name = L["Auto Scale"],
						desc = L["Automatically scale the User Interface based on your screen resolution"],
						type = "toggle",
					},					
					uiscale = {
						order = 3,
						name = L["Scale"],
						desc = L["Controls the scaling of the entire User Interface"],
						disabled = function(info) return db.general.autoscale end,
						type = "range",
						min = 0.64, max = 1, step = 0.01,
						isPercent = true,
					},		
				},
			},
		},
	}
end
