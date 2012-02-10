local E, L, DF = unpack(select(2, ...)); --Engine
local CH = E:GetModule('Chat')


local blockMessages = {
	['[\227-\237]'] = true, --Credit: Ketho (EU-Boulderfist)
}

function CH:SpamFilter(event, msg)
	for blockMessage in pairs(blockMessages) do
		if strfind(msg, blockMessage) then
			return true
		end
	end
end