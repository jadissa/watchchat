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
  self[ 'channels' ]              = self:getChannels( )
  self[ 'persistence' ]           = wc:getNameSpace( )
  self[ 'persistence' ][ 'seen' ] = { }

  --[[
  -- clear out watch
  self[ 'persistence' ][ 'watch' ]  = { }

  -- clear out ignore
  self[ 'persistence' ][ 'ignore' ] = { }
  ]]

  self[ 'watches' ]     = self[ 'persistence' ][ 'watch' ] or { }
  self[ 'ignores' ]     = self[ 'persistence' ][ 'ignore' ] or { }
  self[ 'options' ]     = self[ 'persistence' ][ 'options' ]
  self[ 'seen' ]        = self[ 'persistence' ][ 'seen' ]
  self[ 'events' ]      = {
    'CHAT_MSG_GUILD',
    'CHAT_MSG_CHANNEL',
    'CHAT_MSG_SAY',
    'CHAT_MSG_PARTY',
    'CHAT_MSG_WHISPER',
  }
  self[ 'limit' ]       = #self[ 'events' ] * 4

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
  elseif tokens[ 1 ] == 'limit' then
    self:rate( )
  else
  	self:help( )
  end

end

-- colorize text
--
-- returns void
function ui:color( input, theme )

  if theme == nil then
    theme = 'info'
  end
  return CreateColor(
    wc[ 'theme' ][ theme ][ 'r' ], 
    wc[ 'theme' ][ theme ][ 'g' ], 
    wc[ 'theme' ][ theme ][ 'b' ] 
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

-- toggles limit
-- 
-- returns void
function ui:rate( )

  if self[ 'options' ][ 'rate_limit' ] == false then
    self[ 'options' ][ 'rate_limit' ]  = true
    wc:warn( 'enabled limit' )
  else
    self[ 'options' ][ 'rate_limit' ]  = false
    wc:warn( 'disabled limit' )
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
  wc:warn( '-- toggle limit: try /wc limit' )
  if self[ 'options' ][ 'sound' ] == true then
    wc:notify( 'sound is enabled' )
  else
    wc:warn( 'sound is disabled' )
  end
  if self[ 'options' ][ 'rate_limit' ] == true then
    wc:notify( 'limit is enabled' )
  else
    wc:warn( 'limit is disabled' )
  end

end

-- filter chat
-- 
-- returns void
function ui:filter( event, message, sender, ... )
  
  if message == nil or sender == GetUnitName( 'player' ) .. '-' .. GetRealmName() then
    return true
  end
  for _, ignore in pairs( ui[ 'ignores' ] ) do
    if strlower( message ):find( strlower( ignore ) ) then
      return true
    end
  end
  local found = false
  for _, watch in pairs( ui[ 'watches' ] ) do
    if strlower( message ):find( strlower( watch ) ) then
      found = true
    end
  end
  if found == true then
    wc:cache( sender, message )
    if ui[ 'options' ][ 'rate_limit' ] == true then
      if ui[ 'seen' ][ sender ][ message ][ 'count' ] >= ui[ 'limit' ] then
        return true
      end
    end
    local prefix = ui:color( wc:GetName( ) .. ' {diamond} ' )
    if ui[ 'options' ][ 'sound' ] == true then
      PlaySound( SOUNDKIT.TELL_MESSAGE )
    end
    return false, string.join( '', prefix, ui:color( message, 'text' ) ), sender, ...
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
  local i = CreateFrame( 'Frame' )
  i:RegisterEvent( 'PLAYER_LOGOUT' )
  local function logoutHandler( self, event, ... )
    if event == 'PLAYER_LOGOUT' then
      ui[ 'seen' ]  = { }
    end
  end
  i:SetScript( 'OnEvent', logoutHandler )
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