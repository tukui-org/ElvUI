local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')

local next = next
local unpack = unpack
local strfind = strfind
local strlower = strlower

local CreateFrame = CreateFrame

function NP:Construct_Auras(nameplate)
	local Auras, Buffs, Debuffs

	if E.Retail then
		Auras = E:Auras_Create(nameplate, 'Auras')
	else
		Auras = CreateFrame('Frame', '$parentAuras', nameplate)

		Auras:Size(1)
		Auras.size = 27
		Auras.num = 4
		Auras.spacing = E.Border * 2
		Auras.onlyShowPlayer = false
		Auras.disableMouse = true
		Auras.isNameplate = true
		Auras.initialAnchor = 'BOTTOMLEFT'
		Auras.growthX = 'RIGHT'
		Auras.growthY = 'UP'
		Auras.type = 'auras'
		Auras.forceShow = nameplate == NP.TestFrame
		Auras.stacks = {}
		Auras.rows = {}
	end

	if E.Retail then
		Buffs = E:Auras_Create(nameplate, 'Buffs')
	else
		Buffs = CreateFrame('Frame', '$parentBuffs', nameplate)

		Buffs:Size(1)
		Buffs.size = 27
		Buffs.num = 4
		Buffs.spacing = E.Border * 2
		Buffs.onlyShowPlayer = false
		Buffs.disableMouse = true
		Buffs.isNameplate = true
		Buffs.initialAnchor = 'BOTTOMLEFT'
		Buffs.growthX = 'RIGHT'
		Buffs.growthY = 'UP'
		Buffs.type = 'buffs'
		Buffs.forceShow = nameplate == NP.TestFrame
		Buffs.stacks = {}
		Buffs.rows = {}
	end

	if E.Retail then
		Debuffs = E:Auras_Create(nameplate, 'Debuffs')
	else
		Debuffs = CreateFrame('Frame', '$parentDebuffs', nameplate)

		Debuffs:Size(1)
		Debuffs.size = 27
		Debuffs.num = 4
		Debuffs.spacing = E.Border * 2
		Debuffs.onlyShowPlayer = false
		Debuffs.disableMouse = true
		Debuffs.isNameplate = true
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.growthX = 'RIGHT'
		Debuffs.growthY = 'UP'
		Debuffs.type = 'debuffs'
		Debuffs.forceShow = nameplate == NP.TestFrame
		Debuffs.stacks = {}
		Debuffs.rows = {}
	end

	Auras.PreUpdate = UF.PreUpdateAura
	Auras.PreSetPosition = UF.SortAuras
	Auras.SetPosition = UF.SetPosition
	Auras.PostCreateButton = NP.Construct_AuraIcon
	Auras.PostUpdateButton = UF.PostUpdateAura
	Auras.CustomFilter = NP.AuraFilter

	Buffs.PreUpdate = UF.PreUpdateAura
	Buffs.PreSetPosition = UF.SortAuras
	Buffs.SetPosition = UF.SetPosition
	Buffs.PostCreateButton = NP.Construct_AuraIcon
	Buffs.PostUpdateButton = UF.PostUpdateAura
	Buffs.CustomFilter = NP.AuraFilter

	Debuffs.PreUpdate = UF.PreUpdateAura
	Debuffs.PreSetPosition = UF.SortAuras
	Debuffs.SetPosition = UF.SetPosition
	Debuffs.PostCreateButton = NP.Construct_AuraIcon
	Debuffs.PostUpdateButton = UF.PostUpdateAura
	Debuffs.CustomFilter = NP.AuraFilter

	nameplate.Auras_, nameplate.Buffs_, nameplate.Debuffs_ = Auras, Buffs, Debuffs
	nameplate.Auras, nameplate.Buffs, nameplate.Debuffs = Auras, Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end

	button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	button.Icon:SetDrawLayer('ARTWORK')
	button.Icon:SetInside()

	button.Count:ClearAllPoints()
	button.Count:Point('BOTTOMRIGHT', 1, 1)
	button.Count:SetJustifyH('RIGHT')

	button.Overlay:SetTexture()
	button.Stealable:SetTexture()

	button.Cooldown:SetAllPoints(button.Icon)

	local auras = button:GetParent()
	local nameplate = auras:GetParent()

	local db = NP:PlateDB(nameplate)
	button.db = db[auras.type]

	E:RegisterCooldown(button.Cooldown, 'nameplates', nameplate.frameType, auras.type)

	NP:UpdateAuraSettings(button)
