local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

local CPOINT_TEX = [=[Interface\AddOns\ElvUI\media\textures\bubbleTex.tga]=]
local numChildren = -1

local AURA_TYPE_BUFF = 1
local AURA_TYPE_DEBUFF = 6
local AURA_TARGET_HOSTILE = 1
local AURA_TARGET_FRIENDLY = 2
local AuraList, AuraGUID = {}, {}

local AURA_TYPE = {
	["Buff"] = 1,
	["Curse"] = 2,
	["Disease"] = 3,
	["Magic"] = 4,
	["Poison"] = 5,
	["Debuff"] = 6,
}

local TimeColors = {
	[0] = '|cffeeeeee',
	[1] = '|cffeeeeee',
	[2] = '|cffeeeeee',
	[3] = '|cffFFEE00',
	[4] = '|cfffe0000',
}

local RaidIconIndex = {
	"STAR",
	"CIRCLE",
	"DIAMOND",
	"TRIANGLE",
	"MOON",
	"SQUARE",
	"CROSS",
	"SKULL",
}

local band = bit.band
local ceil = math.ceil
local twipe = table.wipe

NP.HealerSpecs = {
	[L['Restoration']] = true,
	[L['Holy']] = true,
	[L['Discipline']] = true,
	[L['Mistweaver']] = true,
}

NP.TankClasses = {
	['WARRIOR'] = true,
	['PALADIN'] = true,
	['MONK'] = true,
	['DEATHKNIGHT'] = true,
	['DRUID'] = true,
}

NP.RaidTargetReference = {
	["STAR"] = 0x00000001,
	["CIRCLE"] = 0x00000002,
	["DIAMOND"] = 0x00000004,
	["TRIANGLE"] = 0x00000008,
	["MOON"] = 0x00000010,
	["SQUARE"] = 0x00000020,
	["CROSS"] = 0x00000040,
	["SKULL"] = 0x00000080,
}

NP.ComboColors = {
	[1] = {0.69, 0.31, 0.31},
	[2] = {0.69, 0.31, 0.31},
	[3] = {0.65, 0.63, 0.35},
	[4] = {0.65, 0.63, 0.35},
	[5] = {0.33, 0.59, 0.33}
}

NP.RaidIconCoordinate = {
	[0]		= { [0]		= "STAR", [0.25]	= "MOON", },
	[0.25]	= { [0]		= "CIRCLE", [0.25]	= "SQUARE",	},
	[0.5]	= { [0]		= "DIAMOND", [0.25]	= "CROSS", },
	[0.75]	= { [0]		= "TRIANGLE", [0.25]	= "SKULL", }, 
}

NP.Handled = {} --Skinned Nameplates
NP.Healers = {};
NP.GUIDIgnoreCast = {};
NP.TargetOfGroupMembers = {}
NP.ByRaidIcon = {}			-- Raid Icon to GUID 		-- ex.  ByRaidIcon["SKULL"] = GUID
NP.ByName = {}				-- Name to GUID (PVP)
NP.Aura_List = {}	-- Two Dimensional
NP.Aura_Spellid = {}
NP.Aura_Expiration = {}
NP.Aura_Stacks = {}
NP.Aura_Caster = {}
NP.Aura_Duration = {}
NP.Aura_Texture = {}
NP.Aura_Type = {}
NP.Aura_Target = {}
NP.GroupTanks = {};
NP.GroupMembers = {};
NP.CachedAuraDurations = {};
NP.AurasCache = {}

NP.MAX_DISPLAYABLE_DEBUFFS = 5;
NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS = 2;

function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP
	
	if type(self.db.healthtext) == 'Boolean' then
		self.db.healthtext = P.nameplate.healthtext
	end
	
	CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
		local count = WorldFrame:GetNumChildren()
		if(count ~= numChildren) then
			numChildren = count
			NP:HookFrames(WorldFrame:GetChildren())
		end	

		NP:ForEachPlate(NP.CheckFilter)
		NP:ForEachPlate(NP.UpdateColoring)	

		if(self.elapsed and self.elapsed > 0.2) then
			NP:ForEachPlate(NP.UpdateIsBeingTanked)
			NP:ForEachPlate(NP.UpdateThreat)
			NP:ForEachPlate(NP.CheckUnit_Guid)
			NP:ForEachPlate(NP.CheckRaidIcon)
			NP:ForEachPlate(NP.Update_LevelText)

			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end)	

	self:UpdateAllPlates()
	self:ToggleCPoints()
end

function NP:UpdateAllPlates()
	if E.private["nameplate"].enable ~= true then return end
	for frame, _ in pairs(self.Handled) do
		frame = _G[frame]
		self:SkinPlate(frame:GetChildren())
	end

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateRoster")
	self:RegisterEvent("PARTY_CONVERTED_TO_RAID", "UpdateRoster")
	self:RegisterEvent("UNIT_PET", "UpdateRoster")
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('UNIT_TARGET')
	self:RegisterEvent('UNIT_AURA')	
	self:PLAYER_ENTERING_WORLD()
end

--Run a function for all visible nameplates
function NP:ForEachPlate(functionToRun, ...)
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]
		if frame and frame:IsShown() then
			functionToRun(NP, select(1,frame:GetChildren()), ...)
		end
	end
end

function NP:HookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()
		local name = frame:GetName()
		
		if(not NP.Handled[name] and (name and name:find("NamePlate%d"))) then
			NP:SkinPlate(frame:GetChildren())
		end
	end
end

