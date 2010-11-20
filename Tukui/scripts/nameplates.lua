--Base code by Dawn (dNameplates)
if not TukuiCF["nameplate"].enable == true then return end

local TEXTURE = TukuiCF["media"].normTex
local FONT = TukuiCF["media"].font
local FONTSIZE = 11
local FONTFLAG = "THINOUTLINE"
local hpHeight = 12
local hpWidth = 110
local iconSize = 25		--Size of all Icons, RaidIcon/ClassIcon/Castbar Icon
local cbHeight = 5
local cbWidth = 110
local blankTex = TukuiCF["media"].blank
local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]
local numChildren = -1
local frames = {}
local noscalemult = TukuiDB.mult * TukuiCF["general"].uiscale

--Change defaults if we are showing health text or not
if TukuiCF["nameplate"].showhealth ~= true then
	hpHeight = 7
	iconSize = 20
end

local NamePlates = CreateFrame("Frame", nil, UIParent)
NamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
SetCVar("bloatthreat", 0) -- stop resizing nameplate according to threat level.
SetCVar("bloattest", 0)
if TukuiCF["nameplate"].overlap == true then
	SetCVar("spreadnameplates", "0")
else
	SetCVar("spreadnameplates", "1")
end

local function QueueObject(parent, object)
	parent.queue = parent.queue or {}
	parent.queue[object] = true
end

local function HideObjects(parent)
	for object in pairs(parent.queue) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
			object.SetTexture = TukuiDB.dummy
		else
			object:Hide()
			object.Show = TukuiDB.dummy
		end
	end
end

local goodR, goodG, goodB = unpack(TukuiCF["nameplate"].goodcolor)
local badR, badG, badB = unpack(TukuiCF["nameplate"].badcolor)
local transitionR, transitionG, transitionB = unpack(TukuiCF["nameplate"].transitioncolor)
local function UpdateThreat(frame, elapsed)	
	frame.elapsed = frame.elapsed + elapsed
	if frame.elapsed >= 0.2 then
		if TukuiCF["nameplate"].enhancethreat ~= true then
			if(frame.region:IsShown()) then
				local _, val = frame.region:GetVertexColor()
				if(val > 0.7) then
					frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 1, 0)
				else
					frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 0, 0)
				end
			else
				frame.healthbackdrop.shadow:SetBackdropBorderColor(0, 0, 0)
			end
		else
			if not frame.region:IsShown() then
				if InCombatLockdown() and frame.hasclass ~= true then
					--No Threat
					if TukuiDB.Role == "Tank" then
						frame.hp:SetStatusBarColor(badR, badG, badB)
						frame.hp.hpbg:SetVertexColor(badR, badG, badB, 0.4)
					else
						frame.hp:SetStatusBarColor(goodR, goodG, goodB)
						frame.hp.hpbg:SetVertexColor(goodR, goodG, goodB, 0.35)
					end		
				else
					--Set colors to their original, not in combat
					frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
					frame.hp.hpbg:SetVertexColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
				end
			else
				--Ok we either have threat or we're losing/gaining it
				local r, g, b = frame.region:GetVertexColor()
				if g + b == 0 then
					--Have Threat
					if TukuiDB.Role == "Tank" then
						frame.hp:SetStatusBarColor(goodR, goodG, goodB)
						frame.hp.hpbg:SetVertexColor(goodR, goodG, goodB, 0.35)
					else
						frame.hp:SetStatusBarColor(badR, badG, badB)
						frame.hp.hpbg:SetVertexColor(badR, badG, badB, 0.4)
					end
				else
					--Losing/Gaining Threat
					frame.hp:SetStatusBarColor(transitionR, transitionG, transitionB)
					frame.hp.hpbg:SetVertexColor(transitionR, transitionG, transitionB, 0.35)					
				end
			end
		end
		
		-- show current health value
		local minHealth, maxHealth = frame.healthOriginal:GetMinMaxValues()
		local valueHealth = frame.healthOriginal:GetValue()
		local d =(valueHealth/maxHealth)*100
		
		if TukuiCF["nameplate"].showhealth == true then
			frame.hp.value:SetText(TukuiDB.ShortValue(valueHealth).." - "..(string.format("%d%%", math.floor((valueHealth/maxHealth)*100))))
		end
			
		--Change frame style if the frame is our target or not
		if UnitName("target") == frame.name:GetText() and frame:GetAlpha() == 1 then
			--Targetted Unit
			frame.name:SetTextColor(1, 1, 0)
			
			if TukuiCF["nameplate"].enhancethreat == true then
				frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 1, 1)
			else
				frame.healthbackdrop:SetBackdropBorderColor(1, 1, 1)
			end
			if frame.overlay:IsShown() then frame.overlay:Hide() end
		else
			--Not Targetted
			frame.name:SetTextColor(1, 1, 1)
			
			if TukuiCF["nameplate"].enhancethreat ~= true then
				frame.healthbackdrop:SetBackdropBorderColor(0.6, 0.6, 0.6)
			else
				if frame.hasclass ~= true then
					frame.healthbackdrop.shadow:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
		
		--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
		if frame.hasclass == true then
			if(d <= 50 and d >= 26) then
				frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 1, 0)
			elseif(d < 26) then
				frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 0, 0)
			else
				if UnitName("target") == frame.name:GetText() and frame:GetAlpha() == 1 then
					frame.healthbackdrop.shadow:SetBackdropBorderColor(1, 1, 1)	
				else
					frame.healthbackdrop.shadow:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
		frame.elapsed = 0
	end
