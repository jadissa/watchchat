 -------------------------------------
-- wc --------------
-- Emerald Dream/Grobbulus --------

-- 
local utility   = LibStub:GetLibrary( 'utility' )
local wc  = LibStub( 'AceAddon-3.0' ):NewAddon( 'wc' )

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
function wc:notify( ... )

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

-- persistence reference
--
-- returns table
function wc:getDB( ) 
  return self[ 'db' ]
end

-- persistence reference
--
-- returns table
function wc:getNameSpace( )
  return self:getDB( )[ 'profile' ]
end

-- persistence wipe handler
--
-- returns table
function wc:wipeDB( )
  return self:getDB( ):ResetDB( )
end

-- set/get configuration
-- if it needs to be modified, a copy should be made
-- keep this copy pristine and in original condition
--
-- returns table
function wc:getConfig( )

  local persistence = self:getNameSpace( )
  if persistence[ 'watch' ] ~= nil then
    return persistence[ 'watch' ]
  end
  persistence[ 'watch' ] = { }
  return persistence[ 'watch' ]

end

-- build baseline data
--
-- returns void
function wc:init( )
  self:getConfig( )
end

-- register persistence
--
-- returns void
function wc:OnInitialize( )

  local defaults = { }
  defaults[ 'profile' ] = { }
  defaults[ 'profile' ][ 'options' ]  = { }
  defaults[ 'profile' ][ 'options' ][ 'sound' ]  = true
  defaults[ 'profile' ][ 'options' ][ 'verbose' ]  = true

  self[ 'db' ] = LibStub( 'AceDB-3.0' ):New(
    'persistence', defaults, true
  )

end

-- activated app handler
--
-- returns void
function wc:OnEnable( )

  self:Enable( )
  self:init( )

end