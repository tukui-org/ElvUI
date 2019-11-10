local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

local _G = _G
local pairs, unpack = pairs, unpack
local CreateFrame = CreateFrame

local questIconTypes = { "Item", "Loot", "Skull", "Chat" }
local targetIndicators = { "Spark", "TopIndicator", "LeftIndicator", "RightIndicator" }

function NP:Construct_QuestIcons(nameplate)
	local QuestIcons = CreateFrame("Frame", nameplate:GetDebugName() .. "QuestIcons", nameplate)
	QuestIcons:Size(20)
	QuestIcons:Hide()

	for _, object in pairs(questIconTypes) do
		local icon = QuestIcons:CreateTexture(nil, "BORDER", nil, 1)
		icon.Text = QuestIcons:CreateFontString(nil, "OVERLAY")
		icon.Text:FontTemplate()
		icon:Hide()

		QuestIcons[object] = icon
	end

	QuestIcons.Item:SetTexCoord(unpack(E.TexCoords))
	QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	return QuestIcons
end

function NP:Update_QuestIcons(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == "FRIENDLY_NPC" or nameplate.frameType == "ENEMY_NPC") and db.questIcon.enable then
		if not nameplate:IsElementEnabled("QuestIcons") then
			nameplate:EnableElement("QuestIcons")
		end

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point(E.InversePoints[db.questIcon.position], nameplate, db.questIcon.position, db.questIcon.xOffset, db.questIcon.yOffset)

		for _, object in pairs(questIconTypes) do
			local icon = nameplate.QuestIcons[object]
			icon:Size(db.questIcon.size, db.questIcon.size)
			icon.Text:FontTemplate(E.Libs.LSM:Fetch("font", db.questIcon.font), db.questIcon.fontSize, db.questIcon.fontOutline)
			icon.Text:ClearAllPoints()
			icon.Text:Point(db.questIcon.textPosition, icon)
			icon.size, icon.position = db.questIcon.size, db.questIcon.position
		end
	elseif nameplate:IsElementEnabled("QuestIcons") then
		nameplate:DisableElement("QuestIcons")
	end
end

function NP:Construct_ClassificationIndicator(nameplate)
	return nameplate:CreateTexture(nameplate:GetDebugName() .. "ClassificationIndicator", "OVERLAY")
end

function NP:Update_ClassificationIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == "FRIENDLY_NPC" or nameplate.frameType == "ENEMY_NPC") and db.eliteIcon.enable then
		if not nameplate:IsElementEnabled("ClassificationIndicator") then
			nameplate:EnableElement("ClassificationIndicator")
		end

		nameplate.ClassificationIndicator:ClearAllPoints()
		nameplate.ClassificationIndicator:Size(db.eliteIcon.size, db.eliteIcon.size)
		nameplate.ClassificationIndicator:Point(E.InversePoints[db.eliteIcon.position], nameplate, db.eliteIcon.position, db.eliteIcon.xOffset, db.eliteIcon.yOffset)
	elseif nameplate:IsElementEnabled("ClassificationIndicator") then
		nameplate:DisableElement("ClassificationIndicator")
	end
end

function NP:Construct_TargetIndicator(nameplate)
	local TargetIndicator = CreateFrame("Frame", nameplate:GetDebugName() .. "TargetIndicator", nameplate)
	TargetIndicator:SetFrameLevel(0)

	TargetIndicator.Shadow = CreateFrame("Frame", nil, TargetIndicator)
	TargetIndicator.Shadow:SetBackdrop({edgeFile = E.LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(5)})
	TargetIndicator.Shadow:Hide()

	for _, object in pairs(targetIndicators) do
		local indicator = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
		indicator:Hide()

		TargetIndicator[object] = indicator
	end

	return TargetIndicator
end

