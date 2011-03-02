local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Base code by Dawn (dNameplates)
if not C["nameplate"].enable == true then return end

local TEXTURE = C["media"].normTex
local FONT = C["media"].font
local FONTSIZE = 10
local FONTFLAG = "THINOUTLINE"
local hpHeight = 12
local hpWidth = 110
local iconSize = 25		--Size of all Icons, RaidIcon/ClassIcon/Castbar Icon
local cbHeight = 5
local cbWidth = 110
local blankTex = C["media"].blank
local OVERLAY = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]
local numChildren = -1
local frames = {}
local noscalemult = E.mult * C["general"].uiscale

--Change defaults if we are showing health text or not
if C["nameplate"].showhealth ~= true then
	hpHeight = 7
	iconSize = 20
end

local NamePlates = CreateFrame("Frame", nil, UIParent)
NamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
if C["nameplate"].trackauras == true or C["nameplate"].trackccauras == true then
	NamePlates:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function QueueObject(parent, object)
	parent.queue = parent.queue or {}
	parent.queue[object] = true
end

local function HideObjects(parent)
	for object in pairs(parent.queue) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
			object.SetTexture = E.dummy
		elseif (object:GetObjectType() == 'FontString') then
			object.ClearAllPoints = E.dummy
			object.SetFont = E.dummy
			object.SetPoint = E.dummy
			object:Hide()
			object.Show = E.dummy
			object.SetText = E.dummy
			object.SetShadowOffset = E.dummy
		else
			object:Hide()
			object.Show = E.dummy
		end
	end
end

--Create our Aura Icons
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)
	
	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetTexture(unpack(C["media"].backdropcolor))
	button.bg:SetAllPoints(button)
	
	button.bord = button:CreateTexture(nil, "BORDER")
	button.bord:SetTexture(unpack(C["media"].bordercolor))
	button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
	button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
	
	button.bg2 = button:CreateTexture(nil, "ARTWORK")
	button.bg2:SetTexture(unpack(C["media"].backdropcolor))
	button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
	button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)	
	
	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
	button.icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.cd = CreateFrame("Cooldown",nil,button)
	button.cd:SetAllPoints(button)
	button.cd:SetReverse(true)
	button.count = button:CreateFontString(nil,"OVERLAY")
	button.count:SetFont(FONT,7,FONTFLAG)
	button.count:SetShadowColor(0, 0, 0, 0.4)
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
	return button
end

--Update an Aura Icon
local function UpdateAuraIcon(button, unit, index, filter)
	local name,_,icon,count,debuffType,duration,expirationTime,_,_,_,spellID = UnitAura(unit,index,filter)
	
	button.icon:SetTexture(icon)
	button.cd:SetCooldown(expirationTime-duration,duration)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	if count > 1 then 
		button.count:SetText(count)
	else
		button.count:SetText("")
	end
	button.cd:SetScript("OnUpdate", function(self) if not button.cd.timer then self:SetScript("OnUpdate", nil) return end button.cd.timer.text:SetFont(FONT,8,FONTFLAG) button.cd.timer.text:SetShadowColor(0, 0, 0, 0.4) end)
	button:Show()
end

--Filter auras on nameplate, and determine if we need to update them or not.
local tab = CLASS_FILTERS[E.myclass].target
local function OnAura(frame, unit)
	if not frame.icons or not tab or not frame.unit then return end
	local i = 1
	for index = 1,40 do
		if i > 5 then return end
		local match
		local name,_,_,_,_,duration,_,caster,_,_,spellid = UnitAura(frame.unit,index,"HARMFUL")
		
		if C["nameplate"].trackauras == true then
			for _, tab in pairs(tab) do
				local id = tab.id
				if caster == "player" then match = true end
			end
		end
		
		if C["nameplate"].trackccauras == true then
			if E.DebuffWhiteList[name] then match = true end
		end
		
		if duration and match == true then
			if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
			local icon = frame.icons[i]
			if i == 1 then icon:SetPoint("RIGHT",frame.icons,"RIGHT") end
			if i ~= 1 and i <= 5 then icon:SetPoint("RIGHT", frame.icons[i-1], "LEFT", -2, 0) end
			i = i + 1
			UpdateAuraIcon(icon, frame.unit, index, "HARMFUL")
		end
	end
	for index = i, #frame.icons do frame.icons[index]:Hide() end
