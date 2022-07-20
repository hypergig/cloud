local vars = import '../vars.jsonnet';

local name = {
  name: vars.minecraftServer.name,
};

local selector = {
  app: name.name,
};

local metadata = {
  metadata: name {
    labels+: selector,
  },
};

[
  metadata {
    apiVersion: 'v1',
    kind: 'Service',
    spec: {
      selector: selector,
      ports: [
        {
          port: 19132,
          protocol: 'UDP',
        },
      ],
      type: 'LoadBalancer',
    },
  },
  metadata {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    spec: {
      strategy: {
        type: 'Recreate',
      },
      replicas: 1,
      selector: {
        matchLabels: selector,
      },
      template: metadata {
        spec: {
          containers: [
            name {
              image: 'itzg/minecraft-bedrock-server',
              imagePullPolicy: 'Always',
              tty: true,
              stdin: true,
              env: [
                { name: 'ALLOW_CHEATS', value: 'false' },
                { name: 'DEFAULT_PLAYER_PERMISSION_LEVEL', value: 'member' },
                { name: 'DIFFICULTY', value: 'normal' },
                { name: 'EMIT_SERVER_TELEMETRY', value: 'true' },
                { name: 'EULA', value: 'TRUE' },
                { name: 'GAMEMODE', value: 'survival' },
                { name: 'LEVEL_NAME', value: vars.minecraftServer.friendlyName },
                { name: 'LEVEL_TYPE', value: 'DEFAULT' },
                { name: 'MAX_THREADS', value: '0' },
                { name: 'ONLINE_MODE', value: 'true' },
                { name: 'OPS', value: std.join(',', vars.minecraftServer.ops) },
                { name: 'SERVER_NAME', value: vars.minecraftServer.friendlyName },
                { name: 'TICK_DISTANCE', value: '12' },
                { name: 'WHITE_LIST_USERS', value: std.join(',', vars.minecraftServer.players) },
              ],
              volumeMounts: [{ name: 'data', mountPath: '/data' }],
              ports: [{ containerPort: 19132, protocol: 'UDP' }],
              resources: {
                // autopilot pods are always guaranteed QoS
                // ie - limits == requests
                requests: {
                  cpu: '2',
                  'ephemeral-storage': '10Gi',
                  memory: '2Gi',
                },
              },
            },
          ],
          volumes: [
            {
              name: 'data',
              gcePersistentDisk: {
                pdName: vars.minecraftServer.disk,
              },
            },
          ],
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: 'topology.kubernetes.io/zone',
                        operator: 'In',
                        values: [vars.diskZone],
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      },
    },
  },
]