function NP:Update_TargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if nameplate.frameType == "PLAYER" then
		if nameplate:IsElementEnabled("TargetIndicator") then
			nameplate:DisableElement("TargetIndicator")
		end
		return
	end

	if not nameplate:IsElementEnabled("TargetIndicator") then
		nameplate:EnableElement("TargetIndicator")
	end

	nameplate.TargetIndicator.style = NP.db.units.TARGET.glowStyle
	nameplate.TargetIndicator.lowHealthThreshold = NP.db.lowHealthThreshold

	if nameplate.TargetIndicator.style ~= "none" then
		local GlowStyle, Color = NP.db.units.TARGET.glowStyle, NP.db.colors.glowColor

		if not db.health.enable and (GlowStyle ~= "style2" and GlowStyle ~= "style6" and GlowStyle ~= "style8") then
			GlowStyle = "style2"
			nameplate.TargetIndicator.style = "style2"
		end

		if nameplate.TargetIndicator.TopIndicator and (GlowStyle == "style3" or GlowStyle == "style5" or GlowStyle == "style6") then
			nameplate.TargetIndicator.TopIndicator:Point("BOTTOM", nameplate.Health, "TOP", 0, -6)
			nameplate.TargetIndicator.TopIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if (nameplate.TargetIndicator.LeftIndicator and nameplate.TargetIndicator.RightIndicator) and (GlowStyle == "style4" or GlowStyle == "style7" or GlowStyle == "style8") then
			nameplate.TargetIndicator.LeftIndicator:Point("LEFT", nameplate.Health, "RIGHT", -3, 0)
			nameplate.TargetIndicator.RightIndicator:Point("RIGHT", nameplate.Health, "LEFT", 3, 0)
			nameplate.TargetIndicator.LeftIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
			nameplate.TargetIndicator.RightIndicator:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end

		if nameplate.TargetIndicator.Shadow and (GlowStyle == "style1" or GlowStyle == "style5" or GlowStyle == "style7") then
			nameplate.TargetIndicator.Shadow:SetOutside(nameplate.Health, E:Scale(E.PixelMode and 6 or 8), E:Scale(E.PixelMode and 6 or 8))
			nameplate.TargetIndicator.Shadow:SetBackdropBorderColor(Color.r, Color.g, Color.b)
			nameplate.TargetIndicator.Shadow:SetAlpha(Color.a)
		end

		if nameplate.TargetIndicator.Spark and (GlowStyle == "style2" or GlowStyle == "style6" or GlowStyle == "style8") then
			local size = E.Border + 14
			nameplate.TargetIndicator.Spark:Point("TOPLEFT", nameplate.Health, "TOPLEFT", -(size * 2), size)
			nameplate.TargetIndicator.Spark:Point("BOTTOMRIGHT", nameplate.Health, "BOTTOMRIGHT", (size * 2), -size)
			nameplate.TargetIndicator.Spark:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
		end
	end
end

function NP:Construct_Highlight(nameplate)
	local Highlight = CreateFrame("Frame", nameplate:GetDebugName() .. "Highlight", nameplate)
	Highlight:Hide()
	Highlight:EnableMouse(false)
	Highlight:SetFrameLevel(9)

	Highlight.texture = Highlight:CreateTexture(nil, "ARTWORK")

	return Highlight
end

