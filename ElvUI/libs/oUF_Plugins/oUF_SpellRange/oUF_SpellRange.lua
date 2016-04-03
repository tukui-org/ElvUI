--[[****************************************************************************
  * oUF_SpellRange by Saiket                                                   *
  * oUF_SpellRange.lua - Improved range element for oUF.                       *
  *                                                                            *
  * Elements handled: .SpellRange                                              *
  * Settings: (Either Update method or both alpha properties are required)     *
  *   - .SpellRange.Update( Frame, InRange ) - Callback fired when a unit      *
  *       either enters or leaves range. Overrides default alpha changing.     *
  *   OR                                                                       *
  *   - .SpellRange.insideAlpha - Frame alpha value for units in range.        *
  *   - .SpellRange.outsideAlpha - Frame alpha for units out of range.         *
  * Note that SpellRange will automatically disable Range elements of frames.  *
  ****************************************************************************]]


local oUF = select( 2, ... ).oUF or _G[ assert( GetAddOnMetadata( ..., "X-oUF" ), "X-oUF metadata missing in parent addon." ) ];
assert( oUF, "Unable to locate oUF." );

local UpdateRate = 0.1;

local UpdateFrame;
local Objects = {};
local ObjectRanges = {};

-- Class-specific spell info
local HelpIDs, HelpName; -- Array of possible spell IDs in order of priority, and the name of the highest known priority spell
local HarmIDs, HarmName;




local IsInRange;
do
	local UnitIsConnected = UnitIsConnected;
	local UnitCanAssist = UnitCanAssist;
	local UnitCanAttack = UnitCanAttack;
	local UnitIsUnit = UnitIsUnit;
	local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid;
	local UnitIsDead = UnitIsDead;
	local UnitOnTaxi = UnitOnTaxi;
	local UnitInRange = UnitInRange;
	local IsInGroup = IsInGroup;
	local IsSpellInRange = IsSpellInRange;
	local CheckInteractDistance = CheckInteractDistance;
	--- Uses an appropriate range check for the given unit.
	-- Actual range depends on reaction, known spells, and status of the unit.
	-- @param UnitID  Unit to check range for.
	-- @return True if in casting range.
	function IsInRange ( UnitID )
		if ( UnitIsConnected( UnitID ) ) then
			if ( UnitCanAssist( "player", UnitID ) ) then
				if ( HelpName and not UnitIsDead( UnitID ) ) then
					return IsSpellInRange( HelpName, UnitID ) == 1;
				elseif ( not UnitOnTaxi( "player" ) ) then -- UnitInRange always returns nil while on flightpaths
					-- Use UnitInRange if available (38 yd range)
					if ( IsInGroup() ) then -- UnitInRange only works while in a group
						if ( UnitIsUnit( UnitID, "player" ) or UnitIsUnit( UnitID, "pet" ) ) then
							return UnitInRange( UnitID );
						end
					elseif ( UnitPlayerOrPetInParty( UnitID ) or UnitPlayerOrPetInRaid( UnitID ) ) then
						return UnitInRange( UnitID );
					end
				end
			elseif ( HarmName and not UnitIsDead( UnitID ) and UnitCanAttack( "player", UnitID ) ) then
				return IsSpellInRange( HarmName, UnitID ) == 1;
			end

			-- Fallback when spell not found or class uses none
			return CheckInteractDistance( UnitID, 4 ); -- Follow distance (28 yd range)
		end
	end
end
--- Rechecks range for a unit frame, and fires callbacks when the unit passes in or out of range.
local function UpdateRange ( self )
	local InRange = not not IsInRange( self.unit ); -- Cast to boolean
	if ( ObjectRanges[ self ] ~= InRange ) then -- Range state changed
		ObjectRanges[ self ] = InRange;

		local SpellRange = self.SpellRange;
		if ( SpellRange.Update ) then
			SpellRange.Update( self, InRange );
		else
			self:SetAlpha( SpellRange[ InRange and "insideAlpha" or "outsideAlpha" ] );
		end
	end
end


local OnUpdate;
do
	local NextUpdate = 0;
	--- Updates the range display for all visible oUF unit frames on an interval.
	function OnUpdate ( self, Elapsed )
		NextUpdate = NextUpdate - Elapsed;
		if ( NextUpdate <= 0 ) then
			NextUpdate = UpdateRate;

			for Object in pairs( Objects ) do
				if ( Object:IsVisible() ) then
					UpdateRange( Object );
				end
			end
		end
	end