end

local function UpdateObjects(frame)
	frame = frame:GetParent()
	
	local r, g, b = frame.hp:GetStatusBarColor()
	local r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local classname = ""
	
	frame.hp:ClearAllPoints()
	frame.hp:SetSize(hpWidth, hpHeight)	
	frame.hp:SetPoint('CENTER', frame, 0, -10)
	frame.hp:GetStatusBarTexture():SetHorizTile(true)
	
	--Class Icons
	for class, color in pairs(RAID_CLASS_COLORS) do
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
			classname = class
		end
	end
	if (classname) then
		texcoord = CLASS_BUTTONS[classname]
		if texcoord then
			frame.hasclass = true
		else
			texcoord = {0.5, 0.75, 0.5, 0.75}
			frame.hasclass = false
		end
	else
		texcoord = {0.5, 0.75, 0.5, 0.75}
		frame.hasclass = false
	end
	frame.class:SetTexCoord(texcoord[1],texcoord[2],texcoord[3],texcoord[4]);
	
	--Set the name text
	frame.name:SetText(frame.oldname:GetText())
	
	--Position the highlight texture
	frame.overlay:ClearAllPoints()
	frame.overlay:SetAllPoints(frame.hp)
	frame.overlay:SetTexture(1,1,1,0.25)
	
	-- color hp bg dependend on hp color
    local BGr, BGg, BGb = frame.hp:GetStatusBarColor()
	frame.hp.hpbg:SetVertexColor(BGr*0.36, BGg*0.36, BGb*0.36, 0.35)
	
	--create variable for original colors
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = frame.hp:GetStatusBarColor()
	
	--Setup level text
	local level, elite, mylevel = tonumber(frame.level:GetText()), frame.elite:IsShown(), UnitLevel("player")
	frame.level:ClearAllPoints()
	if TukuiCF["nameplate"].showhealth == true then
		frame.level:SetPoint("RIGHT", frame.hp, "RIGHT", 2, 0)
	else
		frame.level:SetPoint("RIGHT", frame.hp, "LEFT", -1, 0)
	end
	if frame.boss:IsShown() then
		frame.level:SetText("B")
		frame.level:SetTextColor(0.8, 0.05, 0)
		frame.level:Show()
	elseif not elite and level == mylevel then
		frame.level:Hide()
	else
		frame.level:SetText(level..(elite and "+" or ""))
	end
	
	HideObjects(frame)
end

local function UpdateCastbar(frame)
	frame:ClearAllPoints()
	frame:SetSize(cbWidth, cbHeight)
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -8)
	frame:GetStatusBarTexture():SetHorizTile(true)

	if(not frame.shield:IsShown()) then
		frame:SetStatusBarColor(1, 0.3, 0.3)
	end
end	

local function UpdateCastText(frame, curValue)
	local minValue, maxValue = frame:GetMinMaxValues()
	
	if UnitChannelInfo("target") then
		frame.time:SetFormattedText("%.1f ", curValue)
		frame.name:SetText(select(1, (UnitChannelInfo("target"))))
	end
	
	if UnitCastingInfo("target") then
		frame.time:SetFormattedText("%.1f ", maxValue - curValue)
		frame.name:SetText(select(1, (UnitCastingInfo("target"))))
	end
