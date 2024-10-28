import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:file_picker/file_picker.dart';

/// Helper class for specific bluesky API functions
class SkyApi {
  var c = Bluesky.anonymous();

  void setSession(Session newSession) {
    c = Bluesky.fromSession(newSession);
  }

  /// Checks if a session has expired
  Future<bool> isSessionExpired(Session oldSession) async {
    final tmpApi = Bluesky.fromSession(oldSession);
    try {
      await tmpApi.atproto.server.getSession();
      return false;
    } on InvalidRequestException catch (_) {
      return true;
    }
  }

  List<FeedView> filterFeed(List<FeedView> items) {
    return items
        .where((item) =>
            item.post.author.isNotBlocking && item.post.author.isNotMuted)
        .toList();
  }

  /// Handle file upload, returns Embed of type selected
  Future<Embed?> upload(List<PlatformFile> files, FileType type) async {
    Embed? embed;

    switch (type) {
      case FileType.image:
        final List<Image> images = List.empty(
          growable: true,
        );

        for (var file in files) {
          final bytes = await file.xFile.readAsBytes();

          final uploaded = await c.atproto.repo.uploadBlob(
            bytes,
          );

          images.add(
            Image(alt: '', image: uploaded.data.blob),
          );
        }

        embed = Embed.images(
          data: EmbedImages(
            images: images,
          ),
        );
        break;
      default:
        embed = null;
    }

    return embed;
  }
}
