local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "HealiumSkin"
local function SkinHealium(self)
	local captionFrames = {
		"HealiumPartyFrame",
		"HealiumPetFrame",
		"HealiumMeFrame",
		"HealiumFriendsFrame",
		"HealiumDanagersFrame",
		"HealiumHealersFrame",
		"HealiumTanksFrame",
		"HealiumTargetFrame",
		"HealiumFocusFrame",
		"HealiumGroup1Frame",
		"HealiumGroup2Frame",
		"HealiumGroup3Frame",
		"HealiumGroup4Frame",
		"HealiumGroup5Frame",
		"HealiumGroup6Frame",
		"HealiumGroup7Frame",
		"HealiumGroup8Frame",
	}

	local skinnedFrames = {}
	local skinHeader = function(self)
		if not(self) or (skinnedFrames[self:GetName()]) then
			return
		end

		local frameName = self:GetName()

		local captionbar = self.CaptionBar
		local captiontext = self.CaptionBar.Caption
		local closebutton = self.CaptionBar.CloseButton

		AS:SkinFrame(captionbar, true)
		S:HandleCloseButton(closebutton)

		skinnedFrames[self:GetName()] = true
	end

	local skinUnitFrame = function(self)
		if not(self) or (skinnedFrames[self:GetName()]) then
			return
		end

		local frameName = self:GetName()
		local name = self.name
		local hptext = self.HPText
		local raidtarget = self.raidTargetIcon
		local cursebar = self.CurseBar
		local aggrobar = self.AggroBar
		local predictbar = self.PredictBar
		local healthbar = self.HealthBar
		local manabar = self.ManaBar
			
		self:StripTextures()

		AS:SkinStatusBar(predictbar)
		AS:SkinStatusBar(healthbar)
		AS:SkinStatusBar(manabar)
			
		predictbar:SetHeight(24)
		healthbar:SetHeight(24)
		manabar:SetHeight(24)
			
		predictbar:SetPoint("TOPLEFT", 7, 0)
		healthbar:SetPoint("TOPLEFT", 7, 0)
		manabar:ClearAllPoints()
		manabar:SetPoint("TOPLEFT", -4, 0)
			
		skinnedFrames[self:GetName()] = true
	end
		
	local skinHeal = function(self)
		if not(self) or (skinnedFrames[self:GetName()]) then
			return
		end

		local icon = self.icon
		local texture = icon:GetTexture()
		AS:SkinIconButton(self, true, true, true)

		icon:SetTexture(texture)
		icon:SetDrawLayer("OVERLAY")
		icon:ClearAllPoints()
		icon:SetInside()

		skinnedFrames[self:GetName()] = true
	end
		
	local skinBuff = function(self)
		if not(self) or (skinnedFrames[self:GetName()]) then
			return
		end
			
		local icon = self.icon
		local cooldown = self.cooldown
		local count = self.count 
		local border = self.border 

		AS:SkinIconButton(self, false, true, true)
		self:SetSize(28,28)			
		icon:SetDrawLayer("OVERLAY")
		icon:ClearAllPoints()
		icon:SetInside()

		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)

		skinnedFrames[self:GetName()] = true
	end
		
	local skinAllHealiumFrames = function()
		if not(Healium_Frames) then
			return
		end
			
		for i,frameName in pairs(captionFrames) do
			if (_G[frameName]) then
				skinHeader(_G[frameName])
			end
			for i,frame in pairs(Healium_Frames) do
				skinUnitFrame(frame)

				for v = 1, Healium_MaxButtons do
					skinHeal(_G[frame:GetName().. "_Heal" .. v])
					if v == 1 then
						_G[frame:GetName().. "_Heal" .. v]:SetPoint("LEFT", frame:GetName(), "RIGHT", 2, 2)
					else
						_G[frame:GetName().. "_Heal" .. v]:SetPoint("LEFT", _G[frame:GetName().. "_Heal".. (v-1)], "RIGHT", 2, 0)
					end
				end

				for v = 1, 6 do
					skinBuff(_G[frame:GetName() .. "_Buff" .. v])
					if v == 1 then
						_G[frame:GetName().. "_Buff" .. v]:SetPoint("RIGHT", frame:GetName(), "LEFT", -8, 2)
					else
						_G[frame:GetName().. "_Buff" .. v]:SetPoint("RIGHT", _G[frame:GetName().. "_Buff".. (v-1)], "LEFT", -2, 0)
					end
				end
			end
		end
	end

	skinAllHealiumFrames()

	hooksecurefunc("Healium_HealButton_OnLoad", skinHeal)
	hooksecurefunc("Healium_CreateUnitFrames", skinAllHealiumFrames)
	hooksecurefunc("HealiumUnitFrames_Button_OnLoad", skinUnitFrame)
end

AS:RegisterSkin(name,SkinHealium)