local vars = import '../vars.jsonnet';
{
  resources: [
    {
      name: 'nightly',
      type: 'gcp-types/compute-v1:resourcePolicies',
      properties: {
        name: $.resources[0].name,
        project: vars.project,
        region: vars.location,
        snapshotSchedulePolicy: {
          snapshotProperties: {
            guestFlush: false,
          },
          retentionPolicy: {
            onSourceDiskDelete: 'KEEP_AUTO_SNAPSHOTS',
            maxRetentionDays: 14,
          },
          schedule: {
            dailySchedule: {
              startTime: '00:00',
              daysInCycle: 1,
            },
          },
        },
      },
    },
    {
      name: vars.minecraftServer.disk,
      type: 'gcp-types/compute-v1:disks',
      metadata: {
        dependsOn: [
          $.resources[0].name,
        ],
      },
      properties: {
        sizeGb: '10',
        zone: vars.diskZone,
        type: 'projects/%s/zones/%s/diskTypes/pd-balanced' % [vars.project, vars.diskZone],
        resourcePolicies: [
          'projects/%s/regions/%s/resourcePolicies/%s' % [vars.project, vars.location, $.resources[0].name],
        ],
      },
    },
  ],
}
