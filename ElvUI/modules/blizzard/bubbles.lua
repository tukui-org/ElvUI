local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["chat"].bubbles ~= true or IsAddOnLoaded("BossEncounter2") then return end

local chatbubblehook = CreateFrame("Frame", nil, E.UIParent)
local noscalemult = E.mult * C["general"].uiscale
local tslu = 0
local numkids = 0
local bubbles = {}

if E.eyefinity then
	-- hide options, disable bubbles, not compatible eyefinity
	InterfaceOptionsSocialPanelChatBubbles:SetScale(0.00001)
	InterfaceOptionsSocialPanelPartyChat:SetScale(0.00001)
	SetCVar("chatBubbles", 0)
	SetCVar("chatBubblesParty", 0)
end


local function skinbubble(frame)
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
		end
	end
	
	frame:SetBackdrop({
		bgFile = C["media"].blank,
		edgeFile = C["media"].blank,
		tile = false, tileSize = 0, edgeSize = noscalemult,
		insets = {left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	})
	frame:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	frame:SetBackdropColor(.1, .1, .1, .8)
	frame:SetClampedToScreen(false)
	
	tinsert(bubbles, frame)
end

local function ischatbubble(frame)
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	return frame:GetRegions():GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
end

chatbubblehook:SetScript("OnUpdate", function(chatbubblehook, elapsed)
	tslu = tslu + elapsed

	if tslu > .05 then
		tslu = 0

		local newnumkids = WorldFrame:GetNumChildren()
		if newnumkids ~= numkids then
			for i=numkids + 1, newnumkids do
				local frame = select(i, WorldFrame:GetChildren())

				if ischatbubble(frame) then
					skinbubble(frame)
				end
			end
			numkids = newnumkids
		end
		
		for i, frame in next, bubbles do
			local r, g, b = frame.text:GetTextColor()
			frame:SetBackdropBorderColor(r, g, b, .8)
			
			-- bubbles is unfortunatly not compatible with eyefinity, we hide it event if they are enabled. :(
			if E.eyefinity then frame:SetScale(0.00001) end			
		end
	end
end)