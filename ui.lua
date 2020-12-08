 -------------------------------------
-- wc --------------
-- Emerald Dream/Grobbulus --------

-- 
local ui = LibStub( 'AceAddon-3.0' ):GetAddon( 'wc' )
local utility = LibStub:GetLibrary( 'utility' )

-- setup addon
--
-- returns void
function ui:setup( )

  self:RegisterChatCommand( 'wc', 'processInput' )
  self[ 'channels' ]              = self:getChannels( )
  self[ 'persistence' ]           = ui:getNameSpace( )
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
  elseif tokens[ 1 ] == 'notify' then
    self:notify( )
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
    ui[ 'theme' ][ theme ][ 'r' ], 
    ui[ 'theme' ][ theme ][ 'g' ], 
    ui[ 'theme' ][ theme ][ 'b' ] 
  ):WrapTextInColorCode( input )

end

-- add to watch list
-- 
-- returns void
function ui:watch( input )

  if input == nil then
    ui:warn( 'try /wc watch keyword' )
    return false
  end
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
    ui:info( 'watching ' .. input )
  else
    ui:warn( 'already watching ' .. input )
  end

end

-- remove from watch list
-- 
-- returns void
function ui:unwatch( input )

  if input == nil then
    ui:warn( 'try /wc unwatch keyword' )
    return false
  end
  for i, keyword in pairs( self[ 'watches' ] ) do
    if strlower( input ) == strlower( keyword ) then
      tremove( self[ 'watches' ], i )
      ui:warn( 'no longer watching ' .. input )
    end
  end

end

-- add to ignore list
-- 
-- returns void
function ui:ignore( input )

  if input == nil then
    ui:warn( 'try /wc ignore keyword' )
    return false
  end
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
    ui:info( 'ignoring ' .. input )
  else
    ui:warn( 'already ignoring ' .. input )
  end

end

-- remove from ignore list
-- 
-- returns void
function ui:unignore( input )

  if input == nil then
    ui:warn( 'try /wc unignore keyword' )
    return false
  end
  for i, keyword in pairs( self[ 'ignores' ] ) do
    if strlower( input ) == strlower( keyword ) then
      tremove( self[ 'ignores' ], i )
      ui:warn( 'no longer ignoring ' .. input )
    end
  end

end

-- report list
-- 
-- returns void
function ui:list( )

  for i, keyword in pairs( self[ 'watches' ] ) do
    ui:info( 'watching ' .. keyword )
  end
  for i, keyword in pairs( self[ 'ignores' ] ) do
    ui:warn( 'ignoring ' .. keyword )
  end

end

-- toggles sound
-- 
-- returns void
function ui:sound( )

  if self[ 'options' ][ 'sound' ] == false then
    self[ 'options' ][ 'sound' ]  = true
    ui:info( 'enabled sound' )
  else
    self[ 'options' ][ 'sound' ]  = false
    ui:warn( 'disabled sound' )
  end

end

-- toggles limit
-- 
-- returns void
function ui:rate( )

  if self[ 'options' ][ 'rate_limit' ] == false then
    self[ 'options' ][ 'rate_limit' ]  = true
    ui:info( 'enabled limit' )
  else
    self[ 'options' ][ 'rate_limit' ]  = false
    ui:warn( 'disabled limit' )
  end

end

-- toggles notify
-- 
-- returns void
function ui:notify( )

  if self[ 'options' ][ 'pause_notify' ] == false then
    self[ 'options' ][ 'pause_notify' ]  = true
    ui:warn( 'diabled notify' )
  else
    self[ 'options' ][ 'pause_notify' ]  = false
    ui:info( 'enabled notify' )
  end

end

-- help
-- 
-- returns void
function ui:help( )

  ui:warn( '-- watch keyword: try /wc watch' )
  ui:warn( '-- unwatch keyword: try /wc unwatch' )
  ui:warn( '-- ignore keyword: try /wc ignore' )
  ui:warn( '-- unignore keyword: try /wc unignore' )
  ui:warn( '-- display keywords: try /wc list' )
  ui:warn( '-- toggle sound: try /wc sound' )
  ui:warn( '-- toggle limit: try /wc limit' )
  ui:warn( '-- toggle notify: try /wc notify' )
  if self[ 'options' ][ 'sound' ] == true then
    ui:info( 'sound is enabled' )
  else
    ui:warn( 'sound is disabled' )
  end
  if self[ 'options' ][ 'rate_limit' ] == true then
    ui:info( 'limit is enabled' )
  else
    ui:warn( 'limit is disabled' )
  end
  if self[ 'options' ][ 'pause_notify' ] == true then
    ui:warn( 'notify is disabled' )
  else
    ui:info( 'notify is enabled' )
  end

end

-- filter chat
-- 
-- returns void
function ui:filter( event, message, sender, ... )
  
  -- ignore everything the player says
  -- do not highlight
  if message == nil or sender == GetUnitName( 'player' ) .. '-' .. GetRealmName() then
    return false, message, sender, ...
  end

  -- ignore everything on the ignore list
  for _, ignore in pairs( ui[ 'ignores' ] ) do
    if strlower( message ):find( strlower( ignore ) ) then
      return true
    end
  end

  -- ignore everything if paused
  if ui[ 'options' ][ 'pause_notify' ] == true then
    return false, message, sender, ...
  end

  -- check for matching watch
  local found = false
  for _, watch in pairs( ui[ 'watches' ] ) do
    if strlower( message ):find( strlower( watch ) ) then
      found = true
    end
  end
  if found == true then
    ui:cache( sender, message )
    if ui[ 'options' ][ 'rate_limit' ] == true then
      if ui[ 'seen' ][ sender ][ message ][ 'count' ] >= ui[ 'limit' ] then
        return true
      end
    end
    local prefix = ui:color( ui:GetName( ) .. ' {diamond} ' )
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
    ui:info( 'WATCHING ' .. channel[ 'name' ] )
  end
  local guild_name = GetGuildInfo( 'player' )
  if guild_name ~= nil then
    ui:info( 'WATCHING ' .. guild_name )
  end
  f = CreateFrame( 'Frame' )
  f:RegisterEvent( 'PLAYER_LOGOUT' )
  local function logoutHandler( self, event, ... )
    if event == 'PLAYER_LOGOUT' then
      ui[ 'seen' ]  = { }
    end
  end
  f:SetScript( 'OnEvent', logoutHandler )
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
  self:setup( )
  self:listen( )
end