function NP:SkinPlate(frame, nameFrame)
	local oldhp, cb = frame:GetChildren()
	
	local _, cbborder, cbshield, cbicon, cbtext, cbshadow = cb:GetRegions()
	local threat, hpborder, overlay, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
	local oldname = nameFrame:GetRegions()
	local font = LSM:Fetch("font", self.db.font)
	local noscalemult = E.mult * UIParent:GetScale()

	--Health Bar
	if not frame.hp then
		frame.oldhp = oldhp
		
		local SHADOW_SPACING = E.PixelMode and (((noscalemult * 5) - UIParent:GetScale() / 3)) or 4
		frame.hp = CreateFrame("Statusbar", nil, frame)
		frame.hp:SetFrameLevel(oldhp:GetFrameLevel() + 1)
		frame.hp:SetFrameStrata(oldhp:GetFrameStrata())
		frame.hp:CreateShadow('Default')
		frame.hp.shadow:ClearAllPoints()
		frame.hp.shadow:Point("TOPLEFT", frame.hp, -SHADOW_SPACING, SHADOW_SPACING)
		frame.hp.shadow:Point("BOTTOMLEFT", frame.hp, -SHADOW_SPACING, -SHADOW_SPACING)
		frame.hp.shadow:Point("TOPRIGHT", frame.hp, SHADOW_SPACING, SHADOW_SPACING)
		frame.hp.shadow:Point("BOTTOMRIGHT", frame.hp, SHADOW_SPACING, -SHADOW_SPACING)
		frame.hp.shadow:SetScale(2)
		frame.hp.shadow:SetBackdropBorderColor(1, 1, 1, 0.9)
		frame.hp.shadow:SetFrameLevel(0)
		frame.hp.shadow:SetAlpha(0)
		self:CreateVirtualFrame(frame.hp)

		oldhp:SetAllPoints(frame.hp)
		
		frame.hp.hpbg = frame.hp:CreateTexture(nil, 'BORDER')
		frame.hp.hpbg:SetAllPoints(frame.hp)
		frame.hp.hpbg:SetTexture(1,1,1,0.25) 	
	end
	frame.hp:SetStatusBarTexture(E["media"].normTex)
	self:SetVirtualBackdrop(frame.hp, unpack(E["media"].backdropcolor))
		
	if not frame.cpoints then
		frame.cpoints = CreateFrame("Frame", nil, frame.hp)
		frame.cpoints:Point("CENTER", frame.hp, "BOTTOM")
		frame.cpoints:Height(1)
		frame.cpoints:Width(68)
		
		for i=1, MAX_COMBO_POINTS do
			frame.cpoints[i] = frame.cpoints:CreateTexture(nil, 'OVERLAY')
			frame.cpoints[i]:SetTexture(CPOINT_TEX)
			frame.cpoints[i]:Size(12)
			
			if i == 1 then
				frame.cpoints[i]:SetPoint("LEFT", frame.cpoints, "TOPLEFT")
			else
				frame.cpoints[i]:SetPoint("LEFT", frame.cpoints[i-1], "RIGHT", 2, 0)
			end
			
			frame.cpoints[i]:Hide()
		end
	end
		
	if not frame.overlay then
		overlay:SetTexture(1, 1, 1, 0.35)
		overlay:SetAllPoints(frame.hp)
		frame.overlay = overlay
	end	
	
	-- threat updates
	if not frame.threat then	
		frame.threat = threat	
	end
	
	--Level Text
	if not frame.hp.level then
		frame.hp.level = frame.hp:CreateFontString(nil, "OVERLAY")
		frame.hp.level:SetPoint("RIGHT", frame.hp, "LEFT", -1, 0)
		frame.hp.oldlevel = oldlevel
		frame.hp.boss = bossicon
		frame.hp.elite = elite
	end
	frame.hp.level:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	if oldlevel:GetObjectType() == 'FontString' then
		frame.hp.level:SetText(oldlevel:GetText())
		frame.hp.level:SetTextColor(oldlevel:GetTextColor())
	end
	
	if not frame.classIcon then
		frame.classIcon = frame.hp:CreateTexture(nil, "ARTWORK");
		frame.classIcon:Size(30);
		frame.classIcon:Point("RIGHT", frame.hp.level, "LEFT", -1, 0);
		frame.classIcon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);
		frame.classIcon:Hide();
	end	
	
	--Name Text
	if not frame.hp.name then
		frame.hp.name = frame.hp:CreateFontString(nil, 'OVERLAY')
		frame.hp.oldname = oldname
	end
	frame.hp.name:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	frame.hp.name:SetPoint('BOTTOM', frame.hp, 'TOP', 0 + self.db.nameXOffset, 4 + self.db.nameYOffset)
	frame.hp.name:SetJustifyH(self.db.nameJustifyH)
	frame.hp.name:SetHeight(self.db.fontSize)

	--Health Text
	if not frame.hp.value then
		frame.hp.value = frame.hp:CreateFontString(nil, "OVERLAY")	
		frame.hp.value:SetPoint("CENTER", frame.hp)
	end
	frame.hp.value:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	
	--Cast Bar
	if not frame.cb then
		cb.shield = cbshield
		frame.cb = cb

		cb:SetFrameLevel(1)
		cb:SetStatusBarTexture(TEXTURE)
		self:CreateVirtualFrame(cb)
		
		--Create Cast Time Text
		cb.time = cb:CreateFontString(nil, "ARTWORK")
		cb.time:SetPoint("RIGHT", cb, "LEFT", -1, 0)

		--Create Cast Name Text
		frame.cb.name = cbtext
		frame.cb.name:ClearAllPoints()
		frame.cb.name:SetPoint("TOP", frame.cb, "BOTTOM", 0, -3)
		
		--Setup CastBar Icon
		cbicon:ClearAllPoints()
		cbicon:SetPoint("TOPLEFT", frame.hp, "TOPRIGHT", 8, 0)		
		cbicon:SetTexCoord(.07, .93, .07, .93)
		cbicon:SetDrawLayer("OVERLAY")
		cb.icon = cbicon
		self:CreateVirtualFrame(cb, cb.icon)		
	end
	frame.cb.name:FontTemplate(font, self.db.fontSize, self.db.fontOutline)
	frame.cb.time:FontTemplate(font, self.db.fontSize, self.db.fontOutline)

	--Raid Icon
	if not frame.raidicon then
		raidicon:ClearAllPoints()
		raidicon:SetPoint("BOTTOM", frame.hp, "TOP", 0, 16)
		raidicon:SetSize(35, 35)
		frame.raidicon = raidicon	
	end
	
	--Heal Icon
	if not frame.healerIcon then
		frame.healerIcon = frame:CreateTexture(nil, 'ARTWORK')
		frame.healerIcon:SetPoint("BOTTOM", frame.hp, "TOP", 0, 16)
		frame.healerIcon:SetSize(35, 35)
		frame.healerIcon:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])	
	end
	
	if not frame.AuraWidget then
		--if not WatcherIsEnabled then Enable() end
		-- Create Base frame
		local f = CreateFrame("Frame", nil, frame)
		f:SetHeight(32); f:Show()
		f:SetPoint('BOTTOMRIGHT', frame.hp, 'TOPRIGHT', 0, 10)
		f:SetPoint('BOTTOMLEFT', frame.hp, 'TOPLEFT', 0, 10)
		
		-- Create Icon Array
		f.PollFunction = NP.UpdateAuraTime
		f.AuraIconFrames = {}
		local AuraIconFrames = f.AuraIconFrames
		for index = 1, NP.MAX_DISPLAYABLE_DEBUFFS do AuraIconFrames[index] = NP:CreateAuraIcon(f);  end
		local FirstRowCount = min(NP.MAX_DISPLAYABLE_DEBUFFS/2)
		-- Set Anchors	
		AuraIconFrames[1]:SetPoint("RIGHT", f, -1, 0)
		for index = 2, NP.MAX_DISPLAYABLE_DEBUFFS do AuraIconFrames[index]:SetPoint("RIGHT", AuraIconFrames[index-1], "LEFT", -3, 0) end
		
		-- Functions
		f._Hide = f.Hide
		f.Hide = function() NP:ClearAuraContext(f); f:_Hide() end
		f:SetScript("OnHide", function() for index = 1, 4 do NP.PolledHideIn(AuraIconFrames[index], 0) end end)	
		f.UpdateContext = NP.UpdateAuraContext
		f.Update = NP.UpdateAuraContext
		f.UpdateTarget = NP.UpdateAuraTarget
		
		frame.AuraWidget = f
	end
	
	for index = 1, NP.MAX_DISPLAYABLE_DEBUFFS do 
		if frame.AuraWidget.AuraIconFrames and frame.AuraWidget.AuraIconFrames[index] then
			local auraFont = LSM:Fetch("font", self.db.auraFont)
			frame.AuraWidget.AuraIconFrames[index].TimeLeft:FontTemplate(auraFont, self.db.auraFontSize, self.db.auraFontOutline)
			frame.AuraWidget.AuraIconFrames[index].Stacks:FontTemplate(auraFont, self.db.auraFontSize, self.db.auraFontOutline)
		end
	end
		
	--Hide Old Stuff
	self:QueueObject(frame, oldhp)
	self:QueueObject(frame, oldlevel)
	self:QueueObject(frame, threat)
	self:QueueObject(frame, hpborder)
	self:QueueObject(frame, cbshield)
	self:QueueObject(frame, cbborder)
	self:QueueObject(frame, cbshadow)
	self:QueueObject(frame, oldname)
	self:QueueObject(frame, bossicon)
	self:QueueObject(frame, elite)
	
	self.HealthBar_OnShow(frame.hp)
	self.CastBar_OnShow(cb)

	cb:HookScript('OnShow', self.CastBar_OnShow)	
	cb:HookScript('OnValueChanged', self.CastBar_OnValueChanged)			
	frame.hp:HookScript('OnShow', self.HealthBar_OnShow)		
	oldhp:HookScript('OnValueChanged', self.HealthBar_ValueChanged)
	frame:HookScript("OnHide", self.OnHide)

	NP.Handled[frame:GetParent():GetName()] = true
end

function NP:QueueObject(frame, object)
	if not frame.queue then frame.queue = {} end
	frame.queue[object] = true

	if object.OldTexture then
		object:SetTexture(object.OldTexture)
	end
end