end

--Color the castbar depending on if we can interrupt or not, 
--also resize it as nameplates somehow manage to resize some frames when they reappear after being hidden
local function UpdateCastbar(frame)
	frame:ClearAllPoints()
	frame:SetSize(cbWidth, cbHeight)
	frame:SetPoint('TOP', frame:GetParent().hp, 'BOTTOM', 0, -8)
	frame:GetStatusBarTexture():SetHorizTile(true)

	if(not frame.shield:IsShown()) then
		frame:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	end
end	

--Determine whether or not the cast is Channelled or a Regular cast so we can grab the proper Cast Name
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

--Sometimes castbar likes to randomly resize
local OnValueChanged = function(self, curValue)
	UpdateCastText(self, curValue)
	if self.needFix then
		UpdateCastbar(self)
		self.needFix = nil
	end
end

--Sometimes castbar likes to randomly resize
local OnSizeChanged = function(self)
	self.needFix = true
end

--We need to reset everything when a nameplate it hidden, this is so theres no left over data when a nameplate gets reshown for a differant mob.
local function OnHide(frame)
	frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	frame.overlay:Hide()
	frame.cb:Hide()
	frame.unit = nil
	frame.guid = nil
	frame.hasclass = nil
	frame.isFriendly = nil
	frame.hp.rcolor = nil
	frame.hp.gcolor = nil
	frame.hp.bcolor = nil
	if frame.icons then
		for _,icon in ipairs(frame.icons) do
			icon:Hide()
		end
	end	
	
	frame.healthborder_tex1:SetTexture(unpack(C["media"].bordercolor))
	frame.healthborder_tex2:SetTexture(unpack(C["media"].bordercolor))
	frame.healthborder_tex3:SetTexture(unpack(C["media"].bordercolor))
	frame.healthborder_tex4:SetTexture(unpack(C["media"].bordercolor))	
	frame:SetScript("OnUpdate",nil)
end

--Color the nameplate to 'Our' style instead of using blizzards ugly colors.
local function Colorize(frame)
	local r,g,b = frame.hp:GetStatusBarColor()
	if frame.hasclass == true then frame.isFriendly = false return end
	
	if g+b == 0 then -- hostile
		r,g,b = unpack(E.oUF_colors.reaction[1])
		frame.isFriendly = false
	elseif r+b == 0 then -- friendly npc
		r,g,b = unpack(E.oUF_colors.power["MANA"])
		frame.isFriendly = true
	elseif r+g > 1.95 then -- neutral
		r,g,b = unpack(E.oUF_colors.reaction[4])
		frame.isFriendly = false
	elseif r+g == 0 then -- friendly player
		r,g,b = unpack(E.oUF_colors.reaction[5])
		frame.isFriendly = true
	else -- enemy player
		frame.isFriendly = false
	end
	frame.hp:SetStatusBarColor(r,g,b)
end

