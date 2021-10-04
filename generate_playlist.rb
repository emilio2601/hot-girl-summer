require "csv"
require "date"
require "rspotify"
require "dotenv/load"
require "./listening_history_service.rb"

SUMMER_START = DateTime.iso8601("2021-06-01")
SUMMER_END = DateTime.iso8601("2021-09-01")
SUMMER = SUMMER_START..SUMMER_END

INCLUSION_THRESHOLD = 25
PLAYLIST_ID = "04rbVkoutryqe1riHtYWTX"

SONG_BLACKLIST = %w[4WeFxTWbIphMs0j96hH3Lx 30fGAryPIZTx0RHNtQ2QQR 5cFSGxC26QRmbWx5Zup49L 4uNxEmMsMfO7DtaLHqPXWz 4m7WHxxBQkHvhcqJw3LdSt 10bGyWxBsksEb5QN4c2Jt1 2s5Bm2Miv88YIcpDE5dqKq 63y4ZibWpnXxv7im3e5HEt 6UDwJbSKySZ4RqBl9cz2c8 7EBpervzdzoOgA1bgk1sSm 7bra7QzKZP9wmyhIZTjKT0 7nlz9iIydZFHOzOBBm6X8B 2898wbxGjsuzB16jb18cbE 4W5ujj9ZiCesGUxpHVgUyZ]

RSpotify.authenticate(ENV["SPOTIFY_CLIENT_ID"], ENV["SPOTIFY_CLIENT_SECRET"])
creds = { "token" => ENV["SPOTIFY_ACCESS_TOKEN"], "refresh_token" => ENV["SPOTIFY_REFRESH_TOKEN"] }
user = RSpotify::User.new({ "credentials" => creds, "id" => "1276652802" })

lh_data = CSV.read("data/lastfm_2021_10_3.csv")
lh_svc = ListeningHistoryService.for(lh_data)

listen_count = d = Hash.new { |h, k| h[k] = 0 }

tracks = lh_svc.get_scrobbles_within(SUMMER)
tracks.each do |t|
  listen_count[t.uid] += 1
end

sp_playlist = user.playlists.select { |p| p.id == PLAYLIST_ID }.first

tracks = listen_count.sort_by { |t, c| c }.reverse.select { |t, c| c >= INCLUSION_THRESHOLD }.map do |track, count|
  sp_track = RSpotify::Track.search(track).reject { |t| SONG_BLACKLIST.include? t.id }.first
  puts "Adding #{sp_track.name} - #{sp_track.id}"
  sp_track
end

sp_playlist.replace_tracks!(tracks)
