{
  normalizeName(str):: std.strReplace(std.asciiLower(str), ' ', '-'),
  minecraftDisk(str):: 'minecraft-' + self.normalizeName(str),
  minResources:: {
    // set everything so low autopilot is forced to use the bare minimum
    resources: {
      // autopilot pods are always guaranteed QoS
      // ie - limits == requests
      requests: {
        cpu: '500m',
        'ephemeral-storage': '1Gi',
        memory: '2Gi',
      },
    },
  },
  autoDelete:: {
    autoDelete: 'true',
  },
}
