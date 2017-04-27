library irc_bot;

import 'dart:io';
import 'dart:async';
import 'dart:mirrors';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:cleverbot/cleverbot.dart';
import 'package:xml/xml.dart' as xml;
import 'package:markov_dart/markov_dart.dart';

part 'irc/enums/message_type.dart';
part 'irc/enums/user_level.dart';
part 'irc/enums/messages.dart';

part 'irc/entities/irc_command.dart';
part 'irc/entities/irc_message.dart';
part 'irc/entities/sender.dart';
part 'irc/entities/connection_settings.dart';

part 'irc/annotations/command_annotation.dart';

part 'irc/connection.dart';
part 'irc/plugin_base.dart';
part 'irc/user_container.dart';

part 'misc/json_config.dart';
part 'misc/duration_parser.dart';

part 'plugins/core.dart';
part 'plugins/echo.dart';
part 'plugins/ping.dart';
part 'plugins/invite.dart';
part 'plugins/weather.dart';
part 'plugins/random_reply.dart';
part 'plugins/cleverbot.dart';
part 'plugins/google_search.dart';
part 'plugins/google_url_shortener.dart';
part 'plugins/google_maps.dart';
part 'plugins/rss_reader.dart';
part 'plugins/markov.dart';
part 'plugins/timer.dart';
part 'plugins/realtalk.dart';

part 'plugins/models/rss_reader/feed_info.dart';
part 'plugins/models/rss_reader/parser.dart';
