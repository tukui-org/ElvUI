-- credits : Aezay (TipTac) and Caellian for some parts of code.

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["tooltip"].enable then return end

local ElvuiTooltip = CreateFrame("Frame", nil, E.UIParent)

local _G = getfenv(0)

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local TooltipHolder = CreateFrame("Frame", "TooltipHolder", E.UIParent)
TooltipHolder:SetWidth(130)
TooltipHolder:SetHeight(22)
TooltipHolder:SetPoint("BOTTOMRIGHT", ElvuiInfoRight, "BOTTOMRIGHT")

E.CreateMover(TooltipHolder, "TooltipMover", "Tooltip")

local gsub, find, format = string.gsub, string.find, string.format

local Tooltips = {GameTooltip,ItemRefTooltip,ItemRefShoppingTooltip1,ItemRefShoppingTooltip2,ItemRefShoppingTooltip3,ShoppingTooltip1,ShoppingTooltip2,ShoppingTooltip3,WorldMapTooltip,WorldMapCompareTooltip1,WorldMapCompareTooltip2,WorldMapCompareTooltip3}

local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}
 	
local NeedBackdropBorderRefresh = false

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	if C["tooltip"].cursor == true then
		if IsAddOnLoaded("Elvui_RaidHeal") and parent ~= UIParent then 
			self:SetOwner(parent, "ANCHOR_NONE")	
		else
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	else
		self:SetOwner(parent, "ANCHOR_NONE")
	end
	self.default = 1
end)