--HealthBar OnShow, use this to set variables for the nameplate, also size the healthbar here because it likes to lose it's
--size settings when it gets reshown
local function UpdateObjects(frame)
	local frame = frame:GetParent()
	
	local r, g, b = frame.hp:GetStatusBarColor()
	local r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
	local classname = ""
	
	--Have to reposition this here so it doesnt resize after being hidden
	frame.hp:ClearAllPoints()
	frame.hp:SetSize(hpWidth, hpHeight)	
	frame.hp:SetPoint('TOP', frame, 'TOP', 0, -15)
	frame.hp:GetStatusBarTexture():SetHorizTile(true)
			
	--Class Icons, also determines if the current frame is a Enemy Player frame
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
			frame.hasclass = false
		end
	else
		frame.hasclass = false
	end
	
	if frame.hp.rcolor == 0 and frame.hp.gcolor == 0 and frame.hp.bcolor ~= 0 then
		frame.hasclass = true
	end

	--create variable for original colors
	Colorize(frame)
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = frame.hp:GetStatusBarColor()
	frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
	frame.name:SetTextColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	
	--Set the name text
	frame.name:SetText(frame.oldname:GetText())
	
	--Setup level text
	local level, elite, mylevel = tonumber(frame.oldlevel:GetText()), frame.elite:IsShown(), UnitLevel("player")
	frame.hp.level:ClearAllPoints()
	if C["nameplate"].showhealth == true then
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
		frame.hp.level:Show()
	end
	
	frame.overlay:ClearAllPoints()
	frame.overlay:SetAllPoints(frame.hp)
	
	-- Aura tracking
	if C["nameplate"].trackauras == true or C["nameplate"].trackccauras == true then
		if frame.icons then return end
		frame.icons = CreateFrame("Frame",nil,frame)
		frame.icons:SetPoint("BOTTOMRIGHT",frame.hp,"TOPRIGHT", 0, FONTSIZE+5)
		frame.icons:SetWidth(20 + hpWidth)
		frame.icons:SetHeight(25)
		frame.icons:SetFrameLevel(frame.hp:GetFrameLevel()+2)
		frame:RegisterEvent("UNIT_AURA")
		frame:HookScript("OnEvent", OnAura)
	end	

	HideObjects(frame)
end

