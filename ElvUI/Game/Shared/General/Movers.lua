local E, L, V, P, G = unpack(ElvUI)
local Sticky = E.Libs.SimpleSticky

local _G = _G
local type, unpack, pairs, error, ipairs = type, unpack, pairs, error, ipairs
local format, next, split, find, strupper = format, next, strsplit, strfind, strupper

local UIParent = UIParent
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local hooksecurefunc = hooksecurefunc

E.CreatedMovers = {}
E.DisabledMovers = {}
E.ConnectedMovers = {}

local function SizeChanged(parent, width, height)
	if InCombatLockdown() then return end
	parent.mover:SetSize(width, height)
end

local function WidthChanged(parent, width)
	if InCombatLockdown() then return end
	parent.mover:SetWidth(width)
end

local function HeightChanged(parent, height)
	if InCombatLockdown() then return end
	parent.mover:SetHeight(height)
end

local function GetPoint(obj)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = UIParent end

	return format('%s,%s,%s,%d,%d', point, anchor:GetName(), secondaryPoint, x and E:Round(x) or 0, y and E:Round(y) or 0)
end

local function GetSettingPoints(text)
	if not text then return end

	local delim = (find(text, '\031') and '\031') or ','
	return split(delim, text)
end

local function UpdateCoords(frame)
	local mover = frame.child
	local x, y, _, nudgePoint, nudgeInversePoint = E:CalculateMoverPoints(mover)
	local coordX, coordY = E:GetXYOffset(nudgeInversePoint, 1)

	E.MoverNudgeFrame:ClearAllPoints()
	E.MoverNudgeFrame:SetPoint(nudgePoint, mover, nudgeInversePoint, coordX, coordY)
	E:UpdateNudgeFrame(mover, x, y)
end

function E:SetMoverPoints(name, parent)
	local holder = E.CreatedMovers[name]
	if not holder then return end

	local point1, relativeTo1, relativePoint1, xOffset1, yOffset1 = unpack(holder.originPoint)
	local point2, relativeTo2, relativePoint2, xOffset2, yOffset2 = GetSettingPoints(E.db.movers and E.db.movers[name] or E:GetMoverLayout(name))
	if not _G[relativeTo2] then -- fallback to the parents original point (on create) if the setting doesn't exist
		point2, relativeTo2, relativePoint2, xOffset2, yOffset2 = point1, relativeTo1, relativePoint1, xOffset1, yOffset1
	end

	if point2 then
		holder.mover:ClearAllPoints()
		holder.mover:SetPoint(point2, relativeTo2, relativePoint2, xOffset2, yOffset2)
	end

	if parent then
		parent:ClearAllPoints()
		parent:SetPoint(point1, parent.mover, nil, 0, 0)
	end
end

local isDragging = false
local coordFrame = CreateFrame('Frame')
coordFrame:SetScript('OnUpdate', UpdateCoords)
coordFrame:Hide()

local function HandlePostDrag(frame, event)
	if frame.postdrag and type(frame.postdrag) == 'function' then
		frame.postdrag(frame, E:GetScreenQuadrant(frame))
	end

	if event then
		frame:UnregisterAllEvents()
	end
end

local function StartMoving(mover, anchor)
	local offset = mover.snapOffset
	Sticky:StartMoving(mover, E.db.general.stickyFrames and E.snapBars, offset, offset, offset, offset, anchor)
end

local function OnDragStart(frame)
	if E:AlertCombat() then return end

	if _G.ElvUIGrid then
		E:UIFrameFadeIn(_G.ElvUIGrid, 0.75, _G.ElvUIGrid:GetAlpha(), 1)
	end

	if next(E.ConnectedMovers) then
		for mover in next, E.ConnectedMovers do
			StartMoving(mover, frame)
		end
	else
		StartMoving(frame)
	end

	coordFrame.child = frame
	coordFrame:Show()

	isDragging = true
end

local function StopMoving(frame)
	Sticky:StopMoving(frame)

	local x2, y2, p2 = E:CalculateMoverPoints(frame)
	frame:ClearAllPoints()
	frame:SetPoint(p2, UIParent, p2, x2, y2)

	E:SaveMoverPosition(frame.name)

	HandlePostDrag(frame)

	frame:SetUserPlaced(false)
end

local function OnDragStop(frame)
	if E:AlertCombat() then return end

	if _G.ElvUIGrid and E.ConfigurationMode then
		E:UIFrameFadeOut(_G.ElvUIGrid, 0.75, _G.ElvUIGrid:GetAlpha(), 0.4)
	end

	coordFrame.child = nil
	coordFrame:Hide()

	isDragging = false

	if next(E.ConnectedMovers) then
		local r, g, b = unpack(E.media.rgbvaluecolor)
		for mover in next, E.ConnectedMovers do
			StopMoving(mover)

			mover.text:SetTextColor(r, g, b)
			mover:SetBackdropBorderColor(r, g, b)

			mover.IsConnected = nil
			E.ConnectedMovers[mover] = nil
		end
	else
		StopMoving(frame)
	end
