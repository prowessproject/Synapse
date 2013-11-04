-module(synapse_eunit).

-include("synapse.hrl").
-include_lib("eunit/include/eunit.hrl").

-compile([export_all]).

learn_test_() ->
    {"Test learning of a simple example",
     {inorder,
      [{test, ?MODULE, learn1}]}
    }.

learn1() ->
    Traces = synapse_stamina:read_trace_file("../test/test2.traces"),
    SM = synapse:learn(Traces,#learner_metainfo{module=locker}),
    ?assert(synapse_sm:sanity_check(SM)),
    %% State names are not fixed, but they can be defined based on
    %% walks.
    ?assertEqual(
       synapse_sm:walk(SM,[init])
       ,synapse_sm:walk(SM,[init,lock,unlock])
      ),
    ?assertEqual(
       synapse_sm:walk(SM,[init,lock])
       ,synapse_sm:walk(SM,[init,lock,unlock,lock])
      ),
    ?assertEqual(
       synapse_sm:walk(SM,[init])
       ,synapse_sm:walk(SM,[init,'read/0'])
      ),
    ?assertEqual(
       synapse_sm:walk(SM,[init,lock,'write(wibble)'])
       ,synapse_sm:walk(SM,[init,lock,'write(wibble)',unlock,lock])
      ),
    ?assertEqual(
       synapse_sm:walk(SM,[init])
       ,synapse_sm:walk(SM,[init,lock,'write(wibble)','write(0)',unlock])
      ).