--This is where we create most 'Static' objects for the nameplate, it gets fired when a nameplate is first seen.
local function SkinObjects(frame)
	local hp, cb = frame:GetChildren()
	local threat, hpborder, cbshield, cbborder, cbicon, overlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	local hpborder, threat, overlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	local _, cbborder, cbshield, cbicon = cb:GetRegions()
	
	frame.healthOriginal = hp
	
	--Just make sure these are correct
	hp:SetFrameLevel(1)
	cb:SetFrameLevel(1)
	
	-- Create Health Backdrop frame
	local healthbarbackdrop_tex = hp:CreateTexture(nil, "BORDER")
	healthbarbackdrop_tex:SetDrawLayer("BORDER", -8)
	healthbarbackdrop_tex:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*3, noscalemult*3)
	healthbarbackdrop_tex:SetPoint("TOPRIGHT", hp, "TOPRIGHT", noscalemult*3, noscalemult*3)
	healthbarbackdrop_tex:SetHeight(hpHeight + noscalemult*6)
	healthbarbackdrop_tex:SetTexture(unpack(C["media"].backdropcolor))

	--Create our fake border.. fuck blizz
	local healthbarborder_tex1 = hp:CreateTexture(nil, "BORDER")
	healthbarborder_tex1:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*2, noscalemult*2)
	healthbarborder_tex1:SetPoint("TOPRIGHT", hp, "TOPRIGHT", noscalemult*2, noscalemult*2)
	healthbarborder_tex1:SetHeight(noscalemult)
	healthbarborder_tex1:SetTexture(unpack(C["media"].bordercolor))	
	healthbarborder_tex1:SetDrawLayer("BORDER", -7)
	frame.healthborder_tex1 = healthbarborder_tex1
	
	local healthbarborder_tex2 = hp:CreateTexture(nil, "BORDER")
	healthbarborder_tex2:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2)
	healthbarborder_tex2:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	healthbarborder_tex2:SetHeight(noscalemult)
	healthbarborder_tex2:SetTexture(unpack(C["media"].bordercolor))	
	healthbarborder_tex2:SetDrawLayer("BORDER", -7)
	frame.healthborder_tex2 = healthbarborder_tex2
	
	local healthbarborder_tex3 = hp:CreateTexture(nil, "BORDER")
	healthbarborder_tex3:SetPoint("TOPLEFT", hp, "TOPLEFT", -noscalemult*2, noscalemult*2)
	healthbarborder_tex3:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
	healthbarborder_tex3:SetWidth(noscalemult)
	healthbarborder_tex3:SetTexture(unpack(C["media"].bordercolor))	
	healthbarborder_tex3:SetDrawLayer("BORDER", -7)
	frame.healthborder_tex3 = healthbarborder_tex3
	
	local healthbarborder_tex4 = hp:CreateTexture(nil, "BORDER")
	healthbarborder_tex4:SetPoint("TOPRIGHT", hp, "TOPRIGHT", noscalemult*2, noscalemult*2)
	healthbarborder_tex4:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
	healthbarborder_tex4:SetWidth(noscalemult)
	healthbarborder_tex4:SetTexture(unpack(C["media"].bordercolor))	
	healthbarborder_tex4:SetDrawLayer("BORDER", -7)
	frame.healthborder_tex4 = healthbarborder_tex4

	hp:SetStatusBarTexture(TEXTURE)
	frame.hp = hp
	
	--Actual Background for the Healthbar
	hp.hpbg = hp:CreateTexture(nil, 'BORDER')
	hp.hpbg:SetAllPoints(hp)
	hp.hpbg:SetTexture(1,1,1,0.25)  
	
	--Reuse old Overlay Highlight
	frame.overlay = overlay
	frame.overlay:SetTexture(1,1,1,0.15)
	frame.overlay:SetAllPoints(hp)
	
	--Create Level
	hp.level = hp:CreateFontString(nil, "OVERLAY")
	hp.level:SetFont(FONT, FONTSIZE, FONTFLAG)
	hp.level:SetShadowColor(0, 0, 0, 0.4)
	hp.level:SetTextColor(1, 1, 1)
	hp.level:SetShadowOffset(E.mult, -E.mult)	
	
	--Needed for level text
	frame.oldlevel = oldlevel
	frame.boss = bossicon
	frame.elite = elite
	
	--Create Health Text
	if C["nameplate"].showhealth == true then
		hp.value = hp:CreateFontString(nil, "OVERLAY")	
		hp.value:SetFont(FONT, FONTSIZE, FONTFLAG)
		hp.value:SetShadowColor(0, 0, 0, 0.4)
		hp.value:SetPoint("CENTER", hp)
		hp.value:SetTextColor(1,1,1)
		hp.value:SetShadowOffset(E.mult, -E.mult)
	end
	
	--Debug Text for when i'm testing
	hp.debug = hp:CreateFontString(nil, "OVERLAY")	
	hp.debug:SetFont(FONT, FONTSIZE, FONTFLAG)
	hp.debug:SetShadowColor(0, 0, 0, 0.4)
	hp.debug:SetPoint("CENTER", hp, "CENTER", 0, 50)
	hp.debug:SetTextColor(1,1,1)
	hp.debug:SetShadowOffset(E.mult, -E.mult)
	
	-- Create Cast Bar Backdrop frame
	local castbarbackdrop_tex = cb:CreateTexture(nil, "BACKGROUND")
	castbarbackdrop_tex:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*3, noscalemult*3)
	castbarbackdrop_tex:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
	castbarbackdrop_tex:SetTexture(unpack(C["media"].backdropcolor))
	
	--Create our fake border.. fuck blizz
	local castbarborder_tex1 = cb:CreateTexture(nil, "BORDER")
	castbarborder_tex1:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*2, noscalemult*2)
	castbarborder_tex1:SetPoint("TOPRIGHT", cb, "TOPRIGHT", noscalemult*2, noscalemult*2)
	castbarborder_tex1:SetHeight(noscalemult)
	castbarborder_tex1:SetTexture(unpack(C["media"].bordercolor))	
	
	local castbarborder_tex2 = cb:CreateTexture(nil, "BORDER")
	castbarborder_tex2:SetPoint("BOTTOMLEFT", cb, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2)
	castbarborder_tex2:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	castbarborder_tex2:SetHeight(noscalemult)
	castbarborder_tex2:SetTexture(unpack(C["media"].bordercolor))	
	
	local castbarborder_tex3 = cb:CreateTexture(nil, "BORDER")
	castbarborder_tex3:SetPoint("TOPLEFT", cb, "TOPLEFT", -noscalemult*2, noscalemult*2)
	castbarborder_tex3:SetPoint("BOTTOMLEFT", cb, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
	castbarborder_tex3:SetWidth(noscalemult)
	castbarborder_tex3:SetTexture(unpack(C["media"].bordercolor))	
	
	local castbarborder_tex4 = cb:CreateTexture(nil, "BORDER")
	castbarborder_tex4:SetPoint("TOPRIGHT", cb, "TOPRIGHT", noscalemult*2, noscalemult*2)
	castbarborder_tex4:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
	castbarborder_tex4:SetWidth(noscalemult)
	castbarborder_tex4:SetTexture(unpack(C["media"].bordercolor))
	
	--Setup CastBar Icon
	cbicon:ClearAllPoints()
	cbicon:SetPoint("TOPLEFT", hp, "TOPRIGHT", 8, 0)		
	cbicon:SetSize(iconSize, iconSize)
	cbicon:SetTexCoord(.07, .93, .07, .93)
	cbicon:SetDrawLayer("OVERLAY")
		
	-- Create Cast Icon Backdrop frame
	local casticonbackdrop_tex = cb:CreateTexture(nil, "BACKGROUND")
	casticonbackdrop_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult*3, noscalemult*3)
	casticonbackdrop_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
	casticonbackdrop_tex:SetTexture(unpack(C["media"].backdropcolor))
	
	local casticonborder_tex = cb:CreateTexture(nil, "BORDER")
	casticonborder_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult*2, noscalemult*2)
	casticonborder_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
	casticonborder_tex:SetTexture(unpack(C["media"].bordercolor))	
	
	local casticonbackdrop2_tex = cb:CreateTexture(nil, "ARTWORK")
	casticonbackdrop2_tex:SetPoint("TOPLEFT", cbicon, "TOPLEFT", -noscalemult, noscalemult)
	casticonbackdrop2_tex:SetPoint("BOTTOMRIGHT", cbicon, "BOTTOMRIGHT", noscalemult, -noscalemult)
	casticonbackdrop2_tex:SetTexture(unpack(C["media"].backdropcolor))	
	
	cb.icon = cbicon
	
	--Create Cast Time Text
	cb.time = cb:CreateFontString(nil, "ARTWORK")
	cb.time:SetPoint("RIGHT", cb, "LEFT", -1, 0)
	cb.time:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.time:SetShadowColor(0, 0, 0, 0.4)
	cb.time:SetTextColor(1, 1, 1)
	cb.time:SetShadowOffset(E.mult, -E.mult)

	--Create Cast Name Text
	cb.name = cb:CreateFontString(nil, "ARTWORK")
	cb.name:SetPoint("TOP", cb, "BOTTOM", 0, -3)
	cb.name:SetFont(FONT, FONTSIZE, FONTFLAG)
	cb.name:SetTextColor(1, 1, 1)
	cb.name:SetShadowColor(0, 0, 0, 0.4)
	cb.name:SetShadowOffset(E.mult, -E.mult)	
	
	--We need the castbar shield to determine if it can be interrupted or not
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
	name:SetShadowColor(0, 0, 0, 0.4)
	name:SetShadowOffset(E.mult, -E.mult)
	frame.oldname = oldname
	frame.name = name
		
	--Reposition and Resize RaidIcon
	raidicon:ClearAllPoints()
	raidicon:SetPoint("BOTTOM", hp, "TOP", 0, 16)
	raidicon:SetSize(iconSize*1.4, iconSize*1.4)
	raidicon:SetTexture(C["media"].raidicons)	
	frame.raidicon = raidicon
	
	--Hide Old Stuff
	QueueObject(frame, oldlevel)
	QueueObject(frame, threat)
	QueueObject(frame, hpborder)
	QueueObject(frame, cbshield)
	QueueObject(frame, cbborder)
	QueueObject(frame, oldname)
	QueueObject(frame, bossicon)
	QueueObject(frame, elite)
	
	UpdateObjects(hp)
	UpdateCastbar(cb)
	
	frame.hp:HookScript('OnShow', UpdateObjects)
	frame:HookScript('OnHide', OnHide)
	frames[frame] = true
