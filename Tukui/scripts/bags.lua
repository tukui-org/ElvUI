--[[
	A featureless, 'pure' version of Stuffing. 
	This version should work on absolutely everything, 
	but I've removed pretty much all of the options.
	
	All credits of this bags script is by Stuffing and his author Hungtar.
	Special Thank's to Hungtar to allow me to use his bag mod for Tukui.
--]]

if not TukuiCF["bags"].enable == true then return end

local bags_BACKPACK = {0, 1, 2, 3, 4}
local bags_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}
local BAGSFONT = TukuiCF["media"].font
local ST_NORMAL = 1
local ST_SPECIAL = 3
local bag_bars = 0

-- hide bags options in default interface
InterfaceOptionsDisplayPanelShowFreeBagSpace:Hide()

Stuffing = CreateFrame ("Frame", nil, UIParent)
Stuffing:RegisterEvent("ADDON_LOADED")
Stuffing:RegisterEvent("PLAYER_ENTERING_WORLD")
Stuffing:SetScript("OnEvent", function(this, event, ...)
	Stuffing[event](this, ...)
end)

-- stub for localization.
local L = setmetatable({}, {
	__index = function (t, v)
		t[v] = v
		return v
	end
})


local function Print (x)
	DEFAULT_CHAT_FRAME:AddMessage("|cffC495DDTukui:|r " .. x)
end

local function Stuffing_Sort(args)
	if not args then
		args = ""
	end

	Stuffing.itmax = 0
	Stuffing:SetBagsForSorting(args)
	Stuffing:SortBags()
end


local function Stuffing_OnShow()
	Stuffing:PLAYERBANKSLOTS_CHANGED(29)	-- XXX: hack to force bag frame update

	Stuffing:Layout()
	Stuffing:SearchReset()
end


local function StuffingBank_OnHide()
	CloseBankFrame()
	if Stuffing.frame:IsShown() then
		Stuffing.frame:Hide()
	end
end


local function Stuffing_OnHide()
	if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
		Stuffing.bankFrame:Hide()
	end
end


local function Stuffing_Open()
	Stuffing.frame:Show()
end


local function Stuffing_Close()
	Stuffing.frame:Hide()
end


local function Stuffing_Toggle()
	if Stuffing.frame:IsShown() then
		Stuffing.frame:Hide()
	else
		Stuffing.frame:Show()
	end
end


local function Stuffing_ToggleBag(id)
	if id == -2 then
		ToggleKeyRing()
		return
	end
	Stuffing_Toggle()
end


--
-- bag slot stuff
--
local trashParent = CreateFrame("Frame", nil, UIParent)
local trashButton = {}
local trashBag = {}

-- for the tooltip frame used to scan item tooltips
local StuffingTT = nil

-- mostly from carg.bags_Aurora
local QUEST_ITEM_STRING = nil