function NP:CreateVirtualFrame(parent, point)
	point = point or parent
	local noscalemult = E.mult * UIParent:GetScale()
	
	if point.bordertop then return end

	
	point.backdrop2 = parent:CreateTexture(nil, "BORDER")
	point.backdrop2:SetDrawLayer("BORDER", -4)
	point.backdrop2:SetAllPoints(point)
	point.backdrop2:SetTexture(unpack(E["media"].backdropcolor))		
	
	if E.PixelMode then 
		point.bordertop = parent:CreateTexture(nil, "BORDER")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))	
		point.bordertop:SetDrawLayer("BORDER", -7)
		
		point.borderbottom = parent:CreateTexture(nil, "BORDER")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))	
		point.borderbottom:SetDrawLayer("BORDER", -7)
		
		point.borderleft = parent:CreateTexture(nil, "BORDER")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))	
		point.borderleft:SetDrawLayer("BORDER", -7)
		
		point.borderright = parent:CreateTexture(nil, "BORDER")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))	
		point.borderright:SetDrawLayer("BORDER", -7)			
	else
		point.backdrop = parent:CreateTexture(nil, "BORDER")
		point.backdrop:SetDrawLayer("BORDER", -8)
		point.backdrop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*3, noscalemult*3)
		point.backdrop:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*3, -noscalemult*3)
		point.backdrop:SetTexture(0, 0, 0, 1)

		point.bordertop = parent:CreateTexture(nil, "BORDER")
		point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.bordertop:SetHeight(noscalemult)
		point.bordertop:SetTexture(unpack(E["media"].bordercolor))	
		point.bordertop:SetDrawLayer("BORDER", -7)
		
		point.borderbottom = parent:CreateTexture(nil, "BORDER")
		point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult*2, -noscalemult*2)
		point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult*2, -noscalemult*2)
		point.borderbottom:SetHeight(noscalemult)
		point.borderbottom:SetTexture(unpack(E["media"].bordercolor))	
		point.borderbottom:SetDrawLayer("BORDER", -7)
		
		point.borderleft = parent:CreateTexture(nil, "BORDER")
		point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult*2, noscalemult*2)
		point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult*2, -noscalemult*2)
		point.borderleft:SetWidth(noscalemult)
		point.borderleft:SetTexture(unpack(E["media"].bordercolor))	
		point.borderleft:SetDrawLayer("BORDER", -7)
		
		point.borderright = parent:CreateTexture(nil, "BORDER")
		point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult*2, noscalemult*2)
		point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult*2, -noscalemult*2)
		point.borderright:SetWidth(noscalemult)
		point.borderright:SetTexture(unpack(E["media"].bordercolor))	
		point.borderright:SetDrawLayer("BORDER", -7)
	end
end

function NP:SetVirtualBorder(parent, r, g, b)
	parent.bordertop:SetTexture(r, g, b)
	parent.borderbottom:SetTexture(r, g, b)
	parent.borderleft:SetTexture(r, g, b)
	parent.borderright:SetTexture(r, g, b)
end

function NP:SetVirtualBackdrop(parent, r, g, b)
	parent.backdrop2:SetTexture(r, g, b)
end

function NP:HideObjects(frame)
	local objectType
	for object in pairs(frame.queue) do		
		objectType = object:GetObjectType()  
		if objectType == "Texture" then
			object.OldTexture = object:GetTexture()
			object:SetTexture("")
			object:SetTexCoord(0, 0, 0, 0)
		elseif objectType == 'FontString' then
			object:SetWidth(0.001)
		elseif objectType == 'StatusBar' then
			object:SetStatusBarTexture("")
		else
			object:Hide()
		end
	end
end

function NP:Update_LevelText(frame)
	local region = select(4, frame:GetRegions())
	if region and region:GetObjectType() == 'FontString' then
		frame.hp.oldlevel = select(4, frame:GetRegions())
	end

	if frame.hp.oldlevel:IsShown() then
		if self.db.showlevel == true then
			local level, elite, boss, mylevel = frame.hp.oldlevel:GetObjectType() == 'FontString' and tonumber(frame.hp.oldlevel:GetText()) or nil, frame.isElite, frame.isBoss, UnitLevel("player")
			if boss then
				frame.hp.level:SetText("??")
				frame.hp.level:SetTextColor(0.8, 0.05, 0)
				frame.hp.level:Show()
			elseif not elite and level == mylevel then
				frame.hp.level:Hide()
				frame.hp.level:SetText(nil)
			elseif level then
				frame.hp.level:SetText(level..(elite and "+" or ""))
				frame.hp.level:SetTextColor(frame.hp.oldlevel:GetTextColor())
				frame.hp.level:Show()
			end
			
			frame.hp.oldlevel:SetWidth(000.1)
		elseif frame.hp.level then
			frame.hp.level:Hide()
			frame.hp.level:SetText(nil)
		end
	elseif frame.isBoss and self.db.showlevel and frame.hp.level:GetText() ~= '??' then
		frame.hp.level:SetText("??")
		frame.hp.level:SetTextColor(0.8, 0.05, 0)
		frame.hp.level:Show()
	end
end

function NP:RoundColors(r, g, b)	
	return floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100
end

function NP:Colorize(frame, r, g, b)
	frame.hp.originalr, frame.hp.originalg, frame.hp.originalb = r, g, b
	for class, _ in pairs(RAID_CLASS_COLORS) do
		local bb = b
		if class == 'MONK' then
			bb = bb - 0.01
		end
		
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == bb then
			frame.hasClass = class
			frame.isFriendly = false
			frame.hp:SetStatusBarColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b)
			frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
			return
		end
	end
	--fix this
	frame.isPlayer = nil
	frame.isTagged = nil;
	local color
	
	if (r + b + b) > 2 then -- tapped
		color = self.db.tappedcolor
		r,g,b = color.r, color.g, color.b
		frame.isFriendly = false	
		frame.isTagged = true;
	elseif g+b == 0 then -- hostile
		color = self.db.enemy
		r,g,b = color.r, color.g, color.b
		frame.isFriendly = false
	elseif r+b == 0 then -- friendly npc
		color = self.db.friendlynpc
		r,g,b = color.r, color.g, color.b
		frame.isFriendly = true
	elseif r+g > 1.95 then -- neutral
		color = self.db.neutral
		r,g,b = color.r, color.g, color.b
		frame.isFriendly = false
	elseif r+g == 0 then -- friendly player
		color = self.db.friendlyplayer
		r,g,b = color.r, color.g, color.b
		frame.isFriendly = true
	else -- enemy player
		frame.isFriendly = false
	end
	
	frame.hasClass = nil
	frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor = r, g, b
	frame.hp:SetStatusBarColor(r,g,b)
end

function NP:UpdateColoring(frame)
	local r, g, b = NP:RoundColors(frame.oldhp:GetStatusBarColor())
	
	if (r ~= frame.hp.originalr or g ~= frame.hp.originalg or b ~= frame.hp.originalb) then
		NP:Colorize(frame, r, g, b)
	end
end

