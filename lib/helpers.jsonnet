{
  normalizeName(str):: std.strReplace(std.asciiLower(str), ' ', '-'),
  minecraftDisk(str):: 'minecraft-' + self.normalizeName(str),
}
