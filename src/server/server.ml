let calculate_new_rating player gameinfo = Int64.of_int 1500

let db_player_of_gameinfo_player: Gameinfo.tplayer -> Db.player = function
  {Gameinfo.name = nm; Gameinfo.clan = cn; Gameinfo.score = scr; Gameinfo.team = tm} ->
    {Db.name = nm; Db.clan = cn; Db.rating = Int64.of_int (-1)}

let process_player_info player gameinfo =
  match Db.select_player player.Gameinfo.name with
  | None -> Db.insert_player (db_player_of_gameinfo_player player)
  | Some existing_player ->
      let new_rating = calculate_new_rating existing_player gameinfo in
      Db.update_rating existing_player.Db.name new_rating

let process_message (msg: string): unit =
  let json = Json.json_of_string msg in
  let gameinfo = Json.gameinfo_of_json json in
  let players = gameinfo.Gameinfo.players in
  List.iter (fun player -> process_player_info player gameinfo) players

let handle_connection (input: in_channel) (output: out_channel): unit =
  let msg = Std.input_all input in
  let _ = process_message msg in
  Network.close_connection (input, output)