function NP:HealthBar_OnShow()
	local frame = self:GetParent()
	
	local noscalemult = E.mult * UIParent:GetScale()
	--Have to reposition this here so it doesnt resize after being hidden
	frame.hp:ClearAllPoints()
	frame.hp:Size(NP.db.width, NP.db.height)	
	frame.hp:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 5)
	frame.hp:GetStatusBarTexture():SetHorizTile(true)
	frame.hp.name:SetWidth(frame.hp:GetWidth())

	NP.HealthBar_ValueChanged(frame.oldhp, frame.oldhp:GetValue())
	
	if not E.PixelMode and frame.hp.backdrop then
		frame.hp.backdrop:SetPoint('TOPLEFT', -noscalemult*3, noscalemult*3)
		frame.hp.backdrop:SetPoint('BOTTOMRIGHT', noscalemult*3, -noscalemult*3)	
	end
	
	local r, g, b = NP:RoundColors(frame.oldhp:GetStatusBarColor())
	NP:Colorize(frame, r, g, b)
	frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, 0.25)
	
	
	if frame.hasClass and NP.db.classIcons then
		local tCoords = CLASS_BUTTONS[frame.hasClass]
		frame.classIcon:SetTexCoord(tCoords[1], tCoords[2], tCoords[3], tCoords[4])
		frame.classIcon:Show()
	elseif frame.classIcon:IsShown() then
		frame.classIcon:Hide()
	end
	
	--Set the name text
	frame.hp.name:SetText(frame.hp.oldname:GetText())
	local isSmallNP
	if frame.hp:GetEffectiveScale() < 1 then
		frame.hp:SetScale(2.5 / frame.hp:GetScale())
 		isSmallNP = true;
 	end
	
	frame.isSmallNP = isSmallNP and NP.db.smallPlates
	
	if frame.isSmallNP then
		frame.hp:Width(frame:GetWidth() * frame:GetEffectiveScale())
	end
	
	frame.AuraWidget:SetScale(frame.hp:GetScale())
	
	NP.ScanHealth(frame.oldhp, frame.oldhp:GetValue())
	NP:CheckFilter(frame)
	
	frame.isBoss = frame.hp.boss:IsShown()
	frame.isElite = frame.hp.elite:IsShown()
	NP:Update_LevelText(frame)
	
	NP:HideObjects(frame)
end

function NP:HealthBar_ValueChanged(curValue)
	local frame = self:GetParent()
	frame.hp:SetMinMaxValues(frame.oldhp:GetMinMaxValues())
	frame.hp:SetValue(curValue)
	NP.ScanHealth(frame.oldhp, curValue)
end

function NP:OnHide()
	local frame = self
	frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	frame.hp.name:SetTextColor(1, 1, 1)
	frame.hp:SetScale(1)
	frame.cb:SetScale(1)
	frame.classIcon:Hide()
	frame.AuraWidget:SetScale(1)
	frame.cb:Hide()
	frame.isBoss = nil
	frame.isElite = nil
	frame.unit = nil
	frame.isMarked = nil
	frame.isSmallNP = nil
	frame.raidIconType = nil
	frame.threatStatus = nil
	frame.guid = nil
	frame.hasClass = nil
	frame.customColor = nil
	frame.customScale = nil
	frame.isFriendly = nil
	frame.hp.rcolor = nil
	frame.hp.gcolor = nil
	frame.hp.bcolor = nil
	frame.hp.originalr = nil
	frame.hp.originalg = nil
	frame.hp.originalb = nil
	frame.isTagged = nil
	frame.isBeingTanked = nil
	frame.hp.shadow:SetAlpha(0)
	NP:SetVirtualBackdrop(frame.hp, unpack(E["media"].backdropcolor))
	NP:SetVirtualBorder(frame.hp, unpack(E["media"].bordercolor))
	if frame.icons then
		for _,icon in ipairs(frame.icons) do
			icon:Hide()
		end
	end

	for i=1, MAX_COMBO_POINTS do
		frame.cpoints[i]:Hide()
	end
end

local good, bad, transition, offtank, transition2, combat, goodscale, badscale
function NP:UpdateThreat(frame)
	if frame.hasClass or frame.isTagged then return end
	combat = InCombatLockdown()
	good = self.db.goodcolor
	bad = self.db.badcolor
	offtank = self.db.offtankcolor
	goodscale = self.db.goodscale
	badscale = self.db.badscale
	transition = self.db.goodtransitioncolor
	transition2 = self.db.badtransitioncolor

	local bgMult = self.db.bgMult
	if self.db.enhancethreat ~= true then
		if(frame.threat:IsShown()) then
			local _, val = frame.threat:GetVertexColor()
			if(val > 0.7) then
				self:SetVirtualBorder(frame.hp, transition.r, transition.g, transition.b)
				if not frame.customScale and (goodscale ~= 1 or badscale ~= 1) then
					frame.hp:Height(self.db.height)
					frame.hp:Width(self.db.width)
				end					
			else
				self:SetVirtualBorder(frame.hp, bad.r, bad.g, bad.b)
				if not frame.customScale and badscale ~= 1 then
					frame.hp:Height(self.db.height * badscale)
					frame.hp:Width(self.db.width * badscale)
				end						
			end
		else
			self:SetVirtualBorder(frame.hp, unpack(E["media"].bordercolor))
			if not frame.customScale and goodscale ~= 1 then
				frame.hp:Height(self.db.height * goodscale)
				frame.hp:Width(self.db.width * goodscale)
			end								
		end
		frame.hp.name:SetTextColor(1, 1, 1)
	else
		if not frame.threat:IsShown() then
			if combat and frame.isFriendly ~= true then
				--No Threat
				if E.role == "Tank" then
					if not frame.customColor then
						if frame.isBeingTanked and self.db.offtank then
							frame.hp:SetStatusBarColor(offtank.r, offtank.g, offtank.b)
							frame.hp.hpbg:SetTexture(offtank.r, offtank.g, offtank.b, bgMult)						
						else
							frame.hp:SetStatusBarColor(bad.r, bad.g, bad.b)
							frame.hp.hpbg:SetTexture(bad.r, bad.g, bad.b, bgMult)
						end
					end

					if not frame.customScale and badscale ~= 1 then
						frame.hp:Height(self.db.height * badscale)
						frame.hp:Width(self.db.width * badscale)
					end								
					frame.threatStatus = "BAD"
				else
					if not frame.customColor then
						if (not frame.isBeingTanked) and self.db.offtank and self.displayLooseMobs then
							frame.hp:SetStatusBarColor(offtank.r, offtank.g, offtank.b)
							frame.hp.hpbg:SetTexture(offtank.r, offtank.g, offtank.b, bgMult)						
						else					
							frame.hp:SetStatusBarColor(good.r, good.g, good.b)
							frame.hp.hpbg:SetTexture(good.r, good.g, good.b, bgMult)
						end
					end
					
					if not frame.customScale and goodscale ~= 1 then
						frame.hp:Height(self.db.height * goodscale)
						frame.hp:Width(self.db.width * goodscale)
					end					
					frame.threatStatus = "GOOD"
				end		
			else
				--Set colors to their original, not in combat
				if not frame.customColor then
					if frame.isBeingTanked and self.db.offtank then
						frame.hp:SetStatusBarColor(offtank.r, offtank.g, offtank.b)
						frame.hp.hpbg:SetTexture(offtank.r, offtank.g, offtank.b, bgMult)	
					else
						frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
						frame.hp.hpbg:SetTexture(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor, bgMult)
					end
				end
				
				if not frame.customScale and (goodscale ~= 1 or badscale ~= 1) then
					frame.hp:Height(self.db.height)
					frame.hp:Width(self.db.width)
				end			
				frame.threatStatus = nil
			end
		else
			--Ok we either have threat or we're losing/gaining it
			local r, g, b = frame.threat:GetVertexColor()
			if g + b == 0 then
				--Have Threat
				if E.role == "Tank" then
					if not frame.customColor then
						frame.hp:SetStatusBarColor(good.r, good.g, good.b)
						frame.hp.hpbg:SetTexture(good.r, good.g, good.b, bgMult)
					end
					
					if not frame.customScale and goodscale ~= 1 then
						frame.hp:Height(self.db.height * goodscale)
						frame.hp:Width(self.db.width * goodscale)
					end
					
					frame.threatStatus = "GOOD"
				else
					if not frame.customColor then
						frame.hp:SetStatusBarColor(bad.r, bad.g, bad.b)
						frame.hp.hpbg:SetTexture(bad.r, bad.g, bad.b, bgMult)
					end
					
					if not frame.customScale and badscale ~= 1 then
						frame.hp:Height(self.db.height * badscale)
						frame.hp:Width(self.db.width * badscale)
					end					
					frame.threatStatus = "BAD"
				end
			else
				--Losing/Gaining Threat
				
				if not frame.customScale and (goodscale ~= 1 or badscale ~= 1) then
					frame.hp:Height(self.db.height)
					frame.hp:Width(self.db.width)
				end	
				
				if E.role == "Tank" then
					if frame.threatStatus == "GOOD" then
						--Losing Threat
						if not frame.customColor then
							frame.hp:SetStatusBarColor(transition2.r, transition2.g, transition2.b)	
							frame.hp.hpbg:SetTexture(transition2.r, transition2.g, transition2.b, bgMult)
						end
					else
						--Gaining Threat
						if not frame.customColor then
							frame.hp:SetStatusBarColor(transition.r, transition.g, transition.b)	
							frame.hp.hpbg:SetTexture(transition.r, transition.g, transition.b, bgMult)
						end
					end
				else
					if frame.threatStatus == "GOOD" then
						--Losing Threat
						if not frame.customColor then
							frame.hp:SetStatusBarColor(transition.r, transition.g, transition.b)	
							frame.hp.hpbg:SetTexture(transition.r, transition.g, transition.b, bgMult)
						end
					else
						--Gaining Threat
						if not frame.customColor then
							frame.hp:SetStatusBarColor(transition2.r, transition2.g, transition2.b)	
							frame.hp.hpbg:SetTexture(transition2.r, transition2.g, transition2.b, bgMult)
						end
					end				
				end
			end
		end
		
		if combat then
			frame.hp.name:SetTextColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
		else
			frame.hp.name:SetTextColor(1, 1, 1)
		end
	end
