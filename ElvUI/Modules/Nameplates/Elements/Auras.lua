local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_Buffs(frame)
	local buffs = CreateFrame('Frame', frame:GetName().."Buffs", frame)
	buffs.spacing = E.Spacing
	buffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	buffs.PostCreateIcon = self.Construct_AuraIcon
	buffs.PostUpdateIcon = self.PostUpdateAura
	buffs.CustomFilter = self.AuraFilter
	buffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	buffs.type = 'buffs'
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	buffs:Width(100)

	return buffs
end

function NP:Construct_Debuffs(frame)
	local debuffs = CreateFrame('Frame', frame:GetName().."Debuffs", frame)
	debuffs.spacing = E.Spacing
	debuffs.PreSetPosition = (not frame:GetScript("OnUpdate")) and self.SortAuras or nil
	debuffs.PostCreateIcon = self.Construct_AuraIcon
	debuffs.PostUpdateIcon = self.PostUpdateAura
	debuffs.CustomFilter = self.AuraFilter
	debuffs.type = 'debuffs'
	debuffs:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 10) --Make them appear above any text element
	--Set initial width to prevent division by zero. This value doesn't matter, as it will be updated later
	debuffs:Width(100)

	return debuffs
end

function NP:Construct_AuraIcon(button)
	local offset = E.Border

	button.text = button.cd:CreateFontString(nil, 'OVERLAY')
	button.text:Point('CENTER', 1, 1)
	button.text:SetJustifyH('CENTER')

	button:SetTemplate()

	-- cooldown override settings
	--if not button.timerOptions then
	--	button.timerOptions = {}
	--end

	--button.timerOptions.reverseToggle = UF.db.cooldown.reverse
	--button.timerOptions.hideBlizzard = UF.db.cooldown.hideBlizzard

	--if UF.db.cooldown.override and E.TimeColors.unitframe then
	--	button.timerOptions.timeColors, button.timerOptions.timeThreshold = E.TimeColors.unitframe, UF.db.cooldown.threshold
	--else
	--	button.timerOptions.timeColors, button.timerOptions.timeThreshold = nil, nil
	--end

	--if UF.db.cooldown.checkSeconds then
	--	button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = UF.db.cooldown.hhmmThreshold, UF.db.cooldown.mmssThreshold
	--else
	--	button.timerOptions.hhmmThreshold, button.timerOptions.mmssThreshold = nil, nil
	--end

	--if UF.db.cooldown.fonts and UF.db.cooldown.fonts.enable then
	--	button.timerOptions.fontOptions = UF.db.cooldown.fonts
	--elseif E.db.cooldown.fonts and E.db.cooldown.fonts.enable then
	--	button.timerOptions.fontOptions = E.db.cooldown.fonts
	--else
	--	button.timerOptions.fontOptions = nil
	--end
	----------

	button.cd:SetReverse(true)
	button.cd:SetInside(button, offset, offset)

	button.icon:SetInside(button, offset, offset)
	button.icon:SetTexCoord(unpack(E.TexCoords))
	button.icon:SetDrawLayer('ARTWORK')

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', 1, 1)
	button.count:SetJustifyH('RIGHT')

	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)

	-- support cooldown override
	--if not button.isRegisteredCooldown then
	--	button.CooldownOverride = 'unitframe'
	--	button.isRegisteredCooldown = true

	--	if not E.RegisteredCooldowns.unitframe then E.RegisteredCooldowns.unitframe = {} end
	--	tinsert(E.RegisteredCooldowns.unitframe, button)
	--end

	NP:UpdateAuraIconSettings(button, true)
end

function NP:EnableDisable_Auras(frame)
	if frame.db.debuffs.enable or frame.db.buffs.enable then
		if not frame:IsElementEnabled('Aura') then
			frame:EnableElement('Aura')
		end
	else
		if frame:IsElementEnabled('Aura') then
			frame:DisableElement('Aura')
		end
	end
end

function NP:PostUpdateAura(unit, button)
	local auras = button:GetParent()
	local frame = auras:GetParent()
	local type = auras.type
	local db = frame.db and frame.db[type]

	if db then
		if db.clickThrough and button:IsMouseEnabled() then
			button:EnableMouse(false)
		elseif not db.clickThrough and not button:IsMouseEnabled() then
			button:EnableMouse(true)
		end
	end

	if button.isDebuff then
		if(not button.isFriend and not button.isPlayer) then --[[and (not E.isDebuffWhiteList[name])]]
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not strfind(unit, 'arena%d')) and true or false)
		else
			local color = (button.dtype and DebuffTypeColor[button.dtype]) or DebuffTypeColor.none
			if button.name and (button.name == "Unstable Affliction" or button.name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if button.isStealable and not button.isFriend then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
		else
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	--if E:Cooldown_IsEnabled(button) then
	--	if button.expiration and button.duration and (button.duration ~= 0) then
	--		local getTime = GetTime()
	--		if not button:GetScript('OnUpdate') then
	--			button.expirationTime = button.expiration
	--			button.expirationSaved = button.expiration - getTime
	--			button.nextupdate = -1
	--			button:SetScript('OnUpdate', NP.UpdateAuraTimer)
	--		end
	--		if (button.expirationTime ~= button.expiration) or (button.expirationSaved ~= (button.expiration - getTime))  then
	--			button.expirationTime = button.expiration
	--			button.expirationSaved = button.expiration - getTime
	--			button.nextupdate = -1
	--		end
	--	end

	--	if button.expiration and button.duration and (button.duration == 0 or button.expiration <= 0) then
	--		button.expirationTime = nil
	--		button.expirationSaved = nil
	--		button:SetScript('OnUpdate', nil)
	--		if button.text:GetFont() then
	--			button.text:SetText('')
	--		end
	--	end
	--end
end

function NP:UpdateAuraIconSettings(auras, noCycle)
	local frame = auras:GetParent()
	local type = auras.type

	if noCycle then
		frame = auras:GetParent():GetParent()
		type = auras:GetParent().type
	end

	if not frame.db then return end
	local index, db = 1, frame.db[type]
	auras.db = db

	if db then
		local font = E.Libs.LSM:Fetch("font", E.db.unitframe.font)
		local outline = E.db.unitframe.fontOutline
		local customFont

		if not noCycle then
			while auras[index] do
				if (not customFont) and (auras[index].timerOptions and auras[index].timerOptions.fontOptions) then
					customFont = E.Libs.LSM:Fetch("font", auras[index].timerOptions.fontOptions.font)
				end

				NP:AuraIconUpdate(frame, db, auras[index], font, outline, customFont)

				index = index + 1
			end
		else
			if auras.timerOptions and auras.timerOptions.fontOptions then
				customFont = E.Libs.LSM:Fetch("font", auras.timerOptions.fontOptions.font)
			end

			NP:AuraIconUpdate(frame, db, auras, font, outline, customFont)
		end
	end
end

function NP:AuraIconUpdate(frame, db, button, font, outline, customFont)
	if customFont and (button.timerOptions and button.timerOptions.fontOptions and button.timerOptions.fontOptions.enable) then
		button.text:FontTemplate(customFont, button.timerOptions.fontOptions.fontSize, button.timerOptions.fontOptions.fontOutline)
	else
		button.text:FontTemplate(font, db.fontSize, outline)
	end

	button.count:FontTemplate(font, db.countFontSize or db.fontSize, outline)
	button.unit = frame.unit -- used to update cooldown text

--	E:ToggleBlizzardCooldownText(button.cd, button)
end