function Stuffing:SlotUpdate(b)
	if not StuffingFrameBags:IsShown() then return end -- don't do any slot update if bags are not show
	local texture, count, locked = GetContainerItemInfo (b.bag, b.slot)
	local clink = GetContainerItemLink(b.bag, b.slot)
	
	-- set all slot color to default tukui on update
	if not b.frame.lock then
		b.frame:SetBackdropBorderColor(unpack(TukuiCF.media.bordercolor))
	end
	
	if b.Cooldown then
		local cd_start, cd_finish, cd_enable = GetContainerItemCooldown(b.bag, b.slot)
		CooldownFrame_SetTimer(b.Cooldown, cd_start, cd_finish, cd_enable)
	end

	if(clink) then
		local iType
		b.name, _, b.rarity, _, _, iType = GetItemInfo(clink)
		
		-- color slot according to item quality
		if not b.frame.lock and b.rarity and b.rarity > 1 then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(b.rarity))
		end

			if not StuffingTT then
				StuffingTT = CreateFrame("GameTooltip", "StuffingTT", nil, "GameTooltipTemplate")
				StuffingTT:Hide()
			end

			if QUEST_ITEM_STRING == nil then
				-- GetItemInfo returns a localized item type.
				-- this is to figure out what that string is.
				local t = {GetAuctionItemClasses()}
				QUEST_ITEM_STRING = t[#t]	-- #t == 12
			end

			-- load tooltip, check if ITEM_BIND_QUEST ("Quest Item") is in it.
			-- If the tooltip says its a quest item, we assume it is a quest item
			-- and ignore the item type from GetItemInfo.
			StuffingTT:SetOwner(WorldFrame, "ANCHOR_NONE")
			StuffingTT:ClearLines()
			StuffingTT:SetBagItem(b.bag, b.slot)
			for i = 1, StuffingTT:NumLines() do
				local txt = getglobal("StuffingTTTextLeft" .. i)
				if txt then
					local text = txt:GetText()
					if string.find (txt:GetText(), ITEM_BIND_QUEST) then
						iType = QUEST_ITEM_STRING
					end
				end
			end

			if iType and iType == QUEST_ITEM_STRING then
				b.qitem = true
				-- color quest item red
				if not b.frame.lock then b.frame:SetBackdropBorderColor(1.0, 0.3, 0.3) end
			else
				b.qitem = nil
			end
	else
		b.name, b.rarity, b.qitem = nil, nil, nil
	end
	
	SetItemButtonTexture(b.frame, texture)
	SetItemButtonCount(b.frame, count)
	SetItemButtonDesaturated(b.frame, locked, 0.5, 0.5, 0.5)
		
	b.frame:Show()
end


function Stuffing:BagSlotUpdate(bag)
	if not self.buttons then
		return
	end

	for _, v in ipairs (self.buttons) do
		if v.bag == bag then
			self:SlotUpdate(v)
		end
	end
end


function Stuffing:BagFrameSlotNew (slot, p)
	for _, v in ipairs(self.bagframe_buttons) do
		if v.slot == slot then
			--print ("found " .. slot)
			return v, false
		end
	end

	--print ("new " .. slot)
	local ret = {}
	local tpl

	if slot > 3 then
		ret.slot = slot
		slot = slot - 4
		tpl = "BankItemButtonBagTemplate"
		ret.frame = CreateFrame("CheckButton", "StuffingBBag" .. slot, p, tpl)
		ret.frame:SetID(slot + 4)
		table.insert(self.bagframe_buttons, ret)

		BankFrameItemButton_Update(ret.frame)
		BankFrameItemButton_UpdateLocked(ret.frame)

		if not ret.frame.tooltipText then
			ret.frame.tooltipText = ""
		end
	else
		tpl = "BagSlotButtonTemplate"
		ret.frame = CreateFrame("CheckButton", "StuffingFBag" .. slot .. "Slot", p, tpl)
		ret.slot = slot
		table.insert(self.bagframe_buttons, ret)
	end

	return ret
end


function Stuffing:SlotNew (bag, slot)
	for _, v in ipairs(self.buttons) do
		if v.bag == bag and v.slot == slot then
			return v, false
		end
	end

	local tpl = "ContainerFrameItemButtonTemplate"

	if bag == -1 then
		tpl = "BankItemButtonGenericTemplate"
	end

	local ret = {}

	if #trashButton > 0 then
		local f = -1
		for i, v in ipairs(trashButton) do
			local b, s = v:GetName():match("(%d+)_(%d+)")

			b = tonumber(b)
			s = tonumber(s)

			--print (b .. " " .. s)
			if b == bag and s == slot then
				f = i
				break
			end
		end

		if f ~= -1 then
			--print("found it")
			ret.frame = trashButton[f]
			table.remove(trashButton, f)
		end
	end

	if not ret.frame then
		ret.frame = CreateFrame("Button", "StuffingBag" .. bag .. "_" .. slot, self.bags[bag], tpl)
	end

	ret.bag = bag
	ret.slot = slot
	ret.frame:SetID(slot)

	ret.Cooldown = _G[ret.frame:GetName() .. "Cooldown"]
	ret.Cooldown:Show()

	self:SlotUpdate (ret)

	return ret, true
end


-- from OneBag
 
local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400

function Stuffing:BagType(bag)
	local bagType = select(2, GetContainerNumFreeSlots(bag))

	if bit.band(bagType, BAGTYPE_PROFESSION) > 0 then
		return ST_SPECIAL
	end

	return ST_NORMAL
end


function Stuffing:BagNew (bag, f)
	for i, v in pairs(self.bags) do
		if v:GetID() == bag then
			v.bagType = self:BagType(bag)
			return v
		end
	end

	local ret

	if #trashBag > 0 then
		local f = -1
		for i, v in pairs(trashBag) do
			if v:GetID() == bag then
				f = i
				break
			end
		end

		if f ~= -1 then
			--print("found bag " .. bag)
			ret = trashBag[f]
			table.remove(trashBag, f)
			ret:Show()
			ret.bagType = self:BagType(bag)
			return ret
		end
	end

	--print("new bag " .. bag)
	ret = CreateFrame("Frame", "StuffingBag" .. bag, f)
	ret.bagType = self:BagType(bag)

	ret:SetID(bag)
	return ret
end


function Stuffing:SearchUpdate(str)
	str = string.lower(str)

	for _, b in ipairs(self.buttons) do
		if b.frame and not b.name then
			b.frame:SetAlpha(.2)
		end
		if b.name then
			if not string.find (string.lower(b.name), str) then
				SetItemButtonDesaturated(b.frame, 1, 1, 1, 1)
				b.frame:SetAlpha(.2)
			else
				SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
				b.frame:SetAlpha(1)
			end
		end
	end
end


function Stuffing:SearchReset()
	for _, b in ipairs(self.buttons) do
		b.frame:SetAlpha(1)
		SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
	end
end

-- drop down menu stuff from Postal
local Stuffing_DDMenu = CreateFrame("Frame", "Stuffing_DropDownMenu")
Stuffing_DDMenu.displayMode = "MENU"
Stuffing_DDMenu.info = {}
Stuffing_DDMenu.HideMenu = function()
	if UIDROPDOWNMENU_OPEN_MENU == Stuffing_DDMenu then
		CloseDropDownMenus()
	end
end

function Stuffing:CreateBagFrame(w)
	local n = "StuffingFrame"  .. w
	local f = CreateFrame ("Frame", n, UIParent)
	f:EnableMouse(1)
	f:SetMovable(1)
	f:SetToplevel(1)
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(20)

	if w == "Bank" then
		f:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, TukuiDB.Scale(5))
	else
		f:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB.Scale(5))
	end
	
	-- close button
	f.b_close = CreateFrame("Button", "Stuffing_CloseButton" .. w, f, "UIPanelCloseButton")
	f.b_close:SetWidth(TukuiDB.Scale(32))
	f.b_close:SetHeight(TukuiDB.Scale(32))
	f.b_close:SetPoint("TOPRIGHT", TukuiDB.Scale(-3), TukuiDB.Scale(-3))
	f.b_close:SetScript("OnClick", function(self, btn)
		if self:GetParent():GetName() == "StuffingFrameBags" and btn == "RightButton" then
			if Stuffing_DDMenu.initialize ~= Stuffing.Menu then
				CloseDropDownMenus()
				Stuffing_DDMenu.initialize = Stuffing.Menu
			end
			ToggleDropDownMenu(1, nil, Stuffing_DDMenu, self:GetName(), 0, 0)
			return
		end
		self:GetParent():Hide()
	end)
	f.b_close:RegisterForClicks("AnyUp")
	f.b_close:GetNormalTexture():SetDesaturated(1)

	-- create the bags frame
	local fb = CreateFrame ("Frame", n .. "BagsFrame", f)
	fb:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, TukuiDB.Scale(2))
	fb:SetFrameStrata("HIGH")
	f.bags_frame = fb

	return f
