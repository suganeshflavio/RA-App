import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Strips anything that could execute code or navigate away when the
/// content — authored by an admin through the rich-text editor, but served
/// back to students inside a WebView — is rendered. Mirrors the DOMPurify
/// pass the admin dashboard already applies before display; nothing
/// sanitizes this HTML before it is stored, so the app cannot trust it as-is.
const _disallowedTags = {'script', 'style', 'iframe', 'object', 'embed', 'link', 'meta', 'form'};

bool _isEventHandlerAttribute(String name) => name.startsWith('on');

bool _isUnsafeUrlAttribute(String name) => name == 'src' || name == 'href';

bool _hasUnsafeScheme(String value) {
  final trimmed = value.trim().toLowerCase();
  return trimmed.startsWith('javascript:') || trimmed.startsWith('data:text/html');
}

void _sanitizeNode(Node node) {
  final children = List<Node>.from(node.nodes);
  for (final child in children) {
    if (child is Element) {
      if (_disallowedTags.contains(child.localName)) {
        child.remove();
        continue;
      }

      final attributeNames = List<Object>.from(child.attributes.keys);
      for (final name in attributeNames) {
        final key = name.toString();
        final value = child.attributes[name] ?? '';
        if (_isEventHandlerAttribute(key) ||
            (_isUnsafeUrlAttribute(key) && _hasUnsafeScheme(value))) {
          child.attributes.remove(name);
        }
      }

      _sanitizeNode(child);
    }
  }
}

/// Returns a sanitized HTML fragment safe to inject into the KaTeX render
/// template. Plain text (no tags) passes through untouched.
String sanitizeRichHtml(String rawHtml) {
  if (rawHtml.trim().isEmpty) return '';

  final fragment = html_parser.parseFragment(rawHtml);
  _sanitizeNode(fragment);
  return fragment.outerHtml;
}
