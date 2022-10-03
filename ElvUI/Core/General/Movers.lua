local E, L, V, P, G = unpack(ElvUI)
local Sticky = E.Libs.SimpleSticky

local _G = _G
local type, unpack, pairs, error, ipairs = type, unpack, pairs, error, ipairs
local format, split, find, strupper = format, strsplit, strfind, strupper

local UIParent = UIParent
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local hooksecurefunc = hooksecurefunc

E.CreatedMovers = {}
E.DisabledMovers = {}

local function SizeChanged(frame, width, height)
	if InCombatLockdown() then return end
	frame.mover:SetSize(width, height)
end

local function WidthChanged(frame, width)
	if InCombatLockdown() then return end
	frame.mover:SetWidth(width)
end

local function HeightChanged(frame, height)
	if InCombatLockdown() then return end
	frame.mover:SetHeight(height)
end

local function GetPoint(obj)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = UIParent end

	return format('%s,%s,%s,%d,%d', point, anchor:GetName(), secondaryPoint, x and E:Round(x) or 0, y and E:Round(y) or 0)
end

local function GetSettingPoints(name)
	local db = E.db.movers and E.db.movers[name]
	if db then
		local delim = (find(db, '\031') and '\031') or ','
		return split(delim, db)
	end
end

local function UpdateCoords(self)
	local mover = self.child
	local x, y, _, nudgePoint, nudgeInversePoint = E:CalculateMoverPoints(mover)
	local coordX, coordY = E:GetXYOffset(nudgeInversePoint, 1)
	local nudgeFrame = _G.ElvUIMoverNudgeWindow

	nudgeFrame:ClearAllPoints()
	nudgeFrame:SetPoint(nudgePoint, mover, nudgeInversePoint, coordX, coordY)
	E:UpdateNudgeFrame(mover, x, y)
end

function E:SetMoverPoints(name, parent)
	local holder = E.CreatedMovers[name]
	if not holder then return end

	local point1, relativeTo1, relativePoint1, xOffset1, yOffset1 = unpack(holder.parentPoint)
	local point2, relativeTo2, relativePoint2, xOffset2, yOffset2 = GetSettingPoints(name)
	if not _G[relativeTo2] then -- fallback to the parents original point (on create) if the setting doesn't exist
		point2, relativeTo2, relativePoint2, xOffset2, yOffset2 = point1, relativeTo1, relativePoint1, xOffset1, yOffset1
	end

	if point2 then
		holder.mover:ClearAllPoints()
		holder.mover:SetPoint(point2, relativeTo2, relativePoint2, xOffset2, yOffset2)
	end

	if parent then
		parent:ClearAllPoints()
		parent:SetPoint(point1, parent.mover, 0, 0)
	end
end

local isDragging = false
local coordFrame = CreateFrame('Frame')
coordFrame:SetScript('OnUpdate', UpdateCoords)
coordFrame:Hide()

local function HandlePostDrag(self, event)
	if self.postdrag and type(self.postdrag) == 'function' then
		self.postdrag(self, E:GetScreenQuadrant(self))
	end

	if event then
		self:UnregisterAllEvents()
	end
end

local function OnDragStart(self)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	if _G.ElvUIGrid then
		E:UIFrameFadeIn(_G.ElvUIGrid, 0.75, _G.ElvUIGrid:GetAlpha(), 1)
	end

	Sticky:StartMoving(self, E.db.general.stickyFrames and E.snapBars, self.snapOffset, self.snapOffset, self.snapOffset, self.snapOffset)

	coordFrame.child = self
	coordFrame:Show()
	isDragging = true
end

local function OnDragStop(self)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end

	if _G.ElvUIGrid and E.ConfigurationMode then
		E:UIFrameFadeOut(_G.ElvUIGrid, 0.75, _G.ElvUIGrid:GetAlpha(), 0.4)
	end

	Sticky:StopMoving(self)

	local x2, y2, p2 = E:CalculateMoverPoints(self)
	self:ClearAllPoints()
	self:SetPoint(p2, UIParent, p2, x2, y2)

	E:SaveMoverPosition(self.name)

	coordFrame.child = nil
	coordFrame:Hide()
	isDragging = false

	HandlePostDrag(self)

	self:SetUserPlaced(false)
end

local function OnEnter(self)
	if isDragging then return end

	for _, frame in pairs(E.CreatedMovers) do
		local mover = frame.mover
		if mover:IsShown() and mover ~= self then
			E:UIFrameFadeOut(mover, 0.75, mover:GetAlpha(), 0.5)
		end
	end

	E.AssignFrameToNudge(self)

	coordFrame.child = self
	coordFrame:GetScript('OnUpdate')(coordFrame)

	self.text:SetTextColor(1, 1, 1)
end

local function OnLeave(self)
	if isDragging then return end

	for _, frame in pairs(E.CreatedMovers) do
		local mover = frame.mover
		if mover:IsShown() and mover ~= self then
			E:UIFrameFadeIn(mover, 0.75, mover:GetAlpha(), 1)
		end
	end

	self.text:SetTextColor(unpack(E.media.rgbvaluecolor))
end

