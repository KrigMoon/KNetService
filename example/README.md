# KNetService Example

Демонстрационное Flutter-приложение, показывающее работу с пакетом `k_net_service`
через UI на базе KUI.

## Что показывает

- **Журнал** — метрики KJournal: статус, писатели, читатели, заполнение буферов читателей.
- **Сеть** — метрики KNet и Core: статус, курсор, исполнитель, пиры, entry/exit, читатели.
- **Системные сообщения** — записи журнала и ответы на команды в реальном времени.
- **Чат** — отправка команд через `KNetService.execute()` и отображение входящих пакетов.

Кнопка питания в меню переключает `run()` / `endwork()`. При старте регистрируется
внешняя команда `/map` (через `CommandContainer`) и `autoRun` с `/connect ...`.

## Запуск

```bash
cd example
flutter pub get
flutter run
```

Поддерживаются Linux (amd64) и Android (arm, arm64, x86_64) — там, где есть
соответствующая сборка `libknet_service.so`.

## Ссылки

- [Основной README пакета](../README.md)
- [KJournal](https://github.com/KrigMoon/KJournal)
- [KNet](https://github.com/KrigMoon/KNet)
- [KUI](https://github.com/KrigMoon/KUI)