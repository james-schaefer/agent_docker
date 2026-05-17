A basic docker container for running various LLM CLI agents: Claude Code, Codex, and Aider.

Aider is configured to connect to a local vLLM instance on port 8000. The container runs with
`--network host` so that `localhost:8000` inside the container reaches the host's vLLM service.
