std.filter(
  function(x) x.kind == 'Deployment',
  (import 'manifest.jsonnet'),
)