end

local function OnEnter(frame)
	if isDragging then return end

	for _, holder in pairs(E.CreatedMovers) do
		local mover = holder.mover
		if mover:IsShown() and mover ~= frame then
			E:UIFrameFadeOut(mover, 0.75, mover:GetAlpha(), 0.5)
		end
	end

	E.AssignFrameToNudge(frame)

	coordFrame.child = frame
	coordFrame:GetScript('OnUpdate')(coordFrame)

	if not frame.IsConnected then
		frame.text:SetTextColor(1, 1, 1)
	end
end

local function OnLeave(frame)
	if isDragging then return end

	for _, holder in pairs(E.CreatedMovers) do
		local mover = holder.mover
		if mover:IsShown() and mover ~= frame then
			E:UIFrameFadeIn(mover, 0.75, mover:GetAlpha(), 1)
		end
	end

	if not frame.IsConnected then
		local r, g, b = unpack(E.media.rgbvaluecolor)
		frame.text:SetTextColor(r, g, b)
	end
end

local function OnMouseUp(_, button)
	if button == 'LeftButton' and not isDragging and not IsShiftKeyDown() then
		E.MoverNudgeFrame:SetShown(not E.MoverNudgeFrame:IsShown())
	end
end

local function OnMouseDown(frame, button)
	if isDragging then
		OnDragStop(frame)
	elseif button == 'RightButton' then
		if IsControlKeyDown() and frame.textString then
			E:ResetMovers(frame.textString) --Allow resetting of anchor by Ctrl+RightClick
		elseif IsShiftKeyDown() then
			frame:Hide() --Allow hiding a mover temporarily
		elseif frame.configString then
			E:ToggleOptions(frame.configString) --OpenConfig
		end
	elseif IsShiftKeyDown() then
	--	E.ConnectedMovers[frame] = true
	--	frame.IsConnected = true

	--	frame.text:SetTextColor(1, 0.3, 0.3)
	--	frame:SetBackdropBorderColor(1, 0.3, 0.3)
	end
end

local function OnMouseWheel(_, delta)
	if IsShiftKeyDown() then
		E:NudgeMover(delta)
	else
		E:NudgeMover(nil, delta)
	end
end

local function OnShow(frame, r, g, b)
	if not r then
		r, g, b = unpack(E.media.rgbvaluecolor)
	end

	frame.text:FontTemplate()
	frame.text:SetTextColor(r, g, b)

	frame:SetBackdropBorderColor(r, g, b)

	E:ForceBorderColor(frame, r, g, b)
end

local function UpdateColors(_, _, r, g, b)
	for _, holder in pairs(E.CreatedMovers) do
		if holder.mover:IsShown() then -- hidden movers take the color in OnShow
			OnShow(holder.mover, r, g, b)
		end
	end
end
E.valueColorUpdateFuncs.Movers = UpdateColors

local function SetSnapOffset(holder, snapOffset)
	local offset = snapOffset or -2

	holder.mover.snapOffset = offset
	holder.snapOffset = offset
end

function E:SetMoverSnapOffset(name, snapOffset)
	local holder = E.CreatedMovers[name]
	if not holder then return end

	SetSnapOffset(holder, snapOffset)
end

