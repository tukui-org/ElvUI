--[[
Author: Affli@RU-Howling Fjord, 
Modified: Elv
All rights reserved.
]]--
local E, C, L, DB = unpack(select(2, ...))

if not C["skin"].dbm == true or not IsAddOnLoaded("DBM-Core") then return end

local croprwicons = true			-- crops blizz shitty borders from icons in RaidWarning messages
local rwiconsize = 18			-- RaidWarning icon size, because 12 is small for me. Works only if croprwicons=true
local buttonsize = 22

local function SkinBars(self)
	for bar in self:GetBarIterator() do
		if not bar.injected then
				bar.ApplyStyle=function()
				local frame = bar.frame
				local tbar = _G[frame:GetName().."Bar"]
				local spark = _G[frame:GetName().."BarSpark"]
				local texture = _G[frame:GetName().."BarTexture"]
				local icon1 = _G[frame:GetName().."BarIcon1"]
				local icon2 = _G[frame:GetName().."BarIcon2"]
				local name = _G[frame:GetName().."BarName"]
				local timer = _G[frame:GetName().."BarTimer"]
				
				if not (icon1.overlay) then
					icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
					icon1.overlay:CreatePanel(template, buttonsize, buttonsize, "BOTTOMRIGHT", tbar, "BOTTOMLEFT", -buttonsize/4, -2)
					
					local backdroptex = icon1.overlay:CreateTexture(nil, "BORDER")
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:Point("TOPLEFT", icon1.overlay, "TOPLEFT", 2, -2)
					backdroptex:Point("BOTTOMRIGHT", icon1.overlay, "BOTTOMRIGHT", -2, 2)
					backdroptex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				end

				if not (icon2.overlay) then
					icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
					icon2.overlay:CreatePanel(template, buttonsize, buttonsize, "BOTTOMLEFT", tbar, "BOTTOMRIGHT", buttonsize/4, -2)
					
					local backdroptex = icon2.overlay:CreateTexture(nil, "BORDER")
					backdroptex:SetTexture([=[Interface\Icons\Spell_Nature_WispSplode]=])
					backdroptex:Point("TOPLEFT", icon2.overlay, "TOPLEFT", 2, -2)
					backdroptex:Point("BOTTOMRIGHT", icon2.overlay, "BOTTOMRIGHT", -2, 2)
					backdroptex:SetTexCoord(0.08, 0.92, 0.08, 0.92)					
				end

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end
				
				if bar.enlarged then frame:SetWidth(E.Scale(bar.owner.options.HugeWidth)) else frame:SetWidth(E.Scale(bar.owner.options.Width)) end
				if bar.enlarged then tbar:SetWidth(E.Scale(bar.owner.options.HugeWidth)) else tbar:SetWidth(E.Scale(bar.owner.options.Width)) end

				if not frame.styled then
					frame:SetScale(1)
					frame.SetScale=E.dummy
					frame:SetHeight(buttonsize)
					frame:SetTemplate("Transparent")
					frame.styled=true
				end

				if not spark.killed then
					spark:SetAlpha(0)
					spark:SetTexture(nil)
					spark.killed=true
				end
	
				if not icon1.styled then
					icon1:SetTexCoord(0.08, 0.92, 0.08, 0.92)
					icon1:ClearAllPoints()
					icon1:Point("TOPLEFT", icon1.overlay, 2, -2)
					icon1:Point("BOTTOMRIGHT", icon1.overlay, -2, 2)
					icon1.styled=true
				end
				
				if not icon2.styled then
					icon2:SetTexCoord(0.08, 0.92, 0.08, 0.92)
					icon2:ClearAllPoints()
					icon2:Point("TOPLEFT", icon2.overlay, 2, -2)
					icon2:Point("BOTTOMRIGHT", icon2.overlay, -2, 2)
					icon2.styled=true
				end

				if not texture.styled then
					texture:SetTexture(C["media"].normTex)
					texture.styled=true
				end
				
				tbar:SetStatusBarTexture(C["media"].normTex)
				if not tbar.styled then
					tbar:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
					tbar:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
					
					tbar.styled=true
				end

				if not name.styled then
					name:ClearAllPoints()
					name:Point("LEFT", frame, "LEFT", 4, 0)
					name:SetWidth(165)
					name:SetHeight(8)
					name:SetFont(C["media"].font, 12, "OUTLINE")
					name:SetJustifyH("LEFT")
					name:SetShadowColor(0, 0, 0, 0)
					name.SetFont = E.dummy
					name.styled=true
				end
				
				if not timer.styled then	
					timer:ClearAllPoints()
					timer:Point("RIGHT", frame, "RIGHT", -4, 0)
					timer:SetFont(C["media"].font, 12, "OUTLINE")
					timer:SetJustifyH("RIGHT")
					timer:SetShadowColor(0, 0, 0, 0)
					timer.SetFont = E.dummy
					timer.styled=true
				end

				if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
				if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end
				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				texture:SetAlpha(1)
				frame:Show()
				bar:Update(0)
				bar.injected=true
			end
			bar:ApplyStyle()
		end

	end
