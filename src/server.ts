import * as gcp from "@pulumi/gcp"
import * as pulumi from "@pulumi/pulumi"
import { disk } from "./disk"
import { zone } from "./zone"

const config = new pulumi.Config()
const name = config.require("serverName")
const ops: string[] = config.requireObject("ops")
const allowList: string[] = config.requireObject("allowList")

const container = {
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
          { name: "ALLOW_LIST_USERS", value: allowList.join(",") },

          // names
          { name: "LEVEL_NAME", value: name },
          { name: "SERVER_NAME", value: name },

          // server setting
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
          pdName: disk.name,
          fsType: "ext4",
          readOnly: false,
        },
      },
    ],
  },
}

const instanceArgs: gcp.compute.InstanceArgs = {
  name: name,
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
      source: disk.name,
      deviceName: disk.name,
    },
  ],
  metadata: {
    "google-logging-enabled": "true",
    "google-monitoring-enabled": "true",
    "gce-container-declaration": pulumi.jsonStringify(container),
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
}

// supports toggling instance between desired status
function ensure(desiredStatus: string) {
  // always instantiate the instance with the desired status, pulumi will know what to do
  const server = new gcp.compute.Instance(
    name,
    { ...instanceArgs, desiredStatus },
    {
      replaceOnChanges: ["metadata"],
      deleteBeforeReplace: true,
    }
  )

  // only instantiate the A record when desired state is RUNNING,
  // if we don't delete this record there is a high probability
  // the next time a client attempts to connect before the server
  // is RUNNING it will get the old IP and cache that for 60 seconds
  // which is annoying, a missing record instead is registered as an
  // error and not cached
  if (desiredStatus === "RUNNING") {
    new gcp.dns.RecordSet(name, {
      name: pulumi.interpolate`${name}.${zone.dnsName}`,
      type: "A",
      // we want a pretty low ttl here, the server is meant to be
      // togged often
      ttl: 60,
      managedZone: zone.name,
      rrdatas: [
        server.networkInterfaces.apply(
          n => n[0].accessConfigs?.[0]?.natIp || "UNKNOWN"
        ),
      ],
    })
  }
}

export const turnOn = () => ensure("RUNNING")
export const suspend = () => ensure("SUSPENDED")