end

local goodR, goodG, goodB = unpack(C["nameplate"].goodcolor)
local badR, badG, badB = unpack(C["nameplate"].badcolor)
local transitionR, transitionG, transitionB = unpack(C["nameplate"].transitioncolor)
local function UpdateThreat(frame, elapsed)
	frame.hp:Show()
	if C["nameplate"].enhancethreat ~= true then
		if(frame.region:IsShown()) then
			local _, val = frame.region:GetVertexColor()
			if(val > 0.7) then
				frame.healthborder_tex1:SetTexture(transitionR, transitionG, transitionB)
				frame.healthborder_tex2:SetTexture(transitionR, transitionG, transitionB)
				frame.healthborder_tex3:SetTexture(transitionR, transitionG, transitionB)
				frame.healthborder_tex4:SetTexture(transitionR, transitionG, transitionB)
			else
				frame.healthborder_tex1:SetTexture(badR, badG, badB)
				frame.healthborder_tex2:SetTexture(badR, badG, badB)
				frame.healthborder_tex3:SetTexture(badR, badG, badB)
				frame.healthborder_tex4:SetTexture(badR, badG, badB)
			end
		else
			frame.healthborder_tex1:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex2:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex3:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex4:SetTexture(unpack(C["media"].bordercolor))
		end
	else
		if not frame.region:IsShown() then
			if InCombatLockdown() and frame.hasclass ~= true and frame.isFriendly ~= true then
				--No Threat
				if E.Role == "Tank" then
					frame.hp:SetStatusBarColor(badR, badG, badB)
					frame.hp.hpbg:SetTexture(badR, badG, badB, 0.25)
				else
					frame.hp:SetStatusBarColor(goodR, goodG, goodB)
					frame.hp.hpbg:SetTexture(goodR, goodG, goodB, 0.25)
				end		
			else
				--Set colors to their original, not in combat
				frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
				frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
			end
		else
			--Ok we either have threat or we're losing/gaining it
			local r, g, b = frame.region:GetVertexColor()
			if g + b == 0 then
				--Have Threat
				if E.Role == "Tank" then
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
end

