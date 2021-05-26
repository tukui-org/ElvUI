local _G = _G
local select = select

local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame
-- GLOBALS: ElvUI

local function OnMouseDown(self, button)
	local text = self.Text:GetText()
	if button == 'RightButton' then
		ElvUI[1]:GetModule('Chat'):SetChatEditBoxMessage(text)
	elseif button == 'MiddleButton' then
		local rawData = self:GetParent():GetAttributeData().rawValue
		if rawData.IsObjectType and rawData:IsObjectType('Texture') then
			_G.TEX = rawData
			ElvUI[1]:Print('_G.TEX set to: ', text)
		else
			_G.FRAME = rawData
			ElvUI[1]:Print('_G.FRAME set to: ', text)
		end
	else
		_G.TableAttributeDisplayValueButton_OnMouseDown(self)
	end
end

local function UpdateLines(self)
	local scrollFrame = self.LinesScrollFrame or _G.TableAttributeDisplay.LinesScrollFrame -- tinspect, or fstack ctrl
	if not scrollFrame then return end
	for i = 1, scrollFrame.LinesContainer:GetNumChildren() do
		local child = select(i, scrollFrame.LinesContainer:GetChildren())
		if child.ValueButton and child.ValueButton:GetScript('OnMouseDown') ~= OnMouseDown then
			child.ValueButton:SetScript('OnMouseDown', OnMouseDown)
		end
	end
end

local event = 'ADDON_LOADED'
local function Setup(frame)
	if frame.Registered then return end
	local debugTools = IsAddOnLoaded('Blizzard_DebugTools')
	if debugTools then
		hooksecurefunc(_G.TableInspectorMixin, 'RefreshAllData', UpdateLines) -- /tinspect
		hooksecurefunc(_G.TableAttributeDisplay.dataProviders[2], 'RefreshData', UpdateLines) -- fstack ctrl
		frame.Registered = true

		if frame:IsEventRegistered(event) then
			frame:UnregisterEvent(event)
		end
	elseif not frame:IsEventRegistered(event) then
		frame:RegisterEvent(event)
	end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', Setup)
Setup(frame)
