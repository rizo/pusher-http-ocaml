
module YS = Yojson.Safe

open Pure


(** Application information for the Pusher app. *)
type auth =
  { app_id     : int;
    app_key    : string;
    app_secret : string }

(** [auth_to_yojson auth] is a [string] value representation of [auth]. *)
val show_auth : auth -> string

(** [auth_to_yojson auth] is a [Yojson.json] value representation of [auth]. *)
val auth_to_yojson : auth -> YS.json

(** [auth_of_yojson json] is a [auth] value representation of [json]. *)
val auth_of_yojson : YS.json -> auth

(** Pusher instance type for a host, path with a given [auth]. *)
type t =
  { host : string;
    path : string;
    auth : auth }

(** [show pusher] is a [string] value representation of [t]. *)
val show : t -> string

type event =
  { name : string;
    data : string }

(** [show_event event] is a [string] value representation of [event]. *)
val show_event : event -> string

(** The type for unique socket identifiers. *)
type socket_id = int

(** Channel type module. Manages the creation, queryng and rendering of
    channels. *)
module Channel : sig

  (** The type for channel kinds. A channel can be one of: public, private or
      presence channels. *)
  type kind =
    | Public
    | Private
    | Presence

  (**  *)
  type t =
    { kind : kind;
      name : string }

  val show : t -> string

  val compare : t -> t -> Comparable.order

  type info_query

  type info

  (** [prefix channel] renders the prefix string of the channel. *)
  val prefix : t -> string

  (** [to_string channel] converts a channel to string identifier. *)
  val to_string : t -> string

  (** [of_string string] converts a string identifier to channel. *)
  val of_string : string -> t

  module Map : Map.S
end


type user =
  { id : string }

val show_user : user -> string

val compare_user : user -> user -> int


type error = exn


(** Trigger an event to one or more channels. *)
val trigger
   : t
  -> Channel.t list
  -> event
  -> socket_id option
  -> (unit, error) result

(** Query for information on a single channel.
    Can query user count and subscription count (if enabled). *)
val channel
   : t
  -> Channel.t
  -> Channel.info_query
  -> (Channel.info, error) result

(** Query a list of channels for information. *)
val channels
   : t
  -> Channel.kind option
  -> string
  -> Channel.info_query
  -> (Channel.info Channel.Map.t, error) result

(** Get a list of users in a presence channel. *)
val users
   : t
  -> Channel.t
  -> (user list, error) result


