local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

--Lua functions
local _G = _G
local unpack = unpack
local tinsert = tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
-- GLOBALS: ElvUIBags, ElvUIAssignBagDropdown

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return; end
	E:UIFrameFadeIn(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return; end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 0)
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()
	bag.IconBorder:SetAlpha(0)

	bag:StripTextures()
	bag:SetTemplate(nil, true)
	bag:StyleButton(true)
	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not ElvUIBags then return; end

	local buttonSpacing = E:Scale(E.db.bags.bagBar.spacing)
	local backdropSpacing = E:Scale(E.db.bags.bagBar.backdropSpacing)
	local bagBarSize = E:Scale(E.db.bags.bagBar.size)
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection

	local visibility = E.db.bags.bagBar.visibility
	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	RegisterStateDriver(ElvUIBags, "visibility", visibility)

	if E.db.bags.bagBar.mouseover then
		ElvUIBags:SetAlpha(0)
	else
		ElvUIBags:SetAlpha(1)
	end

	if showBackdrop then
		ElvUIBags.backdrop:Show()
	else
		ElvUIBags.backdrop:Hide()
	end

	local bdpSpacing = (showBackdrop and backdropSpacing + E.Border) or 0
	local btnSpacing = (buttonSpacing + E.Border)

	for i=1, #ElvUIBags.buttons do
		local button = ElvUIBags.buttons[i]
		local prevButton = ElvUIBags.buttons[i-1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if growthDirection == 'HORIZONTAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:SetPoint('LEFT', ElvUIBags, 'LEFT', bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint('LEFT', prevButton, 'RIGHT', btnSpacing, 0)
			end
		elseif growthDirection == 'VERTICAL' and sortDirection == 'ASCENDING' then
			if i == 1 then
				button:SetPoint('TOP', ElvUIBags, 'TOP', 0, -bdpSpacing)
			elseif prevButton then
				button:SetPoint('TOP', prevButton, 'BOTTOM', 0, -btnSpacing)
			end
		elseif growthDirection == 'HORIZONTAL' and sortDirection == 'DESCENDING' then
			if i == 1 then
				button:SetPoint('RIGHT', ElvUIBags, 'RIGHT', -bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint('RIGHT', prevButton, 'LEFT', -btnSpacing, 0)
			end
		else
			if i == 1 then
				button:SetPoint('BOTTOM', ElvUIBags, 'BOTTOM', 0, bdpSpacing)
			elseif prevButton then
				button:SetPoint('BOTTOM', prevButton, 'TOP', 0, btnSpacing)
			end
		end
		if i ~= 1 then
			button.IconBorder:SetSize(bagBarSize, bagBarSize)
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = btnSpacing * NUM_BAG_FRAMES
	local bdpDoubled = bdpSpacing * 2

	if growthDirection == 'HORIZONTAL' then
		ElvUIBags:SetWidth(btnSize + btnSpace + bdpDoubled)
		ElvUIBags:SetHeight(bagBarSize + bdpDoubled)
	else
		ElvUIBags:SetHeight(btnSize + btnSpace + bdpDoubled)
		ElvUIBags:SetWidth(bagBarSize + bdpDoubled)
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	ElvUIBags:Point('TOPRIGHT', _G.RightChatPanel, 'TOPLEFT', -4, 0)
	ElvUIBags.buttons = {}
	ElvUIBags:CreateBackdrop(E.db.bags.transparent and 'Transparent')
	ElvUIBags.backdrop:SetAllPoints()
	ElvUIBags:EnableMouse(true)
	ElvUIBags:SetScript("OnEnter", OnEnter)
	ElvUIBags:SetScript("OnLeave", OnLeave)

	_G.MainMenuBarBackpackButton:SetParent(ElvUIBags)
	_G.MainMenuBarBackpackButton.SetParent = E.dummy
	_G.MainMenuBarBackpackButton:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	_G.MainMenuBarBackpackButtonCount:ClearAllPoints()
	_G.MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", _G.MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
	_G.MainMenuBarBackpackButton:HookScript('OnEnter', OnEnter)
	_G.MainMenuBarBackpackButton:HookScript('OnLeave', OnLeave)

	tinsert(ElvUIBags.buttons, _G.MainMenuBarBackpackButton)
	B:SkinBag(_G.MainMenuBarBackpackButton)

	for i=0, NUM_BAG_FRAMES-1 do
		local b = _G["CharacterBag"..i.."Slot"]
		b:SetParent(ElvUIBags)
		b.SetParent = E.dummy
		b:HookScript('OnEnter', OnEnter)
		b:HookScript('OnLeave', OnLeave)

		B:SkinBag(b)
		tinsert(ElvUIBags.buttons, b)
	end

	--Item assignment
	for i = 1, #ElvUIBags.buttons do
		local bagButton = ElvUIBags.buttons[i]
		if i == 1 then --Backpack
			B:CreateFilterIcon(bagButton)
			bagButton:SetScript("OnClick", function(holder, button)
				if button == "RightButton" and holder.id then
					if ElvUIAssignBagDropdown then
						ElvUIAssignBagDropdown.holder = holder
						_G.ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
					end
				else
					_G.MainMenuBarBackpackButton_OnClick(holder)
				end
			end)
		else
			B:CreateFilterIcon(bagButton)
			bagButton:SetScript("OnClick", function(holder, button)
				if button == "RightButton" and holder.id then
					if ElvUIAssignBagDropdown then
						ElvUIAssignBagDropdown.holder = holder
						_G.ToggleDropDownMenu(1, nil, ElvUIAssignBagDropdown, "cursor")
					end
				else
					_G.BagSlotButton_OnClick(holder)
				end
			end)
		end

		bagButton.id = (i - 1)
	end

	--Hide and show to update assignment textures on first load
	ElvUIBags:Hide()
	ElvUIBags:Show()

	B:SizeAndPositionBagBar()
	E:CreateMover(ElvUIBags, 'BagsMover', L["Bags"], nil, nil, nil, nil, nil, 'bags,general')
end
