local helpers = import '../lib/helpers.jsonnet';
local vars = import '../vars.jsonnet';

local name = {
  name: 'external-dns',
};

local metadata = {
  metadata: name {
    labels+: {
      app: name.name,
    },
  },
};

[
  metadata {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
  },
  metadata {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRole',
    rules: [
      {
        apiGroups: [''],
        resources: ['services'],
        verbs: ['get', 'watch', 'list'],
      },
      {
        apiGroups: [''],
        resources: ['pods'],
        verbs: ['get', 'watch', 'list'],
      },
      {
        apiGroups: ['extensions', 'networking.k8s.io'],
        resources: ['ingresses'],
        verbs: ['get', 'watch', 'list'],
      },
      {
        apiGroups: [''],
        resources: ['nodes'],
        verbs: ['list', 'watch'],
      },
      {
        apiGroups: [''],
        resources: ['endpoints'],
        verbs: ['get', 'watch', 'list'],
      },
    ],
  },
  metadata {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRoleBinding',
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: name.name,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: name.name,
        namespace: 'default',
      },
    ],
  },
  metadata {
    apiVersion: 'v1',
    kind: 'Secret',
    data: {
      key: std.base64(vars.godaddy.key),
      secret: std.base64(vars.godaddy.secret),
    },
  },
  metadata {
    apiVersion: 'batch/v1',
    kind: 'Job',
    spec: {
      template: metadata {
        spec: {
          restartPolicy: 'OnFailure',
          serviceAccountName: name.name,
          nodeSelector: {
            'cloud.google.com/gke-spot': 'true',
          },
          containers: [
            name + helpers.minResources {
              image: 'k8s.gcr.io/external-dns/external-dns:v0.12.0',
              imagePullPolicy: 'Always',
              env: [
                {
                  name: 'GODADDY_API_KEY',
                  valueFrom: {
                    secretKeyRef: {
                      name: name.name,
                      key: 'key',
                    },
                  },
                },
                {
                  name: 'GODADDY_API_SECRET',
                  valueFrom: {
                    secretKeyRef: {
                      name: name.name,
                      key: 'secret',
                    },
                  },
                },
              ],
              args: [
                '--once',
                '--source=service',
                '--domain-filter=' + vars.dns.zone,
                '--provider=godaddy',
                '--txt-prefix=%s.' % name.name,
                '--txt-owner-id=' + vars.minecraftServer.name,
                '--godaddy-api-key=$(GODADDY_API_KEY)',
                '--godaddy-api-secret=$(GODADDY_API_SECRET)',
                '--log-level=debug',
              ],
            },
          ],
        },
      },
    },
  },
]