end

function NP:ScanHealth(valueHealth)
	-- show current health value
	local frame = self:GetParent()
	local minHealth, maxHealth = frame.oldhp:GetMinMaxValues()
	local d =(valueHealth/maxHealth)*100
	
	if NP.db.healthtext ~= '' and valueHealth and maxHealth and maxHealth > 1 and not frame.isSmallNP then
		frame.hp.value:Show()
		frame.hp.value:SetText(E:GetFormattedText(NP.db.healthtext, valueHealth, maxHealth))
	else
		frame.hp.value:Hide()
	end
			
	--Setup frame shadow to change depending on enemy players health, also setup targetted unit to have white shadow
	if (NP.db.lowHealthWarning == 'PLAYERS' and frame.hasClass == true or frame.isFriendly == true) or NP.db.lowHealthWarning == 'ALL' then
		local threshold = NP.db.lowHealthWarningThreshold * 100
		if(d <= threshold and d >= (threshold / 2)) then
			NP:SetVirtualBorder(frame.hp, 1, 1, 0)
		elseif(d < (threshold / 2)) then
			NP:SetVirtualBorder(frame.hp, 1, 0, 0)
		else
			NP:SetVirtualBorder(frame.hp, unpack(E["media"].bordercolor))
		end
	elseif (frame.hasClass ~= true and frame.isFriendly ~= true) or NP.db.lowHealthWarning == 'ALL' then
		NP:SetVirtualBorder(frame.hp, unpack(E["media"].bordercolor))
	end
end

function NP:GetTargetNameplate()
	if not UnitExists("target") then return end
	
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame.guid == UnitGUID("target") then
			return frame
		end
	end
end

--Scan all visible nameplate for a known unit.
function NP:CheckUnit_Guid(frame, ...)
	if UnitExists("target") and frame:GetParent():GetAlpha() == 1 and UnitName("target") == frame.hp.name:GetText() then
		frame.guid = UnitGUID("target")
		frame.unit = "target"
		NP:UpdateAurasByUnitID("target")
		frame.hp.shadow:SetAlpha(1)
		
		if self.db.comboPoints then
			NP:UpdateCPoints(frame)
		end
	elseif frame.overlay:IsShown() and UnitExists("mouseover") and UnitName("mouseover") == frame.hp.name:GetText() then
		frame.guid = UnitGUID("mouseover")
		frame.unit = "mouseover"
		NP:UpdateAurasByUnitID("mouseover")
		frame.hp.shadow:SetAlpha(0)
		
		if self.db.comboPoints then
			local cpoints = GetComboPoints('player', 'mouseover')
			if cpoints and cpoints > 0 then
				NP:UpdateCPoints(frame, true)
			end
		end
	else
		frame.unit = nil
		frame.hp.shadow:SetAlpha(0)
	end	

	--[[if not frame.test then
		frame.test = frame:CreateFontString(nil, 'OVERLAY')
		frame.test:Point('TOP', frame, 'TOP')
		frame.test:FontTemplate()
		
	end
	frame.test:SetText(frame.guid)]]
end

function NP:TogglePlate(frame, hide)
	if hide == true then
		frame.hp:Hide()
		frame.cb:Hide()
		frame.hp.oldlevel:Hide()	
	else
		frame.hp:Show()
	end
end

--Create our blacklist for nameplates, so prevent a certain nameplate from ever showing
function NP:CheckFilter(frame, ...)
	local name = frame.hp.oldname:GetText()
	local db = E.global.nameplate["filter"][name]

	if db and db.enable then
		if db.hide then
			self:TogglePlate(frame, true)
		else
			self:TogglePlate(frame, false)
			
			if db.customColor then
				frame.customColor = db.customColor
				frame.hp.hpbg:SetTexture(db.color.r, db.color.g, db.color.b, 0.25)
				frame.hp:SetStatusBarColor(db.color.r, db.color.g, db.color.b)
			else
				frame.customColor = nil	
			end
			
			if db.customScale and db.customScale ~= 1 then
				frame.hp:Height(self.db.height * db.customScale)
				frame.hp:Width(self.db.width * db.customScale)
				frame.customScale = db.customScale
			else
				frame.customScale = nil
			end
		end
	else
		self:TogglePlate(frame, false)
	end
	
	--Check For Healers
	if self.Healers[name] then
		frame.healerIcon:Show()
	else
		frame.healerIcon:Hide()
	end
end

function NP:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i);
		if name then
			name = name:match("(.+)%-.+") or name
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil;
			end
		end
	end
end

function NP:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then return end
	
	for i=1, 5 do
		local name = UnitName(format('arena%d', i))
		if name and name ~= UNKNOWN then
			local s = GetArenaOpponentSpec(i)
			local _, talentSpec = nil, UNKNOWN
			if s and s > 0 then
				_, talentSpec = GetSpecializationInfoByID(s)
			end
			
			if talentSpec and talentSpec ~= UNKNOWN and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			end
		end
	end
end

do
	local PolledHideIn
	local Framelist = {}			-- Key = Frame, Value = Expiration Time
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0
	
	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + 1
		-- Cycle through the watchlist, hiding frames which are timed-out
		for frame, expiration in pairs(Framelist) do
			-- If expired...
			if expiration < curTime then frame:Hide(); Framelist[frame] = nil
			-- If active...
			else 
				-- Update the frame
				if frame.Poll then frame.Poll(NP, frame, expiration) end
				framecount = framecount + 1 
			end
		end
		-- If no more frames to watch, unregister the OnUpdate script
		if framecount == 0 then Watcherframe:SetScript("OnUpdate", nil); WatcherframeActive = false end
	end
	
	function PolledHideIn(frame, expiration)
	
		if expiration == 0 then 
			
			frame:Hide()
			Framelist[frame] = nil
		else
			Framelist[frame] = expiration
			frame:Show()
			
			if not WatcherframeActive then 
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end
	
	NP.PolledHideIn = PolledHideIn
end

