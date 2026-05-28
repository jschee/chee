# frozen_string_literal: true

max_threads_count = ENV.fetch("APP_MAX_THREADS", 5)
min_threads_count = ENV.fetch("APP_MIN_THREADS", max_threads_count)

threads min_threads_count, max_threads_count
port ENV.fetch("PORT", 4567)
environment ENV.fetch("RACK_ENV", "development")

stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true