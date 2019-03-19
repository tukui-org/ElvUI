--Lua functions
local _G = _G
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame

local E, Chat
local function OnMouseDown(self, button)
	if not E then E = _G.ElvUI and _G.ElvUI[1] end
	if not E then return end

	local text = self.Text:GetText()
	if button == "RightButton" then
		if not Chat then Chat = E:GetModule("Chat") end
		if not Chat then return end

		Chat:SetChatEditBoxMessage(text)
	elseif button == "MiddleButton" then
		local rawData = self:GetParent():GetAttributeData().rawValue

		if rawData.GetObjectType and rawData:GetObjectType() == "Texture" then
			_G.TEX = rawData
			E:Print("_G.TEX set to: ", text)
		else
			_G.FRAME = rawData
			E:Print("_G.FRAME set to: ", text)
		end
	else
		_G.TableAttributeDisplayValueButton_OnMouseDown(self)
	end
end

local function UpdateLines(self)
	if not self.LinesScrollFrame then return end
	for i=1, self.LinesScrollFrame.LinesContainer:GetNumChildren() do
		local child = select(i, self.LinesScrollFrame.LinesContainer:GetChildren())
		if child.ValueButton and child.ValueButton:GetScript("OnMouseDown") ~= OnMouseDown then
			child.ValueButton:SetScript("OnMouseDown", OnMouseDown)
		end
	end
end

local event = "ADDON_LOADED"
local function Setup(frame)
	local debugTools = IsAddOnLoaded("Blizzard_DebugTools")
	if debugTools then
		hooksecurefunc(_G.TableInspectorMixin, "RefreshAllData", UpdateLines)

		if frame:IsEventRegistered(event) then
			frame:UnregisterEvent(event)
		end
	elseif not frame:IsEventRegistered(event) then
		frame:RegisterEvent(event)
	end
end

local frame = CreateFrame('Frame')
frame:SetScript("OnEvent", Setup)
Setup(frame)
