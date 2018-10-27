local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor")
local AceGUI = LibStub("AceGUI-3.0")

local tsort, tinsert = table.sort, table.insert
local format = string.format
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0-ElvUI")
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI")

local _G = _G
local UnitName = UnitName
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitExists = UnitExists
local GameTooltip_Hide = GameTooltip_Hide
local GameFontHighlightSmall = _G['GameFontHighlightSmall']

AC:RegisterOptionsTable("ElvUI", E.Options)
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT)

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	self:RefreshCustomTextsConfigs()
	ACR:NotifyChange("ElvUI")
end

E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r",E.version),
		width = "full",
	},
	LoginMessage = {
		order = 2,
		type = 'toggle',
		name = L["Login Message"],
		get = function(info) return E.db.general.loginmessage end,
		set = function(info, value) E.db.general.loginmessage = value end,
	},
	ToggleTutorial = {
		order = 3,
		type = 'execute',
		name = L["Toggle Tutorials"],
		func = function() E:Tutorials(true); E:ToggleConfig()  end,
	},
	Install = {
		order = 4,
		type = 'execute',
		name = L["Install"],
		desc = L["Run the installation process."],
		func = function() E:Install(); E:ToggleConfig() end,
	},
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode() end,
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},
}

local DONATOR_STRING = ""
local DEVELOPER_STRING = ""
local TESTER_STRING = ""
local LINE_BREAK = "\n"
local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee",
	"Portable",
	"Ithilyn"
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine",
	"Blazeflack",
	"|cffff7d0aMerathilis|r",
	"|cFF8866ccSimpy|r"
}

local TESTERS = {
	"Tukui Community",
	"|cffF76ADBSarah|r - For Sarahing",
	"Affinity",
	"Azilroka",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Repooc",
	"Darth Predator",
	"Alex",
	"Nidra",
	"Kurhyus",
	"BuG",
	"Yachanay",
	"Catok"
}

tsort(DONATORS, function(a,b) return a < b end) --Alphabetize
for _, donatorName in pairs(DONATORS) do
	tinsert(E.CreditsList, donatorName)
	DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
end

tsort(DEVELOPERS, function(a,b) return a < b end) --Alphabetize
for _, devName in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, devName)
	DEVELOPER_STRING = DEVELOPER_STRING..LINE_BREAK..devName
end

tsort(TESTERS, function(a,b) return a < b end) --Alphabetize
for _, testerName in pairs(TESTERS) do
	tinsert(E.CreditsList, testerName)
	TESTER_STRING = TESTER_STRING..LINE_BREAK..testerName
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L["ELVUI_CREDITS"]..'\n\n'..L["Coding:"]..DEVELOPER_STRING..'\n\n'..L["Testing:"]..TESTER_STRING..'\n\n'..L["Donations:"]..DONATOR_STRING,
		},
	},
}

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filters"] = L["Aura Filters"],
	["styleFilters"] = L["NamePlate Style Filters"],
}
local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filters",
	"styleFilters",
}
local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"],
}
local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin",
}

