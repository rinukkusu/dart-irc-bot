part of irc_bot;

enum ColorEnum {
  White,
  Black,
  Blue,
  Green,
  Red,
  Brown,
  Purple,
  Orange,
  Yellow,
  LightGreen,
  Teal,
  LightCyan,
  LightBlue,
  Pink,
  Grey,
  LightGrey
}

class IrcColors {
  static String _decode(String b) => UTF8.decode([int.parse(b)]);
  static String _cc(ColorEnum val) => "${COLOR}${_c(val)}";
  static String _c(ColorEnum val) => val.index.toString().padLeft(2, "0");

  static String BOLD = _decode("0x02");
  static String COLOR = _decode("0x03");
  static String ITALIC = _decode("0x1D");
  static String UNDERLINE = _decode("0x1F");
  static String INVERT = _decode("0x16");
  static String RESET = _decode("0x0F");

  static String White = _cc(ColorEnum.White);
  static String Black = _cc(ColorEnum.Black);
  static String Blue = _cc(ColorEnum.Blue);
  static String Green = _cc(ColorEnum.Green);
  static String Red = _cc(ColorEnum.Red);
  static String Brown = _cc(ColorEnum.Brown);
  static String Purple = _cc(ColorEnum.Purple);
  static String Orange = _cc(ColorEnum.Orange);
  static String Yellow = _cc(ColorEnum.Yellow);
  static String LightGreen = _cc(ColorEnum.LightGreen);
  static String Teal = _cc(ColorEnum.Teal);
  static String LightCyan = _cc(ColorEnum.LightCyan);
  static String LightBlue = _cc(ColorEnum.LightBlue);
  static String Pink = _cc(ColorEnum.Pink);
  static String Grey = _cc(ColorEnum.Grey);
  static String LightGrey = _cc(ColorEnum.LightGrey);

  static String format(String message, String code, [String argument = ""]) {
    return "$code$argument$message$code";
  }

  static String color(String message, ColorEnum color) =>
      format(COLOR, message, _c(color));
  static String bold(String message) => format(BOLD, message);
  static String italic(String message) => format(ITALIC, message);
  static String underline(String message) => format(UNDERLINE, message);
  static String invert(String message) => format(INVERT, message);
}
