%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is Erlando.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2011-2013 VMware, Inc.  All rights reserved.
%%

-module(monad_plus).

-export([guard/2, msum/2, mfilter/3]).

-type(monad(_A) :: any()). %% urm, don't know what to do here.
-spec(guard/2 :: (atom(), boolean()) -> monad(_A)).
-spec(msum/2 :: (atom(), [monad(A)]) -> monad(A)).
-spec(mfilter/3 :: (atom(), fun ((A) -> boolean()), monad(A)) -> monad(A)).

-compile({parse_transform, do}).
-compile({parse_transform, cut}).

-callback mzero() -> any().
-callback mplus(any(), any()) -> any().

guard(Monad, true)  -> Monad:return(ok);
guard(Monad, false) -> Monad:fail("").

msum(Monad, List) ->
    lists:foldr(Monad:mplus(_, _), Monad:mzero(), List).

mfilter(Monad, Pred, X) ->
    do([Monad || A <- X,
                 case Pred(A) of
                     true  -> return(A);
                     false -> Monad:mzero()
                 end]).