--Create our blacklist for nameplates, so prevent a certain nameplate from ever showing
local function CheckBlacklist(frame, ...)
	if E.PlateBlacklist[frame.name:GetText()] then
		frame:SetScript("OnUpdate", function() end)
		frame.hp:Hide()
		frame.cb:Hide()
		frame.overlay:Hide()
		frame.oldlevel:Hide()
	end
end

--When becoming intoxicated blizzard likes to re-show the old level text, this should fix that
local function HideDrunkenText(frame, ...)
	if frame and frame.oldlevel and frame.oldlevel:IsShown() then
		frame.oldlevel:Hide()
	end
end

--Force the name text of a nameplate to be behind other nameplates unless it is our target
local function AdjustNameLevel(frame, ...)
	if UnitName("target") == frame.name:GetText() and frame:GetAlpha() == 1 then
		frame.name:SetDrawLayer("OVERLAY")
	else
		frame.name:SetDrawLayer("BORDER")
	end
end

--Health Text, also border coloring for certain plates depending on health
local function ShowHealth(frame, ...)
	-- show current health value
	local minHealth, maxHealth = frame.healthOriginal:GetMinMaxValues()
	local valueHealth = frame.healthOriginal:GetValue()
	local d =(valueHealth/maxHealth)*100
	
	if C["nameplate"].showhealth == true then
		frame.hp.value:SetText(E.ShortValue(valueHealth).." - "..(string.format("%d%%", math.floor((valueHealth/maxHealth)*100))))
	end
			
	--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
	if frame.hasclass == true or frame.isFriendly == true then
		if(d <= 50 and d >= 20) then
			frame.healthborder_tex1:SetTexture(1, 1, 0)
			frame.healthborder_tex2:SetTexture(1, 1, 0)
			frame.healthborder_tex3:SetTexture(1, 1, 0)
			frame.healthborder_tex4:SetTexture(1, 1, 0)
		elseif(d < 20) then
			frame.healthborder_tex1:SetTexture(1, 0, 0)
			frame.healthborder_tex2:SetTexture(1, 0, 0)
			frame.healthborder_tex3:SetTexture(1, 0, 0)
			frame.healthborder_tex4:SetTexture(1, 0, 0)
		else
			frame.healthborder_tex1:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex2:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex3:SetTexture(unpack(C["media"].bordercolor))
			frame.healthborder_tex4:SetTexture(unpack(C["media"].bordercolor))
		end
	elseif (frame.hasclass ~= true and frame.isFriendly ~= true) and C["nameplate"].enhancethreat == true then
		frame.healthborder_tex1:SetTexture(unpack(C["media"].bordercolor))
		frame.healthborder_tex2:SetTexture(unpack(C["media"].bordercolor))
		frame.healthborder_tex3:SetTexture(unpack(C["media"].bordercolor))
		frame.healthborder_tex4:SetTexture(unpack(C["media"].bordercolor))
	end
