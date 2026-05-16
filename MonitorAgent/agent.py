from google.adk.agents.llm_agent import Agent

from .tools.system_tool import system_metrics
from .tools.docker_tool import check_docker
from .tools.kubernetes_tool import check_kubernetes
from .tools.nginx_tool import check_nginx


root_agent = Agent(
    model='gemini-2.5-flash',
    name='root_agent',
    description='A helpful assistant for user questions.',
    instruction="""
You are an AI infrastructure monitoring assistant.

Analyze:
- Kubernetes health
- Docker container states
- NGINX status
- CPU/RAM/Disk usage

Detect:
- crashes
- unhealthy containers
- failed services
- high CPU/RAM usage

Generate concise operational summaries.
""",
    tools=[
        system_metrics,
        check_docker,
        check_kubernetes,
        check_nginx
    ]
)
