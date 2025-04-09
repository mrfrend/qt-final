# Туториал

## Устанавливаем окружение
```python
python -m venv venv
venv\Scripts\activate
```

## Устанавливаем библиотеки
```python
pip install -r requirements.txt
```
Делать желательно в PyCharm. Возможно понадобится заново открыть после установки библиотек

## Подключение
В файле dbhelper.py меняем по-необходимости параметры подключения к БД
```python
import MySQLdb as mdb

db = mdb.connect(host="localhost", user="root", password="", database="trips")
cursor = db.cursor()
```

## Выполняем скрипт в файле trips.sql
Чтобы подключиться к базе, она должна быть создана. Логично? Логично.

## Запуск

Запускаем файл main.py