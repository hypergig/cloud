[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'bedrock-0',
      labels: {
        app: 'bedrock-0',
      },
    },
    spec: {
      strategy: {
        type: 'Recreate',
      },
      replicas: 1,
      selector: {
        matchLabels: {
          app: 'bedrock-0',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'bedrock-0',
          },
        },
        spec: {
          containers: [
            {
              name: 'main',
              image: 'itzg/minecraft-bedrock-server',
              imagePullPolicy: 'Always',
              env: [
                {
                  name: 'EULA',
                  value: 'TRUE',
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
                pdName: 'bedrock-0',
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
                        values: [
                          'us-central1-a',
                        ],
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