function NP:CreateAuraIcon(parent)
	local noscalemult = E.mult * UIParent:GetScale()
	local button = CreateFrame("Frame",nil,parent)
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetScript('OnHide', function()
		if parent.guid then
			NP:UpdateIconGrid(parent, parent.guid)
		end
	end)
	
	if E.PixelMode then
		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
		
		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)		
	else
		button.bg = button:CreateTexture(nil, "BACKGROUND")
		button.bg:SetTexture(0, 0, 0, 1)
		button.bg:SetAllPoints(button)
		
		button.bord = button:CreateTexture(nil, "BACKGROUND")
		button.bord:SetDrawLayer('BACKGROUND', 2)
		button.bord:SetTexture(unpack(E["media"].bordercolor))
		button.bord:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult,-noscalemult)
		button.bord:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult,noscalemult)
		
		button.bg2 = button:CreateTexture(nil, "BACKGROUND")
		button.bg2:SetDrawLayer('BACKGROUND', 3)
		button.bg2:SetTexture(0, 0, 0, 1)
		button.bg2:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*2,-noscalemult*2)
		button.bg2:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*2,noscalemult*2)	

		button.Icon = button:CreateTexture(nil, "BORDER")
		button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT", noscalemult*3,-noscalemult*3)
		button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-noscalemult*3,noscalemult*3)
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)		
	end
	
	button.TimeLeft = button:CreateFontString(nil, 'OVERLAY')
	button.TimeLeft:Point('CENTER', 1, 1)
	button.TimeLeft:SetJustifyH('CENTER')	
	button.TimeLeft:SetShadowColor(0, 0, 0, 0)
	
	button.Stacks = button:CreateFontString(nil,"OVERLAY")
	button.Stacks:SetShadowColor(0, 0, 0, 0)
	button.Stacks:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
	
	button.AuraInfo = {	
		Name = "",
		Icon = "",
		Stacks = 0,
		Expiration = 0,
		Type = "",
	}			

	button.Poll = parent.PollFunction
	button:Hide()
	
	return button
end

function NP:UpdateAuraTime(frame, expiration)
	local timeleft = expiration-GetTime()
	local timervalue, formatid = E:GetTimeInfo(timeleft, 4)	
	frame.TimeLeft:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], E.TimeFormats[3][2]), timervalue)	
end

function NP:ClearAuraContext(frame)
	if frame.guidcache then 
		AuraGUID[frame.guidcache] = nil 
		frame.unit = nil
	end
	AuraList[frame] = nil
end

function NP:UpdateAuraContext(frame)
	local parent = frame:GetParent()
	local guid = parent.guid
	frame.unit = parent.unit
	frame.guidcache = guid
	
	AuraList[frame] = true
	if guid then AuraGUID[guid] = frame end
	
	if parent.isTarget then UpdateAurasByUnitID("target")
	elseif parent.isMouseover then UpdateAurasByUnitID("mouseover") end
	
	local raidicon, name
	if parent.isMarked then
		raidicon = parent.raidIconType
		if guid and raidicon then ByRaidIcon[raidicon] = guid end
	end
	
	
	local frame = NP:SearchForFrame(guid, raidicon, parent.hp.name:GetText())
	if frame then
		NP:UpdateAuras(frame)
	end
end

function NP:UpdateAuraTarget()
	NP:UpdateIconGrid(self, UnitGUID("target"))
end

function NP:CheckRaidIcon(frame)
	frame.isMarked = frame.raidicon:IsShown() or false
	
	if frame.isMarked then
		local ux, uy = frame.raidicon:GetTexCoord()
		frame.raidIconType = NP.RaidIconCoordinate[ux][uy]	
	else
		frame.isMarked = nil;
		frame.raidIconType = nil;
	end
end

function NP:SearchNameplateByGUID(guid)
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.guid == guid then
			return frame
		end
	end
end

function NP:SearchNameplateByName(sourceName)
	if not sourceName then return; end
	local SearchFor = strsplit("-", sourceName)
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.hp.name:GetText() == SearchFor and frame.hasClass then
			return frame
		end
	end
end

function NP:SearchNameplateByIcon(UnitFlags)
	local UnitIcon
	for iconname, bitmask in pairs(NP.RaidTargetReference) do
		if band(UnitFlags, bitmask) > 0  then
			UnitIcon = iconname
			break
		end
	end	

	return NP:SearchNameplateByIconName(UnitIcon)
end

function NP:SearchNameplateByIconName(raidicon)
	local frame
	for frame, _ in pairs(NP.Handled) do
		frame = _G[frame]:GetChildren()
		if frame and frame:IsShown() and frame.isMarked and (frame.raidIconType == raidIcon) then
			return frame
		end
	end		
end

function NP:SearchForFrame(guid, raidicon, name)
	local frame

	if guid then frame = self:SearchNameplateByGUID(guid) end
	if (not frame) and name then frame = self:SearchNameplateByName(name) end
	if (not frame) and raidicon then frame = self:SearchNameplateByIconName(raidicon) end
	
	return frame
end

function NP:SetAuraInstance(guid, spellid, expiration, stacks, caster, duration, texture, auratype, auratarget)
	local filter = false
	if (self.db.trackauras and caster == UnitGUID('player')) then
		filter = true;
	end
	
	local trackFilter = E.global['unitframe']['aurafilters'][self.db.trackfilter]
	if self.db.trackfilter and #self.db.trackfilter > 1 and trackFilter then
		local name = GetSpellInfo(spellid)
		local spellList = trackFilter.spells
		local type = trackFilter.type
		if type == 'Blacklist' then
			if spellList[name] and spellList[name].enable then
				filter = false;
			end
		else
			if spellList[name] and spellList[name].enable then
				filter = true;
			end
		end
	end
	
	if E.global.unitframe.InvalidSpells[spellid] then
		filter = false;
	end

	if filter ~= true then
		return;
	end

	if guid and spellid and caster and texture then
		local aura_id = spellid..(tostring(caster or "UNKNOWN_CASTER"))
		local aura_instance_id = guid..aura_id
		NP.Aura_List[guid] = NP.Aura_List[guid] or {}
		NP.Aura_List[guid][aura_id] = aura_instance_id
		NP.Aura_Spellid[aura_instance_id] = spellid
		NP.Aura_Expiration[aura_instance_id] = expiration
		NP.Aura_Stacks[aura_instance_id] = stacks
		NP.Aura_Caster[aura_instance_id] = caster
		NP.Aura_Duration[aura_instance_id] = duration
		NP.Aura_Texture[aura_instance_id] = texture
		NP.Aura_Type[aura_instance_id] = auratype
		NP.Aura_Target[aura_instance_id] = auratarget
	end
end

function NP:RemoveAuraInstance(guid, spellid)
	if guid and spellid and NP.Aura_List[guid] then
		local aura_instance_id = tostring(guid)..tostring(spellid)..(tostring(caster or "UNKNOWN_CASTER"))
		local aura_id = spellid..(tostring(caster or "UNKNOWN_CASTER"))
		if NP.Aura_List[guid][aura_id] then
			NP.Aura_Spellid[aura_instance_id] = nil
			NP.Aura_Expiration[aura_instance_id] = nil
			NP.Aura_Stacks[aura_instance_id] = nil
			NP.Aura_Caster[aura_instance_id] = nil
			NP.Aura_Duration[aura_instance_id] = nil
			NP.Aura_Texture[aura_instance_id] = nil
			NP.Aura_Type[aura_instance_id] = nil
			NP.Aura_Target[aura_instance_id] = nil
			NP.Aura_List[guid][aura_id] = nil
		end
	end
end

function NP:UpdateAuraByLookup(guid)
 	if guid == UnitGUID("target") then
		NP:UpdateAurasByUnitID("target")
	elseif guid == UnitGUID("mouseover") then
		NP:UpdateAurasByUnitID("mouseover")
	elseif self.TargetOfGroupMembers[guid] then
		local unit = self.TargetOfGroupMembers[guid]
		if unit then
			local unittarget = UnitGUID(unit.."target")
			if guid == unittarget then
				NP:UpdateAurasByUnitID(unittarget)
			end
		end		
	end
end