end
local OnSpellsChanged;
do
	local IsSpellKnown = IsSpellKnown;
	local GetSpellInfo = GetSpellInfo;
	--- @return Highest priority spell name available, or nil if none.
	local function GetSpellName ( IDs )
		if ( IDs ) then
			for _, ID in ipairs( IDs ) do
				if ( IsSpellKnown( ID ) ) then
					return GetSpellInfo( ID );
				end
			end
		end
	end
	--- Checks known spells for the highest priority spell name to use.
	function OnSpellsChanged ()
		HelpName, HarmName = GetSpellName( HelpIDs ), GetSpellName( HarmIDs );
	end
end


--- Called by oUF when the unit frame's unit changes or otherwise needs a complete update.
-- @param Event  Reason for the update.  Can be a real event, nil, or a string defined by oUF.
local function Update ( self, Event, UnitID )
	if ( Event ~= "OnTargetUpdate" ) then -- OnTargetUpdate is fired on a timer for *target units that don't have real events
		ObjectRanges[ self ] = nil; -- Force update to fire
		UpdateRange( self ); -- Update range immediately
	end
end
--- Forces range to be recalculated for this element's frame immediately.
local function ForceUpdate ( self )
	return Update( self.__owner, "ForceUpdate", self.__owner.unit );
end
--- Called by oUF for new unit frames to setup range checking.
-- @return True if the range element was actually enabled.
local function Enable ( self, UnitID )
	local SpellRange = self.SpellRange;
	if ( SpellRange ) then
		assert( type( SpellRange ) == "table", "oUF layout addon using invalid SpellRange element." );
		assert( type( SpellRange.Update ) == "function"
			or ( tonumber( SpellRange.insideAlpha ) and tonumber( SpellRange.outsideAlpha ) ),
			"oUF layout addon omitted required SpellRange properties." );
		if ( self.Range ) then -- Disable default range checking
			self:DisableElement( "Range" );
			self.Range = nil; -- Prevent range element from enabling, since enable order isn't stable
		end

		SpellRange.__owner = self;
		SpellRange.ForceUpdate = ForceUpdate;
		if ( not UpdateFrame ) then
			UpdateFrame = CreateFrame( "Frame" );
			UpdateFrame:SetScript( "OnUpdate", OnUpdate );
			UpdateFrame:SetScript( "OnEvent", OnSpellsChanged );
		end
		if ( not next( Objects ) ) then -- First object
			UpdateFrame:Show();
			UpdateFrame:RegisterEvent( "SPELLS_CHANGED" );
			OnSpellsChanged(); -- Recheck spells immediately
		end
		Objects[ self ] = true;
		return true;
	end
end
--- Called by oUF to disable range checking on a unit frame.
local function Disable ( self )
	Objects[ self ] = nil;
	ObjectRanges[ self ] = nil;
	if ( not next( Objects ) ) then -- Last object
		UpdateFrame:Hide();
		UpdateFrame:UnregisterEvent( "SPELLS_CHANGED" );
	end
end




local _, Class = UnitClass( "player" );
--- Optional lists of low level baseline skills with greater than 28 yard range.
-- First known spell in the appropriate class list gets used.
-- Note: Spells probably shouldn't have minimum ranges!
HelpIDs = ( {
	-- DEATHKNIGHT = {};
	DRUID = { 774 }; -- Rejuvination (40yd) - Lvl 4
	-- HUNTER = {};
	MAGE = { 475 }; -- Remove Curse (40yd) - Lvl 29
	PALADIN = { 85673 }; -- Word of Glory (40yd) - Lvl 9
	PRIEST = { 17 }; -- Power Word: Shield (40yd) - Lvl 5
	-- ROGUE = {};
	SHAMAN = { 8004 }; -- Healing Surge (40yd) - Lvl 7
	WARLOCK = { 5697 }; -- Unending Breath (30yd) - Lvl 24
	-- WARRIOR = {};
} )[ Class ];

HarmIDs = ( {
	DEATHKNIGHT = { 47541 }; -- Death Coil (30yd) - Starter
	DRUID = { 5176 }; -- Wrath (40yd) - Starter
	HUNTER = { 75 }; -- Auto Shot (5-40yd) - Starter
	MAGE = { 44614 }; -- Frostfire Bolt (40yd) - Starter
	PALADIN = { 62124 }; -- Reckoning (30yd) - Lvl 15
	PRIEST = { 589 }; -- Shadow Word: Pain (40yd) - Lvl 3
	-- ROGUE = {};
	SHAMAN = { 403 }; -- Lightning Bolt (30yd) - Starter
	WARLOCK = { 686 }; -- Shadow Bolt (40yd) - Starter
	WARRIOR = { 355 }; -- Taunt (30yd) - Lvl 12
} )[ Class ];

oUF:AddElement( "SpellRange", Update, Enable, Disable );