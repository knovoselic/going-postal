class ColoredLogFormatter < LogFormatter
  COLOR_MAP = {
    DEBUG: ->(msg) { "\033[38;5;66m#{msg}\033[0m" },
    INFO: ->(msg) { "\033[38;5;24m#{msg}\033[0m" },
    WARN: ->(msg) { "\033[38;5;143m#{msg}\033[0m" },
    ERROR: ->(msg) { "\033[38;5;202m#{msg}\033[0m" },
    FATAL: ->(msg) { "\033[38;5;160m#{msg}\033[0m" },
    ANY: ->(msg) { "\033[38;5;92m#{msg}\033[0m" }
  }

  def call(severity, time, progname, msg)
    msg = super severity, time, progname, msg
    color_message msg, severity
  end

  private

  def color_message(msg, severity)
    COLOR_MAP[severity.to_sym].call msg
  end
end
