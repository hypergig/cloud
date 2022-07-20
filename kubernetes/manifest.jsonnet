local helpers = import '../lib/helpers.jsonnet';
std.map(
  // mark all top level objects as safe to auto delete
  function(o) o { metadata+: { labels+: helpers.autoDelete } },
  std.flattenArrays(
    [
      (import 'external-dns.jsonnet'),
      (import 'minecraft.jsonnet'),
    ]
  )
)