local function SetRightTooltipPos(self)
	local inInstance, instanceType = IsInInstance()
	self:ClearAllPoints()
	if InCombatLockdown() and C["tooltip"].hidecombat == true and (C["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
		self:Hide()
	elseif InCombatLockdown() and C["tooltip"].hidecombat == true and C["tooltip"].hidecombatraid == false then
		self:Hide()
	else
		if C["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() then
			self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", -1, E.Scale(18))	
		elseif #ContainerFrame1.bags > 0 and _G[ContainerFrame1.bags[#ContainerFrame1.bags]]:IsShown() then
			self:Point("BOTTOMRIGHT", _G[ContainerFrame1.bags[#ContainerFrame1.bags]], "TOPRIGHT", -2, 18)
		elseif TooltipMover and E.Movers and E.Movers["TooltipMover"] then
			local point, _, _, _, _ = TooltipMover:GetPoint()
			if point == "TOPLEFT" then
				self:SetPoint("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, E.Scale(-4))
			elseif point == "TOPRIGHT" then
				self:SetPoint("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, E.Scale(-4))
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				self:SetPoint("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, E.Scale(18))
			else
				self:SetPoint("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, E.Scale(18))
			end
		else
			if E.CheckAddOnShown() == true then
				if C["chat"].showbackdrop == true and E.ChatRightShown == true then
					self:Point("BOTTOMRIGHT", ChatRBGDummy, "TOPRIGHT", 0, 18)	
				else
					self:Point("BOTTOMRIGHT", ChatRBGDummy, "TOPRIGHT", -8, -14)				
				end	
			else
				self:Point("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -12, 47)	
			end
		end
	end
end

GameTooltip:HookScript("OnUpdate",function(self, ...)
	if self:GetAnchorType() == "ANCHOR_CURSOR" then
		local x, y = GetCursorPosition();
		local effScale = self:GetEffectiveScale();
		self:ClearAllPoints();
		self:SetPoint("BOTTOMLEFT", UIParent,"BOTTOMLEFT",(x / effScale + (15)),(y / effScale + (7)))		
	end
	
	if self:GetAnchorType() == "ANCHOR_CURSOR" and NeedBackdropBorderRefresh == true and C["tooltip"].cursor ~= true then
		-- h4x for world object tooltip border showing last border color 
		-- or showing background sometime ~blue :x
		NeedBackdropBorderRefresh = false
		self:SetBackdropColor(unpack(C.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(C.media.bordercolor))
	elseif self:GetAnchorType() == "ANCHOR_NONE" then
		SetRightTooltipPos(self)
	end
end)

local function Hex(color)
	return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return Hex(color), r, g, b	
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b		
		return Hex(color), r, g, b		
	end
end

-- update HP value on status bar
GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	
	if (value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()
	
	-- fix target of target returning nil
	if (not unit) then
		local GMF = GetMouseFocus()
		unit = GMF and GMF:GetAttribute("unit")
	end

	if not self.text then
		self.text = self:CreateFontString(nil, "OVERLAY")
		self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, E.Scale(-3))
		self.text:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
		self.text:Show()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			local hp = E.ShortValue(min).." / "..E.ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(L.unitframes_ouf_ghost)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(L.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		end
	else
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			self.text:Show()
			local hp = E.ShortValue(min).." / "..E.ShortValue(max)
			if min == 0 or min == 1 then
				self.text:SetText(L.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		else
			self.text:Hide()
		end
	end
end)

local healthBar = GameTooltipStatusBar
healthBar:ClearAllPoints()
healthBar:SetHeight(E.Scale(5))
healthBar:SetPoint("TOPLEFT", healthBar:GetParent(), "BOTTOMLEFT", E.Scale(2), E.Scale(-5))
healthBar:SetPoint("TOPRIGHT", healthBar:GetParent(), "BOTTOMRIGHT", -E.Scale(2), E.Scale(-5))
healthBar:SetStatusBarTexture(C["media"].normTex)


local healthBarBG = CreateFrame("Frame", "StatusBarBG", healthBar)
healthBarBG:SetFrameLevel(healthBar:GetFrameLevel() - 1)
healthBarBG:SetPoint("TOPLEFT", -E.Scale(2), E.Scale(2))
healthBarBG:SetPoint("BOTTOMRIGHT", E.Scale(2), -E.Scale(2))
healthBarBG:SetTemplate("Default")
healthBarBG:SetBackdropColor(unpack(C.media.backdropfadecolor))

-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {};
local token
for class, color in next, RAID_CLASS_COLORS do
	ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r*255,color.g*255,color.b*255);
end

local function AddTargetedBy()
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
			line:SetFormattedText(L.tooltip_whotarget.." (|cffffffff%d|r): %s",(#targetedList + 1) / 3,table.concat(targetedList));
			wipe(targetedList);
		end
	end
end

local SlotName = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand","Ranged","Ammo"
}

local function GetItemLvL(unit)
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

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local lines = self:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	
	-- A mage's mirror images sometimes doesn't return a unit, this would fix it
	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end
	
	-- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
	if not unit then self:Hide() return end
	
	-- for hiding tooltip on unitframes
	if (self:GetOwner() ~= E.UIParent and C["tooltip"].hideuf) then self:Hide() return end

	if self:GetOwner() ~= E.UIParent and unit then
		SetRightTooltipPos(self)
	end	
	
	-- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
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

	local color = GetColor(unit)	
	if not color then color = "|CFFFFFFFF" end -- just safe mode for when GetColor(unit) return nil for unit too far away

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")
	

	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guildName then
			if UnitIsInMyGuild(unit) then
				_G["GameTooltipTextLeft2"]:SetText("<"..E.ValColor..guildName.."|r> ["..E.ValColor..guildRankName.."|r]")
			else
				_G["GameTooltipTextLeft2"]:SetText("<|cff00ff10"..guildName.."|r> [|cff00ff10"..guildRankName.."|r]")
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

	local pvpLine
	for i = 1, lines do
		if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and _G["GameTooltipTextLeft"..i]:GetText() == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end
	
	if IsShiftKeyDown() and (unit and CanInspect(unit)) and C["tooltip"].itemid == true then
		local isInspectOpen = (InspectFrame and InspectFrame:IsShown()) or (Examiner and Examiner:IsShown())
		if ((unit) and (CanInspect(unit)) and (not isInspectOpen)) then
			NotifyInspect(unit)
			
			local ilvl = GetItemLvL(unit)
			
			ClearInspectPlayer(unit)
			
			if ilvl > 1 then
				GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", "|cffFFFFFF"..ilvl.."|r")
				GameTooltip:Show()
			end
		end
	end	

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex, _, _, _ = GetColor(unit.."target")
		if not hex then hex = "|cffFFFFFF" end
		GameTooltip:AddDoubleLine(TARGET..":", hex..UnitName(unit.."target").."|r")
	end
	
	if C["tooltip"].whotargetting == true then token = unit AddTargetedBy() end
		
	
	-- Sometimes this wasn't getting reset, the fact a cleanup isn't performed at this point, now that it was moved to "OnTooltipCleared" is very bad, so this is a fix
	self.fadeOut = nil
end)

local Colorize = function(self)
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
		
	local reaction = unit and UnitReaction(unit, "player")
	local player = unit and UnitIsPlayer(unit)
	local tapped = unit and UnitIsTapped(unit)
	local tappedbyme = unit and UnitIsTappedByPlayer(unit)
	local connected = unit and UnitIsConnected(unit)
	local dead = unit and UnitIsDead(unit)
	

	if (reaction) and (tapped and not tappedbyme or not connected or dead) then
		r, g, b = 0.55, 0.57, 0.61
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif player and not C["tooltip"].colorreaction == true then
		local class = select(2, UnitClass(unit))
		local c = E.colors.class[class]
		if c then
			r, g, b = c[1], c[2], c[3]
		end
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif reaction then
		local c = E.colors.reaction[reaction]
		r, g, b = c[1], c[2], c[3]
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			healthBarBG:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			healthBar:SetStatusBarColor(unpack(C["media"].bordercolor))
		end
	end	
	-- need this
	NeedBackdropBorderRefresh = true
end

local SetStyle = function(self)
	self:SetTemplate("Default", true)
	Colorize(self)
	self:SetClampedToScreen(true)
end

local function PositionBGToastFrame(self, elapsed)
	if(self.elapsed and self.elapsed > 0.2) then
		local inInstance, instanceType = IsInInstance()
		self:ClearAllPoints()
		if InCombatLockdown() and C["tooltip"].hidecombat == true and (C["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
			self:Hide()
		elseif InCombatLockdown() and C["tooltip"].hidecombat == true and C["tooltip"].hidecombatraid == false then
			self:Hide()
		else
			if C["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() then
				self:Point("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", 0, 4)
			elseif #ContainerFrame1.bags > 0 and _G[ContainerFrame1.bags[#ContainerFrame1.bags]]:IsShown() then
				self:Point("BOTTOMRIGHT", _G[ContainerFrame1.bags[#ContainerFrame1.bags]], "TOPRIGHT", 0, 4)
			elseif TooltipMover and E.Movers and E.Movers["TooltipMover"] then
				local point, _, _, _, _ = TooltipMover:GetPoint()
				if point == "TOPLEFT" then
					self:Point("TOPLEFT", TooltipMover, "BOTTOMLEFT", 0, -4)
				elseif point == "TOPRIGHT" then
					self:Point("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", 0, -4)
				elseif point == "BOTTOMLEFT" or point == "LEFT" then
					self:Point("BOTTOMLEFT", TooltipMover, "TOPLEFT", 0, 4)
				else
					self:Point("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", 0, 4)
				end
			else
				if E.CheckAddOnShown() == true then
					if C["chat"].showbackdrop == true and E.ChatRightShown == true then
						self:Point("BOTTOMRIGHT", ChatRBGDummy, "TOPRIGHT", 0, 4)
					else
						self:Point("BOTTOMRIGHT", ChatRBGDummy, "TOPRIGHT", -7, -25)					
					end	
				else
					self:Point("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -11, 36)	
				end
			end
		end
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

ElvuiTooltip:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiTooltip:SetScript("OnEvent", function(self, event, addon)
	for _, tt in pairs(Tooltips) do
		tt:HookScript("OnShow", SetStyle)
	end
	
	E.SkinCloseButton(ItemRefCloseButton)
	ItemRefTooltip:HookScript("OnTooltipSetItem", SetStyle)
	FriendsTooltip:SetTemplate("Default", true)
	BNToastFrame:SetTemplate("Default", true)
	BNToastFrame.elapsed = 0.3
	BNToastFrame:HookScript('OnUpdate', PositionBGToastFrame)
	BNToastFrame:SetFrameStrata('TOOLTIP')
	BNToastFrame:SetFrameLevel(20)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", nil)
	
	-- Hide tooltips in combat for actions, pet actions and shapeshift
	if C["tooltip"].hidebuttons == true then
		local CombatHideActionButtonsTooltip = function(self)
			if not IsShiftKeyDown() then
				self:Hide()
			end
		end
	 
		hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
	end
	
	LoadAddOn("Blizzard_DebugTools")
	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * C["general"].uiscale
		self:SetBackdrop({
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		})
		self:SetBackdropColor(unpack(C.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(C.media.bordercolor))
	end)
	
	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)
end)

--Fix compare tooltips
hooksecurefunc("GameTooltip_ShowCompareItem", function(self, shift)
	if ( not self ) then
		self = GameTooltip;
	end
	local item, link = self:GetItem();
	if ( not link ) then
		return;
	end
	
	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(self.shoppingTooltips);

	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local side = "left";
	if ( shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self) ) then
		item1 = true;
	end
	if ( shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self) ) then
		item2 = true;
	end
	if ( shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self) ) then
		item3 = true;
	end

	-- find correct side
	local rightDist = 0;
	local leftPos = self:GetLeft();
	local rightPos = self:GetRight();
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
	if ( self:GetAnchorType() and self:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
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
			self:SetAnchorType(self:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	-- anchor the compare tooltips
	if ( item3 ) then
		shoppingTooltip3:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip3:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip3:Point("TOPRIGHT", self, "TOPLEFT", -2, -10);
		else
			shoppingTooltip3:Point("TOPLEFT", self, "TOPRIGHT", 2, -10);
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self);
		shoppingTooltip3:Show();
	end
	
	if ( item1 ) then
		if( item3 ) then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE");
		else
			shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		end
		shoppingTooltip1:ClearAllPoints();
		if ( side and side == "left" ) then
			if( item3 ) then
				shoppingTooltip1:Point("TOPRIGHT", shoppingTooltip3, "TOPLEFT", -2, 0);
			else
				shoppingTooltip1:Point("TOPRIGHT", self, "TOPLEFT", -2, -10);
			end
		else
			if( item3 ) then
				shoppingTooltip1:Point("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 2, 0);
			else
				shoppingTooltip1:Point("TOPLEFT", self, "TOPRIGHT", 2, -10);
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self);
		shoppingTooltip1:Show();

		if ( item2 ) then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE");
			shoppingTooltip2:ClearAllPoints();
			if ( side and side == "left" ) then
				shoppingTooltip2:Point("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -2, 0);
			else
				shoppingTooltip2:Point("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 2, 0);
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self);
			shoppingTooltip2:Show();
		end
	end

end)