function(project, location) {
  resources: [
    {
      name: 'fun-cluster',
      type: 'gcp-types/container-v1beta1:projects.locations.clusters',
      properties: {
        parent: 'projects/%s/locations/%s' % [project, location],
        cluster: {
          network: 'projects/%s/global/networks/default' % project,
          subnetwork: 'projects/%s/regions/%s/subnetworks/default' % [project, location],
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
          location: '%s' % location,
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
