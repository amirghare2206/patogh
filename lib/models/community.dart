enum CommunityType { group, channel }

class Community {
  final String id;
  final String title;
  final String description;
  final CommunityType type;
  final String owner;
  final int members;
  final bool joined;

  const Community({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.owner,
    required this.members,
    this.joined = false,
  });

  Community copyWith({int? members, bool? joined}) {
    return Community(
      id: id,
      title: title,
      description: description,
      type: type,
      owner: owner,
      members: members ?? this.members,
      joined: joined ?? this.joined,
    );
  }
}