end

local OnValueChanged = function(self, curValue)
	UpdateCastText(self, curValue)
	if self.needFix then
		UpdateCastbar(self)
		self.needFix = nil
	end
end

local OnSizeChanged = function(self)
	self.needFix = true
end

local function SkinObjects(frame)
	local hp, cb = frame:GetChildren()
	local threat, hpborder, cbshield, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon, elite = frame:GetRegions()
	frame.healthOriginal = hp
	
	--Create Health Backdrop Frame
	local healthbackdrop = CreateFrame("Frame", nil, hp)
	healthbackdrop:SetBackdrop({
		bgFile = TukuiCF["media"].blank,
		edgeFile = TukuiCF["media"].blank,
		tile = false, tileSize = 0, edgeSize = noscalemult,
		insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	})
	healthbackdrop:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
	healthbackdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
	healthbackdrop:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*2, noscalemult*2)
	healthbackdrop:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	if (hp:GetFrameLevel() - 1) > 0 then
		healthbackdrop:SetFrameLevel(hp:GetFrameLevel() - 1)
	else
		hp:SetFrameLevel(9)
		healthbackdrop:SetFrameLevel(hp:GetFrameLevel() - 1)
	end
	healthbackdrop:SetFrameStrata(hp:GetFrameStrata())
	frame.healthbackdrop = healthbackdrop
	
	hp:HookScript('OnShow', UpdateObjects)
	hp:SetStatusBarTexture(TEXTURE)
	frame.hp = hp
	
	--Create Shadow for Healthbar
	TukuiDB.CreateShadow(frame.healthbackdrop)
	
	--Actual Background for the Healthbar
	hp.hpbg = hp:CreateTexture(nil, 'BORDER')
	hp.hpbg:SetAllPoints(hp)
	hp.hpbg:SetTexture(1,1,1,0.4)	
	
	--Need to Reposition the overlay with the health
	frame.overlay = overlay
	
	--Needed for level text
	frame.level = level
	frame.boss = bossicon
	frame.elite = elite
	frame.level:SetFont(FONT, FONTSIZE, FONTFLAG)
	frame.level:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	
	--Create Health Text
	if TukuiCF["nameplate"].showhealth == true then
		hp.value = hp:CreateFontString(nil, "OVERLAY")	
		hp.value:SetFont(FONT, FONTSIZE, FONTFLAG)
		hp.value:SetPoint("CENTER", hp)
		hp.value:SetTextColor(1,1,1)
		hp.value:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	end
	
	-- Create Castbar Backdrop frame
	local castbackdrop = CreateFrame("Frame", nil, cb)
	castbackdrop:SetBackdrop({
		bgFile = TukuiCF["media"].blank,
		edgeFile = TukuiCF["media"].blank,
		tile = false, tileSize = 0, edgeSize = noscalemult,
		insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	})
	castbackdrop:SetBackdropBorderColor(0.6,0.6,0.6,1)
	castbackdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
	castbackdrop:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*2, noscalemult*2)
	castbackdrop:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	castbackdrop:SetFrameStrata(cb:GetFrameStrata())
	if (cb:GetFrameLevel() - 1) > 0 then
		castbackdrop:SetFrameLevel(cb:GetFrameLevel() - 1)
	else
		cb:SetFrameLevel(9)
		castbackdrop:SetFrameLevel(cb:GetFrameLevel() - 1)
	end
	frame.castbackdrop = castbackdrop

	--Create Shadow for Healthbar
	TukuiDB.CreateShadow(frame.castbackdrop)
	
	--Setup CastBar Icon
	cbicon:ClearAllPoints()
	cbicon:SetPoint("TOPLEFT", hp, "TOPRIGHT", 8, 0)		
	cbicon:SetSize(iconSize, iconSize)
	cbicon:SetTexCoord(.07, .93, .07, .93)

	-- Create Cast Icon Backdrop frame
	local casticonbackdrop = CreateFrame("Frame", nil, cb)
	casticonbackdrop:SetBackdrop({
		bgFile = TukuiCF["media"].blank,
		edgeFile = TukuiCF["media"].blank,
		tile = false, tileSize = 0, edgeSize = noscalemult,
		insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	})
	casticonbackdrop:SetBackdropBorderColor(0.6,0.6,0.6,1)
	casticonbackdrop:SetBackdropColor(0.1, 0.1, 0.1, 1)
	casticonbackdrop:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult*2, noscalemult*2)
	casticonbackdrop:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	casticonbackdrop:SetFrameLevel(hp:GetFrameLevel() - 1)
	casticonbackdrop:SetFrameStrata(hp:GetFrameStrata())
	frame.casticonbackdrop = casticonbackdrop
	
	--Create Shadow for Cast Icon
	TukuiDB.CreateShadow(frame.casticonbackdrop)
	
	--Create Cast Time Text
	cb.time = cb:CreateFontString(nil, "ARTWORK")
	cb.time:SetPoint("RIGHT", cb, "LEFT", -1, 0)
	cb.time:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.time:SetTextColor(1, 1, 1)
	cb.time:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)

	--Create Cast Name Text
	cb.name = cb:CreateFontString(nil, "ARTWORK")
	cb.name:SetPoint("TOP", cb, "BOTTOM", 0, -3)
	cb.name:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.name:SetTextColor(1, 1, 1)
	cb.name:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	
	cb.icon = cbicon
	cb.shield = cbshield
	cb:HookScript('OnShow', UpdateCastbar)
	cb:HookScript('OnSizeChanged', OnSizeChanged)
	cb:HookScript('OnValueChanged', OnValueChanged)	
	cb:SetStatusBarTexture(TEXTURE)
	frame.cb = cb

	--Create Name Text
	local name = hp:CreateFontString(nil, 'OVERLAY')
	name:SetPoint('BOTTOMLEFT', hp, 'TOPLEFT', -10, 3)
	name:SetPoint('BOTTOMRIGHT', hp, 'TOPRIGHT', 10, 3)
	name:SetFont(FONT, FONTSIZE, FONTFLAG)
	name:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	frame.oldname = oldname
	frame.name = name
	
	--Reposition and Resize RaidIcon
	raidicon:ClearAllPoints()
	raidicon:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	raidicon:SetSize(iconSize*1.4, iconSize*1.4)
	raidicon:SetTexture(TukuiCF["media"].raidicons)	
	frame.raidicon = raidicon
	
	--Create Class Icon
	local cIconTex = hp:CreateTexture(nil, "OVERLAY")
	cIconTex:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	cIconTex:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	cIconTex:SetSize(iconSize, iconSize)
	frame.class = cIconTex
	
	--Set update variable
	frame.elapsed = 0
	
	--Hide Old Stuff
	QueueObject(frame, threat)
	QueueObject(frame, hpborder)
	QueueObject(frame, cbshield)
	QueueObject(frame, cbborder)
	QueueObject(frame, oldname)
	QueueObject(frame, bossicon)
	QueueObject(frame, elite)
	
	UpdateObjects(hp)
	UpdateCastbar(cb)
		
	frames[frame] = true
