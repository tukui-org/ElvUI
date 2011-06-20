local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--------------------------------------------------------------------
 -- Call To Arms
--------------------------------------------------------------------

if C["datatext"].calltoarms and C["datatext"].calltoarms > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	Text:SetShadowColor(0, 0, 0, 0.4)
	E.PP(C["datatext"].calltoarms, Text)
	Stat:SetParent(Text:GetParent())
	
	local TANK_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:0:18:22:40|t"
	local HEALER_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:20:38:1:19|t"
	local DPS_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:20:38:22:40|t"	
	
	local function MakeIconString(tank, healer, damage)
		local str = ""
		if tank then 
			str = str..TANK_ICON
		end
		if healer then
			str = str..HEALER_ICON
		end
		if damage then
			str = str..DPS_ICON
		end	
		
		return str
	end

	local function OnEvent(self, event, ...)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true		
		for i=1, GetNumRandomDungeons() do
			local id, name = GetLFGRandomDungeonInfo(i)
			for x = 1,LFG_ROLE_NUM_SHORTAGE_TYPES do
				local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
				if eligible then unavailable = false end
				if eligible and forTank and itemCount > 0 then tankReward = true end
				if eligible and forHealer and itemCount > 0 then healerReward = true end
				if eligible and forDamage and itemCount > 0 then dpsReward = true end				
			end
		end	
		
		if unavailable then
			Text:SetText(QUEUE_TIME_UNAVAILABLE)
		else
			Text:SetText(BATTLEGROUND_HOLIDAY..":"..MakeIconString(tankReward, healerReward, dpsReward))
		end
		
		self:SetAllPoints(Text)
	end

	local function OnEnter(self)
		local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
		GameTooltip:SetOwner(panel, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(BATTLEGROUND_HOLIDAY)
		GameTooltip:AddLine(' ')
		
		local allUnavailable = true
		local numCTA = 0
		for i=1, GetNumRandomDungeons() do
			local id, name = GetLFGRandomDungeonInfo(i)
			local tankReward = false
			local healerReward = false
			local dpsReward = false
			local unavailable = true
			for x=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
				local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
				if eligible then unavailable = false end
				if eligible and forTank and itemCount > 0 then tankReward = true end
				if eligible and forHealer and itemCount > 0 then healerReward = true end
				if eligible and forDamage and itemCount > 0 then dpsReward = true end
			end
			if not unavailable then
				allUnavailable = false
				local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
				if rolesString ~= ""  then 
					GameTooltip:AddDoubleLine(name..":", rolesString, 1, 1, 1)
				end
				if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
			end
		end
		
		if allUnavailable then 
			GameTooltip:AddLine(L.datatext_cta_allunavailable)
		elseif numCTA == 0 then 
			GameTooltip:AddLine(L.datatext_cta_nodungeons) 
		end
		GameTooltip:Show()	
	end
    
	Stat:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	Stat:RegisterEvent("PLAYER_LOGIN")
	Stat:SetScript("OnEvent", OnEvent)
	Stat:SetScript("OnMouseDown", function() ToggleFrame(LFDParentFrame) end)
	Stat:SetScript("OnEnter", OnEnter)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
end