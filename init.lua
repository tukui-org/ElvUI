--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:
	
	local E, L, DF = unpack(select(2, ...)); --Engine
	
To load the AddOn engine inside another addon add this to the top of your file:
	
	local E, L, DF = unpack(AddOn); --Engine
]]
local AddOnName, Engine = ...;
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0");
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 650;
AddOn.DF = {}; AddOn.DF["profile"] = {}; -- Defaults
AddOn.Options = {
	type = "group",
	name = AddOnName,
	args = {},
};

local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false);

Engine[1] = AddOn;
Engine[2] = Locale;
Engine[3] = AddOn.DF["profile"];

_G[AddOnName] = Engine;

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

function AddOn:OnInitialize()
	self.data = LibStub("AceDB-3.0"):New("ElvData", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.data.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	self.db = self.data.profile;
	self:UIScale();
	self:UpdateMedia();
	self:GetModule('RaidUtility'):Initialize()
	self:RegisterEvent('PLAYER_LOGIN', 'Initialize')
end

function AddOn:OnProfileChanged()
	StaticPopup_Show("CONFIG_RL")
end

function AddOn:LoadConfig()	
	AC:RegisterOptionsTable(AddOnName, self.Options)
	ACD:SetDefaultSize(AddOnName, DEFAULT_WIDTH, DEFAULT_HEIGHT)	
	
	--Create Profiles Table
	self.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.data);
	AC:RegisterOptionsTable("ElvProfiles", self.Options.args.profiles)
	self.Options.args.profiles.order = -10		
end

function AddOn:ToggleConfig() 
	local mode = 'Close'
	if not ACD.OpenFrames[AddOnName] then
		mode = 'Open'
	end
	
	if mode == 'Open' then
		ElvConfigToggle.text:SetTextColor(unpack(AddOn.media.rgbvaluecolor))
	else
		ElvConfigToggle.text:SetTextColor(1, 1, 1)
	end
	
	ACD[mode](ACD, AddOnName) 
	
	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end