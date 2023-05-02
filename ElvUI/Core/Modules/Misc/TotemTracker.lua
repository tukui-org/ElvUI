local E, L, V, P, G = unpack(ElvUI)
local T = E:GetModule('TotemTracker')
local AB = E:GetModule('ActionBars')

local _G = _G
local ipairs = ipairs

local CreateFrame = CreateFrame
local GetTotemInfo = GetTotemInfo
local MAX_TOTEMS = MAX_TOTEMS

-- SHAMAN_TOTEM_PRIORITIES does not work here because we need to swap 3/4 instead of 1/2
local priority = E.myclass == 'SHAMAN' and { [1]=1, [2]=2, [3]=4, [4]=3 } or STANDARD_TOTEM_PRIORITIES

function T:UpdateButton(button, totem)
	if not (button and totem) then return end

	local haveTotem, _, startTime, duration, icon = GetTotemInfo(totem.slot)

	button:SetShown(haveTotem and duration > 0)

	if haveTotem then
		button.icon:SetTexture(icon)
		button.cooldown:SetCooldown(startTime, duration)

		if totem:GetParent() ~= button.holder then
			totem:ClearAllPoints()
			totem:SetParent(button.holder)
			totem:SetAllPoints(button.holder)
		end
	end
end

function T:Update()
	if E.Retail then
		for _, button in ipairs(T.bar) do
			if button:IsShown() then
				button:SetShown(false)
			end
		end
		for totem in _G.TotemFrame.totemPool:EnumerateActive() do
			T:UpdateButton(T.bar[priority[totem.layoutIndex]], totem)
		end
	else
		for i = 1, MAX_TOTEMS do
			T:UpdateButton(T.bar[priority[i]], _G['TotemFrameTotem'..i])
		end
	end
end

function T:PositionAndSize()
	if not E.private.general.totemTracker then return end

	for i = 1, MAX_TOTEMS do
		local button = T.bar[i]
		local prevButton = T.bar[i-1]
		local width = T.db.size
		local height = T.db.keepSizeRatio and T.db.size or T.db.height

		button:Size(width, height)
		button:ClearAllPoints()

		AB:TrimIcon(button)

		if T.db.growthDirection == 'HORIZONTAL' and T.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('LEFT', T.bar, 'LEFT', T.db.spacing, 0)
			elseif prevButton then
				button:Point('LEFT', prevButton, 'RIGHT', T.db.spacing, 0)
			end
		elseif T.db.growthDirection == 'VERTICAL' and T.db.sortDirection == 'ASCENDING' then
			if i == 1 then
				button:Point('TOP', T.bar, 'TOP', 0, -T.db.spacing)
			elseif prevButton then
				button:Point('TOP', prevButton, 'BOTTOM', 0, -T.db.spacing)
			end
		elseif T.db.growthDirection == 'HORIZONTAL' and T.db.sortDirection == 'DESCENDING' then
			if i == 1 then
				button:Point('RIGHT', T.bar, 'RIGHT', -T.db.spacing, 0)
			elseif prevButton then
				button:Point('RIGHT', prevButton, 'LEFT', -T.db.spacing, 0)
			end
		else
			if i == 1 then
				button:Point('BOTTOM', T.bar, 'BOTTOM', 0, T.db.spacing)
			elseif prevButton then
				button:Point('BOTTOM', prevButton, 'TOP', 0, T.db.spacing)
			end
		end
	end

	if T.db.growthDirection == 'HORIZONTAL' then
		T.bar:Width(T.db.size * MAX_TOTEMS + T.db.spacing * MAX_TOTEMS + T.db.spacing)
		T.bar:Height(T.db.size + T.db.spacing * 2)
	else
		T.bar:Height(T.db.size * MAX_TOTEMS + T.db.spacing * MAX_TOTEMS + T.db.spacing)
		T.bar:Width(T.db.size + T.db.spacing * 2)
	end

	T:Update()
end

function T:Initialize()
	T.Initialized = true

	if not E.private.general.totemTracker then return end

	local bar = CreateFrame('Frame', 'ElvUI_TotemTracker', E.UIParent)
	bar:Point('BOTTOMLEFT', E.UIParent, 'BOTTOMLEFT', 490, 4)

	T.bar = bar
	T.db = E.db.general.totems

	for i = 1, MAX_TOTEMS do
		local button = CreateFrame('Button', bar:GetName()..'Totem'..i, bar)
		button:SetID(i)
		button:SetTemplate()
		button:StyleButton()
		button:Hide()

		button.db = T.db

		button.holder = CreateFrame('Frame', nil, button)
		button.holder:SetAlpha(0)
		button.holder:SetAllPoints()

		button.icon = button:CreateTexture(nil, 'ARTWORK')
		button.icon:SetInside()

		button.cooldown = CreateFrame('Cooldown', button:GetName()..'Cooldown', button, 'CooldownFrameTemplate')
		button.cooldown:SetReverse(true)
		button.cooldown:SetInside()

		E:RegisterCooldown(button.cooldown)

		T.bar[i] = button
	end

	T:PositionAndSize()

	T:RegisterEvent('PLAYER_TOTEM_UPDATE', 'Update')
	T:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update')

	if E.Retail then
		T:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'Update')
	else
		T:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'Update')
	end

	E:CreateMover(bar, 'TotemTrackerMover', L["Totem Tracker"], nil, nil, nil, nil, nil, 'general,totems')
end

E:RegisterModule(T:GetName())
