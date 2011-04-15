
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["unitframes"]["enable"] ~= true then return end


local CreateColor = function( red, green, blue, alpha )
	return { red / 255, green / 255, blue / 255, alpha };
end

-- Configuration starts here:
if C["classtimer"].enable == false then return end

BAR_HEIGHT = C["classtimer"].bar_height;
BAR_SPACING = C["classtimer"].bar_spacing;
LAYOUT = C["classtimer"].layout;
ICON_POSITION = C["classtimer"].icon_position;
ICON_COLOR = { unpack(C["media"].bordercolor) };
SPARK = C["classtimer"].showspark;
CAST_SEPARATOR = C["classtimer"].cast_suparator;
CAST_SEPARATOR_COLOR = CreateColor( 0, 0, 0, 0.5 );
TEXT_MARGIN = 5;
local GROUP_SPACING = 3

if ( E and C["media"] and C["media"]["uffont"] ) then
	-- Sets font for all texts
	MASTER_FONT = { C["media"].uffont, 12, "THINOUTLINE" };

	-- Sets font for stack count
	STACKS_FONT = { C["media"].uffont, 11, "THINOUTLINE" };
else
	-- Sets font for all texts
	MASTER_FONT = { [=[Interface\Addons\ElvUI\media\Russel Square LT.ttf]=], 12, "OUTLINE" };

	-- Sets font for stack count
	STACKS_FONT = { [=[Interface\Addons\ElvUI\media\Russel Square LT.ttf]=], 11, "OUTLINE" };
end
PERMANENT_AURA_VALUE = 1;
if C["classtimer"].classcolor == false then
	PLAYER_BAR_COLOR = { unpack(C["classtimer"].buffcolor) };
	TARGET_BAR_COLOR = { unpack(C["classtimer"].buffcolor) };
	TARGET_DEBUFF_COLOR = { unpack(C["classtimer"].debuffcolor) };
	TRINKET_BAR_COLOR = { unpack(C["classtimer"].proccolor) };
	PLAYER_DEBUFF_COLOR = nil
else
	classcolor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))];
	PLAYER_BAR_COLOR = {classcolor.r, classcolor.g, classcolor.b, 1};
	TARGET_BAR_COLOR = {classcolor.r, classcolor.g, classcolor.b, 1};
	TARGET_DEBUFF_COLOR = {classcolor.r, classcolor.g, classcolor.b, 1};
	TRINKET_BAR_COLOR = {classcolor.r, classcolor.g, classcolor.b, 1};
	PLAYER_DEBUFF_COLOR = nil
end
PLAYER_DEBUFF_COLOR = nil;
SORT_DIRECTION = true;
TENTHS_TRESHOLD = 1
	
