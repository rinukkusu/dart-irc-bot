library irc_bot;

import 'dart:io';
import 'dart:async';
import 'dart:mirrors';

part 'irc/enums/message_type.dart';
part 'irc/entities/irc_command.dart';
part 'irc/entities/irc_message.dart';
part 'irc/connection.dart';
part 'irc/plugin_base.dart';
part 'irc/command_dispatcher.dart';

part 'plugins/echo.dart';
part 'plugins/ping.dart';
