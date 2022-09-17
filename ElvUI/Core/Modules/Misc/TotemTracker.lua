local E, L, V, P, G = unpack(ElvUI)
local T = E:GetModule('TotemTracker')

local _G = _G
local unpack = unpack

local CreateFrame = CreateFrame
local GetTotemInfo = GetTotemInfo
local MAX_TOTEMS = MAX_TOTEMS

-- SHAMAN_TOTEM_PRIORITIES does not work here because we need to swap 3/4 instead of 1/2
local priority = E.myclass == 'SHAMAN' and { [1]=1, [2]=2, [3]=4, [4]=3 } or STANDARD_TOTEM_PRIORITIES

function T:Update()
	for i = 1, MAX_TOTEMS do
		local button = T.bar[priority[i]]
		local totem = _G['TotemFrameTotem'..i]
		if totem:IsShown() then
			local _, _, startTime, duration, icon = GetTotemInfo(totem.slot)

			button:Show()
			button.iconTexture:SetTexture(icon)
			button.cooldown:SetCooldown(startTime, duration)

			totem:ClearAllPoints()
			totem:SetParent(button.holder)
			totem:SetAllPoints(button.holder)
		else
			button:Hide()
		end
	end
end

function T:PositionAndSize()
	if not E.private.general.totemTracker then return end

	for i = 1, MAX_TOTEMS do
		local button = T.bar[i]
		local prevButton = T.bar[i-1]
		button:Size(T.db.size)
		button:ClearAllPoints()

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
		local frame = CreateFrame('Button', bar:GetName()..'Totem'..i, bar)
		frame:SetID(i)
		frame:SetTemplate()
		frame:StyleButton()
		frame:Hide()

		frame.holder = CreateFrame('Frame', nil, frame)
		frame.holder:SetAlpha(0)
		frame.holder:SetAllPoints()

		frame.iconTexture = frame:CreateTexture(nil, 'ARTWORK')
		frame.iconTexture:SetTexCoord(unpack(E.TexCoords))
		frame.iconTexture:SetInside()

		frame.cooldown = CreateFrame('Cooldown', frame:GetName()..'Cooldown', frame, 'CooldownFrameTemplate')
		frame.cooldown:SetReverse(true)
		frame.cooldown:SetInside()

		E:RegisterCooldown(frame.cooldown)

		T.bar[i] = frame
	end

	T:PositionAndSize()

	T:RegisterEvent('PLAYER_TOTEM_UPDATE', 'Update')
	T:RegisterEvent('PLAYER_ENTERING_WORLD', 'Update')

	E:CreateMover(bar, 'TotemTrackerMover', L["Totem Tracker"], nil, nil, nil, nil, nil, 'general,totems')
end

E:RegisterModule(T:GetName())
