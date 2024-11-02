import 'dart:convert';

import 'package:bluesky/bluesky.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/hashtag.dart';
import 'package:lightbluesky/pages/profile.dart';

/// Text with facets
///
/// Facets = Tag, mention...
class TextWithFacets extends StatelessWidget {
  const TextWithFacets({super.key, required this.text, required this.facets});

  /// Unedited text
  final String text;

  /// Facets available
  final List<Facet>? facets;

  /// Builds all textspans using data available in facets[i].index
  List<TextSpan> _buildTextSpans(
    String text,
    List<Facet> facets,
    BuildContext context,
  ) {
    List<TextSpan> spans = [];
    final utf8Bytes = utf8.encode(text); // Encode text as UTF-8 bytes
    int currentIndex = 0;

    for (final facet in facets) {
      // Add non-facet text before the current facet
      if (currentIndex < facet.index.byteStart) {
        spans.add(
          TextSpan(
            text: utf8.decode(
              utf8Bytes.sublist(
                currentIndex,
                facet.index.byteStart,
              ),
            ),
          ),
        );
      }

      // Add the facet text with a different style
      spans.add(
        TextSpan(
          text: utf8.decode(
            utf8Bytes.sublist(
              facet.index.byteStart,
              facet.index.byteEnd,
            ),
          ),
          style: const TextStyle(
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleLink(
                  facet.features[0],
                  context,
                ),
        ),
      );

      currentIndex = facet.index.byteEnd;
    }

    // Add any remaining text after the last facet
    if (currentIndex < utf8Bytes.length) {
      spans.add(
        TextSpan(
          text: utf8.decode(utf8Bytes.sublist(currentIndex)),
        ),
      );
    }

    return spans;
  }

  /// Different action depending on facet type
  void _handleLink(FacetFeature feature, BuildContext context) {
    if (feature is UFacetFeatureLink) {
      Ui.openUrl(feature.data.uri);
    } else if (feature is UFacetFeatureMention) {
      Ui.nav(
        context,
        ProfilePage(
          did: feature.data.did,
        ),
      );
    } else if (feature is UFacetFeatureTag) {
      Ui.nav(
        context,
        HashtagPage(name: feature.data.tag),
      );
    } else {
      Ui.snackbar(context, "Unkown facet type! :(");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skip span building if there are no facets
    if (facets == null) {
      return Text(text);
    }

    return Text.rich(
      TextSpan(
        children: _buildTextSpans(
          text,
          facets!,
          context,
        ),
      ),
    );
  }
}
