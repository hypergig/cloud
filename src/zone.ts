import * as gcp from "@pulumi/gcp"
import * as pulumi from "@pulumi/pulumi"

const config = new pulumi.Config()
export const zone = new gcp.dns.ManagedZone(
  "primary",
  {
    name: "primary",
    dnsName: config.require("rootDomain") + ".",
  },
  { protect: true },
)
