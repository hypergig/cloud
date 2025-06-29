import * as gcp from "@pulumi/gcp"
import * as pulumi from "@pulumi/pulumi"

const config = new pulumi.Config()
const name = config.require("serverName")

export const disk = new gcp.compute.Disk(
  name + "-data",
  {
    name: name + "-data",
    type: "pd-ssd",
    size: 10,
    createSnapshotBeforeDestroy: true,
  },
  { protect: true }
)
