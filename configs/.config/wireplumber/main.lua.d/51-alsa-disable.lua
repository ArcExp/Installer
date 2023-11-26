rule = {
  matches = {
    {
      { "device.name", "equals", "alsa_card.pci-0000_00_03.0" }, --replace the alsa card value here with your own device name
    },
  },
  apply_properties = {
    ["device.disabled"] = true,
  },
}

table.insert(alsa_monitor.rules,rule)
