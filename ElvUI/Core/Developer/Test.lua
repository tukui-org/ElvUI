------------------------------------------------------------------------
-- Going to leave this as my bullshit lua file.
-- So I can test stuff.
------------------------------------------------------------------------

local guilds = {}

local f = CreateFrame("Frame")
f:RegisterEvent("CLUB_FINDER_GUILD_REALM_NAME_UPDATED")
f:SetScript("OnEvent", function(self, event, guid, realm)
    guilds = {} -- Reset the table to avoid stale data

    for _, guildDB in ipairs(ClubFinderGuildFinderFrame.GuildCards.CardList) do
        local clubFinderGUID = guildDB.clubFinderGUID -- Assuming this exists

        if clubFinderGUID then
            guilds[clubFinderGUID] = {
                realmName = guildDB.realmName,
                name = guildDB.name,
                numActiveMembers = guildDB.numActiveMembers,
            }
        end
    end
end)

SLASH_DUMPGUILDS1 = "/dumpguilds"
SlashCmdList["DUMPGUILDS"] = function(msg)
    -- Check if guilds list is populated
    if next(guilds) == nil then
        print("Error: No guilds found. Please open Guild Finder, search for guilds, and try again.")
        print("Usage: /dumpguilds <minPlayers>")
        return
    end

    local cutoff = tonumber(msg) -- Convert argument to a number
    local guildList = {}

    -- Convert table into sortable list
    for _, guild in pairs(guilds) do
        table.insert(guildList, guild)
    end

    -- Sort guilds by active members in descending order
    table.sort(guildList, function(a, b)
        return a.numActiveMembers > b.numActiveMembers
    end)

    -- Print sorted guild list with cutoff applied
    for _, guild in ipairs(guildList) do
        if not cutoff or guild.numActiveMembers >= cutoff then
            print(guild.name .. " .. " .. guild.numActiveMembers)
        end
    end
end