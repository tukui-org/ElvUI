local E, L, DF = unpack(select(2, ...)); --Engine
local TT = E:NewModule('Tooltip', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

local _G = getfenv(0)
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
local gsub, find, format = string.gsub, string.find, string.format
local GameTooltips = {
	GameTooltip,
	ItemRefTooltip,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	ShoppingTooltip1,
	ShoppingTooltip2,ShoppingTooltip3,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3
}

local linkTypes = {
	item = true, 
	enchant = true, 
	spell = true, 
	quest = true, 
	unit = true, 
	talent = true, 
	achievement = true, 
	glyph = true
}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}

function TT:SetStatusBarAnchor(pos)
	GameTooltipStatusBar:ClearAllPoints()
	
	if pos == 'BOTTOM' then
		GameTooltipStatusBar:Point("TOPLEFT", GameTooltipStatusBar:GetParent(), "BOTTOMLEFT", 2, -5)
		GameTooltipStatusBar:Point("TOPRIGHT", GameTooltipStatusBar:GetParent(), "BOTTOMRIGHT", -2, -5)			
	else	
		GameTooltipStatusBar:Point("BOTTOMLEFT", GameTooltipStatusBar:GetParent(), "TOPLEFT", 2, 5)
		GameTooltipStatusBar:Point("BOTTOMRIGHT", GameTooltipStatusBar:GetParent(), "TOPRIGHT", -2, 5)			
	end
	
	if not GameTooltipStatusBar.text then return end
	GameTooltipStatusBar.text:ClearAllPoints()
	
	if pos == 'BOTTOM' then
		GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, -3)
	else
		GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, 3)	
	end
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if self.db.anchor == 'CURSOR' then
		tt:SetOwner(parent, "ANCHOR_CURSOR")	
		
		if InCombatLockdown() and E.db.tooltip.combathide then
			tt:Hide()
		else		
			TT:SetStatusBarAnchor('TOP')
		end
	elseif self.db.anchor == 'SMART' then
		tt:SetOwner(parent, "ANCHOR_NONE")
		
		if InCombatLockdown() and E.db.tooltip.combathide then
			tt:Hide()
		else
			tt:ClearAllPoints()
			
			if BagsFrame and BagsFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', BagsFrame, 'TOPRIGHT', 0, 18)	
			elseif RightChatPanel:GetAlpha() == 1 then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)		
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
			
			TT:SetStatusBarAnchor('BOTTOM')
		end
	else
		tt:SetOwner(parent, "ANCHOR_NONE")
		
		if InCombatLockdown() and E.db.tooltip.combathide then
			tt:Hide()
		else
			tt:ClearAllPoints()
			
			local point = E:GetScreenQuadrant(TooltipMover)
			if point == "TOPLEFT" then
				tt:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, -4)
			elseif point == "TOPRIGHT" then
				tt:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, -4)
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				tt:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, 18)
			else
				tt:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, 18)
			end			
			
			TT:SetStatusBarAnchor('BOTTOM')
		end	
	end
end

