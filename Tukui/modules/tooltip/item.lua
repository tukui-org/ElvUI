if TukuiCF.tooltip.enable ~= true then return end

GameTooltip:HookScript("OnTooltipCleared", function(self) self.TukuiItemTooltip=nil end)
GameTooltip:HookScript("OnTooltipSetItem", function(self)
	if TukuiItemTooltip and not self.TukuiItemTooltip and (TukuiItemTooltip.id or TukuiItemTooltip.count) then
		local item, link = self:GetItem()
		local num = GetItemCount(link)
		local left = ""
		local right = ""
		
		if TukuiItemTooltip.id and link ~= nil then
			left = "|cFFCA3C3C"..ID.."|r "..link:match(":(%w+)")
		end
		
		if TukuiItemTooltip.count and num > 1 then
			right = "|cFFCA3C3C"..tukuilocal.tooltip_count.."|r "..num
		end
				
		self:AddLine(" ")
		self:AddDoubleLine(left, right)
		self.TukuiItemTooltip = 1
	end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, name)
	if name ~= "Tukui" then return end
	f:UnregisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", nil)
	TukuiItemTooltip = TukuiItemTooltip or {count=true,id=TukuiCF["tooltip"].itemid}
end)

--------------------------------------------------------------------
-- SpellID's by Silverwind
-- http://wow.curseforge.com/addons/spellid/
--------------------------------------------------------------------
if TukuiCF["tooltip"].itemid ~= true then return end

hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
	local id = select(11,UnitBuff(...))
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(11,UnitDebuff(...))
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11,UnitAura(...))
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
	if string.find(link,"^spell:") then
		local id = string.sub(link,7)
		ItemRefTooltip:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		ItemRefTooltip:Show()
	end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3,self:GetSpell())
	if id then
		self:AddLine("|cFFCA3C3C"..ID.."|r".." "..id)
		self:Show()
	end
end)
