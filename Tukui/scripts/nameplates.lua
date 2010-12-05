--Base code by Dawn (dNameplates)
if not TukuiCF["nameplate"].enable == true then return end

local TEXTURE = TukuiCF["media"].normTex
local FONT = TukuiCF["media"].font
local FONTSIZE = TukuiCF["general"].fontscale*0.9
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

local function CheckBlacklist(frame, ...)
	if PlateBlacklist[frame.name:GetText()] then
		frame:SetScript("OnUpdate", function() end)
		frame.hp:Hide()
		frame.cb:Hide()
		frame.overlay:Hide()
		frame.oldlevel:Hide()
	end
end

local function ForEachPlate(functionToRun, ...)
	for frame in pairs(frames) do
		if frame:IsShown() then
			functionToRun(frame, ...)
		end
	end
end

local goodR, goodG, goodB = unpack(TukuiCF["nameplate"].goodcolor)
local badR, badG, badB = unpack(TukuiCF["nameplate"].badcolor)
local transitionR, transitionG, transitionB = unpack(TukuiCF["nameplate"].transitioncolor)
local function UpdateThreat(frame, elapsed)
	frame.hp:Show()
	frame.overlay:Show()
	
	if TukuiCF["nameplate"].enhancethreat ~= true then
		if(frame.region:IsShown()) then
			local _, val = frame.region:GetVertexColor()
			if(val > 0.7) then
				frame.healthborder_tex:SetTexture(transitionR, transitionG, transitionB)
			else
				frame.healthborder_tex:SetTexture(badR, badG, badB)
			end
		else
			frame.healthborder_tex:SetTexture(0.6, 0.6, 0.6)
		end
	else
		if not frame.region:IsShown() then
			if InCombatLockdown() and frame.hasclass ~= true then
				--No Threat
				if TukuiDB.Role == "Tank" then
					frame.hp:SetStatusBarColor(badR, badG, badB)
					frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				else
					frame.hp:SetStatusBarColor(goodR, goodG, goodB)
					frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				end		
			else
				--Set colors to their original, not in combat
				frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
			end
		else
			--Ok we either have threat or we're losing/gaining it
			local r, g, b = frame.region:GetVertexColor()
			if g + b == 0 then
				--Have Threat
				if TukuiDB.Role == "Tank" then
					frame.hp:SetStatusBarColor(goodR, goodG, goodB)
					frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				else
					frame.hp:SetStatusBarColor(badR, badG, badB)
					frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				end
			else
				--Losing/Gaining Threat
				frame.hp:SetStatusBarColor(transitionR, transitionG, transitionB)	
				frame.hp.hpbg:SetTexture(transitionR, transitionG, transitionB, 0.25)
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
	else
		--Not Targetted
		frame.name:SetTextColor(1, 1, 1)
	end
	
	--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
	if frame.hasclass == true then
		if(d <= 50 and d >= 21) then
			frame.healthborder_tex:SetTexture(1, 1, 0)
		elseif(d < 21) then
			frame.healthborder_tex:SetTexture(1, 0, 0)
		else
			frame.healthborder_tex:SetTexture(0.6, 0.6, 0.6)
		end
	elseif frame.hasclass ~= true then
		frame.healthborder_tex:SetTexture(0.6, 0.6, 0.6)
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

	--create variable for original colors
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = frame.hp:GetStatusBarColor()
	frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
	
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
	
	if frame.hp.rcolor == 0 and frame.hp.gcolor == 0 and frame.hp.bcolor ~= 0 then
		texcoord = {0.5, 0.75, 0.5, 0.75}
		frame.hasclass = true
	end
	frame.class:SetTexCoord(texcoord[1],texcoord[2],texcoord[3],texcoord[4])
	
	--Set the name text
	frame.name:SetText(frame.oldname:GetText())
	
	--Setup level text
	local level, elite, mylevel = tonumber(frame.oldlevel:GetText()), frame.elite:IsShown(), UnitLevel("player")
	frame.hp.level:ClearAllPoints()
	if TukuiCF["nameplate"].showhealth == true then
		frame.hp.level:SetPoint("RIGHT", frame.hp, "RIGHT", 2, 0)
	else
		frame.hp.level:SetPoint("RIGHT", frame.hp, "LEFT", -1, 0)
	end
	
	frame.hp.level:SetTextColor(frame.oldlevel:GetTextColor())
	if frame.boss:IsShown() then
		frame.hp.level:SetText("B")
		frame.hp.level:SetTextColor(0.8, 0.05, 0)
		frame.hp.level:Show()
	elseif not elite and level == mylevel then
		frame.hp.level:Hide()
	else
		frame.hp.level:SetText(level..(elite and "+" or ""))
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
	local threat, hpborder, cbshield, cbborder, cbicon, oldoverlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	frame.healthOriginal = hp
	
	--Just make sure these are correct
	hp:SetFrameLevel(9)
	cb:SetFrameLevel(9)
	
	--Create Health Backdrop Frame
	local healthbackdrop = CreateFrame("Frame", nil, hp)
	healthbackdrop:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*3, noscalemult*3)
	healthbackdrop:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
	healthbackdrop:SetFrameLevel(1)
	healthbackdrop_tex = healthbackdrop:CreateTexture(nil, "BACKGROUND")
	healthbackdrop_tex:SetAllPoints(healthbackdrop)
	healthbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	frame.healthbackdrop = healthbackdrop_tex
	
	local healthborder = CreateFrame("Frame", nil, hp)
	healthborder:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*2, noscalemult*2)
	healthborder:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	healthborder:SetFrameLevel(hp:GetFrameLevel() - 2)
	healthborder_tex = healthborder:CreateTexture(nil, "BACKGROUND")
	healthborder_tex:SetAllPoints(healthborder)
	healthborder_tex:SetTexture(0.6, 0.6, 0.6)	
	frame.healthborder_tex = healthborder_tex
	
	--Create Health Backdrop Frame
	local healthbackdrop2 = CreateFrame("Frame", nil, hp)
	healthbackdrop2:SetPoint("TOPLEFT", healthborder, "TOPLEFT", noscalemult, -noscalemult)
	healthbackdrop2:SetPoint("BOTTOMRIGHT", healthborder, "BOTTOMRIGHT", -noscalemult, noscalemult)
	healthbackdrop2:SetFrameLevel(hp:GetFrameLevel() - 1)
	healthbackdrop2_tex = healthbackdrop2:CreateTexture(nil, "BORDER")
	healthbackdrop2_tex:SetAllPoints(healthbackdrop2)
	healthbackdrop2_tex:SetTexture(0.1, 0.1, 0.1)
	
	hp:HookScript('OnShow', UpdateObjects)
	hp:SetStatusBarTexture(TEXTURE)
	frame.hp = hp
	
	--Actual Background for the Healthbar
	hp.hpbg = hp:CreateTexture(nil, 'BORDER')
	hp.hpbg:SetAllPoints(hp)
	hp.hpbg:SetTexture(1,1,1,0.25)  
	
	--Create Overlay Highlight
	frame.overlay = frame:CreateTexture(nil, "HIGHLIGHT")
	frame.overlay:SetAllPoints(hp)
	frame.overlay:SetTexture(1,1,1,0.2)
	
	--Create Name
	hp.level = hp:CreateFontString(nil, "OVERLAY")
	hp.level:SetFont(FONT, FONTSIZE, FONTFLAG)
	hp.level:SetTextColor(1, 1, 1)
	hp.level:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)	
	
	--Needed for level text
	frame.oldlevel = oldlevel
	frame.boss = bossicon
	frame.elite = elite
	
	--Create Health Text
	if TukuiCF["nameplate"].showhealth == true then
		hp.value = hp:CreateFontString(nil, "OVERLAY")	
		hp.value:SetFont(FONT, FONTSIZE, FONTFLAG)
		hp.value:SetPoint("CENTER", hp)
		hp.value:SetTextColor(1,1,1)
		hp.value:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	end
	
	--Create Castbar Backdrop Frame
	local castbarbackdrop = CreateFrame("Frame", nil, cb)
	castbarbackdrop:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*3, noscalemult*3)
	castbarbackdrop:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
	castbarbackdrop:SetFrameLevel(cb:GetFrameLevel() - 3)
	castbarbackdrop_tex = castbarbackdrop:CreateTexture(nil, "BACKGROUND")
	castbarbackdrop_tex:SetAllPoints(castbarbackdrop)
	castbarbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	
	local castbarborder = CreateFrame("Frame", nil, cb)
	castbarborder:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*2, noscalemult*2)
	castbarborder:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	castbarborder:SetFrameLevel(cb:GetFrameLevel() - 2)
	castbarborder_tex = castbarborder:CreateTexture(nil, "BACKGROUND")
	castbarborder_tex:SetAllPoints(castbarborder)
	castbarborder_tex:SetTexture(0.6, 0.6, 0.6)	
	
	--Create Health Backdrop Frame
	local castbarbackdrop2 = CreateFrame("Frame", nil, cb)
	castbarbackdrop2:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult, noscalemult)
	castbarbackdrop2:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult, -noscalemult)
	castbarbackdrop2:SetFrameLevel(cb:GetFrameLevel() - 1)
	castbarbackdrop2_tex = castbarbackdrop2:CreateTexture(nil, "BACKGROUND")
	castbarbackdrop2_tex:SetAllPoints(castbarbackdrop2)
	castbarbackdrop2_tex:SetTexture(0.1, 0.1, 0.1)
	
	--Setup CastBar Icon
	cbicon:ClearAllPoints()
	cbicon:SetPoint("TOPLEFT", hp, "TOPRIGHT", 8, 0)		
	cbicon:SetSize(iconSize, iconSize)
	cbicon:SetTexCoord(.07, .93, .07, .93)
	cbicon:SetDrawLayer("OVERLAY")

	-- Create Cast Icon Backdrop frame
	local castbarbackdrop_tex = cb:CreateTexture(nil, "BACKGROUND")
	castbarbackdrop_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult*3, noscalemult*3)
	castbarbackdrop_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
	castbarbackdrop_tex:SetTexture(0.1, 0.1, 0.1)
	
	local castbarborder_tex = cb:CreateTexture(nil, "BORDER")
	castbarborder_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult*2, noscalemult*2)
	castbarborder_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	castbarborder_tex:SetTexture(0.6, 0.6, 0.6)	
	
	--Create Health Backdrop Frame
	local castbarbackdrop2_tex = cb:CreateTexture(nil, "ARTWORK")
	castbarbackdrop2_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult, noscalemult)
	castbarbackdrop2_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult, -noscalemult)
	castbarbackdrop2_tex:SetTexture(0.1, 0.1, 0.1)
	
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
	
	--Create level Text
	
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
	
	--Hide Old Stuff
	QueueObject(frame, oldlevel)
	QueueObject(frame, oldoverlay)
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

	if(self.elapsed and self.elapsed > 0.2) then
		for frame in pairs(frames) do
			UpdateThreat(frame, self.elapsed)
		end
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
	
	ForEachPlate(CheckBlacklist)
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
		if InCombatLockdown() then
			SetCVar("nameplateShowEnemies", 1)
		else
			SetCVar("nameplateShowEnemies", 0)
		end
	end
end