local function OnMouseUp(_, button)
	if button == 'LeftButton' and not isDragging then
		_G.ElvUIMoverNudgeWindow:SetShown(not _G.ElvUIMoverNudgeWindow:IsShown())
	end
end

local function OnMouseDown(self, button)
	if isDragging then
		OnDragStop(self)
	elseif button == 'RightButton' then
		if IsControlKeyDown() and self.textString then
			E:ResetMovers(self.textString) --Allow resetting of anchor by Ctrl+RightClick
		elseif IsShiftKeyDown() then
			self:Hide() --Allow hiding a mover temporarily
		elseif self.configString then
			E:ToggleOptionsUI(self.configString) --OpenConfig
		end
	end
end

local function OnMouseWheel(_, delta)
	if IsShiftKeyDown() then
		E:NudgeMover(delta)
	else
		E:NudgeMover(nil, delta)
	end
end

local function OnShow(self, r, g, b)
	if not r then r, g, b = unpack(E.media.rgbvaluecolor) end

	self.text:FontTemplate()
	self.text:SetTextColor(r, g, b)

	self:SetBackdropBorderColor(r, g, b)
	self.forcedBorderColors = {r, g, b}
end

local function UpdateColors()
	local r, g, b = unpack(E.media.rgbvaluecolor)
	for _, holder in pairs(E.CreatedMovers) do
		OnShow(holder.mover, r, g, b)
	end
end
E.valueColorUpdateFuncs[UpdateColors] = true

