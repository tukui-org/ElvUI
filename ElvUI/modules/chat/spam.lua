local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
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