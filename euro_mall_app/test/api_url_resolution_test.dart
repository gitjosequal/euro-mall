import 'package:flutter_test/flutter_test.dart';

/// Guards against Dio + [Uri.resolve] joining bugs: base must end with `/`
/// and paths must be relative (see [ApiClient] in lib/core/api/api_client.dart).
void main() {
  test('trailing slash on API base preserves /v1 when resolving paths', () {
    final base = Uri.parse('https://example.com/api/v1/');
    expect(
      base.resolve('app/config').toString(),
      'https://example.com/api/v1/app/config',
    );
  });

  test('no trailing slash on base breaks v1 segment (why we normalize)', () {
    final bad = Uri.parse('https://example.com/api/v1');
    expect(
      bad.resolve('app/config').toString(),
      isNot(contains('/api/v1/app')),
    );
  });
}
