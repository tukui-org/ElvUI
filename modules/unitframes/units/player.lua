local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');



local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local CAN_HAVE_CLASSBAR = (E.myclass == "PALADIN" or E.myclass == "SHAMAN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK")

function UF:Construct_PlayerFrame(frame)
	frame.Threat = self:Construct_ThreatGlow(frame, true)
	
	frame.Health = self:Construct_HealthBar(frame, true, true, 'RIGHT')
	frame.Health.frequentUpdates = true;
	
	frame.Power = self:Construct_PowerBar(frame, true, true, 'LEFT', true)
	frame.Power.frequentUpdates = true;
	
	frame.Name = self:Construct_NameText(frame)
	
	frame.Portrait = self:Construct_Portrait(frame)
	
	frame.Buffs = self:Construct_Buffs(frame)
	
	frame.Debuffs = self:Construct_Debuffs(frame)
	
	frame.Castbar = self:Construct_Castbar(frame, 'LEFT')
	
	if E.myclass == "PALADIN" then
		frame.HolyPower = self:Construct_PaladinWarlockResourceBar(frame, E.myclass)
	elseif E.myclass == "WARLOCK" then
		frame.SoulShards = self:Construct_PaladinWarlockResourceBar(frame, E.myclass)
	elseif E.myclass == "DEATHKNIGHT" then
		frame.Runes = self:Construct_DeathKnightResourceBar(frame)
	elseif E.myclass == "SHAMAN" then
		frame.TotemBar = self:Construct_ShamanTotemBar(frame)
	elseif E.myclass == "DRUID" then
		frame.EclipseBar = self:Construct_DruidResourceBar(frame)
		frame.DruidAltMana = self:Construct_DruidAltManaBar(frame)
	end
	frame.RaidIcon = UF:Construct_RaidIcon(frame)
	frame.Resting = self:Construct_RestingIndicator(frame)
	frame.Combat = self:Construct_CombatIndicator(frame)
	frame.PvPText = self:Construct_PvPIndicator(frame)
	frame.AltPowerBar = self:Construct_AltPowerBar(frame)
	frame.DebuffHighlight = self:Construct_DebuffHighlight(frame)
	frame.HealPrediction = self:Construct_HealComm(frame)

	frame.CombatFade = true
end