end

--Scan all visible nameplate for a known unit.
local function CheckUnit_Guid(frame, ...)
	--local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
	if UnitExists("target") and frame:GetAlpha() == 1 and UnitName("target") == frame.name:GetText() then
		frame.guid = UnitGUID("target")
		frame.unit = "target"
		OnAura(frame, "target")
	elseif frame.overlay:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == frame.name:GetText() then
		frame.guid = UnitGUID("mouseover")
		frame.unit = "mouseover"
		OnAura(frame, "mouseover")
	else
		frame.unit = nil
	end	
	
	if C["debug"].enabled == true then frame.hp.debug:SetText(frame.unit or "") end
end

--Attempt to match a nameplate with a GUID from the combat log
local function MatchGUID(frame, destGUID, spellID)
	if not frame.guid then return end
	
	if frame.guid == destGUID then
		for _,icon in ipairs(frame.icons) do if icon.spellID == spellID then icon:Hide() end end
	end
end

--Run a function for all visible nameplates, we use this for the blacklist, to check unitguid, and to hide drunken text
local function ForEachPlate(functionToRun, ...)
	for frame in pairs(frames) do
		if frame:IsShown() then
			functionToRun(frame, ...)
		end
	end
end

--Check if the frames default overlay texture matches blizzards nameplates default overlay texture
local select = select
local function HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()

		if(not frames[frame] and (frame:GetName() and frame:GetName():find("NamePlate%d")) and region and region:GetObjectType() == 'Texture' and region:GetTexture() == OVERLAY) then
			SkinObjects(frame)
			frame.region = region
		end
	end
end

--Core right here, scan for any possible nameplate frames that are Children of the WorldFrame
CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		HookFrames(WorldFrame:GetChildren())
	end

	if(self.elapsed and self.elapsed > 0.2) then
		ForEachPlate(UpdateThreat, self.elapsed)
		ForEachPlate(AdjustNameLevel)
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
	
	ForEachPlate(ShowHealth)
	ForEachPlate(CheckBlacklist)
	ForEachPlate(HideDrunkenText)
	ForEachPlate(CheckUnit_Guid)
end)

function NamePlates:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, _, spellID)
	if event == "SPELL_AURA_REMOVED" and destName ~= UnitName("player") then
		ForEachPlate(MatchGUID, destGUID, spellID)
	end
end

--Only show nameplates when in combat
if C["nameplate"].combat == true then
	NamePlates:RegisterEvent("PLAYER_REGEN_ENABLED")
	NamePlates:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	function NamePlates:PLAYER_REGEN_ENABLED()
		SetCVar("nameplateShowEnemies", 0)
	end

	function NamePlates:PLAYER_REGEN_DISABLED()
		SetCVar("nameplateShowEnemies", 1)
	end
end

NamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
function NamePlates:PLAYER_ENTERING_WORLD()
	if C["nameplate"].combat == true then
		if InCombatLockdown() then
			SetCVar("nameplateShowEnemies", 1)
		else
			SetCVar("nameplateShowEnemies", 0)
		end
	end
	
	if C["nameplate"].enable == true and C["nameplate"].enhancethreat == true then
		SetCVar("threatWarning", 3)
	end
end