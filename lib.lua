 -------------------------------------
-- wc --------------
-- Emerald Dream/Grobbulus --------

-- 
local utility   = LibStub:GetLibrary( 'utility' )
local wc  = LibStub( 'AceAddon-3.0' ):NewAddon( 'wc', 'AceConsole-3.0' )

wc[ 'messenger' ] = _G[ 'DEFAULT_CHAT_FRAME' ]
wc[ 'theme' ] = {
  text = {
    hex = 'ffffff',
  },
  info = {
    hex = 'ff30f4', 
  },
  warn = {
    hex = 'ffbf00', 
  },
  font = {
    family = 'Fonts\\FRIZQT__.TTF',
    flags = 'OUTLINE, MONOCHROME',
    large = 14,
    normal = 10,
    small = 8,
  },
}

local systemv 
local enduserv

for name, tdata in pairs( wc[ 'theme' ] ) do
  if name ~= 'font' then
    wc[ 'theme' ][ name ][ 'r' ], 
    wc[ 'theme' ][ name ][ 'g' ], 
    wc[ 'theme' ][ name ][ 'b' ] 
    = utility:hex2rgb( tdata[ 'hex' ] )
  end
end

-- notice message handler
--
-- returns void
function wc:info( ... )

  local prefix = CreateColor(
    self[ 'theme' ][ 'info' ][ 'r' ], 
    self[ 'theme' ][ 'info' ][ 'g' ], 
    self[ 'theme' ][ 'info' ][ 'b' ] 
  ):WrapTextInColorCode( self:GetName( ) )

  self[ 'messenger' ]:AddMessage( string.join( ' ', prefix, ... ) )

end

-- warning message handler
--
-- returns void
function wc:warn( ... )

  local prefix = CreateColor(
    self[ 'theme' ][ 'warn' ][ 'r' ], 
    self[ 'theme' ][ 'warn' ][ 'g' ], 
    self[ 'theme' ][ 'warn' ][ 'b' ] 
  ):WrapTextInColorCode( self:GetName( ) )

  self[ 'messenger' ]:AddMessage( string.join( ' ', prefix, ... ) )

end

function wc:cache( sender, message )

  if sender == nil or message == nil then
    return
  end
  local persistence = self:getNameSpace( )
  if persistence[ 'seen' ][ sender ] == nil then
    persistence[ 'seen' ][ sender ] = { }
  end
  if persistence[ 'seen' ][ sender ][ message ] == nil then
    persistence[ 'seen' ][ sender ][ message ] = {
      count = 1
    }
  else
    persistence[ 'seen' ][ sender ][ message ][ 'count' ] = persistence[ 'seen' ][ sender ][ message ][ 'count' ] + 1
  end

end

-- persistence reference
--
-- returns table
function wc:getDB( ) 
  return self[ 'db' ]
end

-- character persistence reference
--
-- returns table
function wc:getNameSpace( )
  local db = self:getDB( )
  if db == nil then
    local defaults = { }
    defaults[ 'char' ] = { }
    defaults[ 'char' ][ 'watch' ] = { strlower( GetUnitName( 'player' ) ) }
    defaults[ 'char' ][ 'ignore' ] = { }
    defaults[ 'char' ][ 'options' ]  = { }
    defaults[ 'char' ][ 'options' ][ 'sound' ]  = true
    defaults[ 'char' ][ 'options' ][ 'verbose' ]  = true
    defaults[ 'char' ][ 'options' ][ 'rate_limit' ]  = true
    defaults[ 'char' ][ 'options' ][ 'pause_notify' ]  = false
    defaults[ 'char' ][ 'seen' ] = { }
    self[ 'db' ] = LibStub( 'AceDB-3.0' ):New(
      'wc', defaults, true
    )
  end
  return self:getDB( )[ 'char' ]
end

-- persistence wipe handler
--
-- returns table
function wc:wipeDB( )
  return self:getDB( ):ResetDB( )
end