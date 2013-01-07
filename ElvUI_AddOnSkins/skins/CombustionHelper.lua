local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "CombustionHelperSkin"
local function SkinCombustionHelper(self)
		AS:SkinBackdropFrame(CombustionFrame)
		CombustionFrame:HookScript("OnUpdate", function(self) self:StripTextures() end)
		CombuMBTrackerBorderFrame:Kill()
		CombuMBTrackerFrame:HookScript("OnUpdate", function(self) self:SetTemplate("Transparent") self:SetPoint("BOTTOM", CombustionFrame, "TOP", 0, 4) end)
end

AS:RegisterSkin(name,SkinCombustionHelper)