end

function NP:Configure_AuraUnit(nameplate)
	E:Auras_SetUnit(nameplate.Auras_, nameplate.unit)
	E:Auras_SetUnit(nameplate.Buffs_, nameplate.unit)
	E:Auras_SetUnit(nameplate.Debuffs_, nameplate.unit)
end

function NP:Configure_AuraUpdate(nameplate)
	E:Auras_UpdateButtons(nameplate.Auras_)
	E:Auras_UpdateButtons(nameplate.Buffs_)
	E:Auras_UpdateButtons(nameplate.Debuffs_)
end

function NP:Configure_AuraContainer(data, db)
	UF:UpdateFilters(data, db) -- attach the objects
	UF:GroupFilters(data, data.filter) -- build the groups

	local maxDuration = (db.maxDuration and db.maxDuration > 0) and db.maxDuration or nil
	local allowList = db.useAllowlist and E:Auras_GetFilter(E.global.unitframe.aurafilters, db.allowList or 'Whitelist') or nil
	local blockList = db.useBlocklist and E:Auras_GetFilter(E.global.unitframe.aurafilters, db.blockList or 'Blacklist') or nil
	local candidateFilters = E:Auras_CanidateFilters(allowList, blockList, maxDuration)

	return allowList, blockList, candidateFilters, maxDuration
end

function NP:Configure_AuraFilters(nameplate, which)
	local frameType = nameplate.frameType
	if not frameType then return end

	local obj = NP.AuraContainers[frameType]
	local info = obj and obj[which]
	if not info then return end

	return info.filter, info.filters, info.allowList, info.blockList, info.candidateFilters, info.maxDuration
end

do
	local types = { 'Auras', 'Debuffs', 'Buffs' }
	function NP:Configure_AuraContainers()
		for frameType, data in next, NP.AuraContainers do
			local plateDB = NP:PlateDB(nil, frameType)
			for _, which in next, types do
				local info = data[which]
				if not info then
					info = { filters = {} }
					data[which] = info
				end

				local auraType = strlower(which)
				local db = plateDB[auraType]
				if db then
					info.filter = NP:GetAuraFilter(which, db) -- keep before Configure_AuraContainer
					info.allowList, info.blockList, info.candidateFilters, info.maxDuration = NP:Configure_AuraContainer(info, db)
				end
			end
		end
	end
end

function NP:GetAuraFilter(which, db)
	if which == 'Auras' then -- this wont actually use helpful for blizzard auras its just to stop it from trying debuffs too
		return db.filter or 'HARMFUL'
	elseif E.Retail then
		return (which == 'Buffs' and 'HELPFUL') or 'HARMFUL'
	end
end