end
 
local SkinBossTitle=function()
	local anchor=DBMBossHealthDropdown:GetParent()
	if not anchor.styled then
		local header={anchor:GetRegions()}
			if header[1]:IsObjectType("FontString") then
				header[1]:SetFont(C["media"].font, 12, "OUTLINE")
				header[1]:SetTextColor(1,1,1,1)
				header[1]:SetShadowColor(0, 0, 0, 0)
				anchor.styled=true	
			end
		header=nil
	end
	anchor=nil
end

local SkinBoss=function()
	local count = 1
	while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
		local bar = _G[format("DBM_BossHealth_Bar_%d", count)]
		local background = _G[bar:GetName().."BarBorder"]
		local progress = _G[bar:GetName().."Bar"]
		local name = _G[bar:GetName().."BarName"]
		local timer = _G[bar:GetName().."BarTimer"]
		local prev = _G[format("DBM_BossHealth_Bar_%d", count-1)]	

		if (count == 1) then
			local	_, anch, _ ,_, _ = bar:GetPoint()
			bar:ClearAllPoints()
			if DBM_SavedOptions.HealthFrameGrowUp then
				bar:Point("BOTTOM", anch, "TOP" , 0 , 12)
			else
				bar:Point("TOP", anch, "BOTTOM" , 0, -buttonsize)
			end
		else
			bar:ClearAllPoints()
			if DBM_SavedOptions.HealthFrameGrowUp then
				bar:Point("TOPLEFT", prev, "TOPLEFT", 0, buttonsize+4)
			else
				bar:Point("TOPLEFT", prev, "TOPLEFT", 0, -(buttonsize+4))
			end
		end

		if not bar.styled then
			bar:SetHeight(buttonsize)
			bar:SetTemplate("Transparent")
			background:SetNormalTexture(nil)
			bar.styled=true
		end	
		
		if not progress.styled then
			progress:SetStatusBarTexture(C["media"].normTex)
			progress.styled=true
		end				
		progress:ClearAllPoints()
		progress:Point("TOPLEFT", bar, "TOPLEFT", 2, -2)
		progress:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)

		if not name.styled then
			name:ClearAllPoints()
			name:Point("LEFT", bar, "LEFT", 4, 0)
			name:SetFont(C["media"].font, 12, "OUTLINE")
			name:SetJustifyH("LEFT")
			name:SetShadowColor(0, 0, 0, 0)
			name.styled=true
		end
		
		if not timer.styled then
			timer:ClearAllPoints()
			timer:Point("RIGHT", bar, "RIGHT", -4, 0)
			timer:SetFont(C["media"].font, 12, "OUTLINE")
			timer:SetJustifyH("RIGHT")
			timer:SetShadowColor(0, 0, 0, 0)
			timer.styled=true
		end
		count = count + 1
	end
end

-- mwahahahah, eat this ugly DBM.
hooksecurefunc(DBT,"CreateBar",SkinBars)
hooksecurefunc(DBM.BossHealth,"Show",SkinBossTitle)
hooksecurefunc(DBM.BossHealth,"AddBoss",SkinBoss)
hooksecurefunc(DBM.BossHealth,"UpdateSettings",SkinBoss)
DBM.RangeCheck:Show()
DBM.RangeCheck:Hide()
DBMRangeCheck:HookScript("OnShow",function(self)
	self:SetTemplate("Transparent")
end)


local RaidNotice_AddMessage_=RaidNotice_AddMessage
RaidNotice_AddMessage=function(noticeFrame, textString, colorInfo)
	if textString:find(" |T") then
		textString = string.gsub(textString,"(:12:12)",":18:18:0:0:64:64:5:59:5:59")
	end
	return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
end

local ForceOptions = function()
	DBM_SavedOptions.Enabled=true

	DBT_SavedOptions["DBM"].Scale = 1
	DBT_SavedOptions["DBM"].HugeScale = 1
	DBT_SavedOptions["DBM"].BarXOffset = 0
	DBT_SavedOptions["DBM"].BarYOffset = 9
	DBT_SavedOptions["DBM"].Texture = "ElvUI Norm"
	DBT_SavedOptions["DBM"].Font = "ElvUI Font"
end

local loadOptions = CreateFrame("Frame")
loadOptions:RegisterEvent("PLAYER_LOGIN")
loadOptions:SetScript("OnEvent", ForceOptions)