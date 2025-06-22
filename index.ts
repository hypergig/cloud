import * as gcp from "@pulumi/gcp"

const domain = gcp.secretmanager.getSecretVersionAccessOutput({
  secret: "domain",
})

new gcp.dns.ManagedZone("primary", {
  name: "primary",
  dnsName: domain.secretData.apply(d => d + "."),
})
