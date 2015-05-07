class LogFormatter < ::Logger::Formatter
  def call(severity, time, progname, msg)
    format "%s, [%s#%d $%s] %5s -- %s: %s\n",
           severity[0..0], format_datetime(time), $PID,
           Thread.current.object_id.to_s(36),
           severity,
           progname,
           msg2str(msg)
  end

  private

  def format_datetime(time)
    super time.utc
  end
end
