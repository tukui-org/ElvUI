local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TT = E:NewModule('Tooltip', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

local _G = getfenv(0)
local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
local gsub, find, format = string.gsub, string.find, string.format
local abs, floor = math.abs, math.floor

TT.InspectCache = {};
TT.lastInspectRequest = 0;

local INSPECT_DELAY = 0.2;
local INSPECT_FREQ = 2;

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

local levelAdjust = {
	["0"]=0,["1"]=8,
	["373"]=4,["374"]=8,
	["375"]=4,
	["376"]=4,
	["377"]=4,
	["379"]=4,
	["380"]=4,
	["445"]=0,["446"]=4,["447"]=8,
	["451"]=0,["452"]=8,
	["453"]=0,["454"]=4,["455"]=8,
	["456"]=0,["457"]=8,
	["458"]=0,["459"]=4,["460"]=8,["461"]=12,["462"]=16,
	["465"]=0,["466"]=4,["467"]=8,
	["476"]=0, ["479"]=0,
}


local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

function TT:IsInspectFrameOpen() 
	return (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown()); 
end

function TT:SetStatusBarAnchor(pos)
	GameTooltip.pos = pos
	GameTooltipStatusBar:ClearAllPoints()

	if pos == 'BOTTOM' then
		GameTooltipStatusBar:Point("TOPLEFT", GameTooltipStatusBar:GetParent(), "BOTTOMLEFT", E.Border, -(E.Border + 3))
		GameTooltipStatusBar:Point("TOPRIGHT", GameTooltipStatusBar:GetParent(), "BOTTOMRIGHT", -E.Border, -(E.Border + 3))			
	else	
		GameTooltipStatusBar:Point("BOTTOMLEFT", GameTooltipStatusBar:GetParent(), "TOPLEFT", E.Border, (E.Border + 3))
		GameTooltipStatusBar:Point("BOTTOMRIGHT", GameTooltipStatusBar:GetParent(), "TOPRIGHT", -E.Border, (E.Border + 3))			
	end	
	
	if GameTooltipStatusBar.text then
		GameTooltipStatusBar.text:ClearAllPoints()
		
		if pos == 'BOTTOM' then
			GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, -3)
		else
			GameTooltipStatusBar.text:Point("CENTER", GameTooltipStatusBar, 0, 3)	
		end
	end
end

function TT:GameTooltip_SetDefaultAnchor(tt, parent)
	if E.private["tooltip"].enable ~= true then return end
	if self.db.anchor == 'CURSOR' then
		if parent then
			tt:SetOwner(parent, "ANCHOR_CURSOR")	
		end
		
		if InCombatLockdown() and E.db.tooltip.combathide then
			tt:Hide()
		else		
			TT:SetStatusBarAnchor('TOP')
		end
	elseif self.db.anchor == 'SMART' then
		if parent then
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
		
		if InCombatLockdown() and E.db.tooltip.combathide then
			tt:Hide()
		else
			tt:ClearAllPoints()
			
			if ElvUI_ContainerFrame and ElvUI_ContainerFrame:IsShown() then
				tt:Point('BOTTOMRIGHT', ElvUI_ContainerFrame, 'TOPRIGHT', 0, 18)	
			elseif RightChatPanel:GetAlpha() == 1 and RightChatPanel:IsShown() then
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'TOPRIGHT', 0, 18)		
			else
				tt:Point('BOTTOMRIGHT', RightChatPanel, 'BOTTOMRIGHT', 0, 18)
			end
			
			TT:SetStatusBarAnchor('BOTTOM')
		end
	else
		if parent then
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
		
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
	local isGameTooltip = tt == GameTooltip
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
		if isGameTooltip then
			GameTooltipStatusBar.backdrop:SetBackdropBorderColor(r, g, b)
			GameTooltipStatusBar:ColorBar(r, g, b)
		end
	elseif player then
		local class = select(2, UnitClass(unit))
		if class then
			local color = RAID_CLASS_COLORS[class]
			tt:SetBackdropBorderColor(color.r, color.g, color.b)
			if isGameTooltip then
				GameTooltipStatusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
				GameTooltipStatusBar:ColorBar(color.r, color.g, color.b)
			end
		end
	elseif reaction then
		local color = FACTION_BAR_COLORS[reaction]
		tt:SetBackdropBorderColor(color.r, color.g, color.b)
		if isGameTooltip then
			GameTooltipStatusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			GameTooltipStatusBar:ColorBar(color.r, color.g, color.b)
		end
	else
		local _, link = tt:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			tt:SetBackdropBorderColor(r, g, b)
		else
			local r, g, b = unpack(E["media"].bordercolor)
			tt:SetBackdropBorderColor(r, g, b)
			if E.PixelMode then
				r, g, b = 0.3, 0.3, 0.3
			end
			
			if isGameTooltip then
				GameTooltipStatusBar.backdrop:SetBackdropBorderColor(r, g, b)
				GameTooltipStatusBar:ColorBar(r, g, b)	
			end
		end
	end	
	
	tt.needRefresh = true
