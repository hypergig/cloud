{
  normalizeName(str):: std.strReplace(std.asciiLower(str), ' ', '-'),
  minecraftDisk(str):: 'minecraft-' + self.normalizeName(str),
  minResources:: {
    // set everything so low autopilot is forced to use the bare minimum
    resources: {
      // autopilot pods are always guaranteed QoS
      // ie - limits == requests
      requests: {
        cpu: '1m',
        'ephemeral-storage': '1Mi',
        memory: '1Mi',
      },
    },
  },
  autoDelete:: {
    autoDelete: 'true',
  },
}
