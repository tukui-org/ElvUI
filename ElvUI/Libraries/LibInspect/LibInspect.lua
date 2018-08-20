--[[
type:
    all - use sparingly because achivements look havy
    items - returns a table of items
    honor - not yet
    talents - not yet
    achivements - not yet

Methods:
success = LibInspect:AddHook('MyAddon', type, function(guid, data, age) YourFunction(guid, data, age); end);

maxAge = LibInspect:SetMaxAge(seconds);
recanQuantity = LibInspect:SetRescan(items);

caninspect, unitfound, refreshing = LibInspect:RequestData(type, target, force);
    or LibInspect:Request_Type_(target, force)
    ex. LibInspect:RequestItems(...)

Callbacks:
    When the data is ready you YourFunction(guid, data, age) will be called

    guid = UnitGUID(); use this to tie it to the inspect request

    data = false or {
        items = {
            1 = itemLink,
            2 = itemLink,
            ...
            19 = itemLink,
        },
        honor = ...,
        talents = {
            id = ,
            name = string,
            description = string,
            icon = image,
            background = image,
            role = role,
            talents = {
                1 = {   -- see GetTalentInfo()
                    name = string,
                    iconTexture = image,
                    tier = int,
                    column = int,
                    selected = bool,
                    available = bool,
                },
                ...
            },
            glyphs = {
                1 = {   -- see GetGlyphSocketInfo()
                    enabled = int,
                    glyphType = GLYPH_TYPE_MAJOR or GLYPH_TYPE_MINOR,
                    glyphTooltipIndex = ,
                    glyphSpell = spellId,
                    iconFilename = image or nil,
                    glyphID = ,
                },
                ...
            },
        },
        achivements = ...,
    }

    age = ##; how old in seconds the data is
]]

-- Start the lib
local lib = LibStub:NewLibrary('LibInspect', 5);
if not lib then return end
if not lib.frame then lib.frame = CreateFrame("Frame"); end

lib.maxAge = 1800; -- seconds
lib.rescan = 7; -- What to consider min items
lib.rescanGUID = {}; -- GUID for 2nd pass scanning
lib.cache = {};
lib.hooks = {
    items = {},
    honor = {},
    talents = {},
    achievemnts = {},
};

lib.events = {
    items = "INSPECT_READY",
    talents = "INSPECT_READY",
    honor = "INSPECT_HONOR_UPDATE",
    achievemnts = "INSPECT_ACHIEVEMENT_READY",
}

function lib:AddHook(addon, what, callback)
    if addon and what and callback then
        if type(what) == 'string' then
            if what == 'all' then
                local i = self:SecureAddHook(addon, 'items', callback);
                local h = self:SecureAddHook(addon, 'honor', callback);
                local t = self:SecureAddHook(addon, 'talents', callback);
                local a = self:SecureAddHook(addon, 'achievemnts', callback);

                if i and h and t and a then
                    return true;
                else
                    return false, i, h, t, a;
                end
            elseif what == 'items' then
                return self:SecureAddHook(addon, 'items', callback);
            elseif what == 'honor' then
                return self:SecureAddHook(addon, 'honor', callback);
            elseif what == 'talents' then
                return self:SecureAddHook(addon, 'talents', callback);
            elseif what == 'achievemnts' then
                return self:SecureAddHook(addon, 'achievemnts', callback);
            else
                --- print('LibInspect:AddHook Unkown Type '..what);
                return false;
            end
        end
    else
        --- print('LibInspect:AddHook Missing Variable ', addon, what, callback);
        return false;
    end
end

-- Internal only, should prob be local
function lib:SecureAddHook(addon, what, callback)
    if self.hooks[what] then
        self.hooks[what][addon] = callback;

        -- Register the event
        if self.events[what] then
            self.frame:RegisterEvent(self.events[what]);
        end

        return true;
    else
        --- print('LibInspect:SecureAddHook Unkown Type ', addon, what, callback);
        return false;
    end
end

function lib:RemoveHook(addon, what)
    if addon then
        if not what then what = 'all'; end

        if what == 'all' then
            self:RemoveHook(addon, 'items');
            self:RemoveHook(addon, 'honor');
            self:RemoveHook(addon, 'talents');
            self:RemoveHook(addon, 'achievemnts');
        elseif what == 'items' or what == 'honor' or what == 'talents' or what == 'achievemnts' then
            self.hooks[what][addon] = false;

            -- Clean up events if we can
            if self:count(self.hooks[what]) == 0 and self.events[what] then
                self.frame:UnregisterEvent(self.events[what]);
            end
        else
            --- print('LibInspect:RemoveHook Unkown Type ', what);
            return false;
        end
    else
        --- print('LibInspect:RemoveHook No Addon Passed');
        return false;
    end
