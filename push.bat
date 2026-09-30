@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd /d "%~dp0"

set "REPO_URL=https://github.com/kotmir/shoe-store.git"

echo ==========================================
echo    [ShoeStore] Автоматический Git-Пуш
echo ==========================================
echo.

REM ---------- Проверки ----------
git --version > nul 2>&1
if errorlevel 1 (
    echo [Ошибка] Git не найден. Установи Git и перезапусти консоль.
    goto :end
)

REM ---------- Первый запуск: git init + подключение GitHub ----------
git rev-parse --is-inside-work-tree > nul 2>&1
if errorlevel 1 (
    echo [Настройка] Папка ещё не git-репозиторий, создаю...
    git init -q
    git branch -M main
)

git remote get-url origin > nul 2>&1
if errorlevel 1 (
    echo [Настройка] Подключаю репозиторий: %REPO_URL%
    git remote add origin "%REPO_URL%"
)

set "branch="
for /f "delims=" %%b in ('git branch --show-current') do set "branch=%%b"
if not defined branch (
    echo [Ошибка] Не удалось определить ветку, возможно, detached HEAD.
    goto :end
)
echo Текущая ветка: !branch!
echo.

REM ---------- Структура проекта: пустые папки db и src ----------
if not exist "docs" mkdir "docs"
if not exist "db" mkdir "db"
if not exist "src" mkdir "src"
if not exist "db\.gitkeep" if not exist "db\*.sql" type nul > "db\.gitkeep"
if not exist "src\.gitkeep" (
    dir /b "src" 2>nul | findstr "." > nul
    if errorlevel 1 type nul > "src\.gitkeep"
)

REM ---------- Защита: .gitignore для C# / Visual Studio ----------
set "ignore_added="
call :ensure_ignore "bin/"
call :ensure_ignore "obj/"
call :ensure_ignore ".vs/"
call :ensure_ignore "*.user"
call :ensure_ignore "*.suo"
call :ensure_ignore "packages/"
call :ensure_ignore "*.log"
call :ensure_ignore ".env"
call :ensure_ignore "appsettings.Local.json"
if defined ignore_added echo [Защита] .gitignore обновлён.

REM ---------- Убираем из git то, что уже отслеживается, но не должно ----------
set "untracked="
for /f "delims=" %%f in ('git ls-files ".vs" "*.user" "*.suo" ".env" "*.log" "appsettings.Local.json"') do (
    git rm --cached -q -- "%%f"
    echo [Защита] Убран из git: %%f
    set "untracked=1"
)
for /f "delims=" %%f in ('git ls-files "*/bin/*" "*/obj/*" "bin/*" "obj/*"') do (
    git rm --cached -q -- "%%f"
    set "untracked=1"
)
if defined untracked (
    echo [Защита] Лишние файлы остались на диске, но больше не попадут на GitHub.
)
echo.

REM ---------- Добавление изменений ----------
echo [1/3] Добавление изменений...
git add -A
echo.
git status -s

REM ---------- Сообщение коммита ----------
echo.
echo Выберите вариант сообщения для коммита:
echo  1. Сгенерировать случайное
echo  2. Ввести своё вручную
set "choice=1"
set /p "choice=Ваш выбор (1 или 2, по умолчанию 1): "

set "comment="
if "!choice!"=="2" (
    set /p "comment=Введите сообщение для коммита: "
)
if defined comment set "comment=!comment:"=!"

if not defined comment (
    set "msg0=👟 Новая пара фич в каталоге обуви"
    set "msg1=🛒 Корзина стала чуть умнее"
    set "msg2=🧾 Подкрутили оформление заказа"
    set "msg3=📦 Остатки на складе теперь точнее"
    set "msg4=🔍 Поиск и фильтры работают быстрее"
    set "msg5=🎨 Навели красоту на формы приложения"
    set "msg6=🗄️ Обновили базу данных магазина"
    set "msg7=🐛 Поймали очередного жука в коде"
    set "msg8=🔐 Доработали вход и роли пользователей"
    set "msg9=💸 Скидки и цены считаются правильно"
    set "msg10=🖼️ Фото товаров и картинки-заглушки на месте"
    set "msg11=🧹 Причесали код и убрали лишнее"
    set "msg12=📝 Обновили документацию проекта"
    set "msg13=📊 Гантт и паспорт проекта актуализированы"
    set "msg14=⚙️ Мелкие правки и оптимизация"
    set "msg15=🚀 Магазин «Шаг» становится лучше"
    set "msg16=🌙 Ночная сессия кодинга завершена"
    set "msg17=✅ Всё работает, можно идти на склад"
    set "msg18=🧪 Отладили модуль, аварий больше нет"
    set "msg19=🥿 Ещё один шаг к готовому проекту"
    set /a rand=!random! %% 20
    for %%i in (!rand!) do set "comment=!msg%%i!"
)

REM ---------- Коммит ----------
echo.
echo [2/3] Создание коммита: !comment!
git commit -m "!comment!"
if errorlevel 1 (
    echo [Внимание] Новый коммит не создан ^(нет изменений или ошибка^). Отправляю уже имеющиеся коммиты.
)

REM ---------- Push ----------
echo.
echo [3/3] Отправка на GitHub, ветка !branch!...
git push -u origin "!branch!"
if errorlevel 1 (
    echo.
    echo Push не прошёл. Возможно, на GitHub есть новые коммиты.
    set /p "retry=Подтянуть изменения через pull --rebase и повторить? (y/N): "
    if /i not "!retry!"=="y" goto :end

    git pull --rebase origin "!branch!"
    if errorlevel 1 (
        echo [Ошибка] Rebase не удался. Реши конфликты вручную.
        goto :end
    )
    git push -u origin "!branch!"
    if errorlevel 1 (
        echo [Ошибка] Повторный push не удался.
        goto :end
    )
)

echo.
echo ==========================================
echo   [Готово] Проект улетел в репозиторий, ветка !branch!
echo ==========================================

:end
echo.
pause
endlocal
exit /b

REM ---------- Подпрограмма: добавить строку в .gitignore, если её там нет ----------
:ensure_ignore
findstr /x /c:"%~1" ".gitignore" > nul 2>&1
if errorlevel 1 (
    if not defined ignore_added (
        if exist ".gitignore" echo.>>".gitignore"
        set "ignore_added=1"
    )
    echo %~1>>".gitignore"
)
exit /b