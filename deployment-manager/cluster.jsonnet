local vars = import '../vars.jsonnet';
{
  resources: [
    {
      name: vars.cluster.name,
      type: 'gcp-types/container-v1:projects.locations.clusters',
      properties: {
        parent: 'projects/%s/locations/%s' % [vars.project, vars.location],
        cluster: {
          network: 'projects/%s/global/networks/default' % vars.project,
          subnetwork: 'projects/%s/regions/%s/subnetworks/default' % [vars.project, vars.location],
          networkPolicy: {},
          ipAllocationPolicy: {
            useIpAliases: true,
            clusterIpv4CidrBlock: '/17',
            servicesIpv4CidrBlock: '/22',
          },
          masterAuthorizedNetworksConfig: {},
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
          location: '%s' % vars.location,
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
  ],
}
