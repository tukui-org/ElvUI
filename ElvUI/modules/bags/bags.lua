local E, L, DF = unpack(select(2, ...)); --Engine
local B = E:NewModule('Bags', 'AceHook-3.0', 'AceEvent-3.0');

local ST_NORMAL = 1
local ST_SOULBAG = 2
local ST_SPECIAL = 3
local ST_QUIVER = 4
local specialSort = false
local bagFrame, bankFrame
local BAGS_BACKPACK = {0, 1, 2, 3, 4}
local BAGS_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}
local trashParent = CreateFrame("Frame", nil, E.UIParent)
local trashButton, trashBag = {}, {}

B.buttons = {};
B.bags = {};

local function ResetAndClear(self)
	if not self then return end

	if self:GetParent().detail then
		self:GetParent().detail:Show()
	end

	self:ClearFocus()
	B:SearchReset()
end

--This one isn't for the actual bag buttons its for the buttons you can use to swap bags.
function B:BagFrameSlotNew(frame, slot)
	for _, v in ipairs(frame.buttons) do
		if v.slot == slot then
			return v, false
		end
	end

	local ret = {}
	if slot > 3 then
		ret.slot = slot
		slot = slot - 4
		ret.frame = CreateFrame("CheckButton", "ElvUIBankBag" .. slot, frame, "BankItemButtonBagTemplate")
		ret.frame:SetID(slot + 4)
		table.insert(frame.buttons, ret)

		if not ret.frame.tooltipText then
			ret.frame.tooltipText = ""
		end
	else
		--This is fucking retarded, the frame name needs to have 9 digits before the word Bag.
		ret.frame = CreateFrame("CheckButton", "ElvUIMainBag" .. slot .. "Slot", frame, "BagSlotButtonTemplate")
		ret.slot = slot
		table.insert(frame.buttons, ret)
	end

	ret.frame:HookScript("OnEnter", function()
		local bag
		for ind, val in ipairs(B.buttons) do
			if val.bagOwner == ret.slot then
				val.frame:SetAlpha(1)
				--E:Print('Matched Bag Slot: '..val.bagOwner..' to button: '..ind)
			else
				val.frame:SetAlpha(0.2)
			end
		end
	end)

	ret.frame:HookScript("OnLeave", function()
		for _, btn in ipairs(self.buttons) do
			btn.frame:SetAlpha(1)
		end
	end)

	ret.frame:SetScript('OnClick', nil)

	ret.frame:SetTemplate('Default', true)
	ret.frame:StyleButton()
	ret.frame:SetFrameLevel(ret.frame:GetFrameLevel() + 1)

	local t = _G[ret.frame:GetName().."IconTexture"]
	ret.frame:SetPushedTexture("")
	ret.frame:SetNormalTexture("")
	ret.frame:SetCheckedTexture(nil)
	t:SetTexCoord(unpack(E.TexCoords))
	t:Point("TOPLEFT", ret.frame, 2, -2)
	t:Point("BOTTOMRIGHT", ret.frame, -2, 2)

	return ret
end

local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400
local BAGTYPE_FISHING = 32768
function B:BagType(bag)
	local bagType = select(2, GetContainerNumFreeSlots(bag))

	if bagType and bit.band(bagType, BAGTYPE_FISHING) > 0 then
		return ST_FISHBAG
	elseif bagType and bit.band(bagType, BAGTYPE_PROFESSION) > 0 then
		return ST_SPECIAL
	end

	return ST_NORMAL
end

function B:BagNew(bag, f)
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
			ret = trashBag[f]
			table.remove(trashBag, f)
			ret:Show()
			ret.bagType = B:BagType(bag)
			return ret
		end
	end

	ret = CreateFrame("Frame", "ElvUIBag" .. bag, f)
	ret.bagType = B:BagType(bag)

	ret:SetID(bag)
	return ret
end