local function UpdateMover(name, parent, textString, overlay, snapOffset, postdrag, shouldDisable, configString, ignoreSizeChanged)
	if not (name and parent) then return end --If for some reason the parent isnt loaded yet, also require a name

	local holder = E.CreatedMovers[name]
	if holder.Created then return end
	holder.Created = true

	if overlay == nil then overlay = true end

	local f = CreateFrame('Button', name, UIParent)
	f:SetClampedToScreen(true)
	f:RegisterForDrag('LeftButton', 'RightButton')
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetFrameStrata(overlay and 'DIALOG' or 'BACKGROUND')
	f:EnableMouseWheel(true)
	f:SetMovable(true)
	f:SetTemplate('Transparent', nil, nil, true)
	f:SetSize(parent:GetSize())
	f:Hide()

	local fs = f:CreateFontString(nil, 'OVERLAY')
	fs:FontTemplate()
	fs:SetPoint('CENTER')
	fs:SetText(textString or name)
	fs:SetJustifyH('CENTER')
	fs:SetTextColor(unpack(E.media.rgbvaluecolor))
	f:SetFontString(fs)

	f.text = fs
	f.name = name
	f.parent = parent
	f.overlay = overlay
	f.postdrag = postdrag
	f.textString = textString or name
	f.snapOffset = snapOffset or -2
	f.shouldDisable = shouldDisable
	f.configString = configString
	f.ignoreSizeChanged = ignoreSizeChanged

	holder.mover = f
	parent.mover = f
	E.snapBars[#E.snapBars+1] = f

	if not ignoreSizeChanged then
		hooksecurefunc(parent, 'SetSize', SizeChanged)
		hooksecurefunc(parent, 'SetWidth', WidthChanged)
		hooksecurefunc(parent, 'SetHeight', HeightChanged)
	end

	E:SetMoverPoints(name, parent)

	f:SetScript('OnDragStart', OnDragStart)
	f:SetScript('OnDragStop', OnDragStop)
	f:SetScript('OnEnter', OnEnter)
	f:SetScript('OnLeave', OnLeave)
	f:SetScript('OnMouseDown', OnMouseDown)
	f:SetScript('OnMouseUp', OnMouseUp)
	f:SetScript('OnMouseWheel', OnMouseWheel)
	f:SetScript('OnShow', OnShow)
	f:SetScript('OnEvent', HandlePostDrag)
	f:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function E:CalculateMoverPoints(mover, nudgeX, nudgeY)
	local centerX, centerY = UIParent:GetCenter()
	local width = UIParent:GetRight()
	local x, y = mover:GetCenter()

	local point, nudgePoint, nudgeInversePoint = 'BOTTOM', 'BOTTOM', 'TOP'
	if y >= centerY then -- TOP: 1080p = 540
		point, nudgePoint, nudgeInversePoint = 'TOP', 'TOP', 'BOTTOM'
		y = -(UIParent:GetTop() - mover:GetTop())
	else
		y = mover:GetBottom()
	end

	if x >= (width * 2 / 3) then -- RIGHT: 1080p = 1280
		point, nudgePoint, nudgeInversePoint = point..'RIGHT', 'RIGHT', 'LEFT'
		x = mover:GetRight() - width
	elseif x <= (width / 3) then -- LEFT: 1080p = 640
		point, nudgePoint, nudgeInversePoint = point..'LEFT', 'LEFT', 'RIGHT'
		x = mover:GetLeft()
	else
		x = x - centerX
	end

	--Update coordinates if nudged
	x = x + (nudgeX or 0)
	y = y + (nudgeY or 0)

	return x, y, point, nudgePoint, nudgeInversePoint
end

function E:HasMoverBeenMoved(name)
	return E.db.movers and E.db.movers[name]
end

function E:SaveMoverPosition(name)
	local holder = E.CreatedMovers[name]
	if not holder then return end
	if not E.db.movers then E.db.movers = {} end
	E.db.movers[name] = GetPoint(holder.mover)
end

function E:SetMoverSnapOffset(name, offset)
	local holder = E.CreatedMovers[name]
	if not holder then return end
	holder.mover.snapOffset = offset or -2
	holder.snapoffset = offset or -2
end

function E:SetMoverLayoutPositionPoint(holder, name, parent)
	local layout = E.LayoutMoverPositions[E.db.layoutSetting]
	local layoutPoint = (layout and layout[name]) or E.LayoutMoverPositions.ALL[name]
	holder.layoutPoint = layoutPoint
	holder.point = layoutPoint or GetPoint(parent or holder.mover)

	if parent then -- CreateMover call
		holder.parentPoint = {parent:GetPoint()}
	end
end

function E:SaveMoverDefaultPosition(name)
	local holder = E.CreatedMovers[name]
	if not holder then return end

	E:SetMoverLayoutPositionPoint(holder, name)

	HandlePostDrag(holder.mover)
end

function E:CreateMover(parent, name, textString, overlay, snapoffset, postdrag, types, shouldDisable, configString, ignoreSizeChanged)
	local holder = E.CreatedMovers[name]
	if holder == nil then
		holder = {}
		holder.types = {}

		if types then
			for _, x in ipairs({split(',', types)}) do
				holder.types[x] = true
			end
		else
			holder.types.ALL = true
			holder.types.GENERAL = true
		end

		E:SetMoverLayoutPositionPoint(holder, name, parent)
		E.CreatedMovers[name] = holder
	end

	UpdateMover(name, parent, textString, overlay, snapoffset, postdrag, shouldDisable, configString, ignoreSizeChanged)
end

function E:ToggleMovers(show, which)
	self.configMode = show

	local upperText = strupper(which)
	for _, holder in pairs(E.CreatedMovers) do
		local isName = (holder.mover.name == which) or strupper(holder.mover.textString) == upperText
		if show and (isName or holder.types[upperText]) then
			holder.mover:Show()
		else
			holder.mover:Hide()
		end
	end
end

function E:GetMoverHolder(name)
	local created = self.CreatedMovers[name]
	local disabled = self.DisabledMovers[name]
	return created or disabled, not not disabled
end

function E:DisableMover(name)
	if self.DisabledMovers[name] then return end

	local holder = self.CreatedMovers[name]
	if not holder then
		error(format('mover %s doesnt exist', name or 'nil'))
	end

	self.DisabledMovers[name] = {}
	for x, y in pairs(holder) do
		self.DisabledMovers[name][x] = y
	end

	if self.configMode then
		holder.mover:Hide()
	end

	self.CreatedMovers[name] = nil
end

function E:EnableMover(name)
	if self.CreatedMovers[name] then return end

	local holder = self.DisabledMovers[name]
	if not holder then
		error(format('mover %s doesnt exist', name or 'nil'))
	end

	self.CreatedMovers[name] = {}
	for x, y in pairs(holder) do
		self.CreatedMovers[name][x] = y
	end

	if self.configMode then
		holder.mover:Show()
	end

	self.DisabledMovers[name] = nil
end

function E:ResetMovers(arg)
	local all = not arg or arg == ''
	if all then self.db.movers = nil end

	for name, holder in pairs(E.CreatedMovers) do
		if all or (holder.mover and holder.mover.textString == arg) then
			local point, anchor, secondaryPoint, x, y = split(',', holder.point)

			local frame = holder.mover
			if point then
				frame:ClearAllPoints()
				frame:SetPoint(point, anchor, secondaryPoint, x, y)
			end

			HandlePostDrag(frame)

			if all then
				E:SaveMoverPosition(name)
			else
				if holder.layoutPoint then
					E:SaveMoverPosition(name)
				elseif self.db.movers then
					self.db.movers[name] = nil
				end
				break
			end
		end
	end
end

--Profile Change
function E:SetMoversPositions()
	--E:SetMoversPositions() is the first function called in E:StaggeredUpdateAll().
	--Because of that, we can allow ourselves to re-enable all disabled movers here,
	--as the subsequent updates to these elements will disable them again if needed.
	for name in pairs(E.DisabledMovers) do
		local disable = E.DisabledMovers[name].shouldDisable
		local shouldDisable = (disable and disable()) or false
		if not shouldDisable then E:EnableMover(name) end
	end

	for name in pairs(E.CreatedMovers) do
		E:SetMoverPoints(name)
	end
end

function E:SetMoversClampedToScreen(value)
	for _, holder in pairs(E.CreatedMovers) do
		holder.mover:SetClampedToScreen(value)
	end
end

function E:LoadMovers()
	for n, t in pairs(E.CreatedMovers) do
		UpdateMover(n, t.parent, t.textString, t.overlay, t.snapoffset, t.postdrag, t.shouldDisable, t.configString, t.ignoreSizeChanged)
	end
end
