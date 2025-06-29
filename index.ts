import * as gcp from "@pulumi/gcp"
import * as pulumi from "@pulumi/pulumi"
import { suspend, turnOn } from "./src/server"

if (process.env.TOGGLE !== "true") {
  // by default don't toggle the server, just instantiate it like normal
  turnOn()
} else {
  // if toggle is enabled, check the servers current status and toggle it
  const config = new pulumi.Config()
  const name = config.require("serverName")
  gcp.compute
    .getInstance({ name })
    .then(i => (i.currentStatus === "RUNNING" ? suspend() : turnOn()))
    // toggling a missing instance turns it on
    .catch(turnOn)
}
