local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end
 
local playerClass = select(2,UnitClass("player"))
local CanDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Magic = false, Curse = true },
	PALADIN = { Magic = false, Poison = true, Disease = true },
	MAGE = { Curse = true },
	DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
	MONK = { Magic = false, Poison = true, Disease = true }
}

local blackList = {
	[GetSpellInfo(140546)] = true, --Fully Mutated
	[GetSpellInfo(136184)] = true, --Thick Bones
	[GetSpellInfo(136186)] = true, --Clear mind
	[GetSpellInfo(136182)] = true, --Improved Synapses
	[GetSpellInfo(136180)] = true, --Keen Eyesight
}

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)
local dispellist = CanDispel[playerClass] or {}
local origColors = {}
local origBorderColors = {}
local origPostUpdateAura = {}
 
local function GetDebuffType(unit, filter, filterTable)
	if not unit or not UnitCanAssist("player", unit) then return nil end
	local i = 1
	while true do
		local name, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")

		if not texture then break end
		if(filterTable and filterTable[name] and filterTable[name].enable) then
			return debufftype, texture, true, filterTable[name].style, filterTable[name].color
		elseif debufftype and (not filter or (filter and dispellist[debufftype])) and not blackList[name] then
			return debufftype, texture
		end
		i = i + 1
	end
end

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	
	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end
 
local function CheckSpec(self, event, levels)
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end

	--Check for certain talents to see if we can dispel magic or not
	if playerClass == "PRIEST" then
		if CheckTalentTree(3) then
			dispellist.Disease = false
		else
			dispellist.Disease = true	
		end		
	elseif playerClass == "PALADIN" then
		if CheckTalentTree(1) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "SHAMAN" then
		if CheckTalentTree(3) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "DRUID" then
		if CheckTalentTree(4) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "MONK" then
		if CheckTalentTree(2) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end		
	end
end

local function CheckSymbiosis()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		dispellist.Disease = true
	else
		dispellist.Disease = false
	end
end
 
local function Update(object, event, unit)
	if unit ~= object.unit then return; end

	local debuffType, texture, wasFiltered, style, color = GetDebuffType(unit, object.DebuffHighlightFilter, object.DebuffHighlightFilterTable)
	if(wasFiltered) then
		if style == "GLOW" and object.DBHGlow then
			object.DBHGlow:Show()
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif object.DBHGlow then
			object.DBHGlow:Hide()
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a or object.DebuffHighlightAlpha or .5)
		end		
	elseif debuffType then
		color = DebuffTypeColor[debuffType]
		if object.DebuffHighlightBackdrop and object.DBHGlow then
			object.DBHGlow:Show()
			object.DBHGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif object.DebuffHighlightUseTexture then
			object.DebuffHighlight:SetTexture(texture)
		else
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or .5)
		end
	else
		if object.DBHGlow then
			object.DBHGlow:Hide()
		end

		if object.DebuffHighlightUseTexture then
			object.DebuffHighlight:SetTexture(nil)
		else
			object.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end
end
 
local function Enable(object)
	-- if we're not highlighting this unit return
	if not object.DebuffHighlightBackdrop and not object.DebuffHighlight and not object.DBHGlow then
		return
	end
	-- if we're filtering highlights and we're not of the dispelling type, return
	if object.DebuffHighlightFilter and not CanDispel[playerClass] then
		return
	end
 
	object:RegisterEvent("UNIT_AURA", Update)
	if playerClass == "DRUID" then
		object:RegisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end

	return true
end

local function Disable(object)
	object:UnregisterEvent("UNIT_AURA", Update)

	if playerClass == "DRUID" then
		object:UnregisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end

	if object.DBHGlow then
		object.DBHGlow:Hide()
	end

	if object.DebuffHighlight then
		local color = origColors[object]
		if color then
			object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("CHARACTER_POINTS_CHANGED")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:SetScript("OnEvent", CheckSpec)

oUF:AddElement('DebuffHighlight', Update, Enable, Disable)