:- [configs].
:- [graphviz].
:- [output].
:- [analysis].
:- [vulnDatabase].

% Example: createRangeFromIGS(['server_access_root'], [], 'server_access_root')
% Finds all lattices, create directories, generate lattices in directory, create ansible playbooks
createRangeFromIGS(InitialState, Goal, Params) :-
    createAllLatticesFromIGS(InitialState, Goal, Lattices),
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
createAllLatticesFromIGS(InitialState, Goals, Lattices) :-
	setof([(Config, Vulns)], achieveGoal(Goals, InitialState, [], Config, Vulns), Paths),
    % repeatedly merge these configs until no more merging is possible
    groupPathsByConfigs(Paths, LatticePaths),
    % now keep just one config and all paths, per lattice
    maplist(appendPathsIntoLattice, LatticePaths, Lattices), print(Lattices)
    .

% keep single config (all paths will share this same config), append all paths into a set of vulns
appendPathsIntoLattice([], []).
appendPathsIntoLattice([(Config, Vulns)|Rest], (Config, AllVulns)) :-
    maplist(secondPair, Rest, RestVulns),
    append([Vulns|RestVulns], AllVulns).

secondPair((_, B), B).

% work backwards from goal to initial
achieveGoal([], _, [], [], []).
achieveGoal([Goal|Goals], InitialState, StartingConfigs, AcceptedConfigs, [(Input, Description, Output)|Vulns]) :-
    vuln(Description, Input, Output, Configs),
    member(Goal, Output),
    subtract(Input, InitialState, NewInput),
    union(NewInput, Goals, NewGoals),
    union(InitialState, Output, NewState),
    print("-----------"), nl ,
	format(atom(PrintGoal), "Goal: ~s", [Goal]),
    atomic_list_concat(Goals, ", ", GoalsAtom), atom_string(GoalsAtom, GoalsString),
    format(atom(PrintGoals), "Goals: ~s", [GoalsString]),
    atomic_list_concat(InitialState, ", ", InitialStateAtom), atom_string(InitialStateAtom, InitialStateString),
    format(atom(PrintInitialState), "InitialState: ~s", [InitialStateString]),
    atomic_list_concat(StartingConfigs, ", ", StartingConfigsAtom), atom_string(StartingConfigsAtom, StartingConfigsString),
    format(atom(PrintStartingConfigs), "StartingConfigs: ~s", [StartingConfigsString]),
    atomic_list_concat(Input, ", ", InputAtom), atom_string(InputAtom, InputString),
    format(atom(PrintInput), "Input: ~s", [InputString]),
    atomic_list_concat(Output, ", ", OutputAtom), atom_string(OutputAtom, OutputString),
    format(atom(PrintOutput), "Output: ~s", [OutputString]),
    format(atom(PrintDescription), "Description: ~s", [Description]),
    print(PrintGoal), nl, print(PrintGoals), nl, print(PrintInitialState), nl, print(PrintStartingConfigs), nl, print(PrintInput), nl, print(PrintDescription), nl, print(PrintOutput), nl, print(Vulns), nl,
    print("-----------"), nl,
    achieveGoal(NewGoals, NewState, StartingConfigs, NewConfigs, Vulns),
    checkConfigs(NewConfigs, Configs, AcceptedConfigs)
    .

