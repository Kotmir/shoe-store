# Магазин обуви «Шаг»

Учебный проект: настольное приложение для просмотра каталога обуви и управления товарами.

## Команда

- KotMir
- TimeShift

## Стек

- C# / .NET 8, WPF
- SQLite (`Microsoft.Data.Sqlite`)
- draw.io — блок-схемы и ER-диаграмма

## Структура репозитория

```
├── README.md
├── .gitignore
├── docs/          паспорт проекта, гантт, диаграммы
├── db/            schema.sql (структура БД), seed.sql (тестовые данные)
└── src/ShoeStore/ исходный код приложения
```

## Запуск

1. Установите [.NET 8 SDK](https://dotnet.microsoft.com/download) (нужен Windows).
2. Откройте папку `src/ShoeStore` в Visual Studio (или выполните `dotnet run` в этой папке).
3. При первом запуске рядом с `exe` автоматически создаётся файл базы `shoestore.db` из `db/schema.sql` и `db/seed.sql`.

## Тестовые учётные записи

| Роль          | Логин     | Пароль       |
|---------------|-----------|--------------|
| Администратор | `admin`   | `admin123`   |
| Менеджер      | `manager` | `manager123` |
| Клиент        | `client`  | `client123`  |
| Гость         | кнопка «Войти как гость» | — |

## Ресурсы

Положите в `src/ShoeStore/Images/` файлы из Приложения 2:

- `picture.png` — заглушка для товаров без фото;
- `logo.png` — логотип компании (показывается в шапке и на окне входа).

Фото, добавленные администратором, сохраняются в `Images/Products/` рядом с `exe`, в БД хранится путь.

## Что реализовано

- Вход по логину и паролю, вход гостем, выход на окно входа, ФИО в правом верхнем углу.
- Каталог: фото или заглушка, все поля товара, подсветка (скидка > 15% — `#2E8B57`, нет на складе — голубой), перечёркнутая старая цена.
- Менеджер и администратор: поиск в реальном времени по текстовым полям, фильтр по поставщику, сортировка по остатку, просмотр заказов.
- Администратор: добавление, редактирование (по клику на товар), удаление с подтверждением и запретом для товаров из заказов, загрузка фото до 300×200.
- Окна сообщений с заголовками и пиктограммами.

## Установка .NET 8 на Linux

> ⚠️ WPF работает только на Windows. Инструкция ниже полезна для CLI-инструментов (`dotnet build`, `dotnet test`) и кросс-платформенных частей проекта.

### Способ 1 — пакетный менеджер (рекомендуется)

**Ubuntu / Debian**

```bash
# Добавить репозиторий Microsoft
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Установить SDK
sudo apt-get update
sudo apt-get install -y dotnet-sdk-8.0
```

**Fedora / RHEL / CentOS**

```bash
sudo dnf install dotnet-sdk-8.0
```

**Arch Linux**

```bash
sudo pacman -S dotnet-sdk
```

### Способ 2 — скрипт install-dotnet.sh

```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0
```

После установки добавьте в `~/.bashrc` (или `~/.zshrc`):

```bash
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
```

Затем перезагрузите оболочку:

```bash
source ~/.bashrc
```

### Проверка

```bash
dotnet --version   # должно вывести 8.x.x
```

---

## Дальше

- Импорт данных заказчика (Приложение 2) в БД.
- Стиль по Приложению 3: шрифт и цвета меняются в `src/ShoeStore/Themes/Colors.xaml`, стили элементов — в `Themes/Controls.xaml`; иконка приложения (`.ico` в свойствах проекта).
- Блок-схемы и ER-диаграмма в `docs/`.
- Управление заказами для администратора.