end

function TT:SetStyle(tt)
	if not tt.template then
		tt:SetTemplate('Transparent')
		tt:SetClampedToScreen(true)
	end
	
	tt:SetBackdropColor(unpack(E.media.backdropfadecolor))
	self:Colorize(tt)
end

function TT:PLAYER_ENTERING_WORLD()
	if not self.initialhook then
		for _, tt in pairs(GameTooltips) do
			self:HookScript(tt, 'OnShow', 'SetStyle')
		end

		self:HookScript(ItemRefTooltip, "OnTooltipSetItem", 'SetStyle')
		FriendsTooltip:SetTemplate("Transparent")
		
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
	local numGroup = GetNumGroupMembers()
	if IsInGroup() then
		for i = 1, numGroup do
			local unit = (IsInRaid() and "raid"..i or "party"..i);
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
			local line = _G[("GameTooltipTextLeft%d"):format(GameTooltip:NumLines())];
			if not line then return end
			line:SetFormattedText("%s (|cffffffff%d|r): %s", L['Targeted By:'], (#targetedList + 1) / 3, table.concat(targetedList));
			wipe(targetedList);
		end
	end
end

local SlotName = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand"
}

function TT:GetItemLvL(unit)
	local total, item = 0, 0

	for i = 1, #SlotName do
		local slot = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(SlotName[i])))
		if (slot ~= nil) then
			local _, _, _, ilvl = GetItemInfo(slot)
			local upgrade = slot:match(":(%d+)\124h%[")
			if ilvl ~= nil then
				item = item + 1
				total = total + ilvl + (upgrade and levelAdjust[upgrade] or 0)
			end
		end
	end
	if (total < 1 or item < 1) then
		return 0
	end
	
	return floor(total / item);
end

