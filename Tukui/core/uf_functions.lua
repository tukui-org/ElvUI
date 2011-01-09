------------------------------------------------------------------------
--	UnitFrame Functions
------------------------------------------------------------------------
local TukuiDB = TukuiDB
local TukuiCF = TukuiCF
local tukuilocal = tukuilocal

TukuiDB.LoadUFFunctions = function(layout)
	function TukuiDB.SpawnMenu(self)
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

	TukuiDB.Fader = function(self, arg1, arg2)	
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

	TukuiDB.AuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)	
		local header = icon:GetParent():GetParent():GetParent():GetName()
		local inInstance, instanceType = IsInInstance()
		icon.owner = caster
		icon.isStealable = isStealable
		if header == "oUF_TukuiHealR6R25" or (TukuiCF["raidframes"].griddps == true and header == "oUF_TukuiDPSR6R25") then 
			if inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if DebuffWhiteList[name] or TargetPVPOnly[name] then
					return true
				else
					return false
				end
			else
				if header == "oUF_TukuiHealR6R25" and DebuffHealerWhiteList[name] then
					return true
				elseif header == "oUF_TukuiDPSR6R25" and DebuffDPSWhiteList[name] then
					return true
				else
					return false
				end
			end	
		elseif (unit and unit:find("arena%d")) then --Arena frames
			if dtype then
				if DebuffWhiteList[name] then
					return true
				else
					return false
				end			
			else
				if ArenaBuffWhiteList[name] then
					return true
				else
					return false
				end		
			end
		elseif unit == "target" then --Target Only
			if TukuiCF["auras"].playerdebuffsonly == true then
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
				elseif DebuffWhiteList[name] or (inInstance and ((instanceType == "pvp" or instanceType == "arena") and TargetPVPOnly[name])) then
					return true
				else
					return false
				end
			else
				return true
			end
		else --Everything else
			if unit ~= "player" and unit ~= "targettarget" and unit ~= "focus" and TukuiCF["auras"].arenadebuffs == true and inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if DebuffWhiteList[name] or TargetPVPOnly[name] then
					return true
				else
					return false
				end
			else
				if DebuffBlacklist[name] then
					return false
				else
					return true
				end
			end
		end
	end

	TukuiDB.PostUpdateHealth = function(health, unit, min, max)
		local header = health:GetParent():GetParent():GetName()
		
		--Setup color health by value option
		if TukuiCF["unitframes"].healthcolorbyvalue == true then
			if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) and unit == "target" then
				health:SetStatusBarColor(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 0.3)		
			elseif not UnitIsConnected(unit) then
				health:SetStatusBarColor(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 0.3)				
			else
				local perc = (min/max)*100
				if(perc <= 50 and perc >= 26) then
					health:SetStatusBarColor(224/255, 221/255, 9/255, 1)
					health.bg:SetTexture(224/255, 221/255, 9/255, 0.1)
				elseif(perc < 26) then
					health:SetStatusBarColor(255/255, 13/255, 9/255, 1)
					health.bg:SetTexture(255/255, 13/255, 9/255, 0.1)
				else
					if TukuiCF["unitframes"].classcolor ~= true then
						health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
						health.bg:SetTexture(unpack(TukuiCF["unitframes"].healthbackdropcolor))		
					else
						if (UnitIsPlayer(unit)) then
							local class = select(2, UnitClass(unit))
							if not class then return end
							local c = TukuiDB.oUF_colors.class[class]
							health:SetStatusBarColor(c[1], c[2], c[3], 1)
							health.bg:SetTexture(c[1], c[2], c[3], 0.3)	
						else
							local reaction = UnitReaction(unit, 'player')
							if not reaction then return end
							local c = TukuiDB.oUF_colors.reaction[reaction]
							health:SetStatusBarColor(c[1], c[2], c[3], 1)
							health.bg:SetTexture(c[1], c[2], c[3], 0.3)						
						end
					end
				end
			end
		else
			if (UnitIsTapped("target")) and (not UnitIsTappedByPlayer("target")) and unit == "target" then
				health:SetStatusBarColor(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 0.3)		
			elseif not UnitIsConnected(unit) then
				health:SetStatusBarColor(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 1)
				health.bg:SetTexture(TukuiDB.oUF_colors.tapped[1], TukuiDB.oUF_colors.tapped[2], TukuiDB.oUF_colors.tapped[3], 0.3)						
			else
				if TukuiCF["unitframes"].classcolor ~= true then
					health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
					health.bg:SetTexture(unpack(TukuiCF["unitframes"].healthbackdropcolor))		
				else		
					if (UnitIsPlayer(unit)) then
						local class = select(2, UnitClass(unit))
						if not class then return end
						local c = TukuiDB.oUF_colors.class[class]
						health:SetStatusBarColor(c[1], c[2], c[3], 1)
						health.bg:SetTexture(c[1], c[2], c[3], 0.3)	
					else
						local reaction = UnitReaction(unit, 'player')
						if not reaction then return end
						local c = TukuiDB.oUF_colors.reaction[reaction]
						health:SetStatusBarColor(c[1], c[2], c[3], 1)
						health.bg:SetTexture(c[1], c[2], c[3], 0.3)						
					end			
				end
			end
		end
		
		--Small frames don't have health value display
		if not health.value then return end
		
		if header == "oUF_TukuiHealParty" or header == "oUF_TukuiDPSParty" or header == "oUF_TukuiHealR6R25" or header == "oUF_TukuiDPSR6R25" or header == "oUF_TukuiHealR26R40" or header == "oUF_TukuiDPSR26R40" then --Raid/Party Layouts
			if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
				if not UnitIsConnected(unit) then
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max and TukuiCF["raidframes"].healthdeficit == true then
					health.value:SetText("|cff559655-"..TukuiDB.ShortValueNegative(max-min).."|r")
				else
					health.value:SetText("")
				end
			end
			if (header == "oUF_TukuiHealR6R25" or header == "oUF_TukuiDPSR6R25" or header == "oUF_TukuiHealR26R40" or header == "oUF_TukuiDPSR26R40") and TukuiCF["raidframes"].hidenonmana == true then
				local powertype, _ = UnitPowerType(unit)
				if powertype ~= SPELL_POWER_MANA then
					health:SetHeight(health:GetParent():GetHeight())
				else
					if header == "oUF_TukuiHealR6R25" then
						health:SetHeight(health:GetParent():GetHeight() * 0.85)
					elseif header == "oUF_TukuiDPSR6R25" then
						if TukuiCF["raidframes"].griddps ~= true then
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
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max then
					local r, g, b
					r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						if TukuiCF["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", TukuiDB.ShortValue(min), TukuiDB.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif unit == "target" or unit == "focus" or (unit and unit:find("boss%d")) then
						if TukuiCF["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", TukuiDB.ShortValue(min), TukuiDB.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", TukuiDB.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..TukuiDB.ShortValue(min).."|r")
					else
						health.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", TukuiDB.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
					end
				else
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						health.value:SetText("|cff559655"..TukuiDB.ShortValue(max).."|r")
					elseif unit == "target" or unit == "focus" or (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..TukuiDB.ShortValue(max).."|r")
					else
						health.value:SetText("|cff559655"..TukuiDB.ShortValue(max).."|r")
					end
				end
			end
		end
	end

	TukuiDB.CheckPower = function(self, event)
		local unit = self.unit
		local powertype, _ = UnitPowerType(unit)
		if powertype ~= SPELL_POWER_MANA then
			self.Health:SetHeight(self.Health:GetParent():GetHeight())
			if self.Power then
				self.Power:Hide()
			end
		else
			if IsAddOnLoaded("Tukui_Heal_Layout") and self:GetParent():GetName() == "oUF_TukuiHealR6R25" then
					self.Health:SetHeight(self.Health:GetParent():GetHeight() * 0.85)
			elseif self:GetParent():GetName() == "oUF_TukuiDPSR6R25" then
				if TukuiCF["raidframes"].griddps ~= true then
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

	TukuiDB.PostNamePosition = function(self)
		self.Name:ClearAllPoints()
		if (self.Power.value:GetText() and UnitIsPlayer("target") and TukuiCF["unitframes"].targetpowerplayeronly == true) or (self.Power.value:GetText() and TukuiCF["unitframes"].targetpowerplayeronly == false) then
			self.Name:SetPoint("CENTER", self.health, "CENTER", 0, 1)
		else
			self.Power.value:SetAlpha(0)
			self.Name:SetPoint("LEFT", self.health, "LEFT", 4, 1)
		end
	end

	TukuiDB.PreUpdatePower = function(power, unit)
		local _, pType = UnitPowerType(unit)
		
		local color = TukuiDB.oUF_colors.power[pType]
		if color then
			power:SetStatusBarColor(color[1], color[2], color[3])
		end
	end

	TukuiDB.PostUpdatePower = function(power, unit, min, max)
		local self = power:GetParent()
		local header = power:GetParent():GetParent():GetName()
		local pType, pToken = UnitPowerType(unit)
		local color = TukuiDB.oUF_colors.power[pToken]
		
		if header == "oUF_TukuiDPSR6R25" or header == "oUF_TukuiHealR6R25" then
			if pType ~= SPELL_POWER_MANA then
				power:Hide()
			else
				power:Show()
			end
		end
		
		if not power.value then return end
		
		if color then
			power.value:SetTextColor(color[1], color[2], color[3])
		end	
			
		if min == 0 then 
				power.value:SetText("") 
		else
			if not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
				power.value:SetText()
			elseif UnitIsDead(unit) or UnitIsGhost(unit) then
				power.value:SetText()
			else
				if min ~= max then
					if pType == 0 then
						if unit == "target" then
							if TukuiCF["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", TukuiDB.ShortValue(max - (max - min)), TukuiDB.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), TukuiDB.ShortValue(max - (max - min)))
							end
						elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
							if TukuiCF["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", TukuiDB.ShortValue(max - (max - min)), TukuiDB.ShortValue(max))
							else
								power.value:SetFormattedText("%d%%", floor(min / max * 100))
							end
						elseif (unit and unit:find("arena%d")) then
							power.value:SetText(TukuiDB.ShortValue(min))
						else
							if TukuiCF["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", TukuiDB.ShortValue(max - (max - min)), TukuiDB.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), TukuiDB.ShortValue(max - (max - min)))
							end
						end
					else
						power.value:SetText(max - (max - min))
					end
				else
					if unit == "pet" or unit == "target" or (unit and unit:find("arena%d")) then
						power.value:SetText(TukuiDB.ShortValue(min))
					else
						power.value:SetText(TukuiDB.ShortValue(min))
					end
				end
			end
		end
		
		if self.Name then
			if unit == "target" then TukuiDB.PostNamePosition(self, power) end
		end
	end

	TukuiDB.CustomCastTimeText = function(self, duration)
		self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
	end

	TukuiDB.CustomCastDelayText = function(self, duration)
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
	end

	local FormatTime = function(s)
		local day, hour, minute = 86400, 3600, 60
		if s >= day then
			return format("%dd", ceil(s / hour))
		elseif s >= hour then
			return format("%dh", ceil(s / hour))
		elseif s >= minute then
			return format("%dm", ceil(s / minute))
		elseif s >= minute / 12 then
			return floor(s)
		end
		return format("%.1f", s)
	end

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
					self.remaining:SetText(time)
					if self.timeLeft <= 5 then
						self.remaining:SetTextColor(0.99, 0.31, 0.31)
					else
						self.remaining:SetTextColor(1, 1, 1)
					end
				else
					self.remaining:Hide()
					self:SetScript("OnUpdate", nil)
				end
				self.elapsed = 0
			end
		end
	end

	function TukuiDB.PvPUpdate(self, elapsed)
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

	function TukuiDB.PostCreateAura(element, button)
		local unit = button:GetParent():GetParent().unit
		local header = button:GetParent():GetParent():GetParent():GetName()
		
		if header == "oUF_TukuiHealR6R25" or (header == "oUF_TukuiDPSR6R25" and TukuiCF["raidframes"].griddps == true) then
			button:EnableMouse(false)
			button:SetFrameLevel(button:GetParent():GetParent().Power:GetFrameLevel() + 4)
		end
		
		if unit == "focus" or unit == "targettarget" or header == "oUF_TukuiHealR6R25" or header == "oUF_TukuiDPSR6R25" or header == "oUF_TukuiHealParty" then
			button.remaining = TukuiDB.SetFontString(button, TukuiCF["media"].font, TukuiCF["auras"].auratextscale*0.85, "THINOUTLINE")
		else
			button.remaining = TukuiDB.SetFontString(button, TukuiCF["media"].font, TukuiCF["auras"].auratextscale, "THINOUTLINE")
		end
		
		TukuiDB.SetTemplate(button)
		button.remaining:SetPoint("CENTER", TukuiDB.Scale(0), TukuiDB.mult)
		
		button.cd.noOCC = true		 	-- hide OmniCC CDs
		button.cd.noCooldownCount = true	-- hide CDC CDs
		
		button.cd:SetReverse()
		button.icon:SetPoint("TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		button.icon:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
		
		button.count:SetPoint("BOTTOMRIGHT", TukuiDB.mult, TukuiDB.Scale(1.5))
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(TukuiCF["media"].font, TukuiCF["auras"].auratextscale*0.8, "THINOUTLINE")

		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 2)	   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.remaining:SetParent(button.overlayFrame)
		
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1,1,1,0.45)
		highlight:SetAllPoints(button.icon)	
	end

	function TukuiDB.PostUpdateAura(icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
		local name, _, _, _, dtype, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
		
		if(icon.debuff) then
			if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") and (not DebuffWhiteList[name]) then
				icon:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
				icon.icon:SetDesaturated(true)
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				if (name == "Unstable Affliction" or name == "Vampiric Touch") and TukuiDB.myclass ~= "WARLOCK" then
					icon:SetBackdropBorderColor(0.05, 0.85, 0.94)
				else
					icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
				end
				icon.icon:SetDesaturated(false)
			end
		else
			if (icon.isStealable or (TukuiDB.myclass == "PRIEST" and dtype == "Magic")) and not UnitIsFriend("player", unit) then
				icon:SetBackdropBorderColor(237/255, 234/255, 142/255)
			else
				icon:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
			end
		end
		
		if duration and duration > 0 then
			if TukuiCF["auras"].auratimer == true then
				icon.remaining:Show()
			else
				icon.remaining:Hide()
			end
		else
			icon.remaining:Hide()
		end
		
		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end

	TukuiDB.HidePortrait = function(self, event)
		if self.unit == "target" then
			if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
				self.PFrame:SetAlpha(0)
			else
				self.PFrame:SetAlpha(1)
			end
		end
	end

	TukuiDB.PostCastStart = function(self, unit, name, rank, castid)
		if unit == "vehicle" then unit = "player" end
		--Fix blank castbar with opening text
		if name == "Opening" then
			self.Text:SetText(OPENING)
		else
			self.Text:SetText(string.sub(name, 0, 25))
		end
		
		if self.interrupt and unit ~= "player" then
			if UnitCanAttack("player", unit) then
				self:SetStatusBarColor(unpack(TukuiCF["castbar"].nointerruptcolor))
			else
				self:SetStatusBarColor(unpack(TukuiCF["castbar"].castbarcolor))	
			end
		else
			if TukuiCF["castbar"].classcolor ~= true or unit ~= "player" then
				self:SetStatusBarColor(unpack(TukuiCF["castbar"].castbarcolor))
			else
				self:SetStatusBarColor(unpack(oUF.colors.class[select(2, UnitClass(unit))]))
			end	
		end
	end

	TukuiDB.UpdateShards = function(self, event, unit, powerType)
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

	TukuiDB.UpdateHoly = function(self, event, unit, powerType)
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

	TukuiDB.MoveBuffs = function(self, login)
		local parent = self:GetParent()
		if login then
			self:SetScript("OnUpdate", nil)
		end
		
		if self:IsShown() then
			if self == parent.EclipseBar then
				parent.FlashInfo:Hide()
				parent.PvP:SetAlpha(0)
			end
			parent.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerBuffs"] and DPSElementsCharPos["DPSPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerBuffs"] and HealElementsCharPos["HealPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerDebuffs"] and DPSElementsCharPos["DPSPlayerDebuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerDebuffs"] and HealElementsCharPos["HealPlayerDebuffs"]["moved"] == true) then return end
			
			if parent.Debuffs then 
				parent.Debuffs:ClearAllPoints()
				if parent.Debuffs then parent.Debuffs:SetPoint("BOTTOM", parent.Health, "TOP", 0, TukuiDB.Scale(17)) end	
			end		
		else
			if self == parent.EclipseBar then
				parent.FlashInfo:Show()
				parent.PvP:SetAlpha(1)
			end
			parent.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))
			
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerBuffs"] and DPSElementsCharPos["DPSPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerBuffs"] and HealElementsCharPos["HealPlayerBuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and DPSElementsCharPos["DPSPlayerDebuffs"] and DPSElementsCharPos["DPSPlayerDebuffs"]["moved"] == true) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and HealElementsCharPos["HealPlayerDebuffs"] and HealElementsCharPos["HealPlayerDebuffs"]["moved"] == true) then return end
			
			if parent.Debuffs then 
				parent.Debuffs:ClearAllPoints()
				parent.Debuffs:SetPoint("BOTTOM", parent.Health, "TOP", 0, TukuiDB.Scale(6))
			end	
		end
	end

	local starfirename = select(1, GetSpellInfo(2912))
	TukuiDB.EclipseDirection = function(self)
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

	TukuiDB.ToggleBars = function(self)
		local parent = self:GetParent()
		local unit = parent.unit
		if unit == "vehicle" then unit = "player" end
		if unit ~= "player" then return end
		
		if IsAddOnLoaded("Tukui_Dps_Layout") then
			oUF_Tukz_player = oUF_TukzDPS_player
		elseif IsAddOnLoaded("Tukui_Heal_Layout") then
			oUF_Tukz_player = oUF_TukzHeal_player
		end
		
		if self == oUF_Tukz_player.EclipseBar and (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then 
			oUF_Tukz_player.EclipseBar:SetScript("OnUpdate", function() 
				if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
					if oUF_Tukz_player.EclipseBar:IsShown() then
						oUF_Tukz_player.EclipseBar:Hide()
						oUF_Tukz_player.EclipseBar:SetScript("OnUpdate", nil)
					end
				else
					oUF_Tukz_player.EclipseBar:Show()
					oUF_Tukz_player.EclipseBar:SetScript("OnUpdate", nil)			
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

	TukuiDB.ComboDisplay = function(self, event, unit)
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
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and ((DPSElementsCharPos["DPSComboBar"] and DPSElementsCharPos["DPSComboBar"]["moved"] == true) or (DPSElementsCharPos["DPSTargetBuffs"] and DPSElementsCharPos["DPSTargetBuffs"]["moved"] == true))) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and ((HealElementsCharPos["HealComboBar"] and HealElementsCharPos["HealComboBar"]["moved"] == true) or (HealElementsCharPos["HealTargetBuffs"] and HealElementsCharPos["HealTargetBuffs"]["moved"] == true))) then return end
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			if self.Buffs then self.Buffs:ClearAllPoints() self.Buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, TukuiDB.Scale(17)) end	
		else
			for i=1, MAX_COMBO_POINTS do
				cpoints[i]:Hide()
			end
			if (IsAddOnLoaded("Tukui_Dps_Layout") and DPSElementsCharPos and ((DPSElementsCharPos["DPSComboBar"] and DPSElementsCharPos["DPSComboBar"]["moved"] == true) or (DPSElementsCharPos["DPSTargetBuffs"] and DPSElementsCharPos["DPSTargetBuffs"]["moved"] == true))) then return end
			if (IsAddOnLoaded("Tukui_Heal_Layout") and HealElementsCharPos and ((HealElementsCharPos["HealComboBar"] and HealElementsCharPos["HealComboBar"]["moved"] == true) or (HealElementsCharPos["HealTargetBuffs"] and HealElementsCharPos["HealTargetBuffs"]["moved"] == true))) then return end
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))	
			if self.Buffs then self.Buffs:ClearAllPoints() self.Buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, TukuiDB.Scale(4)) end	
		end
	end

	TukuiDB.MLAnchorUpdate = function (self)
		if self.Leader:IsShown() then
			self.MasterLooter:SetPoint("TOPLEFT", 14, 8)
		else
			self.MasterLooter:SetPoint("TOPLEFT", 2, 8)
		end
	end

	TukuiDB.RestingIconUpdate = function (self)
		if IsResting() then
			self.Resting:Show()
		else
			self.Resting:Hide()
		end
	end

	TukuiDB.UpdateReputation = function(self, event, unit, bar, min, max, value, name, id)
		if not name then return end
		local name, id = GetWatchedFactionInfo()
		bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
		
		local cur = value - min
		local total = max - min
		
		bar.Text:SetFormattedText(name..': '..TukuiDB.ShortValue(cur)..' / '..TukuiDB.ShortValue(total)..' <%d%%>', (cur / total) * 100)
	end

	local delay = 0
	TukuiDB.UpdateManaLevel = function(self, elapsed)
		delay = delay + elapsed
		if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
		delay = 0

		local percMana = UnitMana("player") / UnitManaMax("player") * 100

		if percMana <= 20 then
			self.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_lowmana.."|r")
			TukuiDB.Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			TukuiDB.StopFlash(self)
		end
	end

	TukuiDB.UpdateDruidMana = function(self)
		if self.unit ~= "player" then return end

		local num, str = UnitPowerType("player")
		if num ~= 0 then
			local min = UnitPower("player", 0)
			local max = UnitPowerMax("player", 0)

			local percMana = min / max * 100
			if percMana <= TukuiCF["unitframes"].lowThreshold then
				self.FlashInfo.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_lowmana.."|r")
				TukuiDB.Flash(self.FlashInfo, 0.3)
			else
				self.FlashInfo.ManaLevel:SetText()
				TukuiDB.StopFlash(self.FlashInfo)
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

	function TukuiDB.UpdateThreat(self, event, unit)
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
				self.FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
				if self.HealthBorder then
					self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
				end
				if self.PFrame then
					self.PFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
				end
			end
		end 
	end

	TukuiDB.updateAllElements = function(frame)
		for _, v in ipairs(frame.__elements) do
			v(frame, "UpdateElement", frame.unit)
		end
		
		local header = frame:GetParent():GetName()
		if (header == "oUF_TukuiDPSR6R25" or header == "oUF_TukuiHealR6R25") and TukuiCF["raidframes"].hidenonmana == true then
			local powertype, _ = UnitPowerType(frame.unit)
			if powertype ~= SPELL_POWER_MANA then
				frame.Health:SetHeight(frame.Health:GetParent():GetHeight())
				if frame.Power then
					frame.Power:Hide()
				end
			else
				if IsAddOnLoaded("Tukui_Heal_Layout") and frame:GetParent():GetName() == "oUF_TukuiHealR6R25" then
					frame.Health:SetHeight(frame.Health:GetParent():GetHeight() * 0.85)
				elseif frame:GetParent():GetName() == "oUF_TukuiDPSR6R25" then
					if TukuiCF["raidframes"].griddps ~= true then
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

	function TukuiDB.ExperienceText(self, unit, min, max)
		local rested = GetXPExhaustion()
		if rested then 
			self.Text:SetFormattedText('XP: '..TukuiDB.ShortValue(min)..' / '..TukuiDB.ShortValue(max)..' <%d%%>  R: +'..TukuiDB.ShortValue(rested)..' <%d%%>', min / max * 100, rested / max * 100)
		else
			self.Text:SetFormattedText('XP: '..TukuiDB.ShortValue(min)..' / '..TukuiDB.ShortValue(max)..' <%d%%>', min / max * 100)
		end
	end



	--------------------------------------------------------------------------------------------
	-- THE AURAWATCH FUNCTION ITSELF. HERE BE DRAGONS!
	--------------------------------------------------------------------------------------------

	TukuiDB.countOffsets = {
		TOPLEFT = {6, 1},
		TOPRIGHT = {-6, 1},
		BOTTOMLEFT = {6, 1},
		BOTTOMRIGHT = {-6, 1},
		LEFT = {6, 1},
		RIGHT = {-6, 1},
		TOP = {0, 0},
		BOTTOM = {0, 0},
	}

	function TukuiDB.CreateAuraWatchIcon(self, icon)
		if (icon.cd) then
			icon.cd:SetReverse()
		end 	
	end

	function TukuiDB.createAuraWatch(self, unit)
		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("TOPLEFT", self.Health, 2, -2)
		auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
		auras.presentAlpha = 1
		auras.missingAlpha = 0
		auras.icons = {}
		auras.PostCreateIcon = TukuiDB.CreateAuraWatchIcon

		if (not TukuiCF["auras"].auratimer) then
			auras.hideCooldown = true
		end

		local buffs = {}
		if IsAddOnLoaded("Tukui_Dps_Layout") then
			if (TukuiDB.DPSBuffIDs["ALL"]) then
				for key, value in pairs(TukuiDB.DPSBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (TukuiDB.DPSBuffIDs[TukuiDB.myclass]) then
				for key, value in pairs(TukuiDB.DPSBuffIDs[TukuiDB.myclass]) do
					tinsert(buffs, value)
				end
			end	
		else
			if (TukuiDB.HealerBuffIDs["ALL"]) then
				for key, value in pairs(TukuiDB.HealerBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (TukuiDB.HealerBuffIDs[TukuiDB.myclass]) then
				for key, value in pairs(TukuiDB.HealerBuffIDs[TukuiDB.myclass]) do
					tinsert(buffs, value)
				end
			end
		end
		
		if TukuiDB.PetBuffs[TukuiDB.myclass] then
			for key, value in pairs(TukuiDB.PetBuffs[TukuiDB.myclass]) do
				tinsert(buffs, value)
			end
		end

		-- "Cornerbuffs"
		if (buffs) then
			for key, spell in pairs(buffs) do
				local icon = CreateFrame("Frame", nil, auras)
				icon.spellID = spell[1]
				icon.anyUnit = spell[4]
				icon:SetWidth(TukuiDB.Scale(TukuiCF["auras"].buffindicatorsize))
				icon:SetHeight(TukuiDB.Scale(TukuiCF["auras"].buffindicatorsize))
				icon:SetPoint(spell[2], 0, 0)

				local tex = icon:CreateTexture(nil, "OVERLAY")
				tex:SetAllPoints(icon)
				tex:SetTexture([=[Interface\AddOns\Tukui\media\textures\blank]=])
				if (spell[3]) then
					tex:SetVertexColor(unpack(spell[3]))
				else
					tex:SetVertexColor(0.8, 0.8, 0.8)
				end

				local count = icon:CreateFontString(nil, "OVERLAY")
				count:SetFont(TukuiCF["media"].uffont, 8, "THINOUTLINE")
				count:SetPoint("CENTER", unpack(TukuiDB.countOffsets[spell[2]]))
				icon.count = count

				auras.icons[spell[1]] = icon
			end
		end

		self.AuraWatch = auras
	end
end