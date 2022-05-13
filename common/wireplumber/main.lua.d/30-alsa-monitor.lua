alsa_monitor = {}
alsa_monitor.properties = {}
alsa_monitor.rules = {
{
    matches = {
      {
        -- Matches all sources.
        { "node.name", "matches", "alsa_input.*" },
      },
      {
        -- Matches all sinks.
        { "node.name", "matches", "alsa_output.*" },
      },
    },
    apply_properties = {
      --["node.nick"]              = "My Node",
      --["priority.driver"]        = 100,
      --["priority.session"]       = 100,
      ["node.pause-on-idle"]     = false,
      --["resample.quality"]       = 4,
      --["channelmix.normalize"]   = false,
      --["channelmix.mix-lfe"]     = false,
      --["audio.channels"]         = 2,
      --["audio.format"]           = "S16LE",
      --["audio.rate"]             = 44100,
      --["audio.position"]         = "FL,FR",
      --["api.alsa.period-size"]   = 1024,
      ["api.alsa.headroom"]      = 128,
      --["api.alsa.disable-mmap"]  = false,
      ["api.alsa.disable-batch"] = true,
      ["session.suspend-timeout-seconds"] = 0
    },
  },
}

function alsa_monitor.enable()
  if not alsa_monitor.enabled then
    return
  end

  -- The "reserve-device" module needs to be loaded for reservation to work
  if alsa_monitor.properties["alsa.reserve"] then
    load_module("reserve-device")
  end

  load_monitor("alsa", {
    properties = alsa_monitor.properties,
    rules = alsa_monitor.rules,
  })

  if alsa_monitor.properties["alsa.midi"] then
    load_monitor("alsa-midi", {
      properties = alsa_monitor.properties,
    })
    -- The "file-monitor-api" module needs to be loaded for MIDI device monitoring
    if alsa_monitor.properties["alsa.midi.monitoring"] then
      load_module("file-monitor-api")
    end
  end
end
