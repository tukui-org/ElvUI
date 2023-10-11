local E, L, V, P, G = unpack(ElvUI)

local _G = _G
local next = next
local tinsert = tinsert

local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local ToggleFrame = ToggleFrame
local UIParent = UIParent

local function OnClick(btn)
	if btn.func then
		btn.func()
	end

	btn:GetParent():Hide()
end

local function OnEnter(btn)
	if btn.hoverTex then
		btn.hoverTex:Show()
	end
end

local function OnLeave(btn)
	if btn.hoverTex then
		btn.hoverTex:Hide()
	end
end

local function CreateButton(frame, i)
	local button = CreateFrame('Button', nil, frame)
	button:SetScript('OnEnter', OnEnter)
	button:SetScript('OnLeave', OnLeave)
	frame.buttons[i] = button

	local hover = button:CreateTexture(nil, 'OVERLAY')
	hover:SetAllPoints()
	hover:SetTexture(136810) -- Interface\QuestFrame\UI-QuestTitleHighlight
	hover:SetBlendMode('ADD')
	hover:Hide()
	button.hoverTex = hover

	local text = button:CreateFontString(nil, 'BORDER')
	text:SetAllPoints()
	text:FontTemplate(nil, nil, 'SHADOW')
	text:SetJustifyH('LEFT')
	button.text = text

	return button
end

function E:DropDown(list, frame, width, height, padding, xOffset, yOffset)
	if not width then width = 135 end
	if not height then height = 16 end
	if not padding then padding = 10 end

	if not frame.buttons then
		frame.buttons = {}

		frame:SetFrameStrata('DIALOG')
		frame:SetClampedToScreen(true)
		frame:Hide()

		tinsert(_G.UISpecialFrames, frame:GetName())
	end

	for _, button in next, frame.buttons do
		button:Hide()
	end

	local numEntries = #list
	for i = 1, numEntries do
		local entry = list[i]
		local button = frame.buttons[i] or CreateButton(frame, i)
		button.text:SetText(entry.text)
		button.func = entry.func

		button:Show()
		button:ClearAllPoints()
		button:SetScript('OnClick', OnClick)
		button:Size(width, height)

		if i == 1 then
			button:Point('TOPLEFT', frame, 'TOPLEFT', padding, -padding)
		else
			button:Point('TOPLEFT', frame.buttons[i-1], 'BOTTOMLEFT')
		end
	end

	local x, y = GetCursorPosition()
	local SPACING = padding * 2

	frame:ClearAllPoints()
	frame:Point('TOPLEFT', UIParent, 'BOTTOMLEFT', (x / E.uiscale) + (xOffset or 0), (y / E.uiscale) + (yOffset or 0))
	frame:Size(width + SPACING, (numEntries * height) + SPACING)

	ToggleFrame(frame)
end
