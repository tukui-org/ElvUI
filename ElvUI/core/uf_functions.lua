------------------------------------------------------------------------
--	UnitFrame Functions
------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.LoadUFFunctions = function(layout)
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

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
		if header == "ElvuiHealR6R25" or (C["raidframes"].griddps == true and header == "ElvuiDPSR6R25") then 
			if inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if E.DebuffWhiteList[spellID] or E.TargetPVPOnly[spellID] then
					return true
				else
					return false
				end
			else
				if header == "ElvuiHealR6R25" and E.DebuffHealerWhiteList[spellID] then
					return true
				elseif header == "ElvuiDPSR6R25" and E.DebuffDPSWhiteList[spellID] then
					return true
				else
					return false
				end
			end	
		elseif (unit and unit:find("arena%d")) then --Arena frames
			if dtype then
				if E.DebuffWhiteList[spellID] then
					return true
				else
					return false
				end			
			else
				if E.ArenaBuffWhiteList[spellID] then
					return true
				else
					return false
				end		
			end
		elseif unit == "target" then --Target Only
			if C["auras"].playerdebuffsonly == true then
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
				elseif E.DebuffWhiteList[spellID] or (inInstance and ((instanceType == "pvp" or instanceType == "arena") and E.TargetPVPOnly[spellID])) then
					return true
				else
					return false
				end
			else
				return true
			end
		else --Everything else
			if unit ~= "player" and unit ~= "targettarget" and unit ~= "focus" and C["auras"].arenadebuffs == true and inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if E.DebuffWhiteList[spellID] or E.TargetPVPOnly[spellID] then
					return true
				else
					return false
				end
			else
				if E.DebuffBlacklist[spellID] then
					return false
				else
					return true
				end
			end
		end
	end

	E.PostUpdateHealth = function(health, unit, min, max)
		local header = health:GetParent():GetParent():GetName()

		if C["general"].classcolortheme == true then
			local r, g, b = health:GetStatusBarColor()
			health:GetParent().FrameBorder:SetBackdropBorderColor(r,g,b)
			
			if health:GetParent().PowerFrame then
				health:GetParent().PowerFrame:SetBackdropBorderColor(r,g,b)
			end
			
			if unit == "target" then
				if health:GetParent().CPoints.FrameBackdrop then
					health:GetParent().CPoints.FrameBackdrop:SetBackdropBorderColor(r,g,b)
				end
			elseif unit and unit:find("boss%d") then
				if health:GetParent().AltPowerBar.FrameBackdrop then
					health:GetParent().AltPowerBar.FrameBackdrop:SetBackdropBorderColor(r,g,b)
				end
			elseif unit and unit:find("arena%d") then
				if health:GetParent().Trinketbg then
					health:GetParent().Trinketbg:SetBackdropBorderColor(r,g,b)
				end
			end
		end
		
		if unit and unit:find("boss%d") then
			local curpow = UnitPower(unit)
			if curpow == 0 then
				health.value:ClearAllPoints()
				health.value:SetPoint("LEFT", health, "LEFT", E.Scale(2), E.Scale(1))				
			else
				health.value:ClearAllPoints()
				health.value:SetPoint("TOPLEFT", health, "TOPLEFT", E.Scale(2), E.Scale(-2))		
			end		
		end
		
		--Setup color health by value option
		if C["unitframes"].healthcolorbyvalue == true then
			if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) and unit == "target" then
				health:SetStatusBarColor(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 0.3)		
			elseif not UnitIsConnected(unit) then
				health:SetStatusBarColor(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 0.3)				
			else
				local perc = (min/max)*100
				if(perc <= 50 and perc >= 26) then
					health:SetStatusBarColor(224/255, 221/255, 9/255, 1)
					health.bg:SetTexture(224/255, 221/255, 9/255, 0.1)
				elseif(perc < 26) then
					health:SetStatusBarColor(255/255, 13/255, 9/255, 1)
					health.bg:SetTexture(255/255, 13/255, 9/255, 0.1)
				else
					if C["unitframes"].classcolor ~= true then
						health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))
						health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))		
					else
						if (UnitIsPlayer(unit)) then
							local class = select(2, UnitClass(unit))
							if not class then return end
							local c = E.oUF_colors.class[class]
							health:SetStatusBarColor(c[1], c[2], c[3], 1)
							health.bg:SetTexture(c[1], c[2], c[3], 0.3)	
						else
							local reaction = UnitReaction(unit, 'player')
							if not reaction then return end
							local c = E.oUF_colors.reaction[reaction]
							health:SetStatusBarColor(c[1], c[2], c[3], 1)
							health.bg:SetTexture(c[1], c[2], c[3], 0.3)						
						end
					end
				end
			end
		else
			if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) and unit == "target" then
				health:SetStatusBarColor(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 0.3)		
			elseif not UnitIsConnected(unit) then
				health:SetStatusBarColor(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(E.oUF_colors.tapped[1], E.oUF_colors.tapped[2], E.oUF_colors.tapped[3], 0.3)						
			else
				if C["unitframes"].classcolor ~= true then
					health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))
					health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))		
				else		
					if (UnitIsPlayer(unit)) then
						local class = select(2, UnitClass(unit))
						if not class then return end
						local c = E.oUF_colors.class[class]
						health:SetStatusBarColor(c[1], c[2], c[3], 1)
						health.bg:SetTexture(c[1], c[2], c[3], 0.3)	
					else
						local reaction = UnitReaction(unit, 'player')
						if not reaction then return end
						local c = E.oUF_colors.reaction[reaction]
						health:SetStatusBarColor(c[1], c[2], c[3], 1)
						health.bg:SetTexture(c[1], c[2], c[3], 0.3)						
					end			
				end
			end
		end
		
		--Small frames don't have health value display
		if not health.value then return end
		
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
			if (header == "ElvuiHealR6R25" or header == "ElvuiDPSR6R25" or header == "ElvuiHealR26R40" or header == "ElvuiDPSR26R40") and C["raidframes"].hidenonmana == true then
				local powertype, _ = UnitPowerType(unit)
				if powertype ~= SPELL_POWER_MANA then
					health:SetHeight(health:GetParent():GetHeight())
				else
					if header == "ElvuiHealR6R25" then
						health:SetHeight(health:GetParent():GetHeight() * 0.85)
					elseif header == "ElvuiDPSR6R25" then
						if C["raidframes"].griddps ~= true then
							health:SetHeight(health:GetParent():GetHeight() * 0.75)
						else
							health:SetHeight(health:GetParent():GetHeight() * 0.83)
						end
					else
						health:SetHeight(health:GetParent():GetHeight())	
					end
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

	E.CheckPower = function(self, event)
		local unit = self.unit
		local powertype, _ = UnitPowerType(unit)
		if powertype ~= SPELL_POWER_MANA then
			self.Health:SetHeight(self.Health:GetParent():GetHeight())
			if self.Power then
				self.Power:Hide()
			end
		else
			if IsAddOnLoaded("ElvUI_Heal_Layout") and self:GetParent():GetName() == "ElvuiHealR6R25" then
					self.Health:SetHeight(self.Health:GetParent():GetHeight() * 0.85)
			elseif self:GetParent():GetName() == "ElvuiDPSR6R25" then
				if C["raidframes"].griddps ~= true then
					self.Health:SetHeight(self.Health:GetParent():GetHeight() * 0.75)
				else
					self.Health:SetHeight(self.Health:GetParent():GetHeight() * 0.83)
				end
			else
				self.Health:SetHeight(self.Health:GetParent():GetHeight())	
			end
			if self.Power then
				self.Power:Show()
			end
		end	
	end

	E.PostNamePosition = function(self)
		self.Name:ClearAllPoints()
		if (self.Power.value:GetText() and UnitIsPlayer("target") and C["unitframes"].targetpowerplayeronly == true) or (self.Power.value:GetText() and C["unitframes"].targetpowerplayeronly == false) then
			self.Name:SetPoint("CENTER", self.health, "CENTER", 0, 1)
		else
			self.Power.value:SetAlpha(0)
			self.Name:SetPoint("LEFT", self.health, "LEFT", 4, 1)
		end
	end

	E.PreUpdatePower = function(power, unit)
		local _, pType = UnitPowerType(unit)
		
		local color = E.oUF_colors.power[pType]
		if color then
			power:SetStatusBarColor(color[1], color[2], color[3])
		end
	end
	
	E.PostUpdatePower = function(power, unit, min, max)
		local self = power:GetParent()
		local header = power:GetParent():GetParent():GetName()
		local pType, pToken, altR, altG, altB = UnitPowerType(unit)
		local color = E.oUF_colors.power[pToken]
		
		if header == "ElvuiDPSR6R25" or header == "ElvuiHealR6R25" then
			if pType ~= SPELL_POWER_MANA then
				power:Hide()
			else
				power:Show()
			end
		end
		
		if not power.value then return end
		
		if color then
			power.value:SetTextColor(color[1], color[2], color[3])
		else
			power.value:SetTextColor(altR, altG, altB, 1)
		end	
			
		if min == 0 then 
			power.value:SetText("") 
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
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max), E.ShortValue(max - (max - min)))
							else
								power.value:SetFormattedText("%s |cffD7BEA5-|r %d%%", E.ShortValue(max - (max - min)), floor(min / max * 100))
							end						
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
		
		if self.Name then
			if unit == "target" then E.PostNamePosition(self, power) end
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
					local r, g, b = self:GetParent():GetParent().FrameBorder:GetBackdropBorderColor()
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
				local factionGroup = UnitFactionGroup(unit)
				if(UnitIsPVPFreeForAll(unit)) then
					if time ~= 301000 and time ~= -1 then
						self.PvP:SetText(PVP.." ".."("..min..":"..sec..")")
					else
						self.PvP:SetText(PVP)
					end
				elseif(factionGroup and UnitIsPVP(unit)) then
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
		
		if header == "ElvuiHealR6R25" or (header == "ElvuiDPSR6R25" and C["raidframes"].griddps == true) then
			button:EnableMouse(false)
			button:SetFrameLevel(button:GetParent():GetParent().Power:GetFrameLevel() + 4)
		end
		
		if unit == "focus" or unit == "targettarget" or header == "ElvuiHealR6R25" or header == "ElvuiDPSR6R25" or header == "ElvuiHealParty" then
			button:FontString(nil, C["media"].font, C["auras"].auratextscale*0.85, "THINOUTLINE")
		else
			button:FontString(nil, C["media"].font, C["auras"].auratextscale, "THINOUTLINE")
		end
		
		button:SetTemplate("Default")
		button.text:SetPoint("CENTER", E.Scale(0), E.mult)
		
		button.cd.noOCC = true		 	-- hide OmniCC CDs
		button.cd.noCooldownCount = true	-- hide CDC CDs
		
		button.cd:SetReverse()
		button.icon:SetPoint("TOPLEFT", E.Scale(2), E.Scale(-2))
		button.icon:SetPoint("BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
		
		button.count:SetPoint("BOTTOMRIGHT", E.mult, E.Scale(1.5))
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(C["media"].font, C["auras"].auratextscale*0.8, "THINOUTLINE")

		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", E.Scale(2), E.Scale(-2))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
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
			if (icon.isStealable or (E.myclass == "PRIEST" and dtype == "Magic")) and not UnitIsFriend("player", unit) then
				icon:SetBackdropBorderColor(237/255, 234/255, 142/255)
			else
				if C["general"].classcolortheme == true then
					local r, g, b = icon:GetParent():GetParent().FrameBorder:GetBackdropBorderColor()
					icon:SetBackdropBorderColor(r, g, b)
				else
					icon:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				end			
			end
		end
		
		if duration and duration > 0 then
			if C["auras"].auratimer == true then
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
		
		
		if E.ReverseTimerSpells and E.ReverseTimerSpells[spellID] then icon.reverse = true end
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end

	E.HidePortrait = function(self, event)
		if self.unit == "target" then
			if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
				self.PFrame:SetAlpha(0)
			else
				self.PFrame:SetAlpha(1)
			end
		end
	end

	E.PostCastStart = function(self, unit, name, rank, castid)
		if unit == "vehicle" then unit = "player" end
		--Fix blank castbar with opening text
		if name == "Opening" then
			self.Text:SetText(OPENING)
		else
			self.Text:SetText(string.sub(name, 0, 25))
		end
		
		if self.interrupt and unit ~= "player" then
			if UnitCanAttack("player", unit) then
				self:SetStatusBarColor(unpack(C["castbar"].nointerruptcolor))
			else
				self:SetStatusBarColor(unpack(C["castbar"].castbarcolor))	
			end
		else
			if C["castbar"].classcolor ~= true or unit ~= "player" then
				self:SetStatusBarColor(unpack(C["castbar"].castbarcolor))
			else
				self:SetStatusBarColor(unpack(oUF.colors.class[select(2, UnitClass(unit))]))
			end	
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

	E.MoveBuffs = function(self, login)
		local parent = self:GetParent()
		if login then
			self:SetScript("OnUpdate", nil)
		end
		
		if self:IsShown() then
			if self == parent.EclipseBar then
				parent.FlashInfo:Hide()
				parent.PvP:SetAlpha(0)
			end
			parent.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
			
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerBuffs"] and DPSElementsCharPos["DPSPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerBuffs"] and HealElementsCharPos["HealPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerDebuffs"] and DPSElementsCharPos["DPSPlayerDebuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerDebuffs"] and HealElementsCharPos["HealPlayerDebuffs"]["moved"] == true) then return end
			
			if parent.Debuffs then 
				parent.Debuffs:ClearAllPoints()
				if parent.Debuffs then parent.Debuffs:SetPoint("BOTTOM", parent.Health, "TOP", 0, E.Scale(17)) end	
			end		
		else
			if self == parent.EclipseBar then
				parent.FlashInfo:Show()
				parent.PvP:SetAlpha(1)
			end
			parent.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(4))
			
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerBuffs"] and DPSElementsCharPos["DPSPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerBuffs"] and HealElementsCharPos["HealPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerDebuffs"] and DPSElementsCharPos["DPSPlayerDebuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerDebuffs"] and HealElementsCharPos["HealPlayerDebuffs"]["moved"] == true) then return end
			
			if parent.Debuffs then 
				parent.Debuffs:ClearAllPoints()
				parent.Debuffs:SetPoint("BOTTOM", parent.Health, "TOP", 0, E.Scale(6))
			end	
		end
	end

	local starfirename = select(1, GetSpellInfo(2912))
	E.EclipseDirection = function(self)
		if ( GetEclipseDirection() == "sun" ) then
			self.Text:SetText(starfirename.."!")
			self.Text:SetTextColor(.2,.2,1,1)
		elseif ( GetEclipseDirection() == "moon" ) then
			self.Text:SetText(POWER_TYPE_WRATH.."!")
			self.Text:SetTextColor(1,1,.3, 1)
		else
			self.Text:SetText("")
		end
	end

	E.ToggleBars = function(self)
		local parent = self:GetParent()
		local unit = parent.unit
		if unit == "vehicle" then unit = "player" end
		if unit ~= "player" then return end
		
		if IsAddOnLoaded("ElvUI_Dps_Layout") then
			Elv_player = ElvDPS_player
		elseif IsAddOnLoaded("ElvUI_Heal_Layout") then
			Elv_player = ElvHeal_player
		end
		
		if self == Elv_player.EclipseBar and (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then 
			Elv_player.EclipseBar:SetScript("OnUpdate", function() 
				if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
					if Elv_player.EclipseBar:IsShown() then
						Elv_player.EclipseBar:Hide()
						Elv_player.EclipseBar:SetScript("OnUpdate", nil)
					end
				else
					Elv_player.EclipseBar:Show()
					Elv_player.EclipseBar:SetScript("OnUpdate", nil)			
				end
			end) 
			return 
		end
		
		if UnitHasVehicleUI("player") then
			self:Hide()
		else	
			self:Show()
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
			for i=1, MAX_COMBO_POINTS do
				cpoints[i]:Show()
			end
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and ((DPSElementsCharPos["DPSComboBar"] and DPSElementsCharPos["DPSComboBar"]["moved"] == true) or (DPSElementsCharPos["DPSTargetBuffs"] and DPSElementsCharPos["DPSTargetBuffs"]["moved"] == true))) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and ((HealElementsCharPos["HealComboBar"] and HealElementsCharPos["HealComboBar"]["moved"] == true) or (HealElementsCharPos["HealTargetBuffs"] and HealElementsCharPos["HealTargetBuffs"]["moved"] == true))) then return end
			self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
			if self.Buffs then self.Buffs:ClearAllPoints() self.Buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, E.Scale(17)) end	
		else
			for i=1, MAX_COMBO_POINTS do
				cpoints[i]:Hide()
			end
			if (IsAddOnLoaded("ElvUI_Dps_Layout") and DPSElementsCharPos and ((DPSElementsCharPos["DPSComboBar"] and DPSElementsCharPos["DPSComboBar"]["moved"] == true) or (DPSElementsCharPos["DPSTargetBuffs"] and DPSElementsCharPos["DPSTargetBuffs"]["moved"] == true))) then return end
			if (IsAddOnLoaded("ElvUI_Heal_Layout") and HealElementsCharPos and ((HealElementsCharPos["HealComboBar"] and HealElementsCharPos["HealComboBar"]["moved"] == true) or (HealElementsCharPos["HealTargetBuffs"] and HealElementsCharPos["HealTargetBuffs"]["moved"] == true))) then return end
			self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(4))	
			if self.Buffs then self.Buffs:ClearAllPoints() self.Buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, E.Scale(4)) end	
		end
	end

	E.MLAnchorUpdate = function (self)
		if self.Leader:IsShown() then
			self.MasterLooter:SetPoint("TOPLEFT", 14, 8)
		else
			self.MasterLooter:SetPoint("TOPLEFT", 2, 8)
		end
	end

	E.RestingIconUpdate = function (self)
		if IsResting() then
			self.Resting:Show()
		else
			self.Resting:Hide()
		end
	end

	E.UpdateReputation = function(self, event, unit, bar, min, max, value, name, id)
		if not name then return end
		local name, id = GetWatchedFactionInfo()
		bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
		
		local cur = value - min
		local total = max - min
		
		bar.Text:SetFormattedText(name..': '..E.ShortValue(cur)..' / '..E.ShortValue(total)..' <%d%%>', (cur / total) * 100)
	end

	local delay = 0
	E.UpdateManaLevel = function(self, elapsed)
		delay = delay + elapsed
		if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
		delay = 0

		local percMana = UnitMana("player") / UnitManaMax("player") * 100

		if percMana <= 20 then
			self.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
			E.Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			E.StopFlash(self)
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
				self.FlashInfo.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
				E.Flash(self.FlashInfo, 0.3)
			else
				self.FlashInfo.ManaLevel:SetText()
				E.StopFlash(self.FlashInfo)
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
		if (self.unit ~= unit) or (unit == "target" or unit == "focus" or unit == "focustarget" or unit == "targettarget") then return end
		if not self.unit then return end
		if not unit then return end
		
		local threat = UnitThreatSituation(self.unit)
		if threat and threat > 1 then
			local r, g, b = GetThreatStatusColor(threat)
			if self.FrameBorder.shadow then
				self.FrameBorder.shadow:SetBackdropBorderColor(r,g,b,0.85)
				if self.PowerFrame and self.PowerFrame.shadow then
					self.PowerFrame.shadow:SetBackdropBorderColor(r,g,b,0.85)
				end
				if self.PFrame and self.PFrame.shadow then
					self.PFrame.shadow:SetBackdropBorderColor(r, g, b, 1)
				end
			else
				if self.HealthBorder then
					self.HealthBorder:SetBackdropBorderColor(r, g, b, 1)
				end
				if self.PFrame then
					self.PFrame:SetBackdropBorderColor(r, g, b, 1)
				end
				self.FrameBorder:SetBackdropBorderColor(r, g, b, 1)
			end
		else
			if self.FrameBorder.shadow then
				self.FrameBorder.shadow:SetBackdropBorderColor(0,0,0,0.75)
				if self.PowerFrame and self.PowerFrame.shadow then
					self.PowerFrame.shadow:SetBackdropBorderColor(0,0,0,0.75)
				end
				if self.PFrame and self.PFrame.shadow then
					self.PFrame.shadow:SetBackdropBorderColor(0, 0, 0, 1)
				end
			else
				self.FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				if self.HealthBorder then
					self.HealthBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				end
				if self.PFrame then
					self.PFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				end
			end
		end 
	end

	E.updateAllElements = function(frame)
		for _, v in ipairs(frame.__elements) do
			v(frame, "UpdateElement", frame.unit)
		end
		
		local header = frame:GetParent():GetName()
		if (header == "ElvuiDPSR6R25" or header == "ElvuiHealR6R25") and C["raidframes"].hidenonmana == true then
			local powertype, _ = UnitPowerType(frame.unit)
			if powertype ~= SPELL_POWER_MANA then
				frame.Health:SetHeight(frame.Health:GetParent():GetHeight())
				if frame.Power then
					frame.Power:Hide()
				end
			else
				if IsAddOnLoaded("ElvUI_Heal_Layout") and frame:GetParent():GetName() == "ElvuiHealR6R25" then
					frame.Health:SetHeight(frame.Health:GetParent():GetHeight() * 0.85)
				elseif frame:GetParent():GetName() == "ElvuiDPSR6R25" then
					if C["raidframes"].griddps ~= true then
						frame.Health:SetHeight(frame.Health:GetParent():GetHeight() * 0.75)
					else
						frame.Health:SetHeight(frame.Health:GetParent():GetHeight() * 0.83)
					end
				else
					frame.Health:SetHeight(frame.Health:GetParent():GetHeight())	
				end
				if frame.Power then
					frame.Power:Show()
				end
			end		
		end
	end

	function E.ExperienceText(self, unit, min, max)
		local rested = GetXPExhaustion()
		if rested then 
			self.Text:SetFormattedText('XP: '..E.ShortValue(min)..' / '..E.ShortValue(max)..' <%d%%>  R: +'..E.ShortValue(rested)..' <%d%%>', min / max * 100, rested / max * 100)
		else
			self.Text:SetFormattedText('XP: '..E.ShortValue(min)..' / '..E.ShortValue(max)..' <%d%%>', min / max * 100)
		end
	end
	
	function E.AltPowerBarOnToggle(self)
		local unit = self:GetParent().unit or self:GetParent():GetParent().unit
		
		if unit == nil or unit ~= "player" then return end
		
		if self:IsShown() then
			for _, text in pairs(E.LeftDatatexts) do text:Hide() end
			local type = select(10, UnitAlternatePowerInfo(unit))
			if self.text and type then self.text:SetText(type..": "..E.ValColor.."0%") end
		else
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
		
		if unit == nil or unit ~= "player" then return end --Only want to see this on the players bar
		
		local type = select(10, UnitAlternatePowerInfo(unit))
				
		if self.text and perc > 0 then
			self.text:SetText(type..": "..E.ValColor..format("%d%%", perc))
		elseif self.text then
			self.text:SetText(type..": "..E.ValColor.."0%")
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
			icon.cd:SetReverse()
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

		if (not C["auras"].auratimer) then
			auras.hideCooldown = true
		end

		local buffs = {}
		if IsAddOnLoaded("ElvUI_Dps_Layout") then
			if (E.DPSBuffIDs["ALL"]) then
				for key, value in pairs(E.DPSBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (E.DPSBuffIDs[E.myclass]) then
				for key, value in pairs(E.DPSBuffIDs[E.myclass]) do
					tinsert(buffs, value)
				end
			end	
		else
			if (E.HealerBuffIDs["ALL"]) then
				for key, value in pairs(E.HealerBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (E.HealerBuffIDs[E.myclass]) then
				for key, value in pairs(E.HealerBuffIDs[E.myclass]) do
					tinsert(buffs, value)
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
				icon.spellID = spell[1]
				icon.anyUnit = spell[4]
				icon:SetWidth(E.Scale(C["auras"].buffindicatorsize))
				icon:SetHeight(E.Scale(C["auras"].buffindicatorsize))
				icon:SetPoint(spell[2], 0, 0)

				local tex = icon:CreateTexture(nil, "OVERLAY")
				tex:SetAllPoints(icon)
				tex:SetTexture(C["media"].blank)
				if (spell[3]) then
					tex:SetVertexColor(unpack(spell[3]))
				else
					tex:SetVertexColor(0.8, 0.8, 0.8)
				end

				local count = icon:CreateFontString(nil, "OVERLAY")
				count:SetFont(C["media"].uffont, 8, "THINOUTLINE")
				count:SetPoint("CENTER", unpack(E.countOffsets[spell[2]]))
				icon.count = count

				auras.icons[spell[1]] = icon
			end
		end

		self.AuraWatch = auras
	end
end