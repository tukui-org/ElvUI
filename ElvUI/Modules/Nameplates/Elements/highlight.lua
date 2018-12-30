local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

local function MouseOnUnit(frame)
	if frame and frame:IsVisible() and UnitExists('mouseover') then
		return frame.unit and UnitIsUnit('mouseover', frame.unit)
	end

	return false
end

function mod:UpdateElement_Highlight(frame)
	if frame:IsShown() and frame.unit and UnitIsUnit("mouseover", frame.unit) and (frame.NameOnlyChanged or (not self.db.units[frame.UnitType].healthbar.enable and self.db.units[frame.UnitType].showName)) and not frame.isTarget then
		frame.Name.NameOnlyGlow:Show()
		frame.Highlight:Show()
	elseif frame:IsShown() and frame.unit and UnitIsUnit("mouseover", frame.unit) and not self.db.units[frame.UnitType].healthbar.enable and self.db.showNPCTitles and (frame.NPCTitle:GetText() ~= nil and frame.NPCTitle:GetText() ~= "") and not frame.isTarget then
		frame.NPCTitle.NameOnlyGlow:Show()
		frame.Highlight:Show()
	elseif frame:IsShown() and frame.unit and UnitIsUnit("mouseover", frame.unit) and (not frame.NameOnlyChanged or self.db.units[frame.UnitType].healthbar.enable) and not frame.isTarget then
		frame.Highlight.texture:ClearAllPoints()
		frame.Highlight.texture:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT")
		frame.Highlight.texture:SetPoint("BOTTOMRIGHT", frame.HealthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
		frame.Highlight.texture:Show()
		frame.Highlight:Show()
	else
		frame.Highlight:Hide()
	end
end

function mod:ConfigureElement_Highlight(frame)
	if not self.db.units[frame.UnitType].healthbar.enable then return end
	frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_Highlight(frame)
	local f = CreateFrame("Frame", nil, frame)
	f.texture = frame.HealthBar:CreateTexture("$parentHighlight", "ARTWORK", nil, 1)
	f.texture:SetVertexColor(1, 1, 1, .3)
	f.texture:Hide()

	f:HookScript("OnHide", function()
		frame.Name.NameOnlyGlow:Hide()
		frame.NPCTitle.NameOnlyGlow:Hide()
		frame.Highlight.texture:Hide()
	end)

	f:SetScript("OnUpdate", function(watcher, elapsed)
		if watcher.elapsed and watcher.elapsed > 0.1 then
			if not MouseOnUnit(frame) then
				watcher:Hide()
			end
			watcher.elapsed = 0
		else
			watcher.elapsed = (watcher.elapsed or 0) + elapsed
		end
	end)

	return f
end
