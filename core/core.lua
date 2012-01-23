local E, L, DF = unpack(select(2, ...)); --Engine
local LSM = LibStub("LibSharedMedia-3.0")
local _, ns = ...
local ElvUF = ns.oUF
local ACD = LibStub("AceConfigDialog-3.0")

--Variables
_, E.myclass = UnitClass("player");
E.myname, _ = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
_, E.wowbuild = GetBuildInfo(); E.wowbuild = tonumber(E.wowbuild);
E.noop = function() end;
E.screenheight = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"));
E.screenwidth = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x+%d"));
E.MinimapSize = 175
E.RBRWidth = ((E.MinimapSize - 6) / 6) + 4
E.ValColor = '|cff1784d1' -- DEPRECIATED SOON, REMEMBER TO REMOVE THIS AND CODE AROUND IT
E.TexCoords = {.08, .92, .08, .92}

E['valueColorUpdateFuncs'] = {};

--Table contains the SharedMedia values of all the fonts/textures
E["media"] = {};

--Table contains every frame we use :SetTemplate or every text we use :Font on
E["frames"] = {};
E["texts"] = {};

E['snapBars'] = {}

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata(..., "Title")

--Modules List
E["RegisteredModules"] = {}

function E:Print(msg)
	print(self["media"].hexvaluecolor..'ElvUI:|r', msg)
end