function UF:Update_PlayerFrame(frame, db)
	frame.db = db
	local BORDER = E:Scale(2)
	local SPACING = E:Scale(1)
	local UNIT_WIDTH = db.width
	local UNIT_HEIGHT = db.height
	
	local USE_POWERBAR = db.power.enable
	local USE_MINI_POWERBAR = db.power.width ~= 'fill' and USE_POWERBAR
	local USE_POWERBAR_OFFSET = db.power.offset ~= 0 and USE_POWERBAR
	local POWERBAR_OFFSET = db.power.offset
	local POWERBAR_HEIGHT = db.power.height
	local POWERBAR_WIDTH = db.width - (BORDER*2)
	
	local USE_CLASSBAR = db.classbar.enable and CAN_HAVE_CLASSBAR
	local USE_MINI_CLASSBAR = db.classbar.fill == "spaced" and USE_CLASSBAR
	local CLASSBAR_HEIGHT = db.classbar.height
	local CLASSBAR_WIDTH = db.width - (BORDER*2)
	
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	
	local unit = self.unit
	
	frame.colors = ElvUF.colors
	frame:Size(UNIT_WIDTH, UNIT_HEIGHT)
	
	--Adjust some variables
	do
		if not USE_POWERBAR then
			POWERBAR_HEIGHT = 0
		end
		
		if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
			PORTRAIT_WIDTH = 0
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end			
		end
		
		if USE_PORTRAIT then
			CLASSBAR_WIDTH = math.ceil((UNIT_WIDTH - (BORDER*2)) - PORTRAIT_WIDTH)
			
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end
		end
		
		if USE_POWERBAR_OFFSET then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
		end

		if USE_MINI_CLASSBAR then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH*2/3
		end	
		
		if USE_MINI_POWERBAR then
			POWERBAR_WIDTH = POWERBAR_WIDTH / 2
		end
	end
	
	--Threat
	do
		local threat = frame.Threat
		
		local mini_classbarY = 0
		if USE_MINI_CLASSBAR then
			mini_classbarY = -(SPACING+(CLASSBAR_HEIGHT/2))
		end
		
		threat:ClearAllPoints()
		threat:SetBackdropBorderColor(0, 0, 0, 0)
		threat:Point("TOPLEFT", -4, 4+mini_classbarY)
		threat:Point("TOPRIGHT", 4, 4+mini_classbarY)
		
		if USE_MINI_POWERBAR then
			threat:Point("BOTTOMLEFT", -4, -4 + (POWERBAR_HEIGHT/2))
			threat:Point("BOTTOMRIGHT", 4, -4 + (POWERBAR_HEIGHT/2))		
		else
			threat:Point("BOTTOMLEFT", -4, -4)
			threat:Point("BOTTOMRIGHT", 4, -4)
		end

		if USE_POWERBAR_OFFSET then
			threat:Point("TOPRIGHT", 4-POWERBAR_OFFSET, 4+mini_classbarY)
			threat:Point("BOTTOMRIGHT", 4-POWERBAR_OFFSET, -4)	
		end		

		if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
			if USE_PORTRAIT == true and not USE_PORTRAIT_OVERLAY then
				threat:Point("BOTTOMLEFT", frame.Portrait.backdrop, "BOTTOMLEFT", -4, -4)
			else
				threat:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", -5, -5)
			end
			threat:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 5, -5)
		end				
	end
	
	--Health
	do
		local health = frame.Health
		health.Smooth = self.db.smoothbars

		--Text
		if db.health.text then
			health.value:Show()
			
			local x, y = self:GetPositionOffset(db.health.position)
			health.value:ClearAllPoints()
			health.value:Point(db.health.position, health, db.health.position, x, y)
		else
			health.value:Hide()
		end
		
		--Colors
		health.colorSmooth = nil
		health.colorHealth = nil
		health.colorClass = nil
		health.colorReaction = nil
		if self.db['colors'].healthclass ~= true then
			if self.db['colors'].colorhealthbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end		
		else
			health.colorClass = true
			health.colorReaction = true
		end	
		
		--Position
		health:ClearAllPoints()
		health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, -BORDER)
		if USE_POWERBAR_OFFSET then
			health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER+POWERBAR_OFFSET)
		elseif USE_MINI_POWERBAR then
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		
		health.bg:ClearAllPoints()
		if not USE_PORTRAIT_OVERLAY then
			health:Point("TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)		
			health.bg:SetParent(health)
			health.bg:SetAllPoints()
		else
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)		
			health.bg:SetParent(frame.Portrait.overlay)			
		end
		
		if USE_CLASSBAR then
			local DEPTH
			if USE_MINI_CLASSBAR then
				DEPTH = -(BORDER+(CLASSBAR_HEIGHT/2))
			else
				DEPTH = -(BORDER+CLASSBAR_HEIGHT+SPACING)
			end
			
			if USE_POWERBAR_OFFSET then
				health:Point("TOPRIGHT", frame, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), DEPTH)
			else
				health:Point("TOPRIGHT", frame, "TOPRIGHT", -BORDER, DEPTH)
			end
			
			health:Point("TOPLEFT", frame, "TOPLEFT", PORTRAIT_WIDTH+BORDER, DEPTH)
		end
	end
	
	--Name
	do
		local name = frame.Name
		if db.name.enable then
			name:Show()
			
			if not db.power.hideonnpc then
				local x, y = self:GetPositionOffset(db.name.position)
				name:ClearAllPoints()
				name:Point(db.name.position, frame.Health, db.name.position, x, y)				
			end
		else
			name:Hide()
		end
	end	
	
	--Power
	do
		local power = frame.Power
		if USE_POWERBAR then
			if not frame:IsElementEnabled('Power') then
				frame:EnableElement('Power')
				power:Show()
			end		
		
			power.Smooth = self.db.smoothbars
			
			--Text
			if db.power.text then
				power.value:Show()
				
				local x, y = self:GetPositionOffset(db.power.position)
				power.value:ClearAllPoints()
				power.value:Point(db.power.position, frame.Health, db.power.position, x, y)			
			else
				power.value:Hide()
			end
			
			--Colors
			power.colorClass = nil
			power.colorReaction = nil	
			power.colorPower = nil
			if self.db['colors'].powerclass then
				power.colorClass = true
				power.colorReaction = true
			else
				power.colorPower = true
			end		
			
			--Position
			power:ClearAllPoints()
			if USE_POWERBAR_OFFSET then
				power:Point("TOPRIGHT", frame.Health, "TOPRIGHT", POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:Point("BOTTOMLEFT", frame.Health, "BOTTOMLEFT", POWERBAR_OFFSET, -POWERBAR_OFFSET)
				power:SetFrameStrata("LOW")
				power:SetFrameLevel(2)
			elseif USE_MINI_POWERBAR then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("RIGHT", frame, "BOTTOMRIGHT", -(BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(frame:GetFrameLevel() + 3)
			else
				power:Point("TOPLEFT", frame.Health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
				power:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BORDER, BORDER)
			end
		elseif frame:IsElementEnabled('Power') then
			frame:DisableElement('Power')
			power:Hide()
			power.value:Hide()
		end
	end
	
	--Portrait
	do
		local portrait = frame.Portrait
		
		--Set Points
		if USE_PORTRAIT then
			if not frame:IsElementEnabled('Portrait') then
				frame:EnableElement('Portrait')
			end
			
			portrait:ClearAllPoints()
			
			if USE_PORTRAIT_OVERLAY then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
				portrait:SetAllPoints(frame.Health)
				portrait:SetAlpha(0.3)
				portrait:Show()		
			else
				portrait:SetAlpha(1)
				portrait:Show()
				
				if USE_MINI_CLASSBAR and USE_CLASSBAR then
					portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT", 0, -((CLASSBAR_HEIGHT/2)))
				else
					portrait.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT")
				end		
				
				if USE_MINI_POWERBAR or USE_POWERBAR_OFFSET then
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Health.backdrop, "BOTTOMLEFT", -SPACING, 0)
				else
					portrait.backdrop:Point("BOTTOMRIGHT", frame.Power.backdrop, "BOTTOMLEFT", -SPACING, 0)
				end	

				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)				
			end
		else
			if frame:IsElementEnabled('Portrait') then
				frame:DisableElement('Portrait')
				portrait:Hide()
			end		
		end
	end

	--Auras Disable/Enable
	--Only do if both debuffs and buffs aren't being used.
	do
		if db.debuffs.enable or db.buffs.enable then
			if not frame:IsElementEnabled('Aura') then
				frame:EnableElement('Aura')
			end	
		else
			if frame:IsElementEnabled('Aura') then
				frame:DisableElement('Aura')
			end			
		end
		
		frame.Buffs:ClearAllPoints()
		frame.Debuffs:ClearAllPoints()
	end
	
	--Buffs
	do
		local buffs = frame.Buffs
		local rows = db.buffs.numrows
		
		if USE_POWERBAR_OFFSET then
			buffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			buffs:SetWidth(UNIT_WIDTH)
		end
		
		if db.buffs.initialAnchor == "RIGHT" or db.buffs.initialAnchor == "LEFT" then
			rows = 1;
			buffs:SetWidth(UNIT_WIDTH / 2)
		end
		
		buffs.num = db.buffs.perrow * rows
		buffs.size = ((((buffs:GetWidth() - (buffs.spacing*(buffs.num/rows - 1))) / buffs.num)) * rows)

		local x, y = self:GetAuraOffset(db.buffs.initialAnchor, db.buffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.buffs.attachTo)

		buffs:Point(db.buffs.initialAnchor, attachTo, db.buffs.anchorPoint, x, y)
		buffs:Height(buffs.size * rows)
		buffs.initialAnchor = db.buffs.initialAnchor
		buffs["growth-y"] = db.buffs['growth-y']
		buffs["growth-x"] = db.buffs['growth-x']

		if db.buffs.enable then			
			buffs:Show()
		else
			buffs:Hide()
		end
	end
	
	--Debuffs
	do
		local debuffs = frame.Debuffs
		local rows = db.debuffs.numrows
		
		if USE_POWERBAR_OFFSET then
			debuffs:SetWidth(UNIT_WIDTH - POWERBAR_OFFSET)
		else
			debuffs:SetWidth(UNIT_WIDTH)
		end
		
		if db.debuffs.initialAnchor == "RIGHT" or db.debuffs.initialAnchor == "LEFT" then
			rows = 1;
			debuffs:SetWidth(UNIT_WIDTH / 2)
		end
		
		debuffs.num = db.debuffs.perrow * rows
		debuffs.size = ((((debuffs:GetWidth() - (debuffs.spacing*(debuffs.num/rows - 1))) / debuffs.num)) * rows)

		local x, y = self:GetAuraOffset(db.debuffs.initialAnchor, db.debuffs.anchorPoint)
		local attachTo = self:GetAuraAnchorFrame(frame, db.debuffs.attachTo, db.buffs.attachTo == 'DEBUFFS' and db.debuffs.attachTo == 'BUFFS')

		debuffs:Point(db.debuffs.initialAnchor, attachTo, db.debuffs.anchorPoint, x, y)
		debuffs:Height(debuffs.size * rows)
		debuffs.initialAnchor = db.debuffs.initialAnchor
		debuffs["growth-y"] = db.debuffs['growth-y']
		debuffs["growth-x"] = db.debuffs['growth-x']

		if db.debuffs.enable then			
			debuffs:Show()
		else
			debuffs:Hide()
		end
	end	
	
	--Castbar
	do
		local castbar = frame.Castbar
		castbar:Width(db.castbar.width - 3)
		castbar:Height(db.castbar.height)
		
		--Latency
		if db.castbar.latency then
			castbar.SafeZone = castbar.LatencyTexture
			castbar.LatencyTexture:Show()
		else
			castbar.SafeZone = nil
			castbar.LatencyTexture:Hide()
		end
		
		--Icon
		if db.castbar.icon then
			castbar.Icon = castbar.ButtonIcon
			castbar.Icon.bg:Width(db.castbar.height + 4)
			castbar.Icon.bg:Height(db.castbar.height + 4)
			
			castbar:Width(db.castbar.width - castbar.Icon.bg:GetWidth() - 5)
			castbar.Icon.bg:Show()
		else
			castbar.ButtonIcon.bg:Hide()
			castbar.Icon = nil
		end

		if db.castbar.spark then
			castbar.Spark:Show()
		else
			castbar.Spark:Hide()
		end
		
		castbar:Point("TOPRIGHT", frame, "BOTTOMRIGHT", -(BORDER + db.castbar.xOffset), -((BORDER*2+BORDER) + db.castbar.yOffset))
		
		if db.castbar.enable and not frame:IsElementEnabled('Castbar') then
			frame:EnableElement('Castbar')
		elseif not db.castbar.enable and frame:IsElementEnabled('Castbar') then
			frame:DisableElement('Castbar')	
		end			
	end
	
	--Resource Bars
	do
		if E.myclass == "PALADIN" then
			local bars = frame.HolyPower
			bars:ClearAllPoints()
			if USE_MINI_CLASSBAR then
				bars:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 6), -SPACING)
				bars:SetFrameStrata("MEDIUM")
			else
				bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				bars:SetFrameStrata("LOW")
			end
			bars:Width(CLASSBAR_WIDTH)
			bars:Height(CLASSBAR_HEIGHT - (BORDER*2))
		
			for i = 1, MAX_HOLY_POWER do
				bars[i]:SetHeight(bars:GetHeight())	
				bars[i]:SetWidth(E:Scale(bars:GetWidth() - 2)/MAX_HOLY_POWER)	
				bars[i]:GetStatusBarTexture():SetHorizTile(false)
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:SetPoint("LEFT", bars)
				else
					if USE_MINI_CLASSBAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING+(BORDER*2)+8, 0)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING, 0)
					end
				end
				
				if not USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end
			end
			
			if not USE_MINI_CLASSBAR then
				bars.backdrop:Show()
			else
				bars.backdrop:Hide()			
			end		
			
			if USE_CLASSBAR and not frame:IsElementEnabled('HolyPower') then
				frame:EnableElement('HolyPower')
				bars:Show()
			elseif not USE_CLASSBAR and frame:IsElementEnabled('HolyPower') then
				frame:DisableElement('HolyPower')	
				bars:Hide()
			end		
			
		elseif E.myclass == "WARLOCK" then
			local bars = frame.SoulShards
			bars:ClearAllPoints()
			if USE_MINI_CLASSBAR then
				bars:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 6), -SPACING)
				bars:SetFrameStrata("MEDIUM")
			else
				bars:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				bars:SetFrameStrata("LOW")
			end
			bars:Width(CLASSBAR_WIDTH)
			bars:Height(CLASSBAR_HEIGHT - (BORDER*2))
		
			for i = 1, SHARD_BAR_NUM_SHARDS do
				bars[i]:SetHeight(bars:GetHeight())	
				bars[i]:SetWidth(E:Scale(bars:GetWidth() - 2)/SHARD_BAR_NUM_SHARDS)	
				bars[i]:ClearAllPoints()
				if i == 1 then
					bars[i]:SetPoint("LEFT", bars)
				else
					if USE_MINI_CLASSBAR then
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING+(BORDER*2)+8, 0)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING, 0)
					end
				end
				
				if not USE_MINI_CLASSBAR then
					bars[i].backdrop:Hide()
				else
					bars[i].backdrop:Show()
				end				
			end
			
			if not USE_MINI_CLASSBAR then
				bars.backdrop:Show()
			else
				bars.backdrop:Hide()			
			end
			
			if USE_CLASSBAR and not frame:IsElementEnabled('SoulShards') then
				frame:EnableElement('SoulShards')
				bars:Show()
			elseif not USE_CLASSBAR and frame:IsElementEnabled('SoulShards') then
				frame:DisableElement('SoulShards')
				bars:Hide()
			end					
		elseif E.myclass == "DEATHKNIGHT" then
			local runes = frame.Runes
			runes:ClearAllPoints()
			if USE_MINI_CLASSBAR then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 3/2 --Multiply by reciprocal to reset previous setting
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 4/5
				runes:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 8), -SPACING)
				runes:SetFrameStrata("MEDIUM")
			else
				runes:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				runes:SetFrameStrata("LOW")
			end
			runes:Width(CLASSBAR_WIDTH)
			runes:Height(CLASSBAR_HEIGHT - (BORDER*2))			
			
			for i = 1, 6 do
				runes[i]:SetHeight(runes:GetHeight())
				runes[i]:SetWidth(E:Scale(runes:GetWidth() - 5) / 6)	
				if USE_MINI_CLASSBAR then
					runes[i].backdrop:Show()
				else
					runes[i].backdrop:Hide()	
				end
				
				runes[i]:ClearAllPoints()
				if i == 1 then
					runes[i]:SetPoint("LEFT", runes)
				else
					if USE_MINI_CLASSBAR then
						runes[i]:Point("LEFT", runes[i-1], "RIGHT", SPACING+(BORDER*2)+2, 0)
					else
						runes[i]:Point("LEFT", runes[i-1], "RIGHT", SPACING, 0)
					end
				end	
				
				if not USE_MINI_CLASSBAR then
					runes[i].backdrop:Hide()
				else
					runes[i].backdrop:Show()
				end					
			end
			
			if not USE_MINI_CLASSBAR then
				runes.backdrop:Show()
			else
				runes.backdrop:Hide()
			end		

			if USE_CLASSBAR and not frame:IsElementEnabled('Runes') then
				frame:EnableElement('Runes')
				runes:Show()
			elseif not USE_CLASSBAR and frame:IsElementEnabled('Runes') then
				frame:DisableElement('Runes')	
				runes:Hide()
				RuneFrame.Show = RuneFrame.Hide
				RuneFrame:Hide()				
			end					
		elseif E.myclass == "SHAMAN" then
			local totems = frame.TotemBar
			
			totems:ClearAllPoints()
			if not USE_MINI_CLASSBAR then
				totems:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				totems:SetFrameStrata("LOW")
			else
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 3/2 --Multiply by reciprocal to reset previous setting
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 4/5
				totems:Point("CENTER", frame.Health.backdrop, "TOP", -(BORDER*3 + 6), -SPACING)
				totems:SetFrameStrata("MEDIUM")			
			end
			
			totems:Width(CLASSBAR_WIDTH)
			totems:Height(CLASSBAR_HEIGHT - (BORDER*2))

			for i=1, 4 do
				totems[i]:SetHeight(totems:GetHeight())
				totems[i]:SetWidth(E:Scale(totems:GetWidth() - 3) / 4)	

				if USE_MINI_CLASSBAR then
					totems[i].backdrop:Show()
				else
					totems[i].backdrop:Hide()
				end	
				
				totems[i]:ClearAllPoints()
				if i == 1 then
					totems[i]:SetPoint("LEFT", totems)
				else
					if USE_MINI_CLASSBAR then
						totems[i]:Point("LEFT", totems[i-1], "RIGHT", SPACING+(BORDER*2)+4, 0)
					else
						totems[i]:Point("LEFT", totems[i-1], "RIGHT", SPACING, 0)
					end
				end		

				if not USE_MINI_CLASSBAR then
					totems[i].backdrop:Hide()
				else
					totems[i].backdrop:Show()
				end						
			end
			
			if not USE_MINI_CLASSBAR then
				totems.backdrop:Show()
			else
				totems.backdrop:Hide()
			end		

			if USE_CLASSBAR and not frame:IsElementEnabled('TotemBar') then
				frame:EnableElement('TotemBar')
				totems:Show()
			elseif not USE_CLASSBAR and frame:IsElementEnabled('TotemBar') then
				frame:DisableElement('TotemBar')	
				totems:Hide()
			end					
		elseif E.myclass == "DRUID" then
			local eclipseBar = frame.EclipseBar

			eclipseBar:ClearAllPoints()
			if not USE_MINI_CLASSBAR then
				eclipseBar:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				eclipseBar:SetFrameStrata("LOW")
			else		
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 3/2 --Multiply by reciprocal to reset previous setting
				CLASSBAR_WIDTH = CLASSBAR_WIDTH * 2/3			
				eclipseBar:Point("LEFT", frame.Health.backdrop, "TOPLEFT", (BORDER*2 + 4), 0)
				eclipseBar:SetFrameStrata("MEDIUM")						
			end

			eclipseBar:Width(CLASSBAR_WIDTH)
			eclipseBar:Height(CLASSBAR_HEIGHT - (BORDER*2))	
			
			--?? Apparent bug fix for the width after in-game settings change
			eclipseBar.LunarBar:SetMinMaxValues(0, 0)
			eclipseBar.SolarBar:SetMinMaxValues(0, 0)
			eclipseBar.LunarBar:Size(CLASSBAR_WIDTH, CLASSBAR_HEIGHT - (BORDER*2))			
			eclipseBar.SolarBar:Size(CLASSBAR_WIDTH, CLASSBAR_HEIGHT - (BORDER*2))	
			
			if USE_CLASSBAR and not frame:IsElementEnabled('EclipseBar') then
				frame:EnableElement('EclipseBar')
				eclipseBar:Show()
			elseif not USE_CLASSBAR and frame:IsElementEnabled('EclipseBar') then
				frame:DisableElement('EclipseBar')	
				eclipseBar:Hide()
			end					
		end
	end
	
	--Combat Fade
	do
		if db.combatfade and not frame:IsElementEnabled('CombatFade') then
			frame:EnableElement('CombatFade')
		elseif not db.combatfade and frame:IsElementEnabled('CombatFade') then
			frame:DisableElement('CombatFade')
		end		
	end
	
	--AltPower
	do
		local altpower = frame.AltPowerBar
		altpower:Point("TOP", E.UIParent, "TOP", 0, -70)
		altpower:Width(db.altpower.width)
		altpower:Height(db.altpower.height)	
		altpower.Smooth = self.db.smoothbars
		
		if db.altpower.enable and not frame:IsElementEnabled('AltPowerBar') then
			frame:EnableElement('AltPowerBar')
		elseif not db.altpower.enable and frame:IsElementEnabled('AltPowerBar') then
			frame:DisableElement('AltPowerBar')
		end			
	end
	
	--Debuff Highlight
	do
		local dbh = frame.DebuffHighlight
		if E.db.unitframe.debuffHighlighting then
			if not frame:IsElementEnabled('DebuffHighlight') then
				frame:EnableElement('DebuffHighlight')
			end
		else
			if frame:IsElementEnabled('DebuffHighlight') then
				frame:DisableElement('DebuffHighlight')
			end		
		end
	end
	
	--OverHealing
	do
		local healPrediction = frame.HealPrediction
		
		if db.healPrediction then
			if not frame:IsElementEnabled('HealPrediction') then
				frame:EnableElement('HealPrediction')
			end

			healPrediction.myBar:ClearAllPoints()
			healPrediction.myBar:Width(db.width - (BORDER*2))
			healPrediction.myBar:SetPoint('BOTTOMLEFT', frame.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			healPrediction.myBar:SetPoint('TOPLEFT', frame.Health:GetStatusBarTexture(), 'TOPRIGHT')	

			healPrediction.otherBar:ClearAllPoints()
			healPrediction.otherBar:SetPoint('TOPLEFT', healPrediction.myBar:GetStatusBarTexture(), 'TOPRIGHT')	
			healPrediction.otherBar:SetPoint('BOTTOMLEFT', healPrediction.myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')	
			healPrediction.otherBar:Width(db.width - (BORDER*2))
		else
			if frame:IsElementEnabled('HealPrediction') then
				frame:DisableElement('HealPrediction')
			end		
		end
	end
	
	frame.snapOffset = -(12 + db.castbar.height)
	
	if not frame.mover then
		frame:ClearAllPoints()
		frame:Point('BOTTOMLEFT', E.UIParent, 'BOTTOM', -417, 75) --Set to default position
	end

	frame:UpdateAllElements()
end

tinsert(UF['unitstoload'], 'player')