class ListeningHistoryService
  def self.for(csv_file)
    new(csv_file)
  end

  def initialize(csv_file)
    @scrobbles = csv_file.map(&method(:parse_row)).compact
  end

  def parse_row(row_data)
    artist, album, track_name, timestamp = row_data
    return nil unless timestamp

    dt_timestamp = DateTime.parse(timestamp)
    Scrobble.new(artist, album, track_name, dt_timestamp)
  end

  def get_scrobbles_within(range)
    @scrobbles.select do |scrobble|
      range.cover? scrobble.timestamp
    end
  end
end


class Scrobble
  attr_accessor :artist, :album, :track_name, :timestamp

  def initialize(artist, album, track_name, timestamp)
    @artist     = artist
    @album      = album
    @track_name = track_name
    @timestamp  = timestamp
  end

  def to_s
    "#{track_name} - #{artist} at #{timestamp.iso8601}"
  end

  def uid
    "track:#{track_name} artist:#{artist}"
  end
end