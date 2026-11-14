# KNetService

Flutter FFI-обёртка над нативной библиотекой `libknet_service.so`, которая
объединяет две Go-библиотеки: **KJournal** (журнал в памяти) и **KNet** (обмен
пакетами между узлами по gRPC).

Пакет извлекает `.so` из ассетов при первом запуске, загружает его через
`DynamicLibrary.open` и предоставляет типизированный Dart API для журналирования,
обмена пакетами и выполнения внешних команд.

## Зачем это

Позволяет использовать нативный C-функционал KJournal и KNet из Flutter-приложения
без написания платформенного кода. Все потенциально блокирующие FFI-вызовы вынесены
в отдельные изоляты через `Isolate.run`, чтобы не нагружать UI-поток.

Пример использования: [example/README.md](./example/README.md).

## Что умеет

- Извлекает `libknet_service.so` из ассетов в `getApplicationSupportDirectory()` и кэширует.
- Загружает библиотеку через `DynamicLibrary.open`.
- Управляет жизненным циклом: `run()`, `endwork()`, `dispose()`.
- Полинг метрик, записей журнала, пакетов, ответов и списка пиров по таймерам.
- Выполняет внешние команды через `CommandContainer` (check + body).
- Предоставляет статические FFI-примитивы (`static_api.dart`) для прямых вызовов из изолятов.

## Установка

```yaml
dependencies:
  k_net_service:
    git:
      url: https://github.com/username/repo.git
      ref: v1.0.0
```

## Использование

```dart
import 'package:k_net_service/k_net_service.dart';

final libPath = await prepareKnetLibraryPath();
final service = KNetService(libPath: libPath);

service.run(kjSettings, knSettings);

service.addListener(() {
  print('metrics: ${service.metrics}');
  print('records: ${service.records.length}');
});

// ...

service.endwork();
service.dispose();
```

Каждый FFI-вызов выполняется в отдельном изоляте; `libknet_service.so` открывается
заново внутри изолята, так как нативные указатели не могут пересекать границы изолятов.

## Ссылки

- [KJournal](https://github.com/KrigMoon/KJournal) — журнал в памяти: писатели, читатели, `ReaderFilter`, тайм-ауты, дамп в файлы, метрики.
- [KNet](https://github.com/KrigMoon/KNet) — обмен пакетами между узлами по gRPC; роли `SERVER`/`CLIENT`, сервер-хаб.
