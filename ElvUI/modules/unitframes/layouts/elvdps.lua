local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["unitframes"].enable == true then return end

------------------------------------------------------------------------
--	Constants
------------------------------------------------------------------------

local PLAYER_WIDTH = C["unitframes"].playtarwidth*E.ResScale
local PLAYER_HEIGHT = C["unitframes"].playtarheight*E.ResScale
local TARGET_WIDTH = C["unitframes"].playtarwidth*E.ResScale
local TARGET_HEIGHT = C["unitframes"].playtarheight*E.ResScale
local SMALL_WIDTH = C["unitframes"].smallwidth*E.ResScale
local SMALL_HEIGHT = C["unitframes"].smallheight*E.ResScale
local TANK_WIDTH = C["unitframes"].assisttankwidth*E.ResScale
local TANK_HEIGHT = C["unitframes"].assisttankheight*E.ResScale
local BOSS_WIDTH = C["unitframes"].arenabosswidth*E.ResScale
local BOSS_HEIGHT = C["unitframes"].arenabossheight*E.ResScale
local BORDER = 2*E.ResScale
local SPACING = 1*E.ResScale
local FONTSIZE = C["unitframes"].fontsize*E.ResScale
local FONT = C["media"].uffont
local NORMTEX = C["media"].normTex
local POWERTHEME = C["unitframes"].mini_powerbar
local USE_POWERBAR_OFFSET = C["unitframes"].powerbar_offset ~= 0
local POWERBAR_OFFSET = C["unitframes"].powerbar_offset
local MINI_CLASSBAR = C["unitframes"].mini_classbar and (E.myclass == "PALADIN" or E.myclass == "SHAMAN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK")