end

local select = select
local function HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()

		if(not frames[frame] and not frame:GetName() and region and region:GetObjectType() == 'Texture' and region:GetTexture() == OVERLAY) then
			SkinObjects(frame)
			frame.region = region
		end
	end
end


CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		HookFrames(WorldFrame:GetChildren())
	end

	if(self.elapsed and self.elapsed > 0.1) then
		for frame in pairs(frames) do
			UpdateThreat(frame, self.elapsed)
		end
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)

if TukuiCF["nameplate"].combat == true then
	NamePlates:RegisterEvent("PLAYER_REGEN_ENABLED")
	NamePlates:RegisterEvent("PLAYER_REGEN_DISABLED")
	NamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
	function NamePlates:PLAYER_REGEN_ENABLED()
		SetCVar("nameplateShowEnemies", 0)
	end
	
	function NamePlates:PLAYER_REGEN_DISABLED()
		SetCVar("nameplateShowEnemies", 1)
	end
	
	function NamePlates:PLAYER_ENTERING_WORLD()
		SetCVar("threatWarning", 3) --WE NEED THIS
		if InCombatLockdown() then
			SetCVar("nameplateShowEnemies", 1)
		else
			SetCVar("nameplateShowEnemies", 0)
		end
	end
else
	NamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
	function NamePlates:PLAYER_ENTERING_WORLD()
		SetCVar("threatWarning", 3) --WE NEED THIS
	end
end