function E:UpdateMedia()	
	--Fonts
	self["media"].normFont = LSM:Fetch("font", self.db["core"].font)
	self["media"].combatFont = LSM:Fetch("font", self.db["core"].dmgfont)
	

	--Textures
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank")
	self["media"].normTex = LSM:Fetch("statusbar", self.db["core"].normTex)
	self["media"].glossTex = LSM:Fetch("statusbar", self.db["core"].glossTex)

	--Border Color
	local border = self.db["core"].bordercolor
	self["media"].bordercolor = {border.r, border.g, border.b}

	--Backdrop Color
	local backdrop = self.db["core"].backdropcolor
	self["media"].backdropcolor = {backdrop.r, backdrop.g, backdrop.b}

	--Backdrop Fade Color
	backdrop = self.db["core"].backdropfadecolor
	self["media"].backdropfadecolor = {backdrop.r, backdrop.g, backdrop.b, backdrop.a}
	
	--Value Color
	local value = self.db["core"].valuecolor
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.core.panelBackdropNameLeft)
		LeftChatPanel.tex:SetAlpha(E.db.core.backdropfadecolor.a - 0.55 > 0 and E.db.core.backdropfadecolor.a - 0.55 or 0.5)		
		
		RightChatPanel.tex:SetTexture(E.db.core.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(E.db.core.backdropfadecolor.a - 0.55 > 0 and E.db.core.backdropfadecolor.a - 0.55 or 0.5)		
	end
	
	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

function E:ValueFuncCall()
	for func, _ in pairs(self['valueColorUpdateFuncs']) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if frame and frame.template then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == 'Transparent' or frame.template == nil then
				frame:SetBackdropBorderColor(unpack(self['media'].bordercolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == nil then
				if frame.backdropTexture then
					frame.backdropTexture:SetVertexColor(unpack(self['media'].backdropcolor))
				else
					frame:SetBackdropColor(unpack(self['media'].backdropcolor))				
				end
			elseif frame.template == 'Transparent' then
				frame:SetBackdropColor(unpack(self['media'].backdropfadecolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER');
E.UIParent:SetSize(UIParent:GetSize());
tinsert(E['snapBars'], E.UIParent)

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()

--Check if PTR version of WoW is loaded
function E:IsPTRVersion()
	if self.wowbuild > 14545 then
		return true;
	else
		return false;
	end
	return false;
end

--Check the player's role
function E:CheckRole()
	local tree = GetPrimaryTalentTree();
	local resilience;
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true;
	else
		resilience = false;
	end
	if ((self.myclass == "PALADIN" and tree == 2) or 
	(self.myclass == "WARRIOR" and tree == 3) or 
	(self.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(self.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		self.role = "Tank";
	else
		local playerint = select(2, UnitStat("player", 4));
		local playeragi	= select(2, UnitStat("player", 2));
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (self.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not 
		(UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or self.myclass == "ROGUE" or self.myclass == "HUNTER" or (self.myclass == "SHAMAN" and tree == 2) then
			self.role = "Melee";
		else
			self.role = "Caster";
		end
	end
end

function E:RegisterModule(name)
	if self.initialized then
		self:GetModule(name):Initialize()
		tinsert(self['RegisteredModules'], name)
	else
		tinsert(self['RegisteredModules'], name)
	end
end

function E:InitializeModules()	
	for _, module in pairs(E['RegisteredModules']) do
		if self:GetModule(module).Initialize then
			self:GetModule(module):Initialize()
		end
	end
end

function E:CreateMoverPopup()
	local f = CreateFrame("Frame", "ElvUIMoverPopupWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate('Transparent')
	f:SetPoint("TOP", 0, -50)
	f:Hide()
	f:SetScript("OnShow", function() PlaySound("igMainMenuOption") end)
	f:SetScript("OnHide", function() PlaySound("gsTitleOptionExit") end)

	local S = self:GetModule('Skins')

	local header = CreateFrame('Frame', nil, f)
	header:SetTemplate('Default', true)
	header:SetWidth(100); header:SetHeight(25)
	header:SetPoint("CENTER", f, 'TOP')
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText('ElvUI')
		
	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 48)
	desc:SetText(L["Movers unlocked. Move them now and click Lock when you are done."])

	local snapping = CreateFrame("CheckButton", "ElvUISnapping", f, "OptionsCheckButtonTemplate")
	_G[snapping:GetName() .. "Text"]:SetText(L["Sticky Frames"])

	snapping:SetScript("OnShow", function(self)
		self:SetChecked(E.db.core.stickyFrames)
	end)

	snapping:SetScript("OnClick", function(self)
		E.db.core.stickyFrames = self:GetChecked()
	end)

	local lock = CreateFrame("Button", "ElvUILock", f, "OptionsButtonTemplate")
	_G[lock:GetName() .. "Text"]:SetText(L["Lock"])

	lock:SetScript("OnClick", function(self)
		E:MoveUI(false)
		self:GetParent():Hide()
		ACD['Open'](ACD, 'ElvUI') 
	end)

	--position buttons
	snapping:SetPoint("BOTTOMLEFT", 14, 10)
	lock:SetPoint("BOTTOMRIGHT", -14, 14)
	
	S:HandleCheckBox(snapping)
	S:HandleButton(lock)
	
	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:SetScript('OnEvent', function(self)
		if self:IsShown() then
			self:Hide()
		end
	end)
end

function E:CheckIncompatible()
	if IsAddOnLoaded('Prat-3.0') and E.db.chat.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Prat', 'Chat'))
	elseif IsAddOnLoaded('Chatter') and E.db.chat.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Chatter', 'Chat'))
	end
	
	if IsAddOnLoaded('Bartender4') and E.db.actionbar.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Bartender', 'ActionBar'))
	elseif IsAddOnLoaded('Dominos') and E.db.actionbar.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Dominos', 'ActionBar'))
	end	
	
	if IsAddOnLoaded('TidyPlates') and E.db.nameplate.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'TidyPlates', 'NamePlate'))
	elseif IsAddOnLoaded('Aloft') and E.db.nameplate.enable then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Aloft', 'NamePlate'))
	end	
	
	if IsAddOnLoaded('ArkInventory') and E.db.core.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'ArkInventory', 'Bags'))
	elseif IsAddOnLoaded('Bagnon') and E.db.core.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'Bagnon', 'Bags'))
	elseif IsAddOnLoaded('OneBag3') and E.db.core.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'OneBag3', 'Bags'))
	elseif IsAddOnLoaded('OneBank3') and E.db.core.bags then
		E:Print(format(L['INCOMPATIBLE_ADDON'], 'OneBank3', 'Bags'))
	end
end

function E:IsFoolsDay()
	local date = date()
	if string.find(date, '04/01/') then
		return true;
	else
		return false;
	end
end

function E:SendRecieve(event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if (prefix ~= "ElvUI") then return end
		if tonumber(message) > tonumber(E.version) then
			E:Print(L["Your version of ElvUI is out of date. You can download the latest version from www.curse.com"])
			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		SendAddonMessage("ElvUI", E.version, "RAID")
	end
end

function E:Initialize()
	self.data = LibStub("AceDB-3.0"):New("ElvData", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.data.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db = self.data.profile;

	if self.db.core.loginmessage then
		print(format(L['LOGIN_MSG'], self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version))
	end
	
	self:CheckIncompatible()
	
	self:CheckRole()
	self:UIScale('PLAYER_LOGIN');
	
	self:LoadConfig(); --Load In-Game Config
	self:LoadCommands(); --Load Commands
	self:InitializeModules(); --Load Modules	
	self:LoadMovers(); --Load Movers
	
	self.initialized = true

	if self.db.install_complete == nil or (self.db.install_complete and type(self.db.install_complete) == 'boolean') or (self.db.install_complete and type(tonumber(self.db.install_complete)) == 'number' and tonumber(self.db.install_complete) <= 3.05) then
		self:Install()
	end
	
	RegisterAddonMessagePrefix('ElvUI')
	
	self:UpdateMedia()
	self:CreateMoverPopup()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");	
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "SendRecieve")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "SendRecieve")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "SendRecieve")
	self:RegisterEvent("CHAT_MSG_ADDON", "SendRecieve")
end

local toggle
function E:MoveUI(override, type)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if toggle ~= nil then
		toggle = nil
	else
		toggle = true
	end
	
	if override then toggle = override end
	
	if toggle then
		ElvUIMoverPopupWindow:Show()
		ACD['Close'](ACD, 'ElvUI') 
		GameTooltip:Hide()
	else
		ElvUIMoverPopupWindow:Hide()
	end
	
	if type == 'unitframes' and self.UnitFrames then
		ElvUF:MoveUF(toggle)
		return
	elseif type == 'actionbars' and self.ActionBars then
		self.ActionBars:ToggleMovers(toggle)
		return
	end
	
	self:ToggleMovers(toggle)
	
	if self.UnitFrames then
		ElvUF:MoveUF(toggle)
	end
	
	if self.ActionBars then
		self.ActionBars:ToggleMovers(toggle)
	end	
end

function E:ResetAllUI()
	self:ResetMovers()
	
	if self.UnitFrames then
		ElvUF:ResetUF()	
	end
	
	if self.ActionBars then
		self.ActionBars:ResetMovers('')
	end	
end


function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if ... == '' or ... == ' ' or ... == nil then
		StaticPopup_Show('RESETUI_CHECK')
		return
	end
	
	self:ResetMovers(...)
	
	if self.UnitFrames then
		ElvUF:ResetUF(...)	
	end
	
	if self.ActionBars then
		self.ActionBars:ResetMovers(...)
	end	
end