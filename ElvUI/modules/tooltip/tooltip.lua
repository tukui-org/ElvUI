-- credits : Aezay (TipTac) and Caellian for some parts of code.
local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

local db = ElvCF["tooltip"]
if not db.enable then return end

local ElvuiTooltip = CreateFrame("Frame", nil, UIParent)

local _G = getfenv(0)

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local TooltipHolder = CreateFrame("Frame", "TooltipHolder", UIParent)
TooltipHolder:SetWidth(130)
TooltipHolder:SetHeight(22)
TooltipHolder:SetPoint("BOTTOMRIGHT", ElvuiInfoRight, "BOTTOMRIGHT")

ElvDB.CreateMover(TooltipHolder, "TooltipMover", "Tooltip")

local gsub, find, format = string.gsub, string.find, string.format

local Tooltips = {GameTooltip,ItemRefTooltip,ShoppingTooltip1,ShoppingTooltip2,ShoppingTooltip3,WorldMapTooltip}

local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}
 	
local NeedBackdropBorderRefresh = false

--Check if our embed right addon is shown
local function CheckAddOnShown()
	if ElvDB.ChatRightShown == true then
		return true
	elseif ElvCF["skin"].embedright == "Omen" and IsAddOnLoaded("Omen") and OmenAnchor then
		if OmenAnchor:IsShown() then
			return true
		else
			return false
		end
	elseif ElvCF["skin"].embedright == "Recount" and IsAddOnLoaded("Recount") and Recount_MainWindow then
		if Recount_MainWindow:IsShown() then
			return true
		else
			return false
		end
	elseif  ElvCF["skin"].embedright ==  "Skada" and IsAddOnLoaded("Skada") and SkadaBarWindowSkada then
		if SkadaBarWindowSkada:IsShown() then
			return true
		else
			return false
		end
	else
		return false
	end
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	if db.cursor == true then
		if IsAddOnLoaded("ElvUI_Heal_Layout") and parent ~= UIParent then 
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
	self:ClearAllPoints()
	if InCombatLockdown() and db.hidecombat == true and (ElvCF["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
		self:Hide()
	elseif InCombatLockdown() and db.hidecombat == true and ElvCF["tooltip"].hidecombatraid == false then
		self:Hide()
	else
		if ElvCF["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() then
			self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", -1, ElvDB.Scale(18))	
		elseif TooltipMover and ElvDB.Movers["TooltipMover"]["moved"] == true then
			self:SetPoint("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, ElvDB.Scale(18))
		else
			if CheckAddOnShown() == true then
				if ElvCF["chat"].showbackdrop == true and ElvDB.ChatRightShown == true then
					self:SetPoint("BOTTOMRIGHT", ChatRBackground2, "TOPRIGHT", -1, ElvDB.Scale(42))	
				else
					self:SetPoint("BOTTOMRIGHT", ChatRBackground2, "TOPRIGHT", -1, ElvDB.Scale(18))		
				end	
			else
				self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -15, ElvDB.Scale(42))	
			end
		end
	end
end

GameTooltip:HookScript("OnUpdate",function(self, ...)
	local inInstance, instanceType = IsInInstance()
	if self:GetAnchorType() == "ANCHOR_CURSOR" then
		local x, y = GetCursorPosition();
		local effScale = self:GetEffectiveScale();
		self:ClearAllPoints();
		self:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT",(x / effScale + (15)),(y / effScale + (7)))		
	end
	
	if self:GetAnchorType() == "ANCHOR_CURSOR" and NeedBackdropBorderRefresh == true and db.cursor ~= true then
		-- h4x for world object tooltip border showing last border color 
		-- or showing background sometime ~blue :x
		NeedBackdropBorderRefresh = false
		self:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(ElvCF.media.bordercolor))
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
		self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, ElvDB.Scale(-3))
		self.text:SetFont(ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
		self.text:Show()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			local hp = ElvDB.ShortValue(min).." / "..ElvDB.ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(ElvL.unitframes_ouf_ghost)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(ElvL.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		end
	else
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			self.text:Show()
			local hp = ElvDB.ShortValue(min).." / "..ElvDB.ShortValue(max)
			if min == 0 or min == 1 then
				self.text:SetText(ElvL.unitframes_ouf_dead)
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
healthBar:SetHeight(ElvDB.Scale(5))
healthBar:SetPoint("TOPLEFT", healthBar:GetParent(), "BOTTOMLEFT", ElvDB.Scale(2), ElvDB.Scale(-5))
healthBar:SetPoint("TOPRIGHT", healthBar:GetParent(), "BOTTOMRIGHT", -ElvDB.Scale(2), ElvDB.Scale(-5))
healthBar:SetStatusBarTexture(ElvCF.media.normTex)


local healthBarBG = CreateFrame("Frame", "StatusBarBG", healthBar)
healthBarBG:SetFrameLevel(healthBar:GetFrameLevel() - 1)
healthBarBG:SetPoint("TOPLEFT", -ElvDB.Scale(2), ElvDB.Scale(2))
healthBarBG:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), -ElvDB.Scale(2))
ElvDB.SetTemplate(healthBarBG)
healthBarBG:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))

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
			line:SetFormattedText(ElvL.tooltip_whotarget.." (|cffffffff%d|r): %s",(#targetedList + 1) / 3,table.concat(targetedList));
			wipe(targetedList);
		end
	end
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
	if (self:GetOwner() ~= UIParent and db.hideuf) then self:Hide() return end

	if self:GetOwner() ~= UIParent and unit then
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
				_G["GameTooltipTextLeft2"]:SetText("<"..ElvDB.ValColor..guildName.."|r> ["..ElvDB.ValColor..guildRankName.."|r]")
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
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level > 0 and level or "??", classification[classif] or "", crtype or "")
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

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex, r, g, b = GetColor(unit.."target")
		if not r and not g and not b then r, g, b = 1, 1, 1 end
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
	end
	
	if ElvCF["tooltip"].whotargetting == true then token = unit AddTargetedBy() end
		
	
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
	elseif player and not ElvCF["tooltip"].colorreaction == true then
		local class = select(2, UnitClass(unit))
		local c = ElvDB.colors.class[class]
		if c then
			r, g, b = c[1], c[2], c[3]
		end
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif reaction then
		local c = ElvDB.colors.reaction[reaction]
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
			self:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
			healthBarBG:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
			healthBar:SetStatusBarColor(unpack(ElvCF["media"].bordercolor))
		end
	end	
	-- need this
	NeedBackdropBorderRefresh = true
end

local SetStyle = function(self)
	ElvDB.SetNormTexTemplate(self)
	self:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	Colorize(self)
end

ElvuiTooltip:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiTooltip:SetScript("OnEvent", function(self)
	for _, tt in pairs(Tooltips) do
		tt:HookScript("OnShow", SetStyle)
	end
	
	ElvDB.SetTemplate(FriendsTooltip)
	FriendsTooltip:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	ElvDB.SetTemplate(BNToastFrame)
	BNToastFrame:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	ElvDB.SetTemplate(DropDownList1MenuBackdrop)
	DropDownList1MenuBackdrop:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	ElvDB.SetTemplate(DropDownList2MenuBackdrop)
	DropDownList2MenuBackdrop:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	ElvDB.SetTemplate(DropDownList1Backdrop)
	DropDownList1Backdrop:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
	ElvDB.SetTemplate(DropDownList2Backdrop)
	
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ElvDB.Scale(5), ElvDB.Scale(-5))
	end)
		
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", nil)
	
	-- Hide tooltips in combat for actions, pet actions and shapeshift
	if db.hidebuttons == true then
		local CombatHideActionButtonsTooltip = function(self)
			if not IsShiftKeyDown() then
				self:Hide()
			end
		end
	 
		hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
	end
end)


ElvuiTooltip:SetScript("OnUpdate", function(self, elapsed)
	if(self.elapsed and self.elapsed > 0.1) then
		if FrameStackTooltip then
			local noscalemult = ElvDB.mult * ElvCF["general"].uiscale
			local r, g, b = RAID_CLASS_COLORS[ElvDB.myclass].r, RAID_CLASS_COLORS[ElvDB.myclass].g, RAID_CLASS_COLORS[ElvDB.myclass].b
			FrameStackTooltip:SetBackdrop({
			  bgFile = ElvCF["media"].blank, 
			  edgeFile = ElvCF["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = noscalemult, 
			  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
			})
			FrameStackTooltip:SetBackdropColor(unpack(ElvCF.media.backdropfadecolor))
			if ElvCF["general"].classcolortheme == true then
				FrameStackTooltip:SetBackdropBorderColor(r, g, b)
			else
				FrameStackTooltip:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
			end	
			FrameStackTooltip.SetBackdropColor = ElvDB.dummy
			FrameStackTooltip.SetBackdropBorderColor = ElvDB.dummy
			self.elapsed = nil
			self:SetScript("OnUpdate", nil)
		end
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)


