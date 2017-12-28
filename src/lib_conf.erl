%% -*- erlang -*-
%%
%% Simple Erlang configuration handling library.
%%
%% Copyright 2017 Jörgen Brandt
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%    http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% -------------------------------------------------------------------
%% @author Jörgen Brandt <joergen.brandt@onlinehome.de>
%% @version 0.1.3
%% @copyright 2017 Jörgen Brandt
%%
%% @end
%% -------------------------------------------------------------------


-module( lib_conf ).
-author( "Jorgen Brandt <brandjoe@hu-berlin.de>" ).

-export( [create_conf/5] ).


%% @doc Creates a map by combining a DefaultMap, a map extracted from a
%%      ConfigFile, and a ManualMap.
%%
%%      The resulting map contains only keys that were also in DefaultMap. The
%%      values for any of these keys are overwritten first with the according
%%      values from the ConfFile and then with the according values from the
%%      ManualMap.

-spec create_conf( DefaultMap, GlobalFile, UserFile, SupplFile, FlagMap ) ->
        #{ atom() => _ }
when DefaultMap :: #{ atom() => _},
     GlobalFile :: string(),
     UserFile   :: string(),
     SupplFile  :: undefined | string(),
     FlagMap    :: #{ atom() => _ }.

create_conf( DefaultMap, GlobalFile, UserFile, SupplFile, FlagMap )
when is_map( DefaultMap ),
     is_list( GlobalFile ),
     is_list( UserFile ),
     is_map( FlagMap ) ->

  ConfMap1 =
    case file:read_file( GlobalFile ) of

      % if global file does not exist use the unchanged DefaultMap
      {error, enoent} ->
        DefaultMap;

      % report any error that is not enoent
      {error, Reason1} ->
        error( {Reason1, GlobalFile} );

      % global file was successfully read
      {ok, B1} ->

        % parse the content of ConfFile to get ConfMap
        GlobalMap = jsone:decode( B1, [{keys, atom}] ),

        % merge default and global map giving global map precedence
        merge( DefaultMap, GlobalMap )

    end,

  ConfMap2 =
    case os:getenv( "HOME" ) of

      false ->
        error( {env_unset, "HOME"} );

      UserDir ->
        File = string:join( [UserDir, UserFile], "/" ),
        case file:read_file( File ) of

          % if user file does not exist use the unchanged DefaultMap
          {error, enoent} ->
            ConfMap1;

          % report any error that is not enoent
          {error, Reason2} ->
            error( {Reason2, File} );

          % user file was successfully read
          {ok, B2} ->

            % parse the content of ConfFile to get ConfMap
            UserMap = jsone:decode( B2, [{keys, atom}] ),

            % merge old map and user map giving user map precedence
            merge( ConfMap1, UserMap )

        end

    end,

  ConfMap3 =
    case SupplFile of

      undefined ->
        ConfMap2;

      File ->
        case file:read_file( File ) of

          % report any error even if it is enoent
          {error, Reason3} ->
            error( {Reason3, File} );

          % supplement file was successfully read
          {ok, B3} ->

            % parse the content of supplement file to get the supplement map
            SupplMap = jsone:decode( B3, [{keys, atom}] ),

            % merge old map and supplement map giving supplement map precedence
            merge( ConfMap2, SupplMap )

        end

    end,


  % merge the old map and the flag map to obtain the final configuration
  merge( ConfMap3, FlagMap ).

  

%% @doc Merges two maps.
%%
%% The returned map has all the keys from `OldMap'. Values from `NewMap'
%% supersede values from `OldMap'. Keys appearing in `NewMap' but not in
%% `OldMap' are discarded.

-spec merge( OldMap :: #{ _ => _ }, NewMap :: #{ _ => _ } ) -> #{ _ => _ }.

merge( OldMap, NewMap ) ->

  F = fun( Key, OldValue ) ->
        maps:get( Key, NewMap, OldValue )
      end,

  maps:map( F, OldMap ).
