--[[
~AddOn Engine~

To load the AddOn engine add this to the top of your file:
	
	local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
	
To load the AddOn engine inside another addon add this to the top of your file:
	
	local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
]]

BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title");

local AddOnName, Engine = ...;
local AddOn = LibStub("AceAddon-3.0"):NewAddon(AddOnName, "AceConsole-3.0", "AceEvent-3.0", 'AceTimer-3.0', 'AceHook-3.0');
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
AddOn.DF = {}; AddOn.DF["profile"] = {}; AddOn.DF["global"] = {}; AddOn.privateVars = {}; AddOn.privateVars["profile"] = {}; -- Defaults
AddOn.Options = {
	type = "group",
	name = AddOnName,
	args = {},
};

local Locale = LibStub("AceLocale-3.0"):GetLocale(AddOnName, false);

Engine[1] = AddOn;
Engine[2] = Locale;
Engine[3] = AddOn.privateVars["profile"];
Engine[4] = AddOn.DF["profile"];
Engine[5] = AddOn.DF["global"];

_G[AddOnName] = Engine;

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LibDualSpec = LibStub('LibDualSpec-1.0')
local tcopy = table.copy

function AddOn:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {};
	end
	
	ElvCharacterData = nil; --Depreciated
	ElvPrivateData = nil; --Depreciated
	ElvData = nil; --Depreciated
	
	self.db = tcopy(self.DF.profile, true);
	self.global = tcopy(self.DF.global, true);
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end
		
		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname..' - '..self.myrealm]
		end
		
		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true);
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
		end
				
		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then		
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end	

	if self.private.general.pixelPerfect then
		self.Border = 1;
		self.Spacing = 0;
		self.PixelMode = true;
	end

	self:UIScale();
	self:UpdateMedia();
	
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_LOGIN', 'Initialize')
	self:Contruct_StaticPopups()	
	self:InitializeInitialModules()
end

function AddOn:PLAYER_REGEN_ENABLED()
	ACD:Open(AddOnName);
	self:UnregisterEvent('PLAYER_REGEN_ENABLED');
end

function AddOn:PLAYER_REGEN_DISABLED()
	local err = false;
	if ACD.OpenFrames[AddOnName] then
		self:RegisterEvent('PLAYER_REGEN_ENABLED');
		ACD:Close(AddOnName);
		err = true;
	end
	
	if self.CreatedMovers then
		for name, _ in pairs(self.CreatedMovers) do
			if _G[name] and _G[name]:IsShown() then
				err = true;
				_G[name]:Hide();
			end
		end
	end
	
	if err == true then
		self:Print(ERR_NOT_IN_COMBAT);		
	end		
end

function AddOn:OnProfileReset()
	local profileKey
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
	end
	
	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil;
	end	
		
	ElvCharacterDB = nil;
	ReloadUI()
end

function AddOn:LoadConfig()	
	AC:RegisterOptionsTable(AddOnName, self.Options)
	ACD:SetDefaultSize(AddOnName, DEFAULT_WIDTH, DEFAULT_HEIGHT)	
	
	--Create Profiles Table
	self.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.data);
	AC:RegisterOptionsTable("ElvProfiles", self.Options.args.profiles)
	self.Options.args.profiles.order = -10
	
	LibDualSpec:EnhanceDatabase(self.data, AddOnName)
	LibDualSpec:EnhanceOptions(self.Options.args.profiles, self.data)
end

function AddOn:ToggleConfig() 
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return;
	end

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