local exportString = ""
local function ExportImport_Open(mode)
	local Frame = AceGUI:Create("Frame")
	Frame:SetTitle("")
	Frame:EnableResize(false)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	Frame:SetLayout("flow")


	local Box = AceGUI:Create("MultiLineEditBox");
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel("")
	Frame:AddChild(Box)
	--Save original script so we can restore it later
	Box.editBox.OnTextChangedOrig = Box.editBox:GetScript("OnTextChanged")
	Box.editBox.OnCursorChangedOrig = Box.editBox:GetScript("OnCursorChanged")
	--Remove OnCursorChanged script as it causes weird behaviour with long text
	Box.editBox:SetScript("OnCursorChanged", nil)

	local Label1 = AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label1:SetFont(font, 14)
	Label1:SetText(".") --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	Frame:AddChild(Label1)

	local Label2 = AceGUI:Create("Label")
	font = GameFontHighlightSmall:GetFont()
	Label2:SetFont(font, 14)
	Label2:SetText(".\n.")
	Label2:SetWidth(800)
	Frame:AddChild(Label2)

	if mode == "export" then
		Frame:SetTitle(L["Export Profile"])

		local ProfileTypeDropdown = AceGUI:Create("Dropdown")
		ProfileTypeDropdown:SetMultiselect(false)
		ProfileTypeDropdown:SetLabel(L["Choose What To Export"])
		ProfileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder)
		ProfileTypeDropdown:SetValue("profile") --Default export
		Frame:AddChild(ProfileTypeDropdown)

		local ExportFormatDropdown = AceGUI:Create("Dropdown")
		ExportFormatDropdown:SetMultiselect(false)
		ExportFormatDropdown:SetLabel(L["Choose Export Format"])
		ExportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder)
		ExportFormatDropdown:SetValue("text") --Default format
		ExportFormatDropdown:SetWidth(150)
		Frame:AddChild(ExportFormatDropdown)

		local exportButton = AceGUI:Create("Button")
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		local function OnClick(self)
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local profileType, exportFormat = ProfileTypeDropdown:GetValue(), ExportFormatDropdown:GetValue()
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
			if not profileKey or not profileExport then
				Label1:SetText(L["Error exporting profile!"])
			else
				Label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]))
				if profileType == "profile" then
					Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
				end
			end
			Box:SetText(profileExport);
			Box.editBox:HighlightText();
			Box:SetFocus();
			exportString = profileExport
		end
		exportButton:SetCallback("OnClick", OnClick)
		Frame:AddChild(exportButton)

		--Set scripts
		Box.editBox:SetScript("OnChar", function() Box:SetText(exportString); Box.editBox:HighlightText(); end);
		Box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				--Prevent user from changing export string
				Box:SetText(exportString)
				Box.editBox:HighlightText();
			end
		end)

	elseif mode == "import" then
		Frame:SetTitle(L["Import Profile"])
		local importButton = AceGUI:Create("Button-ElvUI") --This version changes text color on SetDisabled
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local text
			local success = D:ImportProfile(Box:GetText())
			if success then
				text = L["Profile imported successfully!"]
			else
				text = L["Error decoding data. Import string may be corrupted!"]
			end
			Label1:SetText(text)
		end)
		Frame:AddChild(importButton)

		local decodeButton = AceGUI:Create("Button-ElvUI")
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")
			local decodedText
			local profileType, profileKey, profileData = D:Decode(Box:GetText())
			if profileData then
				decodedText = E:TableToLuaString(profileData)
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
			Box:SetText(importText)
		end)
		Frame:AddChild(decodeButton)

		local oldText = ""
		local function OnTextChanged()
			local text = Box:GetText()
			if text == "" then
				Label1:SetText("")
				Label2:SetText("")
				importButton:SetDisabled(true)
				decodeButton:SetDisabled(true)
			elseif oldText ~= text then
				local stringType = D:GetImportStringType(text)
				if stringType == "Base64" then
					decodeButton:SetDisabled(false)
				else
					decodeButton:SetDisabled(true)
				end

				local profileType, profileKey = D:Decode(text)
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
					Label2:SetText("")
					importButton:SetDisabled(true)
					decodeButton:SetDisabled(true)
				else
					Label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""))
					if profileType == "profile" then
						Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
					end
					importButton:SetDisabled(false)
				end

				--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
				Box.scrollFrame:UpdateScrollChildRect()
				Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())

				oldText = text
			end
		end

		Box.editBox:SetFocus()
		--Set scripts
		Box.editBox:SetScript("OnChar", nil);
		Box.editBox:SetScript("OnTextChanged", OnTextChanged)
	end

	Frame:SetCallback("OnClose", function(widget)
		--Restore changed scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", Box.editBox.OnTextChangedOrig)
		Box.editBox:SetScript("OnCursorChanged", Box.editBox.OnCursorChangedOrig)
		Box.editBox.OnTextChangedOrig = nil
		Box.editBox.OnCursorChangedOrig = nil

		--Clear stored export string
		exportString = ""

		AceGUI:Release(widget)
		ACD:Open("ElvUI")
	end)

	--Clear default text
	Label1:SetText("")
	Label2:SetText("")

	--Close ElvUI Config
	ACD:Close("ElvUI")

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

LibStub('LibDualSpec-1.0'):EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

E.Options.args.profiles.plugins.ElvUI = {
	spacer = {
		order = 89,
		type = 'description',
		name = '\n\n',
	},
	desc = {
		name = L["This feature will allow you to transfer settings to other characters."],
		type = 'description',
		order = 90,
	},
	distributeProfile = {
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = 'execute',
		order = 91,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name)
			elseif server then
				D:Distribute(name, true)
			end
		end,
	},
	distributeGlobal = {
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		type = 'execute',
		order = 92,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end

			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name, false, true)
			elseif server then
				D:Distribute(name, true, true)
			end
		end,
	},
	spacer2 = {
		order = 93,
		type = 'description',
		name = '',
	},
	exportProfile = {
		name = L["Export Profile"],
		type = 'execute',
		order = 94,
		func = function() ExportImport_Open("export") end,
	},
	importProfile = {
		name = L["Import Profile"],
		type = 'execute',
		order = 95,
		func = function() ExportImport_Open("import") end,
	},
}
