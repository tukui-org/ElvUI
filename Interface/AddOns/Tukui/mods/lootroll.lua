--[[
		this is an edited version of teksloot
		all credits of this mod goes to tekhub
--]]

if not TukuiRollLoot == true then return end


local backdrop = {
	bgFile = BLANK_TEXTURE, tile = true, tileSize = 0,
	edgeFile = BLANK_TEXTURE, edgeSize = 1,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollid, frame.rolltype)
end


local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide(); ResetCursor() end


local rolltypes = {"need", "greed", "disenchant", [0] = "pass"}
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	if frame:IsEnabled() == 0 then GameTooltip:AddLine("|cffff3333Cannot roll") end
	for name,roll in pairs(frame.parent.rolls) do if roll == rolltypes[frame.rolltype] then GameTooltip:AddLine(name, 1, 1, 1) end end
	GameTooltip:Show()
end


local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end


local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end


local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end


local cancelled_rolls = {}
local function OnEvent(frame, event, rollid)
	cancelled_rolls[rollid] = true
	if frame.rollid ~= rollid then return end

	frame.rollid = nil
	frame.time = nil
	frame:Hide()
end


local function StatusUpdate(frame)
	local t = GetLootRollTimeLeft(frame.parent.rollid)
	local perc = t / frame.parent.time
	frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)
end


local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetWidth(28)
	f:SetHeight(28)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil)
	txt:SetFont("Interface\\Addons\\Tukui\\media\\Russel Square LT.ttf", 12, "OUTLINE")
	txt:SetPoint("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)
	return f, txt
end


local function CreateRollFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(328)
	frame:SetHeight(22)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0.1, 0.1, 0.1, 1)
	frame:SetScript("OnEvent", OnEvent)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("LEFT", -24, 0)
	button:SetWidth(22)
	button:SetHeight(22)
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)

	frame.button = button

	local buttonborder = CreateFrame("Frame", nil, button)
	buttonborder:SetWidth(22)
	buttonborder:SetHeight(22)
	buttonborder:SetPoint("CENTER", button, "CENTER")
	buttonborder:SetBackdrop(backdrop)
	buttonborder:SetBackdropColor(1, 1, 1, 0)
	
	local buttonborder2 = CreateFrame("Frame", nil, button)
	buttonborder2:SetWidth(24)
	buttonborder2:SetHeight(24)
	buttonborder2:SetFrameLevel(buttonborder:GetFrameLevel()+1)
	buttonborder2:SetPoint("CENTER", button, "CENTER")
	buttonborder2:SetBackdrop(backdrop)
	buttonborder2:SetBackdropColor(0, 0, 0, 0)
	buttonborder2:SetBackdropBorderColor(0,0,0,1)
	

	frame.buttonborder = buttonborder

	local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetWidth(326)
	status:SetHeight(20)
	status:SetPoint("CENTER", frame, "CENTER", 0, 0)
	status:SetScript("OnUpdate", StatusUpdate)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture("Interface\\Addons\\Tukui\\media\\statusbar")
	status:SetStatusBarColor(.8, .8, .8, .9)
	status.parent = frame
	frame.status = status

	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetWidth(14)
	spark:SetHeight(25)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local de, detext
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2.2)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFont("Interface\\Addons\\Tukui\\media\\Russel Square LT.ttf", 12, "OUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFont("Interface\\Addons\\Tukui\\media\\Russel Square LT.ttf", 12, "OUTLINE")
	loot:SetPoint("LEFT", bind, "RIGHT", 0, .12)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetHeight(10)
	loot:SetWidth(200)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end


local anchor = CreateFrame("Button", nil, UIParent)
anchor:SetWidth(300) anchor:SetHeight(22)
anchor:SetBackdrop(backdrop)
anchor:SetBackdropColor(0.25, 0.25, 0.25, 1)
local label = anchor:CreateFontString(nil, "ARTWORK")
label:SetFont("Interface\\Addons\\Tukui\\media\\Russel Square LT.ttf", 12, "OUTLINE")
label:SetAllPoints(anchor)
label:SetText("teksLoot")

anchor:SetScript("OnClick", anchor.Hide)
anchor:SetScript("OnDragStart", anchor.StartMoving)
anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	self.db.x, self.db.y = self:GetCenter()
end)
anchor:SetMovable(true)
anchor:EnableMouse(true)
anchor:RegisterForDrag("LeftButton")
anchor:RegisterForClicks("RightButtonUp")
anchor:Hide()

local frames = {}

