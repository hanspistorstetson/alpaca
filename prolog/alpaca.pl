:- [configs].
:- [graphviz].
:- [output].
:- [analysis].
:- [vulnDatabase].

% Example: createRangeFromIGS(['server_access_root'], [], 'server_access_root')
% Finds all lattices, create directories, generate lattices in directory, create ansible playbooks

createLatticeFromIGS(InitialState, Goal, Params) :-
    createAllLatticesFromIGS(InitialState, [], Goal, Lattices),
    realizeLatticeConfigsFromParams(Lattices, Params, RealizedLattices),
    print(RealizedLattices), nl, 
    select(Lattice, RealizedLattices, _),
    print(Lattice), nl.

createRangeFromIGS(InitialState, Goal, Params) :-
    createAllLatticesFromIGS(InitialState, [], Goal, Lattices),
    % realize lattice config if there are predicates involved
    realizeLatticeConfigsFromParams(Lattices, Params, RealizedLattices),
    outputRange(InitialState, Goal, Params, RealizedLattices).

realizeLatticeConfigsFromParams([], _, []).
realizeLatticeConfigsFromParams([(Config, Vulns)|Rest], Params, [(RealizedConfig, Vulns)|RealizedRest]) :-
    realizeConfigFromParams(Config, Params, RealizedConfig),
    realizeLatticeConfigsFromParams(Rest, Params, RealizedRest).

% e.g., createAllLatticesFromIGS([server_access_root], [], Lattices)
% paths will be in reverse usually, but that doesnt matter for generating a lattice
% result (Lattices) will have structure: [Lattice|...],
% where each Lattice has the structure: (Config, Vulns),
% where Config is a maximally merged config for the lattice (all paths in the
% lattice are compatible with this same maximal config)
createAllLatticesFromIGS(InitialState, Interim, Goals, Lattices) :-
    setof([(Config, Vulns)],
          achieveGoal(Goals, InitialState, [], Config, Vulns, 0, 1),
          Paths),
    % repeatedly merge these configs until no more merging is possible
    groupPathsByConfigs(Paths, LatticePaths),
    % now keep just one config and all paths, per lattice
    maplist(appendPathsIntoLattice, LatticePaths, Lattices).
    % print(Lattices).
% keep single config (all paths will share this same config), append all paths into a set of vulns
appendPathsIntoLattice([], []).
appendPathsIntoLattice([(Config, Vulns)|Rest],  (Config, AllVulns)) :-
    maplist(secondPair, Rest, RestVulns),
    append([Vulns|RestVulns], AllVulns).

secondPair((_, B), B).


test(Goal, Output, SrcMachine, SrcMachine, Input, InitialState, Goals, NewGoals, NewState, SrcMachine) :-
    member(Goal, Output),
    subtract(Input, InitialState, NewInput),
    union(NewInput, Goals, NewGoals),
    union(InitialState, Output, NewState).

test(_, _, SrcMachine, DestMachine, _, InitialState, Goals, NewGoals, NewState, DestMachine) :-
    SrcMachine \= DestMachine, 
    NewGoals = Goals,
    union(InitialState, Output, NewState).

% work backwards from goal to initial
achieveGoal([], _, [], [], [], Machine, Machine).
achieveGoal([Goal|Goals], InitialState, StartingConfigs, _, [(Input, Description, Output)|Vulns], CurMachine, DestMachine) :-
    vuln(Description, Input, Output, CurMachine, VulnDestMachine, _),
    test(Goal, Output, CurMachine, VulnDestMachine, Input, InitialState, Goals, NewGoals, NewState, NewMachine),
    achieveGoal(NewGoals, NewState, StartingConfigs, _, Vulns, NewMachine, DestMachine).
    % checkConfigs(NewConfigs, Configs, AcceptedConfigs).
