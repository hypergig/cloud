local vars = import '../vars.jsonnet';
{
  resources: [
    {
      name: vars.cluster.name,
      type: 'gcp-types/container-v1:projects.locations.clusters',
      properties: {
        parent: 'projects/%s/locations/%s' % [vars.project, vars.location],
        cluster: {

          // actual vars
          network: 'projects/%s/global/networks/default' % vars.project,
          subnetwork: 'projects/%s/regions/%s/subnetworks/default' % [vars.project, vars.location],

          // the rest
          networkPolicy: {},
          ipAllocationPolicy: {
            useIpAliases: true,
            clusterIpv4CidrBlock: '/17',
            servicesIpv4CidrBlock: '/22',
          },
          masterAuthorizedNetworksConfig: {},
          maintenancePolicy: {
            window: {
              recurringWindow: {
                window: {
                  startTime: '2022-07-12T04:00:00Z',
                  endTime: '2022-07-12T09:00:00Z',
                },
                recurrence: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU',
              },
            },
          },
          binaryAuthorization: {},
          autoscaling: {
            enableNodeAutoprovisioning: true,
            autoprovisioningNodePoolDefaults: {},
          },
          networkConfig: {
            enableIntraNodeVisibility: true,
          },
          authenticatorGroupsConfig: {},
          databaseEncryption: {
            state: 'DECRYPTED',
          },
          verticalPodAutoscaling: {
            enabled: true,
          },
          releaseChannel: {
            channel: 'REGULAR',
          },
          notificationConfig: {
            pubsub: {},
          },
          initialClusterVersion: '1.22.8-gke.202',
          autopilot: {
            enabled: true,
          },
          loggingConfig: {
            componentConfig: {
              enableComponents: [
                'SYSTEM_COMPONENTS',
                'WORKLOADS',
              ],
            },
          },
          monitoringConfig: {
            componentConfig: {
              enableComponents: [
                'SYSTEM_COMPONENTS',
              ],
            },
          },
        },
      },
    },
  ] + std.map(
    function(op) {
      name: self.properties.name,
      type: 'gcp-types/cloudbuild-v1:projects.triggers',
      properties: {
        name: op + '-minecraft',
        gitFileSource: {
          path: 'cloudbuild.yaml',
          repoType: 'GITHUB',
          revision: 'refs/heads/main',
          uri: 'https://github.com/hypergig/cloud',
        },
        sourceToBuild: {
          ref: 'refs/heads/main',
          repoType: 'GITHUB',
          uri: 'https://github.com/hypergig/cloud',
        },
      },
    },
    ['start', 'stop']
  ),
}
