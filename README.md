# n8n + Whisper Transcriber Docker

## Что внутри

- `transcriber` — Docker-контейнер с Whisper, ffmpeg, API и watcher'ом папки задач.
- `n8n` — отдельный контейнер для автоматизаций.
- `data/input` — входные файлы.
- `data/output` — результаты `.txt`, `.docx`, `_meta.json`.
- `data/jobs` — JSON-задачи и статусы.
- `data/logs` — логи обработки.
- `models` — кеш моделей Whisper.

## Запуск GPU

```bat
run_all_gpu.bat
```

После запуска:

- n8n: http://localhost:5678
- Transcriber API: http://localhost:7861
- Проверка API: http://localhost:7861/health

## Запуск CPU

```bat
run_all_cpu.bat
```

CPU будет сильно медленнее. Для нормальной работы нужен GPU.

## Настройка адреса, порта и домена

Docker Compose берёт настройки из файла `.env`. Сначала создай его из примера:

```bat
copy .env.example .env
```

По умолчанию сервисы доступны так:

```text
http://localhost:5678      # n8n
http://localhost:7861      # Transcriber API
http://localhost:7861/health
```

Если хочешь оставить доступ только с этого компьютера, в `.env` укажи:

```env
DOCKER_BIND_ADDRESS=127.0.0.1
N8N_PUBLIC_HOST=localhost
N8N_PUBLIC_URL=http://localhost:5678
TRANSCRIBER_PUBLIC_URL=http://localhost:7861
```

Если хочешь обращаться по домену `politech.space`, домен должен указывать на IP компьютера/сервера, где запущен Docker, а порты должны быть открыты в firewall/роутере. В `.env` укажи:

```env
DOCKER_BIND_ADDRESS=0.0.0.0
N8N_PUBLIC_HOST=politech.space
N8N_PUBLIC_URL=http://politech.space:5678
TRANSCRIBER_PUBLIC_URL=http://politech.space:7861
```

После перезапуска Docker Compose внешние адреса будут:

```text
http://politech.space:5678        # n8n
http://politech.space:7861        # Transcriber API
http://politech.space:7861/health # проверка API
```

Если нужен адрес без порта, например `http://politech.space/health`, тогда нужен reverse proxy на 80 порту, который будет проксировать запросы в контейнер `transcriber:7861`.

## Быстрая проверка без n8n

Открой:

```text
http://localhost:7861
```

Загрузи файл через простую форму. Получишь `job_id`.

Проверка статуса:

```text
http://localhost:7861/jobs/JOB_ID
```

Скачать результат:

```text
http://localhost:7861/download/JOB_ID/txt
http://localhost:7861/download/JOB_ID/docx
```

## Как это должно работать через n8n

Правильная схема:

1. n8n принимает файл от пользователя.
2. n8n сохраняет файл в `/data/input/<job_id>/source.m4a`.
3. n8n создаёт JSON-задачу в `/data/jobs/<job_id>.ready.json`.
4. transcriber каждые 2 секунды смотрит папку `/data/jobs`.
5. Когда видит `.ready.json`, запускает транскрибацию.
6. Результат кладёт в `/data/output/<job_id>/`.
7. n8n проверяет `/data/jobs/<job_id>.status.json` или API `/jobs/<job_id>`.
8. n8n возвращает пользователю `.docx` или `.txt`.

## Формат ready-задачи

```json
{
  "job_id": "test001",
  "input_path": "/data/input/test001/source.m4a",
  "model": "medium",
  "chunk_minutes": 6,
  "enhance_audio": true,
  "output_name": "Расшифровка_совещания",
  "auto_safe_model": true
}
```

Файл должен называться:

```text
/data/jobs/test001.ready.json
```

## Альтернативный вариант для n8n через HTTP

n8n может не создавать `.ready.json`, а вызвать API:

```text
POST http://transcriber:7861/jobs
```

form-data:

```text
input_path=/data/input/test001/source.m4a
model=medium
chunk_minutes=6
enhance_audio=true
```

Внутри docker-сети использовать именно:

```text
http://transcriber:7861
```

Не `localhost`. `localhost` внутри n8n — это сам контейнер n8n.

Снаружи Docker используй публичный адрес из `.env`, например:

```text
POST http://localhost:7861/upload
POST http://politech.space:7861/upload
```

## Рекомендуемые модели

- `small` — быстро, но грязно.
- `medium` — рабочий режим по умолчанию.
- `large-v3` — максимум качества, но может не влезть в 6 GB VRAM. В этом случае контейнер сам откатится на `medium`.

## Тест watcher без n8n

Перетащи аудио/видео на:

```bat
create_ready_job_example.bat
```

Скрипт положит файл в `data/input`, создаст `.ready.json`, а transcriber сам подхватит задачу.