local function UpdateMover(name, parent, textString, overlay, snapOffset, postdrag, shouldDisable, configString, ignoreSizeChanged)
	if not (name and parent) then return end --If for some reason the parent isnt loaded yet, also require a name

	local holder = E.CreatedMovers[name]
	if holder.Created then return end
	holder.Created = true

	if overlay == nil or overlay == true then
		overlay = 'DIALOG'
	elseif overlay == false then
		overlay = 'BACKGROUND'
	end

	local mover = CreateFrame('Button', name, UIParent)
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag('LeftButton', 'RightButton')
	mover:OffsetFrameLevel(1, parent)
	mover:SetFrameStrata(overlay)
	mover:EnableMouseWheel(true)
	mover:SetMovable(true)
	mover:SetTemplate('Transparent', nil, nil, true)
	mover:SetSize(parent:GetSize())
	mover:Hide()

	local r, g, b = unpack(E.media.rgbvaluecolor)
	local text = mover:CreateFontString(nil, 'OVERLAY')
	text:FontTemplate()
	text:SetPoint('CENTER')
	text:SetText(textString or name)
	text:SetJustifyH('CENTER')
	text:SetTextColor(r, g, b)
	mover:SetFontString(text)

	mover.text = text
	mover.name = name
	mover.parent = parent
	mover.overlay = overlay
	mover.postdrag = postdrag
	mover.textString = textString or name
	mover.configString = configString
	mover.ignoreSizeChanged = ignoreSizeChanged

	holder.shouldDisable = type(shouldDisable) == 'function' and shouldDisable or nil

	holder.mover = mover
	parent.mover = mover
	E.snapBars[#E.snapBars+1] = mover

	SetSnapOffset(holder, snapOffset)

	if not ignoreSizeChanged then
		hooksecurefunc(parent, 'SetSize', SizeChanged)
		hooksecurefunc(parent, 'SetWidth', WidthChanged)
		hooksecurefunc(parent, 'SetHeight', HeightChanged)
	end

	E:SetMoverPoints(name, parent)

	mover:SetScript('OnDragStart', OnDragStart)
	mover:SetScript('OnDragStop', OnDragStop)
	mover:SetScript('OnEnter', OnEnter)
	mover:SetScript('OnLeave', OnLeave)
	mover:SetScript('OnMouseDown', OnMouseDown)
	mover:SetScript('OnMouseUp', OnMouseUp)
	mover:SetScript('OnMouseWheel', OnMouseWheel)
	mover:SetScript('OnShow', OnShow)
	mover:SetScript('OnEvent', HandlePostDrag)
	mover:RegisterEvent('PLAYER_ENTERING_WORLD')
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

function E:GetMoverLayout(name)
	local holder = E.CreatedMovers[name]
	if not holder then return end

	local layout, all = E.LayoutMoverPositions[E.db.layoutSet], E.LayoutMoverPositions.ALL
	return (layout and layout[name]) or (all and all[name])
end

function E:SaveMoverPosition(name)
	local holder = E.CreatedMovers[name]
	if not holder then return end
	if not E.db.movers then E.db.movers = {} end
	E.db.movers[name] = GetPoint(holder.mover)
end

function E:CreateMover(parent, name, textString, overlay, snapOffset, postdrag, types, shouldDisable, configString, ignoreSizeChanged)
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

		holder.parent = parent
		holder.originPoint = { parent:GetPoint() }

		E.CreatedMovers[name] = holder
	end

	UpdateMover(name, parent, textString, overlay, snapOffset, postdrag, shouldDisable, configString, ignoreSizeChanged)

	return holder
end

function E:ToggleMovers(show, which)
	E.configMode = show

	local upperText = strupper(which)
	for _, holder in pairs(E.CreatedMovers) do
		local isName = (holder.mover.name == which) or strupper(holder.mover.textString) == upperText
		holder.mover:SetShown(show and (isName or holder.types[upperText]))

		holder.mover.IsConnected = nil
		E.ConnectedMovers[holder.mover] = nil
	end
end

function E:GetMoverHolder(name)
	local created = E.CreatedMovers[name]
	local disabled = E.DisabledMovers[name]
	return created or disabled, not not disabled
end

function E:DisableMover(name)
	if E.DisabledMovers[name] then return end

	local holder = E.CreatedMovers[name]
	if not holder then
		error(format('mover %s doesnt exist', name or 'nil'))
	end

	E.DisabledMovers[name] = {}
	for x, y in pairs(holder) do
		E.DisabledMovers[name][x] = y
	end

	if E.configMode then
		holder.mover:Hide()
	end

	E.CreatedMovers[name] = nil
end

function E:EnableMover(name)
	if E.CreatedMovers[name] then return end

	local holder = E.DisabledMovers[name]
	if not holder then
		error(format('mover %s doesnt exist', name or 'nil'))
	end

	E.CreatedMovers[name] = {}
	for x, y in pairs(holder) do
		E.CreatedMovers[name][x] = y
	end

	if E.configMode then
		holder.mover:Show()
	end

	E.DisabledMovers[name] = nil
end

function E:ResetMovers(arg)
	local all = not arg or arg == ''
	if all then E.db.movers = nil end

	for name, holder in pairs(E.CreatedMovers) do
		if all or (holder.mover and holder.mover.textString == arg) then
			if E.db.movers then
				E.db.movers[name] = nil
			end

			E:SetMoverPoints(name)

			if holder.mover then
				HandlePostDrag(holder.mover)
			end

			if not all then
				break
			end
		end
	end
end

--Profile Change
function E:SetMoversPositions()
	--E:SetMoversPositions() is the first function called in E:UpdateAll().
	--Because of that, we can allow ourselves to re-enable all disabled movers here,
	--as the subsequent updates to these elements will disable them again if needed.
	for name, holder in pairs(E.DisabledMovers) do
		local check = holder.shouldDisable
		local disable = check and check()
		if not disable then E:EnableMover(name) end
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
	for n, h in pairs(E.CreatedMovers) do
		UpdateMover(n, h.parent, h.textString, h.overlay, h.snapOffset, h.postdrag, h.shouldDisable, h.configString, h.ignoreSizeChanged)
	end
end
