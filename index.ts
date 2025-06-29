import * as pulumi from "@pulumi/pulumi"
import * as gcp from "@pulumi/gcp"

const config = new pulumi.Config()
const name = config.require("server1Name")
const ops: string[] = config.requireObject("ops")
const allowList: string[] = config.requireObject("allowList")
const toggle = process.env.TOGGLE === "true"

const zone = new gcp.dns.ManagedZone(
  "primary",
  {
    name: "primary",
    dnsName: config.require("rootDomain") + ".",
  },
  { protect: true }
)

const disk1 = new gcp.compute.Disk(
  name + "-data",
  {
    name: name + "-data",
    type: "pd-ssd",
    size: 10,
    createSnapshotBeforeDestroy: true,
  },
  { protect: true }
)

function doThing(desiredStatus: string) {
  const server1 = new gcp.compute.Instance(
    name,
    {
      name: name,
      desiredStatus,
      networkInterfaces: [
        {
          accessConfigs: [{}],
          network: "default",
        },
      ],
      machineType: "e2-medium",
      tags: ["minecraft"],
      bootDisk: {
        initializeParams: {
          image: "cos-cloud/cos-stable",
          type: "pd-ssd",
        },
      },
      attachedDisks: [
        {
          source: disk1.name,
          deviceName: disk1.name,
        },
      ],
      metadata: {
        "google-logging-enabled": "true",
        "google-monitoring-enabled": "true",
        "gce-container-declaration": pulumi.jsonStringify({
          spec: {
            restartPolicy: "Always",
            containers: [
              {
                name: name,
                image: "itzg/minecraft-bedrock-server",
                stdin: true,
                tty: true,
                env: [
                  // users
                  { name: "OPS", value: ops.join(",") },
                  {
                    name: "ALLOW_LIST_USERS",
                    value: allowList.join(","),
                  },

                  // names
                  { name: "LEVEL_NAME", value: name },
                  { name: "SERVER_NAME", value: name },

                  { name: "DIFFICULTY", value: "normal" },
                  { name: "EMIT_SERVER_TELEMETRY", value: "true" },
                  { name: "EULA", value: "TRUE" },
                  { name: "MAX_THREADS", value: "0" },
                  { name: "ONLINE_MODE", value: "true" },
                  { name: "TICK_DISTANCE", value: "12" },
                ],
                volumeMounts: [
                  {
                    name: "pd-0",
                    mountPath: "/data",
                    readOnly: false,
                  },
                ],
              },
            ],
            volumes: [
              {
                name: "pd-0",
                gcePersistentDisk: {
                  pdName: disk1.name,
                  fsType: "ext4",
                  readOnly: false,
                },
              },
            ],
          },
        }),
      },
      serviceAccount: {
        email: gcp.compute.getDefaultServiceAccountOutput().apply(s => s.email),
        scopes: [
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring.write",
          "https://www.googleapis.com/auth/service.management.readonly",
          "https://www.googleapis.com/auth/servicecontrol",
          "https://www.googleapis.com/auth/trace.append",
        ],
      },
    },
    { replaceOnChanges: ["metadata"], deleteBeforeReplace: true }
  )

  if (desiredStatus === "RUNNING") {
    new gcp.dns.RecordSet(name, {
      name: pulumi.interpolate`${name}.${zone.dnsName}`,
      type: "A",
      ttl: 60,
      managedZone: zone.name,
      rrdatas: [
        server1.networkInterfaces.apply(
          n => n[0].accessConfigs?.[0]?.natIp || ""
        ),
      ],
    })
  }
}

if (toggle) {
  gcp.compute
    .getInstance({ name })
    .then(i => doThing(i.currentStatus === "RUNNING" ? "SUSPENDED" : "RUNNING"))
    .catch(() => doThing("RUNNING"))
} else {
  ;("")
  doThing("RUNNING")
}
