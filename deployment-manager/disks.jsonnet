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
      name: vars.disk,
      type: 'gcp-types/compute-v1:disks',
      metadata: {
        dependsOn: [
          $.resources[0].name,
        ],
      },
      properties: {
        sizeGb: '10',
        zone: '%s-a' % vars.location,
        type: 'projects/%s/zones/%s-a/diskTypes/pd-balanced' % [vars.project, vars.location],
        resourcePolicies: [
          'projects/%s/regions/%s/resourcePolicies/%s' % [vars.project, vars.location, $.resources[0].name],
        ],
      },
    },
  ],
}
