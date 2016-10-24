### Простой чат
Написан для проведения занятия по работе с сетью в Android. Возможности: авторизация, удаление и редактирование сообщений. Оповещение об изменениях. 
Используется REST-архитектура, WS и HTTP протоколы.

### POST /auth  
Авторизация в чате

| Параметр | Принимаемые значения | Описание               |
|----------|----------------------|------------------------|
| name     | String               | Имя пользователя       |
| password | String               | Имя пользователя + 123 |

Возвращаемые значения:
`access_token` в виде строки.

### GET /messages/{count}
Получение сообщений из чата

| Параметр | Принимаемые значения | Описание               |
|----------|----------------------|------------------------|
| count    | Int                  | Количество сообщений. Если параметр больше общего числа сообщений, вернёт все сообщения, но не больше 100.|


Возвращаемые значения:  
JSON
```
[
  {
    "text":"Текст сообщения",
    "senderName":"Имя отправителя"
  }
]
```

### POST /messages
Отправка сообщения

| Параметр     | Отправляемые значения | Описание        |
|--------------|-----------------------|-----------------|
| text         | String                | Текст сообщения |
| access_token | String                | Маркер доступа  |

### PATCH /messages/{id}
Редактирование сообщения

| Параметр     | Отправляемые значения | Описание        |
|--------------|-----------------------|-----------------|
| text         | String                | Текст сообщения |
| access_token | String                | Маркер доступа  |
| id           | Int                   | id сообщения    |

### DELETE /messages/{id}
Удаление сообщения

| Параметр     | Отправляемые значения | Описание        |
|--------------|-----------------------|-----------------|
| id           | Int                   | id сообщения    |
| access_token | String                | Маркер доступа  |

### WebSocket /messages
Оповещение об изменениях. Вид сообщения:  
JSON
```
{
  "message_id":"id сообщения",
  "action":"Тип действия"
  "message_text":"Текст сообщения, если есть."
  "sender_name":"Имя пользователя, если есть."
}
```
Виды действий

| Название       | Описание              | 
|----------------|-----------------------|
| message_edited | Сообщение изменено    | 
| message_sent   | Новое сообщение       |
| user_joined    | Новый пользователь    |
| message_deleted| Сообщение удалено     |