end


function Stuffing:InitBank()
	if self.bankFrame then
		return
	end

	local f = self:CreateBagFrame("Bank")
	f:SetScript("OnHide", StuffingBank_OnHide)
	self.bankFrame = f
end


local parent_startmoving = function(self)
	StartMoving(self:GetParent())
end


local parent_stopmovingorsizing = function (self)
	StopMoving(self:GetParent())
end


function Stuffing:InitBags()
	if self.frame then
		return
	end

	self.buttons = {}
	self.bags = {}
	self.bagframe_buttons = {}

	local f = self:CreateBagFrame("Bags")
	f:SetScript("OnShow", Stuffing_OnShow)
	f:SetScript("OnHide", Stuffing_OnHide)

	-- search editbox (tekKonfigAboutPanel.lua)
	local editbox = CreateFrame("EditBox", nil, f)
	editbox:Hide()
	editbox:SetAutoFocus(true)
	editbox:SetHeight(TukuiDB.Scale(32))
	TukuiDB.SetTemplate(editbox)

	local resetAndClear = function (self)
		self:GetParent().detail:Show()
		self:GetParent().gold:Show()
		self:ClearFocus()
		Stuffing:SearchReset()
	end

	local updateSearch = function(self, t)
		if t == true then
			Stuffing:SearchUpdate(self:GetText())
		end
	end

	editbox:SetScript("OnEscapePressed", resetAndClear)
	editbox:SetScript("OnEnterPressed", resetAndClear)
	editbox:SetScript("OnEditFocusLost", editbox.Hide)
	editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
	editbox:SetScript("OnTextChanged", updateSearch)
	editbox:SetText(tukuilocal.bags_search)


	local detail = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	detail:SetPoint("TOPLEFT", f, TukuiDB.Scale(12), TukuiDB.Scale(-10))
	detail:SetPoint("RIGHT", TukuiDB.Scale(-(16 + 24)), 0)
	detail:SetJustifyH("LEFT")
	detail:SetText("|cff9999ff" .. "Search")
	editbox:SetAllPoints(detail)

	local gold = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	gold:SetJustifyH("RIGHT")
	gold:SetPoint("RIGHT", f.b_close, "LEFT", TukuiDB.Scale(-3), 0)

	f:SetScript("OnEvent", function (self, e)
		self.gold:SetText(GetMoneyString(GetMoney(), 12))
	end)

	f:RegisterEvent("PLAYER_MONEY")
	f:RegisterEvent("PLAYER_LOGIN")
	f:RegisterEvent("PLAYER_TRADE_MONEY")
	f:RegisterEvent("TRADE_MONEY_CHANGED")

	local OpenEditbox = function(self)
		self:GetParent().detail:Hide()
		self:GetParent().gold:Hide()
		self:GetParent().editbox:Show()
		self:GetParent().editbox:HighlightText()
	end

	local button = CreateFrame("Button", nil, f)
	button:EnableMouse(1)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetAllPoints(detail)
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			OpenEditbox(self)
		else
			if self:GetParent().editbox:IsShown() then
				self:GetParent().editbox:Hide()
				self:GetParent().editbox:ClearFocus()
				self:GetParent().detail:Show()
				self:GetParent().gold:Show()
				Stuffing:SearchReset()
			end
		end
	end)

	local tooltip_hide = function()
		GameTooltip:Hide()
	end

	local tooltip_show = function (self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:ClearLines()
		GameTooltip:SetText(tukuilocal.bags_rightclick_search)
	end

	button:SetScript("OnEnter", tooltip_show)
	button:SetScript("OnLeave", tooltip_hide)

	f.editbox = editbox
	f.detail = detail
	f.button = button
	f.gold = gold
	self.frame = f
	f:Hide()
end


function Stuffing:Layout(lb)
	local slots = 0
	local rows = 0
	local off = 26
	local cols
	local f
	local bs

	if lb then
		bs = bags_BANK
		if TukuiCF["panels"].tinfowidth >= 405 then
			cols = 11
		elseif TukuiCF["panels"].tinfowidth >= 370 and TukuiCF["panels"].tinfowidth < 405 then
			cols = 10
		elseif TukuiCF["panels"].tinfowidth >= 335 and TukuiCF["panels"].tinfowidth < 370 then
			cols = 9
		else
			cols = 8
		end
		f = self.bankFrame
	else
		bs = bags_BACKPACK
		if TukuiCF["panels"].tinfowidth >= 405 then
			cols = 11
		elseif TukuiCF["panels"].tinfowidth >= 370 and TukuiCF["panels"].tinfowidth < 405 then
			cols = 10
		elseif TukuiCF["panels"].tinfowidth >= 335 and TukuiCF["panels"].tinfowidth < 370 then
			cols = 9
		else
			cols = 8
		end
		f = self.frame

		f.gold:SetText(GetMoneyString(GetMoney(), 12))
		f.editbox:SetFont(BAGSFONT, 12)
		f.detail:SetFont(BAGSFONT, 12)
		f.gold:SetFont(BAGSFONT, 12)

		f.detail:ClearAllPoints()
		f.detail:SetPoint("TOPLEFT", f, TukuiDB.Scale(12), TukuiDB.Scale(-10))
		f.detail:SetPoint("RIGHT", TukuiDB.Scale(-(16 + 24)), 0)
	end

	f:SetClampedToScreen(1)
	f:SetBackdrop({
		bgFile = TukuiCF["media"].blank,
		edgeFile = TukuiCF["media"].blank,
		edgeSize = TukuiDB.mult,
		insets = {left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
	})
	f:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))


	-- bag frame stuff
	local fb = f.bags_frame
	if bag_bars == 1 then
		fb:SetClampedToScreen(1)
		fb:SetBackdrop({
			bgFile = TukuiCF["media"].blank,
			edgeFile = TukuiCF["media"].blank,
			edgeSize = TukuiDB.mult,
			insets = {left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
		})
		fb:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
		fb:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))

		local bsize = 30
		if lb then bsize = 37 end

		local w = 2 * 12
		w = w + ((#bs - 1) * bsize)
		w = w + (12 * (#bs - 2))

		fb:SetHeight(TukuiDB.Scale(2 * 12 + bsize))
		fb:SetWidth(TukuiDB.Scale(w))
		fb:Show()
	else
		fb:Hide()
	end



	local idx = 0
	for _, v in ipairs(bs) do
		if (not lb and v <= 3 ) or (lb and v ~= -1) then
			local bsize = 30
			if lb then bsize = 37 end

			local b = self:BagFrameSlotNew(v, fb)

			local xoff = 12

			xoff = xoff + (idx * bsize) -- 31)
			xoff = xoff + (idx * 4)

			b.frame:ClearAllPoints()
			b.frame:SetPoint("LEFT", fb, "LEFT", TukuiDB.Scale(xoff), 0)
			b.frame:Show()


			idx = idx + 1
		end
	end


	for _, i in ipairs(bs) do
		local x = GetContainerNumSlots(i)
		if x > 0 then
			if not self.bags[i] then
				self.bags[i] = self:BagNew(i, f)
			end

			slots = slots + GetContainerNumSlots(i)
		end
	end


	rows = floor (slots / cols)
	if (slots % cols) ~= 0 then
		rows = rows + 1
	end

	f:SetWidth(TukuiDB.Scale(cols * 31 + (cols - 1) * 4 + 12 * 2)) 
	f:SetHeight(TukuiDB.Scale(rows * 31 + (rows - 1) * 4 + off + 12 * 2))


	local idx = 0
	for _, i in ipairs(bs) do
		local bag_cnt = GetContainerNumSlots(i)

		if bag_cnt > 0 then
			self.bags[i] = self:BagNew(i, f)
			local bagType = self.bags[i].bagType

			self.bags[i]:Show()
			for j = 1, bag_cnt do
				local b, isnew = self:SlotNew (i, j)
				local xoff
				local yoff
				local x = (idx % cols)
				local y = floor(idx / cols)

				if isnew then
					table.insert(self.buttons, idx + 1, b)
				end

				xoff = 12 + (x * 31)
						+ (x * 4)

				yoff = off + 12 + (y * 31)
						+ ((y - 1) * 4)
				yoff = yoff * -1

				b.frame:ClearAllPoints()
				b.frame:SetPoint("TOPLEFT", f, "TOPLEFT", TukuiDB.Scale(xoff), TukuiDB.Scale(yoff))
				b.frame:SetHeight(TukuiDB.Scale(31))
				b.frame:SetWidth(TukuiDB.Scale(31))
				b.frame:SetPushedTexture("")
				b.frame:SetNormalTexture("")
				b.frame:Show()
				TukuiDB.SetTemplate(b.frame)
				TukuiDB.StyleButton(b.frame)
				
				self:SlotUpdate(b)
				
				local iconTex = _G[b.frame:GetName() .. "IconTexture"]
				iconTex:SetTexCoord(.08, .92, .08, .92)
				iconTex:SetPoint("TOPLEFT", b.frame, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				iconTex:SetPoint("BOTTOMRIGHT", b.frame, TukuiDB.Scale(-2), TukuiDB.Scale(2))

				iconTex:Show()
				b.iconTex = iconTex
				
				idx = idx + 1
			end
		end
	end
end


function Stuffing:SetBagsForSorting(c)
	Stuffing_Open()

	self.sortBags = {}

	local cmd = ((c == nil or c == "") and {"d"} or {strsplit("/", c)})

	for _, s in ipairs(cmd) do
		if s == "c" then
			self.sortBags = {}
		elseif s == "d" then
			if not self.bankFrame or not self.bankFrame:IsShown() then
				for _, i in ipairs(bags_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			else
				for _, i in ipairs(bags_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		elseif s == "p" then
			if not self.bankFrame or not self.bankFrame:IsShown() then
				for _, i in ipairs(bags_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			else
				for _, i in ipairs(bags_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		else
			if tonumber(s) == nil then
				Print(string.format(L["Error: don't know what \"%s\" means."], s))
			end

			table.insert(self.sortBags, tonumber(s))
		end
	end

	local bids = tukuilocal.bags_bids
	for _, i in ipairs(self.sortBags) do
		bids = bids .. i .. " "
	end

	Print(bids)
end


-- slash command handler
local function StuffingSlashCmd(Cmd)
	local cmd, args = strsplit(" ", Cmd:lower(), 2)

	if cmd == "config" then
		Stuffing_OpenConfig()
	elseif cmd == "sort" then
		Stuffing_Sort(args)
	elseif cmd == "psort" then
		Stuffing_Sort("c/p")
	elseif cmd == "stack" then
		Stuffing:SetBagsForSorting(args)
		Stuffing:Restack()
	elseif cmd == "test" then
		Stuffing:SetBagsForSorting(args)
	elseif cmd == "purchase" then
		-- XXX
		if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
			local cnt, full = GetNumBankSlots()
			if full then
				Print(tukuilocal.bags_noslots)
				return
			end

			if args == "yes" then
				PurchaseSlot()
				return
			end

			Print(string.format(tukuilocal.bags_costs, GetBankSlotCost() / 10000))
			Print(tukuilocal.bags_buyslots)
		else
			Print(tukuilocal.bags_openbank)
		end
	else
		Print("sort - " .. tukuilocal.bags_sort)
		Print("stack - " .. tukuilocal.bags_stack)
		Print("purchase - " .. tukuilocal.bags_buybankslot)
	end
end


function Stuffing:ADDON_LOADED(addon)
	if addon ~= "Tukui" then
		return nil
	end

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("ITEM_LOCK_CHANGED")

	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

	self:RegisterEvent("BAG_CLOSED")

	SlashCmdList["STUFFING"] = StuffingSlashCmd
	SLASH_STUFFING1 = "/bags"

	self:InitBags()
	
	tinsert(UISpecialFrames,"StuffingFrameBags")

	ToggleBackpack = Stuffing_Toggle
	OpenAllBags = Stuffing_Toggle
	OpenBackpack = Stuffing_Toggle
	CloseBackpack = Stuffing_Close
	CloseAllBags = Stuffing_Close

	BankFrame:UnregisterAllEvents()
end

function Stuffing:PLAYER_ENTERING_WORLD()
	-- please don't do anything after 1 player_entering_world event.
	Stuffing:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	-- hooking and setting key ring bag
	-- this is just a reskin of Blizzard key bag to fit Tukui
	-- hooking OnShow because sometime key max slot changes.
	ContainerFrame1:HookScript("OnShow", function(self)
		local keybackdrop = CreateFrame("Frame", nil, self)
		keybackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(9), TukuiDB.Scale(-40))
		keybackdrop:SetPoint("BOTTOMLEFT", 0, 0)
		keybackdrop:SetSize(TukuiDB.Scale(179),TukuiDB.Scale(215))
		TukuiDB.SetTemplate(keybackdrop)
		ContainerFrame1CloseButton:Hide()
		ContainerFrame1Portrait:Hide()
		ContainerFrame1Name:Hide()
		ContainerFrame1BackgroundTop:SetAlpha(0)
		ContainerFrame1BackgroundMiddle1:SetAlpha(0)
		ContainerFrame1BackgroundMiddle2:SetAlpha(0)
		ContainerFrame1BackgroundBottom:SetAlpha(0)
		for i=1, GetKeyRingSize() do
			local slot = _G["ContainerFrame1Item"..i]
			local t = _G["ContainerFrame1Item"..i.."IconTexture"]
			slot:SetPushedTexture("")
			slot:SetNormalTexture("")
			t:SetTexCoord(.08, .92, .08, .92)
			t:SetPoint("TOPLEFT", slot, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			t:SetPoint("BOTTOMRIGHT", slot, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			TukuiDB.SetTemplate(slot)
			TukuiDB.StyleButton(slot, false)
		end
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", TukuiDB.Scale(4), TukuiDB.Scale(5))
	end)
end

function Stuffing:PLAYERBANKSLOTS_CHANGED(id)
	if id > 28 then
		for _, v in ipairs(self.bagframe_buttons) do
			if v.frame and v.frame.GetInventorySlot then

				BankFrameItemButton_Update(v.frame)
				BankFrameItemButton_UpdateLocked(v.frame)

				if not v.frame.tooltipText then
					v.frame.tooltipText = ""
				end
			end
		end
	end

	if self.bankFrame and self.bankFrame:IsShown() then
		self:BagSlotUpdate(-1)
	end
end


function Stuffing:BAG_UPDATE(id)
	self:BagSlotUpdate(id)
end


function Stuffing:ITEM_LOCK_CHANGED(bag, slot)
	if slot == nil then
		return
	end

	for _, v in ipairs(self.buttons) do
		if v.bag == bag and v.slot == slot then
			self:SlotUpdate(v)
			break
		end
	end
end


function Stuffing:BANKFRAME_OPENED()
	if not self.bankFrame then
		self:InitBank()
	end

	self:Layout(true)
	for _, x in ipairs(bags_BANK) do
		self:BagSlotUpdate(x)
	end
	self.bankFrame:Show()
	Stuffing_Open()
end


function Stuffing:BANKFRAME_CLOSED()
	if not self.bankFrame then
		return
	end

	self.bankFrame:Hide()
end


function Stuffing:BAG_CLOSED(id)
	local b = self.bags[id]
	if b then
		table.remove(self.bags, id)
		b:Hide()
		table.insert (trashBag, #trashBag + 1, b)
	end

	while true do
		local changed = false

		for i, v in ipairs(self.buttons) do
			if v.bag == id then
				v.frame:Hide()
				v.iconTex:Hide()

				table.insert (trashButton, #trashButton + 1, v.frame)
				table.remove(self.buttons, i)

				v = nil
				changed = true
			end
		end

		if not changed then
			break
		end
	end
end


function Stuffing:SortOnUpdate(e)
	if not self.elapsed then
		self.elapsed = 0
	end

	if not self.itmax then
		self.itmax = 0
	end

	self.elapsed = self.elapsed + e

	if self.elapsed < 0.1 then
		return
	end

	self.elapsed = 0
	self.itmax = self.itmax + 1

	local changed, blocked  = false, false

	if self.sortList == nil or next(self.sortList, nil) == nil then
		-- wait for all item locks to be released.
		local locks = false

		for i, v in pairs(self.buttons) do
			local _, _, l = GetContainerItemInfo(v.bag, v.slot)
			if l then
				locks = true
			else
				v.block = false
			end
		end

		if locks then
			-- something still locked. wait some more.
			return
		else
			-- all unlocked. get a new table.
			self:SetScript("OnUpdate", nil)
			self:SortBags()

			if self.sortList == nil then
				return
			end
		end
	end

	-- go through the list and move stuff if we can.
	for i, v in ipairs (self.sortList) do
		repeat
			if v.ignore then
				blocked = true
				break
			end

			if v.srcSlot.block then
				changed = true
				break
			end

			if v.dstSlot.block then
				changed = true
				break
			end

			local _, _, l1 = GetContainerItemInfo(v.dstSlot.bag, v.dstSlot.slot)
			local _, _, l2 = GetContainerItemInfo(v.srcSlot.bag, v.srcSlot.slot)

			if l1 then
				v.dstSlot.block = true
			end

			if l2 then
				v.srcSlot.block = true
			end

			if l1 or l2 then
				break
			end

			if v.sbag ~= v.dbag or v.sslot ~= v.dslot then
				if v.srcSlot.name ~= v.dstSlot.name then
					v.srcSlot.block = true
					v.dstSlot.block = true
					PickupContainerItem (v.sbag, v.sslot)
					PickupContainerItem (v.dbag, v.dslot)
					changed = true
					break
				end
			end
		until true
	end

	self.sortList = nil

	if (not changed and not blocked) or self.itmax > 250 then
		self:SetScript("OnUpdate", nil)
		self.sortList = nil
		Print (tukuilocal.bags_sortingbags)
	end
end


local function InBags(x)
	if not Stuffing.bags[x] then
		return false
	end

	for _, v in ipairs(Stuffing.sortBags) do
		if x == v then
			return true
		end
	end
	return false
end


function Stuffing:SortBags()
	local bs = self.sortBags
	if #bs < 1 then
		Print (tukuilocal.bags_nothingsort)
		return
	end

	local st = {}
	local bank = false

	Stuffing_Open()

	for i, v in pairs(self.buttons) do
		if InBags(v.bag) then
			self:SlotUpdate(v)

			if v.name then
				local tex, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
				local n, _, q, iL, rL, c1, c2, _, Sl = GetItemInfo(clink)
				table.insert(st, {
					srcSlot = v,
					sslot = v.slot,
					sbag = v.bag,
					--sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. i,
					--sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. (#self.buttons - i),
					sort = q .. c1 .. c2 .. rL .. n .. iL .. Sl .. (#self.buttons - i),
					--sort = q .. (#self.buttons - i) .. n,
				})
			end
		end
	end

	-- sort them
	table.sort (st, function(a, b)
		return a.sort > b.sort
	end)

	-- for each button we want to sort, get a destination button
	local st_idx = #bs
	local dbag = bs[st_idx]
	local dslot = GetContainerNumSlots(dbag)
 
	for i, v in ipairs (st) do
		v.dbag = dbag
		v.dslot = dslot
		v.dstSlot = self:SlotNew(dbag, dslot)
 
		dslot = dslot - 1
 
		if dslot == 0 then
			while true do
				st_idx = st_idx - 1
 
				if st_idx < 0 then
					break
				end
 
				dbag = bs[st_idx]
 
				if Stuffing:BagType(dbag) == ST_NORMAL or dbag < 1 then
					break
				end
			end
 
			dslot = GetContainerNumSlots(dbag)
		end
	end

	-- throw various stuff out of the search list
	local changed = true
	while changed do
		changed = false
		-- XXX why doesn't this remove all x->x moves in one pass?

		for i, v in ipairs (st) do

			-- source is same as destination
			if (v.sslot == v.dslot) and (v.sbag == v.dbag) then
				table.remove (st, i)
				changed = true
			end
		end
	end

	-- kick off moving of stuff, if needed.
	if st == nil or next(st, nil) == nil then
		Print(tukuilocal.bags_sortingbags)
		self:SetScript("OnUpdate", nil)
	else
		self.sortList = st
		self:SetScript("OnUpdate", Stuffing.SortOnUpdate)
	end
end


function Stuffing:RestackOnUpdate(e)
	if not self.elapsed then
		self.elapsed = 0
	end

	self.elapsed = self.elapsed + e

	if self.elapsed < 0.1 then
		return
	end

	self.elapsed = 0
	self:Restack()
end


function Stuffing:Restack()
	local st = {}

	Stuffing_Open()

	for i, v in pairs(self.buttons) do
		if InBags(v.bag) then
			local tex, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
			if clink then
				local n, _, _, _, _, _, _, s = GetItemInfo(clink)

				if cnt ~= s then
					if not st[n] then
						st[n] = {{
							item = v,
							size = cnt,
							max = s
						}}
					else
						table.insert(st[n], {
							item = v,
							size = cnt,
							max = s
						})
					end
				end
			end
		end
	end

	local did_restack = false

	for i, v in pairs(st) do
		if #v > 1 then
			for j = 2, #v, 2 do
				local a, b = v[j - 1], v[j]
				local _, _, l1 = GetContainerItemInfo(a.item.bag, a.item.slot)
				local _, _, l2 = GetContainerItemInfo(b.item.bag, b.item.slot)

				if l1 or l2 then
					did_restack = true
				else
					PickupContainerItem (a.item.bag, a.item.slot)
					PickupContainerItem (b.item.bag, b.item.slot)
					did_restack = true
				end
			end
		end
	end

	if did_restack then
		self:SetScript("OnUpdate", Stuffing.RestackOnUpdate)
	else
		self:SetScript("OnUpdate", nil)
		Print (tukuilocal.bags_stackend)
	end
end

function Stuffing.Menu(self, level)
	if not level then
		return
	end

	local info = self.info

	wipe(info)

	if level ~= 1 then
		return
	end

	wipe(info)
	info.text = tukuilocal.bags_sortmenu
	info.notCheckable = 1
	info.func = function()
		Stuffing_Sort("d")
	end
	UIDropDownMenu_AddButton(info, level)
	
	wipe(info)
	info.text = tukuilocal.bags_sortspecial
	info.notCheckable = 1
	info.func = function()
		Stuffing_Sort("c/p")
	end
	UIDropDownMenu_AddButton(info, level)

	wipe(info)
	info.text = tukuilocal.bags_stackmenu
	info.notCheckable = 1
	info.func = function()
		Stuffing:SetBagsForSorting("d")
		Stuffing:Restack()
	end
	UIDropDownMenu_AddButton(info, level)
	
	wipe(info)
	info.text = tukuilocal.bags_stackspecial
	info.notCheckable = 1
	info.func = function()
		Stuffing:SetBagsForSorting("c/p")
		Stuffing:Restack()
	end
	UIDropDownMenu_AddButton(info, level)

	wipe(info)
	info.text = tukuilocal.bags_showbags
	info.checked = function()
		return bag_bars == 1
	end

	info.func = function()
		if bag_bars == 1 then
			bag_bars = 0
		else
			bag_bars = 1
		end
		Stuffing:Layout()
		if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
			Stuffing:Layout(true)
		end

	end
	UIDropDownMenu_AddButton(info, level)

	wipe(info)
	info.disabled = nil
	info.notCheckable = 1
	info.text = CLOSE
	info.func = self.HideMenu
	info.tooltipTitle = CLOSE
	UIDropDownMenu_AddButton(info, level)
end