end

function lib:SetMaxAge(maxAge)
    if maxAge < self.maxAge then
        self.maxAge = maxAge;
    end

    return self.maxAge;
end

function lib:SetRescan(items)
    if tonumber(items) and items >= 0 and items <= 15 then
        self.rescan = items;
    end

    return self.rescan;
end

function lib:RequestData(what, target, force)
    -- Error out on a few things
    if not target then return false end
    if InCombatLockdown() then return false end
    if not CanInspect(target) then return false end

    if not what then what = 'all'; end

    -- We can skip some things if target is player
    local skip = false;
    if target == 'player' or UnitIsUnit('player', target) then
        skip = true;
    end

    -- Manual requests reset the rescan lock
    self.rescanGUID[target] = 0;

    -- Make sure they are in cache
    local guid = self:AddCharacter(target);

    if guid then

        -- First check for cached
        if self.cache[guid].data == false or self.cache[guid].time == 0 or (time() - self.cache[guid].time) > self.maxAge or force then

            self.cache[guid].target = target;

            if what == 'all' then
                self:SafeRequestItems(target, guid, skip);
                self:SafeRequestHonor(target, guid, skip);
                self:SafeRequestAchivements(target, guid, skip);
            elseif what == 'items' then
                self:SafeRequestItems(target, guid, skip);
            elseif what == 'honor' then
                self:SafeRequestHonor(target, guid, skip);
            elseif what == 'talents' then
                self:SafeRequestItems(target, guid, skip);
            elseif what == 'achivements' then
                self:SafeRequestAchivements(target, guid, skip);
            else
                --- print('LibInspect:RequestData Unkown Type ', what);
                return false;
            end

            return true, true, true;
        else
            if what == 'all' then
                self:RunHooks('items', guid);
                self:RunHooks('honor', guid);
                self:RunHooks('talents', guid);
                self:RunHooks('achivements', guid);
            elseif what == 'items' then
                self:RunHooks('items', guid);
            elseif what == 'honor' then
                self:RunHooks('honor', guid);
            elseif what == 'talents' then
                self:RunHooks('talents', guid);
            elseif what == 'achivements' then
                self:RunHooks('achivements', guid);
            else
                --- print('LibInspect:RequestData Unkown Type ', what);
                return false;
            end

            return true, true, false;
        end
    else
        --- print('LibInspect:RequestData AddCharacter failed to turn a guid ', target, guid, ' another go at guid ', UnitGUID(target));
        return true, false;
    end
end

-- Shortcuts
function lib:RequestItems(target, force) return self:RequestData('items', target, force); end
function lib:RequestHonor(target, force) return self:RequestData('items', target, force); end
function lib:RequestTalents(target, force) return self:RequestData('items', target, force); end
function lib:RequestAchivements(target, force) return self:RequestData('achivements', target, force); end

-- Safe Functions for Requests
function lib:SafeRequestItems(target, guid, skip)

    -- We can skip everything else
    if skip then
        self:InspectReady(guid)
        return
    end

    local canInspect = false;

    if not self.cache[guid].inspect then
        canInspect = true;
    elseif self.cache[guid].inspect and tonumber(self.cache[guid].inspect) and self:GetAge(self.cache[guid].inspect) > 5 then
        canInspect = true;
    end

    if canInspect then

        -- Fix an inspect frame bug, may be fixed in 4.3
        -- if InspectFrame then InspectFrame.unit = target; end

        --- print('LibInspect:SafeRequestItems running NotifyInspect for', UnitName(target), target);
        self.cache[guid].inspect = time();
        NotifyInspect(target);
    end
end

function lib:SafeRequestHonor(target, guid, skip)
    RequestInspectHonorData();
end

function lib:SafeRequestAchivements(target, guid, skip)
end

