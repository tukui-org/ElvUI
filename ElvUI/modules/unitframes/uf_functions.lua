------------------------------------------------------------------------
--	UnitFrame Functions
------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local _, ns = ...

E.LoadUFFunctions = function(layout)
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

	function E.ContructHealthBar(self, bg, text)
		local health = CreateFrame('StatusBar', nil, self)
		health:SetStatusBarTexture(C["media"].normTex)
		health:SetFrameStrata("LOW")
		health.frequentUpdates = 0.2
		health.PostUpdate = E.PostUpdateHealth
		
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end	
		
		if bg then
			health.bg = health:CreateTexture(nil, 'BORDER')
			health.bg:SetAllPoints()
			health.bg:SetTexture(C["media"].blank)
			
			if C["unitframes"].healthbackdrop ~= true then
				health.bg.multiplier = 0.25
			else
				health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
				health.bg.SetVertexColor = E.dummy
			end
		end
		
		if text then
			health:FontString("value", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
			health.value:SetShadowColor(0, 0, 0, 0)
			health.value:SetParent(self)
		end
		
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = true
			
			if C["unitframes"].healthcolorbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true
		end
		health.colorDisconnected = true
		
		health.backdrop = CreateFrame('Frame', nil, health)
		health.backdrop:SetTemplate("Default")
		health.backdrop:Point("TOPRIGHT", health, "TOPRIGHT", 2*E.ResScale, 2*E.ResScale)
		health.backdrop:Point("BOTTOMLEFT", health, "BOTTOMLEFT", -2*E.ResScale, -2*E.ResScale)
		health.backdrop:SetFrameLevel(health:GetFrameLevel() - 1)		
		
		return health
	end

	function E.ConstructPowerBar(self, bg, text)
		local power = CreateFrame('StatusBar', nil, self)
		power:SetStatusBarTexture(C["media"].normTex)
		power.frequentUpdates = 0.2
		power:SetFrameStrata("LOW")
		power.PostUpdate = E.PostUpdatePower
		
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end	
		
		if bg then
			power.bg = power:CreateTexture(nil, 'BORDER')
			power.bg:SetAllPoints()
			power.bg:SetTexture(C["media"].blank)
			power.bg.multiplier = 0.2
		end
		
		if text then
			power:FontString("value", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
			power.value:SetShadowColor(0, 0, 0, 0)			
			power.value:SetParent(self)
		end
		
		if C["unitframes"].classcolorpower == true then
			power.colorClass = true
			power.colorReaction = true
		else
			power.colorPower = true
		end
		
		power.colorDisconnected = true
		power.colorTapping = false
		
		power.backdrop = CreateFrame('Frame', nil, power)
		power.backdrop:SetTemplate("Default")
		power.backdrop:Point("TOPRIGHT", power, "TOPRIGHT", 2*E.ResScale, 2*E.ResScale)
		power.backdrop:Point("BOTTOMLEFT", power, "BOTTOMLEFT", -2*E.ResScale, -2*E.ResScale)
		power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)
	
		return power
	end	

	function E.ConstructCastBar(self, width, height, direction)
		local castbar = CreateFrame("StatusBar", nil, self)
		castbar:SetStatusBarTexture(C["media"].normTex)
		castbar:Height(height)
		castbar:Width(width - 3*E.ResScale)
		castbar.CustomDelayText = E.CustomCastDelayText
		castbar.PostCastStart = E.PostCastStart
		castbar.PostChannelStart = E.PostCastStart		
		castbar.PostCastInterruptible = E.PostCastInterruptible
		castbar.PostCastNotInterruptible = E.PostCastNotInterruptible
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.bg:Point("TOPLEFT", -2*E.ResScale, 2*E.ResScale)
		castbar.bg:Point("BOTTOMRIGHT", 2*E.ResScale, -2*E.ResScale)
		castbar.bg:SetFrameLevel(castbar:GetFrameLevel() - 1)
		
		castbar:FontString("Time", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
		castbar.Time:SetShadowColor(0, 0, 0, 0)	
		castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		castbar.Time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = E.CustomCastTimeText

		castbar:FontString("Text", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		castbar.Text:SetShadowColor(0, 0, 0, 0)
		
		-- cast bar latency on player
		if C["unitframes"].cblatency == true and self.unit == "player" then
			castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")
			castbar.SafeZone:SetTexture(C["media"].normTex)
			castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end			

		if C["unitframes"].cbicons == true then
			local button = CreateFrame("Frame", nil, castbar)
			button:Height(height + 4*E.ResScale)
			button:Width(height + 4*E.ResScale)
			button:SetTemplate("Default")
			button:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			if direction == "LEFT" then
				button:Point("RIGHT", castbar, "LEFT", -3*E.ResScale, 0)
			else
				button:Point("LEFT", castbar, "RIGHT", 3*E.ResScale, 0)
			end
			
			castbar.Icon = button:CreateTexture(nil, "ARTWORK")
			castbar.Icon:Point("TOPLEFT", button, 2*E.ResScale, -2*E.ResScale)
			castbar.Icon:Point("BOTTOMRIGHT", button, -2*E.ResScale, 2*E.ResScale)
			castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			castbar.Icon.bg = button
			castbar:Width(width - button:GetWidth() - 6)
		end
	
		return castbar
	end
	
	local function CreateSwingStatusBar(parent, text)
		local sbar = CreateFrame("Statusbar", nil, parent)
		sbar:SetPoint("TOPLEFT")
		sbar:SetPoint("BOTTOMRIGHT")
		sbar:SetStatusBarTexture(C["media"].normTex)
		sbar:SetStatusBarColor(unpack(C["media"].bordercolor))
		sbar:SetFrameLevel(20)
		sbar:SetFrameStrata("LOW")
		sbar:Hide()
		
		if text then
			sbar:FontString("Text", C["media"].uffont, C["unitframes"].fontsize*E.ResScale, "THINOUTLINE")
			sbar.Text:Point("CENTER", sbar, "CENTER")
			sbar.Text:SetTextColor(0.84, 0.75, 0.65)
		end
		
		sbar.backdrop = CreateFrame("Frame", nil, sbar)
		sbar.backdrop:SetFrameLevel(sbar:GetFrameLevel() - 1)
		sbar.backdrop:Point("TOPLEFT", parent, "TOPLEFT", -2*E.ResScale, 2*E.ResScale)
		sbar.backdrop:Point("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2*E.ResScale, -2*E.ResScale)
		sbar.backdrop:SetTemplate("Default")
		return sbar
	end
	
	function E.ConstructSwingBar(self, width, height, text)
		local swing = CreateFrame("Frame", nil, self)
		swing.Twohand = CreateSwingStatusBar(swing, text)
		swing.Mainhand = CreateSwingStatusBar(swing, text)
		swing.Offhand = CreateSwingStatusBar(swing, text)
		swing.hideOoc = true
		swing:SetWidth(width*E.ResScale)
		swing:SetHeight(height*E.ResScale)
		return swing
	end
	
	function E.SpawnMenu(self)
		local unit = self.unit:gsub("(.)", string.upper, 1)
		if self.unit == "targettarget" then return end
		if _G[unit.."FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
		elseif (self.unit:match("party")) then
			ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
		else
			FriendsDropDown.unit = self.unit
			FriendsDropDown.id = self.id
			FriendsDropDown.initialize = RaidFrameDropDown_Initialize
			ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
		end
	end

	local frameshown = true
	local unitlist = {}
	local function FadeFramesInOut(fade)
		for frames, unitlist in pairs(unitlist) do
			if not UnitExists(_G[unitlist].unit) then return end
			if fade == true then
				UIFrameFadeIn(_G[unitlist], 0.15)
			else
				UIFrameFadeOut(_G[unitlist], 0.15)
			end
		end
	end

	E.Fader = function(self, arg1, arg2)	
		if arg1 == "UNIT_HEALTH" and self.unit ~= arg2 then return end
		
		local unit = self.unit
		if arg2 == true then self = self:GetParent() end
		if not unitlist[tostring(self:GetName())] then tinsert(unitlist, tostring(self:GetName())) end
		
		local cur = UnitHealth("player")
		local max = UnitHealthMax("player")
		
		if (UnitCastingInfo("player") or UnitChannelInfo("player")) and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif cur ~= max and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif (UnitExists("target") or UnitExists("focus")) and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif arg1 == true and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true
		else
			if InCombatLockdown() and frameshown ~= true then
				FadeFramesInOut(true)
				frameshown = true	
			elseif not UnitExists("target") and not InCombatLockdown() and not UnitExists("focus") and (cur == max) and not (UnitCastingInfo("player") or UnitChannelInfo("player")) then
				FadeFramesInOut(false)
				frameshown = false
			end
		end
	end

	E.AuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)	
		local header = icon:GetParent():GetParent():GetParent():GetName()
		local inInstance, instanceType = IsInInstance()
		icon.owner = caster
		icon.isStealable = isStealable
		
		if (unit and unit:find("arena%d")) then --Arena frames
			if E.DebuffWhiteList[name] then
				return true
			elseif E.ArenaBuffWhiteList[name] then
				return true
			else
				return false
			end	
		elseif unit == "target" or (unit and unit:find("boss%d")) then --Target/Boss Only
			if C["unitframes"].playerdebuffsonly == true then
				-- Show all debuffs on friendly targets
				if UnitIsFriend("player", "target") then return true end
				
				local isPlayer
				
				if(caster == 'player' or caster == 'vehicle') then
					isPlayer = true
				else
					isPlayer = false
				end

				if isPlayer then
					return true
				elseif E.DebuffWhiteList[name] or (inInstance and ((instanceType == "pvp" or instanceType == "arena") and E.TargetPVPOnly[name])) then
					return true
				else
					return false
				end
			else
				return true
			end
		else --Everything else
			if unit ~= "player" and unit ~= "targettarget" and unit ~= "focus" and inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if E.DebuffWhiteList[name] or E.TargetPVPOnly[name] then
					return true
				else
					return false
				end
			else
				if E.DebuffBlacklist[name] then
					return false
				else
					return true
				end
			end
		end
	end

	E.PostUpdateHealth = function(health, unit, min, max)
		local r, g, b = health:GetStatusBarColor()
		health.defaultColor = {r, g, b}
		
		if C["general"].classcolortheme == true then
			health.backdrop:SetBackdropBorderColor(r, g, b)
			if health:GetParent().Portrait and health:GetParent().Portrait.backdrop then
				health:GetParent().Portrait.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end
	

		if C["unitframes"].classcolor == true and C["unitframes"].healthcolorbyvalue == true and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			local newr, newg, newb = ElvUF.ColorGradient(min / max, 1, 0, 0, 1, 1, 0, r, g, b)
	
			health:SetStatusBarColor(newr, newg, newb)
			if health.bg and health.bg.multiplier then
				local mu = health.bg.multiplier
				health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
			end
		end

		if C["unitframes"].classcolorbackdrop == true then
			local t
				if UnitIsPlayer(unit) then
					local _, class = UnitClass(unit)
					t = health:GetParent().colors.class[class]
				elseif UnitReaction(unit, 'player') then
					t = health:GetParent().colors.reaction[UnitReaction(unit, "player")]
				end
				
			if t then
				health.bg:SetVertexColor(t[1], t[2], t[3])
			end
		end
		
		if not health.value then return end
		
		local header = health:GetParent():GetParent():GetName()
		if header == "ElvuiHealParty" or header == "ElvuiDPSParty" or header == "ElvuiHealR6R25" or header == "ElvuiDPSR6R25" or header == "ElvuiHealR26R40" or header == "ElvuiDPSR26R40" then --Raid/Party Layouts
			if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
				if not UnitIsConnected(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max and C["raidframes"].healthdeficit == true then
					health.value:SetText("|cff559655-"..E.ShortValueNegative(max-min).."|r")
				else
					health.value:SetText("")
				end
			end
		else
			if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
				if not UnitIsConnected(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max then
					local r, g, b
					r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						if C["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", E.ShortValue(min), E.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif unit == "target" or unit == "focus" or (unit and unit:find("boss%d")) then
						if C["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", E.ShortValue(min), E.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..E.ShortValue(min).."|r")
					else
						health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
					end
				else
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					elseif unit == "target" or unit == "focus" or (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					else
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					end
				end
			end
		end
	end

	E.PostNamePosition = function(self)
		self.Name:ClearAllPoints()
		if (self.Power.value:GetText() and UnitIsPlayer("target") and C["unitframes"].targetpowerplayeronly == true) or (self.Power.value:GetText() and C["unitframes"].targetpowerplayeronly == false) then
			self.Power.value:SetAlpha(1)
			self.Name:SetPoint("CENTER", self.Health, "CENTER")
		else
			self.Power.value:SetAlpha(0)
			self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		end
	end

	E.PostUpdatePower = function(power, unit, min, max)
		local self = power:GetParent()
		local pType, pToken, altR, altG, altB = UnitPowerType(unit)
		local color = E.oUF_colors.power[pToken]
		
		if C["general"].classcolortheme == true then
			power.backdrop:SetBackdropBorderColor(power:GetParent().Health.backdrop:GetBackdropBorderColor())
		end
		
		if not power.value then return end		
	
		if color then
			power.value:SetTextColor(color[1], color[2], color[3])
		else
			power.value:SetTextColor(altR, altG, altB, 1)
		end	
			
		if min == 0 then 
			power.value:SetText() 
		else
			if (not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit)) and not (unit and unit:find("boss%d")) then
				power.value:SetText()
			elseif UnitIsDead(unit) or UnitIsGhost(unit) then
				power.value:SetText()
			else
				if min ~= max then
					if pType == 0 then
						if unit == "target" then
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), E.ShortValue(max - (max - min)))
							end
						elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%%", floor(min / max * 100))
							end
						elseif (unit and unit:find("arena%d")) then
							power.value:SetText(E.ShortValue(min))
						elseif (unit and unit:find("boss%d")) then
							power.value:SetFormattedText("%d%%", floor(min / max * 100))					
						else
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), E.ShortValue(max - (max - min)))
							end
						end
					else
						power.value:SetText(max - (max - min))
					end
				else
					if unit == "pet" or unit == "target" or (unit and unit:find("arena%d")) then
						power.value:SetText(E.ShortValue(min))
					else
						power.value:SetText(E.ShortValue(min))
					end
				end
			end
		end
		
		if self.Name and unit == "target"  then
			E.PostNamePosition(self)
		end
	end
	
	local delay = 0
	E.UpdateManaLevel = function(self, elapsed)
		delay = delay + elapsed
		if self.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
		delay = 0

		local percMana = UnitMana("player") / UnitManaMax("player") * 100

		if percMana <= 20 then
			self.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
			E.Flash(self.ManaLevel, 0.3)
		else
			self.ManaLevel:SetText()
			E.StopFlash(self.ManaLevel)
		end
	end
	
	E.MLAnchorUpdate = function(self)
		if self.Leader:IsShown() then
			self.MasterLooter:Point("TOPRIGHT", -18, 9)
		else
			self.MasterLooter:Point("TOPRIGHT", -4, 9)
		end
	end
	
	E.RoleIconUpdate = function(self, event)
		local lfdrole = self.LFDRole

		local role = UnitGroupRolesAssigned(self.unit)

		if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') and UnitIsConnected(self.unit) then
			if role == 'TANK' then
				lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\tank.tga]])
			elseif role == 'HEALER' then
				lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
			elseif role == 'DAMAGER' then
				lfdrole:SetTexture([[Interface\AddOns\ElvUI\media\textures\dps.tga]])
			end
			
			lfdrole:Show()
		else
			lfdrole:Hide()
		end	
	end
	
	E.UpdateShards = function(self, event, unit, powerType)
		if(self.unit ~= unit or (powerType and powerType ~= 'SOUL_SHARDS')) then return end
		local num = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
		for i = 1, SHARD_BAR_NUM_SHARDS do
			if(i <= num) then
				self.SoulShards[i]:SetAlpha(1)
			else
				self.SoulShards[i]:SetAlpha(.2)
			end
		end
	end

	E.UpdateHoly = function(self, event, unit, powerType)
		if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
		local num = UnitPower(unit, SPELL_POWER_HOLY_POWER)
		for i = 1, MAX_HOLY_POWER do
			if(i <= num) then
				self.HolyPower[i]:SetAlpha(1)
			else
				self.HolyPower[i]:SetAlpha(.2)
			end
		end
	end	
	
	E.EclipseDirection = function(self)
		if ( GetEclipseDirection() == "sun" ) then
			self.Text:SetText(">")
			self.Text:SetTextColor(.2,.2,1,1)
		elseif ( GetEclipseDirection() == "moon" ) then
			self.Text:SetText("<")
			self.Text:SetTextColor(1,1,.3, 1)
		else
			self.Text:SetText("")
		end
	end	

	E.CustomCastTimeText = function(self, duration)
		self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
	end

	E.CustomCastDelayText = function(self, duration)
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
	end

	local FormatTime = function(s, reverse)
		local day, hour, minute, second = 86400, 3600, 60, 1
		if s >= day then
			return format("%dd", ceil(s / hour))
		elseif s >= hour then
			return format("%dh", ceil(s / hour))
		elseif s >= minute then
			return format("%dm", ceil(s / minute))
		elseif s >= minute / 12 then
			return floor(s)
		end
		
		if reverse and reverse == true and s >= second then
			return floor(s)
		else	
			return format("%.1f", s)
		end
	end
	
	local abs = math.abs --faster
	local CreateAuraTimer = function(self, elapsed)	
		if self.timeLeft then
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed >= 0.1 then
				if not self.first then
					self.timeLeft = self.timeLeft - self.elapsed
				else
					self.timeLeft = self.timeLeft - GetTime()
					self.first = false
				end
				if self.timeLeft > 0 then
					local time = FormatTime(self.timeLeft)
					if self.reverse then time = FormatTime(abs(self.timeLeft - self.duration), true) end
					self.text:SetText(time)
					if self.timeLeft <= 5 then
						self.text:SetTextColor(0.99, 0.31, 0.31)
					else
						self.text:SetTextColor(1, 1, 1)
					end
				else
					self.text:Hide()
					self:SetScript("OnUpdate", nil)
				end
				if (not self.debuff) and C["general"].classcolortheme == true then
					local r, g, b = self:GetParent():GetParent().Health.backdrop:GetBackdropBorderColor()
					self:SetBackdropBorderColor(r, g, b)
				end
				self.elapsed = 0
			end
		end
	end

	function E.PvPUpdate(self, elapsed)
		if(self.elapsed and self.elapsed > 0.2) then
			local unit = self.unit
			local time = GetPVPTimer()

			local min = format("%01.f", floor((time/1000)/60))
			local sec = format("%02.f", floor((time/1000) - min *60)) 
			if(self.PvP) then
				if(UnitIsPVPFreeForAll(unit)) then
					if time ~= 301000 and time ~= -1 then
						self.PvP:SetText(PVP.." ".."("..min..":"..sec..")")
					else
						self.PvP:SetText(PVP)
					end
				elseif UnitIsPVP(unit) then
					if time ~= 301000 and time ~= -1 then
						self.PvP:SetText(PVP.." ".."("..min..":"..sec..")")
					else
						self.PvP:SetText(PVP)
					end
				else
					self.PvP:SetText("")
				end
			end
			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	function E.PostCreateAura(element, button)
		local unit = button:GetParent():GetParent().unit
		local header = button:GetParent():GetParent():GetParent():GetName()
		
		if unit == "focus" or unit == "targettarget" or header == "ElvuiHealParty" then
			button:FontString(nil, C["media"].font, C["unitframes"].auratextscale*0.85, "THINOUTLINE")
		else
			button:FontString(nil, C["media"].font, C["unitframes"].auratextscale, "THINOUTLINE")
		end
		
		button:SetTemplate("Default")
		button.text:SetPoint("CENTER", E.Scale(0), E.mult)
		
		button.cd.noOCC = true		 	-- hide OmniCC CDs
		button.cd.noCooldownCount = true	-- hide CDC CDs
		
		button.cd:SetReverse()
		button.icon:Point("TOPLEFT", 2*E.ResScale, -2*E.ResScale)
		button.icon:Point("BOTTOMRIGHT", -2*E.ResScale, 2*E.ResScale)
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
		
		button.count:Point("BOTTOMRIGHT", E.mult, 1.5)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(C["media"].font, C["unitframes"].auratextscale*0.8, "THINOUTLINE")

		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:Point("TOPLEFT", button, "TOPLEFT", 2*E.ResScale, -2*E.ResScale)
		button.cd:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2*E.ResScale, 2*E.ResScale)
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 2)	   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.text:SetParent(button.overlayFrame)
		
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1,1,1,0.45)
		highlight:SetAllPoints(button.icon)	
	end

	function E.PostUpdateAura(icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
		local name, _, _, _, dtype, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, icon.filter)
		
		if(icon.debuff) then
			if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") and (not E.DebuffWhiteList[name]) then
				icon:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				icon.icon:SetDesaturated(true)
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				if (name == "Unstable Affliction" or name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
					icon:SetBackdropBorderColor(0.05, 0.85, 0.94)
				else
					icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
				end
				icon.icon:SetDesaturated(false)
			end
		else
			if (icon.isStealable or ((E.myclass == "PRIEST" or E.myclass == "SHAMAN" or E.myclass == "MAGE") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
				icon:SetBackdropBorderColor(237/255, 234/255, 142/255)
			else
				if C["general"].classcolortheme == true then
					local r, g, b = icon:GetParent():GetParent().Health.backdrop:GetBackdropBorderColor()
					icon:SetBackdropBorderColor(r, g, b)
				else
					icon:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				end			
			end
		end
		
		if duration and duration > 0 then
			if C["unitframes"].auratimer == true then
				icon.text:Show()
			else
				icon.text:Hide()
			end
		else
			icon.text:Hide()
		end
		
		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		
		
		if E.ReverseTimer and E.ReverseTimer[spellID] then 
			icon.reverse = true 
		else
			icon.reverse = false
		end

		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
	
	--Credit Monolit
	local ticks = {}
	local function SetCastTicks(self, num)
		if num and num > 0 then
			local d = self:GetWidth() / num
			for i = 1, num do
				if not ticks[i] then
					ticks[i] = self:CreateTexture(nil, 'OVERLAY')
					ticks[i]:SetTexture(C["media"].blank)
					ticks[i]:SetVertexColor(0, 0, 0)
					ticks[i]:SetWidth(2)
					ticks[i]:SetHeight(self:GetHeight())
				end
				ticks[i]:ClearAllPoints()
				ticks[i]:SetPoint("CENTER", self, "LEFT", d * i, 0)
				ticks[i]:Show()
			end
		else
			for _, tick in pairs(ticks) do
				tick:Hide()
			end
		end
	end

	function E.PostCastInterruptible(self, unit)
		if unit == "vehicle" then unit = "player" end
		if unit ~= "player" then
			if UnitCanAttack("player", unit) then
				self:SetStatusBarColor(unpack(C["unitframes"].nointerruptcolor))
			else
				self:SetStatusBarColor(unpack(C["unitframes"].castbarcolor))	
			end		
		end
	end
	
	function E.PostCastNotInterruptible(self, unit)
		self:SetStatusBarColor(unpack(C["unitframes"].castbarcolor))
	end
	
	E.PostCastStart = function(self, unit, name, rank, castid)
		if unit == "vehicle" then unit = "player" end
		self.Text:SetText(string.sub(name, 0, math.floor((((32/245) * self:GetWidth()) / C["unitframes"].fontsize) * 12)))
		
		if C["unitframes"].cbticks == true and unit == "player" then
			if E.ChannelTicks[name] then
				SetCastTicks(self, E.ChannelTicks[name])
			else
				for _, tick in pairs(ticks) do
					tick:Hide()
				end		
			end
		end
		
		if self.interrupt and unit ~= "player" then
			if UnitCanAttack("player", unit) then
				self:SetStatusBarColor(unpack(C["unitframes"].nointerruptcolor))
			else
				self:SetStatusBarColor(unpack(C["unitframes"].castbarcolor))	
			end
		else
			if C["general"].classcolortheme ~= true then
				self:SetStatusBarColor(unpack(C["unitframes"].castbarcolor))
			else
				self:SetStatusBarColor(self:GetParent().Health.backdrop:GetBackdropBorderColor())
				if self.bg then self.bg:SetBackdropBorderColor(self:GetStatusBarColor()) end
				if self.Icon and self.Icon.bg then self.Icon.bg:SetBackdropBorderColor(self:GetStatusBarColor()) end				
			end	
		end
	end
	
	E.ReputationPositionUpdate = function(self)
		if not self:GetName() then self = self:GetParent() end
		if not self.Reputation then return end
		self.Reputation:ClearAllPoints()
		
		local point, _, _, _, _ = MinimapMover:GetPoint()
		
		if point:match("BOTTOM") then
			if self.Experience and self.Experience:IsShown() then
				self.Reputation:Point("BOTTOMLEFT", self.Experience, "TOPLEFT", 0, 5)
			elseif self.Experience and self.Experience:IsShown() then
				self.Reputation:Point("TOPLEFT", self.Experience, "BOTTOMLEFT", 0, -5)
			else
				self.Reputation:Point("BOTTOMLEFT", ElvuiMinimapStatsLeft, "TOPLEFT", 2, 3)
			end
		else
			if self.Experience and self.Experience:IsShown() then
				self.Reputation:Point("TOPLEFT", self.Experience, "BOTTOMLEFT", 0, -5)
			elseif self.Experience and self.Experience:IsShown() then
				self.Reputation:Point("BOTTOMLEFT", self.Experience, "TOPLEFT", 0, 5)
			else
				self.Reputation:Point("TOPLEFT", ElvuiMinimapStatsLeft, "BOTTOMLEFT", 2, -3)
			end		
		end
	end

	E.PortraitUpdate = function(self, unit) 
		if C["unitframes"].charportraithealth == true then
			self:SetAlpha(0) self:SetAlpha(0.35) 
		end
		
		if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
			self:SetCamera(1)
		end	
	end	
	
	E.ComboDisplay = function(self, event, unit)
		if(unit == 'pet') then return end
		
		local cpoints = self.CPoints
		local cp
		if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
			cp = GetComboPoints('vehicle', 'target')
		else
			cp = GetComboPoints('player', 'target')
		end

		for i=1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1)
			else
				cpoints[i]:SetAlpha(0.15)
			end
		end
		
		if cpoints[1]:GetAlpha() == 1 then
			cpoints:Show()
		else
			cpoints:Hide()
		end
	end

	E.RestingIconUpdate = function (self)
		if IsResting() then
			self.Resting:Show()
		else
			self.Resting:Hide()
		end
	end

	E.UpdateDruidMana = function(self)
		if self.unit ~= "player" then return end

		local num, str = UnitPowerType("player")
		if num ~= 0 then
			local min = UnitPower("player", 0)
			local max = UnitPowerMax("player", 0)

			local percMana = min / max * 100
			if percMana <= C["unitframes"].lowThreshold then
				self.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
				E.Flash(self.ManaLevel, 0.3)
			else
				self.ManaLevel:SetText()
				E.StopFlash(self.ManaLevel)
			end

			if min ~= max then
				if self.Power.value:GetText() then
					self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", -3, 0)
					self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
				else
					self.DruidMana:SetPoint("LEFT", self.Health, "LEFT", 4, 1)
					self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
				end
			else
				self.DruidMana:SetText()
			end

			self.DruidMana:SetAlpha(1)
		else
			self.DruidMana:SetAlpha(0)
		end
	end

	function E.UpdateThreat(self, event, unit)
		if (self.unit ~= unit) or not unit then return end
		
		local threat = UnitThreatSituation(unit)
		if threat and threat > 1 then
			local r, g, b = GetThreatStatusColor(threat)			
			if self.shadow then
				self.shadow:SetBackdropBorderColor(r, g, b)
			elseif self.Health.backdrop then
				self.Health.backdrop:SetBackdropBorderColor(r, g, b)
				
				if self.Power and self.Power.backdrop then
					self.Power.backdrop:SetBackdropBorderColor(r, g, b)
				end
			end
		else		
			if self.shadow then
				self.shadow:SetBackdropBorderColor(0, 0, 0, 0)
			elseif self.Health.backdrop then
				self.Health.backdrop:SetTemplate("Default")
				
				if self.Power and self.Power.backdrop then
					self.Power.backdrop:SetTemplate("Default")
				end
			end
		end 
	end

	function E.AltPowerBarOnToggle(self)
		local unit = self:GetParent().unit or self:GetParent():GetParent().unit
		
		if unit == nil or unit ~= "player" then return end
		
		if self:IsShown() then
			for _, text in pairs(E.LeftDatatexts) do text:Hide() end
			local type = select(10, UnitAlternatePowerInfo(unit))
			if self.text and type then self.text:SetText(type..": 0%") end
		else
			for _, text in pairs(E.LeftDatatexts) do text:Show() end		
		end
		
		if E["elements"] and DPSAltPowerBar and E["elements"]["DPSAltPowerBar"] and E.CreatedMoveEleFrames["DPSAltPowerBar"] then 
			for _, text in pairs(E.LeftDatatexts) do text:Show() end	
		elseif	E["elements"] and HealAltPowerBar and E["elements"]["HealAltPowerBar"] and E.CreatedMoveEleFrames["HealAltPowerBar"] then 
			for _, text in pairs(E.LeftDatatexts) do text:Show() end	
		end
	end
	
	function E.AltPowerBarPostUpdate(self, min, cur, max)
		local perc = math.floor((cur/max)*100)
		
		if perc < 35 then
			self:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			self:SetStatusBarColor(1, 1, 0)
		else
			self:SetStatusBarColor(1, 0, 0)
		end
		
		local unit = self:GetParent().unit or self:GetParent():GetParent().unit
		
		if unit == "player" and self.text then 
			local type = select(10, UnitAlternatePowerInfo(unit))
					
			if perc > 0 then
				self.text:SetText(type..": "..format("%d%%", perc))
			else
				self.text:SetText(type..": 0%")
			end
		elseif unit and unit:find("boss%d") and self.text then
			self.text:SetTextColor(self:GetStatusBarColor())
			if not self:GetParent().Power.value:GetText() or self:GetParent().Power.value:GetText() == "" then
				self.text:Point("BOTTOMRIGHT", self:GetParent().Health, "BOTTOMRIGHT")
			else
				self.text:Point("RIGHT", self:GetParent().Power.value.value, "LEFT", 2, E.mult)	
			end
			if perc > 0 then
				self.text:SetText("|cffD7BEA5[|r"..format("%d%%", perc).."|cffD7BEA5]|r")
			else
				self.text:SetText(nil)
			end
		end
	end



	--------------------------------------------------------------------------------------------
	-- THE AURAWATCH FUNCTION ITSELF. HERE BE DRAGONS!
	--------------------------------------------------------------------------------------------

	E.countOffsets = {
		TOPLEFT = {6, 1},
		TOPRIGHT = {-6, 1},
		BOTTOMLEFT = {6, 1},
		BOTTOMRIGHT = {-6, 1},
		LEFT = {6, 1},
		RIGHT = {-6, 1},
		TOP = {0, 0},
		BOTTOM = {0, 0},
	}

	function E.CreateAuraWatchIcon(self, icon)
		if (icon.cd) then
			if C["raidframes"].buffindicatorcoloricons == true then
				icon.cd:SetReverse()
			end
		end 	
	end

	function E.createAuraWatch(self, unit)
		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("TOPLEFT", self.Health, 2, -2)
		auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
		auras.presentAlpha = 1
		auras.missingAlpha = 0
		auras.icons = {}
		auras.PostCreateIcon = E.CreateAuraWatchIcon

		if (not C["unitframes"].auratimer) then
			auras.hideCooldown = true
		end

		local buffs = {}
		if IsAddOnLoaded("Elvui_RaidDPS") then
			if (E.DPSBuffIDs[E.myclass]) then
				for key, value in pairs(E.DPSBuffIDs[E.myclass]) do
					if value["enabled"] == true then
						tinsert(buffs, value)
					end
				end
			end
		else
			if (E.HealerBuffIDs[E.myclass]) then
				for key, value in pairs(E.HealerBuffIDs[E.myclass]) do
					if value["enabled"] == true then
						tinsert(buffs, value)
					end
				end
			end
		end
		
		if E.PetBuffs[E.myclass] then
			for key, value in pairs(E.PetBuffs[E.myclass]) do
				tinsert(buffs, value)
			end
		end

		-- "Cornerbuffs"
		if (buffs) then
			for key, spell in pairs(buffs) do
				local icon = CreateFrame("Frame", nil, auras)
				icon.spellID = spell["id"]
				icon.anyUnit = spell["anyUnit"]
				icon.onlyShowMissing = spell["onlyShowMissing"]
				if spell["onlyShowMissing"] then
					icon.presentAlpha = 0
					icon.missingAlpha = 1
				else
					icon.presentAlpha = 1
					icon.missingAlpha = 0				
				end
				icon:SetWidth(E.Scale(C["raidframes"].buffindicatorsize))
				icon:SetHeight(E.Scale(C["raidframes"].buffindicatorsize))
				icon:SetPoint(spell["point"], 0, 0)
				
				if C["raidframes"].buffindicatorcoloricons == true then
					local tex = icon:CreateTexture(nil, "OVERLAY")
					tex:SetAllPoints(icon)
					tex:SetTexture(C["media"].blank)
					if (spell["color"]) then
						local color = spell["color"]
						tex:SetVertexColor(color.r, color.g, color.b)
					else
						tex:SetVertexColor(0.8, 0.8, 0.8)
					end
					icon.icon = tex
				else
					local _, _, image = GetSpellInfo(icon.spellID)
					local tex = icon:CreateTexture(nil, 'ARTWORK')
					tex:SetAllPoints(icon)
					tex:SetTexCoord(.18, .82, .18, .82)
					tex:SetTexture(image)
					icon.icon = tex
				end
				
				local border = icon:CreateTexture(nil, "BACKGROUND")
				border:Point("TOPLEFT", -E.mult, E.mult)
				border:Point("BOTTOMRIGHT", E.mult, -E.mult)
				border:SetTexture(C["media"].blank)
				border:SetVertexColor(0, 0, 0)

				local count = icon:CreateFontString(nil, "OVERLAY")
				count:SetFont(C["media"].uffont, C["raidframes"].buffindicatorsize + 3, "THINOUTLINE")
				count:SetPoint("CENTER", unpack(E.countOffsets[spell["point"]]))
				icon.count = count

				auras.icons[spell["id"]] = icon
			end
		end

		self.AuraWatch = auras
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs

	if not ORD then return end
	ORD.ShowDispelableDebuff = true
	ORD.FilterDispellableDebuff = true
	ORD.MatchBySpellName = true

	ORD:RegisterDebuffs(E.RaidDebuffs)	
	
	E.LoadUFFunctions = nil
end