function NP:Configure_Auras(nameplate, which)
	local plateDB = NP:PlateDB(nameplate)
	local auras = nameplate[which]
	local auraType = strlower(which)
	local db = plateDB[auraType]

	auras.size = db.size
	auras.height = not db.keepSizeRatio and db.height
	auras.numAuras = db.numAuras
	auras.numRows = db.numRows
	auras.spacing = db.spacing
	auras.growthY = UF.MatchGrowthY[db.anchorPoint] or db.growthY
	auras.growthX = UF.MatchGrowthX[db.anchorPoint] or db.growthX
	auras.xOffset = db.xOffset
	auras.yOffset = db.yOffset
	auras.anchorPoint = db.anchorPoint
	auras.auraSort = UF.SortAuraFuncs[E.Retail and 'PLAYER' or db.sortMethod]
	auras.initialAnchor = E.InversePoints[db.anchorPoint]
	auras.filterList = UF:ConvertFilters(auras, db.priority)
	auras.smartPosition, auras.smartFluid = UF:SetSmartPosition(nameplate)
	auras.attachTo = UF:GetAuraAnchorFrame(nameplate, db.attachTo) -- keep below SetSmartPosition
	auras.num = db.numAuras * db.numRows
	auras.db = db -- for auraSort

	if E.Retail then
		auras.noMouse = true
		auras.keepSizeRatio = db.keepSizeRatio
		auras.maxFrameCount = auras.numAuras
		auras.sortMethod = E.AuraContainerSortMethod[db.sortMethod]
		auras.nameplateType = nameplate.frameType
		auras.countPosition, auras.countXOffset, auras.countYOffset = db.countPosition, db.countXOffset, db.countYOffset
		auras.countFont, auras.countFontSize, auras.countFontOutline = db.countFont, db.countFontSize, db.countFontOutline

		auras.filter, auras.filters, auras.allowList, auras.blockList, auras.candidateFilters, auras.maxDuration = NP:Configure_AuraFilters(nameplate, which)

		E:Auras_SetContainer(auras)
		E:Auras_SetLineSize(auras)
	else
		local index = 1
		while auras[index] do
			local button = auras[index]
			if button then
				button.db = db
				NP:UpdateAuraSettings(button)
				button:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end

			index = index + 1
		end

		auras:Size(db.numAuras * db.size + ((db.numAuras - 1) * db.spacing), 1)
	end

	auras:SetFrameLevel(7)
	auras:ClearAllPoints()
	auras:Point(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)
end

function NP:Update_Auras(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.auras.enable or db.debuffs.enable or db.buffs.enable then
		if not nameplate:IsElementEnabled('Auras') then
			nameplate:EnableElement('Auras')
		end

		nameplate.Auras_:ClearAllPoints()
		nameplate.Buffs_:ClearAllPoints()
		nameplate.Debuffs_:ClearAllPoints()

		if E.Retail then
			nameplate.Auras_:SetEnabled(db.auras.enable)
			nameplate.Debuffs_:SetEnabled(db.debuffs.enable)
			nameplate.Buffs_:SetEnabled(db.buffs.enable)
		end

		if db.auras.enable then
			nameplate.Auras = nameplate.Auras_
			NP:Configure_Auras(nameplate, 'Auras')
			nameplate.Auras:Show()
		elseif nameplate.Auras then
			nameplate.Auras:Hide()
			nameplate.Auras = nil
		end

		if db.debuffs.enable then
			nameplate.Debuffs = nameplate.Debuffs_
			NP:Configure_Auras(nameplate, 'Debuffs')
			nameplate.Debuffs:Show()
		elseif nameplate.Debuffs then
			nameplate.Debuffs:Hide()
			nameplate.Debuffs = nil
		end

		if db.buffs.enable then
			nameplate.Buffs = nameplate.Buffs_
			NP:Configure_Auras(nameplate, 'Buffs')
			nameplate.Buffs:Show()
		elseif nameplate.Buffs then
			nameplate.Buffs:Hide()
			nameplate.Buffs = nil
		end
	elseif nameplate:IsElementEnabled('Auras') then
		nameplate:DisableElement('Auras')
	end
end

function NP:UpdateAuraSettings(button)
	local db = button.db
	if db then
		if button.Count then
			local point = db.countPosition or 'CENTER'
			button.Count:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Count:FontTemplate(db.countFont, db.countFontSize, db.countFontOutline)
			button.Count:ClearAllPoints()
			button.Count:Point(point, db.countXOffset, db.countYOffset)
		end

		if button.Text then
			local point = db.sourceText.position or 'TOP'
			button.Text:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Text:FontTemplate(db.sourceText.font, db.sourceText.fontSize, db.sourceText.fontOutline)
			button.Text:ClearAllPoints()
			button.Text:Point(point or 'TOP', db.sourceText.xOffset, db.sourceText.yOffset)
		end
	end

	button.needsButtonTrim = true

	UF:UpdateFilters(button)
end
