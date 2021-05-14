class Series {
  int id;
  String name;
  int season;
  int episode;
  String link;
  String comment;
  bool paused;
  bool tor;
  DateTime changed;
  DateTime time;

  Series(
      {this.id,
      this.name,
      this.season,
      this.episode,
      this.link,
      this.comment,
      this.paused,
      this.tor,
      this.changed,
      this.time});

  factory Series.fromJSON(Map item) {
    return Series(
      id: item['ID'],
      name: item['Name'],
      season: item['Season'],
      episode: item['Episode'],
      link: item['Link'],
      comment: item['Comment'],
      paused: item['Paused'],
      tor: item['Tor'],
      changed: DateTime.parse(item['Changed']),
      time: DateTime.parse(item['Time']),
    );
  }
}
