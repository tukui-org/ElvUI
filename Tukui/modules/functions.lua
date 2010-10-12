function TukuiDB.UIScale()
	-- the tukui high reso whitelist
	if not (TukuiDB.getscreenresolution == "1680x945"
		or TukuiDB.getscreenresolution == "2560x1440" 
		or TukuiDB.getscreenresolution == "1680x1050" 
		or TukuiDB.getscreenresolution == "1920x1080" 
		or TukuiDB.getscreenresolution == "1920x1200" 
		or TukuiDB.getscreenresolution == "1600x900" 
		or TukuiDB.getscreenresolution == "2048x1152" 
		or TukuiDB.getscreenresolution == "1776x1000" 
		or TukuiDB.getscreenresolution == "2560x1600" 
		or TukuiDB.getscreenresolution == "1600x1200") then
			if TukuiCF["general"].overridelowtohigh == true then
				TukuiCF["general"].autoscale = false
				TukuiDB.lowversion = false
			else
				TukuiDB.lowversion = true
			end			
	end

	if TukuiCF["general"].autoscale == true then
		-- i'm putting a autoscale feature mainly for an easy auto install process
		-- we all know that it's not very effective to play via 1024x768 on an 0.64 uiscale :P
		-- with this feature on, it should auto choose a very good value for your current reso!
		TukuiCF["general"].uiscale = min(2, max(.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")))
	end

	if TukuiDB.lowversion then
		TukuiDB.raidscale = 0.8
	else
		TukuiDB.raidscale = 1
	end
end
TukuiDB.UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/TukuiCF["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function TukuiDB.Scale(x) return scale(x) end
TukuiDB.mult = mult

function TukuiDB.CreatePanel(f, w, h, a1, p, a2, x, y)
	sh = scale(h)
	sw = scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)
	f:SetBackdrop({
	  bgFile = TukuiCF["media"].blank, 
	  edgeFile = TukuiCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end

function TukuiDB.SetTemplate(f)
	f:SetBackdrop({
	  bgFile = TukuiCF["media"].blank, 
	  edgeFile = TukuiCF["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
end

function TukuiDB.CreateShadow(f)
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))
	shadow:SetPoint("BOTTOMLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(-4))
	shadow:SetPoint("TOPRIGHT", TukuiDB.Scale(4), TukuiDB.Scale(4))
	shadow:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(4), TukuiDB.Scale(-4))
	shadow:SetBackdrop( { 
		edgeFile = TukuiCF["media"].glowTex, edgeSize = TukuiDB.Scale(3),
		insets = {left = TukuiDB.Scale(5), right = TukuiDB.Scale(5), top = TukuiDB.Scale(5), bottom = TukuiDB.Scale(5)},
	})
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, 0.5)
	f.shadow = shadow
end

function TukuiDB.Kill(object)
	object.Show = TukuiDB.dummy
	object:Hide()
end

-- datatext panel position
function TukuiDB.PP(p, obj)
	local left = TukuiInfoLeft
	local right = TukuiInfoRight
	local mapleft = TukuiMinimapStatsLeft
	local mapright = TukuiMinimapStatsRight
	
	if p == 1 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("LEFT", left, 30, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 2 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 3 then
		obj:SetHeight(left:GetHeight())
		obj:SetPoint("RIGHT", left, -30, 0)
		obj:SetPoint('TOP', left)
		obj:SetPoint('BOTTOM', left)
	elseif p == 4 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("LEFT", right, 30, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	elseif p == 5 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	elseif p == 6 then
		obj:SetHeight(right:GetHeight())
		obj:SetPoint("RIGHT", right, -30, 0)
		obj:SetPoint('TOP', right)
		obj:SetPoint('BOTTOM', right)
	end
	
	if TukuiMinimap then
		if p == 7 then
			obj:SetHeight(mapleft:GetHeight())
			obj:SetPoint('TOP', mapleft)
			obj:SetPoint('BOTTOM', mapleft)
		elseif p == 8 then
			obj:SetHeight(mapright:GetHeight())
			obj:SetPoint('TOP', mapright)
			obj:SetPoint('BOTTOM', mapright)
		end
	end
end

function TukuiDB.TukuiPetBarUpdate(self, event)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end			
		end
		
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end
		
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		
		-- grid display
		if name then
			if not TukuiCF["actionbar"].showgrid then
				petActionButton:SetAlpha(1)
			end			
		else
			if not TukuiCF["actionbar"].showgrid then
				petActionButton:SetAlpha(0)
			end
		end
		
		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end
		
		-- between level 1 and 10 on cata, we don't have any control on Pet. (I lol'ed so hard)
		-- Setting desaturation on button to true until you learn the control on class trainer.
		-- you can at least control "follow" button.
		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(0)
		end
	end
end

-- styleButton function authors are Chiril & Karudon.
function TukuiDB.StyleButton(b, checked) 
    local name = b:GetName()
 
    local button          = _G[name]
    local icon            = _G[name.."Icon"]
    local count           = _G[name.."Count"]
    local border          = _G[name.."Border"]
    local hotkey          = _G[name.."HotKey"]
    local cooldown        = _G[name.."Cooldown"]
    local nametext        = _G[name.."Name"]
    local flash           = _G[name.."Flash"]
    local normaltexture   = _G[name.."NormalTexture"]
	local icontexture     = _G[name.."IconTexture"]

	local hover = b:CreateTexture("frame", nil, self) -- hover
	hover:SetTexture(1,1,1,0.3)
	hover:SetHeight(button:GetHeight())
	hover:SetWidth(button:GetWidth())
	hover:SetPoint("TOPLEFT",button,2,-2)
	hover:SetPoint("BOTTOMRIGHT",button,-2,2)
	button:SetHighlightTexture(hover)

	local pushed = b:CreateTexture("frame", nil, self) -- pushed
	pushed:SetTexture(0.9,0.8,0.1,0.3)
	pushed:SetHeight(button:GetHeight())
	pushed:SetWidth(button:GetWidth())
	pushed:SetPoint("TOPLEFT",button,2,-2)
	pushed:SetPoint("BOTTOMRIGHT",button,-2,2)
	button:SetPushedTexture(pushed)
 
	if checked then
		local checked = b:CreateTexture("frame", nil, self) -- checked
		checked:SetTexture(0,1,0,0.3)
		checked:SetHeight(button:GetHeight())
		checked:SetWidth(button:GetWidth())
		checked:SetPoint("TOPLEFT",button,2,-2)
		checked:SetPoint("BOTTOMRIGHT",button,-2,2)
		button:SetCheckedTexture(checked)
	end
end

------------------------------------------------------------------------
--	unitframes Functions
------------------------------------------------------------------------

do
	if TukuiCF["unitframes"].enable ~= true then return end
	
	local SetUpAnimGroup = function(self)
		self.anim = self:CreateAnimationGroup("Flash")
		self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
		self.anim.fadein:SetChange(1)
		self.anim.fadein:SetOrder(2)

		self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
		self.anim.fadeout:SetChange(-1)
		self.anim.fadeout:SetOrder(1)
	end

	local Flash = function(self, duration)
		if not self.anim then
			SetUpAnimGroup(self)
		end

		self.anim.fadein:SetDuration(duration)
		self.anim.fadeout:SetDuration(duration)
		self.anim:Play()
	end

	local StopFlash = function(self)
		if self.anim then
			self.anim:Finish()
		end
	end

	function TukuiDB.SpawnMenu(self)
		local unit = self.unit:gsub("(.)", string.upper, 1)
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

	function TukuiDB.PostUpdatePower(element, unit, min, max)
		element:GetParent().Health:SetHeight(max ~= 0 and 20 or 22)
	end

	TukuiDB.SetFontString = function(parent, fontName, fontHeight, fontStyle)
		local fs = parent:CreateFontString(nil, "OVERLAY")
		fs:SetFont(fontName, fontHeight, fontStyle)
		fs:SetJustifyH("LEFT")
		fs:SetShadowColor(0, 0, 0)
		fs:SetShadowOffset(1.25, -1.25)
		return fs
	end

	local ShortValue = function(value)
		if value >= 1e6 then
			return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e3 or value <= -1e3 then
			return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
		else
			return value
		end
	end

	local ShortValueNegative = function(v)
		if v <= 999 then return v end
		if v >= 1000000 then
			local value = string.format("%.1fm", v/1000000)
			return value
		elseif v >= 1000 then
			local value = string.format("%.1fk", v/1000)
			return value
		end
	end

	TukuiDB.PostUpdateHealth = function(health, unit, min, max)
		if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
			if not UnitIsConnected(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_offline.."|r")
			elseif UnitIsDead(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_dead.."|r")
			elseif UnitIsGhost(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_ghost.."|r")
			end
		else
			local r, g, b
			
			-- overwrite healthbar color for enemy player (a tukui option if enabled), target vehicle/pet too far away returning unitreaction nil and friend unit not a player. (mostly for overwrite tapped for friendly)
			-- I don't know if we really need to call TukuiCF["unitframes"].unicolor but anyway, it's safe this way.
			if (TukuiCF["unitframes"].unicolor ~= true and TukuiCF["unitframes"].enemyhcolor and unit == "target" and UnitIsEnemy(unit, "player")) or (TukuiCF["unitframes"].unicolor ~= true and unit == "target" and not UnitIsPlayer(unit) and UnitIsFriend(unit, "player")) then
				local c = TukuiDB.oUF_colors.reaction[UnitReaction(unit, "player")]
				if c then 
					r, g, b = c[1], c[2], c[3]
					health:SetStatusBarColor(r, g, b)
				else
					-- if "c" return nil it's because it's a vehicle or pet unit too far away, we force friendly color
					-- this should fix color not updating for vehicle/pet too far away from yourself.
					r, g, b = 75/255,  175/255, 76/255
					health:SetStatusBarColor(r, g, b)
				end					
			end

			if min ~= max then
				local r, g, b
				r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
				if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
					if TukuiCF["unitframes"].showtotalhpmp == true then
						health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
					else
						health.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
					end
				elseif unit == "target" or unit == "focus" or (unit and unit:find("boss%d")) then
					if TukuiCF["unitframes"].showtotalhpmp == true then
						health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
					else
						health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
					end
				elseif (unit and unit:find("arena%d")) then
					health.value:SetText("|cff559655"..ShortValue(min).."|r")
				else
					health.value:SetText("|cff559655-"..ShortValueNegative(max-min).."|r")
				end
			else
				if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
					health.value:SetText("|cff559655"..max.."|r")
				elseif unit == "target" or unit == "focus" or (unit and unit:find("arena%d")) then
					health.value:SetText("|cff559655"..ShortValue(max).."|r")
				else
					health.value:SetText(" ")
				end
			end
		end
	end

	TukuiDB.PostUpdateHealthRaid = function(health, unit, min, max)
		if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
			if not UnitIsConnected(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_offline.."|r")
			elseif UnitIsDead(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_dead.."|r")
			elseif UnitIsGhost(unit) then
				health.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_ghost.."|r")
			end
		else
			local r, g, b
			
			-- doing this here to force friendly unit (vehicle or pet) very far away from you to update color correcly
			-- because if vehicle or pet is too far away, unitreaction return nil and color of health bar is white.
			if not UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and TukuiCF["unitframes"].unicolor ~= true then
				r, g, b = 75/255,  175/255, 76/255
				health:SetStatusBarColor(r, g, b)
				health.bg:SetTexture(.1, .1, .1)
			end
			
			if min ~= max then
				health.value:SetText("|cff559655-"..ShortValueNegative(max-min).."|r")
			else
				health.value:SetText(" ")
			end
		end
	end
	
	TukuiDB.PostUpdatePetColor = function(health, unit, min, max)
		-- doing this here to force friendly unit (vehicle or pet) very far away from you to update color correcly
		-- because if vehicle or pet is too far away, unitreaction return nil and color of health bar is white.
		if not UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and TukuiCF["unitframes"].unicolor ~= true then
			r, g, b = 75/255,  175/255, 76/255
			health:SetStatusBarColor(r, g, b)
			health.bg:SetTexture(.1, .1, .1)
		end
	end

	TukuiDB.PostNamePosition = function(self)
		self.Name:ClearAllPoints()
		if (self.Power.value:GetText() and UnitIsEnemy("player", "target") and TukuiCF["unitframes"].targetpowerpvponly == true) or (self.Power.value:GetText() and TukuiCF["unitframes"].targetpowerpvponly == false) then
			self.Name:SetPoint("CENTER", self.panel, "CENTER", 0, 0)
		else
			self.Power.value:SetAlpha(0)
			self.Name:SetPoint("LEFT", self.panel, "LEFT", 4, 0)
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
		local pType, pToken = UnitPowerType(unit)
		local color = TukuiDB.oUF_colors.power[pToken]

		if color then
			power.value:SetTextColor(color[1], color[2], color[3])
		end

		if not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
			power.value:SetText()
		elseif UnitIsDead(unit) or UnitIsGhost(unit) then
			power.value:SetText()
		else
			if min ~= max then
				if pType == 0 then
					if unit == "target" then
						if TukuiCF["unitframes"].showtotalhpmp == true then
							power.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
						else
							power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
						end
					elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
						if TukuiCF["unitframes"].showtotalhpmp == true then
							power.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
						else
							power.value:SetFormattedText("%d%%", floor(min / max * 100))
						end
					elseif (unit and unit:find("arena%d")) then
						power.value:SetText(ShortValue(min))
					else
						if TukuiCF["unitframes"].showtotalhpmp == true then
							power.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
						else
							power.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
						end
					end
				else
					power.value:SetText(max - (max - min))
				end
			else
				if unit == "pet" or unit == "target" or (unit and unit:find("arena%d")) then
					power.value:SetText(ShortValue(min))
				else
					power.value:SetText(min)
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

	local function HideBuffFrame()
		if TukuiCF["unitframes"].playerauras ~= true then return end
		-- hide buff
		BuffFrame:UnregisterEvent("UNIT_AURA")
		BuffFrame:Hide()
		TemporaryEnchantFrame:Hide()
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
	end
	HideBuffFrame()

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

	local CancelAura = function(self, button)
		if button == "RightButton" and not self.debuff then
			-- CancelUnitBuff("player", self:GetID()) -- protected in cata?
		end
	end

	function TukuiDB.PostCreateAura(element, button)
		TukuiDB.SetTemplate(button)
		
		button.remaining = TukuiDB.SetFontString(button, TukuiCF["media"].font, TukuiCF["unitframes"].auratextscale, "THINOUTLINE")
		button.remaining:SetPoint("CENTER", TukuiDB.Scale(1), 0)
		
		button.cd.noOCC = true		 	-- hide OmniCC CDs
		button.cd.noCooldownCount = true	-- hide CDC CDs
		
		button.cd:SetReverse()
		button.icon:SetPoint("TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		button.icon:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
		
		button.count:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(1.5))
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(TukuiCF["media"].font, 9, "THICKOUTLINE")
		button.count:SetTextColor(0.84, 0.75, 0.65)
		
		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.remaining:SetParent(button.overlayFrame)
				
		button.Glow = CreateFrame("Frame", nil, button)
		button.Glow:SetPoint("TOPLEFT", button, "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(3))
		button.Glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-3))
		button.Glow:SetFrameStrata("BACKGROUND")	
		button.Glow:SetBackdrop{edgeFile = TukuiCF["media"].glowTex, edgeSize = 3, insets = {left = 0, right = 0, top = 0, bottom = 0}}
		button.Glow:SetBackdropColor(0, 0, 0, 0)
		button.Glow:SetBackdropBorderColor(0, 0, 0)
	end

	function TukuiDB.PostUpdateAura(icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
		local _, _, _, _, dtype, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)

		if(icon.debuff) then
			if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") then
				icon:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
				icon.icon:SetDesaturated(true)
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
				icon.icon:SetDesaturated(false)
			end
		end
		
		if duration and duration > 0 then
			if TukuiCF["unitframes"].auratimer == true then
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

	TukuiDB.HidePortrait = function(self, unit)
		if self.unit == "target" then
			if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
				self.Portrait:SetAlpha(0)
			else
				self.Portrait:SetAlpha(1)
			end
		end
	end

	local CheckInterrupt = function(self, unit)
		if unit == "vehicle" then unit = "player" end

		if self.interrupt and UnitCanAttack("player", unit) then
			self:SetStatusBarColor(1, 0, 0, 0.5)	
		else
			self:SetStatusBarColor(0.31, 0.45, 0.63, 0.5)		
		end
	end

	TukuiDB.CheckCast = function(self, unit, name, rank, castid)
		CheckInterrupt(self, unit)
	end

	TukuiDB.CheckChannel = function(self, unit, name, rank)
		CheckInterrupt(self, unit)
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
	
	TukuiDB.Phasing = function(self, event)
		local inPhase = UnitInPhase(self.unit)
		local picon = self.PhaseIcon

		if(inPhase) then
			picon:Hide()
			if self.Health.value then self.Health.value:SetAlpha(1) end
		else
			picon:Show()
			if self.Health.value then self.Health.value:SetAlpha(0) end
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
	
	TukuiDB.EclipseDisplay = function(self, login)
		local eb = self.EclipseBar

		if login then
			eb:SetScript("OnUpdate", nil)
		end
		
		if eb:IsShown() then
			self.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(13))
			if TukuiDB.lowversion then
				if self.Buffs then self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 34) end
			else
				if self.Buffs then self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 38) end
			end				
		else
			self.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))
			if TukuiDB.lowversion then
				if self.Buffs then self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26) end
			else
				if self.Buffs then self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 30) end
			end
		end
	end

	TukuiDB.MLAnchorUpdate = function (self)
		if self.Leader:IsShown() then
			self.MasterLooter:SetPoint("TOPLEFT", 14, 8)
		else
			self.MasterLooter:SetPoint("TOPLEFT", 2, 8)
		end
	end

	TukuiDB.UpdateCPoints = function(self, event, unit)
		if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
			self.CPoints.unit = unit
		end
	end

	TukuiDB.UpdateReputationColor = function(self, event, unit, bar)
		local name, id = GetWatchedFactionInfo()
		bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
	end

	TukuiDB.UpdatePetInfo = function(self,event)
		if self.Name then self.Name:UpdateTag(self.unit) end
	end

	local delay = 0
	
	TukuiDB.UpdateManaLevel = function(self, elapsed)
		delay = delay + elapsed
		if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
		delay = 0

		local percMana = UnitMana("player") / UnitManaMax("player") * 100

		if percMana <= TukuiCF.unitframes.lowThreshold then
			self.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_lowmana.."|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
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
				Flash(self.FlashInfo, 0.3)
			else
				self.FlashInfo.ManaLevel:SetText()
				StopFlash(self.FlashInfo)
			end

			if min ~= max then
				if self.Power.value:GetText() then
					self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", 1, 0)
					self.DruidMana:SetFormattedText("|cffD7BEA5-|r  %d%%|r", floor(min / max * 100))
				else
					self.DruidMana:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
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
		if (self.unit ~= unit) or (unit == "target" or unit == "pet" or unit == "focus" or unit == "focustarget" or unit == "targettarget") then return end
		local threat = UnitThreatSituation(self.unit)
		if (threat == 3) then
			if self.panel then
				self.panel:SetBackdropBorderColor(.69,.31,.31,1)
			else
				self.Name:SetTextColor(1,0.1,0.1)
			end
		else
			if self.panel then
				self.panel:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
			else
				self.Name:SetTextColor(1,1,1)
			end
		end 
	end

	--------------------------------------------------------------------------------------------
	-- THE AURAWATCH FUNCTION ITSELF. HERE BE DRAGONS!
	--------------------------------------------------------------------------------------------

	TukuiDB.countOffsets = {
		TOPLEFT = {6*TukuiCF["unitframes"].gridscale, 1},
		TOPRIGHT = {-6*TukuiCF["unitframes"].gridscale, 1},
		BOTTOMLEFT = {6*TukuiCF["unitframes"].gridscale, 1},
		BOTTOMRIGHT = {-6*TukuiCF["unitframes"].gridscale, 1},
		LEFT = {6*TukuiCF["unitframes"].gridscale, 1},
		RIGHT = {-6*TukuiCF["unitframes"].gridscale, 1},
		TOP = {0, 0},
		BOTTOM = {0, 0},
	}

	function TukuiDB.CreateAuraWatchIcon(self, icon)
		TukuiDB.SetTemplate(icon)
		icon.icon:SetPoint("TOPLEFT", TukuiDB.Scale(1), TukuiDB.Scale(-1))
		icon.icon:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(-1), TukuiDB.Scale(1))
		icon.icon:SetTexCoord(.08, .92, .08, .92)
		icon.icon:SetDrawLayer("ARTWORK")
		if (icon.cd) then
			icon.cd:SetReverse()
		end
		icon.overlay:SetTexture()
	end

	function TukuiDB.createAuraWatch(self, unit)
		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("TOPLEFT", self.Health, 2, -2)
		auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
		auras.presentAlpha = 1
		auras.missingAlpha = 0
		auras.icons = {}
		auras.PostCreateIcon = TukuiDB.CreateAuraWatchIcon

		if (not TukuiCF["unitframes"].auratimer) then
			auras.hideCooldown = true
		end

		local buffs = {}

		if (TukuiDB.buffids["ALL"]) then
			for key, value in pairs(TukuiDB.buffids["ALL"]) do
				tinsert(buffs, value)
			end
		end

		if (TukuiDB.buffids[TukuiDB.myclass]) then
			for key, value in pairs(TukuiDB.buffids[TukuiDB.myclass]) do
				tinsert(buffs, value)
			end
		end

		-- "Cornerbuffs"
		if (buffs) then
			for key, spell in pairs(buffs) do
				local icon = CreateFrame("Frame", nil, auras)
				icon.spellID = spell[1]
				icon.anyUnit = spell[4]
				icon:SetWidth(TukuiDB.Scale(6*TukuiCF["unitframes"].gridscale))
				icon:SetHeight(TukuiDB.Scale(6*TukuiCF["unitframes"].gridscale))
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
				count:SetFont(TukuiCF["media"].uffont, 8*TukuiCF["unitframes"].gridscale, "THINOUTLINE")
				count:SetPoint("CENTER", unpack(TukuiDB.countOffsets[spell[2]]))
				icon.count = count

				auras.icons[spell[1]] = icon
			end
		end
		
		self.AuraWatch = auras
	end
end