%% -*- erlang -*-
%%
%% Cuneiform: A Functional Language for Large Scale Scientific Data Analysis
%%
%% Copyright 2016 Jörgen Brandt, Marc Bux, and Ulf Leser
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

%% @author Jörgen Brandt <brandjoe@hu-berlin.de>

-module( lib_conf ).
-author( "Jorgen Brandt <brandjoe@hu-berlin.de>" ).

-export( [create_conf/3] ).


%% @doc Creates a map by combining a DefaultMap, a map extracted from a
%%      ConfigFile, and a ManualMap.
%%
%%      The resulting map contains only keys that were also in DefaultMap. The
%%      values for any of these keys are overwritten first with the according
%%      values from the ConfFile and then with the according values from the
%%      ManualMap.

-spec create_conf( DefaultMap, ConfFile, ManualMap ) -> #{ _ => _ }
when DefaultMap :: #{ _ => _},
     ConfFile   :: string(),
     ManualMap  :: #{ _ => _ }.

create_conf( DefaultMap, ConfFile, ManualMap )
when is_map( DefaultMap ),
     is_list( ConfFile ),
     is_map( ManualMap ) ->

  MergeMap = case file:read_file( ConfFile ) of

    % if ConfFile does not exist use the unchanged DefaultMap
    {error, enoent}  -> DefaultMap;

    % report any error that is not enoent
    {error, Reason1} -> error( Reason1 );

    % ConfFile was successfully read
    {ok, B}          ->

      % parse the content of ConfFile to get ConfMap
      {ok, Tokens, _} = erl_scan:string( binary_to_list( B ) ),
      ConfMap = case erl_parse:parse_term( Tokens ) of
        {error, Reason2} -> error( Reason2 );
        {ok, Y}         -> Y
      end,

      % create MergeMap by traversing all keys in DefaultMap
      % for each key in DefaultMap if the key exists in ConfMap, use its value
      % if it does not exist in ConfMap, use the DefaultMap value instead
      maps:map( fun( K, V ) -> maps:get( K, ConfMap, V ) end, DefaultMap )
  end,

  
  % traverse all keys in MergeMap
  % for each key in MergeMap if the key exists in ManualMap, use its value
  % if it does not exist in ManualMap, use the MergeMap value instead
  maps:map( fun( K, V ) -> maps:get( K, ManualMap, V ) end, MergeMap ).

