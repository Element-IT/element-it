# Как собрать workflow в n8n вручную

Импорт готового workflow может отличаться между версиями n8n, поэтому надёжнее сначала собрать руками.

## Workflow v1: простой HTTP-вариант

### 1. Webhook

Node: `Webhook`

- Method: `POST`
- Path: `transcribe`
- Response: `Using Respond to Webhook node`
- Binary Data: включить

Файл должен приходить multipart/form-data в поле `file`.

### 2. Code node — создать job_id

```js
const job_id = Date.now().toString() + '_' + Math.random().toString(16).slice(2, 8);
return [{ json: { job_id } , binary: $binary }];
```

### 3. Write Binary File

- Binary Property: `file`
- File Path:

```text
/data/input/{{$json.job_id}}/source.m4a
```

Если расширения разные, на первом MVP не умничай: сохраняй как `.m4a` или `.mp3`, ffmpeg разберёт. Потом добавим сохранение исходного расширения.

### 4. HTTP Request — создать задачу

- Method: `POST`
- URL:

```text
http://transcriber:7861/jobs
```

- Body Content Type: `Form-Data`
- Fields:

```text
input_path = /data/input/{{$json.job_id}}/source.m4a
model = medium
chunk_minutes = 6
enhance_audio = true
```

Ответ вернёт настоящий `job_id` от transcriber. Для простоты можно использовать его дальше.

### 5. Wait

- 30 секунд

### 6. HTTP Request — проверить статус

- Method: `GET`
- URL:

```text
http://transcriber:7861/jobs/{{$json.job_id}}
```

Если status != done — повторить Wait + Check.

### 7. HTTP Request — скачать docx

- Method: `GET`
- URL:

```text
http://transcriber:7861/download/{{$json.job_id}}/docx
```

- Response Format: File

### 8. Respond to Webhook

Вернуть бинарный файл пользователю.

## Важное

Для больших аудио синхронный webhook может отвалиться по таймауту. Для боевого режима лучше делать так:

1. Webhook принимает файл и сразу возвращает пользователю `job_id`.
2. Второй endpoint `/result/<job_id>` отдаёт результат, когда он готов.
3. Или n8n отправляет результат в Telegram/почту/PlanFix после завершения.