function TT:GameTooltip_ShowCompareItem(tt, shift)
	if ( not tt ) then
		tt = GameTooltip;
	end
	local item, link = tt:GetItem();
	if ( not link ) then
		return;
	end
	
	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(tt.shoppingTooltips);

	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local side = "left";
	if ( shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, tt) ) then
		item1 = true;
	end
	if ( shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, tt) ) then
		item2 = true;
	end
	if ( shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, tt) ) then
		item3 = true;
	end

	-- find correct side
	local rightDist = 0;
	local leftPos = tt:GetLeft();
	local rightPos = tt:GetRight();
	if ( not rightPos ) then
		rightPos = 0;
	end
	if ( not leftPos ) then
		leftPos = 0;
	end

	rightDist = GetScreenWidth() - rightPos;

	if (leftPos and (rightDist < leftPos)) then
		side = "left";
	else
		side = "right";
	end

	-- see if we should slide the tooltip
	if ( tt:GetAnchorType() and tt:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
		local totalWidth = 0;
		if ( item1  ) then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth();
		end
		if ( item2  ) then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth();
		end
		if ( item3  ) then
			totalWidth = totalWidth + shoppingTooltip3:GetWidth();
		end

		if ( (side == "left") and (totalWidth > leftPos) ) then
			tt:SetAnchorType(tt:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			tt:SetAnchorType(tt:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	-- anchor the compare tooltips
	if ( item3 ) then
		shoppingTooltip3:SetOwner(tt, "ANCHOR_NONE");
		shoppingTooltip3:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip3:Point("TOPRIGHT", tt, "TOPLEFT", -2, -10);
		else
			shoppingTooltip3:Point("TOPLEFT", tt, "TOPRIGHT", 2, -10);
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, tt);
		shoppingTooltip3:Show();
	end
	
	if ( item1 ) then
		if( item3 ) then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE");
		else
			shoppingTooltip1:SetOwner(tt, "ANCHOR_NONE");
		end
		shoppingTooltip1:ClearAllPoints();
		if ( side and side == "left" ) then
			if( item3 ) then
				shoppingTooltip1:Point("TOPRIGHT", shoppingTooltip3, "TOPLEFT", -2, 0);
			else
				shoppingTooltip1:Point("TOPRIGHT", tt, "TOPLEFT", -2, -10);
			end
		else
			if( item3 ) then
				shoppingTooltip1:Point("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 2, 0);
			else
				shoppingTooltip1:Point("TOPLEFT", tt, "TOPRIGHT", 2, -10);
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, tt);
		shoppingTooltip1:Show();

		if ( item2 ) then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE");
			shoppingTooltip2:ClearAllPoints();
			if ( side and side == "left" ) then
				shoppingTooltip2:Point("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -2, 0);
			else
				shoppingTooltip2:Point("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 2, 0);
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, tt);
			shoppingTooltip2:Show();
		end
	end
end

function TT:Colorize(tt)
	local GMF = GetMouseFocus()
	local unit = (select(2, tt:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	
	local reaction = unit and UnitReaction(unit, "player")
	local player = unit and UnitIsPlayer(unit)
	local tapped = unit and UnitIsTapped(unit)
	local tappedbyme = unit and UnitIsTappedByPlayer(unit)
	local connected = unit and UnitIsConnected(unit)
	local dead = unit and UnitIsDead(unit)
	local r, g, b;

	if (reaction) and (tapped and not tappedbyme or not connected or dead) then
		r, g, b = 0.55, 0.57, 0.61
		tt:SetBackdropBorderColor(r, g, b)
		GameTooltipStatusBar.backdrop:SetBackdropBorderColor(r, g, b)
		GameTooltipStatusBar:ColorBar(r, g, b)
	elseif player then
		local class = select(2, UnitClass(unit))
		local color = RAID_CLASS_COLORS[class]
		
		tt:SetBackdropBorderColor(color.r, color.g, color.b)
		GameTooltipStatusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		GameTooltipStatusBar:ColorBar(color.r, color.g, color.b)
	elseif reaction then
		local color = FACTION_BAR_COLORS[reaction]
		tt:SetBackdropBorderColor(color.r, color.g, color.b)
		GameTooltipStatusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		GameTooltipStatusBar:ColorBar(color.r, color.g, color.b)
	else
		local _, link = tt:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			tt:SetBackdropBorderColor(r, g, b)
		else
			tt:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			GameTooltipStatusBar.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			GameTooltipStatusBar:ColorBar(unpack(E["media"].bordercolor))	
		end
	end	
	
	tt.needRefresh = true
end

function TT:SetStyle(tt)
	if not tt.backdropTexture then
		tt:SetTemplate("Transparent")
		tt:SetClampedToScreen(true)
	end
	
	tt:SetBackdropBorderColor(unpack(E.media.bordercolor))
	tt:SetBackdropColor(unpack(E.media.backdropfadecolor))
	self:Colorize(tt)
end

function TT:ADDON_LOADED(event, addon)
	if addon == 'Blizzard_DebugTools' then
		FrameStackTooltip:HookScript("OnShow", function(self)
			local noscalemult = E.mult * E.db["core"].uiscale
			self:SetBackdrop({
			  bgFile = E["media"].blankTex, 
			  edgeFile = E["media"].blankTex, 
			  tile = false, tileSize = 0, edgeSize = noscalemult, 
			  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
			})
			self:SetBackdropColor(unpack(E["media"].backdropfadecolor))
			self:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end)
		
		EventTraceTooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent")
		end)		
		
		self.debugloaded = true
		self:UnregisterEvent('ADDON_LOADED')
	end
end

function TT:PLAYER_ENTERING_WORLD()
	if not self.initialhook then
		for _, tt in pairs(GameTooltips) do
			self:HookScript(tt, 'OnShow', 'SetStyle')
		end
		
		self:HookScript(ItemRefTooltip, "OnTooltipSetItem", 'SetStyle')
		FriendsTooltip:SetTemplate("Transparent")
		
		if IsAddOnLoaded('Blizzard_DebugTools') and not self.debugloaded then
			self:ADDON_LOADED('ADDON_LOADED', 'Blizzard_DebugTools')
		end
		
		self.initialhook = true
	end
end

-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {};
local token

for class, color in next, RAID_CLASS_COLORS do
	ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r*255,color.g*255,color.b*255);
end

function TT:AddTargetedBy()
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	if (numParty > 0 or numRaid > 0) then
		for i = 1, (numRaid > 0 and numRaid or numParty) do
			local unit = (numRaid > 0 and "raid"..i or "party"..i);
			if (UnitIsUnit(unit.."target",token)) and (not UnitIsUnit(unit,"player")) then
				local _, class = UnitClass(unit);
				targetedList[#targetedList + 1] = ClassColors[class];
				targetedList[#targetedList + 1] = UnitName(unit);
				targetedList[#targetedList + 1] = "|r, ";
			end
		end
		if (#targetedList > 0) then
			targetedList[#targetedList] = nil;
			GameTooltip:AddLine(" ",nil,nil,nil,1);
			local line = _G["GameTooltipTextLeft"..GameTooltip:NumLines()];
			if not line then return end
			line:SetFormattedText(L['Targeted By:'].." (|cffffffff%d|r): %s",(#targetedList + 1) / 3,table.concat(targetedList));
			wipe(targetedList);
		end
	end
end

local SlotName = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand","Ranged","Ammo"
}

function TT:GetItemLvL(unit)
	local total, item = 0, 0

	for i in pairs(SlotName) do
		local slot = GetInventoryItemLink(unit, GetInventorySlotInfo(SlotName[i].."Slot"))
		if (slot ~= nil) then
			item = item + 1
			total = total + select(4, GetItemInfo(slot))
		end
	end
	if (total < 1 or item < 1) then
		return 0
	end
	
	return floor(total / item);
end


function TT:GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end
		return E:RGBToHex(color.r, color.g, color.b)
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end
		return E:RGBToHex(color.r, color.g, color.b)	
	end
end

function TT:GameTooltip_OnTooltipSetUnit(tt)
	local lines = tt:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, tt:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	local owner = tt:GetOwner()
	
	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end

	if not unit then tt:Hide() return end

	if (owner ~= UIParent) and E.db.tooltip.ufhide then tt:Hide() return end
	
	if (UnitIsUnit(unit,"mouseover")) then
		unit = "mouseover"
	end

	local race = UnitRace(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)

	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = TT:GetColor(unit)	
	if not color then color = "|CFFFFFFFF" end
	GameTooltipTextLeft1:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")
	
	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			tt:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			tt:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guildName then
			if UnitIsInMyGuild(unit) then
				GameTooltipTextLeft2:SetText("<"..E["media"].hexvaluecolor..guildName.."|r> ["..E.ValColor..guildRankName.."|r]")
			else
				GameTooltipTextLeft2:SetText("<|cff00ff10"..guildName.."|r> [|cff00ff10"..guildRankName.."|r]")
			end
			offset = offset + 1
		end

		for i= offset, lines do
			
			if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and (_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level > 0 and level or "??", race, color, class.."|r")
				break
			end
		end
	else
		for i = 2, lines do			
			if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and ((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level > 0 and level or "?? ", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	for i = 1, lines do
		local line = _G["GameTooltipTextLeft"..i]
		if line and line:GetText() and line:GetText() == PVP_ENABLED then
			line:SetText()
			break
		end
	end
	
	if IsShiftKeyDown() and (unit and CanInspect(unit)) then
		local isInspectOpen = (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown())
		if ((unit) and (CanInspect(unit)) and (not isInspectOpen)) then
			NotifyInspect(unit)
			
			local ilvl = TT:GetItemLvL(unit)
			
			ClearInspectPlayer(unit)
			
			if ilvl > 1 then
				GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", "|cffFFFFFF"..ilvl.."|r")
				GameTooltip:Show()
			end
		end
	end	

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex = TT:GetColor(unit.."target")
		if not hex then hex = "|cffFFFFFF" end
		GameTooltip:AddDoubleLine(TARGET..":", hex..UnitName(unit.."target").."|r")
	end
	
	if E.db.tooltip.whostarget then token = unit TT:AddTargetedBy() end
end

function TT:GameTooltipStatusBar_OnValueChanged(tt, value)
	if not value then return end
	local min, max = tt:GetMinMaxValues()
	
	if (value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()
	
	-- fix target of target returning nil
	if (not unit) then
		local GMF = GetMouseFocus()
		unit = GMF and GMF:GetAttribute("unit")
	end

	if tt.text then
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			tt.text:Show()
			local hp = E:ShortValue(min).." / "..E:ShortValue(max)
			if UnitIsDeadOrGhost(unit) then
				tt.text:SetText(DEAD)
			else
				tt.text:SetText(hp)
			end
		else
			tt.text:Hide()
		end
	end
end

function TT:GameTooltip_OnTooltipCleared(tt)
	tt.itemcleared = nil
end

function TT:GameTooltip_OnUpdate(tt)
	if tt.needRefresh and tt:GetAnchorType() == 'ANCHOR_CURSOR' and E.db.tooltip.anchor ~= 'CURSOR' then
		tt:SetBackdropColor(unpack(E["media"].backdropfadecolor))
		tt:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		tt.needRefresh = nil
	end
end

function TT:GameTooltip_OnTooltipSetItem(tt)
	if not tt.itemcleared then
		local item, link = tt:GetItem()
		local num = GetItemCount(link)
		local left = ""
		local right = ""
		
		if link ~= nil then
			left = "|cFFCA3C3C"..ID.."|r "..link:match(":(%w+)")
		end
		
		if num > 1  then
			right = "|cFFCA3C3C"..L['Count'].."|r "..num
		end
		
		if left ~= "" or right ~= "" then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end
		
		tt.itemcleared = true
	end
end

function TT:Initialize()
	self.db = E.db["tooltip"]
	if self.db.enable ~= true then return end
	E.Tooltip = TT

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Height(5)
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltipStatusBar:GetParent(), "BOTTOMLEFT", 2, -5)
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltipStatusBar:GetParent(), "BOTTOMRIGHT", -2, -5)
	GameTooltipStatusBar:SetStatusBarTexture(E["media"].normTex)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar.ColorBar = GameTooltipStatusBar.SetStatusBarColor
	GameTooltipStatusBar.SetStatusBarColor = E.noop
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, -3)
	GameTooltipStatusBar.text:FontTemplate(nil, nil, 'OUTLINE')
	
	local GameTooltipAnchor = CreateFrame('Frame', 'GameTooltipAnchor', E.UIParent)
	GameTooltipAnchor:Point('BOTTOMRIGHT', RightChatToggleButton, 'BOTTOMRIGHT')
	GameTooltipAnchor:Size(130, 20)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', 'Tooltip')
	
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('ADDON_LOADED')
	self:SecureHook('GameTooltip_SetDefaultAnchor')
	self:SecureHook('GameTooltip_ShowCompareItem')
	self:HookScript(GameTooltip, 'OnUpdate', 'GameTooltip_OnUpdate')
	self:HookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	self:HookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	self:HookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	self:HookScript(GameTooltipStatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	
	--SpellIDs
	hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
		local id = select(11,UnitBuff(...))
		if id then
			self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
			self:Show()
		end
	end)

	hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
		local id = select(11,UnitDebuff(...))
		if id then
			self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
			self:Show()
		end
	end)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
		local id = select(11,UnitAura(...))
		if id then
			self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
			self:Show()
		end
	end)

	hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
		if string.find(link,"^spell:") then
			local id = string.sub(link,7)
			ItemRefTooltip:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
			ItemRefTooltip:Show()
		end
	end)

	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		local id = select(3,self:GetSpell())
		if id then
			self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
			self:Show()
		end
	end)
	
	
	BNToastFrame:Point('TOPRIGHT', MMHolder, 'BOTTOMRIGHT', 0, -10);
	E:CreateMover(BNToastFrame, 'BNETMover', 'BNet Frame')
	BNToastFrame.SetPoint = E.noop
	BNToastFrame.ClearAllPoints = E.noop	
end

E:RegisterModule(TT:GetName())