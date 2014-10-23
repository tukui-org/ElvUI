local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AFK = E:NewModule('AFK', 'AceEvent-3.0', 'AceTimer-3.0');

local CAMERA_SPEED = 0.035
local format = string.format

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime
	self.AFKMode.bottom.time:SetText(format("%02d:%02d", floor(time/60), time % 60))
end

function AFK:SetAFK(status)
	if(InCombatLockdown()) then return end
	if(status) then
		--SaveView(5);
		MoveViewLeftStart(CAMERA_SPEED);
		self.AFKMode:Show()
		UIParent:Hide()

		if(IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player");
			self.AFKMode.bottom.guild:SetText(guildName.."-"..guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L["No Guild"])
		end

		self.AFKMode.bottom.model.curAnimation = "wave"
		self.AFKMode.bottom.model.startTime = GetTime()
		self.AFKMode.bottom.model.duration = 2.3
		self.AFKMode.bottom.model:SetUnit("player")
		self.AFKMode.bottom.model.isIdle = nil
		self.AFKMode.bottom.model:SetAnimation(67)
		self.AFKMode.bottom.model.idleDuration = 40
		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer('UpdateTimer', 1)

		self.isAFK = true
	elseif(self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		MoveViewLeftStop();
		--ResetView(5);
		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self.AFKMode.bottom.time:SetText("00:00")

		if(PVEFrame:IsShown()) then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		self.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if(event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if(event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...);
			if ( status == "confirm" ) then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end

		if(event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end

	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if(UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end


function AFK:Toggle()
	if(E.db.general.afk) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("LFG_PROPOSAL_SHOW")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	end
end

local function OnKeyDown(self, key)
	if(key == 'LALT') then return end
	AFK:SetAFK(false)
	AFK:ScheduleTimer('OnEvent', 60)
end

function AFK:LoopAnimations()
	if(ElvUIAFKPlayerModel.curAnimation == "wave") then
		ElvUIAFKPlayerModel:SetAnimation(69)
		ElvUIAFKPlayerModel.curAnimation = "dance"
		ElvUIAFKPlayerModel.startTime = GetTime()
		ElvUIAFKPlayerModel.duration = 300
		ElvUIAFKPlayerModel.isIdle = false
		ElvUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	local classColor = RAID_CLASS_COLORS[E.myclass]

	self.AFKMode = CreateFrame("Frame", "ElvUIAFKFrame")
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -2)
	self.AFKMode.bottom:SetWidth(GetScreenWidth())
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	self.AFKMode.bottom.logo = self.AFKMode.bottom:CreateTexture(nil, 'OVERLAY')
	self.AFKMode.bottom.logo:SetSize(320, 150)
	self.AFKMode.bottom.logo:SetPoint("CENTER", self.AFKMode.bottom, "CENTER", 0, 50)
	self.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\logo.tga")

	local factionGroup = UnitFactionGroup("player");
	--factionGroup = "Alliance"
	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, 'OVERLAY')
	self.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", -20, -16)
	self.AFKMode.bottom.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
	self.AFKMode.bottom.faction:SetSize(140, 140)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.name:FontTemplate(nil, 20)
	self.AFKMode.bottom.name:SetText(E.myname.."-"..E.myrealm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", -10, -28)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.guild:FontTemplate(nil, 20)
	self.AFKMode.bottom.guild:SetText(L["No Guild"])
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, 'OVERLAY')
	self.AFKMode.bottom.time:FontTemplate(nil, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "ElvUIAFKPlayerModel", self.AFKMode.bottom)
	self.AFKMode.bottom.model:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", 120, -100)
	self.AFKMode.bottom.model:SetSize(800, 800)
	self.AFKMode.bottom.model:SetCamDistanceScale(1.15)
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdateModel", function(self) 
		local timePassed = GetTime() - self.startTime
		if(timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)

	self:Toggle()
	self.isActive = false	
end


E:RegisterModule(AFK:GetName())