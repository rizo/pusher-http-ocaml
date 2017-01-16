
open Pure
open Base

module J = Yojson.Basic


type auth =
  { app_id     : int;
    app_key    : string;
    app_secret : string }
[@@deriving show, yojson]


module Private = struct
  module Auth = struct
    let cstruct_to_hex_string cstruct =
      let `Hex str = Hex.of_cstruct cstruct in
      str

    let hash str =
      str
      |> Cstruct.of_string
      |> Nocrypto.Hash.MD5.digest
      |> cstruct_to_hex_string

    let signature ~secret str =
      str
      |> Cstruct.of_string
      |> Nocrypto.Hash.SHA256.hmac ~key:(Cstruct.of_string secret)
      |> cstruct_to_hex_string

        let form_query_string x = fail ""

    let make_query_string auth timestamp params body =
      (* Update params with additional protocol parameters. *)
      let all_sorted_params = List.append params
          [("auth_key", auth.app_key);
           ("auth_timestamp", string_of_int timestamp);
           ("auth_version", "1.0");
           ("body_md5", hash body)] in
      let sig_parts = String.concat "\n"
          [http_method; request_path; form_query_string all_sorted_params] in
      let auth_sig = signature ~secret:auth.app_secret

  end
end


type t =
  { host : string;
    path : string;
    auth : auth }
[@@deriving show]


type event =
  { name : string;
    data : string }
[@@deriving show]


module Channel = struct
  type kind =
    | Public
    | Private
    | Presence
  [@@ deriving show, ord]

  type t =
    { kind : kind; name : string }
  [@@deriving show, ord]

  let prefix self =
    match self.kind with
    | Public -> ""
    | Private -> "private-"
    | Presence -> "presence-"

  let to_string self =
    prefix self ^ self.name

  let of_string s =
    match String.split_on_char '-' s with
    | [name]             -> Some { kind = Public;   name }
    | ["private";  name] -> Some { kind = Private;  name }
    | ["presence"; name] -> Some { kind = Presence; name }
    | _                  -> None

end


let make_post_request pusher sub_path params body time =
  fail "no"


let make_get_request pusher sub_path params time =
  failwith "todo"


let trigger pusher channels event exclude_socket time =
  if List.length channels > 10 then
    Error (Invalid_argument "Must be less than 10 channels")
  else
    let json = `Assoc
        [("name",     `String event.name);
         ("channels", `List (List.map (fun c -> `String (Channel.to_string c)) channels));
         ("data",     `String event.data)] in
    let body = J.to_string json in
    if String.length body > 10000 then
      Error (Invalid_argument "Body must be less than 10000KB")
    else
      Ok (make_post_request pusher "events" [] body time, body)


let channels pusher channel_kind_filter prefix_filter attributes time =
  let prefix = option "" Channel.prefix channel_kind_filter ^ prefix_filter in
  let params =
    [("info",             "TODO-attributes");
     ("filter_by_prefix", prefix)] in
  make_get_request pusher "channels" params time


