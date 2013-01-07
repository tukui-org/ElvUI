local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "PetBattleTeamsSkin"
local function SkinPetBattleTeams(self)
	E:Delay(6, function()
		AS:SkinFrame(PetBattleTeamFrame)
		S:HandleScrollBar(PetBattleTeamsScrollFrameScrollBar)

		PetBattleTeamsTooltip:HookScript("OnShow", function(self)
			self.Icon:SetTexCoord(0.12, 0.88, 0.12, 0.88)
			self.rarityGlow:SetTexture(nil)
			self.Background:SetTexture(nil)
			self.BorderTop:SetTexture(nil)
			self.BorderTopLeft:SetTexture(nil)
			self.BorderTopRight:SetTexture(nil)
			self.BorderLeft:SetTexture(nil)
			self.BorderRight:SetTexture(nil)
			self.BorderBottom:SetTexture(nil)
			self.BorderBottomRight:SetTexture(nil)
			self.BorderBottomLeft:SetTexture(nil)
			AS:SkinFrame(self, true)
		end)
	end)
end

AS:RegisterSkin(name,SkinPetBattleTeams)