local f = CreateRollFrame() -- Create one for good measure
f:SetPoint("BOTTOMLEFT", next(frames) and frames[#frames] or anchor, "TOPLEFT", 0, 4)
table.insert(frames, f)

local function GetFrame()
	for i,f in ipairs(frames) do
		if not f.rollid then return f end
	end

	local f = CreateRollFrame()
	f:SetPoint("BOTTOMLEFT", next(frames) and frames[#frames] or anchor, "TOPLEFT", 0, 4)
	table.insert(frames, f)
	return f
end


local function START_LOOT_ROLL(rollid, time)
	if cancelled_rolls[rollid] then return end

	local f = GetFrame()
	f.rollid = rollid
	f.time = time
	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollid)
	f.button:SetNormalTexture(texture)
	f.button.link = GetLootRollItemLink(rollid)

	if canNeed then f.needbutt:Enable() else f.needbutt:Disable() end
	if canGreed then f.greedbutt:Enable() else f.greedbutt:Disable() end
	if canDisenchant then f.disenchantbutt:Enable() else f.disenchantbutt:Disable() end
	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed)
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed)
	SetDesaturation(f.disenchantbutt:GetNormalTexture(), not canDisenchant)


	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetVertexColor(color.r, color.g, color.b)
	f.fsloot:SetText(name)

	f:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	f.buttonborder:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:SetPoint("CENTER", WorldFrame, "CENTER")
	f:Show()
end


local locale = GetLocale()
local rollpairs = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil er den Gegenstand nicht benutzen kann.$"]  = "pass",
	["(.*) w\195\188rfelt nicht f\195\188r: (.+|r)$"] = "pass",
	["(.*) hat f\195\188r (.+) 'Gier' ausgew\195\164hlt"] = "greed",
	["(.*) hat f\195\188r (.+) 'Bedarf' ausgew\195\164hlt"] = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
} or locale == "frFR" and {
	["(.*) a pass\195\169 pour\194\160: (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"]  = "pass",
	["(.*) a pass\195\169 pour\194\160: (.+)"]  = "pass",
	["(.*) a choisi Cupidit\195\169 pour\194\160: (.+)"] = "greed",
	["(.*) a choisi Besoin pour\194\160: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
} or locale == "zhTW" and {
	["^(.*) \232\135\170\229\139\149\232\168\173\229\174\154\231\130\186\230\148\190\230\163\132: (.+) \229\155\160\231\130\186\228\187\150/\229\165\185\228\184\141\232\131\189\230\139\191\229\143\150\232\169\178\231\137\169\229\147\129.$"] = "pass",
	["^(.*) \230\148\190\230\163\132: (.+|r)$"]  = "pass",
	["(.*) \229\183\177\233\129\184\230\147\135\232\178\170\229\169\170: (.+)"] = "greed",
	["(.*) \229\183\177\233\129\184\230\147\135\233\156\128\230\177\130: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
} or locale == "ruRU" and {
	["^(.*) автоматически передает предмет (.+) поскольку не может его забрать.$"] = "pass",
	["^(.*) пропускает розыгрыш предмета (.+|r) поскольку не может его забрать.$"] = "pass",
	["(.*) отказывается от предмета (.+)%p"]  = "pass",
	["Разыгрывается%p (.*)%p (.+): \"Не откажусь\""] = "greed",
	["Разыгрывается%p (.*)%p (.+): \"Мне это нужно\""] = "need",
	["Разыгрывается%p (.*)%p (.+): \"Распылить\""] = "disenchant",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass",
	["^(.*) passed on: (.+|r)$"]  = "pass",
	["(.*) has selected Greed for: (.+)"] = "greed",
	["(.*) has selected Need for: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
}
local function ParseRollChoice(msg)
	for i,v in pairs(rollpairs) do
		local _, _, playername, itemname = string.find(msg, i)
		if locale == "ruRU" and (v == "greed" or v == "need" or v == "disenchant")  then 
			local temp = playername
			playername = itemname
			itemname = temp
		end 
		if playername and itemname and playername ~= "Everyone" then return playername, itemname, v end
	end
end

local function CHAT_MSG_LOOT(msg)
	local playername, itemname, rolltype = ParseRollChoice(msg)
	if playername and itemname and rolltype then
		for _,f in ipairs(frames) do
			if f.rollid and f.button.link == itemname and not f.rolls[playername] then
				f.rolls[playername] = rolltype
				f[rolltype]:SetText(tonumber(f[rolltype]:GetText()) + 1)
				return
			end
		end
	end
end


anchor:RegisterEvent("ADDON_LOADED")
anchor:SetScript("OnEvent", function(frame, event, addon)
	if addon ~= "Tukui" then return end

	anchor:UnregisterEvent("ADDON_LOADED")
	anchor:RegisterEvent("START_LOOT_ROLL")
	anchor:RegisterEvent("CHAT_MSG_LOOT")
	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	anchor:SetScript("OnEvent", function(frame, event, ...) if event == "CHAT_MSG_LOOT" then return CHAT_MSG_LOOT(...) else return START_LOOT_ROLL(...) end end)

	anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
end)