function NP:UpdateIsBeingTanked(frame)
	local guid = frame.guid
	if not guid then return end
	
	local unit = self.TargetOfGroupMembers[guid]
 	if unit then
		local targetUnit = unit.."target"
		if UnitExists(targetUnit) then
			local isTankGUID = self.GroupTanks[UnitGUID(targetUnit)]
			local isTanking = UnitDetailedThreatSituation(targetUnit, unit)

			if isTankGUID and isTanking then
				frame.isBeingTanked = true
			elseif not isTankGUID and isTanking then
				frame.isBeingTanked = nil
			end
		end
	end
end

function NP:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, ...)
	local _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellid, spellName, _, auraType, stackCount  = ...

	if band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then 
		if band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
			--	destination plate, by name
			FoundPlate = NP:SearchNameplateByName(sourceName)
		elseif band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then 
			--	destination plate, by raid icon
			FoundPlate = NP:SearchNameplateByIcon(sourceRaidFlags) 
		else 
			return	
		end
	else 
		return 
	end	

	if FoundPlate and FoundPlate:IsShown() and FoundPlate.unit ~= "target" then 
		FoundPlate.guid = sourceGUID
	end		

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
		local duration = NP:GetSpellDuration(spellid)
		local texture = GetSpellTexture(spellid)
				
		NP:SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), 1, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
	elseif event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" then
		local duration = NP:GetSpellDuration(spellid)
		local texture = GetSpellTexture(spellid)
		NP:SetAuraInstance(destGUID, spellid, GetTime() + (duration or 0), stackCount, sourceGUID, duration, texture, AURA_TYPE_DEBUFF, AURA_TARGET_HOSTILE)
	elseif event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then
		NP:RemoveAuraInstance(destGUID, spellid)
	end

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" or event == "SPELL_AURA_REMOVED" then	
		NP:UpdateAuraByLookup(destGUID)
		local name, raidicon
		-- Cache Unit Name for alternative lookup strategy
		if band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and destName then 
			local rawName = strsplit("-", destName)			-- Strip server name from players
			NP.ByName[rawName] = destGUID
			name = rawName
		end
		-- Cache Raid Icon Data for alternative lookup strategy
		for iconname, bitmask in pairs(NP.RaidTargetReference) do
			if band(destRaidFlags, bitmask) > 0  then
				NP.ByRaidIcon[iconname] = destGUID
				raidicon = iconname
				break
			end
		end

		local frame = self:SearchForFrame(destGUID, raidicon, name)	
		if frame then
			NP:UpdateAuras(frame)
		end				
	end		
end

function NP:PLAYER_REGEN_ENABLED()
	if self.db.combat then
		SetCVar("nameplateShowEnemies", 0)
	end
	
	self:CleanAuraLists()
end

function NP:PLAYER_REGEN_DISABLED()
	if self.db.combat then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function NP:CleanAuraLists()	
	local currentTime = GetTime()
	for guid, instance_list in pairs(NP.Aura_List) do
		local auracount = 0
		for aura_id, aura_instance_id in pairs(instance_list) do
			local expiration = NP.Aura_Expiration[aura_instance_id]
			if expiration and expiration < currentTime then
				NP.Aura_List[guid][aura_id] = nil
				NP.Aura_Spellid[aura_instance_id] = nil
				NP.Aura_Expiration[aura_instance_id] = nil
				NP.Aura_Stacks[aura_instance_id] = nil
				NP.Aura_Caster[aura_instance_id] = nil
				NP.Aura_Duration[aura_instance_id] = nil
				NP.Aura_Texture[aura_instance_id] = nil
				NP.Aura_Type[aura_instance_id] = nil
				NP.Aura_Target[aura_instance_id] = nil
				auracount = auracount + 1
			end
		end
		if auracount == 0 then
			NP.Aura_List[guid] = nil
		end
	end
end

function NP:AddToRoster(unitId)
	local unitName = UnitName(unitId)

	if unitName then
		local _, unitClass = UnitClass(unitId)
		local guid = UnitGUID(unitId)
		self.GroupMembers[unitName] = unitId
		
		if ((UnitGroupRolesAssigned(unitId) == 'TANK') or GetPartyAssignment("MAINTANK", unitId)) and self.TankClasses[unitClass] then
			self.GroupTanks[guid] = true
		end		
	end
end

function NP:UpdateRoster()
	local groupType, groupSize, unitId, unitName
	wipe(self.GroupMembers)
	wipe(self.GroupTanks)	
	
	local petExists = UnitExists('pet')
	local inGroup = IsInGroup()
	if IsInRaid() then 
		groupType = "raid"
		groupSize = GetNumGroupMembers()
	elseif inGroup then 
		groupType = "party"
		groupSize = GetNumGroupMembers() - 1
	else 
		groupType = "solo"
		groupSize = 1
	end

	-- Cycle through Group
	if groupType then
		for index = 1, groupSize do
			self:AddToRoster(groupType..index)
		end
	end
	
	if petExists then
		self:AddToRoster('pet')
		
		if groupType ~= "raid" then
			self.GroupTanks[UnitGUID('pet')] = true
		end
	end
	
	if groupType == 'party' then
		self:AddToRoster('player')
	end
	
	local _, instanceType = IsInInstance()
	if (inGroup or petExists) and instanceType ~= 'pvp' and instanceType ~= 'arena' then
		NP.displayLooseMobs = true
	else
		NP.displayLooseMobs = nil
	end	
end


function NP:WipeAuraList(guid)
	if guid and self.Aura_List[guid] then
		local unit_aura_list = self.Aura_List[guid]
		for aura_id, aura_instance_id in pairs(unit_aura_list) do
			self.Aura_Spellid[aura_instance_id] = nil
			self.Aura_Expiration[aura_instance_id] = nil
			self.Aura_Stacks[aura_instance_id] = nil
			self.Aura_Caster[aura_instance_id] = nil
			self.Aura_Duration[aura_instance_id] = nil
			self.Aura_Texture[aura_instance_id] = nil
			self.Aura_Type[aura_instance_id] = nil
			self.Aura_Target[aura_instance_id] = nil
			unit_aura_list[aura_id] = nil
		end
	end
end

function NP:GetSpellDuration(spellid)
	if spellid then return NP.CachedAuraDurations[spellid] end
end

function NP:SetSpellDuration(spellid, duration)
	if spellid then NP.CachedAuraDurations[spellid] = duration end
end

function NP:GetAuraList(guid)
	if guid and self.Aura_List[guid] then return self.Aura_List[guid] end
end

function NP:GetAuraInstance(guid, aura_id)
	if guid and aura_id then
		local aura_instance_id = guid..aura_id
		return self.Aura_Spellid[aura_instance_id], self.Aura_Expiration[aura_instance_id], self.Aura_Stacks[aura_instance_id], self.Aura_Caster[aura_instance_id], self.Aura_Duration[aura_instance_id], self.Aura_Texture[aura_instance_id], self.Aura_Type[aura_instance_id], self.Aura_Target[aura_instance_id]
	end
end

function NP:UpdateIcon(frame, texture, expiration, stacks)

	if frame and texture and expiration then
		-- Icon
		frame.Icon:SetTexture(texture)
		
		-- Stacks
		if stacks > 1 then frame.Stacks:SetText(stacks)
		else frame.Stacks:SetText("") end
		
		-- Expiration
		NP:UpdateAuraTime(frame, expiration)
		frame:Show()
		NP.PolledHideIn(frame, expiration)
	else 
		NP.PolledHideIn(frame, 0)
	end
end

