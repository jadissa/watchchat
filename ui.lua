 -------------------------------------
-- wc --------------
-- Emerald Dream/Grobbulus --------

-- 
local wc = LibStub( 'AceAddon-3.0' ):GetAddon( 'wc' )
local ui = wc:NewModule( 'ui', 'AceConsole-3.0' )
local utility = LibStub:GetLibrary( 'utility' )

-- setup addon
--
-- returns void
function ui:init( )

  self:RegisterChatCommand( 'wc', 'processInput' )
  self[ 'channels' ]    = self:getChannels( )
  self[ 'persistence' ] = wc:getNameSpace( )

  --[[
  -- clear out watch
  self[ 'persistence' ][ 'watch' ]  = { }

  -- clear out ignore
  self[ 'persistence' ][ 'ignore' ] = { }
  ]]

  self[ 'watches' ]     = self[ 'persistence' ][ 'watch' ] or { }
  self[ 'ignores' ]     = self[ 'persistence' ][ 'ignore' ] or { }
  self[ 'options' ]     = self[ 'persistence' ][ 'options' ]
  utility:dump( self['options' ] )
  self[ 'events' ]      = {
    'CHAT_MSG_GUILD',
    'CHAT_MSG_CHANNEL',
    'CHAT_MSG_SAY',
    'CHAT_MSG_PARTY',
    'CHAT_MSG_WHISPER',
  }

end

-- process slash commands
--
-- returns void
function ui:processInput( input )
  
  local tokens = { }
  for token in string.gmatch( input, "[^%s]+" ) do
    tinsert( tokens, token )
  end

  if tokens[ 1 ] == 'watch' then
  	self:watch( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'unwatch' then
    self:unwatch( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'ignore' then
    self:ignore( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'unignore' then
    self:unignore( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'list' then
    self:list( )
  elseif tokens[ 1 ] == 'sound' then
    self:sound( )
  else
  	self:help( )
  end

end

function ui:color( input )

  return CreateColor(
    wc[ 'theme' ][ 'info' ][ 'r' ], 
    wc[ 'theme' ][ 'info' ][ 'g' ], 
    wc[ 'theme' ][ 'info' ][ 'b' ] 
  ):WrapTextInColorCode( input )

end

-- add to watch list
-- 
-- returns void
function ui:watch( input )

  local iterator = 0
  local found = false
  for i, keyword in pairs( self[ 'watches' ] ) do
    if strlower( input ) == strlower( keyword ) then
      iterator = i
      found = true
    end
  end
  if not found then
    tinsert( self[ 'watches' ], input )
    wc:notify( 'watching ' .. input )
  else
    wc:warn( 'already watching ' .. input )
  end

end

-- remove from watch list
-- 
-- returns void
function ui:unwatch( input )

   for i, keyword in pairs( self[ 'watches' ] ) do
    if strlower( input ) == strlower( keyword ) then
      tremove( self[ 'watches' ], i )
      wc:warn( 'no longer watching ' .. input )
    end
   end

end

-- add to ignore list
-- 
-- returns void
function ui:ignore( input )

  local iterator = 0
  local found = false
  for i, keyword in pairs( self[ 'ignores' ] ) do
    if input == keyword then
      iterator = i
      found = true
    end
  end
  if not found then
    tinsert( self[ 'ignores' ], input )
    wc:notify( 'ignoring ' .. input )
  else
    wc:warn( 'already ignoring ' .. input )
  end

end

-- remove from ignore list
-- 
-- returns void
function ui:unignore( input )

   for i, keyword in pairs( self[ 'ignores' ] ) do
    if strlower( input ) == strlower( keyword ) then
      tremove( self[ 'ignores' ], i )
      wc:warn( 'no longer ignoring ' .. input )
    end
   end

end

-- report list
-- 
-- returns void
function ui:list( )

  for i, keyword in pairs( self[ 'watches' ] ) do
    wc:notify( 'watching ' .. keyword )
  end
  for i, keyword in pairs( self[ 'ignores' ] ) do
    wc:warn( 'ignoring ' .. keyword )
  end

end

-- toggles sound
-- 
-- returns void
function ui:sound( )

  if self[ 'options' ][ 'sound' ] == false then
    self[ 'options' ][ 'sound' ]  = true
    wc:warn( 'enabled sound' )
  else
    self[ 'options' ][ 'sound' ]  = false
    wc:warn( 'disabled sound' )
  end

end

-- help
-- 
-- returns void
function ui:help( )

  wc:warn( 'try /wc watch keyword' )
  wc:warn( 'try /wc unwatch keyword' )
  wc:warn( 'try /wc ignore keyword' )
  wc:warn( 'try /wc unignore keyword' )
  wc:warn( '-- display keywords: try /wc list' )
  wc:warn( '-- toggle sound: try /wc sound' )
  if self[ 'options' ][ 'sound' ] == true then
    wc:notify( 'sound is enabled' )
  else
    wc:warn( 'sound is disabled' )
  end

end

-- filter garbage
-- 
-- returns void
function ui:filter( event, message, sender, ... )

  if message == nil or sender == GetUnitName( 'player' ) .. '-' .. GetRealmName() then
    return
  end
  for _, ignore in pairs( ui[ 'ignores' ] ) do
    if strlower( message ):find( strlower( ignore ) ) then
      return true
    end
  end
  for _, watch in pairs( ui[ 'watches' ] ) do
    if strlower( message ):find( strlower( watch ) ) then

      local prefix = ui:color( wc:GetName( ) .. ' {diamond} ' )
      if ui[ 'options' ][ 'sound' ] == true then
        PlaySound( SOUNDKIT.TELL_MESSAGE )
      end

      return false, string.join( ' ', prefix, message ), sender, ...
    end
  end

end

-- watch chat
-- 
-- returns void
function ui:listen( )

  local f = CreateFrame( 'Frame' )
  for _, event in ipairs( self[ 'events' ] ) do
    ChatFrame_AddMessageEventFilter( event, ui.filter )
    f:RegisterEvent( event )
  end
  for _, channel in pairs( self[ 'channels' ] ) do
    wc:notify( 'WATCHING ' .. channel[ 'name' ] )
  end
  local guild_name = GetGuildInfo( 'player' )
  if guild_name ~= nil then
    wc:notify( 'WATCHING ' .. guild_name )
  end
  self:help( )

end

-- get joined channels
-- 
-- returns object
function ui:getChannels( )

  local channels = { }
  local chanList = { GetChannelList( ) }
  for i=1, #chanList, 3 do
    tinsert( channels, {
      id = chanList[ i ],
      name = chanList[ i + 1 ],
      isDisabled = chanList[ i + 2 ],
    } )
  end
  return channels

end

-- register addon
--
-- returns void
function ui:OnInitialize( )
  self:Enable( )
end

-- activated addon handler
--
-- returns void
function ui:OnEnable( )
  self:init( )
  self:listen( )
end