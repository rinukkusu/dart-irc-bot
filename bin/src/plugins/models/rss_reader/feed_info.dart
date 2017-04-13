part of irc_bot;

class FeedInfo {
  String channel;
  String title;
  String url;

  List<FeedItem> items = new List();

  FeedInfo(this.channel, this.title, this.url);

  FeedInfo.fromMap(Map<String, String> map) {
    channel = map["channel"];
    title = map["title"];
    url = map["url"];
  }

  Map<String, String> toMap() {
    return {"channel": channel, "title": title, "url": url};
  }

  void initializeWithItems(List<FeedItem> items) {
    this.items = items;
  }

  List<FeedItem> getNewItems(List<FeedItem> items) {
    var returnItems = new List<FeedItem>();

    items.forEach((item) {
      var found =
          this.items.firstWhere((x) => x.url == item.url, orElse: () => null);
      if (found == null) {
        returnItems.insert(0, item);
      }
    });

    this.items = items;

    return returnItems;
  }
}