function NP:UpdateIconGrid(frame, guid)
	local widget = frame.AuraWidget 
	local AuraIconFrames = widget.AuraIconFrames
	local AurasOnUnit = self:GetAuraList(guid)
	local AuraSlotIndex = 1
	local instanceid
	
	self.AurasCache = wipe(self.AurasCache)
	local aurasCount = 0
	
	-- Cache displayable debuffs
	if AurasOnUnit then
		widget:Show()
		for instanceid in pairs(AurasOnUnit) do
			
			--for i,v in pairs(aura) do aura[i] = nil end
			local aura = {}
			aura.spellid, aura.expiration, aura.stacks, aura.caster, aura.duration, aura.texture, aura.type, aura.target = self:GetAuraInstance(guid, instanceid)
			if tonumber(aura.spellid) then
				aura.name = GetSpellInfo(tonumber(aura.spellid))
				aura.unit = frame.unit
				-- Get Order/Priority
				if aura.expiration > GetTime() then
					aurasCount = aurasCount + 1
					self.AurasCache[aurasCount] = aura
				end
			end
		end
	end
	
	-- Display Auras
	if aurasCount > 0 then 
		for index = 1,  #self.AurasCache do
			local cachedaura = self.AurasCache[index]
			if cachedaura.spellid and cachedaura.expiration then 
				self:UpdateIcon(AuraIconFrames[AuraSlotIndex], cachedaura.texture, cachedaura.expiration, cachedaura.stacks) 
				AuraSlotIndex = AuraSlotIndex + 1
			end
			if AuraSlotIndex > ((frame.isSmallNP and NP.db.smallPlates) and NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS or NP.MAX_DISPLAYABLE_DEBUFFS) then break end
		end
	end
	
	-- Clear Extra Slots
	for AuraSlotIndex = AuraSlotIndex, ((frame.isSmallNP and NP.db.smallPlates) and NP.MAX_SMALLNP_DISPLAYABLE_DEBUFFS or NP.MAX_DISPLAYABLE_DEBUFFS) do self:UpdateIcon(AuraIconFrames[AuraSlotIndex]) end
	
	self.AurasCache = wipe(self.AurasCache)
end

function NP:UpdateAuras(frame)
	-- Check for ID
	local guid = frame.guid
	
	if not guid then
		-- Attempt to ID widget via Name or Raid Icon
		if frame.hasClass then 
			guid = NP.ByName[frame.hp.name:GetText()]
		elseif frame.isMarked then 
			guid = NP.ByRaidIcon[frame.raidIconType] 
		end
		
		if guid then 
			frame.guid = guid
		else
			frame.AuraWidget:Hide()
			return
		end
	end
	
	self:UpdateIconGrid(frame, guid)
end

function NP:UpdateAurasByUnitID(unit)
	-- Check the units Auras
	local guid = UnitGUID(unit)
	-- Reset Auras for a guid
	self:WipeAuraList(guid)
	
	if NP.db.filterType == 'DEBUFFS' then
		local index = 1
		local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid, _, isBossDebuff = UnitDebuff(unit, index)
		while name do
			NP:SetSpellDuration(spellid, duration)
			NP:SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE[dispelType or "Debuff"], unitType)
			index = index + 1
			name , _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid, _, isBossDebuff = UnitDebuff(unit, index)
		end	
	else
		local index = 1
		local name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellid = UnitBuff(unit, index);
		while name do
			NP:SetSpellDuration(spellid, duration)
			NP:SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture, AURA_TYPE[dispelType or "Buff"], unitType)
			index = index + 1
			name, _, texture, count, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(unit, index);
		end		
	end
	
	local raidicon, name
	if UnitPlayerControlled(unit) then name = UnitName(unit) end
	raidicon = RaidIconIndex[GetRaidTargetIndex(unit) or ""]
	if raidicon then self.ByRaidIcon[raidicon] = guid end
	
	local frame = self:SearchForFrame(guid, raidicon, name)
	if frame then
		NP:UpdateAuras(frame)
	end
end

function NP:UNIT_TARGET(event, unit)	
	self.TargetOfGroupMembers = wipe(self.TargetOfGroupMembers)
	
	for name, unitid in pairs(self.GroupMembers) do
		local targetOf = unitid.."target"
		if UnitExists(targetOf) then
			self.TargetOfGroupMembers[UnitGUID(targetOf)] = targetOf
		end
	end
end

function NP:UPDATE_MOUSEOVER_UNIT()
	if UnitExists("mouseover") then
		self.TargetOfGroupMembers[UnitGUID("mouseover")] = "mouseover"
	end
end

function NP:UNIT_AURA(event, unit)
	if unit == "target" then
		self:UpdateAurasByUnitID("target")
	elseif unit == "focus" then
		self:UpdateAurasByUnitID("focus")
	end
end

function NP:CastBar_OnValueChanged(curValue)
	self.time:SetFormattedText("%.1f ", curValue)
	self:SetSize(self:GetParent().hp:GetWidth(), NP.db.cbheight)

	self:ClearAllPoints()
	self:SetPoint('TOP', self:GetParent().hp, 'BOTTOM', 0, -8)
end

function NP:CastBar_OnShow()
	self:ClearAllPoints()
	self:SetSize(self:GetParent().hp:GetWidth(), NP.db.cbheight)
	self:SetPoint('TOP', self:GetParent().hp, 'BOTTOM', 0, -8)
	self:SetStatusBarTexture(E["media"].normTex)
	self:GetStatusBarTexture():SetHorizTile(true)
	if(self.shield:IsShown()) then
		self:SetStatusBarColor(0.78, 0.25, 0.25, 1)
	else
		self:SetStatusBarColor(1, 208/255, 0)
	end	
	
	if self:GetEffectiveScale() < 1 then
		self:SetScale(2.5 / self:GetScale())
 	end
		
	NP:SetVirtualBorder(self, unpack(E["media"].bordercolor))
	NP:SetVirtualBackdrop(self, unpack(E["media"].backdropcolor))	
	
	self.icon:Size(NP.db.cbheight + self:GetParent().hp:GetHeight() + 8)
	NP:SetVirtualBorder(self.icon, unpack(E["media"].bordercolor))
	NP:SetVirtualBackdrop(self.icon, unpack(E["media"].backdropcolor))		
end

function NP:ToggleCPoints()
	if self.db.comboPoints then
		self:RegisterEvent("UNIT_COMBO_POINTS", "UpdateCPoints")
	else
		self:ForEachPlate(NP.HideCPoints)
		self:UnregisterEvent("UNIT_COMBO_POINTS")
	end
end

function NP:HideCPoints(frame)
	if not frame.cpoints[1]:IsShown() then return end
	for i=1, MAX_COMBO_POINTS do
		frame.cpoints[i]:Hide()
	end
end

function NP:UpdateCPoints(frame, isMouseover)
	local unit = "target"
	if isMouseover == true then
		unit = "mouseover"
	end

	if type(frame) ~= "table" then
		frame = self:GetTargetNameplate()
		if frame then
			self:ForEachPlate(self.HideCPoints)
		end
	end
	
	if not frame then return; end

	local cp
	if(UnitHasVehicleUI'player') then
		cp = GetComboPoints('vehicle', unit)
	else
		cp = GetComboPoints('player', unit)
	end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			frame.cpoints[i]:Show()
			frame.cpoints[i]:SetVertexColor(unpack(NP.ComboColors[cp]))
		else
			frame.cpoints[i]:Hide()
		end
	end
end

function NP:PLAYER_ENTERING_WORLD()	
	if InCombatLockdown() and self.db.combat then 
		SetCVar("nameplateShowEnemies", 1) 
	elseif self.db.combat then
		SetCVar("nameplateShowEnemies", 0)
	end
	
	self:UpdateRoster()
	self:CleanAuraLists()
	
	twipe(self.Healers)
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'pvp' and self.db.markHealers then
		self.CheckHealerTimer = self:ScheduleRepeatingTimer("CheckBGHealers", 3)
		self:CheckBGHealers()
	elseif inInstance and instanceType == 'arena' and self.db.markHealers then
		self:RegisterEvent('UNIT_NAME_UPDATE', 'CheckArenaHealers')
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", 'CheckArenaHealers');
		self:CheckArenaHealers()	
	else
		self:UnregisterEvent('UNIT_NAME_UPDATE')
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		if self.CheckHealerTimer then
			self:CancelTimer(self.CheckHealerTimer)
			self.CheckHealerTimer = nil;
		end
	end
end

E:RegisterModule(NP:GetName())