function B:SlotUpdate(b)
	local texture, count, locked = GetContainerItemInfo(b.bag, b.slot)
	local clink = GetContainerItemLink(b.bag, b.slot)

	if not b.frame.lock then
		b.frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	if b.Cooldown then
		local start, duration, enable = GetContainerItemCooldown(b.bag, b.slot)
		CooldownFrame_SetTimer(b.Cooldown, start, duration, enable)
		if ( duration > 0 and enable == 0 ) then
			SetItemButtonTextureVertexColor(b.frame, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(b.frame, 1, 1, 1);
		end
	end

	if(clink) then
		local iType
		b.name, _, b.rarity, _, _, iType = GetItemInfo(clink)

		-- color slot according to item quality
		if not b.frame.lock and b.rarity and b.rarity > 1 then
			b.frame:SetBackdropBorderColor(GetItemQualityColor(b.rarity))
		elseif GetContainerItemQuestInfo(b.bag, b.slot) then
			b.frame:SetBackdropBorderColor(1.0, 0.3, 0.3)
		end
	else
		b.name, b.rarity = nil, nil
	end

	SetItemButtonTexture(b.frame, texture)
	SetItemButtonCount(b.frame, count)
	SetItemButtonDesaturated(b.frame, locked, 0.5, 0.5, 0.5)

	b.frame:Show()
end

function B:SlotNew(bag, slot)
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

			if b == bag and s == slot then
				f = i
				break
			end
		end

		if f ~= -1 then
			ret.frame = trashButton[f]
			table.remove(trashButton, f)
		end
	end

	if not ret.frame then
		ret.frame = CreateFrame("CheckButton", "ElvUINormBag" .. bag .. "_" .. slot, self.bags[bag], tpl)
		ret.frame:StyleButton()
		ret.frame:SetTemplate('Default', true)

		local t = _G[ret.frame:GetName().."IconTexture"]
		ret.frame:SetNormalTexture(nil)
		ret.frame:SetCheckedTexture(nil)

		t:SetTexCoord(unpack(E.TexCoords))
		t:Point("TOPLEFT", ret.frame, 2, -2)
		t:Point("BOTTOMRIGHT", ret.frame, -2, 2)
	end

	ret.bag = bag
	ret.slot = slot
	ret.frame:SetID(slot)

	ret.Cooldown = _G[ret.frame:GetName() .. "Cooldown"]
	ret.Cooldown:Show()

	self:SlotUpdate(ret)

	return ret, true
end

function B:Layout(isBank)
	local slots = 0
	local rows = 0
	local offset = 26
	local cols, f, bs, bSize

	if not isBank then
		bs = BAGS_BACKPACK
		cols = (floor((E.db.core.panelWidth - 10)/370 * 10))
		f = bagFrame
		bSize = 30
	else
		bs = BAGS_BANK
		cols = (floor((E.db.core.panelWidth - 10)/370 * 10))
		f = bankFrame
		bSize = 30
	end

	if not f then return end

	local w = 0
	w = w + ((#bs - 1) * bSize)
	w = w + (12 * (#bs - 2))

	f.ContainerHolder:Height(24 + bSize)
	f.ContainerHolder:Width(w)

	--Position BagFrame Bag Icons
	local idx = 0
	local numSlots, full = GetNumBankSlots()
	for i, v in ipairs(bs) do
		if (not isBank and v <= 3 ) or (isBank and v ~= -1 and numSlots >= 1) then
			local b = B:BagFrameSlotNew(f.ContainerHolder, v)

			local xOff = 12
			xOff = xOff + (idx * bSize)
			xOff = xOff + (idx * 4)

			b.frame:ClearAllPoints()
			b.frame:Point("LEFT", f.ContainerHolder, "LEFT", xOff, 0)
			b.frame:Size(bSize)

			if isBank then
				BankFrameItemButton_Update(b.frame)
				BankFrameItemButton_UpdateLocked(b.frame)
			end

			idx = idx + 1

			if isBank and not full and i > numSlots then
				break
			end
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

	f:Width((E.db.core.panelWidth - 10))
	f:Height(rows * 31 + (rows - 1) * 4 + offset + 24)

	f.HolderFrame:SetWidth(33.5 * cols)
	f.HolderFrame:SetHeight(f:GetHeight() - 8)
	f.HolderFrame:SetPoint("BOTTOM", f, "BOTTOM")

	--Fun Part, Position Actual Bag Buttons
	local idx = 0
	for _, i in ipairs(bs) do
		local bag_cnt = GetContainerNumSlots(i)

		if bag_cnt > 0 then
			self.bags[i] = B:BagNew(i, f)
			local bagType = self.bags[i].bagType
			self.bags[i]:Show()
			for j = 1, bag_cnt do
				local b, isnew = self:SlotNew(i, j)
				local xOff
				local yOff
				local x = (idx % cols)
				local y = floor(idx / cols)

				if isnew then
					table.insert(self.buttons, idx + 1, b)
					
					if not isBank then
						b.bagOwner = i - 1
					else
						b.bagOwner = i
					end
				end

				xOff = (x * 31) + (x * 2.5)

				yOff = offset + 12 + (y * 31) + ((y - 1) * 4)
				yOff = yOff * -1

				b.frame:ClearAllPoints()
				b.frame:Point("TOPLEFT", f.HolderFrame, "TOPLEFT", xOff, yOff)
				b.frame:Size(bSize)
				b.frame.lock = false
				b.frame:SetAlpha(1)
				
				local clink = GetContainerItemLink
				if (clink and b.rarity and b.rarity > 1) then
					b.frame:SetBackdropBorderColor(GetItemQualityColor(b.rarity))
				elseif (clink and b.qitem) then
					b.frame:SetBackdropBorderColor(1.0, 0.3, 0.3)
				elseif bagType == ST_QUIVER then
					b.frame:SetBackdropBorderColor(0.8, 0.8, 0.2, 1)
					b.frame.lock = true
				elseif bagType == ST_SOULBAG then
					b.frame:SetBackdropBorderColor(0.5, 0.2, 0.2)
					b.frame.lock = true
				elseif bagType == ST_SPECIAL then
					b.frame:SetBackdropBorderColor(0.2, 0.2, 0.8)
					b.frame.lock = true
				end

				-- color profession bag slot border ~yellow
				if bagType == ST_SPECIAL then b.frame:SetBackdropBorderColor(255/255, 243/255,  82/255) b.frame.lock = true end

				idx = idx + 1
			end
		end
	end
end

function B:BagSlotUpdate(bag)
	if not self.buttons then
		return
	end

	for _, v in ipairs (self.buttons) do
		if v.bag == bag then
			self:SlotUpdate(v)
		end
	end
end

function B:Bags_OnShow()
	B:PLAYERBANKSLOTS_CHANGED(29)
	B:Layout()
end

function B:Bags_OnHide()
	if bankFrame then
		bankFrame:Hide()
	end
end

local UpdateSearch = function(self, t)
	if t == true then
		B:SearchUpdate(self:GetText(), self:GetParent())
	end
end

function B:SearchUpdate(str, frameMatch)
	str = string.lower(str)

	for _, b in ipairs(self.buttons) do
		if b.name then
			if not string.find (string.lower(b.name), str) and b.frame:GetParent():GetParent() == frameMatch then
				SetItemButtonDesaturated(b.frame, 1, 1, 1, 1)
				b.frame:SetAlpha(0.4)
			else
				SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
				b.frame:SetAlpha(1)
			end
		end
	end
end

function B:SearchReset()
	for _, b in ipairs(self.buttons) do
		SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
		b.frame:SetAlpha(1)
	end
end

local function OpenEditbox(self)
	self:GetParent().detail:Hide()
	self:GetParent().editBox:Show()
	self:GetParent().editBox:SetText(SEARCH)
	self:GetParent().editBox:HighlightText()
end


local function Tooltip_Hide(self)
	if self.backdropTexture then
		self:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	GameTooltip:Hide()
end

local function Tooltip_Show(self)
	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOP", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)

	if self.ttText2 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(self.ttText2, self.ttText2desc, 1, 1, 1)
	end

	GameTooltip:Show()

	if self.backdropTexture then
		self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

function B:CreateBagFrame(type)
	local name = type..'Frame'
	local f = CreateFrame('Button', name, E.UIParent)
	f:SetTemplate('Transparent')
	f:SetFrameStrata("DIALOG")

	if type == 'Bags' then
		f:Point('BOTTOMRIGHT', RightChatToggleButton, 'TOPRIGHT', 0, 4)
	else
		f:Point('BOTTOMLEFT', LeftChatToggleButton, 'TOPLEFT', 0, 4)
	end

	f.HolderFrame = CreateFrame("Frame", name.."HolderFrame", f)

	f.closeButton = CreateFrame('Button', name..'CloseButton', f)
	f.closeButton:Point('TOPRIGHT', -4, -4)
	f.closeButton:Size(15)
	f.closeButton:SetScript("OnEnter", Tooltip_Show)
	f.closeButton:SetScript("OnLeave", Tooltip_Hide)

	if type == 'bags' then
		f.closeButton:SetScript('OnClick', self.CloseBags)
	else
		f.closeButton:SetScript('OnClick', function() f:Hide() end)
	end
	f.closeButton:SetTemplate('Default', true)

	f.closeButton.text = f.closeButton:CreateFontString(nil, 'OVERLAY')
	f.closeButton.text:FontTemplate(nil, 10)
	f.closeButton.text:SetText('X')
	f.closeButton.text:SetJustifyH('CENTER')
	f.closeButton.text:SetPoint('CENTER')

	f.editBox = CreateFrame('EditBox', name..'EditBox', f)
	f.editBox:Hide()
	f.editBox:SetFrameLevel(f.editBox:GetFrameLevel() + 2)
	f.editBox:CreateBackdrop('Default', true)
	f.editBox:Height(15)
	f.editBox:Point('BOTTOMLEFT', f.HolderFrame, 'TOPLEFT', 2, -28)
	f.editBox:Point('BOTTOMRIGHT', f.HolderFrame, 'TOPRIGHT', -123, -28)
	f.editBox:SetAutoFocus(true)
	f.editBox:SetScript("OnEscapePressed", ResetAndClear)
	f.editBox:SetScript("OnEnterPressed", ResetAndClear)
	f.editBox:SetScript("OnEditFocusLost", f.editBox.Hide)
	f.editBox:SetScript("OnEditFocusGained", f.editBox.HighlightText)
	f.editBox:SetScript("OnTextChanged", UpdateSearch)
	f.editBox:SetText(SEARCH)
	f.editBox:FontTemplate()

	f.detail = f:CreateFontString(nil, "ARTWORK")
	f.detail:FontTemplate()
	f.detail:SetAllPoints(f.editBox)
	f.detail:SetJustifyH("LEFT")
	f.detail:SetText("|cff9999ff" .. SEARCH)

	local button = CreateFrame("Button", nil, f)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetAllPoints(f.detail)
	button.ttText = L['Click to search..']
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			OpenEditbox(self)
		else
			if self:GetParent().editBox:IsShown() then
				self:GetParent().editBox:Hide()
				self:GetParent().editBox:ClearFocus()
				self:GetParent().detail:Show()
				B:SearchReset()
			else
				OpenEditbox(self)
			end
		end
	end)

	button:SetScript("OnEnter", Tooltip_Show)
	button:SetScript("OnLeave", Tooltip_Hide)

	f.ContainerHolder = CreateFrame('Frame', name..'ContainerHolder', f)
	f.ContainerHolder:SetFrameLevel(f.ContainerHolder:GetFrameLevel() + 4)
	f.ContainerHolder:Point('BOTTOMLEFT', f, 'TOPLEFT', 0, 1)
	f.ContainerHolder:SetTemplate('Transparent')
	f.ContainerHolder.buttons = {}
	f.ContainerHolder:Hide()

	return f
end

function B:InitBags()
	local f = self:CreateBagFrame('Bags')
	f:SetScript('OnShow', self.Bags_OnShow)
	f:SetScript('OnHide', self.Bags_OnHide)

	--Gold Text
	f.goldText = f:CreateFontString(nil, 'OVERLAY')
	f.goldText:FontTemplate()
	f.goldText:Height(15)
	f.goldText:Point('BOTTOMLEFT', f.detail, 'BOTTOMRIGHT', 4, 0)
	f.goldText:Point('TOPRIGHT', f.HolderFrame, 'TOPRIGHT', -8, -10)
	f.goldText:SetJustifyH("RIGHT")
	f.goldText:SetText(GetCoinTextureString(GetMoney(), 12))

	f:SetScript("OnEvent", function(self)
		self.goldText:SetText(GetCoinTextureString(GetMoney(), 12))
	end)
	f:RegisterEvent("PLAYER_MONEY")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("PLAYER_TRADE_MONEY")
	f:RegisterEvent("TRADE_MONEY_CHANGED")

	--Sort Button
	f.sortButton = CreateFrame('Button', nil, f)
	f.sortButton:Point('TOPRIGHT', f, 'TOP', 0, -4)
	f.sortButton:Size(55, 10)
	f.sortButton:SetTemplate('Default', true)
	f.sortButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.sortButton.backdropTexture.SetVertexColor = E.noop
	f.sortButton.ttText = L['Sort Bags']
	f.sortButton.ttText2 = L['Hold Shift:']
	f.sortButton.ttText2desc = L['Sort Special']
	f.sortButton:SetScript("OnEnter", Tooltip_Show)
	f.sortButton:SetScript("OnLeave", Tooltip_Hide)
	f.sortButton:SetScript('OnClick', function() if IsShiftKeyDown() then B:Sort(f, 'c/p'); else B:Sort(f, 'd'); end end)

	--Stack Button
	f.stackButton = CreateFrame('Button', nil, f)
	f.stackButton:Point('LEFT', f.sortButton, 'RIGHT', 3, 0)
	f.stackButton:Size(55, 10)
	f.stackButton:SetTemplate('Default', true)
	f.stackButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.stackButton.backdropTexture.SetVertexColor = E.noop
	f.stackButton.ttText = L['Stack Items']
	f.stackButton.ttText2 = L['Hold Shift:']
	f.stackButton.ttText2desc = L['Stack Special']
	f.stackButton:SetScript("OnEnter", Tooltip_Show)
	f.stackButton:SetScript("OnLeave", Tooltip_Hide)
	f.stackButton:SetScript('OnClick', function() if IsShiftKeyDown() then B:SetBagsForSorting("c/p"); B:Restack(f); else B:SetBagsForSorting("d"); B:Restack(f); end end)

	--Vendor Button
	f.vendorButton = CreateFrame('Button', nil, f)
	f.vendorButton:Point('RIGHT', f.sortButton, 'LEFT', -3, 0)
	f.vendorButton:Size(55, 10)
	f.vendorButton:SetTemplate('Default', true)
	f.vendorButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.vendorButton.backdropTexture.SetVertexColor = E.noop
	f.vendorButton.ttText = L['Vendor Grays']
	f.vendorButton:SetScript("OnEnter", Tooltip_Show)
	f.vendorButton:SetScript("OnLeave", Tooltip_Hide)
	f.vendorButton:SetScript('OnClick', function() B:VendorGrays() end)

	--Bags Button
	f.bagsButton = CreateFrame('Button', nil, f)
	f.bagsButton:Point('LEFT', f.stackButton, 'RIGHT', 3, 0)
	f.bagsButton:Size(55, 10)
	f.bagsButton:SetTemplate('Default', true)
	f.bagsButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.bagsButton.backdropTexture.SetVertexColor = E.noop
	f.bagsButton.ttText = L['Toggle Bags']
	f.bagsButton:SetScript("OnEnter", Tooltip_Show)
	f.bagsButton:SetScript("OnLeave", Tooltip_Hide)
	f.bagsButton:SetScript('OnClick', function()
		ToggleFrame(f.ContainerHolder)
	end)

	tinsert(UISpecialFrames, f:GetName())

	f:Hide()
	bagFrame = f
end

function B:InitBank()
	local f = self:CreateBagFrame('Bank')
	f:SetScript('OnHide', CloseBankFrame)

	--Gold Text
	f.purchaseBagButton = CreateFrame('Button', nil, f)
	f.purchaseBagButton:Height(19)
	f.purchaseBagButton:Point('BOTTOMLEFT', f.detail, 'BOTTOMRIGHT', 18, -2)
	f.purchaseBagButton:Point('BOTTOMRIGHT', BankFrameHolderFrame, 'TOPRIGHT', -2, 0)
	f.purchaseBagButton:SetFrameLevel(f.purchaseBagButton:GetFrameLevel() + 2)
	f.purchaseBagButton:SetTemplate('Default', true)
	f.purchaseBagButton.text = f.purchaseBagButton:CreateFontString(nil, 'OVERLAY')
	f.purchaseBagButton.text:FontTemplate()
	f.purchaseBagButton.text:SetPoint('CENTER')
	f.purchaseBagButton.text:SetJustifyH('CENTER')
	f.purchaseBagButton.text:SetText(L['Purchase'])
	f.purchaseBagButton:SetScript("OnEnter", Tooltip_Show)
	f.purchaseBagButton:SetScript("OnLeave", Tooltip_Hide)
	f.purchaseBagButton:SetScript("OnClick", function()
		local _, full = GetNumBankSlots()
		if not full then
			StaticPopup_Show("BUY_BANK_SLOT")
		else
			StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
		end
	end)

	--Sort Button
	f.sortButton = CreateFrame('Button', nil, f)
	f.sortButton:Point('TOP', f, 'TOP', 0, -4)
	f.sortButton:Size(85, 10)
	f.sortButton:SetTemplate('Default', true)
	f.sortButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.sortButton.backdropTexture.SetVertexColor = E.noop
	f.sortButton.ttText = L['Sort Bags']
	f.sortButton.ttText2 = L['Hold Shift:']
	f.sortButton.ttText2desc = L['Sort Special']
	f.sortButton:SetScript("OnEnter", Tooltip_Show)
	f.sortButton:SetScript("OnLeave", Tooltip_Hide)
	f.sortButton:SetScript('OnClick', function() if IsShiftKeyDown() then B:Sort(f, 'c/p', true); else B:Sort(f, 'd', true); end end)

	--Stack Button
	f.stackButton = CreateFrame('Button', nil, f)
	f.stackButton:Point('RIGHT', f.sortButton, 'LEFT', -3, 0)
	f.stackButton:Size(85, 10)
	f.stackButton:SetTemplate('Default', true)
	f.stackButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.stackButton.backdropTexture.SetVertexColor = E.noop
	f.stackButton.ttText = L['Stack Items']
	f.stackButton.ttText2 = L['Hold Shift:']
	f.stackButton.ttText2desc = L['Stack Special']
	f.stackButton:SetScript("OnEnter", Tooltip_Show)
	f.stackButton:SetScript("OnLeave", Tooltip_Hide)
	f.stackButton:SetScript('OnClick', function() if IsShiftKeyDown() then B:SetBagsForSorting("c/p", true); B:Restack(f); else B:SetBagsForSorting("d", true); B:Restack(f); end end)

	--Bags Button
	f.bagsButton = CreateFrame('Button', nil, f)
	f.bagsButton:Point('LEFT', f.sortButton, 'RIGHT', 3, 0)
	f.bagsButton:Size(85, 10)
	f.bagsButton:SetTemplate('Default', true)
	f.bagsButton.backdropTexture:SetVertexColor(unpack(E.media.bordercolor))
	f.bagsButton.backdropTexture.SetVertexColor = E.noop
	f.bagsButton.ttText = L['Toggle Bags']
	f.bagsButton:SetScript("OnEnter", Tooltip_Show)
	f.bagsButton:SetScript("OnLeave", Tooltip_Hide)
	f.bagsButton:SetScript('OnClick', function()
		local numSlots, full = GetNumBankSlots()
		if numSlots >= 1 then
			ToggleFrame(f.ContainerHolder)
		else
			StaticPopup_Show("NO_BANK_BAGS")
		end
	end)

	bankFrame = f
end

function B:BAG_UPDATE(event, id)
	self:BagSlotUpdate(id)
end

function B:ITEM_LOCK_CHANGED(event, bag, slot)
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

function B:BANKFRAME_OPENED(event)
	if not bankFrame then
		self:InitBank()
	end

	self:Layout(true)
	for _, x in ipairs(BAGS_BANK) do
		self:BagSlotUpdate(x)
	end

	bankFrame:Show()
	self:OpenBags()
end

function B:BANKFRAME_CLOSED(event)
	if not bankFrame then return end
	bankFrame:Hide()
end

function B:PLAYERBANKSLOTS_CHANGED(event)
	for i, v in pairs(self.buttons) do
		self:SlotUpdate(v)
	end

	for _, x in ipairs(BAGS_BANK) do
		self:BagSlotUpdate(x)
	end
end

function B:GUILDBANKBAGSLOTS_CHANGED(event)
	for i, v in pairs(self.buttons) do
		self:SlotUpdate(v)
	end

	for _, x in ipairs(BAGS_BANK) do
		self:BagSlotUpdate(x)
	end
end

function B:BAG_CLOSED(event, id)
	local b = self.bags[id]
	if b then
		table.remove(self.bags, id)
		b:Hide()
		table.insert(trashBag, #trashBag + 1, b)
	end

	while true do
		local changed = false

		for i, v in ipairs(self.buttons) do
			if v.bag == id then
				v.frame:Hide()

				table.insert(trashButton, #trashButton + 1, v.frame)
				table.remove(self.buttons, i)

				v = nil
				changed = true
			end
		end

		if not changed then
			break
		end
	end

	if bagFrame:IsShown() then
		ToggleFrame(bagFrame)
		ToggleFrame(bagFrame)
	end
end

function B:CloseBags()
	if bagFrame:IsShown() then
		bagFrame:Hide()

		if bankFrame then
			bankFrame:Hide()
		end
	end
end

function B:OpenBags()
	if not bagFrame:IsShown() then
		bagFrame:Show()
	end
end

function B:ToggleBags()
	ToggleFrame(bagFrame)
end

function B:VendorGrays()
	if not MerchantFrame or not MerchantFrame:IsShown() then
		E:Print(L['You must be at a vendor.'])
		return
	end

	local c = 0
	for b=0,4 do
		for s=1,GetContainerNumSlots(b) do
			local l = GetContainerItemLink(b, s)
			if l then
				local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
				if select(3, GetItemInfo(l))==0 and p>0 then
					UseContainerItem(b, s)
					PickupMerchantItem()
					c = c+p
				end
			end
		end
	end

	if c>0 then
		local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
		E:Print(L['Vendored gray items for:'].." |cffffffff"..g..L.goldabbrev.." |cffffffff"..s..L.silverabbrev.." |cffffffff"..c..L.copperabbrev..".")
	else
		E:Print(L['No gray items to sell.'])
	end
end

function B:RestackOnUpdate(e)
	if not self.elapsed then
		self.elapsed = 0
	end

	self.elapsed = self.elapsed + e

	if self.elapsed < 0.1 then
		return
	end

	self.elapsed = 0
	B:Restack(self)
end

local function InBags(x)
	if not B.bags[x] then
		return false
	end

	for _, v in ipairs(B.sortBags) do
		if x == v then
			return true
		end
	end
	return false
end

local function BagToUse(item, bags)
	-- Get the item's family
	local itemFamily = GetItemFamily(item)

	-- If the item is a container, then the itemFamily should be 0
	local equipSlot = select(9, GetItemInfo(item))
	if equipSlot == "INVTYPE_BAG" then
		itemFamily = 0
	end

	local idx
	for i = #bags, 1, -1 do
		if not bags[i].full then
			-- Get the bag's family
			local bagFamily = select(2, GetContainerNumFreeSlots(bags[i].bag))
			if bagFamily == 0 or bit.band(itemFamily, bagFamily) > 0 then
				idx = i
				break
			end
		end
	end

	return idx
end

function B:BAG_UPDATE_COOLDOWN()
	for i, v in pairs(self.buttons) do
		self:SlotUpdate(v)
	end
end

function B:Restack(frame)
	local st = {}

	B:OpenBags()

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
		frame:SetScript("OnUpdate", B.RestackOnUpdate)
	else
		frame:SetScript("OnUpdate", nil)
	end
end

function B:SortOnUpdate(e)
	if not self.elapsed then
		self.elapsed = 0
	end

	if not B.itmax then
		B.itmax = 0
	end

	self.elapsed = self.elapsed + e

	if self.elapsed < 0.1 then
		return
	end

	self.elapsed = 0
	B.itmax = B.itmax + 1

	local changed, blocked  = false, false

	if B.sortList == nil or next(B.sortList, nil) == nil then
		-- wait for all item locks to be released.
		local locks = false

		for i, v in pairs(B.buttons) do
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
			B:SortBags(self)

			if B.sortList == nil then
				return
			end
		end
	end

	-- go through the list and move stuff if we can.
	for i, v in ipairs (B.sortList) do
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

	B.sortList = nil

	if (not changed and not blocked) or B.itmax > 250 then
		self:SetScript("OnUpdate", nil)
		B.sortList = nil
	end
end

function B:SortBags(frame)
	if InCombatLockdown() then return end;

	local bs
	if not specialSort then
		bs = self.sortBags
	else
		bs = {}
		for _, v in ipairs(self.sortBags) do
			table.insert(bs, {
				full = false,
				bag = v,
				slot = GetContainerNumSlots(v),
			})
		end
	end

	if #bs < 1 then
		return
	end

	local st = {}
	self:OpenBags()

	for i, v in pairs(self.buttons) do
		if InBags(v.bag) then
			self:SlotUpdate(v)

			if v.name then
				local tex, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
				local n, _, q, iL, rL, c1, c2, _, Sl = GetItemInfo(clink)

				local itemFamily
				if not specialSort then
					itemFamily = 0 -- It won't affect normal sorting.
				else
					if select(9,GetItemInfo(clink)) == "INVTYPE_BAG" then
						itemFamily = 0
					else
						itemFamily = GetItemFamily(clink)
					end
				end

				table.insert(st, {
					srcSlot = v,
					sslot = v.slot,
					sbag = v.bag,
					--sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. i,
					--sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. (#self.buttons - i),
					sort = itemFamily .. q .. c1 .. c2 .. rL .. n .. iL .. Sl .. (#self.buttons - i),
					--sort = q .. (#self.buttons - i) .. n,
				})
			end
		end
	end

	table.sort (st, function(a, b)
		return a.sort > b.sort
	end)

	if not specialSort then
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

					if dbag and (B:BagType(dbag) == ST_NORMAL or B:BagType(dbag) == ST_SPECIAL or dbag < 1) then
						break
					end
				end

				if dbag then
					dslot = GetContainerNumSlots(dbag)
				else
					dslot = 8
				end
			end
		end
	else -- Special sort
		local b
		for i, v in ipairs (st) do
			-- We need to determine the bag we'll place the item into. This is to prevent an endless cycle
			-- when there are different special bags in the backpack or the bank.
			b = BagToUse(GetContainerItemID(v.sbag, v.sslot), bs)
			v.dbag = bs[b].bag
			v.dslot = bs[b].slot
			v.dstSlot = self:SlotNew(bs[b].bag, bs[b].slot)

			bs[b].slot = bs[b].slot - 1
			if bs[b].slot == 0 then
				bs[b].full = true
			end
		end
	end

	local changed = true
	while changed do
		changed = false
		for i, v in ipairs (st) do
			if (v.sslot == v.dslot) and (v.sbag == v.dbag) then
				table.remove (st, i)
				changed = true
			end
		end
	end

	if st == nil or next(st, nil) == nil then
		frame:SetScript("OnUpdate", nil)
	else
		self.sortList = st
		frame:SetScript("OnUpdate", B.SortOnUpdate)
	end
end

function B:SetBagsForSorting(c, bank)
	self:OpenBags()

	self.sortBags = {}

	local cmd = ((c == nil or c == "") and {"d"} or {strsplit("/", c)})

	for _, s in ipairs(cmd) do
		if s == "c" then
			self.sortBags = {}
		elseif s == "d" then
			specialSort = false

			if not bank then
				for _, i in ipairs(BAGS_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			else
				for _, i in ipairs(BAGS_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		elseif s == "p" then
			specialSort = true

			if not bank then
				for _, i in ipairs(BAGS_BACKPACK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			else
				for _, i in ipairs(BAGS_BANK) do
					if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
						table.insert(self.sortBags, i)
					end
				end
			end
		else
			table.insert(self.sortBags, tonumber(s))
		end
	end
end

function B:Sort(frame, args, bank)
	if not args then
		args = ""
	end

	self.itmax = 0
	self:SetBagsForSorting(args, bank)
	self:SortBags(frame)
end

--Frame Anchors
hooksecurefunc("updateContainerFrameAnchors", function()
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end

	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale;
		yOffset = CONTAINER_OFFSET_Y / containerScale;
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = _G[frameName]:GetHeight();
			if ( freeScreenHeight < frameHeight ) then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
		end
		if ( leftMostPoint < leftLimit ) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end

	if ( containerScale < CONTAINER_SCALE ) then
		containerScale = CONTAINER_SCALE;
	end

	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	xOffset = CONTAINER_OFFSET_X / containerScale;
	yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;

	local bagsPerColumn = 0
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		frame:SetScale(1);
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", RightChatToggleButton, "TOPRIGHT", 2, 2);
			bagsPerColumn = bagsPerColumn + 1
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			if column > 1 then
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[(index - bagsPerColumn) - 1], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			else
				frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - bagsPerColumn], "BOTTOMLEFT", -CONTAINER_SPACING, 0 );
			end
			bagsPerColumn = 0
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);
			bagsPerColumn = bagsPerColumn + 1
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
	end
end)

function B:PLAYERBANKBAGSLOTS_CHANGED()
	B:PLAYERBANKSLOTS_CHANGED(29)
	B:Layout(true)
end

function B:Initialize()
	if not E.db.core.bags then return end
	self:InitBags()

	--Register Events
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("BAG_CLOSED")
	self:RegisterEvent('BAG_UPDATE_COOLDOWN')
	self:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED')

	self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	self:SecureHook('BankFrameItemButton_Update', 'PLAYERBANKSLOTS_CHANGED')

	--Hook onto Blizzard Functions
	self:RawHook('ToggleBackpack', 'ToggleBags', true)
	self:RawHook('ToggleBag', 'ToggleBags', true)
	self:RawHook('ToggleAllBags', 'ToggleBags', true)
	self:RawHook('OpenAllBags', 'OpenBags', true)
	self:RawHook('OpenBackpack', 'OpenBags', true)
	self:RawHook('CloseAllBags', 'CloseBags', true)
	self:RawHook('CloseBackpack', 'CloseBags', true)

	--UIPARENT_MANAGED_FRAME_POSITIONS["CONTAINER_OFFSET_X"] = nil;
	--UIPARENT_MANAGED_FRAME_POSITIONS["CONTAINER_OFFSET_Y"] = nil;

	--Stop Blizzard bank bags from functioning.
	BankFrame:UnregisterAllEvents()

	StackSplitFrame:SetFrameStrata('DIALOG')
	ToggleBackpack()
	ToggleBackpack()
end

E:RegisterModule(B:GetName())