--[[
	Constuctor Functions (inside uf_functions.lua)
	
	E.ContructHealthBar(arg1, arg2, arg3):
		arg1 - first argument should always be self
		arg2 - [true/false] OPTIONAL create a backdrop
		arg3 - [true/false] OPTIONAL create health value text
		
	E.ContructPowerBar(arg1, arg2, arg3):
		arg1 - first argument should always be self
		arg2 - [true/false] OPTIONAL create a backdrop 
		arg3 - [true/false] OPTIONAL create power value text

	E.ConstructCastBar(arg1, arg2, arg3, arg4):
		arg1 - first argument should always be self
		arg2 - width of entire bar, cast icon is calculated in already
		arg3 - height of entire bar
		arg4 - ["Left", "Right"] side that you want the cast icon to go on, if cast icons are enabled.
		
	
	Note: These functions do not make the element active, you have to do that manually.
	
	Example:
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		
		self.Health = health
]]

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------
local function Shared(self, unit)
	-- Set Colors
	self.colors = E.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = E.SpawnMenu
	
	-- Frame Level
	self:SetFrameLevel(5)
	
	------------------------------------------------------------------------
	--	Player
	------------------------------------------------------------------------
	if unit == "player" then
		local POWERBAR_WIDTH = C["unitframes"].playtarwidth/2*E.ResScale
		local CLASSBAR_WIDTH = (C["unitframes"].playtarwidth - (2*2))*E.ResScale
		local CLASSBAR_HEIGHT = (C["unitframes"].classbar_height)*E.ResScale
		local POWERBAR_HEIGHT = (C["unitframes"].powerbar_height)*E.ResScale
		local CASTBAR_HEIGHT = C["unitframes"].castplayerheight*E.ResScale
		local CASTBAR_WIDTH = C["unitframes"].castplayerwidth*E.ResScale
		local PORTRAIT_WIDTH = 45*E.ResScale

		local mini_classbarY = 0
		if MINI_CLASSBAR then
			mini_classbarY = -(SPACING+(CLASSBAR_HEIGHT/2))
		end
		
		--Threat Glow
		self:CreateShadow("Default")
		self.shadow:SetFrameStrata("BACKGROUND")
		self.shadow:SetBackdropBorderColor(0, 0, 0, 0)
		self.shadow:Point("TOPLEFT", -4, 4+mini_classbarY)
		self.shadow:Point("TOPRIGHT", 4, 4+mini_classbarY)
		self.shadow:Point("BOTTOMLEFT", -4, -4)
		self.shadow:Point("BOTTOMRIGHT", 4, -4)		
	
		if USE_POWERBAR_OFFSET then
			self.shadow:Point("TOPRIGHT", 4-POWERBAR_OFFSET, 4+mini_classbarY)
			self.shadow:Point("BOTTOMRIGHT", 4-POWERBAR_OFFSET, -4)	
		end

		if C["unitframes"].charportraithealth == true or C["unitframes"].charportrait == false then
			PORTRAIT_WIDTH = 0
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end			
		elseif C["unitframes"].charportrait == true then
			CLASSBAR_WIDTH = math.ceil(((C["unitframes"].playtarwidth - (2*2)) - 45)*E.ResScale)
			
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end
		elseif USE_POWERBAR_OFFSET then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
		end

		if MINI_CLASSBAR then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH*2/3
		end
		
		--Health Bar
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		if USE_POWERBAR_OFFSET then
			health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER+POWERBAR_OFFSET)
		elseif POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end

		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		self.Health = health
		
		--Power Bar
		local power = E.ConstructPowerBar(self, true, true)
		if USE_POWERBAR_OFFSET then
			power:Point("TOPRIGHT", health, "TOPRIGHT", POWERBAR_OFFSET, -POWERBAR_OFFSET)
			power:Point("BOTTOMLEFT", health, "BOTTOMLEFT", POWERBAR_OFFSET, -POWERBAR_OFFSET)
			power:SetFrameStrata("LOW")
			power:SetFrameLevel(2)
		elseif POWERTHEME == true then
			power:Width(POWERBAR_WIDTH - BORDER*2)
			power:Height(POWERBAR_HEIGHT - BORDER*2)
			power:Point("RIGHT", self, "BOTTOMRIGHT", -(BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)
		end
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		self.Power = power
		
		--Druid Power Bar
		if E.myclass == "DRUID" then
			local dpower = CreateFrame('Frame', nil, self)
			dpower:SetFrameStrata("LOW")
			dpower:Point("TOPLEFT", power, "BOTTOMLEFT", -BORDER, -(BORDER+SPACING))
			dpower:Point("BOTTOMRIGHT", power, "BOTTOMRIGHT", BORDER, -((BORDER+SPACING)+POWERBAR_HEIGHT))
			dpower:SetTemplate("Default")
			dpower:SetFrameLevel(dpower:GetFrameLevel() + 1)
			dpower.ManaBar = CreateFrame('StatusBar', nil, dpower)
			dpower.ManaBar:SetStatusBarTexture(C["media"].normTex)
			dpower.ManaBar:Point("TOPLEFT", dpower, "TOPLEFT", BORDER, -BORDER)		
			dpower.ManaBar:Point("BOTTOMRIGHT", dpower, "BOTTOMRIGHT", -BORDER, BORDER)	
			dpower.bg = dpower:CreateTexture(nil, "BORDER")
			dpower.bg:SetAllPoints(dpower.ManaBar)
			dpower.bg:SetTexture(C["media"].blank)
			dpower.bg.multiplier = 0.3
			dpower.colorPower = true
			self.DruidAltMana = dpower
		end
		
		--Portrait
		if C["unitframes"].charportrait == true then
			if C["unitframes"].charportraithealth == true then
				local portrait = CreateFrame("PlayerModel", nil, health)
				portrait:SetFrameLevel(health:GetFrameLevel() + 1)
				portrait:SetAllPoints(health)
				portrait.PostUpdate = E.PortraitUpdate	
				self.Portrait = portrait
				
				local overlay = CreateFrame("Frame", nil, self)
				overlay:SetFrameLevel(self:GetFrameLevel() - 5)
				
				health.bg:ClearAllPoints()
				health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				health.bg:Point('TOPRIGHT', health)
				health.bg:SetDrawLayer("OVERLAY")
				health.bg:SetParent(overlay)
			else
				--Reposition Health
				health:Point("TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)
				
				
				local portrait = CreateFrame("PlayerModel", nil, self)
				portrait:SetFrameStrata("LOW")
				portrait.backdrop = CreateFrame("Frame", nil, portrait)
				portrait.backdrop:SetTemplate("Default")
				if MINI_CLASSBAR and C["unitframes"].classbar == true then
					portrait.backdrop:Point("TOPLEFT", self, "TOPLEFT", 0, -((CLASSBAR_HEIGHT/2)))
				else
					portrait.backdrop:SetPoint("TOPLEFT", self, "TOPLEFT")
				end
				if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
					portrait.backdrop:Point("BOTTOMRIGHT", health.backdrop, "BOTTOMLEFT", -SPACING, 0)
				else
					portrait.backdrop:Point("BOTTOMRIGHT", power.backdrop, "BOTTOMLEFT", -SPACING, 0)
				end
				portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)
				
				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)
				
				portrait.PostUpdate = E.PortraitUpdate	
				
				self.Portrait = portrait
			end
		end
		
		--Anchor aggro glow to the healthbar if powertheme is on
		if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
			if C["unitframes"].charportrait == true and not C["unitframes"].charportraithealth == true then
				self.shadow:Point("BOTTOMLEFT", self.Portrait.backdrop, "BOTTOMLEFT", -4, -4)
			else
				self.shadow:Point("BOTTOMLEFT", health, "BOTTOMLEFT", -5, -5)
			end
			self.shadow:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 5, -5)
		end				
				
		--Auras
		if C["unitframes"].playerbuffs == true then
			local buffs = CreateFrame("Frame", nil, self)
			buffs.num = C["unitframes"].playeraurasperrow * C["unitframes"].playernumbuffrows
			if USE_POWERBAR_OFFSET then
				buffs:SetWidth(PLAYER_WIDTH - POWERBAR_OFFSET)
			else
				buffs:SetWidth(PLAYER_WIDTH)
			end
			buffs.spacing = E.Scale(SPACING)
			if USE_POWERBAR_OFFSET then
				buffs.size = (((((C["unitframes"].playtarwidth - POWERBAR_OFFSET) - (buffs.spacing*(buffs.num/C["unitframes"].playernumbuffrows - 1))) / buffs.num)) * C["unitframes"].playernumbuffrows)*E.ResScale
			else
				buffs.size = ((((C["unitframes"].playtarwidth - (buffs.spacing*(buffs.num/C["unitframes"].playernumbuffrows - 1))) / buffs.num)) * C["unitframes"].playernumbuffrows)*E.ResScale
			end
			buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, SPACING)
			buffs:SetHeight(buffs.size * C["unitframes"].playernumbuffrows)
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs["growth-y"] = "UP"	
			buffs["growth-x"] = "RIGHT"
			buffs.PostCreateIcon = E.PostCreateAura
			buffs.PostUpdateIcon = E.PostUpdateAura
			self.Buffs = buffs
		end
		
		if C["unitframes"].playerdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = C["unitframes"].playeraurasperrow * C["unitframes"].playernumdebuffrows
			if USE_POWERBAR_OFFSET then
				debuffs:SetWidth(PLAYER_WIDTH - POWERBAR_OFFSET)
			else
				debuffs:SetWidth(PLAYER_WIDTH)
			end
			debuffs.spacing = E.Scale(SPACING)
			if USE_POWERBAR_OFFSET then
				debuffs.size = ((((C["unitframes"].playtarwidth - POWERBAR_OFFSET) - (debuffs.spacing*(debuffs.num/C["unitframes"].playernumdebuffrows - 1))) / debuffs.num) * C["unitframes"].playernumbuffrows)*E.ResScale
			else
				debuffs.size = (((C["unitframes"].playtarwidth - (debuffs.spacing*(debuffs.num/C["unitframes"].playernumdebuffrows - 1))) / debuffs.num) * C["unitframes"].playernumbuffrows)*E.ResScale
			end
			debuffs:SetHeight(debuffs.size * C["unitframes"].playernumdebuffrows)
			if C["unitframes"].playerbuffs == true then
				debuffs:Point("BOTTOM", self.Buffs, "TOP", 0, SPACING)
			else
				debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, SPACING)
			end
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end

		--Cast Bar
		if C["unitframes"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, CASTBAR_WIDTH, CASTBAR_HEIGHT, "LEFT")
			castbar:Point("TOPRIGHT", self, "BOTTOMRIGHT", -BORDER, -(BORDER*2+BORDER))

			self.Castbar = castbar
		end
		
		--Swing Bar
		if C["unitframes"].swing == true then
			local swing = E.ConstructSwingBar(self, CASTBAR_WIDTH - (BORDER*2), POWERBAR_HEIGHT - (BORDER*2), false)
			swing:Point("TOPRIGHT", self, "BOTTOMRIGHT", -BORDER, -(BORDER*2+BORDER))
			self.Swing = swing
		end
		
		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints(self.Health.backdrop)
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end

		--Combat Feedback
		if C["unitframes"].combatfeedback == true then
			self:FontString("CombatFeedbackText", FONT, FONTSIZE, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", health, "CENTER", 0, -5)
			
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
		end
		
		--Low Mana
		self:FontString("ManaLevel", FONT, FONTSIZE, "THINOUTLINE")
		self.ManaLevel:Point("CENTER", health, "CENTER", 0, -5)
		self:HookScript("OnUpdate", E.UpdateManaLevel)
		
		--PvP Text
		self:FontString("PvP", FONT, FONTSIZE, "THINOUTLINE")
		self.PvP:Point("CENTER", health, "CENTER", 0, -5)
		self.PvP:SetTextColor(0.69, 0.31, 0.31)
		self.PvP:Hide()
		self.PvP.Override = E.dummy		
		
		self:HookScript("OnUpdate", E.PvPUpdate)
		self:HookScript("OnEnter", function(self) self.ManaLevel:Hide() self.PvP:Show() end)
		self:HookScript("OnLeave", function(self) self.ManaLevel:Show() self.PvP:Hide() end)
		
		--Combat Icon
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:Size(19, 19)
		combat:Point("CENTER", health, "CENTER", 0,7)
		combat:SetVertexColor(0.69, 0.31, 0.31)
		self.Combat = combat		
		
		if not MINI_CLASSBAR then
			--Leader Icon
			local leader = self:CreateTexture(nil, "OVERLAY")
			leader:Size(14)
			leader:Point("TOPRIGHT", self.Health.backdrop, "TOPRIGHT", -4, 8)
			self.Leader = leader
		
			--Master Looter Icon
			local ml = self:CreateTexture(nil, "OVERLAY")
			ml:Size(14)
			self.MasterLooter = ml
			self:RegisterEvent("PARTY_LEADER_CHANGED", E.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.MLAnchorUpdate)	
		end
		
		--Aggro Glow
		if C["unitframes"].displayaggro == true then
			table.insert(self.__elements, E.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		end
		
		--Auto Hide
		if C["unitframes"].combat == true then
			self:RegisterEvent("PLAYER_ENTERING_WORLD", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", E.Fader)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", E.Fader)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", E.Fader)
			self:RegisterEvent("UNIT_HEALTH", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_STOP", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", E.Fader)
			self:RegisterEvent("UNIT_PORTRAIT_UPDATE", E.Fader)
			self:RegisterEvent("UNIT_MODEL_CHANGED", E.Fader)			
			self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
			self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
		end		
		
		--Experience Bar
		if E.level ~= MAX_PLAYER_LEVEL then
			local experience = CreateFrame("StatusBar", nil, self)
			experience:SetStatusBarTexture(NORMTEX)
			experience:SetStatusBarColor(0, 0.4, 1, .8)
			if C["others"].raidbuffreminder == true then
				experience:Size((E.minimapsize - 4) + 1 + (((E.minimapsize - 9) / 6)) + 4, 10)
			else
				experience:Size((E.minimapsize - 4), 10)
			end
			experience:Point("TOPLEFT", ElvuiMinimapStatsLeft, "BOTTOMLEFT", 2, -3)
			experience:SetFrameLevel(Minimap:GetFrameLevel() + 1)
			experience:SetFrameStrata(Minimap:GetFrameStrata())
			
			if C["unitframes"].combat == true then
				experience:HookScript("OnEnter", function(self) E.Fader(self:GetParent(), true) end)
				experience:HookScript("OnLeave", function(self) E.Fader(self:GetParent(), false) end)
			end

			
			experience.Rested = CreateFrame('StatusBar', nil, experience)
			experience.Rested:SetStatusBarTexture(NORMTEX)
			experience.Rested:SetStatusBarColor(1, 0, 1, 0.2)
			experience.Rested:SetFrameLevel(experience:GetFrameLevel() - 1)
			experience.Rested.SetFrameLevel = E.dummy --oUF_Experience thinks its a good idea to set frame level to 1
			experience.Rested:SetAllPoints(experience)
			
			local resting = self:CreateTexture(nil, "OVERLAY")
			resting:Size(22)
			resting:Point("CENTER", health, "TOPLEFT", -3, 6)
			resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			resting:SetTexCoord(0, 0.5, 0, 0.421875)
			resting:Hide()
			self:RegisterEvent("PLAYER_UPDATE_RESTING", E.RestingIconUpdate)
			self.Resting = resting
			
			experience.backdrop = CreateFrame("Frame", nil, experience)
			experience.backdrop:SetTemplate("Default")
			experience.backdrop:Point("TOPLEFT", experience, "TOPLEFT", -2, 2)
			experience.backdrop:Point("BOTTOMRIGHT", experience, "BOTTOMRIGHT", 2, -2)
			experience.backdrop:SetFrameLevel(experience:GetFrameLevel() - 1)
			experience.backdrop:CreateShadow("Default")
			experience.backdrop.shadow:SetFrameLevel(0)
			experience.PostUpdate = E.ReputationPositionUpdate
			experience:SetScript('OnShow', E.ReputationPositionUpdate)
			experience:SetScript('OnHide', E.ReputationPositionUpdate)
			self.Experience = experience
		end

		local reputation = CreateFrame("StatusBar", nil, self)
		reputation:SetStatusBarTexture(NORMTEX)
		reputation:SetStatusBarColor(0, 1, 0.2, 1)
		reputation.color = true
		if C["others"].raidbuffreminder == true then
			reputation:Size((E.minimapsize - 4) + 1 + (((E.minimapsize - 9) / 6)) + 4, 10)
		else
			reputation:Size((E.minimapsize - 4), 10)
		end
		reputation:Point("TOPLEFT", ElvuiMinimapStatsLeft, "BOTTOMLEFT", 2, -3)
		reputation:SetFrameLevel(Minimap:GetFrameLevel() + 1)
		reputation:SetFrameStrata(Minimap:GetFrameStrata())
		
		reputation.Tooltip = true
		if C["unitframes"].combat == true then
			reputation:HookScript("OnEnter", function(self) E.Fader(self:GetParent(), true) end)
			reputation:HookScript("OnLeave", function(self) E.Fader(self:GetParent(), false) end)
		end

		reputation.backdrop = CreateFrame("Frame", nil, reputation)
		reputation.backdrop:SetTemplate("Default")
		reputation.backdrop:Point("TOPLEFT", reputation, "TOPLEFT", -2, 2)
		reputation.backdrop:Point("BOTTOMRIGHT", reputation, "BOTTOMRIGHT", 2, -2)
		reputation.backdrop:SetFrameLevel(reputation:GetFrameLevel() - 1)
		reputation.backdrop:CreateShadow("Default")
		reputation.backdrop.shadow:SetFrameLevel(0)		
		reputation.PostUpdate = E.ReputationPositionUpdate
		self:RegisterEvent("DISABLE_XP_GAIN", E.ReputationPositionUpdate)
		self:RegisterEvent("ENABLE_XP_GAIN", E.ReputationPositionUpdate)		
		self.Reputation = reputation

		--Class Resource Bars
		if C["unitframes"].classbar == true and (E.myclass == "PALADIN" or E.myclass == "SHAMAN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK") then
			--Reposition Health Bar for ClassBars
			local DEPTH
			if MINI_CLASSBAR == true then
				DEPTH = -(BORDER+(CLASSBAR_HEIGHT/2))
			else
				DEPTH = -(BORDER+CLASSBAR_HEIGHT+SPACING)
			end
			
			if USE_POWERBAR_OFFSET then
				health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), DEPTH)
			else
				health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, DEPTH)
			end
			health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, DEPTH)
			
			--Soul Shard / Holy Power Bar
			if E.myclass == "PALADIN" or E.myclass == "WARLOCK" then
				local bars = CreateFrame("Frame", nil, self)
				
				if MINI_CLASSBAR then
					bars:Point("CENTER", health.backdrop, "TOP", -(BORDER*3 + 6), 0)
					bars:SetFrameStrata("MEDIUM")
				else
					bars:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
					bars:SetFrameStrata("LOW")
				end
				bars:Width(CLASSBAR_WIDTH)
				bars:Height(CLASSBAR_HEIGHT - (BORDER*2))

				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", nil, bars)
					bars[i]:SetHeight(bars:GetHeight())	
					bars[i]:SetWidth(E.Scale(bars:GetWidth() - 2)/3)
					bars[i]:SetStatusBarTexture(NORMTEX)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if MINI_CLASSBAR then
						bars[i].backdrop = CreateFrame("Frame", nil, bars)
						bars[i].backdrop:SetTemplate("Default")
						bars[i].backdrop:Point("TOPLEFT", bars[i], "TOPLEFT", -BORDER, BORDER)
						bars[i].backdrop:Point("BOTTOMRIGHT", bars[i], "BOTTOMRIGHT", BORDER, -BORDER)
						bars[i].backdrop:SetFrameLevel(bars[i]:GetFrameLevel() - 1)
					end
					
					if E.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif E.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
					else
						if MINI_CLASSBAR then
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING+(BORDER*2)+8, 0)
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", SPACING, 0)
						end
					end
					
					bars[i].bg:SetAllPoints(bars[i])
					
					
					bars[i].bg:SetTexture(NORMTEX)					
					bars[i].bg:SetAlpha(.15)
				end
				
				if not MINI_CLASSBAR then
					bars.backdrop = CreateFrame("Frame", nil, bars)
					bars.backdrop:SetTemplate("Default")
					bars.backdrop:Point("TOPLEFT", -BORDER, BORDER)
					bars.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
					bars.backdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
					
					bars:SetScript("OnShow", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -(BORDER+CLASSBAR_HEIGHT+SPACING))
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
					end)
					bars:HookScript("OnHide", function()	
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)		
					end)			
				end
				
				if E.myclass == "PALADIN" then
					bars.Override = E.UpdateHoly
					self.HolyPower = bars
				else
					bars.Override = E.UpdateShards
					self.SoulShards = bars
				end	
			end
			
			--Rune Bar
			if E.myclass == "DEATHKNIGHT" then				
				local runes = CreateFrame("Frame", nil, self)
				if MINI_CLASSBAR then
					CLASSBAR_WIDTH = CLASSBAR_WIDTH * 3/2 --Multiply by reciprocal to reset previous setting
					CLASSBAR_WIDTH = CLASSBAR_WIDTH * 4/5
					runes:Point("CENTER", health.backdrop, "TOP", -(BORDER*3 + 8), 0)
					runes:SetFrameStrata("MEDIUM")
				else
					runes:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
					runes:SetFrameStrata("LOW")
				end
				runes:Width(CLASSBAR_WIDTH)
				runes:Height(CLASSBAR_HEIGHT - (BORDER*2))

				for i = 1, 6 do
					runes[i] = CreateFrame("StatusBar", nil, runes)
					runes[i]:Height(runes:GetHeight())
					runes[i]:SetWidth(E.Scale(runes:GetWidth() - 5) / 6)
					
					if MINI_CLASSBAR then
						runes[i].backdrop = CreateFrame("Frame", nil, runes)
						runes[i].backdrop:SetTemplate("Default")
						runes[i].backdrop:Point("TOPLEFT", runes[i], "TOPLEFT", -BORDER, BORDER)
						runes[i].backdrop:Point("BOTTOMRIGHT", runes[i], "BOTTOMRIGHT", BORDER, -BORDER)
						runes[i].backdrop:SetFrameLevel(runes[i]:GetFrameLevel() - 1)
					end					

					if (i == 1) then
						runes[i]:SetPoint("LEFT", runes)
					else
						if MINI_CLASSBAR then
							runes[i]:Point("LEFT", runes[i-1], "RIGHT", SPACING+(BORDER*2)+2, 0)
						else
							runes[i]:Point("LEFT", runes[i-1], "RIGHT", SPACING, 0)
						end
					end
					runes[i]:SetStatusBarTexture(NORMTEX)
					runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end
				
				if not MINI_CLASSBAR then
					runes.backdrop = CreateFrame("Frame", nil, runes)
					runes.backdrop:SetTemplate("Default")
					runes.backdrop:Point("TOPLEFT", -BORDER, BORDER)
					runes.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
					runes.backdrop:SetFrameLevel(runes:GetFrameLevel() - 1)

					runes:HookScript("OnShow", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -(BORDER+CLASSBAR_HEIGHT+SPACING))
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
					end)
					runes:HookScript("OnHide", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)		
					end)	
				end
				
				self.Runes = runes
			end
			
			--Totem Bar
			if E.myclass == "SHAMAN" then
				local totems = CreateFrame("Frame", nil, self)
				if not MINI_CLASSBAR then
					totems:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
					totems:SetFrameStrata("LOW")
				else
					CLASSBAR_WIDTH = CLASSBAR_WIDTH * 3/2 --Multiply by reciprocal to reset previous setting
					CLASSBAR_WIDTH = CLASSBAR_WIDTH * 4/5
					totems:Point("CENTER", health.backdrop, "TOP", -(BORDER*3 + 6), 0)
					totems:SetFrameStrata("MEDIUM")			
				end
				totems:Width(CLASSBAR_WIDTH)
				totems:Height(CLASSBAR_HEIGHT - (BORDER*2))
				totems.Destroy = true

				for i = 1, 4 do
					totems[i] = CreateFrame("StatusBar", nil, totems)
					totems[i]:SetHeight(totems:GetHeight())
					totems[i]:SetFrameStrata(self:GetFrameStrata())
					totems[i]:SetFrameLevel(self:GetFrameLevel())
					totems[i]:SetWidth(E.Scale(totems:GetWidth() - 3) / 4)

					if MINI_CLASSBAR then
						totems[i].backdrop = CreateFrame("Frame", nil, totems[i])
						totems[i].backdrop:SetTemplate("Default")
						totems[i].backdrop:Point("TOPLEFT", totems[i], "TOPLEFT", -BORDER, BORDER)
						totems[i].backdrop:Point("BOTTOMRIGHT", totems[i], "BOTTOMRIGHT", BORDER, -BORDER)
						totems[i].backdrop:SetFrameLevel(totems[i]:GetFrameLevel() - 2)
					end						
					
					if (i == 1) then
						totems[i]:SetPoint("LEFT", totems)
					else
						if MINI_CLASSBAR then
							totems[i]:Point("LEFT", totems[i-1], "RIGHT", SPACING+(BORDER*2)+4, 0)
						else
							totems[i]:Point("LEFT", totems[i-1], "RIGHT", SPACING, 0)
						end
					end
					totems[i]:SetStatusBarTexture(NORMTEX)
					totems[i]:GetStatusBarTexture():SetHorizTile(false)
					totems[i]:SetMinMaxValues(0, 1)

					
					totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
					totems[i].bg:SetAllPoints()
					totems[i].bg:SetTexture(NORMTEX)
					totems[i].bg.multiplier = 0.3
				end
				
				if not MINI_CLASSBAR then
					totems.backdrop = CreateFrame("Frame", nil, totems)
					totems.backdrop:SetTemplate("Default")
					totems.backdrop:Point("TOPLEFT", -BORDER, BORDER)
					totems.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
					totems.backdrop:SetFrameLevel(totems:GetFrameLevel() - 1)
					
					totems:HookScript("OnShow", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -(BORDER+CLASSBAR_HEIGHT+SPACING))
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
					end)
					totems:HookScript("OnHide", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)		
					end)
				end
				
				self.TotemBar = totems			
			end
			
			--Eclipse Bar
			if E.myclass == "DRUID" then
				local eclipseBar = CreateFrame('Frame', nil, self)
				if not MINI_CLASSBAR then
					eclipseBar:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
					eclipseBar:SetFrameStrata("LOW")
				else
					eclipseBar:Point("LEFT", health.backdrop, "TOPLEFT", (BORDER*2 + 4), 0)
					eclipseBar:SetFrameStrata("MEDIUM")						
				end
				eclipseBar:Width(CLASSBAR_WIDTH)
				eclipseBar:Height(CLASSBAR_HEIGHT - (BORDER*2))

				local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(NORMTEX)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
				solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT')
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(NORMTEX)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				eclipseBar.SolarBar = solarBar

				eclipseBar:FontString("Text", FONT, 10, "THINOUTLINE")
				eclipseBar.Text:SetPoint("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")
				eclipseBar.Text:SetParent(lunarBar)
				
				eclipseBar.backdrop = CreateFrame("Frame", nil, eclipseBar)
				eclipseBar.backdrop:SetTemplate("Default")
				eclipseBar.backdrop:Point("TOPLEFT", eclipseBar, "TOPLEFT", -BORDER, BORDER)
				eclipseBar.backdrop:Point("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", BORDER, -BORDER)
				eclipseBar.backdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
				
				if not MINI_CLASSBAR then
					eclipseBar:HookScript("OnShow", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -(BORDER+CLASSBAR_HEIGHT+SPACING))
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -(BORDER+CLASSBAR_HEIGHT+SPACING))
					end)
					eclipseBar:HookScript("OnHide", function()
						if USE_POWERBAR_OFFSET then
							health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+POWERBAR_OFFSET), -BORDER)
						else
							health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
						end
						health:Point("TOPLEFT", self, "TOPLEFT", PORTRAIT_WIDTH+BORDER, -BORDER)
					end)
				end
				
				self.EclipseBar = eclipseBar
				self.EclipseBar.PostUpdatePower = E.EclipseDirection
			end
		end
		
		--Druid Mana
		if E.myclass == "DRUID" then
			self:FontString("DruidMana", FONT, FONTSIZE, "THINOUTLINE")
			self.DruidMana:SetTextColor(1, 0.49, 0.04)	
			self:HookScript("OnUpdate", E.UpdateDruidMana)
		end
		
		--Alternative Power Bar
		local altpower = CreateFrame("StatusBar", nil, health)
		altpower:SetStatusBarTexture(NORMTEX)
		altpower:GetStatusBarTexture():SetHorizTile(false)
		altpower:EnableMouse(true)
		altpower:SetFrameStrata("MEDIUM")
		altpower.PostUpdate = E.AltPowerBarPostUpdate
		altpower:CreateBackdrop("Default", true)
		altpower:Point("TOPLEFT", ElvuiInfoLeft, "TOPLEFT", 2, -2)
		altpower:Width(ChatLBG:GetWidth() - 52)
		altpower:Height(18)
		altpower:HookScript("OnShow", E.AltPowerBarOnToggle)
		altpower:HookScript("OnHide", E.AltPowerBarOnToggle)
		
		altpower:FontString("text", FONT, FONTSIZE, "THINOUTLINE")
		altpower.text:SetPoint("CENTER")
		altpower.text:SetJustifyH("CENTER")		
		self.AltPowerBar = altpower
		
		--Incoming Heals
		if C["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self)
			mhpb:SetFrameLevel(self:GetFrameLevel() - 2)
			mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			mhpb:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')	
			mhpb:SetWidth(POWERBAR_WIDTH)
			mhpb:SetStatusBarTexture(C["media"].blank)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			
			local ohpb = CreateFrame('StatusBar', nil, self)
			ohpb:SetFrameLevel(self:GetFrameLevel() - 2)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(mhpb:GetWidth())
			ohpb:SetStatusBarTexture(C["media"].blank)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)
			
			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
				PostUpdate = function(self)
					if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
					if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
				end
			}
		end			
	end
	
	------------------------------------------------------------------------
	-- Target
	------------------------------------------------------------------------
	if unit == "target" then
		local POWERBAR_WIDTH = C["unitframes"].playtarwidth/2*E.ResScale
		local CLASSBAR_WIDTH = (C["unitframes"].playtarwidth - (2*2))*E.ResScale
		local CLASSBAR_HEIGHT = (C["unitframes"].classbar_height)*E.ResScale
		local POWERBAR_HEIGHT = (C["unitframes"].powerbar_height)*E.ResScale
		local CASTBAR_HEIGHT = C["unitframes"].casttargetheight*E.ResScale
		local CASTBAR_WIDTH = C["unitframes"].casttargetwidth*E.ResScale
		local PORTRAIT_WIDTH = 45*E.ResScale		
		
		if C["unitframes"].charportraithealth == true or C["unitframes"].charportrait == false then
			PORTRAIT_WIDTH = 0
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end			
		elseif C["unitframes"].charportrait == true then
			CLASSBAR_WIDTH = math.ceil(((C["unitframes"].playtarwidth - (2*2)) - 45)*E.ResScale)
			
			if USE_POWERBAR_OFFSET then
				CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
			end
		elseif USE_POWERBAR_OFFSET then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH - POWERBAR_OFFSET
		end		

		--Health Bar
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		
		if USE_POWERBAR_OFFSET then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER+POWERBAR_OFFSET, BORDER+POWERBAR_OFFSET)
		elseif POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end

		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		self.Health = health

		--Power Bar
		local power = E.ConstructPowerBar(self, true, true)
		if USE_POWERBAR_OFFSET then
			power:Point("TOPLEFT", health, "TOPLEFT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
			power:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", -POWERBAR_OFFSET, -POWERBAR_OFFSET)
			power:SetFrameStrata("LOW")
			power:SetFrameLevel(2)
		elseif POWERTHEME == true then
			power:Width(POWERBAR_WIDTH - BORDER*2)
			power:Height(POWERBAR_HEIGHT - BORDER*2)
			power:Point("LEFT", self, "BOTTOMLEFT", BORDER*2 + 4, BORDER + (POWERBAR_HEIGHT/2))
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPRIGHT", health.backdrop, "BOTTOMRIGHT", -BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER)
		end		
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		
		self.Power = power

		--Name
		self:FontString("Name", FONT, FONTSIZE, "THINOUTLINE")
		self.Name:SetJustifyH("LEFT")
		self.Name.frequentUpdates = 0.2
		self.Name:SetShadowColor(0, 0, 0, 0)
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namelong] [Elvui:diffcolor][level] [shortclassification]')
		
		--Portrait
		if C["unitframes"].charportrait == true then
			if C["unitframes"].charportraithealth == true then
				local portrait = CreateFrame("PlayerModel", nil, health)
				portrait:SetFrameLevel(health:GetFrameLevel() + 1)
				portrait:SetAllPoints(health)
				portrait.PostUpdate = E.PortraitUpdate			
				self.Portrait = portrait
				
				local overlay = CreateFrame("Frame", nil, self)
				overlay:SetFrameLevel(self:GetFrameLevel() - 5)
				
				health.bg:ClearAllPoints()
				health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				health.bg:Point('TOPRIGHT', health)
				health.bg:SetDrawLayer("OVERLAY")
				health.bg:SetParent(overlay)
			else
				--Reposition Health
				health:Point("TOPRIGHT", -(PORTRAIT_WIDTH+BORDER), -BORDER)
				
				local portrait = CreateFrame("PlayerModel", nil, self)
				portrait:SetFrameStrata("LOW")
				portrait.backdrop = CreateFrame("Frame", nil, portrait)
				portrait.backdrop:SetTemplate("Default")
				portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
				if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
					portrait.backdrop:Point("BOTTOMLEFT", health.backdrop, "BOTTOMRIGHT", SPACING, 0)
				else
					portrait.backdrop:Point("BOTTOMLEFT", power.backdrop, "BOTTOMRIGHT", SPACING, 0)
				end				
				portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)
				
				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)
				
				portrait.PostUpdate = E.PortraitUpdate	
				
				self.Portrait = portrait
			end
		end
				
		--Auras
		if C["unitframes"].targetbuffs then
			local buffs = CreateFrame("Frame", nil, self)
			buffs.num = C["unitframes"].targetaurasperrow * C["unitframes"].targetnumbuffrows
			buffs.spacing = E.Scale(SPACING)
			if USE_POWERBAR_OFFSET then
				buffs:SetWidth(TARGET_WIDTH - POWERBAR_OFFSET)
				buffs.size = (((((C["unitframes"].playtarwidth - POWERBAR_OFFSET) - (buffs.spacing*(buffs.num/C["unitframes"].targetnumbuffrows - 1))) / buffs.num)) * C["unitframes"].targetnumbuffrows)*E.ResScale
				buffs:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, SPACING)				
			else
				buffs:SetWidth(TARGET_WIDTH)
				buffs.size = ((((C["unitframes"].playtarwidth - (buffs.spacing*(buffs.num/C["unitframes"].targetnumbuffrows - 1))) / buffs.num)) * C["unitframes"].targetnumbuffrows)*E.ResScale
				buffs:Point("BOTTOM", self, "TOP", 0, SPACING)
			end
			
			buffs:SetHeight(buffs.size * C["unitframes"].targetnumbuffrows)
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs["growth-y"] = "UP"	
			buffs["growth-x"] = "RIGHT"
			buffs.PostCreateIcon = E.PostCreateAura
			buffs.PostUpdateIcon = E.PostUpdateAura
			self.Buffs = buffs	
		end
		
		if C["unitframes"].targetdebuffs then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = C["unitframes"].targetaurasperrow * C["unitframes"].targetnumdebuffrows
			debuffs.spacing = E.Scale(SPACING)
			if USE_POWERBAR_OFFSET then
				debuffs:SetWidth(TARGET_WIDTH - POWERBAR_OFFSET)
				debuffs.size = (((((C["unitframes"].playtarwidth - POWERBAR_OFFSET) - (debuffs.spacing*(debuffs.num/C["unitframes"].targetnumdebuffrows - 1))) / debuffs.num)) * C["unitframes"].targetnumbuffrows)*E.ResScale
			else
				debuffs:SetWidth(TARGET_WIDTH)
				debuffs.size = (((C["unitframes"].playtarwidth - (debuffs.spacing*(debuffs.num/C["unitframes"].targetnumdebuffrows - 1))) / debuffs.num) * C["unitframes"].targetnumdebuffrows)*E.ResScale
			end
			debuffs:SetHeight(debuffs.size * C["unitframes"].targetnumdebuffrows)
			if C["unitframes"].targetbuffs then
				debuffs:Point("BOTTOM", self.Buffs, "TOP", 0, SPACING)
			else
				debuffs:Point("BOTTOM", self, "TOP", 0, SPACING)
			end
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end

		--Cast Bar
		if C["unitframes"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, CASTBAR_WIDTH, CASTBAR_HEIGHT, "RIGHT")
			castbar:Point("TOPLEFT", self, "BOTTOMLEFT", BORDER, -(BORDER*2+BORDER))
			
			self.Castbar = castbar
		end
		
		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints(self.Health.backdrop)
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end

		--Combat Feedback
		if C["unitframes"].combatfeedback == true then
			self:FontString("CombatFeedbackText", FONT, FONTSIZE, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", health, "CENTER", 0, -5)
			
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
		end
				
		--Combo Bar
		local combo = CreateFrame("Frame", nil, self)
		if C["unitframes"].mini_classbar then
			CLASSBAR_WIDTH = CLASSBAR_WIDTH * 4/5
			combo:Point("CENTER", health.backdrop, "TOP", -(BORDER*3 + 6), 0)
			combo:SetFrameStrata("MEDIUM")
		else
			combo:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
			combo:SetFrameStrata("LOW")
		end
		combo:Width(CLASSBAR_WIDTH)
		combo:Height(CLASSBAR_HEIGHT - (BORDER*2))

		for i = 1, 5 do					
			combo[i] = CreateFrame("StatusBar", nil, combo)
			combo[i]:SetHeight(combo:GetHeight())					
			combo[i]:SetStatusBarTexture(NORMTEX)
			combo[i]:GetStatusBarTexture():SetHorizTile(false)
			
			if C["unitframes"].mini_classbar then
				combo[i].backdrop = CreateFrame("Frame", nil, combo)
				combo[i].backdrop:SetTemplate("Default")
				combo[i].backdrop:Point("TOPLEFT", combo[i], "TOPLEFT", -BORDER, BORDER)
				combo[i].backdrop:Point("BOTTOMRIGHT", combo[i], "BOTTOMRIGHT", BORDER, -BORDER)
				combo[i].backdrop:SetFrameLevel(combo[i]:GetFrameLevel() - 1)
			end	
					
			if i == 1 then
				combo[i]:SetPoint("LEFT", combo)
			else
				if C["unitframes"].mini_classbar then
					combo[i]:Point("LEFT", combo[i-1], "RIGHT", SPACING+(BORDER*2)+2, 0)
				else
					combo[i]:Point("LEFT", combo[i-1], "RIGHT", SPACING, 0)
				end
			end
			combo[i]:SetAlpha(0.15)
			combo[i]:SetWidth(E.Scale(CLASSBAR_WIDTH - 4)/5)
		end
		
		combo[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		combo[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		combo[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		combo[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		combo[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		
		
		if not C["unitframes"].mini_classbar then
			combo.backdrop = CreateFrame("Frame", nil, combo)
			combo.backdrop:SetTemplate("Default")
			combo.backdrop:Point("TOPLEFT", -BORDER, BORDER)
			combo.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
			combo.backdrop:SetFrameLevel(combo:GetFrameLevel() - 1)
			
			--[[This is a little differant than everything else because we have to take into account 
			the combobar is movable with the /moveele command, this should make it work correctly only 
			after a reloadui.]]
			combo:HookScript("OnShow", function()		
				if E["elements"] and DPSComboBar and E["elements"]["DPSComboBar"] and E.CreatedMoveEleFrames["DPSComboBar"] then return end
				combo:ClearAllPoints()
				combo:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+SPACING)
				
				health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER+POWERBAR_HEIGHT+SPACING))
			end)
			combo:HookScript("OnHide", function()
				health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER)
			end)
		else
			combo:HookScript("OnShow", function()
				if E["elements"] and DPSComboBar and E["elements"]["DPSComboBar"] and E.CreatedMoveEleFrames["DPSComboBar"] then return end
				combo:ClearAllPoints()
				combo:Point("CENTER", health.backdrop, "TOP", -(BORDER*3 + 6), 0)

				if self.Portrait and self.Portrait.backdrop then
					health:Point("TOPRIGHT", self, "TOPRIGHT", -(PORTRAIT_WIDTH+BORDER), -BORDER-(POWERBAR_HEIGHT/2))
					self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -(POWERBAR_HEIGHT/2))
				else
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER-(POWERBAR_HEIGHT/2))
				end
			end)
			
			combo:HookScript("OnHide", function()
				if self.Portrait and self.Portrait.backdrop then
					self.Portrait.backdrop:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
					health:Point("TOPRIGHT", self, "TOPRIGHT", -(PORTRAIT_WIDTH+BORDER), -BORDER)
				else
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
				end				
			end)
		end
		
		combo:SetScript("OnUpdate", function()
			if C["general"].classcolortheme == true and combo:IsShown() then
				if combo.backdrop then
					combo.backdrop:SetBackdropBorderColor(unpack(self.Health.defaultColor))
				else
					for i=1, 5 do
						combo[i].backdrop:SetBackdropBorderColor(unpack(self.Health.defaultColor))
					end
				end
			elseif C["general"].classcolortheme ~= true then
				combo:SetScript("OnUpdate", nil)
			end			
		end)
			
		combo:Hide()
		
		combo.Override = E.ComboDisplay
		self.CPoints = combo
		
		--Incoming Heals
		if C["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self)
			mhpb:SetFrameLevel(self:GetFrameLevel() - 2)
			mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			mhpb:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')	
			mhpb:SetWidth(POWERBAR_WIDTH)
			mhpb:SetStatusBarTexture(C["media"].blank)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			
			local ohpb = CreateFrame('StatusBar', nil, self)
			ohpb:SetFrameLevel(self:GetFrameLevel() - 2)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(mhpb:GetWidth())
			ohpb:SetStatusBarTexture(C["media"].blank)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)
			
			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
				PostUpdate = function(self)
					if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
					if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
				end
			}
		end					
	end
	
	------------------------------------------------------------------------
	--	TargetofTarget, Pet, PetTarget, Focus, FocusTarget
	------------------------------------------------------------------------
	if (unit == "targettarget" or unit == "pet" or unit == "pettarget" or unit == "focustarget" or unit == "focus") then
		local POWERBAR_WIDTH = C["unitframes"].smallwidth/1.5*E.ResScale
		local POWERBAR_HEIGHT = C["unitframes"].powerbar_height*0.8
		local CASTBAR_WIDTH = C["unitframes"].castfocuswidth*E.ResScale
		local CASTBAR_HEIGHT = C["unitframes"].castfocusheight*E.ResScale
		
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		
		self.Health = health

		--Power Bar
		if unit ~= "pettarget" then
			local power = E.ConstructPowerBar(self, true, nil)
			if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
				power:Width(POWERBAR_WIDTH - BORDER*2)
				power:Height(POWERBAR_HEIGHT - BORDER*2)
				power:Point("CENTER", self, "BOTTOM", 0, BORDER + (POWERBAR_HEIGHT/2))
				power:SetFrameStrata("MEDIUM")
				power:SetFrameLevel(self:GetFrameLevel() + 3)
			else
				power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
				power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)
			end					
			
			self.Power = power
		end
		
		--Name
		self:FontString("Name", FONT, FONTSIZE, "THINOUTLINE")
		self.Name:Point("CENTER", health, "CENTER", 0, 2)
		self.Name:SetShadowColor(0, 0, 0, 0)
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')		
		
		--Auras
		if (unit == "targettarget" and C["unitframes"].totdebuffs == true) or (unit == "focus" and C["unitframes"].focusdebuffs == true) then	
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = C["unitframes"].smallaurasperrow
			debuffs:SetWidth(SMALL_WIDTH)
			debuffs.spacing = E.Scale(SPACING)
			debuffs.size = ((C["unitframes"].smallwidth - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)*E.ResScale
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("TOP", self, "BOTTOM", 0, -SPACING)	
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end
	
		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints(self.Health.backdrop)
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end
		
		if unit == "pet" then
			--Dummy Cast Bar, so we don't see an extra castbar while in vehicle
			if (C["unitframes"].unitcastbar == true) then
				local castbar = CreateFrame("StatusBar", nil, self)
				self.Castbar = castbar
			end
			
			--Incoming Pet Heals
			if C["raidframes"].raidunitbuffwatch == true then
				E.createAuraWatch(self,unit)
			end
			
			--Autohide in combat
			if C["unitframes"].combat == true then
				self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
				self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
			end
		elseif unit == "focus" and C["unitframes"].unitcastbar == true	then
			--Cast Bar
			local castbar = E.ConstructCastBar(self, CASTBAR_WIDTH, CASTBAR_HEIGHT, "LEFT")
			castbar:Point("TOP", E.UIParent, "TOP", 0, -150)
			
			self.Castbar = castbar
		end
	end
	
	------------------------------------------------------------------------
	--	Arena and Boss
	------------------------------------------------------------------------
	if (unit and unit:find("arena%d") and C["unitframes"].arena == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		local POWERBAR_WIDTH = C["unitframes"].arenabosswidth/2*E.ResScale
		local TRINKET_WIDTH = BOSS_HEIGHT * 0.9
		local POWERBAR_HEIGHT = C["unitframes"].powerbar_height*0.7
		local CASTBAR_HEIGHT = 16*E.ResScale
		local CASTBAR_WIDTH = BOSS_WIDTH

		if unit:find("arena%d") then
			POWERBAR_WIDTH = C["unitframes"].arenabosswidth/2.3*E.ResScale
		end
		
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		--Health Bar
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end

		health.value:Point("TOPRIGHT", health, "TOPRIGHT", 0, -2)
		self.Health = health
		
		--Power Bar
		local power = E.ConstructPowerBar(self, true, true)
		if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
			power:Width(POWERBAR_WIDTH - BORDER*2)
			power:Height(POWERBAR_HEIGHT - BORDER*2)
			power:Point("LEFT", self, "BOTTOMLEFT", BORDER*2 + 4, BORDER + (POWERBAR_HEIGHT/2))
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPRIGHT", health.backdrop, "BOTTOMRIGHT", -BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER)
		end		
		power.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT")
		
		self.Power = power
				
		--Name & Trinkets
		if (unit and unit:find('arena%d')) then
			health:Point("TOPRIGHT", self, "TOPRIGHT", -(TRINKET_WIDTH + BORDER), -BORDER)
			
			local trinket = CreateFrame("Frame", nil, self)
			trinket.trinketUseAnnounce = true
			
			trinket.bg = CreateFrame("Frame", nil, trinket)
			trinket.bg:Point("TOPRIGHT", self, "TOPRIGHT")
			if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
				trinket.bg:SetPoint("BOTTOMLEFT", health.backdrop, "BOTTOMRIGHT", SPACING, 0)
			else
				trinket.bg:SetPoint("BOTTOMLEFT", power.backdrop, "BOTTOMRIGHT", SPACING, 0)		
			end
			trinket.bg:SetTemplate("Default")
			trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
			
			trinket:Point("TOPLEFT", trinket.bg, BORDER, -BORDER)
			trinket:Point("BOTTOMRIGHT", trinket.bg, -BORDER, BORDER)
			
			self.Trinket = trinket			
		end
		
		--Name & AltPowerBar
		if (unit and unit:find('boss%d')) then
			local altpower = CreateFrame("StatusBar", nil, self)
			altpower:SetStatusBarTexture(NORMTEX)
			altpower:GetStatusBarTexture():SetHorizTile(false)
			altpower.PostUpdate = E.AltPowerBarPostUpdate
			
			altpower.bg = CreateFrame("Frame", nil, altpower)
			altpower.bg:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", 0, SPACING)
			altpower.bg:Point("TOPRIGHT", self, "TOPRIGHT")
			altpower.bg:SetTemplate("Default")
			altpower.bg:SetFrameLevel(altpower:GetFrameLevel() - 1)

			altpower:Point("TOPLEFT", altpower.bg, "TOPLEFT", BORDER, -BORDER)
			altpower:Point("BOTTOMRIGHT", altpower.bg, "BOTTOMRIGHT", -BORDER, BORDER)
			
			altpower:FontString("text", FONT, FONTSIZE, "THINOUTLINE")
			altpower.text:Point("RIGHT", power.value, "LEFT", 2, E.mult)		
			
			altpower:HookScript("OnShow", function(self) 			
				health:Point("TOPRIGHT", self:GetParent(), "TOPRIGHT", -BORDER, -(POWERBAR_HEIGHT + BORDER))	
			end)
			
			altpower:HookScript("OnHide", function(self) 
				health:Point("TOPRIGHT", self:GetParent(), "TOPRIGHT", -BORDER, -BORDER)
				altpower.text:SetText("")
			end)
			
			self.AltPowerBar = altpower
		end
		
		--Name
		self:FontString("Name", FONT, FONTSIZE, "THINOUTLINE")
		self.Name:Point("LEFT", health, "LEFT", 4, 0)
		self.Name:SetShadowColor(0, 0, 0, 0)
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')
				
		--Auras
		if (unit and unit:find("arena%d") and C["unitframes"].arenabuffs == true) or (unit and unit:find("boss%d") and C["unitframes"].bossbuffs == true) then
			local buffs = CreateFrame("Frame", nil, self)
			buffs.num = 3
			buffs:SetWidth(BOSS_WIDTH)
			buffs.spacing = E.Scale(SPACING)
			if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
				buffs.size = BOSS_HEIGHT - (POWERBAR_HEIGHT - BORDER - SPACING)
			else
				buffs.size = BOSS_HEIGHT
			end
			buffs:Point("TOPRIGHT", self, "TOPLEFT", -4, 0)
			buffs:SetHeight(buffs.size)
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-y"] = "UP"	
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = E.PostCreateAura
			buffs.PostUpdateIcon = E.PostUpdateAura
			if (unit and unit:find('arena%d')) then
				buffs.CustomFilter = E.AuraFilter
			end
			self.Buffs = buffs	
		end
		
		if (unit and unit:find("arena%d") and C["unitframes"].arenadebuffs == true) or (unit and unit:find("boss%d") and C["unitframes"].bossdebuffs == true) then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = 3
			debuffs:SetWidth(BOSS_WIDTH)
			debuffs.spacing = E.Scale(2)
			if POWERTHEME == true or USE_POWERBAR_OFFSET == true then
				debuffs.size = BOSS_HEIGHT - (POWERBAR_HEIGHT - BORDER - SPACING)
			else
				debuffs.size = BOSS_HEIGHT
			end
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("TOPLEFT", self, "TOPRIGHT", 4, 0)
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end
		
		--Cast Bar
		if C["unitframes"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, CASTBAR_WIDTH, CASTBAR_HEIGHT, "RIGHT")
			castbar:Point("TOPLEFT", self, "BOTTOMLEFT", BORDER, -BORDER*2)
			
			self.Castbar = castbar
		end
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists
	------------------------------------------------------------------------
	if unit == "maintank" or unit == "mainassist" or unit == "maintanktarget" or unit == "mainassisttarget" then
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER)
		self.Health = health
	
		--Name
		self:FontString("Name", FONT, FONTSIZE, "THINOUTLINE")
		self.Name:Point("CENTER", health, "CENTER", 0, 2)
		self.Name:SetShadowColor(0, 0, 0, 0)
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')			
	end
	
	------------------------------------------------------------------------
	--	All Units
	------------------------------------------------------------------------
	if unit ~= "party" then
		local x = CreateFrame("Frame", nil, self)
		x:SetFrameStrata("MEDIUM")
		x:SetFrameLevel(50)
		local RaidIcon = x:CreateTexture(nil, "OVERLAY")
		RaidIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp") 
		RaidIcon:Size(18, 18)
		RaidIcon:Point("CENTER", self.Health, "TOP", 0, BORDER)
		self.RaidIcon = RaidIcon
	end
		
	return self
end

------------------------------------------------------------------------
--	Default Positions
------------------------------------------------------------------------

local function LoadDPSLayout()
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

	if E.LoadUFFunctions then E.LoadUFFunctions("ElvDPS") end
	oUF:RegisterStyle('Elv', Shared)

	-- Player
	local player = oUF:Spawn('player', "ElvDPS_player")
	player:Point("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", 0, 35)
	player:Size(PLAYER_WIDTH, PLAYER_HEIGHT)

	-- Target
	local target = oUF:Spawn('target', "ElvDPS_target")
	target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, 35)
	target:Size(TARGET_WIDTH, TARGET_HEIGHT)

	-- Focus
	local focus = oUF:Spawn('focus', "ElvDPS_focus")
	focus:Point("BOTTOMLEFT", ElvDPS_target, "TOPRIGHT", -35, 120)
	focus:Size(SMALL_WIDTH, SMALL_HEIGHT)

	-- Target's Target
	local tot = oUF:Spawn('targettarget', "ElvDPS_targettarget")
	tot:Point("BOTTOM", ElvuiActionBarBackground, "TOP", 0, 35)
	tot:Size(SMALL_WIDTH, SMALL_HEIGHT)

	-- Player's Pet
	local pet = oUF:Spawn('pet', "ElvDPS_pet")
	pet:Point("BOTTOM", ElvDPS_targettarget, "TOP", 0, 15)
	pet:Size(SMALL_WIDTH, SMALL_HEIGHT)
	pet:SetParent(player)

	-- Player's Pet's Target
	if C["unitframes"].pettarget == true then
		local pettarget = oUF:Spawn('pettarget', "ElvDPS_pettarget")
		pettarget:Point("BOTTOM", ElvDPS_pet, "TOP", 0, 8)
		pettarget:Size(SMALL_WIDTH, SMALL_HEIGHT*0.8)
		pettarget:SetParent(pet)
	end

	-- Focus's target
	if C["unitframes"].showfocustarget == true then
		local focustarget = oUF:Spawn('focustarget', "ElvDPS_focustarget")
		focustarget:Point("BOTTOM", ElvDPS_focus, "TOP", 0, 15)
		focustarget:Size(SMALL_WIDTH, SMALL_HEIGHT)
	end

	if C.unitframes.arena then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "ElvDPSArena"..i)
			if i == 1 then
				arena[i]:Point("BOTTOMLEFT", ChatRBGDummy, "TOPLEFT", -80, 185)
			else
				arena[i]:Point("BOTTOM", arena[i-1], "TOP", 0, 25)
			end
			arena[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end

	if C["unitframes"].showboss then
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "ElvDPSBoss"..i)
			if i == 1 then
				boss[i]:Point("BOTTOMLEFT", ChatRBGDummy, "TOPLEFT", -80, 185)
			else
				boss[i]:Point('BOTTOM', boss[i-1], 'TOP', 0, 25)             
			end
			boss[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end
	
	if C["raidframes"].maintank == true then
		local tank = oUF:SpawnHeader('ElvDPSMainTank', nil, 'raid', 
			'oUF-initialConfigFunction', ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(TANK_WIDTH, TANK_HEIGHT),
			'showRaid', true, 
			'groupFilter', 'MAINTANK', 
			'yOffset', 7, 
			'point' , 'BOTTOM',
			'template', 'Elv_Mtt'
		)
		tank:Point("LEFT", E.UIParent, "LEFT", 6, 250)
	end

	if C["raidframes"].mainassist == true then
		local assist = oUF:SpawnHeader("ElvDPSMainAssist", nil, 'raid', 
			'oUF-initialConfigFunction', ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(TANK_WIDTH, TANK_HEIGHT),
			'showRaid', true, 
			'groupFilter', 'MAINASSIST', 
			'yOffset', 7, 
			'point' , 'BOTTOM',
			'template', 'Elv_Mtt'
		)
		if C["raidframes"].maintank == true then 
			assist:Point("TOPLEFT", ElvDPSMainTank, "BOTTOMLEFT", 0, -50)
		else
			assist:Point("LEFT", E.UIParent, "LEFT", 6, 250)
		end
	end

	local party
	if C["raidframes"].disableblizz == true then --seriosly lazy addon authors can suck my dick
		for i = 1,MAX_BOSS_FRAMES do
			local t_boss = _G["Boss"..i.."TargetFrame"]
			t_boss:UnregisterAllEvents()
			t_boss.Show = E.dummy
			t_boss:Hide()
			_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
			_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
		end
		
		party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)
	end

	E.LoadMoveElements("DPS")
	if C["classtimer"].enable == true then
		E.LoadClassTimers(ElvDPS_player, ElvDPS_target)
	end	
end

E.Layouts["DPS"] = LoadDPSLayout

------------------------------------------------------------------------
--	Right-Click on unit frames menu.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "SELECT_ROLE", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end