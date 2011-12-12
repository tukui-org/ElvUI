--[[

****************************************************************************************
LibAboutPanel

File date: 2010-12-01T19:31:23Z
Project version: v1.51

Author: Tekkub, Ackis

****************************************************************************************

]]--

local lib, oldminor = LibStub:NewLibrary("LibAboutPanel", 2)
if not lib then return end

function lib.new(parent, addonname)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame.name, frame.parent, frame.addonname = not parent and gsub(addonname," ","") or "About", parent, gsub(addonname," ","") -- Remove spaces from addonname because GetMetadata doesn't like that
	frame:Hide()
	frame:SetScript("OnShow", lib.OnShow)
	InterfaceOptions_AddCategory(frame)
	return frame
end

local GAME_LOCALE = GetLocale()

local L = {}

-- frFR
if GAME_LOCALE == "frFR" then
	L["About"] = "à propos de"
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy"
-- deDE
elseif GAME_LOCALE == "deDE" then
	L["About"] = "Über"
	L["Click and press Ctrl-C to copy"] = "Klicken und Strg-C drücken zum kopieren"
-- esES
elseif GAME_LOCALE == "esES" then
	L["About"] = "Acerca de"
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy"
-- esMX
elseif GAME_LOCALE == "esMX" then
	L["About"] = "Sobre"
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy"
-- koKR
elseif GAME_LOCALE == "koKR" then
	L["About"] = "대하여"
	L["Click and press Ctrl-C to copy"] = "클릭 후 Ctrl-C 복사"
-- ruRU
elseif GAME_LOCALE == "ruRU" then
	L["About"] = "Об аддоне"
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy"
-- zhCN
elseif GAME_LOCALE == "zhCN" then
	L["About"] = "关于"
	L["Click and press Ctrl-C to copy"] = "点击并 Ctrl-C 复制"
-- zhTW
elseif GAME_LOCALE == "zhTW" then
	L["About"] = "關於"
	L["Click and press Ctrl-C to copy"] = "左鍵點擊並按下 Ctrl-C 以複製字串"
-- enUS and non-localized
else
	L["About"] ="About"
	L["Click and press Ctrl-C to copy"] = "Click and press Ctrl-C to copy"
end

local editbox = CreateFrame('EditBox', nil, UIParent)
editbox:Hide()
editbox:SetAutoFocus(true)
editbox:SetHeight(32)
editbox:SetFontObject('GameFontHighlightSmall')
lib.editbox = editbox

local left = editbox:CreateTexture(nil, "BACKGROUND")
left:SetWidth(8) left:SetHeight(20)
left:SetPoint("LEFT", -5, 0)
left:SetTexture("Interface\\Common\\Common-Input-Border")
left:SetTexCoord(0, 0.0625, 0, 0.625)

local right = editbox:CreateTexture(nil, "BACKGROUND")
right:SetWidth(8) right:SetHeight(20)
right:SetPoint("RIGHT", 0, 0)
right:SetTexture("Interface\\Common\\Common-Input-Border")
right:SetTexCoord(0.9375, 1, 0, 0.625)

local center = editbox:CreateTexture(nil, "BACKGROUND")
center:SetHeight(20)
center:SetPoint("RIGHT", right, "LEFT", 0, 0)
center:SetPoint("LEFT", left, "RIGHT", 0, 0)
center:SetTexture("Interface\\Common\\Common-Input-Border")
center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
editbox:SetScript("OnEnterPressed", editbox.ClearFocus)
editbox:SetScript("OnEditFocusLost", editbox.Hide)
editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
editbox:SetScript("OnTextChanged", function(self)
	self:SetText(self:GetParent().val)
	self:HighlightText()
end)


function lib.OpenEditbox(self)
	editbox:SetText(self.val)
	editbox:SetParent(self)
	editbox:SetPoint("LEFT", self)
	editbox:SetPoint("RIGHT", self)
	editbox:Show()
end


local fields = {"Version", "Author", "X-Category", "X-License", "X-Email", "Email", "eMail", "X-Website", "X-Credits", "X-Localizations", "X-Donate"}
local haseditbox = {["X-Website"] = true, ["X-Email"] = true, ["X-Donate"] = true, ["Email"] = true, ["eMail"] = true}

local function HideTooltip() GameTooltip:Hide() end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(L["Click and press Ctrl-C to copy"])
	--GameTooltip:SetText("Click and press Ctrl-C to copy")
end

function lib.OnShow(frame)

	local notefield = "Notes"

	if (GAME_LOCALE ~= "enUS") then
		notefield = notefield .. "-" .. GAME_LOCALE
	end

	-- Get the localized version of notes if it exists or fall back to the english one.
	local notes = GetAddOnMetadata(frame.addonname, notefield) or GetAddOnMetadata(frame.addonname, "Notes")

	if not frame.about_title then
		frame.about_title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	end
	local title = frame.about_title

	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(frame.parent and (frame.parent.." - " .. L["About"]) or frame.name)

	if not frame.about_subtitle then
		frame.about_subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	end
	local subtitle = frame.about_subtitle
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(notes)

	local anchor
	for _,field in pairs(fields) do
		local val = GetAddOnMetadata(frame.addonname, field)
		if val then
			if not frame[field .. "_title"] then
				frame[field .. "_title"] = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			end
			local title = frame[field .. "_title"]
			title:SetWidth(75)

			if not anchor then
				title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -12)
			else
				title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
			end
			title:SetJustifyH("RIGHT")
			title:SetText(field:gsub("X%-", ""))

			if not frame[field .. "_detail"] then
				frame[field .. "_detail"] = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			end
			local detail = frame[field .. "_detail"]
			detail:SetHeight(32)
			detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
			detail:SetPoint("RIGHT", frame, -16, 0)
			detail:SetJustifyH("LEFT")

			if (field == "Author") then
				local authorservername = GetAddOnMetadata(frame.addonname, "X-Author-Server")
				local authorfaction = GetAddOnMetadata(frame.addonname, "X-Author-Faction")

				if authorservername and authorfaction then
					detail:SetText((haseditbox[field] and "|cff9999ff" or "").. val .. " on " .. authorservername .. " (" .. authorfaction .. ")")
				elseif authorservername and not authorfaction then
					detail:SetText((haseditbox[field] and "|cff9999ff" or "").. val .. " on " .. authorservername)
				elseif not authorservername and authorfaction then
					detail:SetText((haseditbox[field] and "|cff9999ff" or "").. val .. " (" .. authorfaction .. ")")
				else
					detail:SetText((haseditbox[field] and "|cff9999ff" or "").. val)
				end
			elseif (field == "Version") then
				local addonversion = GetAddOnMetadata(frame.addonname, field)
				-- Remove @project-revision@ and replace it with Repository
				addonversion = string.gsub(addonversion,"@project.revision@","Repository")
				detail:SetText((haseditbox[field] and "|cff9999ff" or "").. addonversion)
			else
				detail:SetText((haseditbox[field] and "|cff9999ff" or "").. val)
			end

			if haseditbox[field] then
				local button = CreateFrame("Button", nil, frame)
				button:SetAllPoints(detail)
				button.val = val
				button:SetScript("OnClick", lib.OpenEditbox)
				button:SetScript("OnEnter", ShowTooltip)
				button:SetScript("OnLeave", HideTooltip)
			end

			anchor = title
		end
	end

end
