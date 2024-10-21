import 'package:fluent_result/fluent_result.dart';
import 'package:test/test.dart' hide fail;

final _Person _person = _Person('John Doe', 30);
const _Person? _nullPerson = null;

ResultOf<_Person?> _getNullPerson() {
  const person = _nullPerson;
  return successWith(person);
}

ResultOf<_Person> _getPerson() {
  return successWith(_person);
}

Future<ResultOf<_Person?>> login() async {
  return ResultOf.tryAsync(() async {
    return successWith(_nullPerson);
  });
}

void main() {
  test('ResultOf<Object?> with null', () {
    final result = _getNullPerson();

    expect(result.isSuccess, isTrue);
    expect(result.value, isNull);
  });

  test('ResultOf<Object?> with not null', () {
    final result = _getPerson();

    expect(result.isSuccess, isTrue);
    expect(result.value, isNotNull);
  });

  test('Async ResultOf<Object?> with null', () async {
    final result = await login();

    expect(result.isSuccess, isTrue);
    expect(result.value, isNull);
  });
}

class _Person {
  _Person(this.name, this.age);

  final String name;
  final int age;
}