function TT:GetTalentSpec(unit)
	local spec
	if not unit then
		spec = GetSpecialization()
	else
		spec = GetInspectSpecialization(unit)
	end
	if(spec ~= nil and spec > 0) then
		if unit ~= nil then 
			local role = GetSpecializationRoleByID(spec);
			if(role ~= nil) then
				local _, name = GetSpecializationInfoByID(spec);
				return name
			end
		else
			local _, name = GetSpecializationInfo(spec)

			return name
		end
	end
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
	
	if (UnitIsUnit(unit,"mouseover")) then
		unit = "mouseover"
	end	

	if (owner ~= UIParent) and E.db.tooltip.ufhide ~= 'NONE' then 
		local modifier = E.db.tooltip.ufhide
		
		if modifier == 'ALL' or not ((modifier == 'SHIFT' and IsShiftKeyDown()) or (modifier == 'CTRL' and IsControlKeyDown()) or (modifier == 'ALT' and IsAltKeyDown())) then
			tt:Hide() 
			return 
		end
	end
		
	local race, englishRace = UnitRace(unit)
	local isPlayer = UnitIsPlayer(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)
	local _, faction = UnitFactionGroup(unit)
	local GUID = UnitGUID(unit)
	local iLevel, talentSpec, lastUpdate = 0, "", 30
	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = TT:GetColor(unit)	
	if not color then color = "|CFFFFFFFF" end
	if E.db.tooltip.titles then
		GameTooltipTextLeft1:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and (" - %s|r"):format(realm) or "|r")
	else
		GameTooltipTextLeft1:SetFormattedText("%s%s%s", color, name, realm and realm ~= "" and (" - %s|r"):format(realm) or "|r")
	end
	
	if isPlayer then
		self.currentGUID = GUID
		self.currentName = name
		self.currentUnit = unit
		if (UnitIsUnit(unit,"player")) then
			iLevel = TT:GetItemLvL('player') or 0
			talentSpec = TT:GetTalentSpec() or ''
		else
			for index, _ in pairs(self.InspectCache) do
				local inspectCache = self.InspectCache[index]
				if inspectCache.GUID == GUID then
					iLevel = inspectCache.ItemLevel or 0
					talentSpec = inspectCache.TalentSpec or ""
					lastUpdate = inspectCache.LastUpdate and abs(inspectCache.LastUpdate - floor(GetTime())) or 30
				end
			end	
			
			-- Queue an inspect request
			if unit and (CanInspect(unit)) and (not self:IsInspectFrameOpen()) then
				local lastInspectTime = (GetTime() - self.lastInspectRequest);
				self.UpdateInspect.nextUpdate = (lastInspectTime > INSPECT_FREQ) and INSPECT_DELAY or (INSPECT_FREQ - lastInspectTime + INSPECT_DELAY);
				self.UpdateInspect:Show();
			end			
		end
		
		if UnitIsAFK(unit) then
			tt:AppendText((" %s"):format(("|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF]|r"):format(L['AFK'])))
		elseif UnitIsDND(unit) then 
			tt:AppendText((" %s"):format(("|cffFFFFFF[|r|cffE7E716%s|r|cffFFFFFF]|r"):format(L["DND"])))
		end
		
		local factionColorR, factionColorG, factionColorB = 255, 255, 255
		if englishRace == "Pandaren" and faction ~= select(2, UnitFactionGroup('player')) then
			factionColorR, factionColorG, factionColorB = 255, 0, 0
		end		
		
		local offset = 2
		if guildName then
			if E.db.tooltip.guildranks then
				if UnitIsInMyGuild(unit) then
					GameTooltipTextLeft2:SetText(("<%s%s|r> [%s%s|r]"):format(E["media"].hexvaluecolor, guildName, E["media"].hexvaluecolor, guildRankName))
				else
					GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
				end
			else
				if UnitIsInMyGuild(unit) then
					GameTooltipTextLeft2:SetText(("<%s%s|r>"):format(E["media"].hexvaluecolor, guildName))
				else
					GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
				end			
			end
			offset = offset + 1
		end
		
		if talentSpec ~= "" and E.db.tooltip.talentSpec then
			class = ('%s %s'):format(talentSpec, class)
		end
		
		for i= offset, lines do
			local line = _G[("GameTooltipTextLeft%d"):format(i)]
			if line and line:GetText() and (line:GetText():find(("(%s)"):format(PLAYER))) then
				line:SetFormattedText("|cff%02x%02x%02x%s|r |cff%02x%02x%02x%s|r %s%s", r*255, g*255, b*255, level > 0 and level or "??", factionColorR, factionColorG, factionColorB, race, color, class.."|r")
				break
			end
		end
	else
		for i = 2, lines do			
			local line = _G[("GameTooltipTextLeft%d"):format(i)]
			if line and line:GetText() and ((line:GetText():find(("(%s)"):format(PLAYER))) or crtype and line:GetText():find((LEVEL.." %d"))) then
				line:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level > 0 and level or "??", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	for i = 1, tt:NumLines() do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		while line and line:GetText() and (line:GetText() == PVP_ENABLED or line:GetText() == FACTION_HORDE or line:GetText() == FACTION_ALLIANCE) do
			if line:GetText() == PVP_ENABLED then
				local text = _G[("GameTooltipTextLeft%d"):format(i - 1)]:GetText()
				if text then
					_G[("GameTooltipTextLeft%d"):format(i - 1)]:SetText(("%s (%s)"):format(text, PVP_ENABLED))
				end
			end 		
			line:SetText()
			break
		end
	end
	
	if iLevel > 1 and IsShiftKeyDown() then
		GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", ("|cffFFFFFF%d|r"):format(iLevel))
	end	

	-- ToT line
	local totKey = ("%starget"):format(unit)
	if unit~="player" and UnitExists(totKey) then
		local hex = TT:GetColor(totKey) or "|cffFFFFFF"
		GameTooltip:AddDoubleLine(TARGET..":", ("%s%s|r"):format(hex, UnitName(totKey)))
	end
	
	if E.db.tooltip.whostarget then token = unit TT:AddTargetedBy() end

	GameTooltip:Show()
	GameTooltip.forceRefresh = true
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
		if unit and self.db.health then
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
	if (tt.needRefresh and tt:GetAnchorType() == 'ANCHOR_CURSOR' and E.db.tooltip.anchor ~= 'CURSOR') then
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
		
		if link ~= nil and TT.db.spellid then
			left = (("|cFFCA3C3C%s|r %s"):format(ID, link)):match(":(%w+)")
		end
		
		if num > 1 and self.db.count then
			right = ("|cFFCA3C3C%s|r %d"):format(L['Count'], num)
		end
		
		if left ~= "" or right ~= "" then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end
		
		tt.itemcleared = true
	end
end

