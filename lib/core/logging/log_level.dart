enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warn(2, 'WARN'),
  error(3, 'ERROR'),
  fatal(4, 'FATAL');

  const LogLevel(this.level, this.displayName);

  final int level;

  final String displayName;

  bool isAtOrAbove(LogLevel target) => level >= target.level;

  bool isBelow(LogLevel target) => level < target.level;
}