function NP:Update_Highlight(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if NP.db.highlight and db.enable then
		if not nameplate:IsElementEnabled("Highlight") then
			nameplate:EnableElement("Highlight")
		end

		if db.health.enable and not (db.nameOnly or nameplate.NameOnlyChanged) then
			nameplate.Highlight.texture:SetColorTexture(1, 1, 1, 0.25)
			nameplate.Highlight.texture:SetAllPoints(nameplate.FlashTexture)
			nameplate.Highlight.texture:SetAlpha(0.75)
		else
			nameplate.Highlight.texture:SetTexture(E.Media.Textures.Spark)
			nameplate.Highlight.texture:SetAllPoints(nameplate)
			nameplate.Highlight.texture:SetAlpha(0.50)
		end
	elseif nameplate:IsElementEnabled("Highlight") then
		nameplate:DisableElement("Highlight")
	end
end

function NP:Construct_HealerSpecs(nameplate)
	local texture = nameplate:CreateTexture(nameplate:GetDebugName() .. "HealerSpecs", "OVERLAY")
	texture:Size(40, 40)
	texture:SetTexture(E.Media.Textures.Healer)
	texture:Hide()

	return texture
end

function NP:Update_HealerSpecs(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == "FRIENDLY_PLAYER" or nameplate.frameType == "ENEMY_PLAYER") and db.markHealers then
		if not nameplate:IsElementEnabled("HealerSpecs") then
			nameplate:EnableElement("HealerSpecs")
		end

		nameplate.HealerSpecs:Point("RIGHT", nameplate.Health, "LEFT", -6, 0)
	elseif nameplate:IsElementEnabled("HealerSpecs") then
		nameplate:DisableElement("HealerSpecs")
	end
end

function NP:Update_Fader(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (not db.visibility) or db.visibility.showAlways then
		if nameplate:IsElementEnabled("Fader") then
			nameplate:DisableElement("Fader")

			NP:PlateFade(nameplate, 1, nameplate:GetAlpha(), 1)
		end
	else
		if not nameplate.Fader then
			nameplate.Fader = {}
		end

		if not nameplate:IsElementEnabled("Fader") then
			nameplate:EnableElement("Fader")

			nameplate.Fader:SetOption("MinAlpha", 0)
			nameplate.Fader:SetOption("Smooth", 0.5)
			nameplate.Fader:SetOption("Hover", (nameplate == _G.ElvNP_Player and _G.ElvNP_StaticSecure) or true)
			nameplate.Fader:SetOption("Power", true)
			nameplate.Fader:SetOption("Health", true)
			nameplate.Fader:SetOption("Casting", true)
		end

		nameplate.Fader:SetOption("PlayerTarget", db.visibility.showWithTarget)
		nameplate.Fader:SetOption("Combat", db.visibility.showInCombat)
		nameplate.Fader:SetOption("Delay", db.visibility.hideDelay)

		nameplate.Fader:ForceUpdate()
	end
end

function NP:Construct_Cutaway(nameplate)
	local Cutaway = {}

	Cutaway.Health = nameplate.Health.ClipFrame:CreateTexture(nameplate:GetDebugName() .. "CutawayHealth")
	local healthTexture = nameplate.Health:GetStatusBarTexture()
	Cutaway.Health:SetPoint("TOPLEFT", healthTexture, "TOPRIGHT")
	Cutaway.Health:SetPoint("BOTTOMLEFT", healthTexture, "BOTTOMRIGHT")

	Cutaway.Power = nameplate.Power.ClipFrame:CreateTexture(nameplate:GetDebugName() .. "CutawayPower")
	local powerTexture = nameplate.Power:GetStatusBarTexture()
	Cutaway.Power:SetPoint("TOPLEFT", powerTexture, "TOPRIGHT")
	Cutaway.Power:SetPoint("BOTTOMLEFT", powerTexture, "BOTTOMRIGHT")

	return Cutaway
end

function NP:Update_Cutaway(nameplate)
	local eitherEnabled = NP.db.cutaway.health.enabled or NP.db.cutaway.power.enabled
	if not eitherEnabled then
		if nameplate:IsElementEnabled("Cutaway") then
			nameplate:DisableElement("Cutaway")
		end
	else
		if not nameplate:IsElementEnabled("Cutaway") then
			nameplate:EnableElement("Cutaway")
		end

		nameplate.Cutaway:UpdateConfigurationValues(NP.db.cutaway)

		if NP.db.cutaway.health.forceBlankTexture then
			nameplate.Cutaway.Health:SetTexture(E.media.blankTex)
		else
			nameplate.Cutaway.Health:SetTexture(E.Libs.LSM:Fetch("statusbar", NP.db.statusbar))
		end

		if NP.db.cutaway.power.forceBlankTexture then
			nameplate.Cutaway.Power:SetTexture(E.media.blankTex)
		else
			nameplate.Cutaway.Power:SetTexture(E.Libs.LSM:Fetch("statusbar", NP.db.statusbar))
		end
	end
end

function NP:Construct_NazjatarFollowerXP(nameplate)
	local NazjatarFollowerXP = CreateFrame("StatusBar", nameplate:GetDebugName() .. "NazjatarFollowerXP", nameplate)

	NazjatarFollowerXP:SetFrameStrata(nameplate:GetFrameStrata())
	NazjatarFollowerXP:SetFrameLevel(5)
	NazjatarFollowerXP:CreateBackdrop("Transparent")
	NazjatarFollowerXP:SetStatusBarTexture(E.Libs.LSM:Fetch("statusbar", NP.db.statusbar))

	NP.StatusBars[NazjatarFollowerXP] = true

	return NazjatarFollowerXP
end

function NP:Update_NazjatarFollowerXP(nameplate)
	local db = NP.db.units[nameplate.frameType]
	if not db.nazjatarFollowerXP or not db.nazjatarFollowerXP.enable then
		if nameplate:IsElementEnabled("NazjatarFollowerXP") then
			nameplate:DisableElement("NazjatarFollowerXP")
		end
	else
		if not nameplate:IsElementEnabled("NazjatarFollowerXP") then
			nameplate:EnableElement("NazjatarFollowerXP")
		end

		nameplate.NazjatarFollowerXP:SetHeight(10)
		nameplate.NazjatarFollowerXP:SetPoint("TOPLEFT", nameplate.Castbar, "BOTTOMLEFT", 0, db.nazjatarFollowerXP.yOffset)
		nameplate.NazjatarFollowerXP:SetPoint("TOPRIGHT", nameplate.Castbar, "BOTTOMRIGHT", 0, db.nazjatarFollowerXP.yOffset)

		local color = db.nazjatarFollowerXP.color
		nameplate.NazjatarFollowerXP:SetStatusBarColor(color.r, color.g, color.b)
		nameplate.NazjatarFollowerXP.Rank:SetPoint("RIGHT", nameplate.NazjatarFollowerXP, "LEFT", -4, 0)
		nameplate.NazjatarFollowerXP.ProgressText:SetPoint("CENTER", nameplate.NazjatarFollowerXP, "CENTER")
		nameplate.NazjatarFollowerXP:ForceUpdate()
	end
end
