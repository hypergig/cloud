local helpers = import '../lib/helpers.jsonnet';
local vars = import '../vars.jsonnet';

local selector = {
  app: vars.minecraftServer.name,
};

local name = {
  name: vars.minecraftServer.name,
};

local metadata = {
  metadata: name {
    labels: selector,
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
            {
              name: 'main',
              image: 'itzg/minecraft-bedrock-server',
              imagePullPolicy: 'Always',
              tty: true,
              stdin: true,
              env: [
                {
                  name: 'OPS',
                  value: std.join(',', vars.minecraftServer.ops),
                },
                {
                  name: 'WHITE_LIST_USERS',
                  value: std.join(',', vars.minecraftServer.players),
                },
                {
                  name: 'EULA',
                  value: 'TRUE',
                },
                {
                  name: 'MAX_THREADS',
                  value: '0',
                },
                {
                  name: 'EMIT_SERVER_TELEMETRY',
                  value: 'true',
                },
                {
                  name: 'DIFFICULTY',
                  value: 'normal',
                },
                {
                  name: 'GAMEMODE',
                  value: 'survival',
                },
                {
                  name: 'SERVER_NAME',
                  value: vars.minecraftServer.friendlyName,
                },
                {
                  name: 'LEVEL_NAME',
                  value: vars.minecraftServer.friendlyName,
                },
                {
                  name: 'LEVEL_TYPE',
                  value: 'DEFAULT',
                },
                {
                  name: 'ALLOW_CHEATS',
                  value: 'false',
                },
                {
                  name: 'ONLINE_MODE',
                  value: 'true',
                },
                {
                  name: 'DEFAULT_PLAYER_PERMISSION_LEVEL',
                  value: 'member',
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/data',
                  name: 'data',
                },
              ],
              ports: [
                {
                  containerPort: 19132,
                  protocol: 'UDP',
                },
              ],
              // TODO - resources
              // TODO - probes
              // readinessProbe: {
              //   exec: {
              //     command: [
              //       'mc-monitor',
              //       'status-bedrock',
              //       '--host',
              //       '127.0.0.1',
              //     ],
              //   },
              //   initialDelaySeconds: 30,
              // },
              // livenessProbe: {
              //   exec: {
              //     command: [
              //       'mc-monitor',
              //       'status-bedrock',
              //       '--host',
              //       '127.0.0.1',
              //     ],
              //   },
              //   initialDelaySeconds: 30,
              // },
              // tty: true,
              // stdin: true,
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