function TT:INSPECT_READY(event, GUID)
	if GUID ~= self.lastGUID or self:IsInspectFrameOpen() then
		self:UnregisterEvent('INSPECT_READY');
		return
	end
	
	local ilvl = TT:GetItemLvL('mouseover')
	local talentSpec = TT:GetTalentSpec('mouseover')
	local curTime = GetTime()
	local matchFound
	for index, inspectCache in ipairs(self.InspectCache) do
		if inspectCache.GUID == GUID then
			inspectCache.ItemLevel = ilvl
			inspectCache.TalentSpec = talentSpec
			inspectCache.LastUpdate = floor(curTime)
			matchFound = true
			break
		end
	end

	if not matchFound then
		local GUIDInfo = {
			['GUID'] = GUID,
			['ItemLevel'] = ilvl,
			['TalentSpec'] = talentSpec,
			['LastUpdate'] = floor(curTime)
		}	
		self.InspectCache[#self.InspectCache + 1] = GUIDInfo
	end
	
	if #self.InspectCache > 40 then
		table.remove(self.InspectCache, 1)
	end

	GameTooltip:SetUnit('mouseover')
	
	ClearInspectPlayer();
	self:UnregisterEvent('INSPECT_READY');
end

function TT:Inspect_OnUpdate(elapsed)
	self.nextUpdate = (self.nextUpdate - elapsed);
	if (self.nextUpdate <= 0) then
		self:Hide();
		if (UnitGUID("mouseover") == TT.currentGUID) and (not TT:IsInspectFrameOpen()) then
			TT.lastGUID = TT.currentGUID
			TT.lastInspectRequest = GetTime();
			TT:RegisterEvent("INSPECT_READY");
			NotifyInspect(TT.currentUnit);
		end
	end
end

function TT:MODIFIER_STATE_CHANGED(event, key)
	if not key or not key:find('SHIFT') or not UnitExists('mouseover') then return; end

	GameTooltip:SetUnit('mouseover')
end

function TT:GameTooltip_ShowStatusBar(tt, min, max, value, text)
	local index = tt.shownStatusBars;
	local name = tt:GetName().."StatusBar"..index;
	local statusBar = _G[name];
	if statusBar and not statusBar.skinned then
		statusBar:StripTextures()
		statusBar:SetStatusBarTexture(E['media'].normTex)
		statusBar:CreateBackdrop('Default')
		statusBar.skinned = true;
	end
end

function TT:Initialize()
	self.db = E.db["tooltip"]

	BNToastFrame:Point('TOPRIGHT', MMHolder, 'BOTTOMRIGHT', 0, -10);
	E:CreateMover(BNToastFrame, 'BNETMover', L['BNet Frame'])
	hooksecurefunc(BNToastFrame, "SetPoint", function(self, point, anchor, anchorPoint, xOffset, yOffset)
		if anchor ~= BNETMover then
			BNToastFrame:ClearAllPoints()
			BNToastFrame:Point('TOPLEFT', BNETMover, 'TOPLEFT');
		end
	end)		
	
	if E.private["tooltip"].enable ~= true then return end
	E.Tooltip = TT


	GameTooltipStatusBar:Height(self.db.healthHeight)
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
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 50)
	E:CreateMover(GameTooltipAnchor, 'TooltipMover', L['Tooltip'])
	
	self:SecureHook('GameTooltip_SetDefaultAnchor')
	self:SecureHook('GameTooltip_ShowCompareItem')
	self:SecureHook('GameTooltip_ShowStatusBar')
	self:HookScript(GameTooltip, 'OnUpdate', 'GameTooltip_OnUpdate')
	self:HookScript(GameTooltip, 'OnTooltipCleared', 'GameTooltip_OnTooltipCleared')
	self:HookScript(GameTooltip, 'OnTooltipSetItem', 'GameTooltip_OnTooltipSetItem')
	self:HookScript(GameTooltip, 'OnTooltipSetUnit', 'GameTooltip_OnTooltipSetUnit')
	self:HookScript(GameTooltipStatusBar, 'OnValueChanged', 'GameTooltipStatusBar_OnValueChanged')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	E.Skins:HandleCloseButton(ItemRefCloseButton)
	
	self.UpdateInspect = CreateFrame('Frame')
	self.UpdateInspect:SetScript('OnUpdate', TT.Inspect_OnUpdate)
	self.UpdateInspect:Hide()
	
	--SpellIDs
	hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
		local _, _, _, _, _, _, _, caster, _, _, id = UnitBuff(...)
		if id and TT.db.spellid then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = RAID_CLASS_COLORS[class]
				self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			end

			self:Show()
		end
	end)

	hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
		local _, _, _, _, _, _, _, caster, _, _, id = UnitDebuff(...)
		if id and TT.db.spellid then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = RAID_CLASS_COLORS[class]
				self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			end

			self:Show()
		end	
	end)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
		local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(...)
		if id and TT.db.spellid then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = RAID_CLASS_COLORS[class]
				self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
			else
				self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			end

			self:Show()
		end	
	end)

	hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
		if find(link,"^spell:") and TT.db.spellid then
			local id = string.sub(link,7)
			ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			ItemRefTooltip:Show()
		end
	end)

	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		local id = select(3,self:GetSpell())
		if not id or not TT.db.spellid then return; end
		local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
		local lines = self:NumLines()
		local isFound
		for i= 1, lines do
			local line = _G[("GameTooltipTextLeft%d"):format(i)]
			if line and line:GetText() and line:GetText():find(displayString) then
				isFound = true;
				break
			end
		end
		
		if not isFound then
			self:AddLine(displayString)
			self:Show()
		end
	end)
end

E:RegisterModule(TT:GetName())