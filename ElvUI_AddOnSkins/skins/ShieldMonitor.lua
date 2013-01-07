local E, L, V, P, G, _ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ShieldMonitorSkin"
local function SkinShieldMonitor(self)

	AS:SkinFrameD(shieldmonitor_Frame, true)
	shieldmonitor_Frame:HookScript("OnShow", function(self)
		AS:SkinFrameD(shieldmonitor_Frame, true)
	end)
	shieldmonitor_Frame:RegisterEvent("UNIT_AURA")
	shieldmonitor_Frame:HookScript("OnEvent", function(self)
		AS:SkinFrameD(shieldmonitor_Frame, true)
	end)
	shieldmonitor_Frame:SetSize(209, 20)

	shieldmonitor_Bar:SetStatusBarTexture(E["media"].normTex)
	shieldmonitor_Bar:ClearAllPoints()
	shieldmonitor_Bar:SetInside()

	local IconBorder = CreateFrame("Frame", "ShieldIconBorder", shieldmonitor_Frame)
	AS:SkinFrameD(IconBorder)
	IconBorder:SetSize(20, 20)
	IconBorder:SetPoint("RIGHT", shieldmonitor_Frame, "LEFT", -3, 0)

	shieldmonitor_FrameIcon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	shieldmonitor_FrameIcon1:ClearAllPoints()
	shieldmonitor_FrameIcon1:SetParent(IconBorder)
	shieldmonitor_FrameIcon1:SetInside()

	shieldmonitor_BarText:SetFont(E["media"].normFont, 12, "OUTLINE")
	shieldmonitor_BarText:SetPoint("CENTER", shieldmonitor_Bar, "CENTER", 0, 0)

	shieldmonitor_FrameDuration:SetFont(E["media"].normFont, 12, "OUTLINE")
	shieldmonitor_FrameDuration:SetParent(shieldmonitor_Bar)
	shieldmonitor_FrameDuration:ClearAllPoints()
	shieldmonitor_FrameDuration:SetPoint("RIGHT", shieldmonitor_Frame, "RIGHT", -2, 0)

end

AS:RegisterSkin(name,SkinShieldMonitor)