part of irc_bot;

class FeedItem {
  String title;
  String url;

  FeedItem(this.title, this.url);
}

class Feed {
  DateTime lastBuildDate;
  List<FeedItem> items;

  static Future<Feed> fromUrl(String url) async {
    var feed = new Feed();

    var client = new http.Client();
    var response = await client.get(url);
    var bytes = response.bodyBytes;
    var string = UTF8.decode(bytes);

    var document = xml.parse(string);

    Iterable<xml.XmlElement> rootElements = null;

    rootElements = document.findAllElements("rdf:RDF");
    if (rootElements.isNotEmpty) return feed._parseRdf(rootElements.first);

    rootElements = document.findAllElements("rss");
    if (rootElements.isNotEmpty) return feed._parseRss(rootElements.first);

    return feed;
  }

  Feed _parseRss(xml.XmlElement rss) {
    var channel = rss.findElements("channel").first;

    items = new List<FeedItem>();
    var feedItems = channel.findElements("item");
    feedItems.forEach((i) {
      var title = i.findElements("title").first.text;
      var url = i.findElements("link").first.text;

      items.add(new FeedItem(title, url));
    });

    return this;
  }

  Feed _parseRdf(xml.XmlElement rdf) {
    items = new List<FeedItem>();
    var feedItems = rdf.findElements("item");
    feedItems.forEach((i) {
      var title = i.findElements("title").first.text;
      var url = i.findElements("link").first.text;

      items.add(new FeedItem(title, url));
    });

    return this;
  }
}
