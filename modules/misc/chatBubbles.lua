local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local M = E:GetModule('Misc');

local numChildren = -1

function M:UpdateBubbleBorder()
	if not self:IsShown() or not self.text then return end
	self:SetBackdropBorderColor(self.text:GetTextColor())	
end

function M:SkinBubble(frame)
	local noscalemult = E.mult * (GetCVar('uiScale') or UIParent:GetScale())
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	
	frame:SetBackdrop({
		bgFile = E["media"].blankTex,
		edgeFile = E["media"].blankTex,
		tile = false, tileSize = 0, edgeSize = noscalemult,
	})
	
	local border = CreateFrame("Frame", nil, frame)
	border:SetPoint('TOPLEFT', -noscalemult, noscalemult)
	border:SetPoint('BOTTOMRIGHT', noscalemult, -noscalemult)
	border:SetBackdrop({
		bgFile = E["media"].blankTex,
		edgeFile = E["media"].blankTex, 
		edgeSize = noscalemult * 3, 
	})
	border:SetBackdropBorderColor(0, 0, 0, 1)
	border:SetFrameLevel(frame:GetFrameLevel() - 1)
	
		
	frame:SetBackdropBorderColor(frame.text:GetTextColor())	
	frame:SetBackdropColor(0,0,0,0)
	border:SetBackdropColor(unpack(E["media"].backdropfadecolor))
	
	frame:SetClampedToScreen(false)
	frame.isBubblePowered = true
	frame:HookScript('OnUpdate', M.UpdateBubbleBorder)
end

function M:IsChatBubble(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	return frame:GetRegions():GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]	
end

function M:HookBubbles(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)

		if M:IsChatBubble(frame) and not frame.isBubblePowered then
			M:SkinBubble(frame)
		end
	end
end

function M:LoadChatBubbles()
	if not E.global.general.bubbles then return; end
	CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
		if(WorldFrame:GetNumChildren() ~= numChildren) then
			numChildren = WorldFrame:GetNumChildren()
			M:HookBubbles(WorldFrame:GetChildren())
		end	
	end)	
end