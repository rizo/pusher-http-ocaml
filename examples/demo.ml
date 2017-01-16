
module P = Pusher


let main cred_file_path =
  let cred_res = read_credentials cred_file_path in
  match cred_res with
  | Error msg -> print ~file:stderr msg
  | Ok cred   ->
    let pusher = P.init cred in
    pusher |> demo_trigger;
    pusher |> demo_channels;
    pusher |> demo_channel;
    pusher |> demo_users


let channel =
  P.(Channel Presence "messages")


let demo_trigger pusher =
  let res = P.trigger pusher [channel] "some_event" "data" None in
  match resh with
  | Error msg -> print ~file:stderr ("trigger failed: " ^ msg)
  | Ok () -> ()


let demo_channels pusher =
  let channelsInfoQuery = P.ChannelsInfoQuery $ HS.singleton P.ChannelsUserCount in
  let channels_info_query = P.Channels_info_query (Int.Set.singleton P.)

