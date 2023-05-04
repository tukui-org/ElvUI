local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule('Misc')
local LSM = E.Libs.LSM

local _G = _G
local mod = mod
local floor = floor
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetTime = GetTime

function M:QueueStatusTimeFormat(seconds)
	local hours = floor(mod(seconds,86400)/3600)
	if hours > 0 then return M.QueueStatusDisplay.text:SetFormattedText('%dh', hours) end

	local mins = floor(mod(seconds,3600)/60)
	if mins > 0 then return M.QueueStatusDisplay.text:SetFormattedText('%dm', mins) end

	local secs = mod(seconds,60)
	if secs > 0 then return M.QueueStatusDisplay.text:SetFormattedText('%ds', secs) end
end

function M:QueueStatusSetTime(seconds)
	local timeInQueue = GetTime() - seconds
	M:QueueStatusTimeFormat(timeInQueue)

	local wait = M.QueueStatusDisplay.averageWait
	local waitTime = wait and wait > 0 and (timeInQueue / wait)
	if not waitTime or waitTime >= 1 then
		M.QueueStatusDisplay.text:SetTextColor(1, 1, 1)
	else
		M.QueueStatusDisplay.text:SetTextColor(E:ColorGradient(waitTime, 1,.1,.1, 1,1,.1, .1,1,.1))
	end
end

function M:QueueStatusOnUpdate(elapsed)
	-- Replicate QueueStatusEntry_OnUpdate throttle
	self.updateThrottle = self.updateThrottle - elapsed
	if self.updateThrottle <= 0 then
		M:QueueStatusSetTime(self.queuedTime)
		self.updateThrottle = 0.1
	end
end

function M:SetFullQueueStatus(title, queuedTime, averageWait)
	local db = E.db.general.queueStatus
	if not db or not db.enable then return end

	local display = M.QueueStatusDisplay
	if not display.title or display.title == title then
		if queuedTime then
			display.title = title
			display.updateThrottle = 0
			display.queuedTime = queuedTime
			display.averageWait = averageWait
			display:SetScript('OnUpdate', M.QueueStatusOnUpdate)
		else
			M:ClearQueueStatus()
		end
	end
end

function M:SetMinimalQueueStatus(title)
	if M.QueueStatusDisplay.title == title then
		M:ClearQueueStatus()
	end
end

function M:ClearQueueStatus()
	local display = M.QueueStatusDisplay
	display.text:SetText('')
	display.title = nil
	display.queuedTime = nil
	display.averageWait = nil
	display:SetScript('OnUpdate', nil)
end

function M:CreateQueueStatusText()
	local display = CreateFrame('Frame', 'ElvUIQueueStatusDisplay', _G.QueueStatusButton)
	display:SetIgnoreParentScale(true)
	display:SetScale(E.uiscale)
	display.text = display:CreateFontString(nil, 'OVERLAY')
	display.text:FontTemplate()

	M.QueueStatusDisplay = display

	_G.QueueStatusButton:HookScript('OnHide', M.ClearQueueStatus)
	hooksecurefunc('QueueStatusEntry_SetMinimalDisplay', M.SetMinimalQueueStatus)
	hooksecurefunc('QueueStatusEntry_SetFullDisplay', M.SetFullQueueStatus)
end

function M:QueueStatusReposition(_, anchor)
	if anchor ~= M.QueueStatus then
		self:ClearAllPoints()
		self:Point('CENTER', M.QueueStatus)
	end
end

function M:QueueStatusReparent(parent)
	if parent ~= M.QueueStatus then
		self:SetParent(M.QueueStatus)
	end
end

function M:QueueStatusRescale(eyesize)
	local scale = E.db.general.queueStatus.scale * (E.Retail and 1 or 2)
	if eyesize ~= scale then
		self:SetScale(scale)

		local width, height = self:GetSize()
		local status = scale * (E.Retail and 1.3 or 1) -- account for the border on retail
		M.QueueStatus:SetSize(width * status, height * status)
	end
end

function M:HandleQueueStatus(creation)
	local queueButton = M:GetQueueStatusButton()
	if not queueButton then return end

	if creation then
		hooksecurefunc(queueButton, 'SetParent', M.QueueStatusReparent)
		hooksecurefunc(queueButton, 'SetPoint', M.QueueStatusReposition)
		hooksecurefunc(queueButton, 'SetScale', M.QueueStatusRescale)

		queueButton:SetIgnoreParentScale(true)
	end

	local db = E.db.general.queueStatus
	queueButton:SetFrameStrata(db.frameStrata)
	queueButton:SetFrameLevel(db.frameLevel)
	queueButton:SetPoint('CENTER') -- trigger the hook
	queueButton:SetScale(1) -- trigger the scale

	local queueDisplay = M.QueueStatusDisplay
	if queueDisplay then
		queueDisplay.text:ClearAllPoints()
		queueDisplay.text:Point(db.position, queueButton, db.xOffset, db.yOffset)
		queueDisplay.text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize, db.fontOutline)

		if not db.enable and queueDisplay.title then
			M:ClearQueueStatus()
		end
	end
end

function M:GetQueueStatusButton()
	return _G.QueueStatusButton or _G.MiniMapLFGFrame
end

function M:LoadQueueStatus()
	if (E.Retail and not E.private.actionbar.enable) and not E.private.general.queueStatus then return end

	M.QueueStatus = CreateFrame('Frame', 'ElvUIQueueStatus', E.UIParent)
	M.QueueStatus:Point('BOTTOMRIGHT', _G.ElvUI_MinimapHolder or _G.Minimap, 'BOTTOMRIGHT', -5, 25)
	M.QueueStatus:SetFrameLevel(10) -- over minimap mover
	M.QueueStatus:Size(32)
	E:CreateMover(M.QueueStatus, 'QueueStatusMover', L["Queue Status"], nil, nil, nil, nil, nil, 'general,blizzUIImprovements,queueStatus')

	if E.Retail then
		_G.QueueStatusFrame:SetClampedToScreen(true)
	end

	if _G.QueueStatusButton then
		M:CreateQueueStatusText()
	end

	M:HandleQueueStatus(true)
end
