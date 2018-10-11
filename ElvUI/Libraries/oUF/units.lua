local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local enableTargetUpdate = Private.enableTargetUpdate

local function updateArenaPreparationElements(self, event, elementName, specID)
	local element = self[elementName]
	if(element and self:IsElementEnabled(elementName)) then
		if(element.OverrideArenaPreparation) then
			--[[ Override: Health.OverrideArenaPreparation(self, event, specID)
			Used to completely override the internal update function for arena preparation.

			* self   - the parent object
			* event  - the event triggering the update (string)
			* specID - the specialization ID for the opponent (number)
			--]]
			--[[ Override: Power.OverrideArenaPreparation(self, event, specID)
			Used to completely override the internal update function for arena preparation.

			* self   - the parent object
			* event  - the event triggering the update (string)
			* specID - the specialization ID for the opponent (number)
			--]]
			element.OverrideArenaPreparation(self, event, specID)
			return
		end

		element:SetMinMaxValues(0, 1)
		element:SetValue(1)
		if(element.UpdateColorArenaPreparation) then
			--[[ Override: Health:UpdateColor(specID)
			Used to completely override the internal function for updating the widget's colors
			during arena preparation.

			* self   - the Health element
			* specID - the specialization ID for the opponent (number)
			--]]
			--[[ Override: Power:UpdateColor(specID)
			Used to completely override the internal function for updating the widget's colors
			during arena preparation.

			* self   - the Power element
			* specID - the specialization ID for the opponent (number)
			--]]
			element:UpdateColorArenaPreparation(specID)
		else
			-- this section just replicates the color options available to the Health and Power elements
			local r, g, b, t, _
			-- if(element.colorPower and elementName == 'Power') then
				-- FIXME: no idea if we can get power type here without the unit
			if(element.colorClass) then
				local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
				t = self.colors.class[class]
			elseif(element.colorReaction) then
				t = self.colors.reaction[2]
			elseif(element.colorSmooth) then
				_, _, _, _, _, _, r, g, b = unpack(element.smoothGradient or self.colors.smooth)
			elseif(element.colorHealth and elementName == 'Health') then
				t = self.colors.health
			end

			if(t) then
				r, g, b = t[1], t[2], t[3]
			end

			if(r or g or b) then
				element:SetStatusBarColor(r, g, b)

				local bg = element.bg
				if(bg) then
					local mu = bg.multiplier or 1
					bg:SetVertexColor(r * mu, g * mu, b * mu)
				end
			end
		end

		if(element.PostUpdateArenaPreparation) then
			--[[ Callback: Health:PostUpdateArenaPreparation(event, specID)
			Called after the element has been updated during arena preparation.

			* self   - the Health element
			* event  - the event triggering the update (string)
			* specID - the specialization ID for the opponent (number)
			--]]
			--[[ Callback: Power:PostUpdateArenaPreparation(event, specID)
			Called after the element has been updated during arena preparation.

			* self   - the Power element
			* event  - the event triggering the update (string)
			* specID - the specialization ID for the opponent (number)
			--]]
			element:PostUpdateArenaPreparation(event, specID)
		end
	end
end

local function updateArenaPreparation(self, event)
	if(not self:GetAttribute('oUF-enableArenaPrep')) then
		return
	end

	if(event == 'ARENA_OPPONENT_UPDATE' and not self:IsEnabled()) then
		self:Enable()
		self:UpdateAllElements('ArenaPreparation')
		self:UnregisterEvent(event, updateArenaPreparation)

		-- show elements that don't handle their own visibility
		if(self:IsElementEnabled('Auras')) then
			if(self.Auras) then self.Auras:Show() end
			if(self.Buffs) then self.Buffs:Show() end
			if(self.Debuffs) then self.Debuffs:Show() end
		end

		if(self.Portrait and self:IsElementEnabled('Portrait')) then
			self.Portrait:Show()
		end
	elseif(event == 'PLAYER_ENTERING_WORLD' and not UnitExists(self.unit)) then
		-- semi-recursive call for when the player zones into an arena
		updateArenaPreparation(self, 'ARENA_PREP_OPPONENT_SPECIALIZATIONS')
	elseif(event == 'ARENA_PREP_OPPONENT_SPECIALIZATIONS') then
		if(self.PreUpdate) then
			self:PreUpdate(event)
		end

		local id = tonumber(self.id)
		if(not self:IsEnabled() and GetNumArenaOpponentSpecs() < id) then
			-- hide the object if the opponent leaves
			self:Hide()
		end

		local specID = GetArenaOpponentSpec(id)
		if(specID) then
			if(self:IsEnabled()) then
				-- disable the unit watch so we can forcefully show the object ourselves
				self:Disable()
				self:RegisterEvent('ARENA_OPPONENT_UPDATE', updateArenaPreparation)
			end

			-- update Health and Power (if available) with "fake" data
			updateArenaPreparationElements(self, event, 'Health', specID)
			updateArenaPreparationElements(self, event, 'Power', specID)

			-- hide all other (relevant) elements (they have no effect during arena prep)
			if(self.Auras) then self.Auras:Hide() end
			if(self.Buffs) then self.Buffs:Hide() end
			if(self.Debuffs) then self.Debuffs:Hide() end
			if(self.Castbar) then self.Castbar:Hide() end
			if(self.CombatIndicator) then self.CombatIndicator:Hide() end
			if(self.GroupRoleIndicator) then self.GroupRoleIndicator:Hide() end
			if(self.Portrait) then self.Portrait:Hide() end
			if(self.PvPIndicator) then self.PvPIndicator:Hide() end
			if(self.RaidTargetIndicator) then self.RaidTargetIndicator:Hide() end

			self:Show()
			self:UpdateTags()
		end

		if(self.PostUpdate) then
			self:PostUpdate(event)
		end
	end
end

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
	local unit = object.unit or unit
	if(unit == 'target') then
		object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements)
	elseif(unit == 'mouseover') then
		object:RegisterEvent('UPDATE_MOUSEOVER_UNIT', object.UpdateAllElements)
	elseif(unit == 'focus') then
		object:RegisterEvent('PLAYER_FOCUS_CHANGED', object.UpdateAllElements)
	elseif(unit:match('boss%d?$')) then
		object:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT', object.UpdateAllElements, true)
		object:RegisterEvent('UNIT_TARGETABLE_CHANGED', object.UpdateAllElements)
	elseif(unit:match('arena%d?$')) then
		object:RegisterEvent('ARENA_OPPONENT_UPDATE', object.UpdateAllElements)
		object:RegisterEvent('ARENA_PREP_OPPONENT_SPECIALIZATIONS', updateArenaPreparation, true)
		object:SetAttribute('oUF-enableArenaPrep', true)
		-- the event handler only fires for visible frames, so we have to hook it for arena prep
		object:HookScript('OnEvent', updateArenaPreparation)
	elseif(unit:match('%w+target')) then
		enableTargetUpdate(object)
	end
end