function lib:InspectReady(guid)
    -- Few more error checks
    if not guid then return false end
    if InCombatLockdown() then return false end

    --- print('LibInspect:InspectReady', guid, self.cache[guid]);

    -- Make sure we have a target and its the same as the cache
    if self.cache[guid] and self.cache[guid].target and UnitGUID(self.cache[guid].target) == guid then
        local target = self.cache[guid].target;

        -- Make sure we can still inspect them still
        if CanInspect(target) then
            self.cache[guid].time = time();

            if not self.cache[guid].data then
                self.cache[guid].data = {};
            end

            self.cache[guid].inspect = false;
            self.cache[guid].data['items'] = {};

            local items, count = self:GetItems(target, guid);
            local talents = self:GetTalents(target, guid);

            --- print('LibInspect:InspectReady Done', UnitName(target), guid, self.rescanGUID[target], count);

            -- Do a 2nd pass if there aren't many items
            if count <= self.rescan and self.rescanGUID[target] ~= guid then
                --- print('LibInspect:InspectReady Rescaning', UnitName('target'), count, self.rescan, self.rescanGUID[target], guid);
                self.rescanGUID[target] = guid;
                self:SafeRequestItems(target, guid);
                return false;
            end


            self.cache[guid].data.items = items;
            self.cache[guid].data.talents = talents;
        end

        self:RunHooks('items', guid);
        self:RunHooks('talents', guid);
    end
end

function lib:GetItems(target, guid)
    if CanInspect(target) then
        local items = {};
        local count = 0;

        for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local itemLink = GetInventoryItemLink(target, i);
            items[i] = itemLink;

            if itemLink then
                 --- print('LibInspect:GetItems', UnitName(target), i, itemLink);
                count = count + 1;
            end
        end

        --- print('LibInspect:GetItems Total', UnitName(target), count);

        return items, count;
    else
        return false;
    end
end

function lib:GetTalents(target, guid)
    if CanInspect(target) then
        local specID

        if target == 'player' or UnitIsUnit('player', target) then
            if GetSpecialization() then
                specID = GetSpecializationInfo(GetSpecialization())
            else
                return false
            end
        else
            specID = GetInspectSpecialization(target)
        end

		if (specID) then

			local id, name, description, icon, background = GetSpecializationInfoByID(specID)
			local role = GetSpecializationRoleByID(specID)

			local talents = {
				id = id,
				name = name,
				description = description,
				icon = icon,
				background = background,
				role = role,
				glyphs = {},  -- Removed in 7.03, left for compatability
				talents = {},
			};

			-- Talents
			local classDisplayName, class, classID = UnitClass(target);
			if TalentFrame then
				for tier=1, MAX_TALENT_TIERS do
					local talentRow = TalentFrame["tier"..tier];
					local rowAvailable = true;

					for column=1, NUM_TALENT_COLUMNS do
						local talentID, name, iconTexture, selected, available = GetTalentInfo(tier, column, TalentFrame.talentGroup, TalentFrame.inspect, talentUnit);
						-- local name, iconTexture, tier, column, selected, available = GetTalentInfo(tier, true, nil, target, self.cache[guid].classID);
						talents.talents[tier] = {
							name = name,
							iconTexture = iconTexture,
							tier = tier,
							column = column,
							selected = selected,
							available = available,
						}
					end
				end
			end

			return talents;
		else
			return false;
		end
    else
        return false;
    end
end


function lib:AddCharacter(target)
    local guid = UnitGUID(target);

    if guid then
        -- Set up information
        if not self.cache[guid] then
            local _, _, classID = UnitClass(target);

            self.cache[guid] = {
                data = false,
                time = 0,
                request = 0,
                inspect = false,
                classID = classID,
            };
        end

        -- Update target cache
        self.cache[guid].target = target;

        -- Return guid to save on calls
        return guid;
    else
        return false;
    end
end

function lib:RunHooks(what, guid)
    for addon,callback in pairs(self.hooks[what]) do
        if callback then
            callback(guid, self.cache[guid].data, self:GetAge(self.cache[guid].time));
        end
    end
end

function lib:GetAge(t)
    if tonumber(t) then
        return time() - tonumber(t);
    else
        return false;
    end
end

function lib:count(tbl)
    local i = 0;

    for k,v in pairs(tbl) do
        i = i + 1;
    end

    return i;
end


local function OnEvent(self, event, ...)
    if event == 'INSPECT_READY' then
        lib:InspectReady(...);
    elseif event == 'INSPECT_HONOR_UPDATE' then
        lib:InspectHonorUpdate(...);
    elseif event == 'INSPECT_ACHIEVEMENT_READY' then
        lib:InspectAchievementReady(...);
    end
end

lib.frame:SetScript("OnEvent", OnEvent);
