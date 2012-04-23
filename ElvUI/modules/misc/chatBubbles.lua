local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local M = E:GetModule('Misc');
local NP = E:GetModule("NamePlates");
local numChildren = -1

function M:UpdateBubbleBorder()
	if not self:IsShown() or not self.text then return end
	NP:SetVirtualBorder(self, self.text:GetTextColor())	
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
	NP:CreateVirtualFrame(frame)	
	NP:SetVirtualBorder(frame, frame.text:GetTextColor())	
	
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