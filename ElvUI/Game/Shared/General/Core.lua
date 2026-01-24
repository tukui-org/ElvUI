local ElvUI = select(2, ...)
ElvUI[2] = ElvUI[1].Libs.ACL:GetLocale('ElvUI', ElvUI[1]:GetLocale()) -- Locale doesn't exist yet, make it exist.
local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local tonumber, pairs, ipairs, error, unpack, tostring = tonumber, pairs, ipairs, error, unpack, tostring
local strjoin, wipe, sort, tinsert, tremove, tContains = strjoin, wipe, sort, tinsert, tremove, tContains
local format, strfind, strrep, strlen, sub, gsub = format, strfind, strrep, strlen, strsub, gsub
local assert, type, pcall, xpcall, next, print = assert, type, pcall, xpcall, next, print
local rawget, rawset, setmetatable = rawget, rawset, setmetatable

local Mixin = Mixin
local ColorMixin = ColorMixin
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local GetCurrentBindingSet = GetCurrentBindingSet
local GetNumGroupMembers = GetNumGroupMembers
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInRaid = IsInRaid
local ReloadUI = ReloadUI
local SaveBindings = SaveBindings
local SetBinding = SetBinding
local UIParent = UIParent
local UnitFactionGroup = UnitFactionGroup

local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local PlayerGetTimerunningSeasonID = PlayerGetTimerunningSeasonID

local DisableAddOn = C_AddOns.DisableAddOn
local GetCVarBool = C_CVar.GetCVarBool

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage

-- GLOBALS: ElvCharacterDB

--Modules
local ActionBars = E:GetModule('ActionBars')
local AFK = E:GetModule('AFK')
local Auras = E:GetModule('Auras')
local Bags = E:GetModule('Bags')
local Blizzard = E:GetModule('Blizzard')
local Chat = E:GetModule('Chat')
local DataBars = E:GetModule('DataBars')
local DataTexts = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Minimap = E:GetModule('Minimap')
local NamePlates = E:GetModule('NamePlates')
local Tooltip = E:GetModule('Tooltip')
local TotemTracker = E:GetModule('TotemTracker')
local UnitFrames = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

--Constants
E.noop = function() end
E.title = format('%s%s|r', E.InfoColor, 'ElvUI')
E.version, E.versionString, E.versionDev, E.versionGit = E:ParseVersionString('ElvUI')
E.myfaction, E.myLocalizedFaction = UnitFactionGroup('player')
E.myLocalizedClass, E.myclass, E.myClassID = UnitClass('player')
E.myLocalizedRace, E.myrace, E.myRaceID = UnitRace('player')
E.mygender = UnitSex('player')
E.mylevel = UnitLevel('player')
E.myname = UnitName('player')
E.myrealm = GetRealmName()
E.mynameRealm = format('%s - %s', E.myname, E.myrealm) -- contains spaces/dashes in realm (for profile keys)
E.expansionLevel = GetExpansionLevel()
E.wowbuild = tonumber(E.wowbuild)
E.physicalWidth, E.physicalHeight = GetPhysicalScreenSize()
E.screenWidth, E.screenHeight = GetScreenWidth(), GetScreenHeight()
E.resolution = format('%dx%d', E.physicalWidth, E.physicalHeight)
E.perfect = 768 / E.physicalHeight
E.allowRoles = E.Retail or E.TBC or E.Mists or E.Wrath or E.ClassicAnniv or E.ClassicAnnivHC or E.ClassicSOD
E.NewSign = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14:14|t]]
E.NewSignNoWhatsNew = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14:14:0:0|t]]
E.TexturePath = [[Interface\AddOns\ElvUI\Media\Textures\]] -- for plugins?
E.ClearTexture = 0 -- used to clear: Set (Normal, Disabled, Checked, Pushed, Highlight) Texture
E.Abbreviate = {}
E.UserList = {}

-- oUF Defines
E.oUF.Tags.Vars.E = E
E.oUF.Tags.Vars.L = L

--Tables
E.media = {}