function E.LoadClassTimers(Elv_player, Elv_target)
	assert(Elv_player, "Classtimers failed to load, you need to specify a player and target frame, E.LoadClassTimers([player], [target])")
	assert(Elv_target, "Classtimers failed to load, you need to specify a player and target frame, E.LoadClassTimers([player], [target])")
	
	local CreateUnitAuraDataSource;
	do
		local auraTypes = { "HELPFUL", "HARMFUL" };

		-- private
		local CheckFilter = function( self, id, caster, filter )
			if ( filter == nil ) then return false; end
				
			local byPlayer = caster == "player" or caster == "pet" or caster == "vehicle";
				
			for _, v in ipairs( filter ) do
				if ( v.id == id and ( v.castByAnyone or byPlayer ) and v.enabled == true ) then return v; end
			end
			
			return false;
		end
		
		local CheckUnit = function( self, unit, filter, result )
			if ( not UnitExists( unit ) ) then return 0; end

			local unitIsFriend = UnitIsFriend( "player", unit );

			for _, auraType in ipairs( auraTypes ) do
				local isDebuff = auraType == "HARMFUL";
			
				for index = 1, 40 do
					local name, _, texture, stacks, _, duration, expirationTime, caster, _, _, spellId = UnitAura( unit, index, auraType );		
					if ( name == nil ) then
						break;
					end							
					
					local filterInfo = CheckFilter( self, spellId, caster, filter );
					if ( filterInfo and ( filterInfo.unitType ~= 1 or unitIsFriend ) and ( filterInfo.unitType ~= 2 or not unitIsFriend ) ) then 					
						filterInfo.name = name;
						filterInfo.texture = texture;
						filterInfo.duration = duration;
						filterInfo.expirationTime = expirationTime;
						filterInfo.stacks = stacks;
						filterInfo.unit = unit;
						filterInfo.isDebuff = isDebuff;
						table.insert( result, filterInfo );
					end
				end
			end
		end

		-- public 
		local Update = function( self )
			local result = self.table;

			for index = 1, #result do
				table.remove( result );
			end				

			CheckUnit( self, self.unit, self.filter, result );
			if ( self.includePlayer ) then
				CheckUnit( self, "player", self.playerFilter, result );
			end
			
			self.table = result;
		end

		local SetSortDirection = function( self, descending )
			self.sortDirection = descending;
		end
		
		local GetSortDirection = function( self )
			return self.sortDirection;
		end
		
		local Sort = function( self )
			local direction = self.sortDirection;
			local time = GetTime();
		
			local sorted;
			repeat
				sorted = true;
				for key, value in pairs( self.table ) do
					local nextKey = key + 1;
					local nextValue = self.table[ nextKey ];
					if ( nextValue == nil ) then break; end
					
					local currentRemaining = value.expirationTime == 0 and 4294967295 or math.max( value.expirationTime - time, 0 );
					local nextRemaining = nextValue.expirationTime == 0 and 4294967295 or math.max( nextValue.expirationTime - time, 0 );
					
					if ( ( direction and currentRemaining < nextRemaining ) or ( not direction and currentRemaining > nextRemaining ) ) then
						self.table[ key ] = nextValue;
						self.table[ nextKey ] = value;
						sorted = false;
					end				
				end			
			until ( sorted == true )
		end
		
		local Get = function( self )
			return self.table;
		end
		
		local Count = function( self )
			return #self.table;
		end
		
		local AddFilter = function( self, filter, defaultColor, debuffColor )
			if ( filter == nil ) then return; end
			
			for _, v in pairs( filter ) do
				local clone = { };
				
				if v.color then
					clone.color = {v.color.r, v.color.g, v.color.b}
				end

				clone.enabled = v.enabled;
				clone.id = v.id;
				clone.castByAnyone = v.castByAnyone;
				clone.unitType = v.unitType;
				clone.castSpellId = v.castSpellId;
				
				clone.defaultColor = defaultColor;
				clone.debuffColor = debuffColor;
				
				table.insert( self.filter, clone );
			end
		end
		
		local AddPlayerFilter = function( self, filter, defaultColor, debuffColor )
			if ( filter == nil ) then return; end

			for _, v in pairs( filter ) do
				local clone = { };
				
				clone.enabled = v.enabled;
				clone.id = v.id;
				clone.castByAnyone = v.castByAnyone;
				clone.color = v.color;
				clone.unitType = v.unitType;
				clone.castSpellId = v.castSpellId;
				
				clone.defaultColor = defaultColor;
				clone.debuffColor = debuffColor;
				
				table.insert( self.playerFilter, clone );
			end
		end
		
		local GetUnit = function( self )
			return self.unit;
		end
		
		local GetIncludePlayer = function( self )
			return self.includePlayer;
		end
		
		local SetIncludePlayer = function( self, value )
			self.includePlayer = value;
		end
		
		-- constructor
		CreateUnitAuraDataSource = function( unit )
			local result = {  };

			result.Sort = Sort;
			result.Update = Update;
			result.Get = Get;
			result.Count = Count;
			result.SetSortDirection = SetSortDirection;
			result.GetSortDirection = GetSortDirection;
			result.AddFilter = AddFilter;
			result.AddPlayerFilter = AddPlayerFilter;
			result.GetUnit = GetUnit; 
			result.SetIncludePlayer = SetIncludePlayer; 
			result.GetIncludePlayer = GetIncludePlayer; 
			
			result.unit = unit;
			result.includePlayer = false;
			result.filter = { };
			result.playerFilter = { };
			result.table = { };
			
			return result;
		end
	end

	local CreateFramedTexture;
	do
		-- public
		local SetTexture = function( self, ... )
			return self.texture:SetTexture( ... );
		end
		
		local GetTexture = function( self )
			return self.texture:GetTexture();
		end
		
		local GetTexCoord = function( self )
			return self.texture:GetTexCoord();
		end
		
		local SetTexCoord = function( self, ... )
			return self.texture:SetTexCoord( ... );
		end
		
		local SetBorderColor = function( self, ... )
			return self.border:SetVertexColor( ... );
		end
		
		-- constructor
		CreateFramedTexture = function( parent )
			local result = parent:CreateTexture( nil, "BACKGROUND", nil );
			local border = parent:CreateTexture( nil, "BORDER", nil );
			local background = parent:CreateTexture( nil, "ARTWORK", nil );
			local texture = parent:CreateTexture( nil, "OVERLAY", nil );		

			
			result:SetTexture( 0.1, 0.1, 0.1, 1 );
			border:SetTexture( 0.5, 0.5, 0.5, 0 );
			background:SetTexture( 0.1, 0.1, 0.1, 1 );
				
			border:SetPoint( "TOPLEFT", result, "TOPLEFT");
			border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT");
			
			background:SetPoint( "TOPLEFT", border, "TOPLEFT");
			background:SetPoint( "BOTTOMRIGHT", border, "BOTTOMRIGHT");

			texture:SetPoint( "TOPLEFT", background, "TOPLEFT");
			texture:SetPoint( "BOTTOMRIGHT", background, "BOTTOMRIGHT");
				
			result.border = border;
			result.background = background;
			result.texture = texture;
				
			result.SetBorderColor = SetBorderColor;
			
			result.SetTexture = SetTexture;
			result.GetTexture = GetTexture;
			result.SetTexCoord = SetTexCoord;
			result.GetTexCoord = GetTexCoord;
			

				
			return result;
		end
	end

	local CreateAuraBarFrame;
	do
		-- classes
		local CreateAuraBar;
		do
			-- private 
			local OnUpdate = function( self, elapsed )	
				local time = GetTime();
			
				if ( time > self.expirationTime ) then
					self.bar:SetScript( "OnUpdate", nil );
					self.bar:SetValue( 0 );
					self.time:SetText( "" );
					
					local spark = self.spark;
					if ( spark ) then			
						spark:Hide();
					end
				else
					local remaining = self.expirationTime - time;
					self.bar:SetValue( remaining );
					
					local timeText = "";
					if ( remaining >= 3600 ) then
						timeText = tostring( math.floor( remaining / 3600 ) ) .. "h";
					elseif ( remaining >= 60 ) then
						timeText = tostring( math.floor( remaining / 60 ) ) .. "m";
					elseif ( remaining > TENTHS_TRESHOLD ) then
						timeText = tostring( math.floor( remaining ) );
					elseif ( remaining > 0 ) then
						timeText = tostring( math.floor( remaining * 10 ) / 10 );
					end
					self.time:SetText( timeText );
					
					local barWidth = self.bar:GetWidth();
					
					local spark = self.spark;
					if ( spark ) then			
						spark:SetPoint( "CENTER", self.bar, "LEFT", barWidth * remaining / self.duration, 0 );
					end
					
					local castSeparator = self.castSeparator;
					if ( castSeparator and self.castSpellId ) then
						local _, _, _, _, _, _, castTime, _, _ = GetSpellInfo( self.castSpellId );

						castTime = castTime / 1000;
						if ( castTime and remaining > castTime ) then
							castSeparator:SetPoint( "CENTER", self.bar, "LEFT", barWidth * ( remaining - castTime ) / self.duration, 0 );
						else
							castSeparator:Hide();
						end
					end
				end
			end
			
			-- public
			local SetIcon = function( self, icon )
				if ( not self.icon ) then return; end
				
				self.icon:SetTexture( icon );
			end
			
			local SetTime = function( self, expirationTime, duration )
				self.expirationTime = expirationTime;
				self.duration = duration;
				
				if ( expirationTime > 0 and duration > 0 ) then		
					self.bar:SetMinMaxValues( 0, duration );
					OnUpdate( self, 0 );
			
					local spark = self.spark;
					if ( spark ) then 
						spark:Show();
					end
			
					self:SetScript( "OnUpdate", OnUpdate );
				else
					self.bar:SetMinMaxValues( 0, 1 );
					self.bar:SetValue( PERMANENT_AURA_VALUE );
					self.time:SetText( "" );
					
					local spark = self.spark;
					if ( spark ) then 
						spark:Hide();
					end
					
					self:SetScript( "OnUpdate", nil );
				end
			end
			
			local SetName = function( self, name )
				self.name:SetText( name );
			end
			
			local SetStacks = function( self, stacks )
				if ( not self.stacks ) then
					if ( stacks ~= nil and stacks > 1 ) then
						local name = self.name;
						
						name:SetText( tostring( stacks ) .. "  " .. name:GetText() );
					end
				else			
					if ( stacks ~= nil and stacks > 1 ) then
						self.stacks:SetText( stacks );
					else
						self.stacks:SetText( "" );
					end
				end
			end
			
			local SetColor = function( self, color )
				self.bar:SetStatusBarColor( unpack( color ) );
			end
			
			local SetCastSpellId = function( self, id )
				self.castSpellId = id;
				
				local castSeparator = self.castSeparator;
				if ( castSeparator ) then
					if ( id ) then
						self.castSeparator:Show();
					else
						self.castSeparator:Hide();
					end
				end
			end
			
			local SetAuraInfo = function( self, auraInfo )
				self:SetName( auraInfo.name );
				self:SetIcon( auraInfo.texture );	
				self:SetTime( auraInfo.expirationTime, auraInfo.duration );
				self:SetStacks( auraInfo.stacks );
				self:SetCastSpellId( auraInfo.castSpellId );
			end
			
			-- constructor
			CreateAuraBar = function( parent )
				local result = CreateFrame( "Frame", nil, parent, nil );

				if ( bit.band( ICON_POSITION, 4 ) == 0 ) then		
					local icon = CreateFramedTexture( result, "OVERLAY" );
					icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
			
					local iconbackdrop = CreateFrame("Frame")
					iconbackdrop:SetAllPoints(icon)
					
					local iconAnchor1;
					local iconAnchor2;
					local iconOffset;
					if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
						iconAnchor1 = "TOPLEFT";
						iconAnchor2 = "TOPRIGHT";
						iconOffset = 1;
					else
						iconAnchor1 = "TOPRIGHT";
						iconAnchor2 = "TOPLEFT";
						iconOffset = -1;
					end			
					
					if ( bit.band( ICON_POSITION, 2 ) == 2 ) then
						icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * 5, 0 );
					else
						icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * ( -BAR_HEIGHT ), 0 );
					end			
					icon:SetWidth( BAR_HEIGHT );
					icon:SetHeight( BAR_HEIGHT );	

					result.icon = icon;
					
					if ICON_POSITION == 2 or ICON_POSITION == 3 then
						iconbackdrop = CreateFrame("Frame")
						iconbackdrop:SetParent(result)
						iconbackdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", E.Scale(-2), E.Scale(2))
						iconbackdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
						iconbackdrop:SetTemplate("Default")
						iconbackdrop:SetFrameLevel(result:GetFrameLevel() - 1)
					end
					
					local stacks = result:CreateFontString( nil, "OVERLAY", nil );
					stacks:SetFont( unpack( STACKS_FONT ) );
					stacks:SetShadowColor( 0, 0, 0, 0 );
					stacks:SetShadowOffset( 1.25, -1.25 );
					stacks:SetPoint( "CENTER", icon, "CENTER", 1, 0);
					result.stacks = stacks;
					

				end
				

				
				local bar = CreateFrame( "StatusBar", nil, result, nil );
				bar:SetStatusBarTexture( C["media"].normTex );
				
				if ( bit.band( ICON_POSITION, 2 ) == 2 or bit.band( ICON_POSITION, 4 ) == 4 ) then
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
				else
					if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
						bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
						bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", -BAR_HEIGHT - 1, 0 );
					else
						bar:SetPoint( "TOPLEFT", result, "TOPLEFT", BAR_HEIGHT + 1, 0 );
						bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );					
					end	
				end
				
				bar.backdrop = CreateFrame("Frame", nil, bar)
				bar.backdrop:Point("TOPLEFT", bar, "TOPLEFT", -2, 2)
				bar.backdrop:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
				bar.backdrop:SetTemplate("Transparent")
				bar.backdrop:SetFrameLevel(bar:GetFrameLevel() - 1)
				
				if ICON_POSITION == 0 then
					bar.backdrop:Point("TOPLEFT", bar, "TOPLEFT", -20, 2)
				elseif ICON_POSITION == 1 then
					bar.backdrop:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 20, -2)
				end
				
				result.bar = bar;
				
				if ( SPARK ) then
					local spark = bar:CreateTexture( nil, "OVERLAY", nil );
					spark:SetTexture( [[Interface\CastingBar\UI-CastingBar-Spark]] );
					spark:SetWidth( 12 );
					spark:SetBlendMode( "ADD" );
					spark:Show();
					result.spark = spark;
				end
				
				if ( CAST_SEPARATOR ) then
					local castSeparator = bar:CreateTexture( nil, "OVERLAY", nil );
					castSeparator:SetTexture( unpack( CAST_SEPARATOR_COLOR ) );
					castSeparator:SetWidth( 1 );
					castSeparator:SetHeight( BAR_HEIGHT );
					castSeparator:Show();
					result.castSeparator = castSeparator;
				end
							
				local name = bar:CreateFontString( nil, "OVERLAY", nil );
				name:SetFont( unpack( MASTER_FONT ) );
				name:SetJustifyH( "LEFT" );
				name:SetShadowColor( 0, 0, 0, 0 );
				name:SetShadowOffset( 1.25, -1.25 );
				name:SetPoint( "TOPLEFT", bar, "TOPLEFT", TEXT_MARGIN, 0 );
				name:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -45, 0 );
				result.name = name;
				
				local time = bar:CreateFontString( nil, "OVERLAY", nil );
				time:SetFont( unpack( MASTER_FONT ) );
				time:SetJustifyH( "RIGHT" );
				time:SetShadowColor( 0, 0, 0, 0 );
				time:SetShadowOffset( 1.25, -1.25 );
				time:SetPoint( "TOPLEFT", name, "TOPRIGHT", 0, 0 );
				time:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -TEXT_MARGIN, 0 );
				result.time = time;
				
				result.SetIcon = SetIcon;
				result.SetTime = SetTime;
				result.SetName = SetName;
				result.SetStacks = SetStacks;
				result.SetAuraInfo = SetAuraInfo;
				result.SetColor = SetColor;
				result.SetCastSpellId = SetCastSpellId;
				
				return result;
			end
		end

		-- private
		local SetAuraBar = function( self, index, auraInfo )
			local line = self.lines[ index ]
			if ( line == nil ) then
				line = CreateAuraBar( self );
				if ( index == 1 ) then
					line:SetPoint( "TOPLEFT", self, "BOTTOMLEFT", 0, BAR_HEIGHT );
					line:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
				else
					local anchor = self.lines[ index - 1 ];
					line:SetPoint( "TOPLEFT", anchor, "TOPLEFT", 0, BAR_HEIGHT + BAR_SPACING );
					line:SetPoint( "BOTTOMRIGHT", anchor, "TOPRIGHT", 0, BAR_SPACING );
				end
				tinsert( self.lines, index, line );
			end	
			
			line:SetAuraInfo( auraInfo );
			if ( auraInfo.color ) then
				line:SetColor( auraInfo.color );
			elseif ( auraInfo.debuffColor and auraInfo.isDebuff ) then
				line:SetColor( auraInfo.debuffColor );
			elseif ( auraInfo.defaultColor ) then
				line:SetColor( auraInfo.defaultColor );
			end
			
			line:Show();
		end
		
		local function OnUnitAura( self, unit )
			if ( unit ~= self.unit and ( self.dataSource:GetIncludePlayer() == false or unit ~= "player" ) ) then
				return;
			end
			
			self:Render();
		end
		
		local function OnPlayerTargetChanged( self, method )
			self:Render();
		end
		
		local function OnPlayerEnteringWorld( self )
			self:Render();
		end
		
		local function OnEvent( self, event, ... )
			if ( event == "UNIT_AURA" ) then
				OnUnitAura( self, ... );
			elseif ( event == "PLAYER_TARGET_CHANGED" ) then
				OnPlayerTargetChanged( self, ... );
			elseif ( event == "PLAYER_ENTERING_WORLD" ) then
				OnPlayerEnteringWorld( self );
			else
				error( "Unhandled event " .. event );
			end
		end
		
		-- public
		local function Render( self )
			local dataSource = self.dataSource;	

			dataSource:Update();
			dataSource:Sort();
			
			local count = dataSource:Count();

			for index, auraInfo in ipairs( dataSource:Get() ) do
				SetAuraBar( self, index, auraInfo );
			end
			
			for index = count + 1, 80 do
				local line = self.lines[ index ];
				if ( line == nil or not line:IsShown() ) then
					break;
				end
				line:Hide();
			end
			
			if ( count > 0 ) then
				self:SetHeight( ( BAR_HEIGHT + BAR_SPACING ) * count - BAR_SPACING );
				self:Show();
			else
				self:Hide();
				self:SetHeight( self.hiddenHeight or 1 );
			end
		end
		
		local function SetHiddenHeight( self, height )
			self.hiddenHeight = height;
		end

		-- constructor
		CreateAuraBarFrame = function( dataSource, parent )
			local result = CreateFrame( "Frame", nil, parent, nil );
			local unit = dataSource:GetUnit();
			
			result.unit = unit;
			
			result.lines = { };		
			result.dataSource = dataSource;
			
			local background = result:CreateTexture( nil, "BACKGROUND", nil );
			background:SetAlpha( 0 );
			background:SetTexture( C["media"].normTex );
			background:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
			background:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
			background:SetVertexColor( 0.15, 0.15, 0.15 );
			result.background = background;
			
			local border = CreateFrame( "Frame", nil, result, nil );
				--border:SetTemplate("Default")
				border:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
				border:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				if result:GetFrameLevel() - 1 > -1 then 
					border:SetFrameLevel(result:GetFrameLevel() - 1)
				else
					border:SetFrameLevel(0)
				end
				border:SetBackdropColor(unpack(C["media"].backdropfadecolor))
			result.border = border;		
			
			result:RegisterEvent( "PLAYER_ENTERING_WORLD" );
			result:RegisterEvent( "UNIT_AURA" );
			if ( unit == "target" ) then
				result:RegisterEvent( "PLAYER_TARGET_CHANGED" );
			end
			
			result:SetScript( "OnEvent", OnEvent );
			
			result.Render = Render;
			result.SetHiddenHeight = SetHiddenHeight;
			
			return result;
		end
	end

	local _, playerClass = UnitClass( "player" );
	local classFilter = CLASS_FILTERS[ playerClass ];

	if ( LAYOUT == 1 ) then
		local dataSource = CreateUnitAuraDataSource( "target" );

		dataSource:SetSortDirection( SORT_DIRECTION );
		
		dataSource:AddPlayerFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );
		
		if ( classFilter ) then
			dataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
			dataSource:AddPlayerFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			dataSource:AddPlayerFilter( classFilter.procs, TRINKET_BAR_COLOR );
			dataSource:SetIncludePlayer( classFilter.player ~= nil );
		end
		local playerFrame = CreateAuraBarFrame( dataSource, Elv_player );
		local yOffset = 6;
		local xOffset1 = 0
		local xOffset2 = -2
		if ICON_POSITION == 0 or ICON_POSITION == 1 then
			xOffset1 = 3
		end		
		if ICON_POSITION == 2 then
			xOffset2 = -2
			xOffset1 = xOffset1 + BAR_HEIGHT+7
		end
		if ICON_POSITION == 3 then
			xOffset1 = 2
			xOffset2 = xOffset2 - (BAR_HEIGHT+5)
		end
		
		playerFrame:SetHiddenHeight( -yOffset );
		if Elv_player.Debuffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Debuffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Debuffs, "TOPRIGHT", xOffset2, yOffset );	
		elseif Elv_player.Buffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Buffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			playerFrame:Point( "BOTTOMLEFT", Elv_player, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player, "TOPRIGHT", xOffset2, yOffset );			
		end
		
		playerFrame:Show(); 
	elseif ( LAYOUT == 2 ) then
		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );

		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		
		playerDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			playerDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		if ICON_POSITION == 0 or ICON_POSITION == 1 then
			xOffset1 = 3
		end
		local yOffset = 6;
		local xOffset1 = 0
		local xOffset2 = -2
		if ICON_POSITION == 2 then
			xOffset2 = -2
			xOffset1 = xOffset1 + BAR_HEIGHT+7
		end
		if ICON_POSITION == 3 then
			xOffset1 = 2
			xOffset2 = xOffset2 - (BAR_HEIGHT+5)
		end
		
		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );	
		playerFrame:SetHiddenHeight( -yOffset );
		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );
		playerFrame:SetHiddenHeight( -yOffset );
		if Elv_player.Debuffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Debuffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Debuffs, "TOPRIGHT", xOffset2, yOffset );	
		elseif Elv_player.Buffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Buffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			playerFrame:Point( "BOTTOMLEFT", Elv_player, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player, "TOPRIGHT", xOffset2, yOffset );			
		end
		playerFrame:Show();

		local targetFrame = CreateAuraBarFrame( targetDataSource, Elv_player );
		targetFrame:Point( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, BAR_SPACING+GROUP_SPACING );
		targetFrame:Point( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, BAR_SPACING+GROUP_SPACING );
		targetFrame:Show();
	elseif ( LAYOUT == 3 ) then
		local yOffset = 6;
		local xOffset1 = 0
		local xOffset2 = -2
		
		if ICON_POSITION == 0 or ICON_POSITION == 1 then
			xOffset1 = 3
		end		
		if ICON_POSITION == 2 then
			xOffset2 = -2
			xOffset1 = xOffset1 + BAR_HEIGHT+7
		end
		if ICON_POSITION == 3 then
			xOffset1 = 2
			xOffset2 = xOffset2 - (BAR_HEIGHT+5)
		end
		
		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );
		local trinketDataSource = CreateUnitAuraDataSource( "player" );
		
		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		trinketDataSource:SetSortDirection( SORT_DIRECTION );
		
		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );
		
		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );
		playerFrame:SetHiddenHeight( -yOffset );
		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );
		playerFrame:SetHiddenHeight( -yOffset );
		
		if Elv_player.Debuffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Debuffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Debuffs, "TOPRIGHT", xOffset2, yOffset );	
		elseif Elv_player.Buffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Buffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			playerFrame:Point( "BOTTOMLEFT", Elv_player, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player, "TOPRIGHT", xOffset2, yOffset );			
		end

		playerFrame:Show();

		local trinketFrame = CreateAuraBarFrame( trinketDataSource, Elv_player );
		trinketFrame:SetHiddenHeight( -BAR_SPACING );
		trinketFrame:Point( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Point( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Show();
		
		local targetFrame = CreateAuraBarFrame( targetDataSource, Elv_player );
		targetFrame:SetHiddenHeight( -BAR_SPACING );
		targetFrame:Point( "BOTTOMLEFT", trinketFrame, "TOPLEFT", 0, BAR_SPACING+GROUP_SPACING );
		targetFrame:Point( "BOTTOMRIGHT", trinketFrame, "TOPRIGHT", 0, BAR_SPACING+GROUP_SPACING );
		targetFrame:Show();
	elseif ( LAYOUT == 4 ) then
		local yOffset = 6;
		local xOffset1 = 0
		local xOffset2 = -2
		
		if ICON_POSITION == 0 or ICON_POSITION == 1 then
			xOffset1 = 3
		end
		
		if ICON_POSITION == 2 then
			xOffset2 = -2
			xOffset1 = xOffset1 + BAR_HEIGHT+7
		end
		if ICON_POSITION == 3 then
			xOffset1 = 2
			xOffset2 = xOffset2 - (BAR_HEIGHT+5)
		end
		
		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );
		local trinketDataSource = CreateUnitAuraDataSource( "player" );
		
		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		trinketDataSource:SetSortDirection( SORT_DIRECTION );
		
		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );
		playerFrame:SetHiddenHeight( -yOffset );
		if Elv_player.Debuffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Debuffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Debuffs, "TOPRIGHT", xOffset2, yOffset );	
		elseif Elv_player.Buffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Buffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			playerFrame:Point( "BOTTOMLEFT", Elv_player, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player, "TOPRIGHT", xOffset2, yOffset );			
		end
		playerFrame:Show();


		local trinketFrame = CreateAuraBarFrame( trinketDataSource, Elv_player );
		trinketFrame:SetHiddenHeight( -BAR_SPACING );
		trinketFrame:Point( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Point( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Show();
		
		local targetFrame = CreateAuraBarFrame( targetDataSource, Elv_target );
		if Elv_target.Debuffs then
			targetFrame:Point( "BOTTOMLEFT", Elv_target.Debuffs, "TOPLEFT", xOffset1, yOffset );
			targetFrame:Point( "BOTTOMRIGHT", Elv_target.Debuffs, "TOPRIGHT", xOffset2, yOffset );
		elseif Elv_target.Buffs then
			targetFrame:Point( "BOTTOMLEFT", Elv_target.Buffs, "TOPLEFT", xOffset1, yOffset );
			targetFrame:Point( "BOTTOMRIGHT", Elv_target.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			targetFrame:Point( "BOTTOMLEFT", Elv_target, "TOPLEFT", xOffset1, yOffset );
			targetFrame:Point( "BOTTOMRIGHT", Elv_target, "TOPRIGHT", xOffset2, yOffset );		
		end		
		targetFrame:Show();
	elseif ( LAYOUT == 5 ) then
		local yOffset = 6;
		local xOffset1 = 0
		local xOffset2 = -2
		
		if ICON_POSITION == 0 or ICON_POSITION == 1 then
			xOffset1 = 3
		end		
		if ICON_POSITION == 2 then
			xOffset2 = -2
			xOffset1 = xOffset1 + BAR_HEIGHT+7
		end
		if ICON_POSITION == 3 then
			xOffset1 = 2
			xOffset2 = xOffset2 - (BAR_HEIGHT+5)
		end
		
		local playerDataSource = CreateUnitAuraDataSource( "player" );
		local trinketDataSource = CreateUnitAuraDataSource( "player" );
		
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		trinketDataSource:SetSortDirection( SORT_DIRECTION );
		
		if ( classFilter ) then
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		local playerFrame = CreateAuraBarFrame( playerDataSource, Elv_player );
		playerFrame:SetHiddenHeight( -yOffset );
		if Elv_player.Debuffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Debuffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Debuffs, "TOPRIGHT", xOffset2, yOffset );	
		elseif Elv_player.Buffs then
			playerFrame:Point( "BOTTOMLEFT", Elv_player.Buffs, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player.Buffs, "TOPRIGHT", xOffset2, yOffset );		
		else
			playerFrame:Point( "BOTTOMLEFT", Elv_player, "TOPLEFT", xOffset1, yOffset );
			playerFrame:Point( "BOTTOMRIGHT", Elv_player, "TOPRIGHT", xOffset2, yOffset );			
		end
		playerFrame:Show();


		local trinketFrame = CreateAuraBarFrame( trinketDataSource, Elv_player );
		trinketFrame:SetHiddenHeight( -BAR_SPACING );
		trinketFrame:Point( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Point( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, BAR_SPACING+GROUP_SPACING );
		trinketFrame:Show();
	else
		error( "Undefined layout " .. tostring( LAYOUT ) );
	end
end

--We need to load classtimers after our UnitFrames load..
local ClassTimerLoader = CreateFrame("Frame")
ClassTimerLoader:RegisterEvent("ADDON_LOADED")
ClassTimerLoader:SetScript("OnEvent", OnUnitFramesLoad)