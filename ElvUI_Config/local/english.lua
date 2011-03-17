-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvuiConfig", "enUS", true)
if not L then return end

--General
L["General Settings"] = true
	L["ELVUI_DESC"] = "User Interface replacement AddOn for World of Warcraft."
	L["Auto Scale"] = true
		L["Automatically scale the User Interface based on your screen resolution"] = true
	L["Scale"] = true
		L["Controls the scaling of the entire User Interface"] = true
	L["Multisample Protection"] = true
		L["Force the Blizzard Multisample Option to be set to 1x. WARNING: Turning this off will lead to blurry borders"] = true
	L["Class Color Theme"] = true
		L["Style all frame borders to be your class color, color unitframes to class color"] = true
	L["Font Scale"] = true
		L["Set the font scale for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"] = true
	L["Resolution Override"] = true
		L["Set a resolution version to use. By default any screensize > 1440 is considered a High resolution. This effects actionbar/unitframe layouts. If set to None, then it will be automatically determined by your screen size"] = true
		L["Low"] = true
		L["High"] = true
		L["None"] = true
	L["Layout Override"] = true
		L["Force a specific layout to show."] = true
		L["DPS"] = true
		L["Heal"] = true

--Media
L["Media"] = true
	L["MEDIA_DESC"] = "Setup Textures, Colors, Fonts and Sounds for ElvUI"
	L["Fonts"] = true
		L["Font"] = true
			L["The font that the core of the UI will use"] = true
		L["UnitFrame Font"] = true
			L["The font that unitframes will use"] = true
		L["Combat Text Font"] = true
			L["The font that combat text will use. WARNING: This requires a game restart after changing this option."] = true
	L["Textures"] = true
		L["StatusBar Texture"] = true
			L["Texture that gets used on all StatusBars"] = true
		L["Gloss Texture"] = true
			L["This gets used by some objects, unless gloss mode is on."] = true
		L["Glow Border"] = true
			L["Shadow Effect"] = true
		L["Backdrop Texture"] = true
			L["Used on almost all frames"] = true
		L["Glossy Texture Mode"] = true
			L["Glossy texture gets used in all aspects of the UI instead of just on various portions."] = true
	L["Colors"] = true
		L["Border Color"] = true
			L["Main Frame's Border Color"] = true
		L["Backdrop Color"] = true
			L["Main Frame's Backdrop Color"] = true
		L["Backdrop Fade Color"] = true
			L["Faded backdrop color of some frames"] = true
		L["Value Color"] = true
			L["Value color of various text/frame objects"] = true
	L["Sounds"] = true
		L["Whisper Sound"] = true
			L["Sound that is played when recieving a whisper"] = true
		L["Warning Sound"] = true
			L["Sound that is played when you don't have a buff active"] = true
--Nameplates
L["Nameplates"] = true
	L["NAMEPLATE_DESC"] = "Setup options for ElvUI nameplates"
	L["Nameplate Options"] = true
		L["Enable/Disable Nameplates"] = true
	L["Show Health"] = true
		L["Display health values on nameplates, this will also increase the size of the nameplate"] = true
	L["Health Threat Coloring"] = true
		L["Color the nameplate's healthbar by your current threat, Example: good threat color is used if your a tank when you have threat, opposite for DPS."] = true
	L["Toggle Combat"] = true
		L["Toggles the nameplates off when not in combat."] = true
	L["Track Auras"] = true
		L["Tracks your debuffs on nameplates."] = true
	L["Track CC Debuffs"] = true
		L["Tracks CC debuffs on nameplates from you or a friendly player"] = true
	L["Good Color"] = true
		L["This is displayed when you have threat as a tank, if you don't have threat it is displayed as a DPS/Healer"] = true
	L["Bad Color"] = true
		L["This is displayed when you don't have threat as a tank, if you do have threat it is displayed as a DPS/Healer"] = true
	L["Transition Color"] = true
		L["This color is displayed when gaining/losing threat"] = true
		
--Profiles
L["Profiles"] = true