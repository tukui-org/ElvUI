local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local unpack = unpack
local strfind = strfind

local CreateFrame = CreateFrame

function NP:Construct_Auras(nameplate)
	local Auras = CreateFrame('Frame', '$parentAuras', nameplate)
	Auras:SetFrameStrata(nameplate:GetFrameStrata())
	Auras:SetFrameLevel(5)
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
	Auras.tickers = {} -- StyleFilters
	Auras.stacks = {}
	Auras.rows = {}

	local Buffs = CreateFrame('Frame', '$parentBuffs', nameplate)
	Buffs:SetFrameStrata(nameplate:GetFrameStrata())
	Buffs:SetFrameLevel(5)
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
	Buffs.tickers = {} -- StyleFilters
	Buffs.stacks = {}
	Buffs.rows = {}

	local Debuffs = CreateFrame('Frame', '$parentDebuffs', nameplate)
	Debuffs:SetFrameStrata(nameplate:GetFrameStrata())
	Debuffs:SetFrameLevel(5)
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
	Debuffs.tickers = {} -- StyleFilters
	Debuffs.stacks = {}
	Debuffs.rows = {}

	Auras.PreUpdate = UF.PreUpdateAura
	Auras.PreSetPosition = UF.SortAuras
	Auras.SetPosition = UF.SetPosition
	Auras.PostCreateButton = NP.Construct_AuraIcon
	Auras.PostUpdateButton = UF.PostUpdateAura
	Auras.CustomFilter = UF.AuraFilter

	Buffs.PreUpdate = UF.PreUpdateAura
	Buffs.PreSetPosition = UF.SortAuras
	Buffs.SetPosition = UF.SetPosition
	Buffs.PostCreateButton = NP.Construct_AuraIcon
	Buffs.PostUpdateButton = UF.PostUpdateAura
	Buffs.CustomFilter = UF.AuraFilter

	Debuffs.PreUpdate = UF.PreUpdateAura
	Debuffs.PreSetPosition = UF.SortAuras
	Debuffs.SetPosition = UF.SetPosition
	Debuffs.PostCreateButton = NP.Construct_AuraIcon
	Debuffs.PostUpdateButton = UF.PostUpdateAura
	Debuffs.CustomFilter = UF.AuraFilter

	nameplate.Auras_, nameplate.Buffs_, nameplate.Debuffs_ = Auras, Buffs, Debuffs
	nameplate.Auras, nameplate.Buffs, nameplate.Debuffs = Auras, Buffs, Debuffs
end

function NP:Construct_AuraIcon(button)
	if not button then return end

	button:SetTemplate(nil, nil, nil, nil, nil, true, true)

	button.Cooldown:SetReverse(true)
	button.Cooldown:SetInside(button)

	button.Icon:SetDrawLayer('ARTWORK')
	button.Icon:SetInside()

	button.Count:ClearAllPoints()
	button.Count:Point('BOTTOMRIGHT', 1, 1)
	button.Count:SetJustifyH('RIGHT')

	button.Overlay:SetTexture()
	button.Stealable:SetTexture()

	E:RegisterCooldown(button.Cooldown, 'nameplates')

	local auras = button:GetParent()
	if auras and auras.type then
		local db = NP:PlateDB(auras.__owner)
		button.db = db[auras.type]
	end

	NP:UpdateAuraSettings(button)
end

function NP:Configure_Auras(nameplate, which)
	local plateDB = NP:PlateDB(nameplate)
	local auras = nameplate[which]
	local auraType = which:lower()
	local db = plateDB[auraType]

	auras.size = db.size
	auras.height = not db.keepSizeRatio and db.height
	auras.numAuras = db.numAuras
	auras.numRows = db.numRows
	auras.onlyShowPlayer = false
	auras.spacing = db.spacing
	auras.growthY = UF.MatchGrowthY[db.anchorPoint] or db.growthY
	auras.growthX = UF.MatchGrowthX[db.anchorPoint] or db.growthX
	auras.xOffset = db.xOffset
	auras.yOffset = db.yOffset
	auras.anchorPoint = db.anchorPoint
	auras.auraSort = UF.SortAuraFuncs[db.sortMethod]
	auras.initialAnchor = E.InversePoints[db.anchorPoint]
	auras.filterList = UF:ConvertFilters(auras, db.priority)
	auras.smartPosition, auras.smartFluid = UF:SetSmartPosition(nameplate)
	auras.attachTo = UF:GetAuraAnchorFrame(nameplate, db.attachTo) -- keep below SetSmartPosition
	auras.num = db.numAuras * db.numRows
	auras.db = db -- for auraSort

	if which == 'Auras' then
		auras.filter = db.filter or 'HARMFUL'
	end

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

	auras:ClearAllPoints()
	auras:Point(auras.initialAnchor, auras.attachTo, auras.anchorPoint, auras.xOffset, auras.yOffset)
	auras:Size(db.numAuras * db.size + ((db.numAuras - 1) * db.spacing), 1)
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

		if db.auras.enable then
			nameplate.Auras = nameplate.Auras_
			NP:Configure_Auras(nameplate, 'Auras')
			nameplate.Auras:Show()
			nameplate.Auras:ForceUpdate()
		elseif nameplate.Auras then
			nameplate.Auras:Hide()
			nameplate.Auras = nil
		end

		if db.debuffs.enable then
			nameplate.Debuffs = nameplate.Debuffs_
			NP:Configure_Auras(nameplate, 'Debuffs')
			nameplate.Debuffs:Show()
			nameplate.Debuffs:ForceUpdate()
		elseif nameplate.Debuffs then
			nameplate.Debuffs:Hide()
			nameplate.Debuffs = nil
		end

		if db.buffs.enable then
			nameplate.Buffs = nameplate.Buffs_
			NP:Configure_Auras(nameplate, 'Buffs')
			nameplate.Buffs:Show()
			nameplate.Buffs:ForceUpdate()
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
			button.Count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
			button.Count:ClearAllPoints()
			button.Count:Point(point, db.countXOffset, db.countYOffset)
		end

		if button.Text then
			local point = db.sourceText.position or 'TOP'
			button.Text:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			button.Text:FontTemplate(LSM:Fetch('font', db.sourceText.font), db.sourceText.fontSize, db.sourceText.fontOutline)
			button.Text:ClearAllPoints()
			button.Text:Point(point or 'TOP', db.sourceText.xOffset, db.sourceText.yOffset)
		end
	end

	UF:CleanCache(button)

	button.needsButtonTrim = true
	button.needsUpdateCooldownPosition = true
end
