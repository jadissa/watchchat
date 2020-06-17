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
end

-- process slash commands
--
-- returns void
function ui:processInput( input )
  
  local tokens = { }
  for token in string.gmatch( input, "[^%s]+" ) do
    tinsert( tokens, token )
  end

  if tokens[ 1 ] == 'add' then
  	self:add( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'remove' then
    self:remove( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'list' then
    self:list( )
  else
  	self:help( )
  end

end

-- add to watch list
-- 
-- returns void
function ui:add( input )

  local iterator = 0
  local found = false
  local persistence = wc:getNameSpace( )
  for i, keyword in pairs( persistence[ 'watch' ] ) do
    if input == keyword then
      iterator = i
      found = true
    end
  end
  if not found then
    tinsert( persistence[ 'watch' ], input )
    wc:notify( 'added ' .. input )
  else
    wc:notify( 'already watching ' .. input )
  end

end

-- remove from watch list
-- 
-- returns void
function ui:remove( input )

   local persistence = wc:getNameSpace( )
   for i, keyword in pairs( persistence[ 'watch' ] ) do
    if string.lower( persistence[ 'watch' ][ i ] ) == string.lower( keyword ) then
      tremove( persistence[ 'watch' ], i )
      wc:warn( 'removed ' .. input )
    end
   end

end

-- report watch list
-- 
-- returns void
function ui:list( )

  local persistence = wc:getNameSpace( )
  for i, keyword in pairs( persistence[ 'watch' ] ) do
    wc:warn( 'activated for ' .. keyword )
  end

end

function ui:help( )

  wc:warn( 'try /wc add keyword' )
  wc:warn( 'try /wc remove keyword' )
  wc:warn( 'try /wc list' )

end

-- watch chat
-- 
-- returns void
function ui:listen( )

  local f = CreateFrame( 'Frame' )
  f:RegisterEvent( 'CHAT_MSG_CHANNEL' )
  f:RegisterEvent( 'CHAT_MSG_SAY' )
  local channels = getChannels( )
  for _, channel in pairs( channels ) do
    wc:notify( 'WATCHING ' .. channel[ 'name' ] )
  end

  local persistence = wc:getNameSpace( )
  local watches = persistence[ 'watch' ]
  for i, watch in pairs( watches ) do
    wc:warn( 'activated for ' .. watches[ i ] )
  end
  self:help( )

  f:SetScript( 'OnEvent', function( self, event, msg, sender, _, chanString, _, _, _, chanNumber, chanName )

    for _, channel in pairs( channels ) do
      if chanName == channel[ 'name' ] then
        if message == nil then
          return
        end
        for i = 1, #watches do
          local i, j = string.find( string.lower( msg ), string.lower( watches[ i ] ) )
          if i ~= nil then
            if string.sub( string.lower( msg ), i, j ) == string.lower( watches[ i ] ) then
              if chanNumber > 0 then SendChatMessage( 'WATCH TRIGGERED! ' .. 'channel ' .. chanName .. ' ' .. sender .. ' said: ' .. msg, 'WHISPER', nil, GetUnitName( 'player' ) ) end
            end
          end
        end
      end

    end

  end )

end

-- get joined channels
-- 
-- returns object
function getChannels( )

  local channels = { }
  local chanList = { GetChannelList( ) }
  for i=1, #chanList, 3 do
    table.insert( channels, {
      id = chanList[ i ],
      name = chanList[ i+1 ],
      isDisabled = chanList[ i+2 ],
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