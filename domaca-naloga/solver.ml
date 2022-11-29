type available = { loc : int * int; possible : int list }

(* TODO: tip stanja ustrezno popravite, saj boste med reševanjem zaradi učinkovitosti
   želeli imeti še kakšno dodatno informacijo *)
type state = { problem : Model.problem; 
               current_grid : int option Model.grid;
               available_list : available list }

let print_state (state : state) : unit =
  Model.print_grid
    (function None -> "?" | Some digit -> string_of_int digit)
    state.current_grid

type response = Solved of Model.solution | Unsolved of state | Fail of state

let find_available (grid : int option array array) r c = match grid.(r).(c) with
  | Some int -> None
  | None ->
  let row = Model.get_row grid r in
  let column = Model.get_column grid c in
  let b = (r / 3) * 3 + (c / 3) in
  let box = Model.get_box grid b in
  let together = Array.fold_left Array.append row [|column; box|] in
  let f i = if (Array.exists ((=) (Some i)) together) then None else Some i in
  let lst = List.filter_map f (List.init 9 (fun x -> x)) in
  Some { loc = (r, c); possible = lst}

let create_available_list grid = 
  let f a b = a @ (List.init 9 b) in
  List.filter_map (fun x -> x) (List.fold_left f [] (List.init 9 (find_available grid)))

let initialize_state (problem : Model.problem) : state =
  { current_grid = Model.copy_grid problem.initial_grid; 
    problem; 
    available_list = create_available_list problem.initial_grid }

let validate_state (state : state) : response =
  let unsolved =
    Array.exists (Array.exists Option.is_none) state.current_grid
  in
  if unsolved then Unsolved state
  else
    (* Option.get ne bo sprožil izjeme, ker so vse vrednosti v mreži oblike Some x *)
    let solution = Model.map_grid Option.get state.current_grid in
    if Model.is_valid_solution state.problem solution then Solved solution
    else Fail state

let branch_state (state : state) : (state * state) option =
  (* TODO: Pripravite funkcijo, ki v trenutnem stanju poišče hipotezo, glede katere
     se je treba odločiti. Če ta obstaja, stanje razveji na dve stanji:
     v prvem predpostavi, da hipoteza velja, v drugem pa ravno obratno.
     Če bo vaš algoritem najprej poizkusil prvo možnost, vam morda pri drugi
     za začetek ni treba zapravljati preveč časa, saj ne bo nujno prišla v poštev. *)
  if List.length state.available_list = 0 then None else
  let f len avail = List.length avail.possible = len in
  let av = List.find_opt (f 1) (state.available_list) in
  match av with
  | Some el -> 
      let new_available = List.filter (fun x -> (x <> el)) state.available_list in
      let cell_element = List.hd el.possible in
      let (r, c) = el.loc in
      state.current_grid.(r).(c) <- Some cell_element;
      Some ({state with available_list = new_available}, {state with available_list = new_available})
      (*       let new_available = List.filter (fun x -> (x <> el)) state.available_list in
      let cell_element = List.hd el.possible in
      let (r, c) = el.loc in
      let grid = Array.map Array.copy state.current_grid in
      grid.(r).(c) <- Some cell_element;
      Some ({state with current_grid = grid; available_list = new_available}, {state with available_list = new_available})
  *)
  | None -> 
      let avail :: xs = state.available_list in
      let (r, c) = avail.loc in
      let cell_element :: other = avail.possible in
      let new_available = { avail with possible = other} :: xs in
      let grid = Array.map Array.copy state.current_grid in
      grid.(r).(c) <- Some cell_element;
      Some ({ state with current_grid = grid; available_list = new_available }, { state with available_list = new_available })


(* pogledamo, če trenutno stanje vodi do rešitve *)
let rec solve_state (state : state) =
  (* uveljavimo trenutne omejitve in pogledamo, kam smo prišli *)
  (* TODO: na tej točki je stanje smiselno počistiti in zožiti možne rešitve *)
  (* najprej insertas kar je todo, potem popucas available za to mesto *)
  match validate_state state with
  | Solved solution ->
      (* če smo našli rešitev, končamo *)
      Some solution
  | Fail fail ->
      (* prav tako končamo, če smo odkrili, da rešitev ni *)
      None
  | Unsolved state' ->
      (* če še nismo končali, raziščemo stanje, v katerem smo končali *)
      explore_state state'

and explore_state (state : state) =
  (* pri raziskovanju najprej pogledamo, ali lahko trenutno stanje razvejimo *)
  match branch_state state with
  | None ->
      (* če stanja ne moremo razvejiti, ga ne moremo raziskati *)
      None
  | Some (st1, st2) -> (
      (* če stanje lahko razvejimo na dve možnosti, poizkusimo prvo *)
      match solve_state st1 with
      | Some solution ->
          (* če prva možnost vodi do rešitve, do nje vodi tudi prvotno stanje *)
          Some solution
      | None ->
          (* če prva možnost ne vodi do rešitve, raziščemo še drugo možnost *)
          solve_state st2 )

let solve_problem (problem : Model.problem) =
  problem |> initialize_state |> solve_state