-- Midnight aura colors
E.ColorCurves = { auras = false, buffs = false, debuffs = false }
ElvUF.ColorCurves = E.ColorCurves -- reference to oUF

E.frames = {}
E.unitFrameElements = {}
E.statusBars = {}
E.texts = {}
E.snapBars = {}
E.RegisteredModules = {}
E.RegisteredInitialModules = {}
E.valueColorUpdateFuncs = setmetatable({}, {
	__newindex = function(_, key, value)
		if type(key) == 'function' then return end
		rawset(E.valueColorUpdateFuncs, key, value)
	end
})

E.TexCoords = {0, 1, 0, 1}
E.FrameLocks = {}
E.VehicleLocks = {}
E.CreditsList = {}
E.ReverseTimer = {} -- Spells that we want to show the duration backwards (oUF_RaidDebuffs, ???)
E.InversePoints = {
	BOTTOM = 'TOP',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT',
	CENTER = 'CENTER',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	TOP = 'BOTTOM',
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT'
}

E.InverseAnchors = {
	BOTTOM = 'TOP',
	BOTTOMLEFT = 'TOPRIGHT',
	BOTTOMRIGHT = 'TOPLEFT',
	CENTER = 'CENTER',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	TOP = 'BOTTOM',
	TOPLEFT = 'BOTTOMRIGHT',
	TOPRIGHT = 'BOTTOMLEFT'
}

-- Workaround for people wanting to use white and it reverting to their class color.
E.PriestColors = { r = 0.99, g = 0.99, b = 0.99, colorStr = 'fffcfcfc' }

-- Socket Type info from 11.2.0 (63003): Interface\AddOns\Blizzard_ItemSocketing\Blizzard_ItemSocketingUI.lua
E.GemTypeInfo = {
	Yellow			= { r = 0.97, g = 0.82, b = 0.29 },
	Red				= { r = 1.00, g = 0.47, b = 0.47 },
	Blue			= { r = 0.47, g = 0.67, b = 1.00 },
	Hydraulic		= { r = 1.00, g = 1.00, b = 1.00 },
	Cogwheel		= { r = 1.00, g = 1.00, b = 1.00 },
	Meta			= { r = 1.00, g = 1.00, b = 1.00 },
	Prismatic		= { r = 1.00, g = 1.00, b = 1.00 },
	PunchcardRed	= { r = 1.00, g = 0.47, b = 0.47 },
	PunchcardYellow	= { r = 0.97, g = 0.82, b = 0.29 },
	PunchcardBlue	= { r = 0.47, g = 0.67, b = 1.00 },
	Domination		= { r = 0.24, g = 0.50, b = 0.70 },
	Cypher			= { r = 1.00, g = 0.80, b = 0.00 },
	Tinker			= { r = 1.00, g = 0.47, b = 0.47 },
	Primordial		= { r = 1.00, g = 0.00, b = 1.00 },
	Fragrance		= { r = 1.00, g = 1.00, b = 1.00 },
	SingingThunder	= { r = 0.97, g = 0.82, b = 0.29 },
	SingingSea		= { r = 0.47, g = 0.67, b = 1.00 },
	SingingWind		= { r = 1.00, g = 0.47, b = 0.47 },
	Fiber			= { r = 0.90, g = 0.80, b = 0.50 },
}

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent)
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel())
E.UIParent:SetSize(E.screenWidth, E.screenHeight)
E.UIParent:SetPoint('BOTTOM')
E.UIParent.origHeight = E.UIParent:GetHeight()
E.snapBars[#E.snapBars + 1] = E.UIParent

E.UFParent = _G.ElvUF_UFParentFrameHider -- created in oUF
E.UFParent:SetParent(E.UIParent)
E.UFParent:SetFrameStrata('LOW')

E.HiddenFrame = CreateFrame('Frame', nil, UIParent)
E.HiddenFrame:SetPoint('BOTTOM')
E.HiddenFrame:SetSize(1,1)
E.HiddenFrame:Hide()

-- rest of file omitted for brevity
